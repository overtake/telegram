#import <Foundation/Foundation.h>
#import <MtProtoKit/MTContext.h>
#import <MtProtoKit/MTProto.h>
#import <MTProtoKit/MTDatacenterAddressSet.h>
#import <MTProtoKit/MTDatacenterAddress.h>
#import <MtProtoKit/MTRequestMessageService.h>
#import <MTProtoKit/MTKeychain.h>
#import "TelegramSerialization.h"
#import "TGUpdateMessageService.h"
@interface MTNetwork : NSObject<MTContextChangeListener>

+ (MTNetwork *)instance;
-(void)initConnectionWithId:(NSInteger)dc_id;
-(void)sendRequest:(RPCRequest *)request;
-(void)sendRequest:(RPCRequest *)request forDatacenter:(int)datacenterId;
-(void)sendRandomRequest:(RPCRequest *)request;
-(MTDatacenterAuthInfo *)authInfoForDatacenter:(int)dc_id;
-(MTKeychain *)keyChain;
-(void)successAuthForDatacenter:(int)dc_id;
-(BOOL)isAuth;
-(void)drop;
-(int)getTime;
-(int)currentDatacenter;
-(void)setDatacenter:(int)dc_id;
-(void)cancelRequest:(RPCRequest *)request;

- (TGUpdateMessageService *)updateService;

-(void)startNetwork;

@end
