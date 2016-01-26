/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGTLSerialization.h"
#import "NSData+Extensions.h"



#import <MTProtoKit/MTDatacenterAddress.h>
#import <MTProtoKit/MTDatacenterSaltInfo.h>
#import <MtProtoKit/MTExportedAuthorizationData.h>

#import "MTProto.h"
#import "TLApi.h"
#import "ClassStore.h"

@interface TGTLSerialization ()

@end

@implementation TGTLSerialization

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
      
    }
    return self;
}

+ (NSData *)serializeMessage:(id)message
{
    if(!message)
        return nil;
    if([message respondsToSelector:@selector(getData)])
        return  [message getData];
    return [ClassStore serialize:message];
}

- (id)parseMessage:(NSData *)data
{
    NSInputStream *is = [[NSInputStream alloc] initWithData:data];
    [is open];
    
    id obj = [ClassStore constructObject:is];
    if([obj isKindOfClass:[TL_gzip_packed class]]) {
        obj = [ClassStore deserialize:[[obj packed_data] gzipInflate]];
    }
    
    return obj;
}

+ (id)parseResponse:(NSData *)data request:(id)request
{
    
    NSInputStream *is = [[NSInputStream alloc] initWithData:data];
    [is open];
    
    id obj = [ClassStore constructObject:is];
    if([obj isKindOfClass:[TL_gzip_packed class]]) {
        obj = [ClassStore deserialize:[[obj packed_data] gzipInflate]];
    }
    
    return obj;
}

- (MTExportAuthorizationResponseParser)exportAuthorization:(int32_t)datacenterId data:(__autoreleasing NSData **)data
{
    TLAPI_auth_exportAuthorization *exportAuthorization = [TLAPI_auth_exportAuthorization createWithDc_id:datacenterId];
    
    if (data)
        *data = [TGTLSerialization serializeMessage:exportAuthorization];
    
    return ^id (NSData *response)
    {
        id result = [self parseMessage:response];
        
        if ([result isKindOfClass:[TL_auth_exportedAuthorization class]])
        {
            return [[MTExportedAuthorizationData alloc] initWithAuthorizationBytes:((TLauth_ExportedAuthorization *)result).bytes authorizationId:((TLauth_ExportedAuthorization *)result).n_id];
        }
        return nil;
    };
}

- (NSData *)importAuthorization:(int32_t)authId bytes:(NSData *)bytes
{
    TLAPI_auth_importAuthorization *importAuthorization = [TLAPI_auth_importAuthorization createWithN_id:authId bytes:bytes];
    
    return [TGTLSerialization serializeMessage:importAuthorization];
}

- (MTRequestDatacenterAddressListParser)requestDatacenterAddressList:(int32_t)datacenterId data:(__autoreleasing NSData **)data
{
    NSData *getConfigData = [TGTLSerialization serializeMessage:[TLAPI_help_getConfig create]];
    if (data)
        *data = getConfigData;
    
    return ^MTDatacenterAddressListData *(NSData *response)
    {
        id result = [self parseMessage:response];
        if ([result isKindOfClass:[TLConfig class]])
        {
            NSMutableArray *addressList = [[NSMutableArray alloc] init];
            
            for (TLDcOption *dcOption in ((TLConfig *)result).dc_options)
            {
                if (dcOption.n_id == datacenterId)
                {
                    MTDatacenterAddress *address = [[MTDatacenterAddress alloc] initWithIp:dcOption.ip_address port:(uint16_t)dcOption.port preferForMedia:(dcOption.flags & 1 << 1) == 1 << 1];
                    [addressList addObject:address];
                }
            }
            
            return [[MTDatacenterAddressListData alloc] initWithAddressList:addressList];
        }
        return nil;
    };
}

- (NSUInteger)currentLayer
{
    return 43;
}

@end