
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
        
        [ASQueue dispatchOnStageQueue:^{
            _objectiveDatacenter = [[NSMutableDictionary alloc] init];
            _pollConnections = [[NSMutableArray alloc] init];
            
            
            TelegramSerialization *serialization = [[TelegramSerialization alloc] init];
            
            MTApiEnvironment *apiEnvironment = [[[MTApiEnvironment class] alloc] init];
            apiEnvironment.apiId = API_ID;
            

            _context = [[MTContext alloc] initWithSerialization:serialization apiEnvironment:apiEnvironment];
            
            if(isTestServer())
                 [_context setKeychain:[MTKeychain unencryptedKeychainWithName:@"org.telegram.test"]];
             else
                [_context setKeychain:[MTKeychain unencryptedKeychainWithName:BUNDLE_IDENTIFIER]];
            
           
            [_context addChangeListener:self];
            
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            _masterDatacenter = (int)[defaults integerForKey:kDefaultDatacenter];
            _masterDatacenter = _masterDatacenter == 0 ? 1 : _masterDatacenter;
            
            
            _datacenterCount = 5;
            
            
            NSString *address = isTestServer() ? @"173.240.5.253" : @"149.154.175.50";
            
            [_context setSeedAddressSetForDatacenterWithId:1 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[[[MTDatacenterAddress alloc] initWithIp:address port:443]]]];
            
            
            if(!isTestServer()) {
                _datacenterWatchdog = [[TGDatacenterWatchdogActor alloc] initWithPath:@"tg"];
                
                
                void (^execute)() = ^{
                    [_datacenterWatchdog execute:nil];
                };
                
                
                execute();
                
                _executeTimer = [[TGTimer alloc] initWithTimeout:60*60 repeat:YES completion:^{
                    execute();
                } queue:[ASQueue globalQueue].nativeQueue];
                
                [_executeTimer start];
            }
            
           
            

        }];
        
    }
    return self;
}

- (TGUpdateMessageService *)updateService {
    return _updateService;
}

-(void)startNetwork {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         [self initConnectionWithId:_masterDatacenter];
    });
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
    
    [ASQueue dispatchOnStageQueue:^{
        
        [_mtProto stop];
        _mtProto = [[MTConnection alloc] initWithContext:_context datacenterId:dc_id];
        
        _requestService = [[MTRequestMessageService alloc] initWithContext:_context];
        _updateService = [[TGUpdateMessageService alloc] init];
        
        [_mtProto addMessageService:_requestService];
        [_mtProto addMessageService:_updateService];
        
        [self resetWorkers];

    }];
    
}


-(void)drop {
    
    [_context removeAllAuthTokens];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDefaultDatacenter];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [self.updateService drop];
    [self setDatacenter:1];
    
    [self initConnectionWithId:_masterDatacenter];
}

-(int)getTime {
    
    return [_context globalTime];
}

-(int)currentDatacenter {
    return (int)_masterDatacenter;
}

-(void)setDatacenter:(int)dc_id {
    _masterDatacenter = dc_id;
    [[NSUserDefaults standardUserDefaults] setObject:@(dc_id) forKey:kDefaultDatacenter];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(MTKeychain *)keyChain {
    return _context.keychain;
}

-(void)cancelRequest:(RPCRequest *)request {
    [ASQueue dispatchOnStageQueue:^{
         [_requestService removeRequestByInternalId:request.mtrequest.internalId];
    }];
    
   
}

-(void)sendRequest:(RPCRequest *)request forDatacenter:(int)datacenterId {
    [ASQueue dispatchOnStageQueue:^{
        NSMutableArray *poll = [_objectiveDatacenter objectForKey:@(datacenterId)];
        
        TGNetworkWorker *worker = [poll objectAtIndex:rand_limit(MAX_WORKER_POLL-1)];
        [worker addRequest:[self constructRequest:request]];
    }];
  
}

-(void)sendRandomRequest:(RPCRequest *)request {
    [ASQueue dispatchOnStageQueue:^{
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
         dependsOnPwd = @[[TLAPI_account_deleteAccount class], [TLAPI_account_getPassword class], [TLAPI_auth_checkPassword class]];
                      
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
        [blockedRequest completeHandler];
        blockedRequest = nil;
    }];
    
    return mtrequest;
}

-(void)sendRequest:(RPCRequest *)request {
    
    [ASQueue dispatchOnStageQueue:^{
        static NSArray *noAuthClasses;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            noAuthClasses = @[[TLAPI_auth_sendCall class], [TLAPI_auth_signIn class], [TLAPI_auth_signUp class], [TLAPI_auth_sendCode class], [TLAPI_auth_checkPhone class], [TLAPI_help_getConfig class], [TLAPI_help_getNearestDc class], [TLAPI_auth_sendSms class], [TLAPI_account_deleteAccount class], [TLAPI_account_getPassword class], [TLAPI_auth_checkPassword class]];
        });
        
        if([self isAuth] || ([noAuthClasses containsObject:[request.object class]])) {
            [_requestService addRequest:[self constructRequest:request]];
        }
    }];
}

-(void)successAuthForDatacenter:(int)dc_id {
    [ASQueue dispatchOnStageQueue:^{
        [_context updateAuthTokenForDatacenterWithId:dc_id authToken:@(dc_id)];
    }];
    
}


-(BOOL)isAuth {
    
    __block BOOL success;
    
    [ASQueue dispatchOnStageQueue:^{
     
        success = [[_context authTokenForDatacenterWithId:_masterDatacenter] intValue] > 0;
    
    } synchronous:YES];
   
    return success;
}

-(MTDatacenterAuthInfo *)authInfoForDatacenter:(int)dc_id {
    
    __block MTDatacenterAuthInfo *info;
    
    [ASQueue dispatchOnStageQueue:^{
       
        info = [_context authInfoForDatacenterWithId:dc_id];
    
    } synchronous:YES];
    
    return info;
}

- (void)contextDatacenterAddressSetUpdated:(MTContext *)context datacenterId:(NSInteger)datacenterId addressSet:(MTDatacenterAddressSet *)addressSet {
    DLog(@"");
    
}
- (void)contextDatacenterAuthInfoUpdated:(MTContext *)context datacenterId:(NSInteger)datacenterId authInfo:(MTDatacenterAuthInfo *)authInfo {
    
}
- (void)contextDatacenterAuthTokenUpdated:(MTContext *)context datacenterId:(NSInteger)datacenterId authToken:(id)authToken {
    DLog(@"");
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

@end
