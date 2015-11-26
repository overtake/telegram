
#import "MTNetwork.h"

#import <MTProtoKit/MTKeychain.h>
#import <MTProtoKit/MTDatacenterAuthInfo.h>
#import "MTConnection.h"
#import <MTProtoKit/MTProtoKit.h>
#import "TGNetworkWorker.h"
#import "TGUpdateMessageService.h"
#import "RpcErrorParser.h"
#import "DatacenterArchiver.h"
#import <MTProtoKit/MTApiEnvironment.h>
#import "TGDatacenterWatchdogActor.h"
#import "TGTimer.h"
#import "TGKeychain.h"
#import "NSData+Extensions.h"
#import "NSMutableData+Extension.h"
#import "SSKeychain.h"
#import "TGTLSerialization.h"
#import "TGPasslock.h"
#import <Security/SecRandom.h>
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


@interface MTNetwork ()
{
    MTContext *_context;
    MTProto *_mtProto;
    MTRequestMessageService *_requestService;
    TGUpdateMessageService *_updateService;
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
    TGKeychain *_keychain;
}

@end

@implementation MTNetwork


-(MTContext *)context {
    return _context;
}


+ (MTNetwork *)instance
{
    static MTNetwork *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      singleton = [[MTNetwork alloc] init];
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
        
        _queue = [[ASQueue alloc] initWithName:"mtnetwork"];
        
        
        [_queue dispatchOnQueue:^{
            
            [self moveAndEncryptKeychain];
            
            _objectiveDatacenter = [[NSMutableDictionary alloc] init];
            _pollConnections = [[NSMutableArray alloc] init];
            
            
            TGTLSerialization *serialization = [[TGTLSerialization alloc] init];
            
            MTApiEnvironment *apiEnvironment = [[[MTApiEnvironment class] alloc] init];
            apiEnvironment.apiId = API_ID;
            

            _context = [[MTContext alloc] initWithSerialization:serialization apiEnvironment:apiEnvironment];
            
            
            _keychain = [self nKeychain];
            
            

            
            [_keychain loadIfNeeded];
            
            if(_keychain.isNeedPasscode) {
                
                [_keychain updatePasscodeHash:[[NSMutableData alloc] initWithRandomBytes:32] save:NO];
                
                dispatch_block_t block = ^ {
                    
                    [TMViewController showBlockPasslock:^BOOL(BOOL result, NSString *md5Hash) {
                                                
                        __block BOOL acceptHash;
                        
                        [_queue dispatchOnQueue:^{
                            
                            acceptHash = [_keychain updatePasscodeHash:[md5Hash dataUsingEncoding:NSUTF8StringEncoding] save:NO];
                            
                        } synchronous:YES];
                        
                        if(acceptHash) {
                            
                            
                                [_queue dispatchOnQueue:^{
                                    
                                    [self updateStorageEncryptionKey];
                                    [Storage updateOldEncryptionKey:md5Hash];
                                    
                                    [Storage initManagerWithCallback:^{
                                    
                                        [self startWithKeychain:_keychain];
                                        [self initConnectionWithId:_masterDatacenter];
                                        
                                        
                                        [ASQueue dispatchOnMainQueue:^{
                                            [Telegram initializeDatabase];
                                            
                                            if(![self isAuth]) {
                                                [[Telegram delegate] logoutWithForce:YES];
                                            } else {
                                                [TGPasslock appIncomeActive];
                                            }
                                        }];
                                        
                                    }];
                                }];
                                
                            

                            
                            
                        }
                        
                        
                        return acceptHash;
                        
                        
                    }];
                    
                };
                
                [ASQueue dispatchOnMainQueue:^{
                    block();
                }];
              
                
                
            } else {
                
                [self updateStorageEncryptionKey];
                
                [self startWithKeychain:_keychain];
                
                if(![self isAuth]) {
                    [[Telegram delegate] logoutWithForce:YES];
                } else {
                    [TGPasslock appIncomeActive];
                }
                
            }
            
            

        }];
        
    }
    return self;
}


-(void)moveAndEncryptKeychain {
    
    
    NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString * odirectory = [[applicationSupportPath stringByAppendingPathComponent:applicationName] stringByAppendingPathComponent:@"mtkeychain"];

    BOOL isset = NO;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:odirectory isDirectory:&isset]) {
        
        if(isset) {
            
            TGKeychain *keychain = [self nKeychain];
            
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


//        NSString * ndirectory = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]] stringByAppendingPathComponent:@"encrypt-mtkeychain"];
//
//        if([[NSFileManager defaultManager] fileExistsAtPath:ndirectory]) {
//
//            TGKeychain *keychain = [TGKeychain unencryptedKeychainWithName:BUNDLE_IDENTIFIER];
//
//            keychain->_encrypted = YES;
//
//            [keychain storeAllKeychain];
//
//            [[NSFileManager defaultManager] removeItemAtPath:ndirectory error:nil];
//
//        }


-(TGKeychain *)nKeychain {
    


    
#ifndef TGDEBUG
    
    if(NSAppKitVersionNumber >= NSAppKitVersionNumber10_9)
        return [TGKeychain keychainWithName:BUNDLE_IDENTIFIER];
    
    return [TGKeychain unencryptedKeychainWithName:BUNDLE_IDENTIFIER];
    
#else
    
    if(isTestServer())  {
        return [TGKeychain unencryptedKeychainWithName:@"org.telegram.test"];
    } else {
        return [TGKeychain unencryptedKeychainWithName:BUNDLE_IDENTIFIER];
    }
    
#endif
    
    
    
     
}


-(void)updatePasscode:(NSData *)md5Hash {
    
    [_queue dispatchOnQueue:^{
        
        TGKeychain *keychain = (TGKeychain *)_keychain;
        
        [keychain updatePasscodeHash:md5Hash save:YES];
        
    }];

}

-(BOOL)checkPasscode:(NSData *)md5Hash {
    
    
    __block BOOL result;
    
    [_queue dispatchOnQueue:^{
        
        TGKeychain *keychain = (TGKeychain *)_keychain;
        
        result = [md5Hash isEqualToData:[keychain md5PasscodeHash]];
        
    } synchronous:YES];
    
    return result;
    
}

-(BOOL)passcodeIsEnabled {
    
    __block BOOL result;
    
    [_queue dispatchOnQueue:^{
        
        TGKeychain *keychain = (TGKeychain *)_keychain;
        
        result = [keychain passcodeIsEnabled];
        
        
    } synchronous:YES];
    
    return result;
   
}

-(void)updateStorageEncryptionKey {
    
    NSString *key = [_keychain objectForKey:@"e_key" group:@"persistent"];
    
    if(!key)
        [self updateEncryptionKey];
     else
        [Storage updateEncryptionKey:key];
}

-(void)startWithKeychain:(TGKeychain *)keychain {
    
    [_context setKeychain:keychain];
    
    
    
    [_context addChangeListener:self];
    
    
    _masterDatacenter = [[keychain objectForKey:@"dc_id" group:@"persistent"] intValue];
    
    if(_masterDatacenter == 0) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        int o = (int) [defaults integerForKey:kDefaultDatacenter];
        
        
        if(o > 0) {
            [_keychain setObject:@(o) forKey:@"dc_id" group:@"persistent"];
            
        }  else {
            o = 2;
        }
        _masterDatacenter = o;
    }
        
    _datacenterCount = 5;
    
    
    NSString *address = isTestServer() ? @"149.154.175.10" : @"149.154.167.51";
    
    [_context setSeedAddressSetForDatacenterWithId:isTestServer() ? 1 : 2 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[[[MTDatacenterAddress alloc] initWithIp:address port:443 preferForMedia:NO]]]];
    
    
    if(!isTestServer()) {
        _datacenterWatchdog = [[TGDatacenterWatchdogActor alloc] initWithPath:@"tg"];
        
        
        void (^execute)() = ^{
            [_datacenterWatchdog execute:nil];
            [self update];
            
        };
        
        _executeTimer = [[TGTimer alloc] initWithTimeout:15*60 repeat:YES completion:^{
            execute();
        } queue:_queue.nativeQueue];
        
        [_executeTimer start];
    }
    
}

- (TGUpdateMessageService *)updateService {
    __block TGUpdateMessageService *s;
    
    [_queue dispatchOnQueue:^{
        
        s =  _updateService;
        
    } synchronous:YES];
    
    return s;
}

-(void)startNetwork {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [_queue dispatchOnQueue:^{
            [self initConnectionWithId:_masterDatacenter];
            
            [_datacenterWatchdog execute:nil];
        }];
    });
}

-(void)update {
    [_mtProto pause];
    [_mtProto resume];
}

+(void)pause {
    [[self instance]->_mtProto pause];
}
+(void)resume {
    [[self instance]->_mtProto resume];
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
    
    dc_id = dc_id == -1 ? _masterDatacenter : dc_id;
    
    [_queue dispatchOnQueue:^{
        
        if(_context.keychain != nil) {
            
            [_mtProto stop];
            
            _mtProto = [[MTConnection alloc] initWithContext:_context datacenterId:dc_id];
            
            _requestService = [[MTRequestMessageService alloc] initWithContext:_context];
            _updateService = [[TGUpdateMessageService alloc] init];
            
            [_mtProto addMessageService:_requestService];
            [_mtProto addMessageService:_updateService];
            
            [self resetWorkers];
        } 

    }];
    
}


-(void)drop {
    
    [_queue dispatchOnQueue:^{
        [_context removeAllAuthTokens];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDefaultDatacenter];
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        
        NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        
        NSString * mtkeychain = [[applicationSupportPath stringByAppendingPathComponent:applicationName] stringByAppendingPathComponent:@"encrypt-mtkeychain"];
        
        [[NSFileManager defaultManager] removeItemAtPath:mtkeychain error:nil];
        
        [SSKeychain deletePasswordForService:appName() account:@"authkeys"];
        
        [_keychain cleanup];
        [_keychain loadIfNeeded];
        
        [_keychain updatePasscodeHash:[[NSData alloc] initWithEmptyBytes:32] save:YES];
        
        [self.updateService drop];
        [self setDatacenter:isTestServer() ? 1 : 2];
        
        
        [self updateEncryptionKey];
        
        
        
    } synchronous:YES];
    
    
}

-(NSString *)updateEncryptionKey {
    uint8_t secKey[32];
    SecRandomCopyBytes(kSecRandomDefault, 32, secKey);
    
    NSString *key = [[[NSString alloc] initWithData:[[NSData alloc] initWithBytes:secKey length:32] encoding:NSASCIIStringEncoding] md5];
    
    [_keychain setObject:key forKey:@"e_key" group:@"persistent"];
    
    [Storage updateEncryptionKey:key];
    
    return key;
}



-(int)getTime {
    
    return [_context globalTime];
}

-(int)currentDatacenter {
    return (int)_masterDatacenter;
}

-(void)setDatacenter:(int)dc_id {
    _masterDatacenter = dc_id;
    
    [_keychain setObject:@(dc_id) forKey:@"dc_id" group:@"persistent"];
    
}

-(void)setUserId:(int)userId {
    if([self getUserId] != userId)
        [_keychain setObject:@(userId) forKey:@"user_id" group:@"persistent"];
}

-(int)getUserId {
    return [[_keychain objectForKey:@"user_id" group:@"persistent"] intValue];
}

-(id<MTKeychain>)keyChain {
    return _context.keychain;
}

-(void)cancelRequest:(RPCRequest *)request {
    [_queue dispatchOnQueue:^{
         [_requestService removeRequestByInternalId:request.mtrequest.internalId];
    }];
}

-(void)cancelRequestWithInternalId:(id)internalId {
    [_queue dispatchOnQueue:^{
        [_requestService removeRequestByInternalId:internalId];
    }];
}

-(void)sendRequest:(RPCRequest *)request forDatacenter:(int)datacenterId {
    [_queue dispatchOnQueue:^{
        NSMutableArray *poll = [_objectiveDatacenter objectForKey:@(datacenterId)];
        
        TGNetworkWorker *worker = [poll objectAtIndex:rand_limit(MAX_WORKER_POLL-1)];
        [worker addRequest:[self constructRequest:request]];
    }];
  
}

-(void)sendRandomRequest:(RPCRequest *)request {
    [_queue dispatchOnQueue:^{
        TGNetworkWorker *worker = [_pollConnections objectAtIndex:rand_limit((int)_pollConnections.count-1)];
        [worker addRequest:[self constructRequest:request]];
    }];
}

-(MTRequest *)constructRequest:(RPCRequest *)request {
    
    __block RPCRequest *blockedRequest = request;
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
            
            [self.updateService mtProto:_mtProto receivedParsedMessage:result];
            
            [blockedRequest completeHandler];
            blockedRequest = nil;
        });
         
    }];
    
    
    if(request.alwayContinueWithErrorContext) {
        [mtrequest setShouldContinueExecutionWithErrorContext:^bool(MTRequestErrorContext *errorContext) {
            return false;
        }];
    }
    
    return mtrequest;
}

-(void)sendRequest:(RPCRequest *)request {
    
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

-(void)addRequest:(MTRequest *)request {
    [_queue dispatchOnQueue:^{
        
        if([self isAuth]) {
             [_requestService addRequest:request];
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
            [Telegram showEnterPasswordPanel];
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
    
    [[MTNetwork instance]->_queue dispatchOnQueue:^{
        
        [[MTNetwork instance]->_dispatchTimers addObject:action];
        
        if(![MTNetwork instance]->_globalTimer)
        {
            [MTNetwork instance]->_globalTimer = [[TGTimer alloc] initWithTimeout:3 repeat:YES completion:^{
                
                
                NSMutableArray *remove = [[NSMutableArray alloc] init];
                
                [[MTNetwork instance]->_dispatchTimers enumerateObjectsUsingBlock:^(GlobalDispatchAction *obj, NSUInteger idx, BOOL *stop) {
                    
                    
                    if([[MTNetwork instance] getTime] >= obj.time)
                    {
                        dispatch_async(obj.queue, ^{
                            obj.callback();
                        });
                        
                        [remove addObject:obj];
                        
                    }
                    
                }];
                
                [[MTNetwork instance]->_dispatchTimers removeObjectsInArray:remove];
                
                
                if([MTNetwork instance]->_dispatchTimers.count == 0)
                {
                    [[MTNetwork instance]->_globalTimer invalidate];
                    [MTNetwork instance]->_globalTimer = nil;
                }
                
            } queue:[MTNetwork instance]->_queue.nativeQueue];
            
            [[MTNetwork instance]->_globalTimer start];
        } else {
            [[MTNetwork instance]->_globalTimer fire];
        }
        
    }];
    
    return action.internalId;
    
}

void remove_global_dispatcher(id internalId) {
    
    if(!internalId)
        return;
    
    [[MTNetwork instance]->_queue dispatchOnQueue:^{
        
        NSMutableArray *objs = [[NSMutableArray alloc] init];
        
        [[MTNetwork instance]->_dispatchTimers enumerateObjectsUsingBlock:^(GlobalDispatchAction *obj, NSUInteger idx, BOOL *stop) {
            
            if(obj.internalId == internalId)
            {
                [objs addObject:obj];
            }
            
        }];
        
        [[MTNetwork instance]->_dispatchTimers removeObjectsInArray:objs];
        
    }];
    
}


@end
