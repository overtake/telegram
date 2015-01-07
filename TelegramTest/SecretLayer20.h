/*
 * Layer 20
 */

@class Secret20_DecryptedMessageAction;
@class Secret20_DecryptedMessageAction_decryptedMessageActionSetMessageTTL;
@class Secret20_DecryptedMessageAction_decryptedMessageActionReadMessages;
@class Secret20_DecryptedMessageAction_decryptedMessageActionDeleteMessages;
@class Secret20_DecryptedMessageAction_decryptedMessageActionScreenshotMessages;
@class Secret20_DecryptedMessageAction_decryptedMessageActionFlushHistory;
@class Secret20_DecryptedMessageAction_decryptedMessageActionNotifyLayer;
@class Secret20_DecryptedMessageAction_decryptedMessageActionTyping;
@class Secret20_DecryptedMessageAction_decryptedMessageActionResend;
@class Secret20_DecryptedMessageAction_decryptedMessageActionRequestKey;
@class Secret20_DecryptedMessageAction_decryptedMessageActionAcceptKey;
@class Secret20_DecryptedMessageAction_decryptedMessageActionCommitKey;
@class Secret20_DecryptedMessageAction_decryptedMessageActionAbortKey;
@class Secret20_DecryptedMessageAction_decryptedMessageActionNoop;

@class Secret20_SendMessageAction;
@class Secret20_SendMessageAction_sendMessageTypingAction;
@class Secret20_SendMessageAction_sendMessageCancelAction;
@class Secret20_SendMessageAction_sendMessageRecordVideoAction;
@class Secret20_SendMessageAction_sendMessageUploadVideoAction;
@class Secret20_SendMessageAction_sendMessageRecordAudioAction;
@class Secret20_SendMessageAction_sendMessageUploadAudioAction;
@class Secret20_SendMessageAction_sendMessageUploadPhotoAction;
@class Secret20_SendMessageAction_sendMessageUploadDocumentAction;
@class Secret20_SendMessageAction_sendMessageGeoLocationAction;
@class Secret20_SendMessageAction_sendMessageChooseContactAction;

@class Secret20_DecryptedMessageLayer;
@class Secret20_DecryptedMessageLayer_decryptedMessageLayer;

@class Secret20_DecryptedMessage;
@class Secret20_DecryptedMessage_decryptedMessage;
@class Secret20_DecryptedMessage_decryptedMessageService;

@class Secret20_DecryptedMessageMedia;
@class Secret20_DecryptedMessageMedia_decryptedMessageMediaEmpty;
@class Secret20_DecryptedMessageMedia_decryptedMessageMediaPhoto;
@class Secret20_DecryptedMessageMedia_decryptedMessageMediaGeoPoint;
@class Secret20_DecryptedMessageMedia_decryptedMessageMediaContact;
@class Secret20_DecryptedMessageMedia_decryptedMessageMediaDocument;
@class Secret20_DecryptedMessageMedia_decryptedMessageMediaVideo;
@class Secret20_DecryptedMessageMedia_decryptedMessageMediaAudio;


@interface Secret20__Environment : NSObject

+ (NSData *)serializeObject:(id)object;
+ (id)parseObject:(NSData *)data;

@end

/*
 * Types 20
 */

@interface Secret20_DecryptedMessageAction : NSObject

+ (Secret20_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtl_seconds:(NSNumber *)ttl_seconds;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandom_ids:(NSArray *)random_ids;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandom_ids:(NSArray *)random_ids;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandom_ids:(NSArray *)random_ids;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionTyping *)decryptedMessageActionTypingWithAction:(Secret20_SendMessageAction *)action;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionResend *)decryptedMessageActionResendWithStart_seq_no:(NSNumber *)start_seq_no end_seq_no:(NSNumber *)end_seq_no;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionRequestKey *)decryptedMessageActionRequestKeyWithExchange_id:(NSNumber *)exchange_id g_a:(NSData *)g_a;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionAcceptKey *)decryptedMessageActionAcceptKeyWithExchange_id:(NSNumber *)exchange_id g_b:(NSData *)g_b key_fingerprint:(NSNumber *)key_fingerprint;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionCommitKey *)decryptedMessageActionCommitKeyWithExchange_id:(NSNumber *)exchange_id key_fingerprint:(NSNumber *)key_fingerprint;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionAbortKey *)decryptedMessageActionAbortKeyWithExchange_id:(NSNumber *)exchange_id;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionNoop *)decryptedMessageActionNoop;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * ttl_seconds;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionReadMessages : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionDeleteMessages : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionScreenshotMessages : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionFlushHistory : Secret20_DecryptedMessageAction

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionNotifyLayer : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * layer;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionTyping : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) Secret20_SendMessageAction * action;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionResend : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * start_seq_no;
@property (nonatomic, strong, readonly) NSNumber * end_seq_no;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionRequestKey : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchange_id;
@property (nonatomic, strong, readonly) NSData * g_a;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionAcceptKey : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchange_id;
@property (nonatomic, strong, readonly) NSData * g_b;
@property (nonatomic, strong, readonly) NSNumber * key_fingerprint;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionCommitKey : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchange_id;
@property (nonatomic, strong, readonly) NSNumber * key_fingerprint;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionAbortKey : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchange_id;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionNoop : Secret20_DecryptedMessageAction

@end


@interface Secret20_SendMessageAction : NSObject

+ (Secret20_SendMessageAction_sendMessageTypingAction *)sendMessageTypingAction;
+ (Secret20_SendMessageAction_sendMessageCancelAction *)sendMessageCancelAction;
+ (Secret20_SendMessageAction_sendMessageRecordVideoAction *)sendMessageRecordVideoAction;
+ (Secret20_SendMessageAction_sendMessageUploadVideoAction *)sendMessageUploadVideoAction;
+ (Secret20_SendMessageAction_sendMessageRecordAudioAction *)sendMessageRecordAudioAction;
+ (Secret20_SendMessageAction_sendMessageUploadAudioAction *)sendMessageUploadAudioAction;
+ (Secret20_SendMessageAction_sendMessageUploadPhotoAction *)sendMessageUploadPhotoAction;
+ (Secret20_SendMessageAction_sendMessageUploadDocumentAction *)sendMessageUploadDocumentAction;
+ (Secret20_SendMessageAction_sendMessageGeoLocationAction *)sendMessageGeoLocationAction;
+ (Secret20_SendMessageAction_sendMessageChooseContactAction *)sendMessageChooseContactAction;

@end

@interface Secret20_SendMessageAction_sendMessageTypingAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageCancelAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageRecordVideoAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageUploadVideoAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageRecordAudioAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageUploadAudioAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageUploadPhotoAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageUploadDocumentAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageGeoLocationAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageChooseContactAction : Secret20_SendMessageAction

@end


@interface Secret20_DecryptedMessageLayer : NSObject

@property (nonatomic, strong, readonly) NSData * random_bytes;
@property (nonatomic, strong, readonly) NSNumber * layer;
@property (nonatomic, strong, readonly) NSNumber * in_seq_no;
@property (nonatomic, strong, readonly) NSNumber * out_seq_no;
@property (nonatomic, strong, readonly) Secret20_DecryptedMessage * message;

+ (Secret20_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithRandom_bytes:(NSData *)random_bytes layer:(NSNumber *)layer in_seq_no:(NSNumber *)in_seq_no out_seq_no:(NSNumber *)out_seq_no message:(Secret20_DecryptedMessage *)message;

@end

@interface Secret20_DecryptedMessageLayer_decryptedMessageLayer : Secret20_DecryptedMessageLayer

@end


@interface Secret20_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * random_id;

+ (Secret20_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandom_id:(NSNumber *)random_id ttl:(NSNumber *)ttl message:(NSString *)message media:(Secret20_DecryptedMessageMedia *)media;
+ (Secret20_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandom_id:(NSNumber *)random_id action:(Secret20_DecryptedMessageAction *)action;

@end

@interface Secret20_DecryptedMessage_decryptedMessage : Secret20_DecryptedMessage

@property (nonatomic, strong, readonly) NSNumber * ttl;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) Secret20_DecryptedMessageMedia * media;

@end

@interface Secret20_DecryptedMessage_decryptedMessageService : Secret20_DecryptedMessage

@property (nonatomic, strong, readonly) Secret20_DecryptedMessageAction * action;

@end


@interface Secret20_DecryptedMessageMedia : NSObject

+ (Secret20_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty;
+ (Secret20_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret20_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (Secret20_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(NSNumber *)user_id;
+ (Secret20_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret20_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h duration:(NSNumber *)duration mime_type:(NSString *)mime_type w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret20_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;

@end

@interface Secret20_DecryptedMessageMedia_decryptedMessageMediaEmpty : Secret20_DecryptedMessageMedia

@end

@interface Secret20_DecryptedMessageMedia_decryptedMessageMediaPhoto : Secret20_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret20_DecryptedMessageMedia_decryptedMessageMediaGeoPoint : Secret20_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end

@interface Secret20_DecryptedMessageMedia_decryptedMessageMediaContact : Secret20_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * phone_number;
@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;
@property (nonatomic, strong, readonly) NSNumber * user_id;

@end

@interface Secret20_DecryptedMessageMedia_decryptedMessageMediaDocument : Secret20_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSString * file_name;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret20_DecryptedMessageMedia_decryptedMessageMediaVideo : Secret20_DecryptedMessageMedia

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

@interface Secret20_DecryptedMessageMedia_decryptedMessageMediaAudio : Secret20_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end


/*
 * Functions 20
 */

