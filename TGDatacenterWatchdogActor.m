/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDatacenterWatchdogActor.h"

#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTProto.h>
#import <MTProtoKit/MTTimer.h>
#import <MTProtoKit/MTRequestMessageService.h>
#import <MTProtoKit/MTRequest.h>
#import <MTProtoKit/MTDatacenterAddressSet.h>
#import <MTProtoKit/MTDatacenterAddress.h>

#import "MTNetwork.h"
@interface TGDatacenterWatchdogActor ()
{
    MTTimer *_startupTimer;
    MTTimer *_addOneMoreDatacenterTimer;
    
    NSMutableDictionary *_mtProtoByDatacenterId;
    NSMutableDictionary *_requestServiceByDatacenterId;
}

@end

@implementation TGDatacenterWatchdogActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/tg/datacenterWatchdog";
}

- (instancetype)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _mtProtoByDatacenterId = [[NSMutableDictionary alloc] init];
        _requestServiceByDatacenterId = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_startupTimer invalidate];
    _startupTimer = nil;
    
    [_addOneMoreDatacenterTimer invalidate];
    _addOneMoreDatacenterTimer = nil;
    
    NSDictionary *mtProtoByDatacenterId = [[NSDictionary alloc] initWithDictionary:_mtProtoByDatacenterId];
    _mtProtoByDatacenterId = nil;
    
    NSDictionary *requestServiceByDatacenterId = [[NSDictionary alloc] initWithDictionary:_requestServiceByDatacenterId];
    _requestServiceByDatacenterId = nil;
    
    [mtProtoByDatacenterId enumerateKeysAndObjectsUsingBlock:^(NSNumber *nDatacenterId, MTProto *mtProto, __unused BOOL *stop)
    {
        [mtProto removeMessageService:requestServiceByDatacenterId[nDatacenterId]];
        [mtProto stop];
    }];
}

- (void)execute:(NSDictionary *)__unused options
{
    __weak TGDatacenterWatchdogActor *weakSelf = self;
    
    [_startupTimer invalidate];
    
    _startupTimer = [[MTTimer alloc] initWithTimeout:8.0 repeat:false completion:^
    {
        __strong TGDatacenterWatchdogActor *strongSelf = weakSelf;
        [strongSelf begin];
    } queue:[ASQueue globalQueue].nativeQueue];
    
    
    [_startupTimer start];
}

- (void)begin
{
    MTContext *context = [[MTNetwork instance] context];
    if (context != nil)
    {
        [self addOneMoreDatacenter];
        
        __weak TGDatacenterWatchdogActor *weakSelf = self;
        _addOneMoreDatacenterTimer = [[MTTimer alloc] initWithTimeout:50 repeat:true completion:^
        {
            __strong TGDatacenterWatchdogActor *strongSelf = weakSelf;
            [strongSelf addOneMoreDatacenter];
        } queue:[ASQueue globalQueue].nativeQueue];
        [_addOneMoreDatacenterTimer start];
    }
}

- (void)addOneMoreDatacenter
{
    MTContext *context = [[MTNetwork instance] context];
    
    for (NSNumber *nDatacenterId in [context knownDatacenterIds])
    {
        if (_mtProtoByDatacenterId[nDatacenterId] == nil)
        {
            [self requestNetworkConfigFromDatacenter:[nDatacenterId integerValue]];
            
            break;
        }
    }
}

- (void)requestNetworkConfigFromDatacenter:(NSInteger)datacenterId
{
    MTLog(@"[TGDatacenterWatchdogActor#%p requesting network config from %d]", self, (int)datacenterId);
    
    MTContext *context = [[MTNetwork instance] context];
    
    MTProto *mtProto = [[MTProto alloc] initWithContext:context datacenterId:datacenterId];
    MTRequestMessageService *requestService = [[MTRequestMessageService alloc] initWithContext:context];
    [mtProto addMessageService:requestService];
    
    _mtProtoByDatacenterId[@(datacenterId)] = mtProto;
    _requestServiceByDatacenterId[@(datacenterId)] = requestService;
    
    MTRequest *request = [[MTRequest alloc] init];
    
    request.body = [TLAPI_help_getConfig create];
    
    __weak TGDatacenterWatchdogActor *weakSelf = self;
    
    [request setCompleted:^(TL_config *result, __unused NSTimeInterval timestamp, id error)
    {
        [ASQueue dispatchOnStageQueue:^{
            __strong TGDatacenterWatchdogActor *strongSelf = weakSelf;
            if (error == nil)
            {
                [strongSelf processConfig:result fromDatacenterId:datacenterId];
            }
        }];
    }];
    
    [requestService addRequest:request];
}

- (void)processConfig:(TL_config *)config fromDatacenterId:(NSInteger)datacenterId
{
    MTContext *context = [[MTNetwork instance] context];
    
    setMaxChatUsers(config.chat_size_max-1);
    setMegagroupSizeMax(config.megagroup_size_max);
    
#if TARGET_IPHONE_SIMULATOR
    NSMutableArray *dcOptions = [[NSMutableArray alloc] init];
    bool processedFirst = false;
    for (TLDcOption *dcOption in config.dc_options)
    {
        if (dcOption.n_id == 1)
        {
            if (!processedFirst)
            {
                TLDcOption$dcOption *modifiedOption = [[TLDcOption$dcOption alloc] init];
                modifiedOption.n_id = dcOption.n_id;
                modifiedOption.ip_address = dcOption.ip_address;
                modifiedOption.port = 443;
                [dcOptions addObject:modifiedOption];
                
                modifiedOption = [[TLDcOption$dcOption alloc] init];
                modifiedOption.n_id = dcOption.n_id;
                modifiedOption.ip_address = dcOption.ip_address;
                modifiedOption.port = 80;
                [dcOptions addObject:modifiedOption];
            }
        }
        else
            [dcOptions addObject:dcOption];
    }
    config.dc_options = dcOptions;
#endif
    
    [context performBatchUpdates:^
    {
        NSMutableDictionary *addressListByDatacenterId = [[NSMutableDictionary alloc] init];
        
        for (TL_dcOption *dcOption in config.dc_options)
        {
            MTDatacenterAddress *configAddress = [[MTDatacenterAddress alloc] initWithIp:dcOption.ip_address port:(uint16_t)dcOption.port preferForMedia:(dcOption.flags & 1 << 1) == 1 << 1];
            
            NSMutableArray *array = addressListByDatacenterId[@(dcOption.n_id)];
            if (array == nil)
            {
                array = [[NSMutableArray alloc] init];
                addressListByDatacenterId[@(dcOption.n_id)] = array;
            }
            
            if (![array containsObject:configAddress])
                [array addObject:configAddress];
        }
        
        [addressListByDatacenterId enumerateKeysAndObjectsUsingBlock:^(NSNumber *nDatacenterId, NSArray *addressList, __unused BOOL *stop)
        {
            MTDatacenterAddressSet *addressSet = [[MTDatacenterAddressSet alloc] initWithAddressList:addressList];

            MTDatacenterAddressSet *currentAddressSet = [context addressSetForDatacenterWithId:[nDatacenterId integerValue]];
            
            if (currentAddressSet == nil || ![addressSet isEqual:currentAddressSet])
            {
                MTLog(@"[TGDatacenterWatchdogActor#%p updating datacenter %d address set to %@]", self, [nDatacenterId intValue], addressSet);
                [context updateAddressSetForDatacenterWithId:[nDatacenterId integerValue] addressSet:addressSet];
            }
        }];
        
        [ASQueue dispatchOnStageQueue:^{
            
            MTLog(@"[TGDatacenterWatchdogActor#%p processed %d datacenter addresses from datacenter %d]", self, (int)config.dc_options.count, (int)datacenterId);
            
            
            
        }];
    }];
}

@end
