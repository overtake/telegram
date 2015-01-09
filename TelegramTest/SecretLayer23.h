/*
 * Layer 23
 */

@class Secret23_DecryptedMessageAction;
@class Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL;
@class Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages;
@class Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages;
@class Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages;
@class Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory;
@class Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer;
@class Secret23_DecryptedMessageAction_decryptedMessageActionTyping;
@class Secret23_DecryptedMessageAction_decryptedMessageActionResend;
@class Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey;
@class Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey;
@class Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey;
@class Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey;
@class Secret23_DecryptedMessageAction_decryptedMessageActionNoop;

@class Secret23_SendMessageAction;
@class Secret23_SendMessageAction_sendMessageTypingAction;
@class Secret23_SendMessageAction_sendMessageCancelAction;
@class Secret23_SendMessageAction_sendMessageRecordVideoAction;
@class Secret23_SendMessageAction_sendMessageUploadVideoAction;
@class Secret23_SendMessageAction_sendMessageRecordAudioAction;
@class Secret23_SendMessageAction_sendMessageUploadAudioAction;
@class Secret23_SendMessageAction_sendMessageUploadPhotoAction;
@class Secret23_SendMessageAction_sendMessageUploadDocumentAction;
@class Secret23_SendMessageAction_sendMessageGeoLocationAction;
@class Secret23_SendMessageAction_sendMessageChooseContactAction;

@class Secret23_PhotoSize;
@class Secret23_PhotoSize_photoSizeEmpty;
@class Secret23_PhotoSize_photoSize;
@class Secret23_PhotoSize_photoCachedSize;

@class Secret23_FileLocation;
@class Secret23_FileLocation_fileLocationUnavailable;
@class Secret23_FileLocation_fileLocation;

@class Secret23_DecryptedMessageLayer;
@class Secret23_DecryptedMessageLayer_decryptedMessageLayer;

@class Secret23_DecryptedMessage;
@class Secret23_DecryptedMessage_decryptedMessage;
@class Secret23_DecryptedMessage_decryptedMessageService;

@class Secret23_DocumentAttribute;
@class Secret23_DocumentAttribute_documentAttributeImageSize;
@class Secret23_DocumentAttribute_documentAttributeAnimated;
@class Secret23_DocumentAttribute_documentAttributeSticker;
@class Secret23_DocumentAttribute_documentAttributeVideo;
@class Secret23_DocumentAttribute_documentAttributeAudio;
@class Secret23_DocumentAttribute_documentAttributeFilename;

@class Secret23_DecryptedMessageMedia;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaContact;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument;


@interface Secret23__Environment : NSObject

+ (NSData *)serializeObject:(id)object;
+ (id)parseObject:(NSData *)data;

@end

/*
 * Types 23
 */

@interface Secret23_DecryptedMessageAction : NSObject

+ (Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtl_seconds:(NSNumber *)ttl_seconds;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandom_ids:(NSArray *)random_ids;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandom_ids:(NSArray *)random_ids;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandom_ids:(NSArray *)random_ids;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionTyping *)decryptedMessageActionTypingWithAction:(Secret23_SendMessageAction *)action;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionResend *)decryptedMessageActionResendWithStart_seq_no:(NSNumber *)start_seq_no end_seq_no:(NSNumber *)end_seq_no;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey *)decryptedMessageActionRequestKeyWithExchange_id:(NSNumber *)exchange_id g_a:(NSData *)g_a;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey *)decryptedMessageActionAcceptKeyWithExchange_id:(NSNumber *)exchange_id g_b:(NSData *)g_b key_fingerprint:(NSNumber *)key_fingerprint;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey *)decryptedMessageActionCommitKeyWithExchange_id:(NSNumber *)exchange_id key_fingerprint:(NSNumber *)key_fingerprint;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey *)decryptedMessageActionAbortKeyWithExchange_id:(NSNumber *)exchange_id;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionNoop *)decryptedMessageActionNoop;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * ttl_seconds;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory : Secret23_DecryptedMessageAction

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * layer;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionTyping : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) Secret23_SendMessageAction * action;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionResend : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * start_seq_no;
@property (nonatomic, strong, readonly) NSNumber * end_seq_no;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchange_id;
@property (nonatomic, strong, readonly) NSData * g_a;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchange_id;
@property (nonatomic, strong, readonly) NSData * g_b;
@property (nonatomic, strong, readonly) NSNumber * key_fingerprint;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchange_id;
@property (nonatomic, strong, readonly) NSNumber * key_fingerprint;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchange_id;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionNoop : Secret23_DecryptedMessageAction

@end


@interface Secret23_SendMessageAction : NSObject

+ (Secret23_SendMessageAction_sendMessageTypingAction *)sendMessageTypingAction;
+ (Secret23_SendMessageAction_sendMessageCancelAction *)sendMessageCancelAction;
+ (Secret23_SendMessageAction_sendMessageRecordVideoAction *)sendMessageRecordVideoAction;
+ (Secret23_SendMessageAction_sendMessageUploadVideoAction *)sendMessageUploadVideoAction;
+ (Secret23_SendMessageAction_sendMessageRecordAudioAction *)sendMessageRecordAudioAction;
+ (Secret23_SendMessageAction_sendMessageUploadAudioAction *)sendMessageUploadAudioAction;
+ (Secret23_SendMessageAction_sendMessageUploadPhotoAction *)sendMessageUploadPhotoAction;
+ (Secret23_SendMessageAction_sendMessageUploadDocumentAction *)sendMessageUploadDocumentAction;
+ (Secret23_SendMessageAction_sendMessageGeoLocationAction *)sendMessageGeoLocationAction;
+ (Secret23_SendMessageAction_sendMessageChooseContactAction *)sendMessageChooseContactAction;

@end

@interface Secret23_SendMessageAction_sendMessageTypingAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageCancelAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageRecordVideoAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageUploadVideoAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageRecordAudioAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageUploadAudioAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageUploadPhotoAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageUploadDocumentAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageGeoLocationAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageChooseContactAction : Secret23_SendMessageAction

@end


@interface Secret23_PhotoSize : NSObject

@property (nonatomic, strong, readonly) NSString * type;

+ (Secret23_PhotoSize_photoSizeEmpty *)photoSizeEmptyWithType:(NSString *)type;
+ (Secret23_PhotoSize_photoSize *)photoSizeWithType:(NSString *)type location:(Secret23_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size;
+ (Secret23_PhotoSize_photoCachedSize *)photoCachedSizeWithType:(NSString *)type location:(Secret23_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h bytes:(NSData *)bytes;

@end

@interface Secret23_PhotoSize_photoSizeEmpty : Secret23_PhotoSize

@end

@interface Secret23_PhotoSize_photoSize : Secret23_PhotoSize

@property (nonatomic, strong, readonly) Secret23_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;

@end

@interface Secret23_PhotoSize_photoCachedSize : Secret23_PhotoSize

@property (nonatomic, strong, readonly) Secret23_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSData * bytes;

@end


@interface Secret23_FileLocation : NSObject

@property (nonatomic, strong, readonly) NSNumber * volume_id;
@property (nonatomic, strong, readonly) NSNumber * local_id;
@property (nonatomic, strong, readonly) NSNumber * secret;

+ (Secret23_FileLocation_fileLocationUnavailable *)fileLocationUnavailableWithVolume_id:(NSNumber *)volume_id local_id:(NSNumber *)local_id secret:(NSNumber *)secret;
+ (Secret23_FileLocation_fileLocation *)fileLocationWithDc_id:(NSNumber *)dc_id volume_id:(NSNumber *)volume_id local_id:(NSNumber *)local_id secret:(NSNumber *)secret;

@end

@interface Secret23_FileLocation_fileLocationUnavailable : Secret23_FileLocation

@end

@interface Secret23_FileLocation_fileLocation : Secret23_FileLocation

@property (nonatomic, strong, readonly) NSNumber * dc_id;

@end


@interface Secret23_DecryptedMessageLayer : NSObject

@property (nonatomic, strong, readonly) NSData * random_bytes;
@property (nonatomic, strong, readonly) NSNumber * layer;
@property (nonatomic, strong, readonly) NSNumber * in_seq_no;
@property (nonatomic, strong, readonly) NSNumber * out_seq_no;
@property (nonatomic, strong, readonly) Secret23_DecryptedMessage * message;

+ (Secret23_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithRandom_bytes:(NSData *)random_bytes layer:(NSNumber *)layer in_seq_no:(NSNumber *)in_seq_no out_seq_no:(NSNumber *)out_seq_no message:(Secret23_DecryptedMessage *)message;

@end

@interface Secret23_DecryptedMessageLayer_decryptedMessageLayer : Secret23_DecryptedMessageLayer

@end


@interface Secret23_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * random_id;

+ (Secret23_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandom_id:(NSNumber *)random_id ttl:(NSNumber *)ttl message:(NSString *)message media:(Secret23_DecryptedMessageMedia *)media;
+ (Secret23_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandom_id:(NSNumber *)random_id action:(Secret23_DecryptedMessageAction *)action;

@end

@interface Secret23_DecryptedMessage_decryptedMessage : Secret23_DecryptedMessage

@property (nonatomic, strong, readonly) NSNumber * ttl;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) Secret23_DecryptedMessageMedia * media;

@end

@interface Secret23_DecryptedMessage_decryptedMessageService : Secret23_DecryptedMessage

@property (nonatomic, strong, readonly) Secret23_DecryptedMessageAction * action;

@end


@interface Secret23_DocumentAttribute : NSObject

+ (Secret23_DocumentAttribute_documentAttributeImageSize *)documentAttributeImageSizeWithW:(NSNumber *)w h:(NSNumber *)h;
+ (Secret23_DocumentAttribute_documentAttributeAnimated *)documentAttributeAnimated;
+ (Secret23_DocumentAttribute_documentAttributeSticker *)documentAttributeSticker;
+ (Secret23_DocumentAttribute_documentAttributeVideo *)documentAttributeVideoWithDuration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h;
+ (Secret23_DocumentAttribute_documentAttributeAudio *)documentAttributeAudioWithDuration:(NSNumber *)duration;
+ (Secret23_DocumentAttribute_documentAttributeFilename *)documentAttributeFilenameWithFile_name:(NSString *)file_name;

@end

@interface Secret23_DocumentAttribute_documentAttributeImageSize : Secret23_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end

@interface Secret23_DocumentAttribute_documentAttributeAnimated : Secret23_DocumentAttribute

@end

@interface Secret23_DocumentAttribute_documentAttributeSticker : Secret23_DocumentAttribute

@end

@interface Secret23_DocumentAttribute_documentAttributeVideo : Secret23_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end

@interface Secret23_DocumentAttribute_documentAttributeAudio : Secret23_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * duration;

@end

@interface Secret23_DocumentAttribute_documentAttributeFilename : Secret23_DocumentAttribute

@property (nonatomic, strong, readonly) NSString * file_name;

@end


@interface Secret23_DecryptedMessageMedia : NSObject

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty;
+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(NSNumber *)user_id;
+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h duration:(NSNumber *)duration mime_type:(NSString *)mime_type w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)decryptedMessageMediaExternalDocumentWithPid:(NSNumber *)pid access_hash:(NSNumber *)access_hash date:(NSNumber *)date mime_type:(NSString *)mime_type size:(NSNumber *)size thumb:(Secret23_PhotoSize *)thumb dc_id:(NSNumber *)dc_id attributes:(NSArray *)attributes;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty : Secret23_DecryptedMessageMedia

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto : Secret23_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint : Secret23_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaContact : Secret23_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * phone_number;
@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;
@property (nonatomic, strong, readonly) NSNumber * user_id;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument : Secret23_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSString * file_name;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo : Secret23_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio : Secret23_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument : Secret23_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * access_hash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) Secret23_PhotoSize * thumb;
@property (nonatomic, strong, readonly) NSNumber * dc_id;
@property (nonatomic, strong, readonly) NSArray * attributes;

@end


/*
 * Functions 23
 */

