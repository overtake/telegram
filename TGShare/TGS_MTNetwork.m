
#import "TGS_MTNetwork.h"

#import <MTProtoKit/MTKeychain.h>
#import <MTProtoKit/MTDatacenterAuthInfo.h>
#import <MTProtoKit/MTProtoKit.h>
#import "TGNetworkWorker.h"
#import "RpcErrorParser.h"
#import "DatacenterArchiver.h"
#import <MTProtoKit/MTApiEnvironment.h>
#import "TGDatacenterWatchdogActor.h"
#import "TGTimer.h"
#import "TGSKeychain.h"
#import "NSData+Extensions.h"
#import "NSMutableData+Extension.h"

#import "TGTLSerialization.h"
#import "ASQueue.h"
#import <MTProtoKit/MTLogging.h>
#import "TLApi.h"
#import "CMath.h"
#import "TGSAppManager.h"
#import "TGSKeychain.h"
@implementation MTRequest (LegacyTL)

- (void)setBody:(TLApiObject *)body
{
    [self setPayload:[TGTLSerialization serializeMessage:body] metadata:body responseParser:^id(NSData *data)
     {
         return [TGTLSerialization parseResponse:data request:body];
     }];
}

- (id)body
{
    return self.metadata;
}

@end

@interface GlobalDispatchAction : NSObject
@property (nonatomic,assign) int time;
@property (nonatomic,copy) dispatch_block_t callback;
@property (nonatomic,assign) dispatch_queue_t queue;
@property (nonatomic,strong) id internalId;
@end

@implementation GlobalDispatchAction


@end


@interface TGS_MTNetwork ()
{
    MTContext *_context;
    MTProto *_mtProto;
    MTRequestMessageService *_requestService;
    NSMutableDictionary *_objectiveDatacenter;
    NSMutableArray *_pollConnections;
    NSUInteger _datacenterCount;
    NSUInteger _masterDatacenter;
    DatacenterArchiver *_datacenterArchived;
    TGDatacenterWatchdogActor *_datacenterWatchdog;
    TGTimer *_executeTimer;
    ASQueue *_queue;
    TGTimer *_globalTimer;
    NSMutableArray *_dispatchTimers;
    TGSKeychain *_keychain;
}

@end

@implementation TGS_MTNetwork


-(MTContext *)context {
    return _context;
}


+ (TGS_MTNetwork *)instance
{
    static TGS_MTNetwork *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[TGS_MTNetwork alloc] init];
    });
    return singleton;
}

static NSString *kDatacenterArchive = @"kDatacenterArchive";
static NSString *kDefaultDatacenter = @"default_dc";

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        
        _dispatchTimers = [[NSMutableArray alloc] init];
        
        _queue = [[ASQueue alloc] initWithName:"TGS_MTNetwork"];
        
        
        
        [_queue dispatchOnQueue:^{
            
            [self moveAndEncryptKeychain];
            
            _objectiveDatacenter = [[NSMutableDictionary alloc] init];
            _pollConnections = [[NSMutableArray alloc] init];
            
            
            TGTLSerialization *serialization = [[TGTLSerialization alloc] init];
            
            MTApiEnvironment *apiEnvironment = [[[MTApiEnvironment class] alloc] init];
            apiEnvironment.apiId = 2834;
            apiEnvironment.disableUpdates = YES;
            
            _context = [[MTContext alloc] initWithSerialization:serialization apiEnvironment:apiEnvironment];
            
            
            _keychain = [self nKeychain];
            
            
            
            [_keychain loadIfNeeded];
            
            if(_keychain.isNeedPasscode) {
                
                [_keychain updatePasscodeHash:[[NSMutableData alloc] initWithRandomBytes:32] save:NO];
                
                dispatch_block_t block = ^ {
                    
                    [TGSAppManager showPasslock:^BOOL(BOOL result, NSString *md5Hash) {
                        
                        __block BOOL acceptHash;
                        
                        [_queue dispatchOnQueue:^{
                            
                            acceptHash = [_keychain updatePasscodeHash:[md5Hash dataUsingEncoding:NSUTF8StringEncoding] save:NO];
                            
                        } synchronous:YES];
                        
                        if(acceptHash) {
                            
                            [_queue dispatchOnQueue:^{
                                
                                [self startWithKeychain:_keychain];
                                [self initConnectionWithId:_masterDatacenter];
                                
                                
                            }];
                            
                            [TGSAppManager initializeContacts];
                            
                            if(![self isAuth]) {
                                [TGSAppManager hidePasslock];
                                [TGSAppManager showNoAuthView];
                            }
                        }
                        
                        
                        return acceptHash;
                        
                        
                    }];
                    
                };
                
                [ASQueue dispatchOnMainQueue:^{
                    block();
                }];
                
                
                
            } else {
                [self startWithKeychain:_keychain];
                
                if(![self isAuth]) {
                    [TGSAppManager showNoAuthView];
                }
                
            }
            
            
            
        }];
        
    }
    return self;
}


-(void)moveAndEncryptKeychain {
    
    NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *applicationName = @"Telegram";
    
    NSString * odirectory = [[applicationSupportPath stringByAppendingPathComponent:applicationName] stringByAppendingPathComponent:@"mtkeychain"];
    
    
    
    BOOL isset = NO;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:odirectory isDirectory:&isset]) {
        
        if(isset) {
            
            TGSKeychain *keychain = [self nKeychain];
            
            [keychain setNotEncryptedKeychain:YES];
            
            [keychain loadIfNeeded];
            
            [keychain setNotEncryptedKeychain:NO];
            
            [keychain updatePasscodeHash:[[NSData alloc] initWithEmptyBytes:32] save:YES];
            
            [[NSFileManager defaultManager] removeItemAtPath:odirectory error:nil];
            
        }
        
    }
    
}

-(MTQueue *)queue {
    return [_mtProto messageServiceQueue];
}

-(TGSKeychain *)nKeychain {
    return [TGSKeychain keychainWithName:@"ru.keepcoder.telegram"];
}


-(void)updatePasscode:(NSData *)md5Hash {
    
    [_queue dispatchOnQueue:^{
        
        TGSKeychain *keychain = (TGSKeychain *)_keychain;
        
        [keychain updatePasscodeHash:md5Hash save:YES];
        
    }];
    
}

-(BOOL)checkPasscode:(NSData *)md5Hash {
    
    
    __block BOOL result;
    
    [_queue dispatchOnQueue:^{
        
        TGSKeychain *keychain = (TGSKeychain *)_keychain;
        
        result = [md5Hash isEqualToData:[keychain md5PasscodeHash]];
        
    } synchronous:YES];
    
    return result;
    
}

-(BOOL)passcodeIsEnabled {
    
    __block BOOL result;
    
    [_queue dispatchOnQueue:^{
        
        TGSKeychain *keychain = (TGSKeychain *)_keychain;
        
        result = [keychain passcodeIsEnabled];
        
        
    } synchronous:YES];
    
    return result;
    
}

-(void)startWithKeychain:(TGSKeychain *)keychain {
    
    [_context setKeychain:keychain];
    
    
    [_context addChangeListener:self];
    
    
    _masterDatacenter = [[keychain objectForKey:@"dc_id" group:@"persistent"] intValue];
    
    _masterDatacenter = _masterDatacenter > 0 ? _masterDatacenter :1;
    
    _datacenterCount = 5;
    
    
    NSString *address =  @"149.154.167.51";
    
    [_context setSeedAddressSetForDatacenterWithId:2 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[[[MTDatacenterAddress alloc] initWithIp:address port:443 preferForMedia:NO]]]];
    
}



-(void)startNetwork {
    
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [_queue dispatchOnQueue:^{
            [self initConnectionWithId:_masterDatacenter];
        }];
        
    });
}

-(void)update {
    [_mtProto pause];
    [_mtProto resume];
}

static int MAX_WORKER_POLL = 5;

-(void)resetWorkers {
    
    
    [_objectiveDatacenter removeAllObjects];
    [_pollConnections removeAllObjects];
    
    for (int i = 1; i < _datacenterCount+1; i++) {
        NSMutableArray *poll = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < MAX_WORKER_POLL; j++) {
            TGNetworkWorker *worker = [[TGNetworkWorker alloc] initWithContext:_context datacenterId:i masterDatacenterId:_mtProto.datacenterId];
            [poll addObject:worker];
        }
        [_objectiveDatacenter setObject:poll forKey:@(i)];
    }
    
    for (int i = 1; i < _datacenterCount+1; i++) {
        TGNetworkWorker *worker = [[TGNetworkWorker alloc] initWithContext:_context datacenterId:_mtProto.datacenterId masterDatacenterId:_mtProto.datacenterId];
        [_pollConnections addObject:worker];
    }
}


-(void)initConnectionWithId:(NSInteger)dc_id {
    
    
    [_queue dispatchOnQueue:^{
        
        if(_context.keychain != nil) {
            
            [_mtProto stop];
            
            _mtProto = [[MTProto alloc] initWithContext:_context datacenterId:dc_id];
            
            _requestService = [[MTRequestMessageService alloc] initWithContext:_context];
            
            [_mtProto addMessageService:_requestService];
            
            [self resetWorkers];
        }
        
    }];
    
}


-(int)getTime {
    
    return [_context globalTime];
}

-(int)getUserId {
    return [[_keychain objectForKey:@"user_id" group:@"persistent"] intValue];
}

-(id<MTKeychain>)keyChain {
    return _context.keychain;
}

-(void)cancelRequest:(TGS_RPCRequest *)request {
    [_queue dispatchOnQueue:^{
        [_requestService removeRequestByInternalId:request.mtrequest.internalId];
    }];
    
    
}

-(void)sendRequest:(TGS_RPCRequest *)request forDatacenter:(int)datacenterId {
    [_queue dispatchOnQueue:^{
        NSMutableArray *poll = [_objectiveDatacenter objectForKey:@(datacenterId)];
        
        TGNetworkWorker *worker = [poll objectAtIndex:rand_limit(MAX_WORKER_POLL-1)];
        [worker addRequest:[self constructRequest:request]];
    }];
    
}

-(void)sendRandomRequest:(TGS_RPCRequest *)request {
    [_queue dispatchOnQueue:^{
        TGNetworkWorker *worker = [_pollConnections objectAtIndex:rand_limit((int)_pollConnections.count-1)];
        [worker addRequest:[self constructRequest:request]];
    }];
}

-(MTRequest *)constructRequest:(TGS_RPCRequest *)request {
    
    __block TGS_RPCRequest *blockedRequest = request;
    MTRequest *mtrequest = [[MTRequest alloc] init];
    mtrequest.body = request.object;
    blockedRequest.mtrequest = mtrequest;
    
    
    
    static NSArray *dependsOnPwd;
    static NSArray *sequentialMessageClasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      dependsOnPwd = @[[TLAPI_account_deleteAccount class], [TLAPI_account_getPassword class], [TLAPI_auth_checkPassword class], [TLAPI_auth_requestPasswordRecovery class], [TLAPI_auth_recoverPassword class]];
                      
                      sequentialMessageClasses = @[
                                                   [TLAPI_messages_sendMessage class],
                                                   [TLAPI_messages_sendMedia class],
                                                   [TLAPI_messages_forwardMessage class],
                                                   [TLAPI_messages_sendEncrypted class],
                                                   [TLAPI_messages_sendEncryptedFile class],
                                                   [TLAPI_messages_sendEncryptedService class]
                                                   ];
                  });
    
    if([dependsOnPwd containsObject:[request.object class]]) {
        mtrequest.dependsOnPasswordEntry = NO;
    }
    
    for (Class sequentialClass in sequentialMessageClasses)
    {
        if ([mtrequest.body isKindOfClass:sequentialClass])
        {
            [mtrequest setShouldDependOnRequest:^bool (MTRequest *anotherRequest)
             {
                 for (Class sequentialClass in sequentialMessageClasses)
                 {
                     if ([anotherRequest.body isKindOfClass:sequentialClass])
                         return true;
                 }
                 
                 return false;
             }];
            
            break;
        }
    }
    
    
    
    [mtrequest setCompleted:^(id result, NSTimeInterval t, id error) {
        blockedRequest.response = result;
        if(error)
            blockedRequest.error = [RpcErrorParser parseRpcError:error];
        
        dispatch_async([_mtProto messageServiceQueue].nativeQueue, ^{
            
            
            [blockedRequest completeHandler];
            blockedRequest = nil;
        });
        
    }];
    
    return mtrequest;
}

-(void)sendRequest:(TGS_RPCRequest *)request {
    
    [_queue dispatchOnQueue:^{
        static NSArray *noAuthClasses;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            noAuthClasses = @[[TLAPI_auth_sendCall class], [TLAPI_auth_signIn class], [TLAPI_auth_signUp class], [TLAPI_auth_sendCode class], [TLAPI_auth_checkPhone class], [TLAPI_help_getConfig class], [TLAPI_help_getNearestDc class], [TLAPI_auth_sendSms class], [TLAPI_account_deleteAccount class], [TLAPI_account_getPassword class], [TLAPI_auth_checkPassword class], [TLAPI_auth_requestPasswordRecovery class], [TLAPI_auth_recoverPassword class]];
        });
        
        if([self isAuth] || ([noAuthClasses containsObject:[request.object class]])) {
            [_requestService addRequest:[self constructRequest:request]];
        }
    }];
}

-(void)successAuthForDatacenter:(int)dc_id {
    [_queue dispatchOnQueue:^{
        [_context updateAuthTokenForDatacenterWithId:dc_id authToken:@(dc_id)];
    }];
    
}


-(BOOL)isAuth {
    
    __block BOOL success;
    
    [_queue dispatchOnQueue:^{
        
        success = [[_context authTokenForDatacenterWithId:_masterDatacenter] intValue] > 0;
        
    } synchronous:YES];
    
    return success;
}

-(MTDatacenterAuthInfo *)authInfoForDatacenter:(int)dc_id {
    
    __block MTDatacenterAuthInfo *info;
    
    [_queue dispatchOnQueue:^{
        
        info = [_context authInfoForDatacenterWithId:dc_id];
        
    } synchronous:YES];
    
    return info;
}

- (void)contextDatacenterAddressSetUpdated:(MTContext *)context datacenterId:(NSInteger)datacenterId addressSet:(MTDatacenterAddressSet *)addressSet {
    MTLog(@"");
    
}
- (void)contextDatacenterAuthInfoUpdated:(MTContext *)context datacenterId:(NSInteger)datacenterId authInfo:(MTDatacenterAuthInfo *)authInfo {
    
}
- (void)contextDatacenterAuthTokenUpdated:(MTContext *)context datacenterId:(NSInteger)datacenterId authToken:(id)authToken {
    MTLog(@"");
}

- (void)contextIsPasswordRequiredUpdated:(MTContext *)context datacenterId:(NSInteger)datacenterId
{
    if (context == _context && datacenterId == _mtProto.datacenterId)
    {
        bool passwordRequired = [context isPasswordInputRequiredForDatacenterWithId:datacenterId];
        
        if(passwordRequired) {
          //  [Telegram showEnterPasswordPanel];
        }
        
    }
}

id dispatch_in_time(int time, dispatch_block_t callback) {
    
    
    assert(callback != nil);
    
    GlobalDispatchAction *action = [[GlobalDispatchAction alloc] init];
    
    action.time = time;
    action.callback = callback;
    action.queue = dispatch_get_current_queue();
    action.internalId = [[NSObject alloc] init];
    
    [[TGS_MTNetwork instance]->_queue dispatchOnQueue:^{
        
        [[TGS_MTNetwork instance]->_dispatchTimers addObject:action];
        
        if(![TGS_MTNetwork instance]->_globalTimer)
        {
            [TGS_MTNetwork instance]->_globalTimer = [[TGTimer alloc] initWithTimeout:3 repeat:YES completion:^{
                
                
                NSMutableArray *remove = [[NSMutableArray alloc] init];
                
                [[TGS_MTNetwork instance]->_dispatchTimers enumerateObjectsUsingBlock:^(GlobalDispatchAction *obj, NSUInteger idx, BOOL *stop) {
                    
                    
                    if([[TGS_MTNetwork instance] getTime] >= obj.time)
                    {
                        dispatch_async(obj.queue, ^{
                            obj.callback();
                        });
                        
                        [remove addObject:obj];
                        
                    }
                    
                }];
                
                [[TGS_MTNetwork instance]->_dispatchTimers removeObjectsInArray:remove];
                
                
                if([TGS_MTNetwork instance]->_dispatchTimers.count == 0)
                {
                    [[TGS_MTNetwork instance]->_globalTimer invalidate];
                    [TGS_MTNetwork instance]->_globalTimer = nil;
                }
                
            } queue:[TGS_MTNetwork instance]->_queue.nativeQueue];
            
            [[TGS_MTNetwork instance]->_globalTimer start];
        } else {
            [[TGS_MTNetwork instance]->_globalTimer fire];
        }
        
    }];
    
    return action.internalId;
    
}

void remove_global_dispatcher(id internalId) {
    
    if(!internalId)
        return;
    
    [[TGS_MTNetwork instance]->_queue dispatchOnQueue:^{
        
        NSMutableArray *objs = [[NSMutableArray alloc] init];
        
        [[TGS_MTNetwork instance]->_dispatchTimers enumerateObjectsUsingBlock:^(GlobalDispatchAction *obj, NSUInteger idx, BOOL *stop) {
            
            if(obj.internalId == internalId)
            {
                [objs addObject:obj];
            }
            
        }];
        
        [[TGS_MTNetwork instance]->_dispatchTimers removeObjectsInArray:objs];
        
    }];
    
}


@end
