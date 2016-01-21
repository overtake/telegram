#import <Foundation/Foundation.h>

/*
 * Layer 45
 */

@class Secret45_DecryptedMessageAction;
@class Secret45_DecryptedMessageAction_decryptedMessageActionSetMessageTTL;
@class Secret45_DecryptedMessageAction_decryptedMessageActionReadMessages;
@class Secret45_DecryptedMessageAction_decryptedMessageActionDeleteMessages;
@class Secret45_DecryptedMessageAction_decryptedMessageActionScreenshotMessages;
@class Secret45_DecryptedMessageAction_decryptedMessageActionFlushHistory;
@class Secret45_DecryptedMessageAction_decryptedMessageActionNotifyLayer;
@class Secret45_DecryptedMessageAction_decryptedMessageActionTyping;
@class Secret45_DecryptedMessageAction_decryptedMessageActionResend;
@class Secret45_DecryptedMessageAction_decryptedMessageActionRequestKey;
@class Secret45_DecryptedMessageAction_decryptedMessageActionAcceptKey;
@class Secret45_DecryptedMessageAction_decryptedMessageActionCommitKey;
@class Secret45_DecryptedMessageAction_decryptedMessageActionAbortKey;
@class Secret45_DecryptedMessageAction_decryptedMessageActionNoop;

@class Secret45_SendMessageAction;
@class Secret45_SendMessageAction_sendMessageTypingAction;
@class Secret45_SendMessageAction_sendMessageCancelAction;
@class Secret45_SendMessageAction_sendMessageRecordVideoAction;
@class Secret45_SendMessageAction_sendMessageUploadVideoAction;
@class Secret45_SendMessageAction_sendMessageRecordAudioAction;
@class Secret45_SendMessageAction_sendMessageUploadAudioAction;
@class Secret45_SendMessageAction_sendMessageUploadPhotoAction;
@class Secret45_SendMessageAction_sendMessageUploadDocumentAction;
@class Secret45_SendMessageAction_sendMessageGeoLocationAction;
@class Secret45_SendMessageAction_sendMessageChooseContactAction;

@class Secret45_PhotoSize;
@class Secret45_PhotoSize_photoSizeEmpty;
@class Secret45_PhotoSize_photoSize;
@class Secret45_PhotoSize_photoCachedSize;

@class Secret45_FileLocation;
@class Secret45_FileLocation_fileLocationUnavailable;
@class Secret45_FileLocation_fileLocation;

@class Secret45_DecryptedMessageLayer;
@class Secret45_DecryptedMessageLayer_decryptedMessageLayer;

@class Secret45_DecryptedMessage;
@class Secret45_DecryptedMessage_decryptedMessageService;
@class Secret45_DecryptedMessage_decryptedMessage;

@class Secret45_DocumentAttribute;
@class Secret45_DocumentAttribute_documentAttributeImageSize;
@class Secret45_DocumentAttribute_documentAttributeAnimated;
@class Secret45_DocumentAttribute_documentAttributeVideo;
@class Secret45_DocumentAttribute_documentAttributeFilename;
@class Secret45_DocumentAttribute_documentAttributeSticker;
@class Secret45_DocumentAttribute_documentAttributeAudio;

@class Secret45_InputStickerSet;
@class Secret45_InputStickerSet_inputStickerSetShortName;
@class Secret45_InputStickerSet_inputStickerSetEmpty;

@class Secret45_MessageEntity;
@class Secret45_MessageEntity_messageEntityUnknown;
@class Secret45_MessageEntity_messageEntityMention;
@class Secret45_MessageEntity_messageEntityHashtag;
@class Secret45_MessageEntity_messageEntityBotCommand;
@class Secret45_MessageEntity_messageEntityUrl;
@class Secret45_MessageEntity_messageEntityEmail;
@class Secret45_MessageEntity_messageEntityBold;
@class Secret45_MessageEntity_messageEntityItalic;
@class Secret45_MessageEntity_messageEntityCode;
@class Secret45_MessageEntity_messageEntityPre;
@class Secret45_MessageEntity_messageEntityTextUrl;

@class Secret45_DecryptedMessageMedia;
@class Secret45_DecryptedMessageMedia_decryptedMessageMediaEmpty;
@class Secret45_DecryptedMessageMedia_decryptedMessageMediaPhoto;
@class Secret45_DecryptedMessageMedia_decryptedMessageMediaGeoPoint;
@class Secret45_DecryptedMessageMedia_decryptedMessageMediaContact;
@class Secret45_DecryptedMessageMedia_decryptedMessageMediaVideo;
@class Secret45_DecryptedMessageMedia_decryptedMessageMediaAudio;
@class Secret45_DecryptedMessageMedia_decryptedMessageMediaExternalDocument;
@class Secret45_DecryptedMessageMedia_decryptedMessageMediaDocument;


@interface Secret45__Environment : NSObject

+ (NSData *)serializeObject:(id)object;
+ (id)parseObject:(NSData *)data;

@end

@interface Secret45_FunctionContext : NSObject

@property (nonatomic, strong, readonly) NSData *payload;
@property (nonatomic, copy, readonly) id (^responseParser)(NSData *);
@property (nonatomic, strong, readonly) id metadata;

- (instancetype)initWithPayload:(NSData *)payload responseParser:(id (^)(NSData *))responseParser metadata:(id)metadata;

@end

/*
 * Types 45
 */

@interface Secret45_DecryptedMessageAction : NSObject

+ (Secret45_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtlSeconds:(NSNumber *)ttlSeconds;
+ (Secret45_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret45_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret45_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret45_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory;
+ (Secret45_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer;
+ (Secret45_DecryptedMessageAction_decryptedMessageActionTyping *)decryptedMessageActionTypingWithAction:(Secret45_SendMessageAction *)action;
+ (Secret45_DecryptedMessageAction_decryptedMessageActionResend *)decryptedMessageActionResendWithStartSeqNo:(NSNumber *)startSeqNo endSeqNo:(NSNumber *)endSeqNo;
+ (Secret45_DecryptedMessageAction_decryptedMessageActionRequestKey *)decryptedMessageActionRequestKeyWithExchangeId:(NSNumber *)exchangeId gA:(NSData *)gA;
+ (Secret45_DecryptedMessageAction_decryptedMessageActionAcceptKey *)decryptedMessageActionAcceptKeyWithExchangeId:(NSNumber *)exchangeId gB:(NSData *)gB keyFingerprint:(NSNumber *)keyFingerprint;
+ (Secret45_DecryptedMessageAction_decryptedMessageActionCommitKey *)decryptedMessageActionCommitKeyWithExchangeId:(NSNumber *)exchangeId keyFingerprint:(NSNumber *)keyFingerprint;
+ (Secret45_DecryptedMessageAction_decryptedMessageActionAbortKey *)decryptedMessageActionAbortKeyWithExchangeId:(NSNumber *)exchangeId;
+ (Secret45_DecryptedMessageAction_decryptedMessageActionNoop *)decryptedMessageActionNoop;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : Secret45_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * ttlSeconds;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionReadMessages : Secret45_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionDeleteMessages : Secret45_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionScreenshotMessages : Secret45_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionFlushHistory : Secret45_DecryptedMessageAction

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionNotifyLayer : Secret45_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * layer;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionTyping : Secret45_DecryptedMessageAction

@property (nonatomic, strong, readonly) Secret45_SendMessageAction * action;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionResend : Secret45_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * startSeqNo;
@property (nonatomic, strong, readonly) NSNumber * endSeqNo;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionRequestKey : Secret45_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSData * gA;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionAcceptKey : Secret45_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSData * gB;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionCommitKey : Secret45_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionAbortKey : Secret45_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;

@end

@interface Secret45_DecryptedMessageAction_decryptedMessageActionNoop : Secret45_DecryptedMessageAction

@end


@interface Secret45_SendMessageAction : NSObject

+ (Secret45_SendMessageAction_sendMessageTypingAction *)sendMessageTypingAction;
+ (Secret45_SendMessageAction_sendMessageCancelAction *)sendMessageCancelAction;
+ (Secret45_SendMessageAction_sendMessageRecordVideoAction *)sendMessageRecordVideoAction;
+ (Secret45_SendMessageAction_sendMessageUploadVideoAction *)sendMessageUploadVideoAction;
+ (Secret45_SendMessageAction_sendMessageRecordAudioAction *)sendMessageRecordAudioAction;
+ (Secret45_SendMessageAction_sendMessageUploadAudioAction *)sendMessageUploadAudioAction;
+ (Secret45_SendMessageAction_sendMessageUploadPhotoAction *)sendMessageUploadPhotoAction;
+ (Secret45_SendMessageAction_sendMessageUploadDocumentAction *)sendMessageUploadDocumentAction;
+ (Secret45_SendMessageAction_sendMessageGeoLocationAction *)sendMessageGeoLocationAction;
+ (Secret45_SendMessageAction_sendMessageChooseContactAction *)sendMessageChooseContactAction;

@end

@interface Secret45_SendMessageAction_sendMessageTypingAction : Secret45_SendMessageAction

@end

@interface Secret45_SendMessageAction_sendMessageCancelAction : Secret45_SendMessageAction

@end

@interface Secret45_SendMessageAction_sendMessageRecordVideoAction : Secret45_SendMessageAction

@end

@interface Secret45_SendMessageAction_sendMessageUploadVideoAction : Secret45_SendMessageAction

@end

@interface Secret45_SendMessageAction_sendMessageRecordAudioAction : Secret45_SendMessageAction

@end

@interface Secret45_SendMessageAction_sendMessageUploadAudioAction : Secret45_SendMessageAction

@end

@interface Secret45_SendMessageAction_sendMessageUploadPhotoAction : Secret45_SendMessageAction

@end

@interface Secret45_SendMessageAction_sendMessageUploadDocumentAction : Secret45_SendMessageAction

@end

@interface Secret45_SendMessageAction_sendMessageGeoLocationAction : Secret45_SendMessageAction

@end

@interface Secret45_SendMessageAction_sendMessageChooseContactAction : Secret45_SendMessageAction

@end


@interface Secret45_PhotoSize : NSObject

@property (nonatomic, strong, readonly) NSString * type;

+ (Secret45_PhotoSize_photoSizeEmpty *)photoSizeEmptyWithType:(NSString *)type;
+ (Secret45_PhotoSize_photoSize *)photoSizeWithType:(NSString *)type location:(Secret45_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size;
+ (Secret45_PhotoSize_photoCachedSize *)photoCachedSizeWithType:(NSString *)type location:(Secret45_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h bytes:(NSData *)bytes;

@end

@interface Secret45_PhotoSize_photoSizeEmpty : Secret45_PhotoSize

@end

@interface Secret45_PhotoSize_photoSize : Secret45_PhotoSize

@property (nonatomic, strong, readonly) Secret45_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;

@end

@interface Secret45_PhotoSize_photoCachedSize : Secret45_PhotoSize

@property (nonatomic, strong, readonly) Secret45_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSData * bytes;

@end


@interface Secret45_FileLocation : NSObject

@property (nonatomic, strong, readonly) NSNumber * volumeId;
@property (nonatomic, strong, readonly) NSNumber * localId;
@property (nonatomic, strong, readonly) NSNumber * secret;

+ (Secret45_FileLocation_fileLocationUnavailable *)fileLocationUnavailableWithVolumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret;
+ (Secret45_FileLocation_fileLocation *)fileLocationWithDcId:(NSNumber *)dcId volumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret;

@end

@interface Secret45_FileLocation_fileLocationUnavailable : Secret45_FileLocation

@end

@interface Secret45_FileLocation_fileLocation : Secret45_FileLocation

@property (nonatomic, strong, readonly) NSNumber * dcId;

@end


@interface Secret45_DecryptedMessageLayer : NSObject

@property (nonatomic, strong, readonly) NSData * randomBytes;
@property (nonatomic, strong, readonly) NSNumber * layer;
@property (nonatomic, strong, readonly) NSNumber * inSeqNo;
@property (nonatomic, strong, readonly) NSNumber * outSeqNo;
@property (nonatomic, strong, readonly) Secret45_DecryptedMessage * message;

+ (Secret45_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithRandomBytes:(NSData *)randomBytes layer:(NSNumber *)layer inSeqNo:(NSNumber *)inSeqNo outSeqNo:(NSNumber *)outSeqNo message:(Secret45_DecryptedMessage *)message;

@end

@interface Secret45_DecryptedMessageLayer_decryptedMessageLayer : Secret45_DecryptedMessageLayer

@end


@interface Secret45_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * randomId;

+ (Secret45_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandomId:(NSNumber *)randomId action:(Secret45_DecryptedMessageAction *)action;
+ (Secret45_DecryptedMessage_decryptedMessage *)decryptedMessageWithFlags:(NSNumber *)flags randomId:(NSNumber *)randomId ttl:(NSNumber *)ttl message:(NSString *)message media:(Secret45_DecryptedMessageMedia *)media entities:(NSArray *)entities viaBotName:(NSString *)viaBotName replyToRandomId:(NSNumber *)replyToRandomId;

@end

@interface Secret45_DecryptedMessage_decryptedMessageService : Secret45_DecryptedMessage

@property (nonatomic, strong, readonly) Secret45_DecryptedMessageAction * action;

@end

@interface Secret45_DecryptedMessage_decryptedMessage : Secret45_DecryptedMessage

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * ttl;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) Secret45_DecryptedMessageMedia * media;
@property (nonatomic, strong, readonly) NSArray * entities;
@property (nonatomic, strong, readonly) NSString * viaBotName;
@property (nonatomic, strong, readonly) NSNumber * replyToRandomId;

@end


@interface Secret45_DocumentAttribute : NSObject

+ (Secret45_DocumentAttribute_documentAttributeImageSize *)documentAttributeImageSizeWithW:(NSNumber *)w h:(NSNumber *)h;
+ (Secret45_DocumentAttribute_documentAttributeAnimated *)documentAttributeAnimated;
+ (Secret45_DocumentAttribute_documentAttributeVideo *)documentAttributeVideoWithDuration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h;
+ (Secret45_DocumentAttribute_documentAttributeFilename *)documentAttributeFilenameWithFileName:(NSString *)fileName;
+ (Secret45_DocumentAttribute_documentAttributeSticker *)documentAttributeStickerWithAlt:(NSString *)alt stickerset:(Secret45_InputStickerSet *)stickerset;
+ (Secret45_DocumentAttribute_documentAttributeAudio *)documentAttributeAudioWithDuration:(NSNumber *)duration title:(NSString *)title performer:(NSString *)performer;

@end

@interface Secret45_DocumentAttribute_documentAttributeImageSize : Secret45_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end

@interface Secret45_DocumentAttribute_documentAttributeAnimated : Secret45_DocumentAttribute

@end

@interface Secret45_DocumentAttribute_documentAttributeVideo : Secret45_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end

@interface Secret45_DocumentAttribute_documentAttributeFilename : Secret45_DocumentAttribute

@property (nonatomic, strong, readonly) NSString * fileName;

@end

@interface Secret45_DocumentAttribute_documentAttributeSticker : Secret45_DocumentAttribute

@property (nonatomic, strong, readonly) NSString * alt;
@property (nonatomic, strong, readonly) Secret45_InputStickerSet * stickerset;

@end

@interface Secret45_DocumentAttribute_documentAttributeAudio : Secret45_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSString * performer;

@end


@interface Secret45_InputStickerSet : NSObject

+ (Secret45_InputStickerSet_inputStickerSetShortName *)inputStickerSetShortNameWithShortName:(NSString *)shortName;
+ (Secret45_InputStickerSet_inputStickerSetEmpty *)inputStickerSetEmpty;

@end

@interface Secret45_InputStickerSet_inputStickerSetShortName : Secret45_InputStickerSet

@property (nonatomic, strong, readonly) NSString * shortName;

@end

@interface Secret45_InputStickerSet_inputStickerSetEmpty : Secret45_InputStickerSet

@end


@interface Secret45_MessageEntity : NSObject

@property (nonatomic, strong, readonly) NSNumber * offset;
@property (nonatomic, strong, readonly) NSNumber * length;

+ (Secret45_MessageEntity_messageEntityUnknown *)messageEntityUnknownWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret45_MessageEntity_messageEntityMention *)messageEntityMentionWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret45_MessageEntity_messageEntityHashtag *)messageEntityHashtagWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret45_MessageEntity_messageEntityBotCommand *)messageEntityBotCommandWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret45_MessageEntity_messageEntityUrl *)messageEntityUrlWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret45_MessageEntity_messageEntityEmail *)messageEntityEmailWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret45_MessageEntity_messageEntityBold *)messageEntityBoldWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret45_MessageEntity_messageEntityItalic *)messageEntityItalicWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret45_MessageEntity_messageEntityCode *)messageEntityCodeWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret45_MessageEntity_messageEntityPre *)messageEntityPreWithOffset:(NSNumber *)offset length:(NSNumber *)length language:(NSString *)language;
+ (Secret45_MessageEntity_messageEntityTextUrl *)messageEntityTextUrlWithOffset:(NSNumber *)offset length:(NSNumber *)length url:(NSString *)url;

@end

@interface Secret45_MessageEntity_messageEntityUnknown : Secret45_MessageEntity

@end

@interface Secret45_MessageEntity_messageEntityMention : Secret45_MessageEntity

@end

@interface Secret45_MessageEntity_messageEntityHashtag : Secret45_MessageEntity

@end

@interface Secret45_MessageEntity_messageEntityBotCommand : Secret45_MessageEntity

@end

@interface Secret45_MessageEntity_messageEntityUrl : Secret45_MessageEntity

@end

@interface Secret45_MessageEntity_messageEntityEmail : Secret45_MessageEntity

@end

@interface Secret45_MessageEntity_messageEntityBold : Secret45_MessageEntity

@end

@interface Secret45_MessageEntity_messageEntityItalic : Secret45_MessageEntity

@end

@interface Secret45_MessageEntity_messageEntityCode : Secret45_MessageEntity

@end

@interface Secret45_MessageEntity_messageEntityPre : Secret45_MessageEntity

@property (nonatomic, strong, readonly) NSString * language;

@end

@interface Secret45_MessageEntity_messageEntityTextUrl : Secret45_MessageEntity

@property (nonatomic, strong, readonly) NSString * url;

@end


@interface Secret45_DecryptedMessageMedia : NSObject

+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty;
+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhoneNumber:(NSString *)phoneNumber firstName:(NSString *)firstName lastName:(NSString *)lastName userId:(NSNumber *)userId;
+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH duration:(NSNumber *)duration mimeType:(NSString *)mimeType w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)decryptedMessageMediaExternalDocumentWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date mimeType:(NSString *)mimeType size:(NSNumber *)size thumb:(Secret45_PhotoSize *)thumb dcId:(NSNumber *)dcId attributes:(NSArray *)attributes;
+ (Secret45_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv attributes:(NSArray *)attributes;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaEmpty : Secret45_DecryptedMessageMedia

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaPhoto : Secret45_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumbW;
@property (nonatomic, strong, readonly) NSNumber * thumbH;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaGeoPoint : Secret45_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaContact : Secret45_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * phoneNumber;
@property (nonatomic, strong, readonly) NSString * firstName;
@property (nonatomic, strong, readonly) NSString * lastName;
@property (nonatomic, strong, readonly) NSNumber * userId;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaVideo : Secret45_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumbW;
@property (nonatomic, strong, readonly) NSNumber * thumbH;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaAudio : Secret45_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaExternalDocument : Secret45_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) Secret45_PhotoSize * thumb;
@property (nonatomic, strong, readonly) NSNumber * dcId;
@property (nonatomic, strong, readonly) NSArray * attributes;

@end

@interface Secret45_DecryptedMessageMedia_decryptedMessageMediaDocument : Secret45_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumbW;
@property (nonatomic, strong, readonly) NSNumber * thumbH;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;
@property (nonatomic, strong, readonly) NSArray * attributes;

@end


/*
 * Functions 45
 */

@interface Secret45: NSObject

@end
