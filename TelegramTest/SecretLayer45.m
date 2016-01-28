#import "SecretLayer45.h"
#import <objc/runtime.h>

static const char *Secret45__Serializer_Key = "Secret45__Serializer";

@interface Secret45__Number : NSNumber
{
    NSNumber *_value;
}

@end

@implementation Secret45__Number

- (instancetype)initWithNumber:(NSNumber *)number
{
    self = [super init];
    if (self != nil)
    {
        _value = number;
    }
    return self;
}

- (char)charValue
{
    return [_value charValue];
}

- (unsigned char)unsignedCharValue
{
    return [_value unsignedCharValue];
}

- (short)shortValue
{
    return [_value shortValue];
}

- (unsigned short)unsignedShortValue
{
    return [_value unsignedShortValue];
}

- (int)intValue
{
    return [_value intValue];
}

- (unsigned int)unsignedIntValue
{
    return [_value unsignedIntValue];
}

- (long)longValue
{
    return [_value longValue];
}

- (unsigned long)unsignedLongValue
{
    return [_value unsignedLongValue];
}

- (long long)longLongValue
{
    return [_value longLongValue];
}

- (unsigned long long)unsignedLongLongValue
{
    return [_value unsignedLongLongValue];
}

- (float)floatValue
{
    return [_value floatValue];
}

- (double)doubleValue
{
    return [_value doubleValue];
}

- (BOOL)boolValue
{
    return [_value boolValue];
}

- (NSInteger)integerValue
{
    return [_value integerValue];
}

- (NSUInteger)unsignedIntegerValue
{
    return [_value unsignedIntegerValue];
}

- (NSString *)stringValue
{
    return [_value stringValue];
}

- (NSComparisonResult)compare:(NSNumber *)otherNumber
{
    return [_value compare:otherNumber];
}

- (BOOL)isEqualToNumber:(NSNumber *)number
{
    return [_value isEqualToNumber:number];
}

- (NSString *)descriptionWithLocale:(id)locale
{
    return [_value descriptionWithLocale:locale];
}

- (void)getValue:(void *)value
{
    [_value getValue:value];
}

- (const char *)objCType
{
    return [_value objCType];
}

- (NSUInteger)hash
{
    return [_value hash];
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return self;
}

@end

@interface Secret45__Serializer : NSObject

@property (nonatomic) int32_t constructorSignature;
@property (nonatomic, copy) bool (^serializeBlock)(id object, NSMutableData *);

@end

@implementation Secret45__Serializer

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
        objc_setAssociatedObject(object, Secret45__Serializer_Key, [[Secret45__Serializer alloc] initWithConstructorSignature:constructorSignature serializeBlock:serializeBlock], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

+ (id)addSerializerToObject:(id)object serializer:(Secret45__Serializer *)serializer
{
    if (object != nil)
        objc_setAssociatedObject(object, Secret45__Serializer_Key, serializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return object;
}

@end

@interface Secret45__UnboxedTypeMetaInfo : NSObject

@property (nonatomic, readonly) int32_t constructorSignature;

@end

@implementation Secret45__UnboxedTypeMetaInfo

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

@interface Secret45__PreferNSDataTypeMetaInfo : NSObject

@end

@implementation Secret45__PreferNSDataTypeMetaInfo

+ (instancetype)preferNSDataTypeMetaInfo
{
    static Secret45__PreferNSDataTypeMetaInfo *instance = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        instance = [[Secret45__PreferNSDataTypeMetaInfo alloc] init];
    });
    return instance;
}

@end

@interface Secret45__BoxedTypeMetaInfo : NSObject

@end

@implementation Secret45__BoxedTypeMetaInfo

+ (instancetype)boxedTypeMetaInfo
{
    static Secret45__BoxedTypeMetaInfo *instance = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^
    {
        instance = [[Secret45__BoxedTypeMetaInfo alloc] init];
    });
    return instance;
}

@end

@implementation Secret45__Environment

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
            if (*offset + 1 > data.length)
                return nil;
            uint8_t tmp = 0;
            [data getBytes:(void *)&tmp range:NSMakeRange(*offset, 1)];
            *offset += 1;

            int paddingBytes = 0;

            int32_t length = tmp;
            if (length == 254)
            {
                length = 0;
                if (*offset + 3 > data.length)
                    return nil;
                [data getBytes:((uint8_t *)&length) + 1 range:NSMakeRange(*offset, 3)];
                *offset += 3;
                length >>= 8;

                paddingBytes = (((length % 4) == 0 ? length : (length + 4 - (length % 4)))) - length;
            }
            else
                paddingBytes = ((((length + 1) % 4) == 0 ? (length + 1) : ((length + 1) + 4 - ((length + 1) % 4)))) - (length + 1);

            bool isData = [metaInfo isKindOfClass:[Secret45__PreferNSDataTypeMetaInfo class]];
            id object = nil;

            if (length > 0)
            {
                if (*offset + length > data.length)
                    return nil;
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
            if ([metaInfo isKindOfClass:[Secret45__BoxedTypeMetaInfo class]])
                isBoxed = true;
            else if ([metaInfo isKindOfClass:[Secret45__UnboxedTypeMetaInfo class]])
                unboxedConstructorSignature = ((Secret45__UnboxedTypeMetaInfo *)metaInfo).constructorSignature;
            else
                return nil;

            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)count];
            for (int32_t i = 0; i < count; i++)
            {
                int32_t itemConstructorSignature = 0;
                if (isBoxed)
                {
                    if (*offset + 4 > data.length)
                        return nil;
                    [data getBytes:(void *)&itemConstructorSignature range:NSMakeRange(*offset, 4)];
                    *offset += 4;
                }
                else
                    itemConstructorSignature = unboxedConstructorSignature;
                id item = [Secret45__Environment parseObject:data offset:offset implicitSignature:itemConstructorSignature metaInfo:nil];
                if (item == nil)
                    return nil;

                [array addObject:item];
            }

            return array;
        } copy];

        parsers[@((int32_t)0xa1733aec)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * ttl_seconds = nil;
            if ((ttl_seconds = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtl_seconds:ttl_seconds];
        } copy];
        parsers[@((int32_t)0xc4f40be)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * random_ids = nil;
            int32_t random_ids_signature = 0; [data getBytes:(void *)&random_ids_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((random_ids = [Secret45__Environment parseObject:data offset:_offset implicitSignature:random_ids_signature metaInfo:[[Secret45__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionReadMessagesWithRandom_ids:random_ids];
        } copy];
        parsers[@((int32_t)0x65614304)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * random_ids = nil;
            int32_t random_ids_signature = 0; [data getBytes:(void *)&random_ids_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((random_ids = [Secret45__Environment parseObject:data offset:_offset implicitSignature:random_ids_signature metaInfo:[[Secret45__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandom_ids:random_ids];
        } copy];
        parsers[@((int32_t)0x8ac1f475)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * random_ids = nil;
            int32_t random_ids_signature = 0; [data getBytes:(void *)&random_ids_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((random_ids = [Secret45__Environment parseObject:data offset:_offset implicitSignature:random_ids_signature metaInfo:[[Secret45__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionScreenshotMessagesWithRandom_ids:random_ids];
        } copy];
        parsers[@((int32_t)0x6719e45c)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret45_DecryptedMessageAction decryptedMessageActionFlushHistory];
        } copy];
        parsers[@((int32_t)0xf3048883)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * layer = nil;
            if ((layer = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:layer];
        } copy];
        parsers[@((int32_t)0xccb27641)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            Secret45_SendMessageAction * action = nil;
            int32_t action_signature = 0; [data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [Secret45__Environment parseObject:data offset:_offset implicitSignature:action_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionTypingWithAction:action];
        } copy];
        parsers[@((int32_t)0x511110b0)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * start_seq_no = nil;
            if ((start_seq_no = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * end_seq_no = nil;
            if ((end_seq_no = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionResendWithStart_seq_no:start_seq_no end_seq_no:end_seq_no];
        } copy];
        parsers[@((int32_t)0xf3c9611b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchange_id = nil;
            if ((exchange_id = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * g_a = nil;
            if ((g_a = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionRequestKeyWithExchange_id:exchange_id g_a:g_a];
        } copy];
        parsers[@((int32_t)0x6fe1735b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchange_id = nil;
            if ((exchange_id = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * g_b = nil;
            if ((g_b = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * key_fingerprint = nil;
            if ((key_fingerprint = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionAcceptKeyWithExchange_id:exchange_id g_b:g_b key_fingerprint:key_fingerprint];
        } copy];
        parsers[@((int32_t)0xec2e0b9b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchange_id = nil;
            if ((exchange_id = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * key_fingerprint = nil;
            if ((key_fingerprint = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionCommitKeyWithExchange_id:exchange_id key_fingerprint:key_fingerprint];
        } copy];
        parsers[@((int32_t)0xdd05ec6b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchange_id = nil;
            if ((exchange_id = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionAbortKeyWithExchange_id:exchange_id];
        } copy];
        parsers[@((int32_t)0xa82fdd63)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret45_DecryptedMessageAction decryptedMessageActionNoop];
        } copy];
        parsers[@((int32_t)0x16bf744e)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret45_SendMessageAction sendMessageTypingAction];
        } copy];
        parsers[@((int32_t)0xfd5ec8f5)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret45_SendMessageAction sendMessageCancelAction];
        } copy];
        parsers[@((int32_t)0xa187d66f)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret45_SendMessageAction sendMessageRecordVideoAction];
        } copy];
        parsers[@((int32_t)0x92042ff7)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret45_SendMessageAction sendMessageUploadVideoAction];
        } copy];
        parsers[@((int32_t)0xd52f73f7)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret45_SendMessageAction sendMessageRecordAudioAction];
        } copy];
        parsers[@((int32_t)0xe6ac8a6f)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret45_SendMessageAction sendMessageUploadAudioAction];
        } copy];
        parsers[@((int32_t)0x990a3c1a)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret45_SendMessageAction sendMessageUploadPhotoAction];
        } copy];
        parsers[@((int32_t)0x8faee98e)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret45_SendMessageAction sendMessageUploadDocumentAction];
        } copy];
        parsers[@((int32_t)0x176f8ba1)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret45_SendMessageAction sendMessageGeoLocationAction];
        } copy];
        parsers[@((int32_t)0x628cbc6f)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret45_SendMessageAction sendMessageChooseContactAction];
        } copy];
        parsers[@((int32_t)0xe17e23c)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * type = nil;
            if ((type = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret45_PhotoSize photoSizeEmptyWithType:type];
        } copy];
        parsers[@((int32_t)0x77bfb61b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * type = nil;
            if ((type = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret45_FileLocation * location = nil;
            int32_t location_signature = 0; [data getBytes:(void *)&location_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((location = [Secret45__Environment parseObject:data offset:_offset implicitSignature:location_signature metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_PhotoSize photoSizeWithType:type location:location w:w h:h size:size];
        } copy];
        parsers[@((int32_t)0xe9a734fa)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * type = nil;
            if ((type = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret45_FileLocation * location = nil;
            int32_t location_signature = 0; [data getBytes:(void *)&location_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((location = [Secret45__Environment parseObject:data offset:_offset implicitSignature:location_signature metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * bytes = nil;
            if ((bytes = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret45_PhotoSize photoCachedSizeWithType:type location:location w:w h:h bytes:bytes];
        } copy];
        parsers[@((int32_t)0x7c596b46)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * volume_id = nil;
            if ((volume_id = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * local_id = nil;
            if ((local_id = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * secret = nil;
            if ((secret = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret45_FileLocation fileLocationUnavailableWithVolume_id:volume_id local_id:local_id secret:secret];
        } copy];
        parsers[@((int32_t)0x53d69076)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * dc_id = nil;
            if ((dc_id = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * volume_id = nil;
            if ((volume_id = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * local_id = nil;
            if ((local_id = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * secret = nil;
            if ((secret = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret45_FileLocation fileLocationWithDc_id:dc_id volume_id:volume_id local_id:local_id secret:secret];
        } copy];
        parsers[@((int32_t)0x1be31789)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * random_bytes = nil;
            if ((random_bytes = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * layer = nil;
            if ((layer = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * in_seq_no = nil;
            if ((in_seq_no = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * out_seq_no = nil;
            if ((out_seq_no = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            Secret45_DecryptedMessage * message = nil;
            int32_t message_signature = 0; [data getBytes:(void *)&message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((message = [Secret45__Environment parseObject:data offset:_offset implicitSignature:message_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:random_bytes layer:layer in_seq_no:in_seq_no out_seq_no:out_seq_no message:message];
        } copy];
        parsers[@((int32_t)0x73164160)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * random_id = nil;
            if ((random_id = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            Secret45_DecryptedMessageAction * action = nil;
            int32_t action_signature = 0; [data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [Secret45__Environment parseObject:data offset:_offset implicitSignature:action_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessage decryptedMessageServiceWithRandom_id:random_id action:action];
        } copy];
        parsers[@((int32_t)0x36b091de)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * flags = nil;
            if ((flags = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * random_id = nil;
            if ((random_id = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * ttl = nil;
            if ((ttl = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * message = nil;
            if ((message = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret45_DecryptedMessageMedia * media = nil;
            if (flags != nil && ([flags intValue] & (1 << 9))) {
            int32_t media_signature = 0; [data getBytes:(void *)&media_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((media = [Secret45__Environment parseObject:data offset:_offset implicitSignature:media_signature metaInfo:nil]) == nil)
               return nil;
            }
            NSArray * entities = nil;
            if (flags != nil && ([flags intValue] & (1 << 7))) {
            int32_t entities_signature = 0; [data getBytes:(void *)&entities_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((entities = [Secret45__Environment parseObject:data offset:_offset implicitSignature:entities_signature metaInfo:[Secret45__BoxedTypeMetaInfo boxedTypeMetaInfo]]) == nil)
               return nil;
            }
            NSString * via_bot_name = nil;
            if (flags != nil && ([flags intValue] & (1 << 11))) {
            if ((via_bot_name = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            }
            NSNumber * reply_to_random_id = nil;
            if (flags != nil && ([flags intValue] & (1 << 3))) {
            if ((reply_to_random_id = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            }
            return [Secret45_DecryptedMessage decryptedMessageWithFlags:flags random_id:random_id ttl:ttl message:message media:media entities:entities via_bot_name:via_bot_name reply_to_random_id:reply_to_random_id];
        } copy];
        parsers[@((int32_t)0x6c37c15c)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * w = nil;
            if ((w = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DocumentAttribute documentAttributeImageSizeWithW:w h:h];
        } copy];
        parsers[@((int32_t)0x11b58939)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret45_DocumentAttribute documentAttributeAnimated];
        } copy];
        parsers[@((int32_t)0x5910cccb)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * duration = nil;
            if ((duration = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DocumentAttribute documentAttributeVideoWithDuration:duration w:w h:h];
        } copy];
        parsers[@((int32_t)0x15590068)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * file_name = nil;
            if ((file_name = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DocumentAttribute documentAttributeFilenameWithFile_name:file_name];
        } copy];
        parsers[@((int32_t)0x3a556302)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * alt = nil;
            if ((alt = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            Secret45_InputStickerSet * stickerset = nil;
            int32_t stickerset_signature = 0; [data getBytes:(void *)&stickerset_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((stickerset = [Secret45__Environment parseObject:data offset:_offset implicitSignature:stickerset_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DocumentAttribute documentAttributeStickerWithAlt:alt stickerset:stickerset];
        } copy];
        parsers[@((int32_t)0xded218e0)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * duration = nil;
            if ((duration = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * title = nil;
            if ((title = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * performer = nil;
            if ((performer = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DocumentAttribute documentAttributeAudioWithDuration:duration title:title performer:performer];
        } copy];
        parsers[@((int32_t)0x861cc8a0)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * short_name = nil;
            if ((short_name = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret45_InputStickerSet inputStickerSetShortNameWithShort_name:short_name];
        } copy];
        parsers[@((int32_t)0xffb62b95)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret45_InputStickerSet inputStickerSetEmpty];
        } copy];
        parsers[@((int32_t)0xbb92ba95)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_MessageEntity messageEntityUnknownWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0xfa04579d)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_MessageEntity messageEntityMentionWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0x6f635b0d)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_MessageEntity messageEntityHashtagWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0x6cef8ac7)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_MessageEntity messageEntityBotCommandWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0x6ed02538)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_MessageEntity messageEntityUrlWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0x64e475c2)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_MessageEntity messageEntityEmailWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0xbd610bc9)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_MessageEntity messageEntityBoldWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0x826f8b60)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_MessageEntity messageEntityItalicWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0x28a20571)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_MessageEntity messageEntityCodeWithOffset:offset length:length];
        } copy];
        parsers[@((int32_t)0x73924be0)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * language = nil;
            if ((language = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret45_MessageEntity messageEntityPreWithOffset:offset length:length language:language];
        } copy];
        parsers[@((int32_t)0x76a6d327)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * offset = nil;
            if ((offset = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * length = nil;
            if ((length = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * url = nil;
            if ((url = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret45_MessageEntity messageEntityTextUrlWithOffset:offset length:length url:url];
        } copy];
        parsers[@((int32_t)0x89f5c4a)] = [^id (__unused NSData *data, __unused NSUInteger* _offset, __unused id metaInfo)
        {
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaEmpty];
        } copy];
        parsers[@((int32_t)0x35480a59)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * lat = nil;
            if ((lat = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            NSNumber * plong = nil;
            if ((plong = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaGeoPointWithLat:lat plong:plong];
        } copy];
        parsers[@((int32_t)0x588a0a97)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * phone_number = nil;
            if ((phone_number = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * first_name = nil;
            if ((first_name = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * last_name = nil;
            if ((last_name = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * user_id = nil;
            if ((user_id = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaContactWithPhone_number:phone_number first_name:first_name last_name:last_name user_id:user_id];
        } copy];
        parsers[@((int32_t)0x57e0a9cb)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * duration = nil;
            if ((duration = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:duration mime_type:mime_type size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0xfa95b0dd)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * pid = nil;
            if ((pid = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * access_hash = nil;
            if ((access_hash = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            Secret45_PhotoSize * thumb = nil;
            int32_t thumb_signature = 0; [data getBytes:(void *)&thumb_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((thumb = [Secret45__Environment parseObject:data offset:_offset implicitSignature:thumb_signature metaInfo:nil]) == nil)
               return nil;
            NSNumber * dc_id = nil;
            if ((dc_id = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSArray * attributes = nil;
            int32_t attributes_signature = 0; [data getBytes:(void *)&attributes_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((attributes = [Secret45__Environment parseObject:data offset:_offset implicitSignature:attributes_signature metaInfo:[Secret45__BoxedTypeMetaInfo boxedTypeMetaInfo]]) == nil)
               return nil;
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaExternalDocumentWithPid:pid access_hash:access_hash date:date mime_type:mime_type size:size thumb:thumb dc_id:dc_id attributes:attributes];
        } copy];
        parsers[@((int32_t)0xf1fa8d78)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumb_w = nil;
            if ((thumb_w = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumb_h = nil;
            if ((thumb_h = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSString * caption = nil;
            if ((caption = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumb thumb_w:thumb_w thumb_h:thumb_h w:w h:h size:size key:key iv:iv caption:caption];
        } copy];
        parsers[@((int32_t)0x7afe8ae2)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumb_w = nil;
            if ((thumb_w = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumb_h = nil;
            if ((thumb_h = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSArray * attributes = nil;
            int32_t attributes_signature = 0; [data getBytes:(void *)&attributes_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((attributes = [Secret45__Environment parseObject:data offset:_offset implicitSignature:attributes_signature metaInfo:[Secret45__BoxedTypeMetaInfo boxedTypeMetaInfo]]) == nil)
               return nil;
            NSString * caption = nil;
            if ((caption = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumb thumb_w:thumb_w thumb_h:thumb_h mime_type:mime_type size:size key:key iv:iv attributes:attributes caption:caption];
        } copy];
        parsers[@((int32_t)0x970c8c0e)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumb_w = nil;
            if ((thumb_w = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumb_h = nil;
            if ((thumb_h = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mime_type = nil;
            if ((mime_type = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * w = nil;
            if ((w = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * h = nil;
            if ((h = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSData * key = nil;
            if ((key = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSData * iv = nil;
            if ((iv = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSString * caption = nil;
            if ((caption = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb:thumb thumb_w:thumb_w thumb_h:thumb_h duration:duration mime_type:mime_type w:w h:h size:size key:key iv:iv caption:caption];
        } copy];
        parsers[@((int32_t)0x8a0df56f)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * lat = nil;
            if ((lat = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            NSNumber * plong = nil;
            if ((plong = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x2210c154 metaInfo:nil]) == nil)
               return nil;
            NSString * title = nil;
            if ((title = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * address = nil;
            if ((address = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * provider = nil;
            if ((provider = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * venue_id = nil;
            if ((venue_id = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaVenueWithLat:lat plong:plong title:title address:address provider:provider venue_id:venue_id];
        } copy];
        parsers[@((int32_t)0x82684ff4)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSString * url = nil;
            if ((url = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaWebpageWithUrl:url];
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
     Secret45__Serializer *serializer = objc_getAssociatedObject(object, Secret45__Serializer_Key);
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

@interface Secret45_BuiltinSerializer_Int : Secret45__Serializer
@end

@implementation Secret45_BuiltinSerializer_Int

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

@interface Secret45_BuiltinSerializer_Long : Secret45__Serializer
@end

@implementation Secret45_BuiltinSerializer_Long

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

@interface Secret45_BuiltinSerializer_Double : Secret45__Serializer
@end

@implementation Secret45_BuiltinSerializer_Double

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

@interface Secret45_BuiltinSerializer_String : Secret45__Serializer
@end

@implementation Secret45_BuiltinSerializer_String

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

@interface Secret45_BuiltinSerializer_Bytes : Secret45__Serializer
@end

@implementation Secret45_BuiltinSerializer_Bytes

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

@interface Secret45_BuiltinSerializer_Int128 : Secret45__Serializer
@end

@implementation Secret45_BuiltinSerializer_Int128

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

@interface Secret45_BuiltinSerializer_Int256 : Secret45__Serializer
@end

@implementation Secret45_BuiltinSerializer_Int256

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



@implementation Secret45_FunctionContext

- (instancetype)initWithPayload:(NSData *)payload responseParser:(id (^)(NSData *))responseParser metadata:(id)metadata
{
    self = [super init];
    if (self != nil)
    {
        _payload = payload;
        _responseParser = [responseParser copy];
        _metadata = metadata;
    }
    return self;
}

@end

@interface Secret45_DecryptedMessageAction ()

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionSetMessageTTL ()

@property (nonatomic, strong) NSNumber * ttl_seconds;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionReadMessages ()

@property (nonatomic, strong) NSArray * random_ids;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionDeleteMessages ()

@property (nonatomic, strong) NSArray * random_ids;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionScreenshotMessages ()

@property (nonatomic, strong) NSArray * random_ids;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionFlushHistory ()

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionNotifyLayer ()

@property (nonatomic, strong) NSNumber * layer;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionTyping ()

@property (nonatomic, strong) Secret45_SendMessageAction * action;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionResend ()

@property (nonatomic, strong) NSNumber * start_seq_no;
@property (nonatomic, strong) NSNumber * end_seq_no;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionRequestKey ()

@property (nonatomic, strong) NSNumber * exchange_id;
@property (nonatomic, strong) NSData * g_a;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionAcceptKey ()

@property (nonatomic, strong) NSNumber * exchange_id;
@property (nonatomic, strong) NSData * g_b;
@property (nonatomic, strong) NSNumber * key_fingerprint;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionCommitKey ()

@property (nonatomic, strong) NSNumber * exchange_id;
@property (nonatomic, strong) NSNumber * key_fingerprint;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionAbortKey ()

@property (nonatomic, strong) NSNumber * exchange_id;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionNoop ()

@end

@implementation Secret45_DecryptedMessageAction

+ (Secret45_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtl_seconds:(NSNumber *)ttl_seconds
{
    Secret45_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionSetMessageTTL alloc] init];
    _object.ttl_seconds = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:ttl_seconds] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandom_ids:(NSArray *)random_ids
{
    Secret45_DecryptedMessageAction_decryptedMessageActionReadMessages *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionReadMessages alloc] init];
    _object.random_ids = 
({
NSMutableArray *random_ids_copy = [[NSMutableArray alloc] initWithCapacity:random_ids.count];
for (id random_ids_item in random_ids)
{
    [random_ids_copy addObject:[Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:random_ids_item] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]]];
}
id random_ids_result = [Secret45__Serializer addSerializerToObject:random_ids_copy serializer:[[Secret45__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret45__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; random_ids_result;});
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandom_ids:(NSArray *)random_ids
{
    Secret45_DecryptedMessageAction_decryptedMessageActionDeleteMessages *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionDeleteMessages alloc] init];
    _object.random_ids = 
({
NSMutableArray *random_ids_copy = [[NSMutableArray alloc] initWithCapacity:random_ids.count];
for (id random_ids_item in random_ids)
{
    [random_ids_copy addObject:[Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:random_ids_item] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]]];
}
id random_ids_result = [Secret45__Serializer addSerializerToObject:random_ids_copy serializer:[[Secret45__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret45__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; random_ids_result;});
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandom_ids:(NSArray *)random_ids
{
    Secret45_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionScreenshotMessages alloc] init];
    _object.random_ids = 
({
NSMutableArray *random_ids_copy = [[NSMutableArray alloc] initWithCapacity:random_ids.count];
for (id random_ids_item in random_ids)
{
    [random_ids_copy addObject:[Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:random_ids_item] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]]];
}
id random_ids_result = [Secret45__Serializer addSerializerToObject:random_ids_copy serializer:[[Secret45__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret45__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; random_ids_result;});
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory
{
    Secret45_DecryptedMessageAction_decryptedMessageActionFlushHistory *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionFlushHistory alloc] init];
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer
{
    Secret45_DecryptedMessageAction_decryptedMessageActionNotifyLayer *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionNotifyLayer alloc] init];
    _object.layer = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:layer] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionTyping *)decryptedMessageActionTypingWithAction:(Secret45_SendMessageAction *)action
{
    Secret45_DecryptedMessageAction_decryptedMessageActionTyping *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionTyping alloc] init];
    _object.action = action;
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionResend *)decryptedMessageActionResendWithStart_seq_no:(NSNumber *)start_seq_no end_seq_no:(NSNumber *)end_seq_no
{
    Secret45_DecryptedMessageAction_decryptedMessageActionResend *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionResend alloc] init];
    _object.start_seq_no = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:start_seq_no] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.end_seq_no = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:end_seq_no] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionRequestKey *)decryptedMessageActionRequestKeyWithExchange_id:(NSNumber *)exchange_id g_a:(NSData *)g_a
{
    Secret45_DecryptedMessageAction_decryptedMessageActionRequestKey *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionRequestKey alloc] init];
    _object.exchange_id = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:exchange_id] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.g_a = [Secret45__Serializer addSerializerToObject:[g_a copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionAcceptKey *)decryptedMessageActionAcceptKeyWithExchange_id:(NSNumber *)exchange_id g_b:(NSData *)g_b key_fingerprint:(NSNumber *)key_fingerprint
{
    Secret45_DecryptedMessageAction_decryptedMessageActionAcceptKey *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionAcceptKey alloc] init];
    _object.exchange_id = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:exchange_id] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.g_b = [Secret45__Serializer addSerializerToObject:[g_b copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.key_fingerprint = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:key_fingerprint] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionCommitKey *)decryptedMessageActionCommitKeyWithExchange_id:(NSNumber *)exchange_id key_fingerprint:(NSNumber *)key_fingerprint
{
    Secret45_DecryptedMessageAction_decryptedMessageActionCommitKey *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionCommitKey alloc] init];
    _object.exchange_id = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:exchange_id] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.key_fingerprint = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:key_fingerprint] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionAbortKey *)decryptedMessageActionAbortKeyWithExchange_id:(NSNumber *)exchange_id
{
    Secret45_DecryptedMessageAction_decryptedMessageActionAbortKey *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionAbortKey alloc] init];
    _object.exchange_id = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:exchange_id] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionNoop *)decryptedMessageActionNoop
{
    Secret45_DecryptedMessageAction_decryptedMessageActionNoop *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionNoop alloc] init];
    return _object;
}


@end

@implementation Secret45_DecryptedMessageAction_decryptedMessageActionSetMessageTTL

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xa1733aec serializeBlock:^bool (Secret45_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.ttl_seconds data:data addSignature:false])
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

@implementation Secret45_DecryptedMessageAction_decryptedMessageActionReadMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xc4f40be serializeBlock:^bool (Secret45_DecryptedMessageAction_decryptedMessageActionReadMessages *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.random_ids data:data addSignature:true])
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

@implementation Secret45_DecryptedMessageAction_decryptedMessageActionDeleteMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x65614304 serializeBlock:^bool (Secret45_DecryptedMessageAction_decryptedMessageActionDeleteMessages *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.random_ids data:data addSignature:true])
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

@implementation Secret45_DecryptedMessageAction_decryptedMessageActionScreenshotMessages

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x8ac1f475 serializeBlock:^bool (Secret45_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.random_ids data:data addSignature:true])
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

@implementation Secret45_DecryptedMessageAction_decryptedMessageActionFlushHistory

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x6719e45c serializeBlock:^bool (__unused Secret45_DecryptedMessageAction_decryptedMessageActionFlushHistory *object, __unused NSMutableData *data)
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

@implementation Secret45_DecryptedMessageAction_decryptedMessageActionNotifyLayer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xf3048883 serializeBlock:^bool (Secret45_DecryptedMessageAction_decryptedMessageActionNotifyLayer *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.layer data:data addSignature:false])
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

@implementation Secret45_DecryptedMessageAction_decryptedMessageActionTyping

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xccb27641 serializeBlock:^bool (Secret45_DecryptedMessageAction_decryptedMessageActionTyping *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.action data:data addSignature:true])
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

@implementation Secret45_DecryptedMessageAction_decryptedMessageActionResend

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x511110b0 serializeBlock:^bool (Secret45_DecryptedMessageAction_decryptedMessageActionResend *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.start_seq_no data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.end_seq_no data:data addSignature:false])
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

@implementation Secret45_DecryptedMessageAction_decryptedMessageActionRequestKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xf3c9611b serializeBlock:^bool (Secret45_DecryptedMessageAction_decryptedMessageActionRequestKey *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.exchange_id data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.g_a data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionRequestKey exchange_id:%@ g_a:%d)", self.exchange_id, (int)[self.g_a length]];
}

@end

@implementation Secret45_DecryptedMessageAction_decryptedMessageActionAcceptKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x6fe1735b serializeBlock:^bool (Secret45_DecryptedMessageAction_decryptedMessageActionAcceptKey *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.exchange_id data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.g_b data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.key_fingerprint data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionAcceptKey exchange_id:%@ g_b:%d key_fingerprint:%@)", self.exchange_id, (int)[self.g_b length], self.key_fingerprint];
}

@end

@implementation Secret45_DecryptedMessageAction_decryptedMessageActionCommitKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xec2e0b9b serializeBlock:^bool (Secret45_DecryptedMessageAction_decryptedMessageActionCommitKey *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.exchange_id data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.key_fingerprint data:data addSignature:false])
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

@implementation Secret45_DecryptedMessageAction_decryptedMessageActionAbortKey

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xdd05ec6b serializeBlock:^bool (Secret45_DecryptedMessageAction_decryptedMessageActionAbortKey *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.exchange_id data:data addSignature:false])
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

@implementation Secret45_DecryptedMessageAction_decryptedMessageActionNoop

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xa82fdd63 serializeBlock:^bool (__unused Secret45_DecryptedMessageAction_decryptedMessageActionNoop *object, __unused NSMutableData *data)
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




@interface Secret45_SendMessageAction ()

@end

@interface Secret45_SendMessageAction_sendMessageTypingAction ()

@end

@interface Secret45_SendMessageAction_sendMessageCancelAction ()

@end

@interface Secret45_SendMessageAction_sendMessageRecordVideoAction ()

@end

@interface Secret45_SendMessageAction_sendMessageUploadVideoAction ()

@end

@interface Secret45_SendMessageAction_sendMessageRecordAudioAction ()

@end

@interface Secret45_SendMessageAction_sendMessageUploadAudioAction ()

@end

@interface Secret45_SendMessageAction_sendMessageUploadPhotoAction ()

@end

@interface Secret45_SendMessageAction_sendMessageUploadDocumentAction ()

@end

@interface Secret45_SendMessageAction_sendMessageGeoLocationAction ()

@end

@interface Secret45_SendMessageAction_sendMessageChooseContactAction ()

@end

@implementation Secret45_SendMessageAction

+ (Secret45_SendMessageAction_sendMessageTypingAction *)sendMessageTypingAction
{
    Secret45_SendMessageAction_sendMessageTypingAction *_object = [[Secret45_SendMessageAction_sendMessageTypingAction alloc] init];
    return _object;
}

+ (Secret45_SendMessageAction_sendMessageCancelAction *)sendMessageCancelAction
{
    Secret45_SendMessageAction_sendMessageCancelAction *_object = [[Secret45_SendMessageAction_sendMessageCancelAction alloc] init];
    return _object;
}

+ (Secret45_SendMessageAction_sendMessageRecordVideoAction *)sendMessageRecordVideoAction
{
    Secret45_SendMessageAction_sendMessageRecordVideoAction *_object = [[Secret45_SendMessageAction_sendMessageRecordVideoAction alloc] init];
    return _object;
}

+ (Secret45_SendMessageAction_sendMessageUploadVideoAction *)sendMessageUploadVideoAction
{
    Secret45_SendMessageAction_sendMessageUploadVideoAction *_object = [[Secret45_SendMessageAction_sendMessageUploadVideoAction alloc] init];
    return _object;
}

+ (Secret45_SendMessageAction_sendMessageRecordAudioAction *)sendMessageRecordAudioAction
{
    Secret45_SendMessageAction_sendMessageRecordAudioAction *_object = [[Secret45_SendMessageAction_sendMessageRecordAudioAction alloc] init];
    return _object;
}

+ (Secret45_SendMessageAction_sendMessageUploadAudioAction *)sendMessageUploadAudioAction
{
    Secret45_SendMessageAction_sendMessageUploadAudioAction *_object = [[Secret45_SendMessageAction_sendMessageUploadAudioAction alloc] init];
    return _object;
}

+ (Secret45_SendMessageAction_sendMessageUploadPhotoAction *)sendMessageUploadPhotoAction
{
    Secret45_SendMessageAction_sendMessageUploadPhotoAction *_object = [[Secret45_SendMessageAction_sendMessageUploadPhotoAction alloc] init];
    return _object;
}

+ (Secret45_SendMessageAction_sendMessageUploadDocumentAction *)sendMessageUploadDocumentAction
{
    Secret45_SendMessageAction_sendMessageUploadDocumentAction *_object = [[Secret45_SendMessageAction_sendMessageUploadDocumentAction alloc] init];
    return _object;
}

+ (Secret45_SendMessageAction_sendMessageGeoLocationAction *)sendMessageGeoLocationAction
{
    Secret45_SendMessageAction_sendMessageGeoLocationAction *_object = [[Secret45_SendMessageAction_sendMessageGeoLocationAction alloc] init];
    return _object;
}

+ (Secret45_SendMessageAction_sendMessageChooseContactAction *)sendMessageChooseContactAction
{
    Secret45_SendMessageAction_sendMessageChooseContactAction *_object = [[Secret45_SendMessageAction_sendMessageChooseContactAction alloc] init];
    return _object;
}


@end

@implementation Secret45_SendMessageAction_sendMessageTypingAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x16bf744e serializeBlock:^bool (__unused Secret45_SendMessageAction_sendMessageTypingAction *object, __unused NSMutableData *data)
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

@implementation Secret45_SendMessageAction_sendMessageCancelAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xfd5ec8f5 serializeBlock:^bool (__unused Secret45_SendMessageAction_sendMessageCancelAction *object, __unused NSMutableData *data)
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

@implementation Secret45_SendMessageAction_sendMessageRecordVideoAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xa187d66f serializeBlock:^bool (__unused Secret45_SendMessageAction_sendMessageRecordVideoAction *object, __unused NSMutableData *data)
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

@implementation Secret45_SendMessageAction_sendMessageUploadVideoAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x92042ff7 serializeBlock:^bool (__unused Secret45_SendMessageAction_sendMessageUploadVideoAction *object, __unused NSMutableData *data)
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

@implementation Secret45_SendMessageAction_sendMessageRecordAudioAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xd52f73f7 serializeBlock:^bool (__unused Secret45_SendMessageAction_sendMessageRecordAudioAction *object, __unused NSMutableData *data)
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

@implementation Secret45_SendMessageAction_sendMessageUploadAudioAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xe6ac8a6f serializeBlock:^bool (__unused Secret45_SendMessageAction_sendMessageUploadAudioAction *object, __unused NSMutableData *data)
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

@implementation Secret45_SendMessageAction_sendMessageUploadPhotoAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x990a3c1a serializeBlock:^bool (__unused Secret45_SendMessageAction_sendMessageUploadPhotoAction *object, __unused NSMutableData *data)
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

@implementation Secret45_SendMessageAction_sendMessageUploadDocumentAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x8faee98e serializeBlock:^bool (__unused Secret45_SendMessageAction_sendMessageUploadDocumentAction *object, __unused NSMutableData *data)
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

@implementation Secret45_SendMessageAction_sendMessageGeoLocationAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x176f8ba1 serializeBlock:^bool (__unused Secret45_SendMessageAction_sendMessageGeoLocationAction *object, __unused NSMutableData *data)
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

@implementation Secret45_SendMessageAction_sendMessageChooseContactAction

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x628cbc6f serializeBlock:^bool (__unused Secret45_SendMessageAction_sendMessageChooseContactAction *object, __unused NSMutableData *data)
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




@interface Secret45_PhotoSize ()

@property (nonatomic, strong) NSString * type;

@end

@interface Secret45_PhotoSize_photoSizeEmpty ()

@end

@interface Secret45_PhotoSize_photoSize ()

@property (nonatomic, strong) Secret45_FileLocation * location;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;

@end

@interface Secret45_PhotoSize_photoCachedSize ()

@property (nonatomic, strong) Secret45_FileLocation * location;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSData * bytes;

@end

@implementation Secret45_PhotoSize

+ (Secret45_PhotoSize_photoSizeEmpty *)photoSizeEmptyWithType:(NSString *)type
{
    Secret45_PhotoSize_photoSizeEmpty *_object = [[Secret45_PhotoSize_photoSizeEmpty alloc] init];
    _object.type = [Secret45__Serializer addSerializerToObject:[type copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret45_PhotoSize_photoSize *)photoSizeWithType:(NSString *)type location:(Secret45_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size
{
    Secret45_PhotoSize_photoSize *_object = [[Secret45_PhotoSize_photoSize alloc] init];
    _object.type = [Secret45__Serializer addSerializerToObject:[type copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.location = location;
    _object.w = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:w] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:h] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:size] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_PhotoSize_photoCachedSize *)photoCachedSizeWithType:(NSString *)type location:(Secret45_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h bytes:(NSData *)bytes
{
    Secret45_PhotoSize_photoCachedSize *_object = [[Secret45_PhotoSize_photoCachedSize alloc] init];
    _object.type = [Secret45__Serializer addSerializerToObject:[type copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.location = location;
    _object.w = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:w] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:h] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.bytes = [Secret45__Serializer addSerializerToObject:[bytes copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}


@end

@implementation Secret45_PhotoSize_photoSizeEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xe17e23c serializeBlock:^bool (Secret45_PhotoSize_photoSizeEmpty *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(photoSizeEmpty type:%d)", (int)[self.type length]];
}

@end

@implementation Secret45_PhotoSize_photoSize

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x77bfb61b serializeBlock:^bool (Secret45_PhotoSize_photoSize *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.location data:data addSignature:true])
                return false;
            if (![Secret45__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(photoSize type:%d location:%@ w:%@ h:%@ size:%@)", (int)[self.type length], self.location, self.w, self.h, self.size];
}

@end

@implementation Secret45_PhotoSize_photoCachedSize

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xe9a734fa serializeBlock:^bool (Secret45_PhotoSize_photoCachedSize *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.type data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.location data:data addSignature:true])
                return false;
            if (![Secret45__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.bytes data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(photoCachedSize type:%d location:%@ w:%@ h:%@ bytes:%d)", (int)[self.type length], self.location, self.w, self.h, (int)[self.bytes length]];
}

@end




@interface Secret45_FileLocation ()

@property (nonatomic, strong) NSNumber * volume_id;
@property (nonatomic, strong) NSNumber * local_id;
@property (nonatomic, strong) NSNumber * secret;

@end

@interface Secret45_FileLocation_fileLocationUnavailable ()

@end

@interface Secret45_FileLocation_fileLocation ()

@property (nonatomic, strong) NSNumber * dc_id;

@end

@implementation Secret45_FileLocation

+ (Secret45_FileLocation_fileLocationUnavailable *)fileLocationUnavailableWithVolume_id:(NSNumber *)volume_id local_id:(NSNumber *)local_id secret:(NSNumber *)secret
{
    Secret45_FileLocation_fileLocationUnavailable *_object = [[Secret45_FileLocation_fileLocationUnavailable alloc] init];
    _object.volume_id = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:volume_id] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.local_id = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:local_id] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.secret = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:secret] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret45_FileLocation_fileLocation *)fileLocationWithDc_id:(NSNumber *)dc_id volume_id:(NSNumber *)volume_id local_id:(NSNumber *)local_id secret:(NSNumber *)secret
{
    Secret45_FileLocation_fileLocation *_object = [[Secret45_FileLocation_fileLocation alloc] init];
    _object.dc_id = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:dc_id] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.volume_id = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:volume_id] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.local_id = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:local_id] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.secret = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:secret] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation Secret45_FileLocation_fileLocationUnavailable

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x7c596b46 serializeBlock:^bool (Secret45_FileLocation_fileLocationUnavailable *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.volume_id data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.local_id data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.secret data:data addSignature:false])
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

@implementation Secret45_FileLocation_fileLocation

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x53d69076 serializeBlock:^bool (Secret45_FileLocation_fileLocation *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.dc_id data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.volume_id data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.local_id data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.secret data:data addSignature:false])
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




@interface Secret45_DecryptedMessageLayer ()

@property (nonatomic, strong) NSData * random_bytes;
@property (nonatomic, strong) NSNumber * layer;
@property (nonatomic, strong) NSNumber * in_seq_no;
@property (nonatomic, strong) NSNumber * out_seq_no;
@property (nonatomic, strong) Secret45_DecryptedMessage * message;

@end

@interface Secret45_DecryptedMessageLayer_decryptedMessageLayer ()

@end

@implementation Secret45_DecryptedMessageLayer

+ (Secret45_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithRandom_bytes:(NSData *)random_bytes layer:(NSNumber *)layer in_seq_no:(NSNumber *)in_seq_no out_seq_no:(NSNumber *)out_seq_no message:(Secret45_DecryptedMessage *)message
{
    Secret45_DecryptedMessageLayer_decryptedMessageLayer *_object = [[Secret45_DecryptedMessageLayer_decryptedMessageLayer alloc] init];
    _object.random_bytes = [Secret45__Serializer addSerializerToObject:[random_bytes copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.layer = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:layer] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.in_seq_no = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:in_seq_no] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.out_seq_no = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:out_seq_no] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.message = message;
    return _object;
}


@end

@implementation Secret45_DecryptedMessageLayer_decryptedMessageLayer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x1be31789 serializeBlock:^bool (Secret45_DecryptedMessageLayer_decryptedMessageLayer *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.random_bytes data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.layer data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.in_seq_no data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.out_seq_no data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.message data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageLayer random_bytes:%d layer:%@ in_seq_no:%@ out_seq_no:%@ message:%@)", (int)[self.random_bytes length], self.layer, self.in_seq_no, self.out_seq_no, self.message];
}

@end




@interface Secret45_DecryptedMessage ()

@property (nonatomic, strong) NSNumber * random_id;

@end

@interface Secret45_DecryptedMessage_decryptedMessageService ()

@property (nonatomic, strong) Secret45_DecryptedMessageAction * action;

@end

@interface Secret45_DecryptedMessage_decryptedMessage ()

@property (nonatomic, strong) NSNumber * flags;
@property (nonatomic, strong) NSNumber * ttl;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) Secret45_DecryptedMessageMedia * media;
@property (nonatomic, strong) NSArray * entities;
@property (nonatomic, strong) NSString * via_bot_name;
@property (nonatomic, strong) NSNumber * reply_to_random_id;

@end

@implementation Secret45_DecryptedMessage

+ (Secret45_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandom_id:(NSNumber *)random_id action:(Secret45_DecryptedMessageAction *)action
{
    Secret45_DecryptedMessage_decryptedMessageService *_object = [[Secret45_DecryptedMessage_decryptedMessageService alloc] init];
    _object.random_id = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:random_id] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.action = action;
    return _object;
}

+ (Secret45_DecryptedMessage_decryptedMessage *)decryptedMessageWithFlags:(NSNumber *)flags random_id:(NSNumber *)random_id ttl:(NSNumber *)ttl message:(NSString *)message media:(Secret45_DecryptedMessageMedia *)media entities:(NSArray *)entities via_bot_name:(NSString *)via_bot_name reply_to_random_id:(NSNumber *)reply_to_random_id
{
    Secret45_DecryptedMessage_decryptedMessage *_object = [[Secret45_DecryptedMessage_decryptedMessage alloc] init];
    _object.flags = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:flags] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.random_id = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:random_id] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.ttl = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:ttl] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.message = [Secret45__Serializer addSerializerToObject:[message copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.media = media;
    _object.entities = 
({
NSMutableArray *entities_copy = [[NSMutableArray alloc] initWithCapacity:entities.count];
for (id entities_item in entities)
{
    [entities_copy addObject:entities_item];
}
id entities_result = [Secret45__Serializer addSerializerToObject:entities_copy serializer:[[Secret45__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret45__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]]; entities_result;});
    _object.via_bot_name = [Secret45__Serializer addSerializerToObject:[via_bot_name copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.reply_to_random_id = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:reply_to_random_id] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    return _object;
}


@end

@implementation Secret45_DecryptedMessage_decryptedMessageService

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x73164160 serializeBlock:^bool (Secret45_DecryptedMessage_decryptedMessageService *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.random_id data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.action data:data addSignature:true])
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

@implementation Secret45_DecryptedMessage_decryptedMessage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x36b091de serializeBlock:^bool (Secret45_DecryptedMessage_decryptedMessage *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.flags data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.random_id data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.ttl data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.message data:data addSignature:false])
                return false;
            if ([object.flags intValue] & (1 << 9)) {
            if (![Secret45__Environment serializeObject:object.media data:data addSignature:true])
                return false;
            }
            if ([object.flags intValue] & (1 << 7)) {
            if (![Secret45__Environment serializeObject:object.entities data:data addSignature:true])
                return false;
            }
            if ([object.flags intValue] & (1 << 11)) {
            if (![Secret45__Environment serializeObject:object.via_bot_name data:data addSignature:false])
                return false;
            }
            if ([object.flags intValue] & (1 << 3)) {
            if (![Secret45__Environment serializeObject:object.reply_to_random_id data:data addSignature:false])
                return false;
            }
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessage flags:%@ random_id:%@ ttl:%@ message:%d media:%@ entities:%@ via_bot_name:%d reply_to_random_id:%@)", self.flags, self.random_id, self.ttl, (int)[self.message length], self.media, self.entities, (int)[self.via_bot_name length], self.reply_to_random_id];
}

@end




@interface Secret45_DocumentAttribute ()

@end

@interface Secret45_DocumentAttribute_documentAttributeImageSize ()

@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;

@end

@interface Secret45_DocumentAttribute_documentAttributeAnimated ()

@end

@interface Secret45_DocumentAttribute_documentAttributeVideo ()

@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;

@end

@interface Secret45_DocumentAttribute_documentAttributeFilename ()

@property (nonatomic, strong) NSString * file_name;

@end

@interface Secret45_DocumentAttribute_documentAttributeSticker ()

@property (nonatomic, strong) NSString * alt;
@property (nonatomic, strong) Secret45_InputStickerSet * stickerset;

@end

@interface Secret45_DocumentAttribute_documentAttributeAudio ()

@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * performer;

@end

@implementation Secret45_DocumentAttribute

+ (Secret45_DocumentAttribute_documentAttributeImageSize *)documentAttributeImageSizeWithW:(NSNumber *)w h:(NSNumber *)h
{
    Secret45_DocumentAttribute_documentAttributeImageSize *_object = [[Secret45_DocumentAttribute_documentAttributeImageSize alloc] init];
    _object.w = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:w] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:h] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_DocumentAttribute_documentAttributeAnimated *)documentAttributeAnimated
{
    Secret45_DocumentAttribute_documentAttributeAnimated *_object = [[Secret45_DocumentAttribute_documentAttributeAnimated alloc] init];
    return _object;
}

+ (Secret45_DocumentAttribute_documentAttributeVideo *)documentAttributeVideoWithDuration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h
{
    Secret45_DocumentAttribute_documentAttributeVideo *_object = [[Secret45_DocumentAttribute_documentAttributeVideo alloc] init];
    _object.duration = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:duration] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.w = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:w] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:h] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_DocumentAttribute_documentAttributeFilename *)documentAttributeFilenameWithFile_name:(NSString *)file_name
{
    Secret45_DocumentAttribute_documentAttributeFilename *_object = [[Secret45_DocumentAttribute_documentAttributeFilename alloc] init];
    _object.file_name = [Secret45__Serializer addSerializerToObject:[file_name copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret45_DocumentAttribute_documentAttributeSticker *)documentAttributeStickerWithAlt:(NSString *)alt stickerset:(Secret45_InputStickerSet *)stickerset
{
    Secret45_DocumentAttribute_documentAttributeSticker *_object = [[Secret45_DocumentAttribute_documentAttributeSticker alloc] init];
    _object.alt = [Secret45__Serializer addSerializerToObject:[alt copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.stickerset = stickerset;
    return _object;
}

+ (Secret45_DocumentAttribute_documentAttributeAudio *)documentAttributeAudioWithDuration:(NSNumber *)duration title:(NSString *)title performer:(NSString *)performer
{
    Secret45_DocumentAttribute_documentAttributeAudio *_object = [[Secret45_DocumentAttribute_documentAttributeAudio alloc] init];
    _object.duration = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:duration] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.title = [Secret45__Serializer addSerializerToObject:[title copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.performer = [Secret45__Serializer addSerializerToObject:[performer copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation Secret45_DocumentAttribute_documentAttributeImageSize

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x6c37c15c serializeBlock:^bool (Secret45_DocumentAttribute_documentAttributeImageSize *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.h data:data addSignature:false])
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

@implementation Secret45_DocumentAttribute_documentAttributeAnimated

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x11b58939 serializeBlock:^bool (__unused Secret45_DocumentAttribute_documentAttributeAnimated *object, __unused NSMutableData *data)
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

@implementation Secret45_DocumentAttribute_documentAttributeVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x5910cccb serializeBlock:^bool (Secret45_DocumentAttribute_documentAttributeVideo *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.h data:data addSignature:false])
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

@implementation Secret45_DocumentAttribute_documentAttributeFilename

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x15590068 serializeBlock:^bool (Secret45_DocumentAttribute_documentAttributeFilename *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.file_name data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeFilename file_name:%d)", (int)[self.file_name length]];
}

@end

@implementation Secret45_DocumentAttribute_documentAttributeSticker

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x3a556302 serializeBlock:^bool (Secret45_DocumentAttribute_documentAttributeSticker *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.alt data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.stickerset data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeSticker alt:%d stickerset:%@)", (int)[self.alt length], self.stickerset];
}

@end

@implementation Secret45_DocumentAttribute_documentAttributeAudio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xded218e0 serializeBlock:^bool (Secret45_DocumentAttribute_documentAttributeAudio *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.title data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.performer data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeAudio duration:%@ title:%d performer:%d)", self.duration, (int)[self.title length], (int)[self.performer length]];
}

@end




@interface Secret45_InputStickerSet ()

@end

@interface Secret45_InputStickerSet_inputStickerSetShortName ()

@property (nonatomic, strong) NSString * short_name;

@end

@interface Secret45_InputStickerSet_inputStickerSetEmpty ()

@end

@implementation Secret45_InputStickerSet

+ (Secret45_InputStickerSet_inputStickerSetShortName *)inputStickerSetShortNameWithShort_name:(NSString *)short_name
{
    Secret45_InputStickerSet_inputStickerSetShortName *_object = [[Secret45_InputStickerSet_inputStickerSetShortName alloc] init];
    _object.short_name = [Secret45__Serializer addSerializerToObject:[short_name copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret45_InputStickerSet_inputStickerSetEmpty *)inputStickerSetEmpty
{
    Secret45_InputStickerSet_inputStickerSetEmpty *_object = [[Secret45_InputStickerSet_inputStickerSetEmpty alloc] init];
    return _object;
}


@end

@implementation Secret45_InputStickerSet_inputStickerSetShortName

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x861cc8a0 serializeBlock:^bool (Secret45_InputStickerSet_inputStickerSetShortName *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.short_name data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(inputStickerSetShortName short_name:%d)", (int)[self.short_name length]];
}

@end

@implementation Secret45_InputStickerSet_inputStickerSetEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xffb62b95 serializeBlock:^bool (__unused Secret45_InputStickerSet_inputStickerSetEmpty *object, __unused NSMutableData *data)
        {
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(inputStickerSetEmpty)"];
}

@end




@interface Secret45_MessageEntity ()

@property (nonatomic, strong) NSNumber * offset;
@property (nonatomic, strong) NSNumber * length;

@end

@interface Secret45_MessageEntity_messageEntityUnknown ()

@end

@interface Secret45_MessageEntity_messageEntityMention ()

@end

@interface Secret45_MessageEntity_messageEntityHashtag ()

@end

@interface Secret45_MessageEntity_messageEntityBotCommand ()

@end

@interface Secret45_MessageEntity_messageEntityUrl ()

@end

@interface Secret45_MessageEntity_messageEntityEmail ()

@end

@interface Secret45_MessageEntity_messageEntityBold ()

@end

@interface Secret45_MessageEntity_messageEntityItalic ()

@end

@interface Secret45_MessageEntity_messageEntityCode ()

@end

@interface Secret45_MessageEntity_messageEntityPre ()

@property (nonatomic, strong) NSString * language;

@end

@interface Secret45_MessageEntity_messageEntityTextUrl ()

@property (nonatomic, strong) NSString * url;

@end

@implementation Secret45_MessageEntity

+ (Secret45_MessageEntity_messageEntityUnknown *)messageEntityUnknownWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret45_MessageEntity_messageEntityUnknown *_object = [[Secret45_MessageEntity_messageEntityUnknown alloc] init];
    _object.offset = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:offset] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:length] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_MessageEntity_messageEntityMention *)messageEntityMentionWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret45_MessageEntity_messageEntityMention *_object = [[Secret45_MessageEntity_messageEntityMention alloc] init];
    _object.offset = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:offset] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:length] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_MessageEntity_messageEntityHashtag *)messageEntityHashtagWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret45_MessageEntity_messageEntityHashtag *_object = [[Secret45_MessageEntity_messageEntityHashtag alloc] init];
    _object.offset = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:offset] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:length] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_MessageEntity_messageEntityBotCommand *)messageEntityBotCommandWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret45_MessageEntity_messageEntityBotCommand *_object = [[Secret45_MessageEntity_messageEntityBotCommand alloc] init];
    _object.offset = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:offset] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:length] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_MessageEntity_messageEntityUrl *)messageEntityUrlWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret45_MessageEntity_messageEntityUrl *_object = [[Secret45_MessageEntity_messageEntityUrl alloc] init];
    _object.offset = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:offset] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:length] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_MessageEntity_messageEntityEmail *)messageEntityEmailWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret45_MessageEntity_messageEntityEmail *_object = [[Secret45_MessageEntity_messageEntityEmail alloc] init];
    _object.offset = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:offset] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:length] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_MessageEntity_messageEntityBold *)messageEntityBoldWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret45_MessageEntity_messageEntityBold *_object = [[Secret45_MessageEntity_messageEntityBold alloc] init];
    _object.offset = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:offset] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:length] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_MessageEntity_messageEntityItalic *)messageEntityItalicWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret45_MessageEntity_messageEntityItalic *_object = [[Secret45_MessageEntity_messageEntityItalic alloc] init];
    _object.offset = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:offset] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:length] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_MessageEntity_messageEntityCode *)messageEntityCodeWithOffset:(NSNumber *)offset length:(NSNumber *)length
{
    Secret45_MessageEntity_messageEntityCode *_object = [[Secret45_MessageEntity_messageEntityCode alloc] init];
    _object.offset = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:offset] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:length] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_MessageEntity_messageEntityPre *)messageEntityPreWithOffset:(NSNumber *)offset length:(NSNumber *)length language:(NSString *)language
{
    Secret45_MessageEntity_messageEntityPre *_object = [[Secret45_MessageEntity_messageEntityPre alloc] init];
    _object.offset = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:offset] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:length] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.language = [Secret45__Serializer addSerializerToObject:[language copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret45_MessageEntity_messageEntityTextUrl *)messageEntityTextUrlWithOffset:(NSNumber *)offset length:(NSNumber *)length url:(NSString *)url
{
    Secret45_MessageEntity_messageEntityTextUrl *_object = [[Secret45_MessageEntity_messageEntityTextUrl alloc] init];
    _object.offset = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:offset] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.length = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:length] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.url = [Secret45__Serializer addSerializerToObject:[url copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation Secret45_MessageEntity_messageEntityUnknown

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xbb92ba95 serializeBlock:^bool (Secret45_MessageEntity_messageEntityUnknown *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityUnknown offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret45_MessageEntity_messageEntityMention

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xfa04579d serializeBlock:^bool (Secret45_MessageEntity_messageEntityMention *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityMention offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret45_MessageEntity_messageEntityHashtag

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x6f635b0d serializeBlock:^bool (Secret45_MessageEntity_messageEntityHashtag *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityHashtag offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret45_MessageEntity_messageEntityBotCommand

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x6cef8ac7 serializeBlock:^bool (Secret45_MessageEntity_messageEntityBotCommand *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityBotCommand offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret45_MessageEntity_messageEntityUrl

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x6ed02538 serializeBlock:^bool (Secret45_MessageEntity_messageEntityUrl *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityUrl offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret45_MessageEntity_messageEntityEmail

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x64e475c2 serializeBlock:^bool (Secret45_MessageEntity_messageEntityEmail *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityEmail offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret45_MessageEntity_messageEntityBold

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xbd610bc9 serializeBlock:^bool (Secret45_MessageEntity_messageEntityBold *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityBold offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret45_MessageEntity_messageEntityItalic

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x826f8b60 serializeBlock:^bool (Secret45_MessageEntity_messageEntityItalic *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityItalic offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret45_MessageEntity_messageEntityCode

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x28a20571 serializeBlock:^bool (Secret45_MessageEntity_messageEntityCode *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityCode offset:%@ length:%@)", self.offset, self.length];
}

@end

@implementation Secret45_MessageEntity_messageEntityPre

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x73924be0 serializeBlock:^bool (Secret45_MessageEntity_messageEntityPre *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.language data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityPre offset:%@ length:%@ language:%d)", self.offset, self.length, (int)[self.language length]];
}

@end

@implementation Secret45_MessageEntity_messageEntityTextUrl

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x76a6d327 serializeBlock:^bool (Secret45_MessageEntity_messageEntityTextUrl *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.offset data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.length data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.url data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(messageEntityTextUrl offset:%@ length:%@ url:%d)", self.offset, self.length, (int)[self.url length]];
}

@end




@interface Secret45_DecryptedMessageMedia ()

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaEmpty ()

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaGeoPoint ()

@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * plong;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaContact ()

@property (nonatomic, strong) NSString * phone_number;
@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSNumber * user_id;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaAudio ()

@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSString * mime_type;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaExternalDocument ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * access_hash;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSString * mime_type;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) Secret45_PhotoSize * thumb;
@property (nonatomic, strong) NSNumber * dc_id;
@property (nonatomic, strong) NSArray * attributes;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaPhoto ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumb_w;
@property (nonatomic, strong) NSNumber * thumb_h;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;
@property (nonatomic, strong) NSString * caption;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaDocument ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumb_w;
@property (nonatomic, strong) NSNumber * thumb_h;
@property (nonatomic, strong) NSString * mime_type;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;
@property (nonatomic, strong) NSArray * attributes;
@property (nonatomic, strong) NSString * caption;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaVideo ()

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
@property (nonatomic, strong) NSString * caption;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaVenue ()

@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * plong;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * address;
@property (nonatomic, strong) NSString * provider;
@property (nonatomic, strong) NSString * venue_id;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaWebpage ()

@property (nonatomic, strong) NSString * url;

@end

@implementation Secret45_DecryptedMessageMedia

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaEmpty *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaEmpty alloc] init];
    return _object;
}

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaGeoPoint alloc] init];
    _object.lat = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:lat] serializer:[[Secret45_BuiltinSerializer_Double alloc] init]];
    _object.plong = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:plong] serializer:[[Secret45_BuiltinSerializer_Double alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(NSNumber *)user_id
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaContact *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaContact alloc] init];
    _object.phone_number = [Secret45__Serializer addSerializerToObject:[phone_number copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.first_name = [Secret45__Serializer addSerializerToObject:[first_name copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.last_name = [Secret45__Serializer addSerializerToObject:[last_name copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.user_id = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:user_id] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaAudio *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaAudio alloc] init];
    _object.duration = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:duration] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.mime_type = [Secret45__Serializer addSerializerToObject:[mime_type copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:size] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret45__Serializer addSerializerToObject:[key copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret45__Serializer addSerializerToObject:[iv copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)decryptedMessageMediaExternalDocumentWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash date:(NSNumber *)date mime_type:(NSString *)mime_type size:(NSNumber *)size thumb:(Secret45_PhotoSize *)thumb dc_id:(NSNumber *)dc_id attributes:(NSArray *)attributes
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaExternalDocument alloc] init];
    _object.pid = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:pid] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.access_hash = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:access_hash] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.date = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:date] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.mime_type = [Secret45__Serializer addSerializerToObject:[mime_type copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:size] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.thumb = thumb;
    _object.dc_id = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:dc_id] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.attributes = 
({
NSMutableArray *attributes_copy = [[NSMutableArray alloc] initWithCapacity:attributes.count];
for (id attributes_item in attributes)
{
    [attributes_copy addObject:attributes_item];
}
id attributes_result = [Secret45__Serializer addSerializerToObject:attributes_copy serializer:[[Secret45__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret45__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]]; attributes_result;});
    return _object;
}

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv caption:(NSString *)caption
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaPhoto *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaPhoto alloc] init];
    _object.thumb = [Secret45__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.thumb_w = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:thumb_w] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.thumb_h = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:thumb_h] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.w = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:w] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:h] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:size] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret45__Serializer addSerializerToObject:[key copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret45__Serializer addSerializerToObject:[iv copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.caption = [Secret45__Serializer addSerializerToObject:[caption copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv attributes:(NSArray *)attributes caption:(NSString *)caption
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaDocument *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaDocument alloc] init];
    _object.thumb = [Secret45__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.thumb_w = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:thumb_w] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.thumb_h = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:thumb_h] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.mime_type = [Secret45__Serializer addSerializerToObject:[mime_type copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:size] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret45__Serializer addSerializerToObject:[key copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret45__Serializer addSerializerToObject:[iv copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.attributes = 
({
NSMutableArray *attributes_copy = [[NSMutableArray alloc] initWithCapacity:attributes.count];
for (id attributes_item in attributes)
{
    [attributes_copy addObject:attributes_item];
}
id attributes_result = [Secret45__Serializer addSerializerToObject:attributes_copy serializer:[[Secret45__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret45__Environment serializeObject:item data:data addSignature:true])
        return false;
    }
    return true;
}]]; attributes_result;});
    _object.caption = [Secret45__Serializer addSerializerToObject:[caption copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h duration:(NSNumber *)duration mime_type:(NSString *)mime_type w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv caption:(NSString *)caption
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaVideo *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaVideo alloc] init];
    _object.thumb = [Secret45__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.thumb_w = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:thumb_w] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.thumb_h = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:thumb_h] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.duration = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:duration] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.mime_type = [Secret45__Serializer addSerializerToObject:[mime_type copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.w = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:w] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:h] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:size] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret45__Serializer addSerializerToObject:[key copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret45__Serializer addSerializerToObject:[iv copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.caption = [Secret45__Serializer addSerializerToObject:[caption copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaVenue *)decryptedMessageMediaVenueWithLat:(NSNumber *)lat plong:(NSNumber *)plong title:(NSString *)title address:(NSString *)address provider:(NSString *)provider venue_id:(NSString *)venue_id
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaVenue *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaVenue alloc] init];
    _object.lat = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:lat] serializer:[[Secret45_BuiltinSerializer_Double alloc] init]];
    _object.plong = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:plong] serializer:[[Secret45_BuiltinSerializer_Double alloc] init]];
    _object.title = [Secret45__Serializer addSerializerToObject:[title copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.address = [Secret45__Serializer addSerializerToObject:[address copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.provider = [Secret45__Serializer addSerializerToObject:[provider copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.venue_id = [Secret45__Serializer addSerializerToObject:[venue_id copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaWebpage *)decryptedMessageMediaWebpageWithUrl:(NSString *)url
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaWebpage *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaWebpage alloc] init];
    _object.url = [Secret45__Serializer addSerializerToObject:[url copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    return _object;
}


@end

@implementation Secret45_DecryptedMessageMedia_decryptedMessageMediaEmpty

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x89f5c4a serializeBlock:^bool (__unused Secret45_DecryptedMessageMedia_decryptedMessageMediaEmpty *object, __unused NSMutableData *data)
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

@implementation Secret45_DecryptedMessageMedia_decryptedMessageMediaGeoPoint

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x35480a59 serializeBlock:^bool (Secret45_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.lat data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.plong data:data addSignature:false])
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

@implementation Secret45_DecryptedMessageMedia_decryptedMessageMediaContact

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x588a0a97 serializeBlock:^bool (Secret45_DecryptedMessageMedia_decryptedMessageMediaContact *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.phone_number data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.first_name data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.last_name data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.user_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaContact phone_number:%d first_name:%d last_name:%d user_id:%@)", (int)[self.phone_number length], (int)[self.first_name length], (int)[self.last_name length], self.user_id];
}

@end

@implementation Secret45_DecryptedMessageMedia_decryptedMessageMediaAudio

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x57e0a9cb serializeBlock:^bool (Secret45_DecryptedMessageMedia_decryptedMessageMediaAudio *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaAudio duration:%@ mime_type:%d size:%@ key:%d iv:%d)", self.duration, (int)[self.mime_type length], self.size, (int)[self.key length], (int)[self.iv length]];
}

@end

@implementation Secret45_DecryptedMessageMedia_decryptedMessageMediaExternalDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xfa95b0dd serializeBlock:^bool (Secret45_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.pid data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.access_hash data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.thumb data:data addSignature:true])
                return false;
            if (![Secret45__Environment serializeObject:object.dc_id data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.attributes data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaExternalDocument id:%@ access_hash:%@ date:%@ mime_type:%d size:%@ thumb:%@ dc_id:%@ attributes:%@)", self.pid, self.access_hash, self.date, (int)[self.mime_type length], self.size, self.thumb, self.dc_id, self.attributes];
}

@end

@implementation Secret45_DecryptedMessageMedia_decryptedMessageMediaPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xf1fa8d78 serializeBlock:^bool (Secret45_DecryptedMessageMedia_decryptedMessageMediaPhoto *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.thumb_w data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.thumb_h data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.caption data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaPhoto thumb:%d thumb_w:%@ thumb_h:%@ w:%@ h:%@ size:%@ key:%d iv:%d caption:%d)", (int)[self.thumb length], self.thumb_w, self.thumb_h, self.w, self.h, self.size, (int)[self.key length], (int)[self.iv length], (int)[self.caption length]];
}

@end

@implementation Secret45_DecryptedMessageMedia_decryptedMessageMediaDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x7afe8ae2 serializeBlock:^bool (Secret45_DecryptedMessageMedia_decryptedMessageMediaDocument *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.thumb_w data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.thumb_h data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.attributes data:data addSignature:true])
                return false;
            if (![Secret45__Environment serializeObject:object.caption data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaDocument thumb:%d thumb_w:%@ thumb_h:%@ mime_type:%d size:%@ key:%d iv:%d attributes:%@ caption:%d)", (int)[self.thumb length], self.thumb_w, self.thumb_h, (int)[self.mime_type length], self.size, (int)[self.key length], (int)[self.iv length], self.attributes, (int)[self.caption length]];
}

@end

@implementation Secret45_DecryptedMessageMedia_decryptedMessageMediaVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x970c8c0e serializeBlock:^bool (Secret45_DecryptedMessageMedia_decryptedMessageMediaVideo *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.thumb_w data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.thumb_h data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.mime_type data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.w data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.h data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.iv data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.caption data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaVideo thumb:%d thumb_w:%@ thumb_h:%@ duration:%@ mime_type:%d w:%@ h:%@ size:%@ key:%d iv:%d caption:%d)", (int)[self.thumb length], self.thumb_w, self.thumb_h, self.duration, (int)[self.mime_type length], self.w, self.h, self.size, (int)[self.key length], (int)[self.iv length], (int)[self.caption length]];
}

@end

@implementation Secret45_DecryptedMessageMedia_decryptedMessageMediaVenue

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x8a0df56f serializeBlock:^bool (Secret45_DecryptedMessageMedia_decryptedMessageMediaVenue *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.lat data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.plong data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.title data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.address data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.provider data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.venue_id data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaVenue lat:%@ long:%@ title:%d address:%d provider:%d venue_id:%d)", self.lat, self.plong, (int)[self.title length], (int)[self.address length], (int)[self.provider length], (int)[self.venue_id length]];
}

@end

@implementation Secret45_DecryptedMessageMedia_decryptedMessageMediaWebpage

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x82684ff4 serializeBlock:^bool (Secret45_DecryptedMessageMedia_decryptedMessageMediaWebpage *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.url data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaWebpage url:%d)", (int)[self.url length]];
}

@end




@implementation Secret45: NSObject

@end
