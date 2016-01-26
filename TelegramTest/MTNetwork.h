#import <Foundation/Foundation.h>
#import <MtProtoKit/MTContext.h>
#import <MtProtoKit/MTProto.h>
#import <MTProtoKit/MTDatacenterAddressSet.h>
#import <MTProtoKit/MTDatacenterAddress.h>
#import <MtProtoKit/MTRequestMessageService.h>
#import <MTProtoKit/MTKeychain.h>
#import "TGUpdateMessageService.h"
#import <MtProtoKit/MTQueue.h>

@interface MTRequest (LegacyTL)
-(void)setBody:(TLApiObject *)body;
@end;

@interface MTNetwork : NSObject<MTContextChangeListener>

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


id dispatch_in_time(int time, dispatch_block_t callback);
void remove_global_dispatcher(id internalId);

@end
