

#import "TGNetworkWorker.h"



#import "TGTimer.h"
#import "ASQueue.h"
#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTProto.h>
#import <MTProtoKit/MTRequestMessageService.h>
#import <MTProtoKit/MTRequest.h>

static int workerCount = 0;

@interface TGNetworkWorker () <MTRequestMessageServiceDelegate>
{
    MTContext *_context;
    MTProto *_mtProto;
    MTRequestMessageService *_requestService;
    
    TGTimer *_timeoutTimer;

    bool _isReadyToBeRemoved;
    bool _isBusy;
}

@end

@implementation TGNetworkWorker

- (instancetype)initWithContext:(MTContext *)context datacenterId:(NSInteger)datacenterId masterDatacenterId:(NSInteger)masterDatacenterId
{
    self = [super init];
    if (self != nil)
    {
        workerCount++;
        MTLog(@"[TGNetworkWorker#%x/%d start (%d)]", (int)self, (int)datacenterId, workerCount);

        _context = context;
        _datacenterId = datacenterId;
        
        _mtProto = [[MTProto alloc] initWithContext:_context datacenterId:_datacenterId];
        _mtProto.requiredAuthToken = @(masterDatacenterId);
        _mtProto.authTokenMasterDatacenterId = masterDatacenterId;
        
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
    [ASQueue dispatchOnStageQueue:^
    {
        [self clearTimer];
        
        __weak TGNetworkWorker *weakSelf = self;
        _timeoutTimer = [[TGTimer alloc] initWithTimeout:30 repeat:false completion:^
        {
            __strong TGNetworkWorker *strongSelf = weakSelf;
            [strongSelf timerTimeout];
        } queue:[[ASQueue globalQueue] nativeQueue]];
        [_timeoutTimer start];
    }];
}

- (void)clearTimer
{
    [ASQueue dispatchOnStageQueue:^
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
    [ASQueue dispatchOnStageQueue:^
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

- (void)setIsBusy:(bool)isBusy
{
    [ASQueue dispatchOnStageQueue:^
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
    [ASQueue dispatchOnStageQueue:^
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
    [ASQueue dispatchOnStageQueue:^
    {
        [_requestService addRequest:request];
    }];
}

- (void)cancelRequestById:(id)requestId
{
    [_requestService removeRequestByInternalId:requestId askForReconnectionOnDrop:true];
}

- (void)requestMessageServiceDidCompleteAllRequests:(MTRequestMessageService *)__unused requestMessageService
{
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
