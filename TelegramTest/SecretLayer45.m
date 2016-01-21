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
            NSNumber * ttlSeconds = nil;
            if ((ttlSeconds = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtlSeconds:ttlSeconds];
        } copy];
        parsers[@((int32_t)0xc4f40be)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * randomIds = nil;
            int32_t randomIds_signature = 0; [data getBytes:(void *)&randomIds_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((randomIds = [Secret45__Environment parseObject:data offset:_offset implicitSignature:randomIds_signature metaInfo:[[Secret45__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionReadMessagesWithRandomIds:randomIds];
        } copy];
        parsers[@((int32_t)0x65614304)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * randomIds = nil;
            int32_t randomIds_signature = 0; [data getBytes:(void *)&randomIds_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((randomIds = [Secret45__Environment parseObject:data offset:_offset implicitSignature:randomIds_signature metaInfo:[[Secret45__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandomIds:randomIds];
        } copy];
        parsers[@((int32_t)0x8ac1f475)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSArray * randomIds = nil;
            int32_t randomIds_signature = 0; [data getBytes:(void *)&randomIds_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((randomIds = [Secret45__Environment parseObject:data offset:_offset implicitSignature:randomIds_signature metaInfo:[[Secret45__UnboxedTypeMetaInfo alloc] initWithConstructorSignature:(int32_t)0x22076cba]]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionScreenshotMessagesWithRandomIds:randomIds];
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
            NSNumber * startSeqNo = nil;
            if ((startSeqNo = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * endSeqNo = nil;
            if ((endSeqNo = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionResendWithStartSeqNo:startSeqNo endSeqNo:endSeqNo];
        } copy];
        parsers[@((int32_t)0xf3c9611b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchangeId = nil;
            if ((exchangeId = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * gA = nil;
            if ((gA = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionRequestKeyWithExchangeId:exchangeId gA:gA];
        } copy];
        parsers[@((int32_t)0x6fe1735b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchangeId = nil;
            if ((exchangeId = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSData * gB = nil;
            if ((gB = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * keyFingerprint = nil;
            if ((keyFingerprint = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionAcceptKeyWithExchangeId:exchangeId gB:gB keyFingerprint:keyFingerprint];
        } copy];
        parsers[@((int32_t)0xec2e0b9b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchangeId = nil;
            if ((exchangeId = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * keyFingerprint = nil;
            if ((keyFingerprint = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionCommitKeyWithExchangeId:exchangeId keyFingerprint:keyFingerprint];
        } copy];
        parsers[@((int32_t)0xdd05ec6b)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * exchangeId = nil;
            if ((exchangeId = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageAction decryptedMessageActionAbortKeyWithExchangeId:exchangeId];
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
            NSNumber * volumeId = nil;
            if ((volumeId = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * localId = nil;
            if ((localId = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * secret = nil;
            if ((secret = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret45_FileLocation fileLocationUnavailableWithVolumeId:volumeId localId:localId secret:secret];
        } copy];
        parsers[@((int32_t)0x53d69076)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * dcId = nil;
            if ((dcId = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * volumeId = nil;
            if ((volumeId = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * localId = nil;
            if ((localId = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * secret = nil;
            if ((secret = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            return [Secret45_FileLocation fileLocationWithDcId:dcId volumeId:volumeId localId:localId secret:secret];
        } copy];
        parsers[@((int32_t)0x1be31789)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * randomBytes = nil;
            if ((randomBytes = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * layer = nil;
            if ((layer = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * inSeqNo = nil;
            if ((inSeqNo = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * outSeqNo = nil;
            if ((outSeqNo = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            Secret45_DecryptedMessage * message = nil;
            int32_t message_signature = 0; [data getBytes:(void *)&message_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((message = [Secret45__Environment parseObject:data offset:_offset implicitSignature:message_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageLayer decryptedMessageLayerWithRandomBytes:randomBytes layer:layer inSeqNo:inSeqNo outSeqNo:outSeqNo message:message];
        } copy];
        parsers[@((int32_t)0x73164160)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * randomId = nil;
            if ((randomId = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            Secret45_DecryptedMessageAction * action = nil;
            int32_t action_signature = 0; [data getBytes:(void *)&action_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((action = [Secret45__Environment parseObject:data offset:_offset implicitSignature:action_signature metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessage decryptedMessageServiceWithRandomId:randomId action:action];
        } copy];
        parsers[@((int32_t)0x36b091de)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * flags = nil;
            if ((flags = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * randomId = nil;
            if ((randomId = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
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
            NSString * viaBotName = nil;
            if (flags != nil && ([flags intValue] & (1 << 11))) {
            if ((viaBotName = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            }
            NSNumber * replyToRandomId = nil;
            if (flags != nil && ([flags intValue] & (1 << 3))) {
            if ((replyToRandomId = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            }
            return [Secret45_DecryptedMessage decryptedMessageWithFlags:flags randomId:randomId ttl:ttl message:message media:media entities:entities viaBotName:viaBotName replyToRandomId:replyToRandomId];
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
            NSString * fileName = nil;
            if ((fileName = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DocumentAttribute documentAttributeFilenameWithFileName:fileName];
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
            NSString * shortName = nil;
            if ((shortName = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            return [Secret45_InputStickerSet inputStickerSetShortNameWithShortName:shortName];
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
        parsers[@((int32_t)0x32798a8c)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumbW = nil;
            if ((thumbW = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumbH = nil;
            if ((thumbH = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
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
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumb thumbW:thumbW thumbH:thumbH w:w h:h size:size key:key iv:iv];
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
            NSString * phoneNumber = nil;
            if ((phoneNumber = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * firstName = nil;
            if ((firstName = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSString * lastName = nil;
            if ((lastName = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * userId = nil;
            if ((userId = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaContactWithPhoneNumber:phoneNumber firstName:firstName lastName:lastName userId:userId];
        } copy];
        parsers[@((int32_t)0x524a415d)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumbW = nil;
            if ((thumbW = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumbH = nil;
            if ((thumbH = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * duration = nil;
            if ((duration = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mimeType = nil;
            if ((mimeType = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
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
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb:thumb thumbW:thumbW thumbH:thumbH duration:duration mimeType:mimeType w:w h:h size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0x57e0a9cb)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * duration = nil;
            if ((duration = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mimeType = nil;
            if ((mimeType = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
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
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:duration mimeType:mimeType size:size key:key iv:iv];
        } copy];
        parsers[@((int32_t)0xfa95b0dd)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSNumber * pid = nil;
            if ((pid = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * accessHash = nil;
            if ((accessHash = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0x22076cba metaInfo:nil]) == nil)
               return nil;
            NSNumber * date = nil;
            if ((date = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mimeType = nil;
            if ((mimeType = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
               return nil;
            NSNumber * size = nil;
            if ((size = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            Secret45_PhotoSize * thumb = nil;
            int32_t thumb_signature = 0; [data getBytes:(void *)&thumb_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((thumb = [Secret45__Environment parseObject:data offset:_offset implicitSignature:thumb_signature metaInfo:nil]) == nil)
               return nil;
            NSNumber * dcId = nil;
            if ((dcId = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSArray * attributes = nil;
            int32_t attributes_signature = 0; [data getBytes:(void *)&attributes_signature range:NSMakeRange(*_offset, 4)]; *_offset += 4;
            if ((attributes = [Secret45__Environment parseObject:data offset:_offset implicitSignature:attributes_signature metaInfo:[Secret45__BoxedTypeMetaInfo boxedTypeMetaInfo]]) == nil)
               return nil;
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaExternalDocumentWithPid:pid accessHash:accessHash date:date mimeType:mimeType size:size thumb:thumb dcId:dcId attributes:attributes];
        } copy];
        parsers[@((int32_t)0xfee613da)] = [^id (NSData *data, NSUInteger* _offset, __unused id metaInfo)
        {
            NSData * thumb = nil;
            if ((thumb = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:[Secret45__PreferNSDataTypeMetaInfo preferNSDataTypeMetaInfo]]) == nil)
               return nil;
            NSNumber * thumbW = nil;
            if ((thumbW = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSNumber * thumbH = nil;
            if ((thumbH = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xa8509bda metaInfo:nil]) == nil)
               return nil;
            NSString * mimeType = nil;
            if ((mimeType = [Secret45__Environment parseObject:data offset:_offset implicitSignature:(int32_t)0xb5286e24 metaInfo:nil]) == nil)
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
            return [Secret45_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumb thumbW:thumbW thumbH:thumbH mimeType:mimeType size:size key:key iv:iv attributes:attributes];
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

@property (nonatomic, strong) NSNumber * ttlSeconds;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionReadMessages ()

@property (nonatomic, strong) NSArray * randomIds;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionDeleteMessages ()

@property (nonatomic, strong) NSArray * randomIds;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionScreenshotMessages ()

@property (nonatomic, strong) NSArray * randomIds;

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

@property (nonatomic, strong) NSNumber * startSeqNo;
@property (nonatomic, strong) NSNumber * endSeqNo;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionRequestKey ()

@property (nonatomic, strong) NSNumber * exchangeId;
@property (nonatomic, strong) NSData * gA;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionAcceptKey ()

@property (nonatomic, strong) NSNumber * exchangeId;
@property (nonatomic, strong) NSData * gB;
@property (nonatomic, strong) NSNumber * keyFingerprint;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionCommitKey ()

@property (nonatomic, strong) NSNumber * exchangeId;
@property (nonatomic, strong) NSNumber * keyFingerprint;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionAbortKey ()

@property (nonatomic, strong) NSNumber * exchangeId;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionNoop ()

@end

@implementation Secret45_DecryptedMessageAction

+ (Secret45_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtlSeconds:(NSNumber *)ttlSeconds
{
    Secret45_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionSetMessageTTL alloc] init];
    _object.ttlSeconds = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:ttlSeconds] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandomIds:(NSArray *)randomIds
{
    Secret45_DecryptedMessageAction_decryptedMessageActionReadMessages *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionReadMessages alloc] init];
    _object.randomIds = 
({
NSMutableArray *randomIds_copy = [[NSMutableArray alloc] initWithCapacity:randomIds.count];
for (id randomIds_item in randomIds)
{
    [randomIds_copy addObject:[Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:randomIds_item] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]]];
}
id randomIds_result = [Secret45__Serializer addSerializerToObject:randomIds_copy serializer:[[Secret45__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret45__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; randomIds_result;});
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandomIds:(NSArray *)randomIds
{
    Secret45_DecryptedMessageAction_decryptedMessageActionDeleteMessages *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionDeleteMessages alloc] init];
    _object.randomIds = 
({
NSMutableArray *randomIds_copy = [[NSMutableArray alloc] initWithCapacity:randomIds.count];
for (id randomIds_item in randomIds)
{
    [randomIds_copy addObject:[Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:randomIds_item] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]]];
}
id randomIds_result = [Secret45__Serializer addSerializerToObject:randomIds_copy serializer:[[Secret45__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret45__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; randomIds_result;});
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandomIds:(NSArray *)randomIds
{
    Secret45_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionScreenshotMessages alloc] init];
    _object.randomIds = 
({
NSMutableArray *randomIds_copy = [[NSMutableArray alloc] initWithCapacity:randomIds.count];
for (id randomIds_item in randomIds)
{
    [randomIds_copy addObject:[Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:randomIds_item] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]]];
}
id randomIds_result = [Secret45__Serializer addSerializerToObject:randomIds_copy serializer:[[Secret45__Serializer alloc] initWithConstructorSignature:(int32_t)0x1cb5c415 serializeBlock:^bool (NSArray *object, NSMutableData *data)
{
    int32_t count = (int32_t)object.count;
    [data appendBytes:(void *)&count length:4];
    for (id item in object)
    {
        if (![Secret45__Environment serializeObject:item data:data addSignature:false])
        return false;
    }
    return true;
}]]; randomIds_result;});
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

+ (Secret45_DecryptedMessageAction_decryptedMessageActionResend *)decryptedMessageActionResendWithStartSeqNo:(NSNumber *)startSeqNo endSeqNo:(NSNumber *)endSeqNo
{
    Secret45_DecryptedMessageAction_decryptedMessageActionResend *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionResend alloc] init];
    _object.startSeqNo = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:startSeqNo] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.endSeqNo = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:endSeqNo] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionRequestKey *)decryptedMessageActionRequestKeyWithExchangeId:(NSNumber *)exchangeId gA:(NSData *)gA
{
    Secret45_DecryptedMessageAction_decryptedMessageActionRequestKey *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionRequestKey alloc] init];
    _object.exchangeId = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:exchangeId] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.gA = [Secret45__Serializer addSerializerToObject:[gA copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionAcceptKey *)decryptedMessageActionAcceptKeyWithExchangeId:(NSNumber *)exchangeId gB:(NSData *)gB keyFingerprint:(NSNumber *)keyFingerprint
{
    Secret45_DecryptedMessageAction_decryptedMessageActionAcceptKey *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionAcceptKey alloc] init];
    _object.exchangeId = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:exchangeId] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.gB = [Secret45__Serializer addSerializerToObject:[gB copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.keyFingerprint = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:keyFingerprint] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionCommitKey *)decryptedMessageActionCommitKeyWithExchangeId:(NSNumber *)exchangeId keyFingerprint:(NSNumber *)keyFingerprint
{
    Secret45_DecryptedMessageAction_decryptedMessageActionCommitKey *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionCommitKey alloc] init];
    _object.exchangeId = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:exchangeId] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.keyFingerprint = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:keyFingerprint] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageAction_decryptedMessageActionAbortKey *)decryptedMessageActionAbortKeyWithExchangeId:(NSNumber *)exchangeId
{
    Secret45_DecryptedMessageAction_decryptedMessageActionAbortKey *_object = [[Secret45_DecryptedMessageAction_decryptedMessageActionAbortKey alloc] init];
    _object.exchangeId = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:exchangeId] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
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
            if (![Secret45__Environment serializeObject:object.ttlSeconds data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionSetMessageTTL ttl_seconds:%@)", self.ttlSeconds];
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
            if (![Secret45__Environment serializeObject:object.randomIds data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionReadMessages random_ids:%@)", self.randomIds];
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
            if (![Secret45__Environment serializeObject:object.randomIds data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionDeleteMessages random_ids:%@)", self.randomIds];
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
            if (![Secret45__Environment serializeObject:object.randomIds data:data addSignature:true])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionScreenshotMessages random_ids:%@)", self.randomIds];
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
            if (![Secret45__Environment serializeObject:object.startSeqNo data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.endSeqNo data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionResend start_seq_no:%@ end_seq_no:%@)", self.startSeqNo, self.endSeqNo];
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
            if (![Secret45__Environment serializeObject:object.exchangeId data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.gA data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionRequestKey exchange_id:%@ g_a:%d)", self.exchangeId, (int)[self.gA length]];
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
            if (![Secret45__Environment serializeObject:object.exchangeId data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.gB data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.keyFingerprint data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionAcceptKey exchange_id:%@ g_b:%d key_fingerprint:%@)", self.exchangeId, (int)[self.gB length], self.keyFingerprint];
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
            if (![Secret45__Environment serializeObject:object.exchangeId data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.keyFingerprint data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionCommitKey exchange_id:%@ key_fingerprint:%@)", self.exchangeId, self.keyFingerprint];
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
            if (![Secret45__Environment serializeObject:object.exchangeId data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageActionAbortKey exchange_id:%@)", self.exchangeId];
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

@property (nonatomic, strong) NSNumber * volumeId;
@property (nonatomic, strong) NSNumber * localId;
@property (nonatomic, strong) NSNumber * secret;

@end

@interface Secret45_FileLocation_fileLocationUnavailable ()

@end

@interface Secret45_FileLocation_fileLocation ()

@property (nonatomic, strong) NSNumber * dcId;

@end

@implementation Secret45_FileLocation

+ (Secret45_FileLocation_fileLocationUnavailable *)fileLocationUnavailableWithVolumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret
{
    Secret45_FileLocation_fileLocationUnavailable *_object = [[Secret45_FileLocation_fileLocationUnavailable alloc] init];
    _object.volumeId = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:volumeId] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.localId = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:localId] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.secret = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:secret] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    return _object;
}

+ (Secret45_FileLocation_fileLocation *)fileLocationWithDcId:(NSNumber *)dcId volumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret
{
    Secret45_FileLocation_fileLocation *_object = [[Secret45_FileLocation_fileLocation alloc] init];
    _object.dcId = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:dcId] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.volumeId = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:volumeId] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.localId = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:localId] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
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
            if (![Secret45__Environment serializeObject:object.volumeId data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.localId data:data addSignature:false])
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
    return [[NSString alloc] initWithFormat:@"(fileLocationUnavailable volume_id:%@ local_id:%@ secret:%@)", self.volumeId, self.localId, self.secret];
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
            if (![Secret45__Environment serializeObject:object.dcId data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.volumeId data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.localId data:data addSignature:false])
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
    return [[NSString alloc] initWithFormat:@"(fileLocation dc_id:%@ volume_id:%@ local_id:%@ secret:%@)", self.dcId, self.volumeId, self.localId, self.secret];
}

@end




@interface Secret45_DecryptedMessageLayer ()

@property (nonatomic, strong) NSData * randomBytes;
@property (nonatomic, strong) NSNumber * layer;
@property (nonatomic, strong) NSNumber * inSeqNo;
@property (nonatomic, strong) NSNumber * outSeqNo;
@property (nonatomic, strong) Secret45_DecryptedMessage * message;

@end

@interface Secret45_DecryptedMessageLayer_decryptedMessageLayer ()

@end

@implementation Secret45_DecryptedMessageLayer

+ (Secret45_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithRandomBytes:(NSData *)randomBytes layer:(NSNumber *)layer inSeqNo:(NSNumber *)inSeqNo outSeqNo:(NSNumber *)outSeqNo message:(Secret45_DecryptedMessage *)message
{
    Secret45_DecryptedMessageLayer_decryptedMessageLayer *_object = [[Secret45_DecryptedMessageLayer_decryptedMessageLayer alloc] init];
    _object.randomBytes = [Secret45__Serializer addSerializerToObject:[randomBytes copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.layer = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:layer] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.inSeqNo = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:inSeqNo] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.outSeqNo = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:outSeqNo] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
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
            if (![Secret45__Environment serializeObject:object.randomBytes data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.layer data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.inSeqNo data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.outSeqNo data:data addSignature:false])
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
    return [[NSString alloc] initWithFormat:@"(decryptedMessageLayer random_bytes:%d layer:%@ in_seq_no:%@ out_seq_no:%@ message:%@)", (int)[self.randomBytes length], self.layer, self.inSeqNo, self.outSeqNo, self.message];
}

@end




@interface Secret45_DecryptedMessage ()

@property (nonatomic, strong) NSNumber * randomId;

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
@property (nonatomic, strong) NSString * viaBotName;
@property (nonatomic, strong) NSNumber * replyToRandomId;

@end

@implementation Secret45_DecryptedMessage

+ (Secret45_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandomId:(NSNumber *)randomId action:(Secret45_DecryptedMessageAction *)action
{
    Secret45_DecryptedMessage_decryptedMessageService *_object = [[Secret45_DecryptedMessage_decryptedMessageService alloc] init];
    _object.randomId = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:randomId] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.action = action;
    return _object;
}

+ (Secret45_DecryptedMessage_decryptedMessage *)decryptedMessageWithFlags:(NSNumber *)flags randomId:(NSNumber *)randomId ttl:(NSNumber *)ttl message:(NSString *)message media:(Secret45_DecryptedMessageMedia *)media entities:(NSArray *)entities viaBotName:(NSString *)viaBotName replyToRandomId:(NSNumber *)replyToRandomId
{
    Secret45_DecryptedMessage_decryptedMessage *_object = [[Secret45_DecryptedMessage_decryptedMessage alloc] init];
    _object.flags = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:flags] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.randomId = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:randomId] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
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
    _object.viaBotName = [Secret45__Serializer addSerializerToObject:[viaBotName copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.replyToRandomId = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:replyToRandomId] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
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
            if (![Secret45__Environment serializeObject:object.randomId data:data addSignature:false])
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
    return [[NSString alloc] initWithFormat:@"(decryptedMessageService random_id:%@ action:%@)", self.randomId, self.action];
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
            if (![Secret45__Environment serializeObject:object.randomId data:data addSignature:false])
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
            if (![Secret45__Environment serializeObject:object.viaBotName data:data addSignature:false])
                return false;
            }
            if ([object.flags intValue] & (1 << 3)) {
            if (![Secret45__Environment serializeObject:object.replyToRandomId data:data addSignature:false])
                return false;
            }
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessage flags:%@ random_id:%@ ttl:%@ message:%d media:%@ entities:%@ via_bot_name:%d reply_to_random_id:%@)", self.flags, self.randomId, self.ttl, (int)[self.message length], self.media, self.entities, (int)[self.viaBotName length], self.replyToRandomId];
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

@property (nonatomic, strong) NSString * fileName;

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

+ (Secret45_DocumentAttribute_documentAttributeFilename *)documentAttributeFilenameWithFileName:(NSString *)fileName
{
    Secret45_DocumentAttribute_documentAttributeFilename *_object = [[Secret45_DocumentAttribute_documentAttributeFilename alloc] init];
    _object.fileName = [Secret45__Serializer addSerializerToObject:[fileName copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
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
            if (![Secret45__Environment serializeObject:object.fileName data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(documentAttributeFilename file_name:%d)", (int)[self.fileName length]];
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

@property (nonatomic, strong) NSString * shortName;

@end

@interface Secret45_InputStickerSet_inputStickerSetEmpty ()

@end

@implementation Secret45_InputStickerSet

+ (Secret45_InputStickerSet_inputStickerSetShortName *)inputStickerSetShortNameWithShortName:(NSString *)shortName
{
    Secret45_InputStickerSet_inputStickerSetShortName *_object = [[Secret45_InputStickerSet_inputStickerSetShortName alloc] init];
    _object.shortName = [Secret45__Serializer addSerializerToObject:[shortName copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
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
            if (![Secret45__Environment serializeObject:object.shortName data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(inputStickerSetShortName short_name:%d)", (int)[self.shortName length]];
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

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaPhoto ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumbW;
@property (nonatomic, strong) NSNumber * thumbH;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaGeoPoint ()

@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * plong;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaContact ()

@property (nonatomic, strong) NSString * phoneNumber;
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSNumber * userId;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaVideo ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumbW;
@property (nonatomic, strong) NSNumber * thumbH;
@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSString * mimeType;
@property (nonatomic, strong) NSNumber * w;
@property (nonatomic, strong) NSNumber * h;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaAudio ()

@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSString * mimeType;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaExternalDocument ()

@property (nonatomic, strong) NSNumber * pid;
@property (nonatomic, strong) NSNumber * accessHash;
@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSString * mimeType;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) Secret45_PhotoSize * thumb;
@property (nonatomic, strong) NSNumber * dcId;
@property (nonatomic, strong) NSArray * attributes;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaDocument ()

@property (nonatomic, strong) NSData * thumb;
@property (nonatomic, strong) NSNumber * thumbW;
@property (nonatomic, strong) NSNumber * thumbH;
@property (nonatomic, strong) NSString * mimeType;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * key;
@property (nonatomic, strong) NSData * iv;
@property (nonatomic, strong) NSArray * attributes;

@end

@implementation Secret45_DecryptedMessageMedia

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaEmpty *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaEmpty alloc] init];
    return _object;
}

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaPhoto *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaPhoto alloc] init];
    _object.thumb = [Secret45__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.thumbW = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:thumbW] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.thumbH = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:thumbH] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.w = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:w] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:h] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:size] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret45__Serializer addSerializerToObject:[key copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret45__Serializer addSerializerToObject:[iv copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaGeoPoint alloc] init];
    _object.lat = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:lat] serializer:[[Secret45_BuiltinSerializer_Double alloc] init]];
    _object.plong = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:plong] serializer:[[Secret45_BuiltinSerializer_Double alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhoneNumber:(NSString *)phoneNumber firstName:(NSString *)firstName lastName:(NSString *)lastName userId:(NSNumber *)userId
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaContact *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaContact alloc] init];
    _object.phoneNumber = [Secret45__Serializer addSerializerToObject:[phoneNumber copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.firstName = [Secret45__Serializer addSerializerToObject:[firstName copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.lastName = [Secret45__Serializer addSerializerToObject:[lastName copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.userId = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:userId] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH duration:(NSNumber *)duration mimeType:(NSString *)mimeType w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaVideo *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaVideo alloc] init];
    _object.thumb = [Secret45__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.thumbW = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:thumbW] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.thumbH = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:thumbH] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.duration = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:duration] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.mimeType = [Secret45__Serializer addSerializerToObject:[mimeType copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.w = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:w] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.h = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:h] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.size = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:size] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret45__Serializer addSerializerToObject:[key copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret45__Serializer addSerializerToObject:[iv copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaAudio *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaAudio alloc] init];
    _object.duration = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:duration] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.mimeType = [Secret45__Serializer addSerializerToObject:[mimeType copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:size] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.key = [Secret45__Serializer addSerializerToObject:[key copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.iv = [Secret45__Serializer addSerializerToObject:[iv copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    return _object;
}

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)decryptedMessageMediaExternalDocumentWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date mimeType:(NSString *)mimeType size:(NSNumber *)size thumb:(Secret45_PhotoSize *)thumb dcId:(NSNumber *)dcId attributes:(NSArray *)attributes
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaExternalDocument alloc] init];
    _object.pid = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:pid] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.accessHash = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:accessHash] serializer:[[Secret45_BuiltinSerializer_Long alloc] init]];
    _object.date = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:date] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.mimeType = [Secret45__Serializer addSerializerToObject:[mimeType copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
    _object.size = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:size] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.thumb = thumb;
    _object.dcId = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:dcId] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
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

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv attributes:(NSArray *)attributes
{
    Secret45_DecryptedMessageMedia_decryptedMessageMediaDocument *_object = [[Secret45_DecryptedMessageMedia_decryptedMessageMediaDocument alloc] init];
    _object.thumb = [Secret45__Serializer addSerializerToObject:[thumb copy] serializer:[[Secret45_BuiltinSerializer_Bytes alloc] init]];
    _object.thumbW = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:thumbW] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.thumbH = [Secret45__Serializer addSerializerToObject:[[Secret45__Number alloc] initWithNumber:thumbH] serializer:[[Secret45_BuiltinSerializer_Int alloc] init]];
    _object.mimeType = [Secret45__Serializer addSerializerToObject:[mimeType copy] serializer:[[Secret45_BuiltinSerializer_String alloc] init]];
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

@implementation Secret45_DecryptedMessageMedia_decryptedMessageMediaPhoto

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x32798a8c serializeBlock:^bool (Secret45_DecryptedMessageMedia_decryptedMessageMediaPhoto *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.thumbW data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.thumbH data:data addSignature:false])
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
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaPhoto thumb:%d thumb_w:%@ thumb_h:%@ w:%@ h:%@ size:%@ key:%d iv:%d)", (int)[self.thumb length], self.thumbW, self.thumbH, self.w, self.h, self.size, (int)[self.key length], (int)[self.iv length]];
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
            if (![Secret45__Environment serializeObject:object.phoneNumber data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.firstName data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.lastName data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.userId data:data addSignature:false])
                return false;
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaContact phone_number:%d first_name:%d last_name:%d user_id:%@)", (int)[self.phoneNumber length], (int)[self.firstName length], (int)[self.lastName length], self.userId];
}

@end

@implementation Secret45_DecryptedMessageMedia_decryptedMessageMediaVideo

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0x524a415d serializeBlock:^bool (Secret45_DecryptedMessageMedia_decryptedMessageMediaVideo *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.thumbW data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.thumbH data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.duration data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.mimeType data:data addSignature:false])
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
            return true;
        }];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaVideo thumb:%d thumb_w:%@ thumb_h:%@ duration:%@ mime_type:%d w:%@ h:%@ size:%@ key:%d iv:%d)", (int)[self.thumb length], self.thumbW, self.thumbH, self.duration, (int)[self.mimeType length], self.w, self.h, self.size, (int)[self.key length], (int)[self.iv length]];
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
            if (![Secret45__Environment serializeObject:object.mimeType data:data addSignature:false])
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
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaAudio duration:%@ mime_type:%d size:%@ key:%d iv:%d)", self.duration, (int)[self.mimeType length], self.size, (int)[self.key length], (int)[self.iv length]];
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
            if (![Secret45__Environment serializeObject:object.accessHash data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.date data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.mimeType data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.thumb data:data addSignature:true])
                return false;
            if (![Secret45__Environment serializeObject:object.dcId data:data addSignature:false])
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
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaExternalDocument id:%@ access_hash:%@ date:%@ mime_type:%d size:%@ thumb:%@ dc_id:%@ attributes:%@)", self.pid, self.accessHash, self.date, (int)[self.mimeType length], self.size, self.thumb, self.dcId, self.attributes];
}

@end

@implementation Secret45_DecryptedMessageMedia_decryptedMessageMediaDocument

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [Secret45__Serializer addSerializerToObject:self withConstructorSignature:0xfee613da serializeBlock:^bool (Secret45_DecryptedMessageMedia_decryptedMessageMediaDocument *object, NSMutableData *data)
        {
            if (![Secret45__Environment serializeObject:object.thumb data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.thumbW data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.thumbH data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.mimeType data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.size data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.key data:data addSignature:false])
                return false;
            if (![Secret45__Environment serializeObject:object.iv data:data addSignature:false])
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
    return [[NSString alloc] initWithFormat:@"(decryptedMessageMediaDocument thumb:%d thumb_w:%@ thumb_h:%@ mime_type:%d size:%@ key:%d iv:%d attributes:%@)", (int)[self.thumb length], self.thumbW, self.thumbH, (int)[self.mimeType length], self.size, (int)[self.key length], (int)[self.iv length], self.attributes];
}

@end




@implementation Secret45: NSObject

@end
