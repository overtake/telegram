#import <Foundation/Foundation.h>
#import <MtProtoKit/MTContext.h>
#import <MtProtoKit/MTProto.h>
#import <MTProtoKit/MTDatacenterAddressSet.h>
#import <MTProtoKit/MTDatacenterAddress.h>
#import <MtProtoKit/MTRequestMessageService.h>
#import <MTProtoKit/MTKeychain.h>
#import <MtProtoKit/MTQueue.h>
#import "TLApiObject.h"
#import "TGS_RPCRequest.h"

@interface MTRequest (LegacyTL)
-(void)setBody:(TLApiObject *)body;
@end

@interface TGS_MTNetwork : NSObject<MTContextChangeListener>

+ (TGS_MTNetwork *)instance;
-(void)initConnectionWithId:(NSInteger)dc_id;
-(void)sendRequest:(TGS_RPCRequest *)request;
-(void)sendRequest:(TGS_RPCRequest *)request forDatacenter:(int)datacenterId;
-(void)sendRandomRequest:(TGS_RPCRequest *)request;
-(MTDatacenterAuthInfo *)authInfoForDatacenter:(int)dc_id;
-(id<MTKeychain>)keyChain;
-(void)successAuthForDatacenter:(int)dc_id;
-(BOOL)isAuth;
-(int)getTime;
-(void)cancelRequest:(TGS_RPCRequest *)request;

-(int)getUserId;

-(void)startNetwork;

-(MTContext *)context;

-(void)update;

-(MTQueue *)queue;

-(void)updatePasscode:(NSData *)md5Hash;
-(BOOL)checkPasscode:(NSData *)md5Hash;
-(BOOL)passcodeIsEnabled;


id dispatch_in_time(int time, dispatch_block_t callback);
void remove_global_dispatcher(id internalId);

@end
