#import <Foundation/Foundation.h>
#import <MtProtoKitMac/MTContext.h>
#import <MtProtoKitMac/MTProto.h>
#import <MtProtoKitMac/MTDatacenterAddressSet.h>
#import <MtProtoKitMac/MTDatacenterAddress.h>
#import <MtProtoKitMac/MTRequestMessageService.h>
#import <MtProtoKitMac/MTKeychain.h>
#import "TGUpdateMessageService.h"
#import <MtProtoKitMac/MTQueue.h>

@interface MTRequest (LegacyTL)
-(void)setBody:(TLApiObject *)body;
@end;

@interface MTNetwork : NSObject<MTContextChangeListener>

typedef enum {
    TGRequestClassGeneric = 1,
    TGRequestClassDownloadMedia = 2,
    TGRequestClassUploadMedia = 4,
    TGRequestClassEnableUnauthorized = 8,
    TGRequestClassEnableMerging = 16,
    TGRequestClassHidesActivityIndicator = 64,
    TGRequestClassLargeMedia = 128,
    TGRequestClassFailOnServerErrors = 256,
    TGRequestClassFailOnFloodErrors = 512,
    TGRequestClassPassthroughPasswordNeeded = 1024,
    TGRequestClassIgnorePasswordEntryRequired = 2048
} TGRequestClass;

+ (MTNetwork *)instance;
-(void)initConnectionWithId:(NSInteger)dc_id;
-(void)sendRequest:(RPCRequest *)request;
-(void)sendRequest:(RPCRequest *)request forDatacenter:(int)datacenterId;
-(void)sendRandomRequest:(RPCRequest *)request;
-(MTDatacenterAuthInfo *)authInfoForDatacenter:(int)dc_id;
-(id<MTKeychain>)keyChain;
-(void)successAuthForDatacenter:(int)dc_id;
-(BOOL)isAuth;
-(void)drop;
-(int)getTime;
-(int)globalTimeOffsetFromUTC;
-(int)currentDatacenter;
-(void)setDatacenter:(int)dc_id;
-(void)cancelRequest:(RPCRequest *)request;
-(void)cancelRequestWithInternalId:(id)internalId;
-(void)setUserId:(int)userId;
-(int)getUserId;

-(void)addRequest:(MTRequest *)request;

- (TGUpdateMessageService *)updateService;

-(void)startNetwork;

-(MTContext *)context;

-(void)update;

+(void)pause;
+(void)resume;
-(NSString *)updateEncryptionKey;

-(MTQueue *)queue;

-(void)updatePasscode:(NSData *)md5Hash;
-(BOOL)checkPasscode:(NSData *)md5Hash;
-(BOOL)passcodeIsEnabled;
-(NSString *)encryptionKey;

id dispatch_in_time(int time, dispatch_block_t callback);
void remove_global_dispatcher(id internalId);

- (SSignal *)requestSignal:(TLApiObject *)rpc continueOnServerErrors:(bool)continueOnServerErrors queue:(ASQueue *)queue;
- (SSignal *)requestSignal:(TLApiObject *)rpc queue:(ASQueue *)queue;
- (SSignal *)requestSignal:(TLApiObject *)rpc;
@end
