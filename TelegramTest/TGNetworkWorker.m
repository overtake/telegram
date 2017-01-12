

#import "TGNetworkWorker.h"



#import "TGTimer.h"
#import "ASQueue.h"
#import <MtProtoKitMac/MTContext.h>
#import <MtProtoKitMac/MTProto.h>
#import <MtProtoKitMac/MTRequestMessageService.h>
#import <MtProtoKitMac/MTRequest.h>


static int workerCount = 0;

@interface TGNetworkWorker () <MTRequestMessageServiceDelegate>
{
    MTContext *_context;
    MTProto *_mtProto;
    MTRequestMessageService *_requestService;
    
    TGTimer *_timeoutTimer;
    
    bool _isReadyToBeRemoved;
    bool _isBusy;
    ASQueue *_queue;
}

@end

@implementation TGNetworkWorker

- (instancetype)initWithContext:(MTContext *)context datacenterId:(NSInteger)datacenterId masterDatacenterId:(NSInteger)masterDatacenterId queue:(ASQueue *)queue
{
    self = [super init];
    if (self != nil)
    {
        workerCount++;
        MTLog(@"[TGNetworkWorker#%x/%d start (%d)]", (int)self, (int)datacenterId, workerCount);
        _queue = queue;
        _context = context;
        _datacenterId = datacenterId;
        
        _mtProto = [[MTProto alloc] initWithContext:_context datacenterId:_datacenterId];
        if (_datacenterId != masterDatacenterId) {
            _mtProto.requiredAuthToken = @(masterDatacenterId);
            _mtProto.authTokenMasterDatacenterId = masterDatacenterId;
        }
        
        _requestService = [[MTRequestMessageService alloc] initWithContext:_context];
        _requestService.delegate = self;
        [_mtProto addMessageService:_requestService];
        
        [self startTimer];
    }
    return self;
}

- (void)dealloc
{
    workerCount--;
    MTLog(@"[TGNetworkWorker#%x stop (%d)]", (int)self, workerCount);
    
    if (_timeoutTimer != nil)
    {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
    
    [_mtProto stop];
    _requestService.delegate = nil;
}

- (void)startTimer
{
    [_queue dispatchOnQueue:^
     {
         [self clearTimer];
         
         __weak TGNetworkWorker *weakSelf = self;
         _timeoutTimer = [[TGTimer alloc] initWithTimeout:30 repeat:false completion:^
                          {
                              
                            //  [_requestService requestCount:^(NSUInteger requestCount) {
                                  
                              __strong TGNetworkWorker *strongSelf = weakSelf;
                              [strongSelf timerTimeout];
                              
                            //  }];
                              
                              
                          } queue:[ASQueue globalQueue].nativeQueue];
         [_timeoutTimer start];
     }];
}

- (void)clearTimer
{
    [_queue dispatchOnQueue:^
     {
         if (_timeoutTimer != nil)
         {
             [_timeoutTimer invalidate];
             _timeoutTimer = nil;
         }
     }];
}

- (void)timerTimeout
{
    [_queue dispatchOnQueue:^
     {
         _isReadyToBeRemoved = true;
         
         id<TGNetworkWorkerDelegate> delegate = _delegate;
         if ([delegate respondsToSelector:@selector(networkWorkerReadyToBeRemoved:)])
             [delegate networkWorkerReadyToBeRemoved:self];
     }];
}

- (bool)isBusy
{
    return _isBusy;
}

-(void)update {
    [_queue dispatchOnQueue:^{
        [_mtProto pause];
        [_mtProto resume];
    }];
}

- (void)setIsBusy:(bool)isBusy
{

    
    [_queue dispatchOnQueue:^
     {
         if (_isBusy != isBusy)
         {
             _isBusy = isBusy;
             if (isBusy)
                 [self clearTimer];
             else
                 [self startTimer];
             
             if (!_isBusy)
             {
                 id<TGNetworkWorkerDelegate> delegate = _delegate;
                 if ([delegate respondsToSelector:@selector(networkWorkerDidBecomeAvailable:)])
                     [delegate networkWorkerDidBecomeAvailable:self];
             }
         }
     }];
}

- (void)updateReadyToBeRemoved
{
    [_queue dispatchOnQueue:^
     {
         if (_isReadyToBeRemoved)
         {
             id<TGNetworkWorkerDelegate> delegate = _delegate;
             if ([delegate respondsToSelector:@selector(networkWorkerReadyToBeRemoved:)])
                 [delegate networkWorkerReadyToBeRemoved:self];
         }
     }];
}

- (void)addRequest:(MTRequest *)request
{
    [_queue dispatchOnQueue:^
     {
         [_requestService addRequest:request];
     }];
}

- (void)cancelRequestById:(id)requestId
{
    [_requestService removeRequestByInternalId:requestId askForReconnectionOnDrop:true];
}

- (void)cancelRequestByIdSoft:(id)requestId
{
    [_requestService removeRequestByInternalId:requestId askForReconnectionOnDrop:false];
}

- (void)ensureConnection
{
    [_mtProto requestTransportTransaction];
}

- (void)requestMessageServiceDidCompleteAllRequests:(MTRequestMessageService *)__unused requestMessageService
{
}

- (void)requestMessageServiceAuthorizationRequired:(MTRequestMessageService *)__unused requestMessageService
{
    [_context updateAuthTokenForDatacenterWithId:_datacenterId authToken:nil];
    [_context authTokenForDatacenterWithIdRequired:_datacenterId authToken:_mtProto.requiredAuthToken masterDatacenterId:_mtProto.authTokenMasterDatacenterId];
}

@end

@implementation TGNetworkWorkerGuard

- (instancetype)initWithWorker:(TGNetworkWorker *)worker
{
    self = [super init];
    if (self != nil)
    {
        _worker = worker;
    }
    return self;
}

- (void)dealloc
{
    [self releaseWorker];
}

- (TGNetworkWorker *)strongWorker
{
    return _worker;
}

- (void)releaseWorker
{
    TGNetworkWorker *worker = _worker;
    _worker = nil;
    [worker setIsBusy:false];
    worker = nil;
}

@end
