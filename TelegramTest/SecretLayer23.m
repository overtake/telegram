#import "SecretLayer23.h"
#import <objc/runtime.h>

static const char *Secret23__Serializer_Key = "Secret23__Serializer";

@interface Secret23__Serializer : NSObject

@property (nonatomic) int32_t constructorSignature;
@property (nonatomic, copy) bool (^serializeBlock)(id object, NSMutableData *);

@end

@implementation Secret23__Serializer

- (instancetype)initWithConstructorSignature:(int32_t)constructorSignature serializeBlock:(bool (^)(id, NSMutableData *))serializeBlock
{
    self = [super init];
    if (self != nil)
    {
        self.constructorSignature = constructorSignature;
        self.serializeBlock = serializeBlock;
    }
    return self;
}

+ (id)addSerializerToObject:(id)object withConstructorSignature:(int32_t)constructorSignature serializeBlock:(bool (^)(id, NSMutableData *))serializeBlock
{
    if (object != nil)
        objc_setAssociatedObject(object, Secret23__Serializer_Key, [[Secret23__Serializer alloc] initWithConstructorSignature:constructorSignature serializeBlock:serializeBlock], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

+ (id)addSerializerToObject:(id)object serializer:(Secret23__Serializer *)serializer
{
    if (object != nil)
        objc_setAssociatedObject(object, Secret23__Serializer_Key, serializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

@end

@interface Secret23__UnboxedTypeMetaInfo : NSObject

@property (nonatomic, readonly) int32_t constructorSignature;

@end

@implementation Secret23__UnboxedTypeMetaInfo

- (instancetype)initWithConstructorSignature:(int32_t)constructorSignature
{
    self = [super init];
    if (self != nil)
    {
        _constructorSignature = constructorSignature;
    }
    return self;
}

@end

@interface Secret23__PreferNSDataTypeMetaInfo : NSObject

@end

@implementation Secret23__PreferNSDataTypeMetaInfo

+ (instancetype)preferNSDataTypeMetaInfo
{
    static Secret23__PreferNSDataTypeMetaInfo *instance = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        instance = [[Secret23__PreferNSDataTypeMetaInfo alloc] init];
    });
    return instance;
}

@end

@interface Secret23__BoxedTypeMetaInfo : NSObject

@end

@implementation Secret23__BoxedTypeMetaInfo

+ (instancetype)boxedTypeMetaInfo
{
    static Secret23__BoxedTypeMetaInfo *instance = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        instance = [[Secret23__BoxedTypeMetaInfo alloc] init];
    });
    return instance;
}

@end

@implementation Secret23__Environment

+ (id (^)(NSData *data, NSUInteger *offset, id metaInfo))parserByConstructorSignature:(int32_t)constructorSignature
{
    static NSMutableDictionary *parsers = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        parsers = [[NSMutableDictionary alloc] init];

        parsers[@((int32_t)0xA8509BDA)] = [^id (NSData *data, NSUInteger *offset, __unused id metaInfo)
        {
            if (*offset + 4 > data.length)
                return nil;
            int32_t value = 0;
            [data getBytes:(void *)&value range:NSMakeRange(*offset, 4)];
            *offset += 4;
            return @(value);
        } copy];

        parsers[@((int32_t)0x22076CBA)] = [^id (NSData *data, NSUInteger *offset, __unused id metaInfo)
        {
            if (*offset + 8 > data.length)
                return nil;
            int64_t value = 0;
            [data getBytes:(void *)&value range:NSMakeRange(*offset, 8)];
            *offset += 8;
            return @(value);
        } copy];

        parsers[@((int32_t)0x2210C154)] = [^id (NSData *data, NSUInteger *offset, __unused id metaInfo)
        {
            if (*offset + 8 > data.length)
                return nil;
            double value = 0;
            [data getBytes:(void *)&value range:NSMakeRange(*offset, 8)];
            *offset += 8;
            return @(value);
        } copy];

        parsers[@((int32_t)0xB5286E24)] = [^id (NSData *data, NSUInteger *offset, __unused id metaInfo)
        {
            uint8_t tmp = 0;
            [data getBytes:(void *)&tmp range:NSMakeRange(*offset, 1)];
            *offset += 1;

            int paddingBytes = 0;

            int32_t length = tmp;
            if (length == 254)
            {
                length = 0;
                [data getBytes:((uint8_t *)&length) + 1 range:NSMakeRange(*offset, 3)];
                *offset += 3;
                length >>= 8;

                paddingBytes = (((length % 4) == 0 ? length : (length + 4 - (length % 4)))) - length;
            }
            else
                paddingBytes = ((((length + 1) % 4) == 0 ? (length + 1) : ((length + 1) + 4 - ((length + 1) % 4)))) - (length + 1);

            bool isData = [metaInfo isKindOfClass:[Secret23__PreferNSDataTypeMetaInfo class]];
            id object = nil;

            if (length > 0)
            {
                if (isData)
                    object = [[NSData alloc] initWithBytes:((uint8_t *)data.bytes) + *offset length:length];
                else
                    object = [[NSString alloc] initWithBytes:((uint8_t *)data.bytes) + *offset length:length encoding:NSUTF8StringEncoding];

                *offset += length;
            }

            *offset += paddingBytes;

            return object == nil ? (isData ? [NSData data] : @"") : object;
        } copy];

        parsers[@((int32_t)0x1cb5c415)] = [^id (NSData *data, NSUInteger *offset, id metaInfo)
        {
            if (*offset + 4 > data.length)
                return nil;

            int32_t count = 0;
            [data getBytes:(void *)&count range:NSMakeRange(*offset, 4)];
            *offset += 4;

            if (count < 0)
                return nil;

            bool isBoxed = false;
            int32_t unboxedConstructorSignature = 0;
            if ([metaInfo isKindOfClass:[Secret23__BoxedTypeMetaInfo class]])
                isBoxed = true;
            else if ([metaInfo isKindOfClass:[Secret23__UnboxedTypeMetaInfo class]])
                unboxedConstructorSignature = ((Secret23__UnboxedTypeMetaInfo *)metaInfo).constructorSignature;
            else
                return nil;

            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)count];
            for (int32_t i = 0; i < count; i++)
            {
                int32_t itemConstructorSignature = 0;
                if (isBoxed)
                {
                    [data getBytes:(void *)&itemConstructorSignature range:NSMakeRange(*offset, 4)];
                    *offset += 4;
                }
                else
                    itemConstructorSignature = unboxedConstructorSignature;
                id item = [Secret23__Environment parseObject:data offset:offset implicitSignature:itemConstructorSignature metaInfo:nil];
                if (item == nil)
                    return nil;

                [array addObject:item];
            }

            return array;
        } copy];

        parsers[@((int32_t)0xa1733aec)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * ttl_seconds = nil;
            if ((ttl_seconds = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtl_seconds:ttl_seconds];
        } copy];
        parsers[@((int32_t)0xc4f40be)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * random_ids = nil;
            int32_t random_ids_signature = 0; [data getBytes:(void *)&random_ids_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((random_ids = [Secret23__Environment parseObject:data offset:_offset implicitSignature:random_ids_signature metaInfo:[[Secret23__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionReadMessagesWithRandom_ids:random_ids];
        } copy];
        parsers[@((int32_t)0x65614304)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * random_ids = nil;
            int32_t random_ids_signature = 0; [data getBytes:(void *)&random_ids_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((random_ids = [Secret23__Environment parseObject:data offset:_offset implicitSignature:random_ids_signature metaInfo:[[Secret23__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandom_ids:random_ids];
        } copy];
        parsers[@((int32_t)0x8ac1f475)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * random_ids = nil;
            int32_t random_ids_signature = 0; [data getBytes:(void *)&random_ids_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((random_ids = [Secret23__Environment parseObject:data offset:_offset implicitSignature:random_ids_signature metaInfo:[[Secret23__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionScreenshotMessagesWithRandom_ids:random_ids];
        } copy];
        parsers[@((int32_t)0x6719e45c)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_DecryptedMessageAction decryptedMessageActionFlushHistory];
        } copy];
        parsers[@((int32_t)0xf3048883)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * layer = nil;
            if ((layer = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:layer];
        } copy];
        parsers[@((int32_t)0xccb27641)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            Secret23_SendMessageAction * action = nil;
            int32_t action_signature = 0; [data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [Secret23__Environment parseObject:data offset:_offset implicitSignature:action_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionTypingWithAction:action];
        } copy];
        parsers[@((int32_t)0x511110b0)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * start_seq_no = nil;
            if ((start_seq_no = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * end_seq_no = nil;
            if ((end_seq_no = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionResendWithStart_seq_no:start_seq_no end_seq_no:end_seq_no];
        } copy];
        parsers[@((int32_t)0xf3c9611b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchange_id = nil;
            if ((exchange_id = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * g_a = nil;
            if ((g_a = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionRequestKeyWithExchange_id:exchange_id g_a:g_a];
        } copy];
        parsers[@((int32_t)0x6fe1735b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchange_id = nil;
            if ((exchange_id = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * g_b = nil;
            if ((g_b = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * key_fingerprint = nil;
            if ((key_fingerprint = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionAcceptKeyWithExchange_id:exchange_id g_b:g_b key_fingerprint:key_fingerprint];
        } copy];
        parsers[@((int32_t)0xec2e0b9b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchange_id = nil;
            if ((exchange_id = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * key_fingerprint = nil;
            if ((key_fingerprint = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionCommitKeyWithExchange_id:exchange_id key_fingerprint:key_fingerprint];
        } copy];
        parsers[@((int32_t)0xdd05ec6b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchange_id = nil;
            if ((exchange_id = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageAction decryptedMessageActionAbortKeyWithExchange_id:exchange_id];
        } copy];
        parsers[@((int32_t)0xa82fdd63)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_DecryptedMessageAction decryptedMessageActionNoop];
        } copy];
        parsers[@((int32_t)0x16bf744e)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageTypingAction];
        } copy];
        parsers[@((int32_t)0xfd5ec8f5)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageCancelAction];
        } copy];
        parsers[@((int32_t)0xa187d66f)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageRecordVideoAction];
        } copy];
        parsers[@((int32_t)0x92042ff7)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageUploadVideoAction];
        } copy];
        parsers[@((int32_t)0xd52f73f7)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageRecordAudioAction];
        } copy];
        parsers[@((int32_t)0xe6ac8a6f)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageUploadAudioAction];
        } copy];
        parsers[@((int32_t)0x990a3c1a)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageUploadPhotoAction];
        } copy];
        parsers[@((int32_t)0x8faee98e)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageUploadDocumentAction];
        } copy];
        parsers[@((int32_t)0x176f8ba1)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageGeoLocationAction];
        } copy];
        parsers[@((int32_t)0x628cbc6f)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_SendMessageAction sendMessageChooseContactAction];
        } copy];
        parsers[@((int32_t)0xe17e23c)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * type = nil;
            if ((type = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret23_PhotoSize photoSizeEmptyWithType:type];
        } copy];
        parsers[@((int32_t)0x77bfb61b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * type = nil;
            if ((type = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret23_FileLocation * location = nil;
            int32_t location_signature = 0; [data getBytes:(void *)&location_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((location = [Secret23__Environment parseObject:data offset:_offset implicitSignature:location_signature metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_PhotoSize photoSizeWithType:type location:location w:w h:h size:size];
        } copy];
        parsers[@((int32_t)0xe9a734fa)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * type = nil;
            if ((type = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret23_FileLocation * location = nil;
            int32_t location_signature = 0; [data getBytes:(void *)&location_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((location = [Secret23__Environment parseObject:data offset:_offset implicitSignature:location_signature metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * bytes = nil;
            if ((bytes = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret23_PhotoSize photoCachedSizeWithType:type location:location w:w h:h bytes:bytes];
        } copy];
        parsers[@((int32_t)0x7c596b46)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * volume_id = nil;
            if ((volume_id = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * local_id = nil;
            if ((local_id = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * secret = nil;
            if ((secret = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret23_FileLocation fileLocationUnavailableWithVolume_id:volume_id local_id:local_id secret:secret];
        } copy];
        parsers[@((int32_t)0x53d69076)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * dc_id = nil;
            if ((dc_id = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * volume_id = nil;
            if ((volume_id = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * local_id = nil;
            if ((local_id = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * secret = nil;
            if ((secret = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret23_FileLocation fileLocationWithDc_id:dc_id volume_id:volume_id local_id:local_id secret:secret];
        } copy];
        parsers[@((int32_t)0x1be31789)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * random_bytes = nil;
            if ((random_bytes = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * layer = nil;
            if ((layer = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * in_seq_no = nil;
            if ((in_seq_no = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * out_seq_no = nil;
            if ((out_seq_no = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            Secret23_DecryptedMessage * message = nil;
            int32_t message_signature = 0; [data getBytes:(void *)&message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((message = [Secret23__Environment parseObject:data offset:_offset implicitSignature:message_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:random_bytes layer:layer in_seq_no:in_seq_no out_seq_no:out_seq_no message:message];
        } copy];
        parsers[@((int32_t)0x204d3878)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * random_id = nil;
            if ((random_id = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * ttl = nil;
            if ((ttl = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * message = nil;
            if ((message = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret23_DecryptedMessageMedia * media = nil;
            int32_t media_signature = 0; [data getBytes:(void *)&media_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((media = [Secret23__Environment parseObject:data offset:_offset implicitSignature:media_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessage decryptedMessageWithRandom_id:random_id ttl:ttl message:message media:media];
        } copy];
        parsers[@((int32_t)0x73164160)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * random_id = nil;
            if ((random_id = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            Secret23_DecryptedMessageAction * action = nil;
            int32_t action_signature = 0; [data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [Secret23__Environment parseObject:data offset:_offset implicitSignature:action_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessage decryptedMessageServiceWithRandom_id:random_id action:action];
        } copy];
        parsers[@((int32_t)0x6c37c15c)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * w = nil;
            if ((w = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DocumentAttribute documentAttributeImageSizeWithW:w h:h];
        } copy];
        parsers[@((int32_t)0x11b58939)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_DocumentAttribute documentAttributeAnimated];
        } copy];
        parsers[@((int32_t)0xfb0a5727)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_DocumentAttribute documentAttributeSticker];
        } copy];
        parsers[@((int32_t)0x5910cccb)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * duration = nil;
            if ((duration = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DocumentAttribute documentAttributeVideoWithDuration:duration w:w h:h];
        } copy];
        parsers[@((int32_t)0x51448e5)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * duration = nil;
            if ((duration = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DocumentAttribute documentAttributeAudioWithDuration:duration];
        } copy];
        parsers[@((int32_t)0x15590068)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * file_name = nil;
            if ((file_name = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DocumentAttribute documentAttributeFilenameWithFile_name:file_name];
        } copy];
        parsers[@((int32_t)0x89f5c4a)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaEmpty];
        } copy];
        parsers[@((int32_t)0x32798a8c)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumb_w = nil;
            if ((thumb_w = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumb_h = nil;
            if ((thumb_h = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumb thumb_w:thumb_w thumb_h:thumb_h w:w h:h size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x35480a59)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * lat = nil;
            if ((lat = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            NSNumber * plong = nil;
            if ((plong = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaGeoPointWithLat:lat plong:plong];
        } copy];
        parsers[@((int32_t)0x588a0a97)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * phone_number = nil;
            if ((phone_number = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * first_name = nil;
            if ((first_name = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * last_name = nil;
            if ((last_name = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * user_id = nil;
            if ((user_id = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaContactWithPhone_number:phone_number first_name:first_name last_name:last_name user_id:user_id];
        } copy];
        parsers[@((int32_t)0xb095434b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumb_w = nil;
            if ((thumb_w = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumb_h = nil;
            if ((thumb_h = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * file_name = nil;
            if ((file_name = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumb thumb_w:thumb_w thumb_h:thumb_h file_name:file_name mime_type:mime_type size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x524a415d)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumb_w = nil;
            if ((thumb_w = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumb_h = nil;
            if ((thumb_h = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb:thumb thumb_w:thumb_w thumb_h:thumb_h duration:duration mime_type:mime_type w:w h:h size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x57e0a9cb)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * duration = nil;
            if ((duration = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret23__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:duration mime_type:mime_type size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0xfa95b0dd)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * pid = nil;
            if ((pid = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            Secret23_PhotoSize * thumb = nil;
            int32_t thumb_signature = 0; [data getBytes:(void *)&thumb_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((thumb = [Secret23__Environment parseObject:data offset:_offset implicitSignature:thumb_signature metaInfo:nil]) == nil)
               return nil;
            NSNumber * dc_id = nil;
            if ((dc_id = [Secret23__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSArray * attributes = nil;
            int32_t attributes_signature = 0; [data getBytes:(void *)&attributes_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((attributes = [Secret23__Environment parseObject:data offset:_offset implicitSignature:attributes_signature metaInfo:[Secret23__BoxedTypeMetaInfo boxedTypeMetaInfo]]) == nil)
               return nil;
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaExternalDocumentWithPid:pid access_hash:access_hash date:date mime_type:mime_type size:size thumb:thumb dc_id:dc_id attributes:attributes];
        } copy];
});

    return parsers[@(constructorSignature)];
}

+ (NSData *)serializeObject:(id)object
{
    NSMutableData *data = [[NSMutableData alloc] init];
    if ([self serializeObject:object data:data addSignature:true])
        return data;
    return nil;
}

+ (bool)serializeObject:(id)object data:(NSMutableData *)data addSignature:(bool)addSignature
{
     Secret23__Serializer *serializer = objc_getAssociatedObject(object, Secret23__Serializer_Key);
     if (serializer == nil)
         return false;
     if (addSignature)
     {
         int32_t value = serializer.constructorSignature;
         [data appendBytes:(void *)&value length:4];
     }
     return serializer.serializeBlock(object, data);
}

+ (id)parseObject:(NSData *)data
{
    if (data.length < 4)
        return nil;
    int32_t constructorSignature = 0;
    [data getBytes:(void *)&constructorSignature length:4];
    NSUInteger offset = 4;
    return [self parseObject:data offset:&offset implicitSignature:constructorSignature metaInfo:nil];
}

+ (id)parseObject:(NSData *)data offset:(NSUInteger *)offset implicitSignature:(int32_t)implicitSignature metaInfo:(id)metaInfo
{
    id (^parser)(NSData *data, NSUInteger *offset, id metaInfo) = [self parserByConstructorSignature:implicitSignature];
    if (parser)
        return parser(data, offset, metaInfo);
    return nil;
}

@end

@interface Secret23_BuiltinSerializer_Int : Secret23__Serializer
@end

@implementation Secret23_BuiltinSerializer_Int

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0xA8509BDA serializeBlock:^bool (NSNumber *object, NSMutableData *data)
    {
        int32_t value = (int32_t)[object intValue];
        [data appendBytes:(void *)&value length:4];
        return true;
    }];
}

@end

@interface Secret23_BuiltinSerializer_Long : Secret23__Serializer
@end

@implementation Secret23_BuiltinSerializer_Long

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0x22076CBA serializeBlock:^bool (NSNumber *object, NSMutableData *data)
    {
        int64_t value = (int64_t)[object longLongValue];
        [data appendBytes:(void *)&value length:8];
        return true;
    }];
}

@end

@interface Secret23_BuiltinSerializer_Double : Secret23__Serializer
@end

@implementation Secret23_BuiltinSerializer_Double

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0x2210C154 serializeBlock:^bool (NSNumber *object, NSMutableData *data)
    {
        double value = (double)[object doubleValue];
        [data appendBytes:(void *)&value length:8];
        return true;
    }];
}

@end

@interface Secret23_BuiltinSerializer_String : Secret23__Serializer
@end

@implementation Secret23_BuiltinSerializer_String

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0xB5286E24 serializeBlock:^bool (NSString *object, NSMutableData *data)
    {
        NSData *value = [object dataUsingEncoding:NSUTF8StringEncoding];
        int32_t length = value.length;
        int32_t padding = 0;
        if (length >= 254)
        {
            uint8_t tmp = 254;
            [data appendBytes:&tmp length:1];
            [data appendBytes:(void *)&length length:3];
            padding = (((length % 4) == 0 ? length : (length + 4 - (length % 4)))) - length;
        }
        else
        {
            [data appendBytes:(void *)&length length:1];
            padding = ((((length + 1) % 4) == 0 ? (length + 1) : ((length + 1) + 4 - ((length + 1) % 4)))) - (length + 1);
        }
        [data appendData:value];
        for (int i = 0; i < padding; i++)
        {
            uint8_t tmp = 0;
            [data appendBytes:(void *)&tmp length:1];
        }

        return true;
    }];
}

@end

@interface Secret23_BuiltinSerializer_Bytes : Secret23__Serializer
@end

@implementation Secret23_BuiltinSerializer_Bytes

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0xB5286E24 serializeBlock:^bool (NSData *object, NSMutableData *data)
    {
        NSData *value = object;
        int32_t length = value.length;
        int32_t padding = 0;
        if (length >= 254)
        {
            uint8_t tmp = 254;
            [data appendBytes:&tmp length:1];
            [data appendBytes:(void *)&length length:3];
            padding = (((length % 4) == 0 ? length : (length + 4 - (length % 4)))) - length;
        }
        else
        {
            [data appendBytes:(void *)&length length:1];
            padding = ((((length + 1) % 4) == 0 ? (length + 1) : ((length + 1) + 4 - ((length + 1) % 4)))) - (length + 1);
        }
        [data appendData:value];
        for (int i = 0; i < padding; i++)
        {
            uint8_t tmp = 0;
            [data appendBytes:(void *)&tmp length:1];
        }

        return true;
    }];
}

@end

@interface Secret23_BuiltinSerializer_Int128 : Secret23__Serializer
@end

@implementation Secret23_BuiltinSerializer_Int128

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0x4BB5362B serializeBlock:^bool (NSData *object, NSMutableData *data)
    {
        if (object.length != 16)
            return false;
        [data appendData:object];
        return true;
    }];
}

@end

@interface Secret23_BuiltinSerializer_Int256 : Secret23__Serializer
@end

@implementation Secret23_BuiltinSerializer_Int256

- (instancetype)init
{
    return [super initWithConstructorSignature:(int32_t)0x0929C32F serializeBlock:^bool (NSData *object, NSMutableData *data)
    {
        if (object.length != 32)
            return false;
        [data appendData:object];
        return true;
    }];
}

@end


@interface Secret23_DecryptedMessageAction ()

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL ()

@property (nonatomic, strong) NSNumber * ttl_seconds;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages ()

@property (nonatomic, strong) NSArray * random_ids;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages ()

@property (nonatomic, strong) NSArray * random_ids;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages ()

@property (nonatomic, strong) NSArray * random_ids;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory ()

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer ()

@property (nonatomic, strong) NSNumber * layer;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionTyping ()

@property (nonatomic, strong) Secret23_SendMessageAction * action;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionResend ()

@property (nonatomic, strong) NSNumber * start_seq_no;
@property (nonatomic, strong) NSNumber * end_seq_no;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey ()

@property (nonatomic, strong) NSNumber * exchange_id;
@property (nonatomic, strong) NSData * g_a;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey ()

@property (nonatomic, strong) NSNumber * exchange_id;
@property (nonatomic, strong) NSData * g_b;
@property (nonatomic, strong) NSNumber * key_fingerprint;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey ()

@property (nonatomic, strong) NSNumber * exchange_id;
@property (nonatomic, strong) NSNumber * key_fingerprint;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey ()

@property (nonatomic, strong) NSNumber * exchange_id;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionNoop ()

@end

@implementation Secret23_DecryptedMessageAction

+ (Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtl_seconds:(NSNumber *)ttl_seconds
{
    Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL alloc] init];
    _object.ttl_seconds = [Secret23__Serializer addSerializerToObject:[ttl_seconds copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandom_ids:(NSArray *)random_ids
{
    Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages alloc] init];
    _object.random_ids = 
({
NSMutableArray *random_ids_copy = [[NSMutableArray alloc] initWithCapacity:random_ids.count];
for (id random_ids_item in random_ids)
{
    [random_ids_copy addObject:[Secret23__Serializer addSerializerToObject:[random_ids_item copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]]];
}
id random_ids_result = [Secret23__Serializer addSerializerToObject:random_ids_copy serializer:[[Secret23__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret23__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; random_ids_result;});
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandom_ids:(NSArray *)random_ids
{
    Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages alloc] init];
    _object.random_ids = 
({
NSMutableArray *random_ids_copy = [[NSMutableArray alloc] initWithCapacity:random_ids.count];
for (id random_ids_item in random_ids)
{
    [random_ids_copy addObject:[Secret23__Serializer addSerializerToObject:[random_ids_item copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]]];
}
id random_ids_result = [Secret23__Serializer addSerializerToObject:random_ids_copy serializer:[[Secret23__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret23__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; random_ids_result;});
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandom_ids:(NSArray *)random_ids
{
    Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages alloc] init];
    _object.random_ids = 
({
NSMutableArray *random_ids_copy = [[NSMutableArray alloc] initWithCapacity:random_ids.count];
for (id random_ids_item in random_ids)
{
    [random_ids_copy addObject:[Secret23__Serializer addSerializerToObject:[random_ids_item copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]]];
}
id random_ids_result = [Secret23__Serializer addSerializerToObject:random_ids_copy serializer:[[Secret23__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret23__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; random_ids_result;});
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory
{
    Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory alloc] init];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer
{
    Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer alloc] init];
    _object.layer = [Secret23__Serializer addSerializerToObject:[layer copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionTyping *)decryptedMessageActionTypingWithAction:(Secret23_SendMessageAction *)action
{
    Secret23_DecryptedMessageAction_decryptedMessageActionTyping *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionTyping alloc] init];
    _object.action = action;
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionResend *)decryptedMessageActionResendWithStart_seq_no:(NSNumber *)start_seq_no end_seq_no:(NSNumber *)end_seq_no
{
    Secret23_DecryptedMessageAction_decryptedMessageActionResend *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionResend alloc] init];
    _object.start_seq_no = [Secret23__Serializer addSerializerToObject:[start_seq_no copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.end_seq_no = [Secret23__Serializer addSerializerToObject:[end_seq_no copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey *)decryptedMessageActionRequestKeyWithExchange_id:(NSNumber *)exchange_id g_a:(NSData *)g_a
{
    Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey alloc] init];
    _object.exchange_id = [Secret23__Serializer addSerializerToObject:[exchange_id copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.g_a = [Secret23__Serializer addSerializerToObject:[g_a copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey *)decryptedMessageActionAcceptKeyWithExchange_id:(NSNumber *)exchange_id g_b:(NSData *)g_b key_fingerprint:(NSNumber *)key_fingerprint
{
    Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey alloc] init];
    _object.exchange_id = [Secret23__Serializer addSerializerToObject:[exchange_id copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.g_b = [Secret23__Serializer addSerializerToObject:[g_b copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.key_fingerprint = [Secret23__Serializer addSerializerToObject:[key_fingerprint copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey *)decryptedMessageActionCommitKeyWithExchange_id:(NSNumber *)exchange_id key_fingerprint:(NSNumber *)key_fingerprint
{
    Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey alloc] init];
    _object.exchange_id = [Secret23__Serializer addSerializerToObject:[exchange_id copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.key_fingerprint = [Secret23__Serializer addSerializerToObject:[key_fingerprint copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey *)decryptedMessageActionAbortKeyWithExchange_id:(NSNumber *)exchange_id
{
    Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey alloc] init];
    _object.exchange_id = [Secret23__Serializer addSerializerToObject:[exchange_id copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageAction_decryptedMessageActionNoop *)decryptedMessageActionNoop
{
    Secret23_DecryptedMessageAction_decryptedMessageActionNoop *_object = [[Secret23_DecryptedMessageAction_decryptedMessageActionNoop alloc] init];
    return _object;
}


@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xa1733aec serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.ttl_seconds data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionSetMessageTTL ttl_seconds:%@)", self.ttl_seconds];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xc4f40be serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.random_ids data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionReadMessages random_ids:%@)", self.random_ids];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x65614304 serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.random_ids data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionDeleteMessages random_ids:%@)", self.random_ids];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x8ac1f475 serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.random_ids data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionScreenshotMessages random_ids:%@)", self.random_ids];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x6719e45c serializeBlock:^bool (__unused Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionFlushHistory)"];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xf3048883 serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.layer data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionNotifyLayer layer:%@)", self.layer];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionTyping

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xccb27641 serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionTyping *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.action data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionTyping action:%@)", self.action];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionResend

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x511110b0 serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionResend *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.start_seq_no data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.end_seq_no data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionResend start_seq_no:%@ end_seq_no:%@)", self.start_seq_no, self.end_seq_no];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xf3c9611b serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.exchange_id data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.g_a data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionRequestKey exchange_id:%@ g_a:%@)", self.exchange_id, self.g_a];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x6fe1735b serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.exchange_id data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.g_b data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.key_fingerprint data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionAcceptKey exchange_id:%@ g_b:%@ key_fingerprint:%@)", self.exchange_id, self.g_b, self.key_fingerprint];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xec2e0b9b serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.exchange_id data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.key_fingerprint data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionCommitKey exchange_id:%@ key_fingerprint:%@)", self.exchange_id, self.key_fingerprint];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xdd05ec6b serializeBlock:^bool (Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.exchange_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionAbortKey exchange_id:%@)", self.exchange_id];
}

@end

@implementation Secret23_DecryptedMessageAction_decryptedMessageActionNoop

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xa82fdd63 serializeBlock:^bool (__unused Secret23_DecryptedMessageAction_decryptedMessageActionNoop *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionNoop)"];
}

@end




@interface Secret23_SendMessageAction ()

@end

@interface Secret23_SendMessageAction_sendMessageTypingAction ()

@end

@interface Secret23_SendMessageAction_sendMessageCancelAction ()

@end

@interface Secret23_SendMessageAction_sendMessageRecordVideoAction ()

@end

@interface Secret23_SendMessageAction_sendMessageUploadVideoAction ()

@end

@interface Secret23_SendMessageAction_sendMessageRecordAudioAction ()

@end

@interface Secret23_SendMessageAction_sendMessageUploadAudioAction ()

@end

@interface Secret23_SendMessageAction_sendMessageUploadPhotoAction ()

@end

@interface Secret23_SendMessageAction_sendMessageUploadDocumentAction ()

@end

@interface Secret23_SendMessageAction_sendMessageGeoLocationAction ()

@end

@interface Secret23_SendMessageAction_sendMessageChooseContactAction ()

@end

@implementation Secret23_SendMessageAction

+ (Secret23_SendMessageAction_sendMessageTypingAction *)sendMessageTypingAction
{
    Secret23_SendMessageAction_sendMessageTypingAction *_object = [[Secret23_SendMessageAction_sendMessageTypingAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageCancelAction *)sendMessageCancelAction
{
    Secret23_SendMessageAction_sendMessageCancelAction *_object = [[Secret23_SendMessageAction_sendMessageCancelAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageRecordVideoAction *)sendMessageRecordVideoAction
{
    Secret23_SendMessageAction_sendMessageRecordVideoAction *_object = [[Secret23_SendMessageAction_sendMessageRecordVideoAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageUploadVideoAction *)sendMessageUploadVideoAction
{
    Secret23_SendMessageAction_sendMessageUploadVideoAction *_object = [[Secret23_SendMessageAction_sendMessageUploadVideoAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageRecordAudioAction *)sendMessageRecordAudioAction
{
    Secret23_SendMessageAction_sendMessageRecordAudioAction *_object = [[Secret23_SendMessageAction_sendMessageRecordAudioAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageUploadAudioAction *)sendMessageUploadAudioAction
{
    Secret23_SendMessageAction_sendMessageUploadAudioAction *_object = [[Secret23_SendMessageAction_sendMessageUploadAudioAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageUploadPhotoAction *)sendMessageUploadPhotoAction
{
    Secret23_SendMessageAction_sendMessageUploadPhotoAction *_object = [[Secret23_SendMessageAction_sendMessageUploadPhotoAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageUploadDocumentAction *)sendMessageUploadDocumentAction
{
    Secret23_SendMessageAction_sendMessageUploadDocumentAction *_object = [[Secret23_SendMessageAction_sendMessageUploadDocumentAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageGeoLocationAction *)sendMessageGeoLocationAction
{
    Secret23_SendMessageAction_sendMessageGeoLocationAction *_object = [[Secret23_SendMessageAction_sendMessageGeoLocationAction alloc] init];
    return _object;
}

+ (Secret23_SendMessageAction_sendMessageChooseContactAction *)sendMessageChooseContactAction
{
    Secret23_SendMessageAction_sendMessageChooseContactAction *_object = [[Secret23_SendMessageAction_sendMessageChooseContactAction alloc] init];
    return _object;
}


@end

@implementation Secret23_SendMessageAction_sendMessageTypingAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x16bf744e serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageTypingAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageTypingAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageCancelAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xfd5ec8f5 serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageCancelAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageCancelAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageRecordVideoAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xa187d66f serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageRecordVideoAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageRecordVideoAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageUploadVideoAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x92042ff7 serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageUploadVideoAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageUploadVideoAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageRecordAudioAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xd52f73f7 serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageRecordAudioAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageRecordAudioAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageUploadAudioAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xe6ac8a6f serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageUploadAudioAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageUploadAudioAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageUploadPhotoAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x990a3c1a serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageUploadPhotoAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageUploadPhotoAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageUploadDocumentAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x8faee98e serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageUploadDocumentAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageUploadDocumentAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageGeoLocationAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x176f8ba1 serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageGeoLocationAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageGeoLocationAction)"];
}

@end

@implementation Secret23_SendMessageAction_sendMessageChooseContactAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x628cbc6f serializeBlock:^bool (__unused Secret23_SendMessageAction_sendMessageChooseContactAction *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(sendMessageChooseContactAction)"];
}

@end




@interface Secret23_PhotoSize ()

@property (nonatomic, strong) NSString * type;

@end

@interface Secret23_PhotoSize_photoSizeEmpty ()

@end

@interface Secret23_PhotoSize_photoSize ()

@property (nonatomic, strong) Secret23_FileLocation * location;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;

@end

@interface Secret23_PhotoSize_photoCachedSize ()

@property (nonatomic, strong) Secret23_FileLocation * location;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSData * bytes;

@end

@implementation Secret23_PhotoSize

+ (Secret23_PhotoSize_photoSizeEmpty *)photoSizeEmptyWithType:(NSString *)type
{
    Secret23_PhotoSize_photoSizeEmpty *_object = [[Secret23_PhotoSize_photoSizeEmpty alloc] init];
    _object.type = [Secret23__Serializer addSerializerToObject:[type copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret23_PhotoSize_photoSize *)photoSizeWithType:(NSString *)type location:(Secret23_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size
{
    Secret23_PhotoSize_photoSize *_object = [[Secret23_PhotoSize_photoSize alloc] init];
    _object.type = [Secret23__Serializer addSerializerToObject:[type copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.location = location;
    _object.w = [Secret23__Serializer addSerializerToObject:[w copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret23__Serializer addSerializerToObject:[h copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret23__Serializer addSerializerToObject:[size copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_PhotoSize_photoCachedSize *)photoCachedSizeWithType:(NSString *)type location:(Secret23_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h bytes:(NSData *)bytes
{
    Secret23_PhotoSize_photoCachedSize *_object = [[Secret23_PhotoSize_photoCachedSize alloc] init];
    _object.type = [Secret23__Serializer addSerializerToObject:[type copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.location = location;
    _object.w = [Secret23__Serializer addSerializerToObject:[w copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret23__Serializer addSerializerToObject:[h copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.bytes = [Secret23__Serializer addSerializerToObject:[bytes copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}


@end

@implementation Secret23_PhotoSize_photoSizeEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xe17e23c serializeBlock:^bool (Secret23_PhotoSize_photoSizeEmpty *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(photoSizeEmpty type:%@)", self.type];
}

@end

@implementation Secret23_PhotoSize_photoSize

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x77bfb61b serializeBlock:^bool (Secret23_PhotoSize_photoSize *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.location data:data addSignature:true])
                return false;
            if (![Secret23__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(photoSize type:%@ location:%@ w:%@ h:%@ size:%@)", self.type, self.location, self.w, self.h, self.size];
}

@end

@implementation Secret23_PhotoSize_photoCachedSize

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xe9a734fa serializeBlock:^bool (Secret23_PhotoSize_photoCachedSize *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.location data:data addSignature:true])
                return false;
            if (![Secret23__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.bytes data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(photoCachedSize type:%@ location:%@ w:%@ h:%@ bytes:%@)", self.type, self.location, self.w, self.h, self.bytes];
}

@end




@interface Secret23_FileLocation ()

@property (nonatomic, strong) NSNumber * volume_id;
@property (nonatomic, strong) NSNumber * local_id;
@property (nonatomic, strong) NSNumber * secret;

@end

@interface Secret23_FileLocation_fileLocationUnavailable ()

@end

@interface Secret23_FileLocation_fileLocation ()

@property (nonatomic, strong) NSNumber * dc_id;

@end

@implementation Secret23_FileLocation

+ (Secret23_FileLocation_fileLocationUnavailable *)fileLocationUnavailableWithVolume_id:(NSNumber *)volume_id local_id:(NSNumber *)local_id secret:(NSNumber *)secret
{
    Secret23_FileLocation_fileLocationUnavailable *_object = [[Secret23_FileLocation_fileLocationUnavailable alloc] init];
    _object.volume_id = [Secret23__Serializer addSerializerToObject:[volume_id copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.local_id = [Secret23__Serializer addSerializerToObject:[local_id copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.secret = [Secret23__Serializer addSerializerToObject:[secret copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret23_FileLocation_fileLocation *)fileLocationWithDc_id:(NSNumber *)dc_id volume_id:(NSNumber *)volume_id local_id:(NSNumber *)local_id secret:(NSNumber *)secret
{
    Secret23_FileLocation_fileLocation *_object = [[Secret23_FileLocation_fileLocation alloc] init];
    _object.dc_id = [Secret23__Serializer addSerializerToObject:[dc_id copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.volume_id = [Secret23__Serializer addSerializerToObject:[volume_id copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.local_id = [Secret23__Serializer addSerializerToObject:[local_id copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.secret = [Secret23__Serializer addSerializerToObject:[secret copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation Secret23_FileLocation_fileLocationUnavailable

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x7c596b46 serializeBlock:^bool (Secret23_FileLocation_fileLocationUnavailable *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.volume_id data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.local_id data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.secret data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(fileLocationUnavailable volume_id:%@ local_id:%@ secret:%@)", self.volume_id, self.local_id, self.secret];
}

@end

@implementation Secret23_FileLocation_fileLocation

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x53d69076 serializeBlock:^bool (Secret23_FileLocation_fileLocation *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.dc_id data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.volume_id data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.local_id data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.secret data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(fileLocation dc_id:%@ volume_id:%@ local_id:%@ secret:%@)", self.dc_id, self.volume_id, self.local_id, self.secret];
}

@end




@interface Secret23_DecryptedMessageLayer ()

@property (nonatomic, strong) NSData * random_bytes;
@property (nonatomic, strong) NSNumber * layer;
@property (nonatomic, strong) NSNumber * in_seq_no;
@property (nonatomic, strong) NSNumber * out_seq_no;
@property (nonatomic, strong) Secret23_DecryptedMessage * message;

@end

@interface Secret23_DecryptedMessageLayer_decryptedMessageLayer ()

@end

@implementation Secret23_DecryptedMessageLayer

+ (Secret23_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithRandom_bytes:(NSData *)random_bytes layer:(NSNumber *)layer in_seq_no:(NSNumber *)in_seq_no out_seq_no:(NSNumber *)out_seq_no message:(Secret23_DecryptedMessage *)message
{
    Secret23_DecryptedMessageLayer_decryptedMessageLayer *_object = [[Secret23_DecryptedMessageLayer_decryptedMessageLayer alloc] init];
    _object.random_bytes = [Secret23__Serializer addSerializerToObject:[random_bytes copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.layer = [Secret23__Serializer addSerializerToObject:[layer copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.in_seq_no = [Secret23__Serializer addSerializerToObject:[in_seq_no copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.out_seq_no = [Secret23__Serializer addSerializerToObject:[out_seq_no copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.message = message;
    return _object;
}


@end

@implementation Secret23_DecryptedMessageLayer_decryptedMessageLayer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x1be31789 serializeBlock:^bool (Secret23_DecryptedMessageLayer_decryptedMessageLayer *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.random_bytes data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.layer data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.in_seq_no data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.out_seq_no data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.message data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageLayer random_bytes:%@ layer:%@ in_seq_no:%@ out_seq_no:%@ message:%@)", self.random_bytes, self.layer, self.in_seq_no, self.out_seq_no, self.message];
}

@end




@interface Secret23_DecryptedMessage ()

@property (nonatomic, strong) NSNumber * random_id;

@end

@interface Secret23_DecryptedMessage_decryptedMessage ()

@property (nonatomic, strong) NSNumber * ttl;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) Secret23_DecryptedMessageMedia * media;

@end

@interface Secret23_DecryptedMessage_decryptedMessageService ()

@property (nonatomic, strong) Secret23_DecryptedMessageAction * action;

@end

@implementation Secret23_DecryptedMessage

+ (Secret23_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandom_id:(NSNumber *)random_id ttl:(NSNumber *)ttl message:(NSString *)message media:(Secret23_DecryptedMessageMedia *)media
{
    Secret23_DecryptedMessage_decryptedMessage *_object = [[Secret23_DecryptedMessage_decryptedMessage alloc] init];
    _object.random_id = [Secret23__Serializer addSerializerToObject:[random_id copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.ttl = [Secret23__Serializer addSerializerToObject:[ttl copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.message = [Secret23__Serializer addSerializerToObject:[message copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.media = media;
    return _object;
}

+ (Secret23_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandom_id:(NSNumber *)random_id action:(Secret23_DecryptedMessageAction *)action
{
    Secret23_DecryptedMessage_decryptedMessageService *_object = [[Secret23_DecryptedMessage_decryptedMessageService alloc] init];
    _object.random_id = [Secret23__Serializer addSerializerToObject:[random_id copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.action = action;
    return _object;
}


@end

@implementation Secret23_DecryptedMessage_decryptedMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x204d3878 serializeBlock:^bool (Secret23_DecryptedMessage_decryptedMessage *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.random_id data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.ttl data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.message data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.media data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessage random_id:%@ ttl:%@ message:%@ media:%@)", self.random_id, self.ttl, self.message, self.media];
}

@end

@implementation Secret23_DecryptedMessage_decryptedMessageService

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x73164160 serializeBlock:^bool (Secret23_DecryptedMessage_decryptedMessageService *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.random_id data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.action data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageService random_id:%@ action:%@)", self.random_id, self.action];
}

@end




@interface Secret23_DocumentAttribute ()

@end

@interface Secret23_DocumentAttribute_documentAttributeImageSize ()

@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;

@end

@interface Secret23_DocumentAttribute_documentAttributeAnimated ()

@end

@interface Secret23_DocumentAttribute_documentAttributeSticker ()

@end

@interface Secret23_DocumentAttribute_documentAttributeVideo ()

@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;

@end

@interface Secret23_DocumentAttribute_documentAttributeAudio ()

@property (nonatomic, strong) NSNumber * duration;

@end

@interface Secret23_DocumentAttribute_documentAttributeFilename ()

@property (nonatomic, strong) NSString * file_name;

@end

@implementation Secret23_DocumentAttribute

+ (Secret23_DocumentAttribute_documentAttributeImageSize *)documentAttributeImageSizeWithW:(NSNumber *)w h:(NSNumber *)h
{
    Secret23_DocumentAttribute_documentAttributeImageSize *_object = [[Secret23_DocumentAttribute_documentAttributeImageSize alloc] init];
    _object.w = [Secret23__Serializer addSerializerToObject:[w copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret23__Serializer addSerializerToObject:[h copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_DocumentAttribute_documentAttributeAnimated *)documentAttributeAnimated
{
    Secret23_DocumentAttribute_documentAttributeAnimated *_object = [[Secret23_DocumentAttribute_documentAttributeAnimated alloc] init];
    return _object;
}

+ (Secret23_DocumentAttribute_documentAttributeSticker *)documentAttributeSticker
{
    Secret23_DocumentAttribute_documentAttributeSticker *_object = [[Secret23_DocumentAttribute_documentAttributeSticker alloc] init];
    return _object;
}

+ (Secret23_DocumentAttribute_documentAttributeVideo *)documentAttributeVideoWithDuration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h
{
    Secret23_DocumentAttribute_documentAttributeVideo *_object = [[Secret23_DocumentAttribute_documentAttributeVideo alloc] init];
    _object.duration = [Secret23__Serializer addSerializerToObject:[duration copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.w = [Secret23__Serializer addSerializerToObject:[w copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret23__Serializer addSerializerToObject:[h copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_DocumentAttribute_documentAttributeAudio *)documentAttributeAudioWithDuration:(NSNumber *)duration
{
    Secret23_DocumentAttribute_documentAttributeAudio *_object = [[Secret23_DocumentAttribute_documentAttributeAudio alloc] init];
    _object.duration = [Secret23__Serializer addSerializerToObject:[duration copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_DocumentAttribute_documentAttributeFilename *)documentAttributeFilenameWithFile_name:(NSString *)file_name
{
    Secret23_DocumentAttribute_documentAttributeFilename *_object = [[Secret23_DocumentAttribute_documentAttributeFilename alloc] init];
    _object.file_name = [Secret23__Serializer addSerializerToObject:[file_name copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation Secret23_DocumentAttribute_documentAttributeImageSize

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x6c37c15c serializeBlock:^bool (Secret23_DocumentAttribute_documentAttributeImageSize *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeImageSize w:%@ h:%@)", self.w, self.h];
}

@end

@implementation Secret23_DocumentAttribute_documentAttributeAnimated

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x11b58939 serializeBlock:^bool (__unused Secret23_DocumentAttribute_documentAttributeAnimated *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeAnimated)"];
}

@end

@implementation Secret23_DocumentAttribute_documentAttributeSticker

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xfb0a5727 serializeBlock:^bool (__unused Secret23_DocumentAttribute_documentAttributeSticker *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeSticker)"];
}

@end

@implementation Secret23_DocumentAttribute_documentAttributeVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x5910cccb serializeBlock:^bool (Secret23_DocumentAttribute_documentAttributeVideo *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeVideo duration:%@ w:%@ h:%@)", self.duration, self.w, self.h];
}

@end

@implementation Secret23_DocumentAttribute_documentAttributeAudio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x51448e5 serializeBlock:^bool (Secret23_DocumentAttribute_documentAttributeAudio *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeAudio duration:%@)", self.duration];
}

@end

@implementation Secret23_DocumentAttribute_documentAttributeFilename

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x15590068 serializeBlock:^bool (Secret23_DocumentAttribute_documentAttributeFilename *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.file_name data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeFilename file_name:%@)", self.file_name];
}

@end




@interface Secret23_DecryptedMessageMedia ()

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty ()

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumb_w;
@property (nonatomic, strong) NSNumber * thumb_h;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint ()

@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * plong;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaContact ()

@property (nonatomic, strong) NSString * phone_number;
@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSNumber * user_id;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumb_w;
@property (nonatomic, strong) NSNumber * thumb_h;
@property (nonatomic, strong) NSString * file_name;
@property (nonatomic, strong) NSString * mime_type;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumb_w;
@property (nonatomic, strong) NSNumber * thumb_h;
@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSString * mime_type;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio ()

@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSString * mime_type;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSString * mime_type;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) Secret23_PhotoSize * thumb;
@property (nonatomic, strong) NSNumber * dc_id;
@property (nonatomic, strong) NSArray * attributes;

@end

@implementation Secret23_DecryptedMessageMedia

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty alloc] init];
    return _object;
}

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto alloc] init];
    _object.thumb = [Secret23__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.thumb_w = [Secret23__Serializer addSerializerToObject:[thumb_w copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.thumb_h = [Secret23__Serializer addSerializerToObject:[thumb_h copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.w = [Secret23__Serializer addSerializerToObject:[w copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret23__Serializer addSerializerToObject:[h copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret23__Serializer addSerializerToObject:[size copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret23__Serializer addSerializerToObject:[key copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret23__Serializer addSerializerToObject:[iv copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint alloc] init];
    _object.lat = [Secret23__Serializer addSerializerToObject:[lat copy] serializer:[[Secret23_BuiltinSerializer_Double alloc] init]];
    _object.plong = [Secret23__Serializer addSerializerToObject:[plong copy] serializer:[[Secret23_BuiltinSerializer_Double alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(NSNumber *)user_id
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaContact *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaContact alloc] init];
    _object.phone_number = [Secret23__Serializer addSerializerToObject:[phone_number copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.first_name = [Secret23__Serializer addSerializerToObject:[first_name copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.last_name = [Secret23__Serializer addSerializerToObject:[last_name copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.user_id = [Secret23__Serializer addSerializerToObject:[user_id copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument alloc] init];
    _object.thumb = [Secret23__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.thumb_w = [Secret23__Serializer addSerializerToObject:[thumb_w copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.thumb_h = [Secret23__Serializer addSerializerToObject:[thumb_h copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.file_name = [Secret23__Serializer addSerializerToObject:[file_name copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.mime_type = [Secret23__Serializer addSerializerToObject:[mime_type copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret23__Serializer addSerializerToObject:[size copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret23__Serializer addSerializerToObject:[key copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret23__Serializer addSerializerToObject:[iv copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h duration:(NSNumber *)duration mime_type:(NSString *)mime_type w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo alloc] init];
    _object.thumb = [Secret23__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.thumb_w = [Secret23__Serializer addSerializerToObject:[thumb_w copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.thumb_h = [Secret23__Serializer addSerializerToObject:[thumb_h copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.duration = [Secret23__Serializer addSerializerToObject:[duration copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.mime_type = [Secret23__Serializer addSerializerToObject:[mime_type copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.w = [Secret23__Serializer addSerializerToObject:[w copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret23__Serializer addSerializerToObject:[h copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret23__Serializer addSerializerToObject:[size copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret23__Serializer addSerializerToObject:[key copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret23__Serializer addSerializerToObject:[iv copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio alloc] init];
    _object.duration = [Secret23__Serializer addSerializerToObject:[duration copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.mime_type = [Secret23__Serializer addSerializerToObject:[mime_type copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret23__Serializer addSerializerToObject:[size copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret23__Serializer addSerializerToObject:[key copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret23__Serializer addSerializerToObject:[iv copy] serializer:[[Secret23_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)decryptedMessageMediaExternalDocumentWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash date:(NSNumber *)date mime_type:(NSString *)mime_type size:(NSNumber *)size thumb:(Secret23_PhotoSize *)thumb dc_id:(NSNumber *)dc_id attributes:(NSArray *)attributes
{
    Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *_object = [[Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument alloc] init];
    _object.pid = [Secret23__Serializer addSerializerToObject:[pid copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [Secret23__Serializer addSerializerToObject:[access_hash copy] serializer:[[Secret23_BuiltinSerializer_Long alloc] init]];
    _object.date = [Secret23__Serializer addSerializerToObject:[date copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.mime_type = [Secret23__Serializer addSerializerToObject:[mime_type copy] serializer:[[Secret23_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret23__Serializer addSerializerToObject:[size copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.thumb = thumb;
    _object.dc_id = [Secret23__Serializer addSerializerToObject:[dc_id copy] serializer:[[Secret23_BuiltinSerializer_Int alloc] init]];
    _object.attributes = 
({
NSMutableArray *attributes_copy = [[NSMutableArray alloc] initWithCapacity:attributes.count];
for (id attributes_item in attributes)
{
    [attributes_copy addObject:attributes_item];
}
id attributes_result = [Secret23__Serializer addSerializerToObject:attributes_copy serializer:[[Secret23__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret23__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]]; attributes_result;});
    return _object;
}


@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x89f5c4a serializeBlock:^bool (__unused Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaEmpty)"];
}

@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x32798a8c serializeBlock:^bool (Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.thumb_w data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.thumb_h data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaPhoto thumb:%@ thumb_w:%@ thumb_h:%@ w:%@ h:%@ size:%@ key:%@ iv:%@)", self.thumb, self.thumb_w, self.thumb_h, self.w, self.h, self.size, self.key, self.iv];
}

@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x35480a59 serializeBlock:^bool (Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.lat data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.plong data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaGeoPoint lat:%@ long:%@)", self.lat, self.plong];
}

@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x588a0a97 serializeBlock:^bool (Secret23_DecryptedMessageMedia_decryptedMessageMediaContact *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.phone_number data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.first_name data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.last_name data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaContact phone_number:%@ first_name:%@ last_name:%@ user_id:%@)", self.phone_number, self.first_name, self.last_name, self.user_id];
}

@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xb095434b serializeBlock:^bool (Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.thumb_w data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.thumb_h data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.file_name data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaDocument thumb:%@ thumb_w:%@ thumb_h:%@ file_name:%@ mime_type:%@ size:%@ key:%@ iv:%@)", self.thumb, self.thumb_w, self.thumb_h, self.file_name, self.mime_type, self.size, self.key, self.iv];
}

@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x524a415d serializeBlock:^bool (Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.thumb_w data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.thumb_h data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaVideo thumb:%@ thumb_w:%@ thumb_h:%@ duration:%@ mime_type:%@ w:%@ h:%@ size:%@ key:%@ iv:%@)", self.thumb, self.thumb_w, self.thumb_h, self.duration, self.mime_type, self.w, self.h, self.size, self.key, self.iv];
}

@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0x57e0a9cb serializeBlock:^bool (Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaAudio duration:%@ mime_type:%@ size:%@ key:%@ iv:%@)", self.duration, self.mime_type, self.size, self.key, self.iv];
}

@end

@implementation Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret23__Serializer addSerializerToObject:self withConstructorSignature:0xfa95b0dd serializeBlock:^bool (Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *object, NSMutableData *data)
        {
            if (![Secret23__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.thumb data:data addSignature:true])
                return false;
            if (![Secret23__Environment serializeObject:object.dc_id data:data addSignature:false])
                return false;
            if (![Secret23__Environment serializeObject:object.attributes data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaExternalDocument id:%@ access_hash:%@ date:%@ mime_type:%@ size:%@ thumb:%@ dc_id:%@ attributes:%@)", self.pid, self.access_hash, self.date, self.mime_type, self.size, self.thumb, self.dc_id, self.attributes];
}

@end




