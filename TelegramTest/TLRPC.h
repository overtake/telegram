//
//  TLRPC.h
//  Telegram
//
//  Auto created by Dmitry Kondratyev on 07.04.14.
//  Copyright (c) 2013 Telegram for OS X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLObject.h"
	
@class TGDecryptedMessageMedia;
	
@class TGInputPeer;
	
@class TGInputUser;
	
@class TGInputContact;
	
@class TGInputFile;
	
@class TGInputMedia;
	
@class TGInputChatPhoto;
	
@class TGInputGeoPoint;
	
@class TGInputPhoto;
	
@class TGInputVideo;
	
@class TGInputFileLocation;
	
@class TGInputPhotoCrop;
	
@class TGInputAppEvent;
	
@class TGPeer;
	
@class TGstorage_FileType;
	
@class TGFileLocation;
	
@class TGUser;
	
@class TGUserProfilePhoto;
	
@class TGUserStatus;
	
@class TGChat;
	
@class TGChatFull;
	
@class TGChatParticipant;
	
@class TGChatParticipants;
	
@class TGChatPhoto;
	
@class TGMessage;
	
@class TGMessageMedia;
	
@class TGMessageAction;
	
@class TGDialog;
	
@class TGPhoto;
	
@class TGPhotoSize;
	
@class TGVideo;
	
@class TGGeoPoint;
	
@class TGauth_CheckedPhone;
	
@class TGauth_SentCode;
	
@class TGauth_Authorization;
	
@class TGauth_ExportedAuthorization;
	
@class TGInputNotifyPeer;
	
@class TGInputPeerNotifyEvents;
	
@class TGInputPeerNotifySettings;
	
@class TGPeerNotifyEvents;
	
@class TGPeerNotifySettings;
	
@class TGWallPaper;
	
@class TGUserFull;
	
@class TGContact;
	
@class TGImportedContact;
	
@class TGContactBlocked;
	
@class TGContactFound;
	
@class TGContactSuggested;
	
@class TGContactStatus;
	
@class TGChatLocated;
	
@class TGcontacts_ForeignLink;
	
@class TGcontacts_MyLink;
	
@class TGcontacts_Link;
	
@class TGcontacts_Contacts;
	
@class TGcontacts_ImportedContacts;
	
@class TGcontacts_Blocked;
	
@class TGcontacts_Found;
	
@class TGcontacts_Suggested;
	
@class TGmessages_Dialogs;
	
@class TGmessages_Messages;
	
@class TGmessages_Message;
	
@class TGmessages_StatedMessages;
	
@class TGmessages_StatedMessage;
	
@class TGmessages_SentMessage;
	
@class TGmessages_Chat;
	
@class TGmessages_Chats;
	
@class TGmessages_ChatFull;
	
@class TGmessages_AffectedHistory;
	
@class TGMessagesFilter;
	
@class TGUpdate;
	
@class TGupdates_State;
	
@class TGupdates_Difference;
	
@class TGUpdates;
	
@class TGphotos_Photos;
	
@class TGphotos_Photo;
	
@class TGupload_File;
	
@class TGDcOption;
	
@class TGConfig;
	
@class TGNearestDc;
	
@class TGhelp_AppUpdate;
	
@class TGhelp_InviteText;
	
@class TGInputGeoChat;
	
@class TGGeoChatMessage;
	
@class TGgeochats_StatedMessage;
	
@class TGgeochats_Located;
	
@class TGgeochats_Messages;
	
@class TGEncryptedChat;
	
@class TGInputEncryptedChat;
	
@class TGEncryptedFile;
	
@class TGInputEncryptedFile;
	
@class TGEncryptedMessage;
	
@class TGDecryptedMessageLayer;
	
@class TGDecryptedMessage;
	
@class TGDecryptedMessageAction;
	
@class TGmessages_DhConfig;
	
@class TGmessages_SentEncryptedMessage;
	
@class TGInputAudio;
	
@class TGInputDocument;
	
@class TGAudio;
	
@class TGDocument;
	
@class TGhelp_Support;
	
@class TGNotifyPeer;
	
@class TGProtoMessage;
	
@class TGProtoMessageContainer;
	
@class TGResPQ;
	
@class TGServer_DH_inner_data;
	
@class TGP_Q_inner_data;
	
@class TGServer_DH_Params;
	
@class TGClient_DH_Inner_Data;
	
@class TGSet_client_DH_params_answer;
	
@class TGPong;
	
@class TGBadMsgNotification;
	
@class TGNewSession;
	
@class TGRpcResult;
	
@class TGRpcError;
	
@class TGRSAPublicKey;
	
@class TGMsgsAck;
	
@class TGRpcDropAnswer;
	
@class TGFutureSalts;
	
@class TGFutureSalt;
	
@class TGDestroySessionRes;
	
@class TGProtoMessageCopy;
	
@class TGObject;
	
@class TGHttpWait;
	
@class TGMsgsStateReq;
	
@class TGMsgsStateInfo;
	
@class TGMsgsAllInfo;
	
@class TGMsgDetailedInfo;
	
@class TGMsgResendReq;

@class TL_SendMessageAction;

	
@interface TGDecryptedMessageMedia : TLObject
@property (nonatomic) int duration;
@property (nonatomic) int size;
@property (nonatomic, strong) NSData *key;
@property (nonatomic, strong) NSData *iv;
@property (nonatomic, strong) NSData *thumb;
@property (nonatomic) int thumb_w;
@property (nonatomic) int thumb_h;
@property (nonatomic) int w;
@property (nonatomic) int h;
@property (nonatomic, strong) NSString *mime_type;
@property double lat;
@property double n_long;
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic) int user_id;
@property (nonatomic, strong) NSString *file_name;
@end

@interface TL_decryptedMessageMediaAudio_12 : TGDecryptedMessageMedia
+ (TL_decryptedMessageMediaAudio_12 *)createWithDuration:(int)duration size:(int)size key:(NSData *)key iv:(NSData *)iv;
@end
@interface TL_decryptedMessageMediaVideo_12 : TGDecryptedMessageMedia
+ (TL_decryptedMessageMediaVideo_12 *)createWithThumb:(NSData *)thumb thumb_w:(int)thumb_w thumb_h:(int)thumb_h duration:(int)duration w:(int)w h:(int)h size:(int)size key:(NSData *)key iv:(NSData *)iv;
@end
@interface TL_decryptedMessageMediaEmpty : TGDecryptedMessageMedia
+ (TL_decryptedMessageMediaEmpty *)create;
@end
@interface TL_decryptedMessageMediaPhoto : TGDecryptedMessageMedia
+ (TL_decryptedMessageMediaPhoto *)createWithThumb:(NSData *)thumb thumb_w:(int)thumb_w thumb_h:(int)thumb_h w:(int)w h:(int)h size:(int)size key:(NSData *)key iv:(NSData *)iv;
@end
@interface TL_decryptedMessageMediaVideo : TGDecryptedMessageMedia
+ (TL_decryptedMessageMediaVideo *)createWithThumb:(NSData *)thumb thumb_w:(int)thumb_w thumb_h:(int)thumb_h duration:(int)duration mime_type:(NSString *)mime_type w:(int)w h:(int)h size:(int)size key:(NSData *)key iv:(NSData *)iv;
@end
@interface TL_decryptedMessageMediaGeoPoint : TGDecryptedMessageMedia
+ (TL_decryptedMessageMediaGeoPoint *)createWithLat:(double)lat n_long:(double)n_long;
@end
@interface TL_decryptedMessageMediaContact : TGDecryptedMessageMedia
+ (TL_decryptedMessageMediaContact *)createWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(int)user_id;
@end
@interface TL_decryptedMessageMediaDocument : TGDecryptedMessageMedia
+ (TL_decryptedMessageMediaDocument *)createWithThumb:(NSData *)thumb thumb_w:(int)thumb_w thumb_h:(int)thumb_h file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(int)size key:(NSData *)key iv:(NSData *)iv;
@end
@interface TL_decryptedMessageMediaAudio : TGDecryptedMessageMedia
+ (TL_decryptedMessageMediaAudio *)createWithDuration:(int)duration mime_type:(NSString *)mime_type size:(int)size key:(NSData *)key iv:(NSData *)iv;
@end
	
@interface TGInputPeer : TLObject
@property (nonatomic) int user_id;
@property long access_hash;
@property (nonatomic) int chat_id;
@end

@interface TL_inputPeerEmpty : TGInputPeer
+ (TL_inputPeerEmpty *)create;
@end
@interface TL_inputPeerSelf : TGInputPeer
+ (TL_inputPeerSelf *)create;
@end
@interface TL_inputPeerContact : TGInputPeer
+ (TL_inputPeerContact *)createWithUser_id:(int)user_id;
@end
@interface TL_inputPeerForeign : TGInputPeer
+ (TL_inputPeerForeign *)createWithUser_id:(int)user_id access_hash:(long)access_hash;
@end
@interface TL_inputPeerChat : TGInputPeer
+ (TL_inputPeerChat *)createWithChat_id:(int)chat_id;
@end
	
@interface TGInputUser : TLObject
@property (nonatomic) int user_id;
@property long access_hash;
@end

@interface TL_inputUserEmpty : TGInputUser
+ (TL_inputUserEmpty *)create;
@end
@interface TL_inputUserSelf : TGInputUser
+ (TL_inputUserSelf *)create;
@end
@interface TL_inputUserContact : TGInputUser
+ (TL_inputUserContact *)createWithUser_id:(int)user_id;
@end
@interface TL_inputUserForeign : TGInputUser
+ (TL_inputUserForeign *)createWithUser_id:(int)user_id access_hash:(long)access_hash;
@end
	
@interface TGInputContact : TLObject
@property long client_id;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;
@end

@interface TL_inputPhoneContact : TGInputContact
+ (TL_inputPhoneContact *)createWithClient_id:(long)client_id phone:(NSString *)phone first_name:(NSString *)first_name last_name:(NSString *)last_name;
@end
	
@interface TGInputFile : TLObject
@property long n_id;
@property (nonatomic) int parts;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *md5_checksum;
@end

@interface TL_inputFile : TGInputFile
+ (TL_inputFile *)createWithN_id:(long)n_id parts:(int)parts name:(NSString *)name md5_checksum:(NSString *)md5_checksum;
@end
@interface TL_inputFileBig : TGInputFile
+ (TL_inputFileBig *)createWithN_id:(long)n_id parts:(int)parts name:(NSString *)name;
@end
	
@interface TGInputMedia : TLObject
@property (nonatomic, strong) TGInputFile *file;
@property (nonatomic, strong) TGInputPhoto *photo_id;
@property (nonatomic, strong) TGInputGeoPoint *geo_point;
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic) int duration;
@property (nonatomic) int w;
@property (nonatomic) int h;
@property (nonatomic, strong) NSString *mime_type;
@property (nonatomic, strong) TGInputFile *thumb;
@property (nonatomic, strong) TGInputVideo *video_id;
@property (nonatomic, strong) TGInputAudio *audio_id;
@property (nonatomic, strong) NSString *file_name;
@property (nonatomic, strong) TGInputDocument *document_id;
@end

@interface TL_inputMediaEmpty : TGInputMedia
+ (TL_inputMediaEmpty *)create;
@end
@interface TL_inputMediaUploadedPhoto : TGInputMedia
+ (TL_inputMediaUploadedPhoto *)createWithFile:(TGInputFile *)file;
@end
@interface TL_inputMediaPhoto : TGInputMedia
+ (TL_inputMediaPhoto *)createWithPhoto_id:(TGInputPhoto *)photo_id;
@end
@interface TL_inputMediaGeoPoint : TGInputMedia
+ (TL_inputMediaGeoPoint *)createWithGeo_point:(TGInputGeoPoint *)geo_point;
@end
@interface TL_inputMediaContact : TGInputMedia
+ (TL_inputMediaContact *)createWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name;
@end
@interface TL_inputMediaUploadedVideo : TGInputMedia
+ (TL_inputMediaUploadedVideo *)createWithFile:(TGInputFile *)file duration:(int)duration w:(int)w h:(int)h mime_type:(NSString *)mime_type;
@end
@interface TL_inputMediaUploadedThumbVideo : TGInputMedia
+ (TL_inputMediaUploadedThumbVideo *)createWithFile:(TGInputFile *)file thumb:(TGInputFile *)thumb duration:(int)duration w:(int)w h:(int)h mime_type:(NSString *)mime_type;
@end
@interface TL_inputMediaVideo : TGInputMedia
+ (TL_inputMediaVideo *)createWithVideo_id:(TGInputVideo *)video_id;
@end
@interface TL_inputMediaUploadedAudio : TGInputMedia
+ (TL_inputMediaUploadedAudio *)createWithFile:(TGInputFile *)file duration:(int)duration mime_type:(NSString *)mime_type;
@end
@interface TL_inputMediaAudio : TGInputMedia
+ (TL_inputMediaAudio *)createWithAudio_id:(TGInputAudio *)audio_id;
@end
@interface TL_inputMediaUploadedDocument : TGInputMedia
+ (TL_inputMediaUploadedDocument *)createWithFile:(TGInputFile *)file file_name:(NSString *)file_name mime_type:(NSString *)mime_type;
@end
@interface TL_inputMediaUploadedThumbDocument : TGInputMedia
+ (TL_inputMediaUploadedThumbDocument *)createWithFile:(TGInputFile *)file thumb:(TGInputFile *)thumb file_name:(NSString *)file_name mime_type:(NSString *)mime_type;
@end
@interface TL_inputMediaDocument : TGInputMedia
+ (TL_inputMediaDocument *)createWithDocument_id:(TGInputDocument *)document_id;
@end
	
@interface TGInputChatPhoto : TLObject
@property (nonatomic, strong) TGInputFile *file;
@property (nonatomic, strong) TGInputPhotoCrop *crop;
@property (nonatomic, strong) TGInputPhoto *n_id;
@end

@interface TL_inputChatPhotoEmpty : TGInputChatPhoto
+ (TL_inputChatPhotoEmpty *)create;
@end
@interface TL_inputChatUploadedPhoto : TGInputChatPhoto
+ (TL_inputChatUploadedPhoto *)createWithFile:(TGInputFile *)file crop:(TGInputPhotoCrop *)crop;
@end
@interface TL_inputChatPhoto : TGInputChatPhoto
+ (TL_inputChatPhoto *)createWithN_id:(TGInputPhoto *)n_id crop:(TGInputPhotoCrop *)crop;
@end
	
@interface TGInputGeoPoint : TLObject
@property double lat;
@property double n_long;
@end

@interface TL_inputGeoPointEmpty : TGInputGeoPoint
+ (TL_inputGeoPointEmpty *)create;
@end
@interface TL_inputGeoPoint : TGInputGeoPoint
+ (TL_inputGeoPoint *)createWithLat:(double)lat n_long:(double)n_long;
@end
	
@interface TGInputPhoto : TLObject
@property long n_id;
@property long access_hash;
@end

@interface TL_inputPhotoEmpty : TGInputPhoto
+ (TL_inputPhotoEmpty *)create;
@end
@interface TL_inputPhoto : TGInputPhoto
+ (TL_inputPhoto *)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
	
@interface TGInputVideo : TLObject
@property long n_id;
@property long access_hash;
@end

@interface TL_inputVideoEmpty : TGInputVideo
+ (TL_inputVideoEmpty *)create;
@end
@interface TL_inputVideo : TGInputVideo
+ (TL_inputVideo *)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
	
@interface TGInputFileLocation : TLObject
@property long volume_id;
@property (nonatomic) int local_id;
@property long secret;
@property long n_id;
@property long access_hash;
@end

@interface TL_inputFileLocation : TGInputFileLocation
+ (TL_inputFileLocation *)createWithVolume_id:(long)volume_id local_id:(int)local_id secret:(long)secret;
@end
@interface TL_inputVideoFileLocation : TGInputFileLocation
+ (TL_inputVideoFileLocation *)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
@interface TL_inputEncryptedFileLocation : TGInputFileLocation
+ (TL_inputEncryptedFileLocation *)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
@interface TL_inputAudioFileLocation : TGInputFileLocation
+ (TL_inputAudioFileLocation *)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
@interface TL_inputDocumentFileLocation : TGInputFileLocation
+ (TL_inputDocumentFileLocation *)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
	
@interface TGInputPhotoCrop : TLObject
@property double crop_left;
@property double crop_top;
@property double crop_width;
@end

@interface TL_inputPhotoCropAuto : TGInputPhotoCrop
+ (TL_inputPhotoCropAuto *)create;
@end
@interface TL_inputPhotoCrop : TGInputPhotoCrop
+ (TL_inputPhotoCrop *)createWithCrop_left:(double)crop_left crop_top:(double)crop_top crop_width:(double)crop_width;
@end
	
@interface TGInputAppEvent : TLObject
@property double time;
@property (nonatomic, strong) NSString *type;
@property long peer;
@property (nonatomic, strong) NSString *data;
@end

@interface TL_inputAppEvent : TGInputAppEvent
+ (TL_inputAppEvent *)createWithTime:(double)time type:(NSString *)type peer:(long)peer data:(NSString *)data;
@end
	
@interface TGPeer : TLObject
@property (nonatomic) int user_id;
@property (nonatomic) int chat_id;
@end

@interface TL_peerUser : TGPeer
+ (TL_peerUser *)createWithUser_id:(int)user_id;
@end
@interface TL_peerChat : TGPeer
+ (TL_peerChat *)createWithChat_id:(int)chat_id;
@end
	
@interface TGstorage_FileType : TLObject

@end

@interface TL_storage_fileUnknown : TGstorage_FileType
+ (TL_storage_fileUnknown *)create;
@end
@interface TL_storage_fileJpeg : TGstorage_FileType
+ (TL_storage_fileJpeg *)create;
@end
@interface TL_storage_fileGif : TGstorage_FileType
+ (TL_storage_fileGif *)create;
@end
@interface TL_storage_filePng : TGstorage_FileType
+ (TL_storage_filePng *)create;
@end
@interface TL_storage_filePdf : TGstorage_FileType
+ (TL_storage_filePdf *)create;
@end
@interface TL_storage_fileMp3 : TGstorage_FileType
+ (TL_storage_fileMp3 *)create;
@end
@interface TL_storage_fileMov : TGstorage_FileType
+ (TL_storage_fileMov *)create;
@end
@interface TL_storage_filePartial : TGstorage_FileType
+ (TL_storage_filePartial *)create;
@end
@interface TL_storage_fileMp4 : TGstorage_FileType
+ (TL_storage_fileMp4 *)create;
@end
@interface TL_storage_fileWebp : TGstorage_FileType
+ (TL_storage_fileWebp *)create;
@end
	
@interface TGFileLocation : TLObject
@property long volume_id;
@property (nonatomic) int local_id;
@property long secret;
@property (nonatomic) int dc_id;
@end

@interface TL_fileLocationUnavailable : TGFileLocation
+ (TL_fileLocationUnavailable *)createWithVolume_id:(long)volume_id local_id:(int)local_id secret:(long)secret;
@end
@interface TL_fileLocation : TGFileLocation
+ (TL_fileLocation *)createWithDc_id:(int)dc_id volume_id:(long)volume_id local_id:(int)local_id secret:(long)secret;
@end
	
@interface TGUser : TLObject
@property (nonatomic) int n_id;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) NSString *user_name;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) TGUserProfilePhoto *photo;
@property (nonatomic, strong) TGUserStatus *status;
@property BOOL inactive;
@property long access_hash;
@end

@interface TL_userEmpty : TGUser
+ (TL_userEmpty *)createWithN_id:(int)n_id;
@end
@interface TL_userSelf : TGUser
+ (TL_userSelf *)createWithN_id:(int)n_id first_name:(NSString *)first_name last_name:(NSString *)last_name user_name:(NSString *)user_name phone:(NSString *)phone photo:(TGUserProfilePhoto *)photo status:(TGUserStatus *)status inactive:(BOOL)inactive;
@end
@interface TL_userContact : TGUser
+ (TL_userContact *)createWithN_id:(int)n_id first_name:(NSString *)first_name last_name:(NSString *)last_name user_name:(NSString *)user_name access_hash:(long)access_hash phone:(NSString *)phone photo:(TGUserProfilePhoto *)photo status:(TGUserStatus *)status;
@end
@interface TL_userRequest : TGUser
+ (TL_userRequest *)createWithN_id:(int)n_id first_name:(NSString *)first_name last_name:(NSString *)last_name user_name:(NSString *)user_name access_hash:(long)access_hash phone:(NSString *)phone photo:(TGUserProfilePhoto *)photo status:(TGUserStatus *)status;
@end
@interface TL_userForeign : TGUser
+ (TL_userForeign *)createWithN_id:(int)n_id first_name:(NSString *)first_name last_name:(NSString *)last_name user_name:(NSString *)user_name access_hash:(long)access_hash photo:(TGUserProfilePhoto *)photo status:(TGUserStatus *)status;
@end
@interface TL_userDeleted : TGUser
+ (TL_userDeleted *)createWithN_id:(int)n_id first_name:(NSString *)first_name last_name:(NSString *)last_name user_name:(NSString *)user_name;
@end
	
@interface TGUserProfilePhoto : TLObject
@property long photo_id;
@property (nonatomic, strong) TGFileLocation *photo_small;
@property (nonatomic, strong) TGFileLocation *photo_big;
@end

@interface TL_userProfilePhotoEmpty : TGUserProfilePhoto
+ (TL_userProfilePhotoEmpty *)create;
@end
@interface TL_userProfilePhoto : TGUserProfilePhoto
+ (TL_userProfilePhoto *)createWithPhoto_id:(long)photo_id photo_small:(TGFileLocation *)photo_small photo_big:(TGFileLocation *)photo_big;
@end
	
@interface TGUserStatus : TLObject
@property (nonatomic) int expires;
@property (nonatomic) int was_online;
@end

@interface TL_userStatusEmpty : TGUserStatus
+ (TL_userStatusEmpty *)create;
@end
@interface TL_userStatusOnline : TGUserStatus
+ (TL_userStatusOnline *)createWithExpires:(int)expires;
@end
@interface TL_userStatusOffline : TGUserStatus
+ (TL_userStatusOffline *)createWithWas_online:(int)was_online;
@end
	
@interface TGChat : TLObject
@property (nonatomic) int n_id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) TGChatPhoto *photo;
@property (nonatomic) int participants_count;
@property (nonatomic) int date;
@property BOOL left;
@property (nonatomic) int version;
@property long access_hash;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *venue;
@property (nonatomic, strong) TGGeoPoint *geo;
@property BOOL checked_in;
@end

@interface TL_chatEmpty : TGChat
+ (TL_chatEmpty *)createWithN_id:(int)n_id;
@end
@interface TL_chat : TGChat
+ (TL_chat *)createWithN_id:(int)n_id title:(NSString *)title photo:(TGChatPhoto *)photo participants_count:(int)participants_count date:(int)date left:(BOOL)left version:(int)version;
@end
@interface TL_chatForbidden : TGChat
+ (TL_chatForbidden *)createWithN_id:(int)n_id title:(NSString *)title date:(int)date;
@end
@interface TL_geoChat : TGChat
+ (TL_geoChat *)createWithN_id:(int)n_id access_hash:(long)access_hash title:(NSString *)title address:(NSString *)address venue:(NSString *)venue geo:(TGGeoPoint *)geo photo:(TGChatPhoto *)photo participants_count:(int)participants_count date:(int)date checked_in:(BOOL)checked_in version:(int)version;
@end
	
@interface TGChatFull : TLObject
@property (nonatomic) int n_id;
@property (nonatomic, strong) TGChatParticipants *participants;
@property (nonatomic, strong) TGPhoto *chat_photo;
@property (nonatomic, strong) TGPeerNotifySettings *notify_settings;
@end

@interface TL_chatFull : TGChatFull
+ (TL_chatFull *)createWithN_id:(int)n_id participants:(TGChatParticipants *)participants chat_photo:(TGPhoto *)chat_photo notify_settings:(TGPeerNotifySettings *)notify_settings;
@end
	
@interface TGChatParticipant : TLObject
@property (nonatomic) int user_id;
@property (nonatomic) int inviter_id;
@property (nonatomic) int date;
@end

@interface TL_chatParticipant : TGChatParticipant
+ (TL_chatParticipant *)createWithUser_id:(int)user_id inviter_id:(int)inviter_id date:(int)date;
@end
	
@interface TGChatParticipants : TLObject
@property (nonatomic) int chat_id;
@property (nonatomic) int admin_id;
@property (nonatomic, strong) NSMutableArray *participants;
@property (nonatomic) int version;
@end

@interface TL_chatParticipantsForbidden : TGChatParticipants
+ (TL_chatParticipantsForbidden *)createWithChat_id:(int)chat_id;
@end
@interface TL_chatParticipants : TGChatParticipants
+ (TL_chatParticipants *)createWithChat_id:(int)chat_id admin_id:(int)admin_id participants:(NSMutableArray *)participants version:(int)version;
@end
	
@interface TGChatPhoto : TLObject
@property (nonatomic, strong) TGFileLocation *photo_small;
@property (nonatomic, strong) TGFileLocation *photo_big;
@end

@interface TL_chatPhotoEmpty : TGChatPhoto
+ (TL_chatPhotoEmpty *)create;
@end
@interface TL_chatPhoto : TGChatPhoto
+ (TL_chatPhoto *)createWithPhoto_small:(TGFileLocation *)photo_small photo_big:(TGFileLocation *)photo_big;
@end
	
@interface TGMessage : TLObject
@property (nonatomic,assign) int flags;
@property (nonatomic) int n_id;
@property (nonatomic) int from_id;
@property (nonatomic, strong) TGPeer *to_id;
@property (nonatomic) int date;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) TGMessageMedia *media;
@property (nonatomic) int fwd_from_id;
@property (nonatomic) int fwd_date;
@property (nonatomic, strong) TGMessageAction *action;
@end

@interface TL_messageEmpty : TGMessage
+ (TL_messageEmpty *)createWithN_id:(int)n_id;
@end
@interface TL_message : TGMessage
+ (TL_message *)createWithN_id:(int)n_id flags:(int)flags from_id:(int)from_id to_id:(TGPeer *)to_id date:(int)date message:(NSString *)message media:(TGMessageMedia *)media;
@end
@interface TL_messageForwarded : TGMessage
+ (TL_messageForwarded *)createWithN_id:(int)n_id flags:(int)flags fwd_from_id:(int)fwd_from_id fwd_date:(int)fwd_date from_id:(int)from_id to_id:(TGPeer *)to_id date:(int)date message:(NSString *)message media:(TGMessageMedia *)media;
@end
@interface TL_messageService : TGMessage
+ (TL_messageService *)createWithN_id:(int)n_id flags:(int)flags from_id:(int)from_id to_id:(TGPeer *)to_id date:(int)date action:(TGMessageAction *)action;
@end
	
@interface TGMessageMedia : TLObject
@property (nonatomic, strong) TGPhoto *photo;
@property (nonatomic, strong) TGVideo *video;
@property (nonatomic, strong) TGGeoPoint *geo;
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic) int user_id;
@property (nonatomic, strong) NSData *bytes;
@property (nonatomic, strong) TGDocument *document;
@property (nonatomic, strong) TGAudio *audio;
@end

@interface TL_messageMediaEmpty : TGMessageMedia
+ (TL_messageMediaEmpty *)create;
@end
@interface TL_messageMediaPhoto : TGMessageMedia
+ (TL_messageMediaPhoto *)createWithPhoto:(TGPhoto *)photo;
@end
@interface TL_messageMediaVideo : TGMessageMedia
+ (TL_messageMediaVideo *)createWithVideo:(TGVideo *)video;
@end
@interface TL_messageMediaGeo : TGMessageMedia
+ (TL_messageMediaGeo *)createWithGeo:(TGGeoPoint *)geo;
@end
@interface TL_messageMediaContact : TGMessageMedia
+ (TL_messageMediaContact *)createWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(int)user_id;
@end
@interface TL_messageMediaUnsupported : TGMessageMedia
+ (TL_messageMediaUnsupported *)createWithBytes:(NSData *)bytes;
@end
@interface TL_messageMediaDocument : TGMessageMedia
+ (TL_messageMediaDocument *)createWithDocument:(TGDocument *)document;
@end
@interface TL_messageMediaAudio : TGMessageMedia
+ (TL_messageMediaAudio *)createWithAudio:(TGAudio *)audio;
@end
	
@interface TGMessageAction : TLObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) TGPhoto *photo;
@property (nonatomic) int user_id;
@property (nonatomic, strong) NSString *address;
@end

@interface TL_messageActionEmpty : TGMessageAction
+ (TL_messageActionEmpty *)create;
@end
@interface TL_messageActionChatCreate : TGMessageAction
+ (TL_messageActionChatCreate *)createWithTitle:(NSString *)title users:(NSMutableArray *)users;
@end
@interface TL_messageActionChatEditTitle : TGMessageAction
+ (TL_messageActionChatEditTitle *)createWithTitle:(NSString *)title;
@end
@interface TL_messageActionChatEditPhoto : TGMessageAction
+ (TL_messageActionChatEditPhoto *)createWithPhoto:(TGPhoto *)photo;
@end
@interface TL_messageActionChatDeletePhoto : TGMessageAction
+ (TL_messageActionChatDeletePhoto *)create;
@end
@interface TL_messageActionChatAddUser : TGMessageAction
+ (TL_messageActionChatAddUser *)createWithUser_id:(int)user_id;
@end
@interface TL_messageActionChatDeleteUser : TGMessageAction
+ (TL_messageActionChatDeleteUser *)createWithUser_id:(int)user_id;
@end
@interface TL_messageActionGeoChatCreate : TGMessageAction
+ (TL_messageActionGeoChatCreate *)createWithTitle:(NSString *)title address:(NSString *)address;
@end
@interface TL_messageActionGeoChatCheckin : TGMessageAction
+ (TL_messageActionGeoChatCheckin *)create;
@end
	
@interface TGDialog : TLObject
@property (nonatomic, strong) TGPeer *peer;
@property (nonatomic) int top_message;
@property (nonatomic) int unread_count;
@property (nonatomic, strong) TGPeerNotifySettings *notify_settings;
@end

@interface TL_dialog : TGDialog
+ (TL_dialog *)createWithPeer:(TGPeer *)peer top_message:(int)top_message unread_count:(int)unread_count notify_settings:(TGPeerNotifySettings *)notify_settings;
@end
	
@interface TGPhoto : TLObject
@property long n_id;
@property long access_hash;
@property (nonatomic) int user_id;
@property (nonatomic) int date;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) TGGeoPoint *geo;
@property (nonatomic, strong) NSMutableArray *sizes;
@end

@interface TL_photoEmpty : TGPhoto
+ (TL_photoEmpty *)createWithN_id:(long)n_id;
@end
@interface TL_photo : TGPhoto
+ (TL_photo *)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date caption:(NSString *)caption geo:(TGGeoPoint *)geo sizes:(NSMutableArray *)sizes;
@end
	
@interface TGPhotoSize : TLObject
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) TGFileLocation *location;
@property (nonatomic) int w;
@property (nonatomic) int h;
@property (nonatomic) int size;
@property (nonatomic, strong) NSData *bytes;
@end

@interface TL_photoSizeEmpty : TGPhotoSize
+ (TL_photoSizeEmpty *)createWithType:(NSString *)type;
@end
@interface TL_photoSize : TGPhotoSize
+ (TL_photoSize *)createWithType:(NSString *)type location:(TGFileLocation *)location w:(int)w h:(int)h size:(int)size;
@end
@interface TL_photoCachedSize : TGPhotoSize
+ (TL_photoCachedSize *)createWithType:(NSString *)type location:(TGFileLocation *)location w:(int)w h:(int)h bytes:(NSData *)bytes;
@end
	
@interface TGVideo : TLObject
@property long n_id;
@property long access_hash;
@property (nonatomic) int user_id;
@property (nonatomic) int date;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic) int duration;
@property (nonatomic, strong) NSString *mime_type;
@property (nonatomic) int size;
@property (nonatomic, strong) TGPhotoSize *thumb;
@property (nonatomic) int dc_id;
@property (nonatomic) int w;
@property (nonatomic) int h;
@end

@interface TL_videoEmpty : TGVideo
+ (TL_videoEmpty *)createWithN_id:(long)n_id;
@end
@interface TL_video : TGVideo
+ (TL_video *)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date caption:(NSString *)caption duration:(int)duration mime_type:(NSString *)mime_type size:(int)size thumb:(TGPhotoSize *)thumb dc_id:(int)dc_id w:(int)w h:(int)h;
@end
	
@interface TGGeoPoint : TLObject
@property double n_long;
@property double lat;
@end

@interface TL_geoPointEmpty : TGGeoPoint
+ (TL_geoPointEmpty *)create;
@end
@interface TL_geoPoint : TGGeoPoint
+ (TL_geoPoint *)createWithN_long:(double)n_long lat:(double)lat;
@end
	
@interface TGauth_CheckedPhone : TLObject
@property BOOL phone_registered;
@property BOOL phone_invited;
@end

@interface TL_auth_checkedPhone : TGauth_CheckedPhone
+ (TL_auth_checkedPhone *)createWithPhone_registered:(BOOL)phone_registered phone_invited:(BOOL)phone_invited;
@end
	
@interface TGauth_SentCode : TLObject
@property BOOL phone_registered;
@property (nonatomic, strong) NSString *phone_code_hash;
@property (nonatomic) int send_call_timeout;
@property BOOL is_password;
@end

@interface TL_auth_sentCode : TGauth_SentCode
+ (TL_auth_sentCode *)createWithPhone_registered:(BOOL)phone_registered phone_code_hash:(NSString *)phone_code_hash send_call_timeout:(int)send_call_timeout is_password:(BOOL)is_password;
@end
	
@interface TGauth_Authorization : TLObject
@property (nonatomic) int expires;
@property (nonatomic, strong) TGUser *user;
@end

@interface TL_auth_authorization : TGauth_Authorization
+ (TL_auth_authorization *)createWithExpires:(int)expires user:(TGUser *)user;
@end
	
@interface TGauth_ExportedAuthorization : TLObject
@property (nonatomic) int n_id;
@property (nonatomic, strong) NSData *bytes;
@end

@interface TL_auth_exportedAuthorization : TGauth_ExportedAuthorization
+ (TL_auth_exportedAuthorization *)createWithN_id:(int)n_id bytes:(NSData *)bytes;
@end
	
@interface TGInputNotifyPeer : TLObject
@property (nonatomic, strong) TGInputPeer *peer;
@property (nonatomic, strong) TGInputGeoChat *geo_peer;
@end

@interface TL_inputNotifyPeer : TGInputNotifyPeer
+ (TL_inputNotifyPeer *)createWithPeer:(TGInputPeer *)peer;
@end
@interface TL_inputNotifyUsers : TGInputNotifyPeer
+ (TL_inputNotifyUsers *)create;
@end
@interface TL_inputNotifyChats : TGInputNotifyPeer
+ (TL_inputNotifyChats *)create;
@end
@interface TL_inputNotifyAll : TGInputNotifyPeer
+ (TL_inputNotifyAll *)create;
@end
@interface TL_inputNotifyGeoChatPeer : TGInputNotifyPeer
+ (TL_inputNotifyGeoChatPeer *)createWithGeo_peer:(TGInputGeoChat *)geo_peer;
@end
	
@interface TGInputPeerNotifyEvents : TLObject

@end

@interface TL_inputPeerNotifyEventsEmpty : TGInputPeerNotifyEvents
+ (TL_inputPeerNotifyEventsEmpty *)create;
@end
@interface TL_inputPeerNotifyEventsAll : TGInputPeerNotifyEvents
+ (TL_inputPeerNotifyEventsAll *)create;
@end
	
@interface TGInputPeerNotifySettings : TLObject
@property (nonatomic) int mute_until;
@property (nonatomic, strong) NSString *sound;
@property BOOL show_previews;
@property (nonatomic) int events_mask;
@end

@interface TL_inputPeerNotifySettings : TGInputPeerNotifySettings
+ (TL_inputPeerNotifySettings *)createWithMute_until:(int)mute_until sound:(NSString *)sound show_previews:(BOOL)show_previews events_mask:(int)events_mask;
@end
	
@interface TGPeerNotifyEvents : TLObject

@end

@interface TL_peerNotifyEventsEmpty : TGPeerNotifyEvents
+ (TL_peerNotifyEventsEmpty *)create;
@end
@interface TL_peerNotifyEventsAll : TGPeerNotifyEvents
+ (TL_peerNotifyEventsAll *)create;
@end
	
@interface TGPeerNotifySettings : TLObject
@property (nonatomic) int mute_until;
@property (nonatomic, strong) NSString *sound;
@property BOOL show_previews;
@property (nonatomic) int events_mask;
@end

@interface TL_peerNotifySettingsEmpty : TGPeerNotifySettings
+ (TL_peerNotifySettingsEmpty *)create;
@end
@interface TL_peerNotifySettings : TGPeerNotifySettings
+ (TL_peerNotifySettings *)createWithMute_until:(int)mute_until sound:(NSString *)sound show_previews:(BOOL)show_previews events_mask:(int)events_mask;
@end
	
@interface TGWallPaper : TLObject
@property (nonatomic) int n_id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *sizes;
@property (nonatomic) int color;
@property (nonatomic) int bg_color;
@end

@interface TL_wallPaper : TGWallPaper
+ (TL_wallPaper *)createWithN_id:(int)n_id title:(NSString *)title sizes:(NSMutableArray *)sizes color:(int)color;
@end
@interface TL_wallPaperSolid : TGWallPaper
+ (TL_wallPaperSolid *)createWithN_id:(int)n_id title:(NSString *)title bg_color:(int)bg_color color:(int)color;
@end
	
@interface TGUserFull : TLObject
@property (nonatomic, strong) TGUser *user;
@property (nonatomic, strong) TGcontacts_Link *link;
@property (nonatomic, strong) TGPhoto *profile_photo;
@property (nonatomic, strong) TGPeerNotifySettings *notify_settings;
@property BOOL blocked;
@property (nonatomic, strong) NSString *real_first_name;
@property (nonatomic, strong) NSString *real_last_name;
@end

@interface TL_userFull : TGUserFull
+ (TL_userFull *)createWithUser:(TGUser *)user link:(TGcontacts_Link *)link profile_photo:(TGPhoto *)profile_photo notify_settings:(TGPeerNotifySettings *)notify_settings blocked:(BOOL)blocked real_first_name:(NSString *)real_first_name real_last_name:(NSString *)real_last_name;
@end
	
@interface TGContact : TLObject
@property (nonatomic) int user_id;
@property BOOL mutual;
@end

@interface TL_contact : TGContact
+ (TL_contact *)createWithUser_id:(int)user_id mutual:(BOOL)mutual;
@end
	
@interface TGImportedContact : TLObject
@property (nonatomic) int user_id;
@property long client_id;
@end

@interface TL_importedContact : TGImportedContact
+ (TL_importedContact *)createWithUser_id:(int)user_id client_id:(long)client_id;
@end
	
@interface TGContactBlocked : TLObject
@property (nonatomic) int user_id;
@property (nonatomic) int date;
@end

@interface TL_contactBlocked : TGContactBlocked
+ (TL_contactBlocked *)createWithUser_id:(int)user_id date:(int)date;
@end
	
@interface TGContactFound : TLObject
@property (nonatomic) int user_id;
@end

@interface TL_contactFound : TGContactFound
+ (TL_contactFound *)createWithUser_id:(int)user_id;
@end
	
@interface TGContactSuggested : TLObject
@property (nonatomic) int user_id;
@property (nonatomic) int mutual_contacts;
@end

@interface TL_contactSuggested : TGContactSuggested
+ (TL_contactSuggested *)createWithUser_id:(int)user_id mutual_contacts:(int)mutual_contacts;
@end
	
@interface TGContactStatus : TLObject
@property (nonatomic) int user_id;
@property (nonatomic) int expires;
@end

@interface TL_contactStatus : TGContactStatus
+ (TL_contactStatus *)createWithUser_id:(int)user_id expires:(int)expires;
@end
	
@interface TGChatLocated : TLObject
@property (nonatomic) int chat_id;
@property (nonatomic) int distance;
@end

@interface TL_chatLocated : TGChatLocated
+ (TL_chatLocated *)createWithChat_id:(int)chat_id distance:(int)distance;
@end
	
@interface TGcontacts_ForeignLink : TLObject
@property BOOL has_phone;
@end

@interface TL_contacts_foreignLinkUnknown : TGcontacts_ForeignLink
+ (TL_contacts_foreignLinkUnknown *)create;
@end
@interface TL_contacts_foreignLinkRequested : TGcontacts_ForeignLink
+ (TL_contacts_foreignLinkRequested *)createWithHas_phone:(BOOL)has_phone;
@end
@interface TL_contacts_foreignLinkMutual : TGcontacts_ForeignLink
+ (TL_contacts_foreignLinkMutual *)create;
@end
	
@interface TGcontacts_MyLink : TLObject
@property BOOL contact;
@end

@interface TL_contacts_myLinkEmpty : TGcontacts_MyLink
+ (TL_contacts_myLinkEmpty *)create;
@end
@interface TL_contacts_myLinkRequested : TGcontacts_MyLink
+ (TL_contacts_myLinkRequested *)createWithContact:(BOOL)contact;
@end
@interface TL_contacts_myLinkContact : TGcontacts_MyLink
+ (TL_contacts_myLinkContact *)create;
@end
	
@interface TGcontacts_Link : TLObject
@property (nonatomic, strong) TGcontacts_MyLink *my_link;
@property (nonatomic, strong) TGcontacts_ForeignLink *foreign_link;
@property (nonatomic, strong) TGUser *user;
@end

@interface TL_contacts_link : TGcontacts_Link
+ (TL_contacts_link *)createWithMy_link:(TGcontacts_MyLink *)my_link foreign_link:(TGcontacts_ForeignLink *)foreign_link user:(TGUser *)user;
@end
	
@interface TGcontacts_Contacts : TLObject
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *users;
@end

@interface TL_contacts_contacts : TGcontacts_Contacts
+ (TL_contacts_contacts *)createWithContacts:(NSMutableArray *)contacts users:(NSMutableArray *)users;
@end
@interface TL_contacts_contactsNotModified : TGcontacts_Contacts
+ (TL_contacts_contactsNotModified *)create;
@end
	
@interface TGcontacts_ImportedContacts : TLObject
@property (nonatomic, strong) NSMutableArray *imported;
@property (nonatomic, strong) NSMutableArray *retry_contacts;
@property (nonatomic, strong) NSMutableArray *users;
@end

@interface TL_contacts_importedContacts : TGcontacts_ImportedContacts
+ (TL_contacts_importedContacts *)createWithImported:(NSMutableArray *)imported retry_contacts:(NSMutableArray *)retry_contacts users:(NSMutableArray *)users;
@end
	
@interface TGcontacts_Blocked : TLObject
@property (nonatomic, strong) NSMutableArray *blocked;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic) int n_count;
@end

@interface TL_contacts_blocked : TGcontacts_Blocked
+ (TL_contacts_blocked *)createWithBlocked:(NSMutableArray *)blocked users:(NSMutableArray *)users;
@end
@interface TL_contacts_blockedSlice : TGcontacts_Blocked
+ (TL_contacts_blockedSlice *)createWithN_count:(int)n_count blocked:(NSMutableArray *)blocked users:(NSMutableArray *)users;
@end
	
@interface TGcontacts_Found : TLObject
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) NSMutableArray *users;
@end

@interface TL_contacts_found : TGcontacts_Found
+ (TL_contacts_found *)createWithResults:(NSMutableArray *)results users:(NSMutableArray *)users;
@end
	
@interface TGcontacts_Suggested : TLObject
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) NSMutableArray *users;
@end

@interface TL_contacts_suggested : TGcontacts_Suggested
+ (TL_contacts_suggested *)createWithResults:(NSMutableArray *)results users:(NSMutableArray *)users;
@end
	
@interface TGmessages_Dialogs : TLObject
@property (nonatomic, strong) NSMutableArray *dialogs;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *chats;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic) int n_count;
@end

@interface TL_messages_dialogs : TGmessages_Dialogs
+ (TL_messages_dialogs *)createWithDialogs:(NSMutableArray *)dialogs messages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users;
@end
@interface TL_messages_dialogsSlice : TGmessages_Dialogs
+ (TL_messages_dialogsSlice *)createWithN_count:(int)n_count dialogs:(NSMutableArray *)dialogs messages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users;
@end
	
@interface TGmessages_Messages : TLObject
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *chats;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic) int n_count;
@end

@interface TL_messages_messages : TGmessages_Messages
+ (TL_messages_messages *)createWithMessages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users;
@end
@interface TL_messages_messagesSlice : TGmessages_Messages
+ (TL_messages_messagesSlice *)createWithN_count:(int)n_count messages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users;
@end
	
@interface TGmessages_Message : TLObject
@property (nonatomic, strong) TGMessage *message;
@property (nonatomic, strong) NSMutableArray *chats;
@property (nonatomic, strong) NSMutableArray *users;
@end

@interface TL_messages_messageEmpty : TGmessages_Message
+ (TL_messages_messageEmpty *)create;
@end
@interface TL_messages_message : TGmessages_Message
+ (TL_messages_message *)createWithMessage:(TGMessage *)message chats:(NSMutableArray *)chats users:(NSMutableArray *)users;
@end
	
@interface TGmessages_StatedMessages : TLObject
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *chats;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic) int pts;
@property (nonatomic) int seq;
@property (nonatomic, strong) NSMutableArray *links;
@end

@interface TL_messages_statedMessages : TGmessages_StatedMessages
+ (TL_messages_statedMessages *)createWithMessages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users pts:(int)pts seq:(int)seq;
@end
@interface TL_messages_statedMessagesLinks : TGmessages_StatedMessages
+ (TL_messages_statedMessagesLinks *)createWithMessages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users links:(NSMutableArray *)links pts:(int)pts seq:(int)seq;
@end
	
@interface TGmessages_StatedMessage : TLObject
@property (nonatomic, strong) TGMessage *message;
@property (nonatomic, strong) NSMutableArray *chats;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic) int pts;
@property (nonatomic) int seq;
@property (nonatomic, strong) NSMutableArray *links;
@end

@interface TL_messages_statedMessage : TGmessages_StatedMessage
+ (TL_messages_statedMessage *)createWithMessage:(TGMessage *)message chats:(NSMutableArray *)chats users:(NSMutableArray *)users pts:(int)pts seq:(int)seq;
@end
@interface TL_messages_statedMessageLink : TGmessages_StatedMessage
+ (TL_messages_statedMessageLink *)createWithMessage:(TGMessage *)message chats:(NSMutableArray *)chats users:(NSMutableArray *)users links:(NSMutableArray *)links pts:(int)pts seq:(int)seq;
@end
	
@interface TGmessages_SentMessage : TLObject
@property (nonatomic) int n_id;
@property (nonatomic) int date;
@property (nonatomic) int pts;
@property (nonatomic) int seq;
@property (nonatomic, strong) NSMutableArray *links;
@end

@interface TL_messages_sentMessage : TGmessages_SentMessage
+ (TL_messages_sentMessage *)createWithN_id:(int)n_id date:(int)date pts:(int)pts seq:(int)seq;
@end
@interface TL_messages_sentMessageLink : TGmessages_SentMessage
+ (TL_messages_sentMessageLink *)createWithN_id:(int)n_id date:(int)date pts:(int)pts seq:(int)seq links:(NSMutableArray *)links;
@end
	
@interface TGmessages_Chat : TLObject
@property (nonatomic, strong) TGChat *chat;
@property (nonatomic, strong) NSMutableArray *users;
@end

@interface TL_messages_chat : TGmessages_Chat
+ (TL_messages_chat *)createWithChat:(TGChat *)chat users:(NSMutableArray *)users;
@end
	
@interface TGmessages_Chats : TLObject
@property (nonatomic, strong) NSMutableArray *chats;
@property (nonatomic, strong) NSMutableArray *users;
@end

@interface TL_messages_chats : TGmessages_Chats
+ (TL_messages_chats *)createWithChats:(NSMutableArray *)chats users:(NSMutableArray *)users;
@end
	
@interface TGmessages_ChatFull : TLObject
@property (nonatomic, strong) TGChatFull *full_chat;
@property (nonatomic, strong) NSMutableArray *chats;
@property (nonatomic, strong) NSMutableArray *users;
@end

@interface TL_messages_chatFull : TGmessages_ChatFull
+ (TL_messages_chatFull *)createWithFull_chat:(TGChatFull *)full_chat chats:(NSMutableArray *)chats users:(NSMutableArray *)users;
@end
	
@interface TGmessages_AffectedHistory : TLObject
@property (nonatomic) int pts;
@property (nonatomic) int seq;
@property (nonatomic) int offset;
@end

@interface TL_messages_affectedHistory : TGmessages_AffectedHistory
+ (TL_messages_affectedHistory *)createWithPts:(int)pts seq:(int)seq offset:(int)offset;
@end
	
@interface TGMessagesFilter : TLObject

@end

@interface TL_inputMessagesFilterEmpty : TGMessagesFilter
+ (TL_inputMessagesFilterEmpty *)create;
@end
@interface TL_inputMessagesFilterPhotos : TGMessagesFilter
+ (TL_inputMessagesFilterPhotos *)create;
@end
@interface TL_inputMessagesFilterVideo : TGMessagesFilter
+ (TL_inputMessagesFilterVideo *)create;
@end
@interface TL_inputMessagesFilterPhotoVideo : TGMessagesFilter
+ (TL_inputMessagesFilterPhotoVideo *)create;
@end
@interface TL_inputMessagesFilterDocument : TGMessagesFilter
+ (TL_inputMessagesFilterDocument *)create;
@end
	
@interface TGUpdate : TLObject
@property (nonatomic, strong) TGMessage *message;
@property (nonatomic,strong) TL_SendMessageAction *action;
@property (nonatomic) int pts;
@property (nonatomic) int n_id;
@property long random_id;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic) int user_id;
@property (nonatomic) int chat_id;
@property (nonatomic, strong) TGChatParticipants *participants;
@property (nonatomic, strong) TGUserStatus *status;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) NSString *user_name;
@property (nonatomic) int date;
@property (nonatomic, strong) TGUserProfilePhoto *photo;
@property BOOL previous;
@property (nonatomic, strong) TGcontacts_MyLink *my_link;
@property (nonatomic, strong) TGcontacts_ForeignLink *foreign_link;
@property long auth_key_id;
@property (nonatomic, strong) NSString *device;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) TGGeoChatMessage *geo_message;
@property (nonatomic, strong) TGEncryptedMessage *encrypted_message;
@property (nonatomic) int qts;
@property (nonatomic, strong) TGEncryptedChat *chat;
@property (nonatomic) int max_date;
@property (nonatomic) int inviter_id;
@property (nonatomic) int version;
@property (nonatomic, strong) NSMutableArray *dc_options;
@property BOOL blocked;
@property (nonatomic, strong) TGNotifyPeer *peer;
@property (nonatomic, strong) TGPeerNotifySettings *notify_settings;
@end

@interface TL_updateNewMessage : TGUpdate
+ (TL_updateNewMessage *)createWithMessage:(TGMessage *)message pts:(int)pts;
@end
@interface TL_updateMessageID : TGUpdate
+ (TL_updateMessageID *)createWithN_id:(int)n_id random_id:(long)random_id;
@end
@interface TL_updateReadMessages : TGUpdate
+ (TL_updateReadMessages *)createWithMessages:(NSMutableArray *)messages pts:(int)pts;
@end
@interface TL_updateDeleteMessages : TGUpdate
+ (TL_updateDeleteMessages *)createWithMessages:(NSMutableArray *)messages pts:(int)pts;
@end
@interface TL_updateRestoreMessages : TGUpdate
+ (TL_updateRestoreMessages *)createWithMessages:(NSMutableArray *)messages pts:(int)pts;
@end
@interface TL_updateUserTyping : TGUpdate
+ (TL_updateUserTyping *)createWithUser_id:(int)user_id action:(TL_SendMessageAction *)action;
@end
@interface TL_updateChatUserTyping : TGUpdate
+ (TL_updateChatUserTyping *)createWithChat_id:(int)chat_id user_id:(int)user_id action:(TL_SendMessageAction *)action;
@end
@interface TL_updateChatParticipants : TGUpdate
+ (TL_updateChatParticipants *)createWithParticipants:(TGChatParticipants *)participants;
@end
@interface TL_updateUserStatus : TGUpdate
+ (TL_updateUserStatus *)createWithUser_id:(int)user_id status:(TGUserStatus *)status;
@end
@interface TL_updateUserName : TGUpdate
+ (TL_updateUserName *)createWithUser_id:(int)user_id first_name:(NSString *)first_name last_name:(NSString *)last_name user_name:(NSString *)user_name;
@end
@interface TL_updateUserPhoto : TGUpdate
+ (TL_updateUserPhoto *)createWithUser_id:(int)user_id date:(int)date photo:(TGUserProfilePhoto *)photo previous:(BOOL)previous;
@end
@interface TL_updateContactRegistered : TGUpdate
+ (TL_updateContactRegistered *)createWithUser_id:(int)user_id date:(int)date;
@end
@interface TL_updateContactLink : TGUpdate
+ (TL_updateContactLink *)createWithUser_id:(int)user_id my_link:(TGcontacts_MyLink *)my_link foreign_link:(TGcontacts_ForeignLink *)foreign_link;
@end
@interface TL_updateActivation : TGUpdate
+ (TL_updateActivation *)createWithUser_id:(int)user_id;
@end
@interface TL_updateNewAuthorization : TGUpdate
+ (TL_updateNewAuthorization *)createWithAuth_key_id:(long)auth_key_id date:(int)date device:(NSString *)device location:(NSString *)location;
@end
@interface TL_updateNewGeoChatMessage : TGUpdate
+ (TL_updateNewGeoChatMessage *)createWithGeo_message:(TGGeoChatMessage *)geo_message;
@end
@interface TL_updateNewEncryptedMessage : TGUpdate
+ (TL_updateNewEncryptedMessage *)createWithEncrypted_message:(TGEncryptedMessage *)encrypted_message qts:(int)qts;
@end
@interface TL_updateEncryptedChatTyping : TGUpdate
+ (TL_updateEncryptedChatTyping *)createWithChat_id:(int)chat_id;
@end
@interface TL_updateEncryption : TGUpdate
+ (TL_updateEncryption *)createWithChat:(TGEncryptedChat *)chat date:(int)date;
@end
@interface TL_updateEncryptedMessagesRead : TGUpdate
+ (TL_updateEncryptedMessagesRead *)createWithChat_id:(int)chat_id max_date:(int)max_date date:(int)date;
@end
@interface TL_updateChatParticipantAdd : TGUpdate
+ (TL_updateChatParticipantAdd *)createWithChat_id:(int)chat_id user_id:(int)user_id inviter_id:(int)inviter_id version:(int)version;
@end
@interface TL_updateChatParticipantDelete : TGUpdate
+ (TL_updateChatParticipantDelete *)createWithChat_id:(int)chat_id user_id:(int)user_id version:(int)version;
@end
@interface TL_updateDcOptions : TGUpdate
+ (TL_updateDcOptions *)createWithDc_options:(NSMutableArray *)dc_options;
@end
@interface TL_updateUserBlocked : TGUpdate
+ (TL_updateUserBlocked *)createWithUser_id:(int)user_id blocked:(BOOL)blocked;
@end
@interface TL_updateNotifySettings : TGUpdate
+ (TL_updateNotifySettings *)createWithPeer:(TGNotifyPeer *)peer notify_settings:(TGPeerNotifySettings *)notify_settings;
@end
	
@interface TGupdates_State : TLObject
@property (nonatomic) int pts;
@property (nonatomic) int qts;
@property (nonatomic) int date;
@property (nonatomic) int seq;
@property (nonatomic) int unread_count;
@end

@interface TL_updates_state : TGupdates_State
+ (TL_updates_state *)createWithPts:(int)pts qts:(int)qts date:(int)date seq:(int)seq unread_count:(int)unread_count;
@end
	
@interface TGupdates_Difference : TLObject
@property (nonatomic) int date;
@property (nonatomic) int seq;
@property (nonatomic, strong) NSMutableArray *n_messages;
@property (nonatomic, strong) NSMutableArray *n_encrypted_messages;
@property (nonatomic, strong) NSMutableArray *other_updates;
@property (nonatomic, strong) NSMutableArray *chats;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) TGupdates_State *state;
@property (nonatomic, strong) TGupdates_State *intermediate_state;
@end

@interface TL_updates_differenceEmpty : TGupdates_Difference
+ (TL_updates_differenceEmpty *)createWithDate:(int)date seq:(int)seq;
@end
@interface TL_updates_difference : TGupdates_Difference
+ (TL_updates_difference *)createWithN_messages:(NSMutableArray *)n_messages n_encrypted_messages:(NSMutableArray *)n_encrypted_messages other_updates:(NSMutableArray *)other_updates chats:(NSMutableArray *)chats users:(NSMutableArray *)users state:(TGupdates_State *)state;
@end
@interface TL_updates_differenceSlice : TGupdates_Difference
+ (TL_updates_differenceSlice *)createWithN_messages:(NSMutableArray *)n_messages n_encrypted_messages:(NSMutableArray *)n_encrypted_messages other_updates:(NSMutableArray *)other_updates chats:(NSMutableArray *)chats users:(NSMutableArray *)users intermediate_state:(TGupdates_State *)intermediate_state;
@end
	
@interface TGUpdates : TLObject
@property (nonatomic) int n_id;
@property (nonatomic) int from_id;
@property (nonatomic, strong) NSString *message;
@property (nonatomic) int pts;
@property (nonatomic) int date;
@property (nonatomic) int seq;
@property (nonatomic) int chat_id;
@property (nonatomic, strong) TGUpdate *update;
@property (nonatomic, strong) NSMutableArray *updates;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *chats;
@property (nonatomic) int seq_start;
@end

@interface TL_updatesTooLong : TGUpdates
+ (TL_updatesTooLong *)create;
@end
@interface TL_updateShortMessage : TGUpdates
+ (TL_updateShortMessage *)createWithN_id:(int)n_id from_id:(int)from_id message:(NSString *)message pts:(int)pts date:(int)date seq:(int)seq;
@end
@interface TL_updateShortChatMessage : TGUpdates
+ (TL_updateShortChatMessage *)createWithN_id:(int)n_id from_id:(int)from_id chat_id:(int)chat_id message:(NSString *)message pts:(int)pts date:(int)date seq:(int)seq;
@end
@interface TL_updateShort : TGUpdates
+ (TL_updateShort *)createWithUpdate:(TGUpdate *)update date:(int)date;
@end
@interface TL_updatesCombined : TGUpdates
+ (TL_updatesCombined *)createWithUpdates:(NSMutableArray *)updates users:(NSMutableArray *)users chats:(NSMutableArray *)chats date:(int)date seq_start:(int)seq_start seq:(int)seq;
@end
@interface TL_updates : TGUpdates
+ (TL_updates *)createWithUpdates:(NSMutableArray *)updates users:(NSMutableArray *)users chats:(NSMutableArray *)chats date:(int)date seq:(int)seq;
@end
	
@interface TGphotos_Photos : TLObject
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic) int n_count;
@end

@interface TL_photos_photos : TGphotos_Photos
+ (TL_photos_photos *)createWithPhotos:(NSMutableArray *)photos users:(NSMutableArray *)users;
@end
@interface TL_photos_photosSlice : TGphotos_Photos
+ (TL_photos_photosSlice *)createWithN_count:(int)n_count photos:(NSMutableArray *)photos users:(NSMutableArray *)users;
@end
	
@interface TGphotos_Photo : TLObject
@property (nonatomic, strong) TGPhoto *photo;
@property (nonatomic, strong) NSMutableArray *users;
@end

@interface TL_photos_photo : TGphotos_Photo
+ (TL_photos_photo *)createWithPhoto:(TGPhoto *)photo users:(NSMutableArray *)users;
@end
	
@interface TGupload_File : TLObject
@property (nonatomic, strong) TGstorage_FileType *type;
@property (nonatomic) int mtime;
@property (nonatomic, strong) NSData *bytes;
@end

@interface TL_upload_file : TGupload_File
+ (TL_upload_file *)createWithType:(TGstorage_FileType *)type mtime:(int)mtime bytes:(NSData *)bytes;
@end
	
@interface TGDcOption : TLObject
@property (nonatomic) int n_id;
@property (nonatomic, strong) NSString *hostname;
@property (nonatomic, strong) NSString *ip_address;
@property (nonatomic) int port;
@end

@interface TL_dcOption : TGDcOption
+ (TL_dcOption *)createWithN_id:(int)n_id hostname:(NSString *)hostname ip_address:(NSString *)ip_address port:(int)port;
@end
	
@interface TGConfig : TLObject
@property (nonatomic) int date;
@property BOOL test_mode;
@property (nonatomic) int this_dc;
@property (nonatomic, strong) NSMutableArray *dc_options;
@property (nonatomic) int chat_size_max;
@property (nonatomic) int broadcast_size_max;
@end

@interface TL_config : TGConfig
+ (TL_config *)createWithDate:(int)date test_mode:(BOOL)test_mode this_dc:(int)this_dc dc_options:(NSMutableArray *)dc_options chat_size_max:(int)chat_size_max broadcast_size_max:(int)broadcast_size_max;
@end
	
@interface TGNearestDc : TLObject
@property (nonatomic, strong) NSString *country;
@property (nonatomic) int this_dc;
@property (nonatomic) int nearest_dc;
@end

@interface TL_nearestDc : TGNearestDc
+ (TL_nearestDc *)createWithCountry:(NSString *)country this_dc:(int)this_dc nearest_dc:(int)nearest_dc;
@end
	
@interface TGhelp_AppUpdate : TLObject
@property (nonatomic) int n_id;
@property BOOL critical;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *text;
@end

@interface TL_help_appUpdate : TGhelp_AppUpdate
+ (TL_help_appUpdate *)createWithN_id:(int)n_id critical:(BOOL)critical url:(NSString *)url text:(NSString *)text;
@end
@interface TL_help_noAppUpdate : TGhelp_AppUpdate
+ (TL_help_noAppUpdate *)create;
@end
	
@interface TGhelp_InviteText : TLObject
@property (nonatomic, strong) NSString *message;
@end

@interface TL_help_inviteText : TGhelp_InviteText
+ (TL_help_inviteText *)createWithMessage:(NSString *)message;
@end
	
@interface TGInputGeoChat : TLObject
@property (nonatomic) int chat_id;
@property long access_hash;
@end

@interface TL_inputGeoChat : TGInputGeoChat
+ (TL_inputGeoChat *)createWithChat_id:(int)chat_id access_hash:(long)access_hash;
@end
	
@interface TGGeoChatMessage : TLObject
@property (nonatomic) int chat_id;
@property (nonatomic) int n_id;
@property (nonatomic) int from_id;
@property (nonatomic) int date;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) TGMessageMedia *media;
@property (nonatomic, strong) TGMessageAction *action;
@end

@interface TL_geoChatMessageEmpty : TGGeoChatMessage
+ (TL_geoChatMessageEmpty *)createWithChat_id:(int)chat_id n_id:(int)n_id;
@end
@interface TL_geoChatMessage : TGGeoChatMessage
+ (TL_geoChatMessage *)createWithChat_id:(int)chat_id n_id:(int)n_id from_id:(int)from_id date:(int)date message:(NSString *)message media:(TGMessageMedia *)media;
@end
@interface TL_geoChatMessageService : TGGeoChatMessage
+ (TL_geoChatMessageService *)createWithChat_id:(int)chat_id n_id:(int)n_id from_id:(int)from_id date:(int)date action:(TGMessageAction *)action;
@end
	
@interface TGgeochats_StatedMessage : TLObject
@property (nonatomic, strong) TGGeoChatMessage *message;
@property (nonatomic, strong) NSMutableArray *chats;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic) int seq;
@end

@interface TL_geochats_statedMessage : TGgeochats_StatedMessage
+ (TL_geochats_statedMessage *)createWithMessage:(TGGeoChatMessage *)message chats:(NSMutableArray *)chats users:(NSMutableArray *)users seq:(int)seq;
@end
	
@interface TGgeochats_Located : TLObject
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *chats;
@property (nonatomic, strong) NSMutableArray *users;
@end

@interface TL_geochats_located : TGgeochats_Located
+ (TL_geochats_located *)createWithResults:(NSMutableArray *)results messages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users;
@end
	
@interface TGgeochats_Messages : TLObject
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *chats;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic) int n_count;
@end

@interface TL_geochats_messages : TGgeochats_Messages
+ (TL_geochats_messages *)createWithMessages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users;
@end
@interface TL_geochats_messagesSlice : TGgeochats_Messages
+ (TL_geochats_messagesSlice *)createWithN_count:(int)n_count messages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users;
@end
	
@interface TGEncryptedChat : TLObject
@property (nonatomic) int n_id;
@property long access_hash;
@property (nonatomic) int date;
@property (nonatomic) int admin_id;
@property (nonatomic) int participant_id;
@property (nonatomic, strong) NSData *g_a;
@property (nonatomic, strong) NSData *g_a_or_b;
@property long key_fingerprint;
@end

@interface TL_encryptedChatEmpty : TGEncryptedChat
+ (TL_encryptedChatEmpty *)createWithN_id:(int)n_id;
@end
@interface TL_encryptedChatWaiting : TGEncryptedChat
+ (TL_encryptedChatWaiting *)createWithN_id:(int)n_id access_hash:(long)access_hash date:(int)date admin_id:(int)admin_id participant_id:(int)participant_id;
@end
@interface TL_encryptedChatRequested : TGEncryptedChat
+ (TL_encryptedChatRequested *)createWithN_id:(int)n_id access_hash:(long)access_hash date:(int)date admin_id:(int)admin_id participant_id:(int)participant_id g_a:(NSData *)g_a;
@end
@interface TL_encryptedChat : TGEncryptedChat
+ (TL_encryptedChat *)createWithN_id:(int)n_id access_hash:(long)access_hash date:(int)date admin_id:(int)admin_id participant_id:(int)participant_id g_a_or_b:(NSData *)g_a_or_b key_fingerprint:(long)key_fingerprint;
@end
@interface TL_encryptedChatDiscarded : TGEncryptedChat
+ (TL_encryptedChatDiscarded *)createWithN_id:(int)n_id;
@end
	
@interface TGInputEncryptedChat : TLObject
@property (nonatomic) int chat_id;
@property long access_hash;
@end

@interface TL_inputEncryptedChat : TGInputEncryptedChat
+ (TL_inputEncryptedChat *)createWithChat_id:(int)chat_id access_hash:(long)access_hash;
@end
	
@interface TGEncryptedFile : TLObject
@property long n_id;
@property long access_hash;
@property (nonatomic) int size;
@property (nonatomic) int dc_id;
@property (nonatomic) int key_fingerprint;
@end

@interface TL_encryptedFileEmpty : TGEncryptedFile
+ (TL_encryptedFileEmpty *)create;
@end
@interface TL_encryptedFile : TGEncryptedFile
+ (TL_encryptedFile *)createWithN_id:(long)n_id access_hash:(long)access_hash size:(int)size dc_id:(int)dc_id key_fingerprint:(int)key_fingerprint;
@end
	
@interface TGInputEncryptedFile : TLObject
@property long n_id;
@property (nonatomic) int parts;
@property (nonatomic, strong) NSString *md5_checksum;
@property (nonatomic) int key_fingerprint;
@property long access_hash;
@end

@interface TL_inputEncryptedFileEmpty : TGInputEncryptedFile
+ (TL_inputEncryptedFileEmpty *)create;
@end
@interface TL_inputEncryptedFileUploaded : TGInputEncryptedFile
+ (TL_inputEncryptedFileUploaded *)createWithN_id:(long)n_id parts:(int)parts md5_checksum:(NSString *)md5_checksum key_fingerprint:(int)key_fingerprint;
@end
@interface TL_inputEncryptedFile : TGInputEncryptedFile
+ (TL_inputEncryptedFile *)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
@interface TL_inputEncryptedFileBigUploaded : TGInputEncryptedFile
+ (TL_inputEncryptedFileBigUploaded *)createWithN_id:(long)n_id parts:(int)parts key_fingerprint:(int)key_fingerprint;
@end
	
@interface TGEncryptedMessage : TLObject
@property long random_id;
@property (nonatomic) int chat_id;
@property (nonatomic) int date;
@property (nonatomic, strong) NSData *bytes;
@property (nonatomic, strong) TGEncryptedFile *file;
@end

@interface TL_encryptedMessage : TGEncryptedMessage
+ (TL_encryptedMessage *)createWithRandom_id:(long)random_id chat_id:(int)chat_id date:(int)date bytes:(NSData *)bytes file:(TGEncryptedFile *)file;
@end
@interface TL_encryptedMessageService : TGEncryptedMessage
+ (TL_encryptedMessageService *)createWithRandom_id:(long)random_id chat_id:(int)chat_id date:(int)date bytes:(NSData *)bytes;
@end
	
@interface TGDecryptedMessageLayer : TLObject
@property (nonatomic) int layer;
@property (nonatomic, strong) TGDecryptedMessage *message;
@end

@interface TL_decryptedMessageLayer : TGDecryptedMessageLayer
+ (TL_decryptedMessageLayer *)createWithLayer:(int)layer message:(TGDecryptedMessage *)message;
@end
	
@interface TGDecryptedMessage : TLObject
@property long random_id;
@property (nonatomic, strong) NSData *random_bytes;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) TGDecryptedMessageMedia *media;
@property (nonatomic, strong) TGDecryptedMessageAction *action;
@end

@interface TL_decryptedMessage : TGDecryptedMessage
+ (TL_decryptedMessage *)createWithRandom_id:(long)random_id random_bytes:(NSData *)random_bytes message:(NSString *)message media:(TGDecryptedMessageMedia *)media;
@end
@interface TL_decryptedMessageService : TGDecryptedMessage
+ (TL_decryptedMessageService *)createWithRandom_id:(long)random_id random_bytes:(NSData *)random_bytes action:(TGDecryptedMessageAction *)action;
@end
	
@interface TGDecryptedMessageAction : TLObject
@property (nonatomic) int ttl_seconds;
@property (nonatomic, strong) NSMutableArray *random_ids;
@property (nonatomic) int layer;
@end

@interface TL_decryptedMessageActionSetMessageTTL : TGDecryptedMessageAction
+ (TL_decryptedMessageActionSetMessageTTL *)createWithTtl_seconds:(int)ttl_seconds;
@end
@interface TL_decryptedMessageActionReadMessages : TGDecryptedMessageAction
+ (TL_decryptedMessageActionReadMessages *)createWithRandom_ids:(NSMutableArray *)random_ids;
@end
@interface TL_decryptedMessageActionDeleteMessages : TGDecryptedMessageAction
+ (TL_decryptedMessageActionDeleteMessages *)createWithRandom_ids:(NSMutableArray *)random_ids;
@end
@interface TL_decryptedMessageActionScreenshotMessages : TGDecryptedMessageAction
+ (TL_decryptedMessageActionScreenshotMessages *)createWithRandom_ids:(NSMutableArray *)random_ids;
@end
@interface TL_decryptedMessageActionFlushHistory : TGDecryptedMessageAction
+ (TL_decryptedMessageActionFlushHistory *)create;
@end
@interface TL_decryptedMessageActionNotifyLayer : TGDecryptedMessageAction
+ (TL_decryptedMessageActionNotifyLayer *)createWithLayer:(int)layer;
@end
	
@interface TGmessages_DhConfig : TLObject
@property (nonatomic, strong) NSData *random;
@property (nonatomic) int g;
@property (nonatomic, strong) NSData *p;
@property (nonatomic) int version;
@end

@interface TL_messages_dhConfigNotModified : TGmessages_DhConfig
+ (TL_messages_dhConfigNotModified *)createWithRandom:(NSData *)random;
@end
@interface TL_messages_dhConfig : TGmessages_DhConfig
+ (TL_messages_dhConfig *)createWithG:(int)g p:(NSData *)p version:(int)version random:(NSData *)random;
@end
	
@interface TGmessages_SentEncryptedMessage : TLObject
@property (nonatomic) int date;
@property (nonatomic, strong) TGEncryptedFile *file;
@end

@interface TL_messages_sentEncryptedMessage : TGmessages_SentEncryptedMessage
+ (TL_messages_sentEncryptedMessage *)createWithDate:(int)date;
@end
@interface TL_messages_sentEncryptedFile : TGmessages_SentEncryptedMessage
+ (TL_messages_sentEncryptedFile *)createWithDate:(int)date file:(TGEncryptedFile *)file;
@end
	
@interface TGInputAudio : TLObject
@property long n_id;
@property long access_hash;
@end

@interface TL_inputAudioEmpty : TGInputAudio
+ (TL_inputAudioEmpty *)create;
@end
@interface TL_inputAudio : TGInputAudio
+ (TL_inputAudio *)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
	
@interface TGInputDocument : TLObject
@property long n_id;
@property long access_hash;
@end

@interface TL_inputDocumentEmpty : TGInputDocument
+ (TL_inputDocumentEmpty *)create;
@end
@interface TL_inputDocument : TGInputDocument
+ (TL_inputDocument *)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
	
@interface TGAudio : TLObject
@property long n_id;
@property long access_hash;
@property (nonatomic) int user_id;
@property (nonatomic) int date;
@property (nonatomic) int duration;
@property (nonatomic, strong) NSString *mime_type;
@property (nonatomic) int size;
@property (nonatomic) int dc_id;
@end

@interface TL_audioEmpty : TGAudio
+ (TL_audioEmpty *)createWithN_id:(long)n_id;
@end
@interface TL_audio : TGAudio
+ (TL_audio *)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date duration:(int)duration mime_type:(NSString *)mime_type size:(int)size dc_id:(int)dc_id;
@end
	
@interface TGDocument : TLObject
@property long n_id;
@property long access_hash;
@property (nonatomic) int user_id;
@property (nonatomic) int date;
@property (nonatomic, strong) NSString *file_name;
@property (nonatomic, strong) NSString *mime_type;
@property (nonatomic) int size;
@property (nonatomic, strong) TGPhotoSize *thumb;
@property (nonatomic) int dc_id;
@end

@interface TL_documentEmpty : TGDocument
+ (TL_documentEmpty *)createWithN_id:(long)n_id;
@end
@interface TL_document : TGDocument
+ (TL_document *)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(int)size thumb:(TGPhotoSize *)thumb dc_id:(int)dc_id;
@end
	
@interface TGhelp_Support : TLObject
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic, strong) TGUser *user;
@end

@interface TL_help_support : TGhelp_Support
+ (TL_help_support *)createWithPhone_number:(NSString *)phone_number user:(TGUser *)user;
@end
	
@interface TGNotifyPeer : TLObject
@property (nonatomic, strong) TGPeer *peer;
@end

@interface TL_notifyPeer : TGNotifyPeer
+ (TL_notifyPeer *)createWithPeer:(TGPeer *)peer;
@end
@interface TL_notifyUsers : TGNotifyPeer
+ (TL_notifyUsers *)create;
@end
@interface TL_notifyChats : TGNotifyPeer
+ (TL_notifyChats *)create;
@end
@interface TL_notifyAll : TGNotifyPeer
+ (TL_notifyAll *)create;
@end
	
@interface TGProtoMessage : TLObject
@property long msg_id;
@property (nonatomic) int seqno;
@property (nonatomic) int bytes;
@property (nonatomic, strong) TGObject *body;
@end

@interface TL_proto_message : TGProtoMessage
+ (TL_proto_message *)createWithMsg_id:(long)msg_id seqno:(int)seqno bytes:(int)bytes body:(TGObject *)body;
@end
	
@interface TGProtoMessageContainer : TLObject
@property (nonatomic, strong) NSMutableArray *messages;
@end

@interface TL_msg_container : TGProtoMessageContainer
+ (TL_msg_container *)createWithMessages:(NSMutableArray *)messages;
@end
	
@interface TGResPQ : TLObject
@property (nonatomic, strong) NSData *nonce;
@property (nonatomic, strong) NSData *server_nonce;
@property (nonatomic, strong) NSData *pq;
@property (nonatomic, strong) NSMutableArray *server_public_key_fingerprints;
@end

@interface TL_req_pq : TGResPQ
+ (TL_req_pq *)createWithNonce:(NSData *)nonce;
@end
@interface TL_resPQ : TGResPQ
+ (TL_resPQ *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce pq:(NSData *)pq server_public_key_fingerprints:(NSMutableArray *)server_public_key_fingerprints;
@end
	
@interface TGServer_DH_inner_data : TLObject
@property (nonatomic, strong) NSData *nonce;
@property (nonatomic, strong) NSData *server_nonce;
@property (nonatomic) int g;
@property (nonatomic, strong) NSData *dh_prime;
@property (nonatomic, strong) NSData *g_a;
@property (nonatomic) int server_time;
@end

@interface TL_server_DH_inner_data : TGServer_DH_inner_data
+ (TL_server_DH_inner_data *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce g:(int)g dh_prime:(NSData *)dh_prime g_a:(NSData *)g_a server_time:(int)server_time;
@end
	
@interface TGP_Q_inner_data : TLObject
@property (nonatomic, strong) NSData *pq;
@property (nonatomic, strong) NSData *p;
@property (nonatomic, strong) NSData *q;
@property (nonatomic, strong) NSData *nonce;
@property (nonatomic, strong) NSData *server_nonce;
@property (nonatomic, strong) NSData *n_nonce;
@end

@interface TL_p_q_inner_data : TGP_Q_inner_data
+ (TL_p_q_inner_data *)createWithPq:(NSData *)pq p:(NSData *)p q:(NSData *)q nonce:(NSData *)nonce server_nonce:(NSData *)server_nonce n_nonce:(NSData *)n_nonce;
@end
	
@interface TGServer_DH_Params : TLObject
@property (nonatomic, strong) NSData *nonce;
@property (nonatomic, strong) NSData *server_nonce;
@property (nonatomic, strong) NSData *p;
@property (nonatomic, strong) NSData *q;
@property long public_key_fingerprint;
@property (nonatomic, strong) NSData *encrypted_data;
@property (nonatomic, strong) NSData *n_nonce_hash;
@property (nonatomic, strong) NSData *encrypted_answer;
@end

@interface TL_req_DH_params : TGServer_DH_Params
+ (TL_req_DH_params *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce p:(NSData *)p q:(NSData *)q public_key_fingerprint:(long)public_key_fingerprint encrypted_data:(NSData *)encrypted_data;
@end
@interface TL_server_DH_params_fail : TGServer_DH_Params
+ (TL_server_DH_params_fail *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce n_nonce_hash:(NSData *)n_nonce_hash;
@end
@interface TL_server_DH_params_ok : TGServer_DH_Params
+ (TL_server_DH_params_ok *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce encrypted_answer:(NSData *)encrypted_answer;
@end
	
@interface TGClient_DH_Inner_Data : TLObject
@property (nonatomic, strong) NSData *nonce;
@property (nonatomic, strong) NSData *server_nonce;
@property long retry_id;
@property (nonatomic, strong) NSData *g_b;
@end

@interface TL_client_DH_inner_data : TGClient_DH_Inner_Data
+ (TL_client_DH_inner_data *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce retry_id:(long)retry_id g_b:(NSData *)g_b;
@end
	
@interface TGSet_client_DH_params_answer : TLObject
@property (nonatomic, strong) NSData *nonce;
@property (nonatomic, strong) NSData *server_nonce;
@property (nonatomic, strong) NSData *encrypted_data;
@property (nonatomic, strong) NSData *n_nonce_hash1;
@property (nonatomic, strong) NSData *n_nonce_hash2;
@property (nonatomic, strong) NSData *n_nonce_hash3;
@end

@interface TL_set_client_DH_params : TGSet_client_DH_params_answer
+ (TL_set_client_DH_params *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce encrypted_data:(NSData *)encrypted_data;
@end
@interface TL_dh_gen_ok : TGSet_client_DH_params_answer
+ (TL_dh_gen_ok *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce n_nonce_hash1:(NSData *)n_nonce_hash1;
@end
@interface TL_dh_gen_retry : TGSet_client_DH_params_answer
+ (TL_dh_gen_retry *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce n_nonce_hash2:(NSData *)n_nonce_hash2;
@end
@interface TL_dh_gen_fail : TGSet_client_DH_params_answer
+ (TL_dh_gen_fail *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce n_nonce_hash3:(NSData *)n_nonce_hash3;
@end
	
@interface TGPong : TLObject
@property long ping_id;
@property long msg_id;
@end

@interface TL_ping : TGPong
+ (TL_ping *)createWithPing_id:(long)ping_id;
@end
@interface TL_pong : TGPong
+ (TL_pong *)createWithMsg_id:(long)msg_id ping_id:(long)ping_id;
@end
	
@interface TGBadMsgNotification : TLObject
@property long bad_msg_id;
@property (nonatomic) int bad_msg_seqno;
@property (nonatomic) int error_code;
@property long new_server_salt;
@end

@interface TL_bad_msg_notification : TGBadMsgNotification
+ (TL_bad_msg_notification *)createWithBad_msg_id:(long)bad_msg_id bad_msg_seqno:(int)bad_msg_seqno error_code:(int)error_code;
@end
@interface TL_bad_server_salt : TGBadMsgNotification
+ (TL_bad_server_salt *)createWithBad_msg_id:(long)bad_msg_id bad_msg_seqno:(int)bad_msg_seqno error_code:(int)error_code new_server_salt:(long)new_server_salt;
@end
	
@interface TGNewSession : TLObject
@property long first_msg_id;
@property long unique_id;
@property long server_salt;
@end

@interface TL_new_session_created : TGNewSession
+ (TL_new_session_created *)createWithFirst_msg_id:(long)first_msg_id unique_id:(long)unique_id server_salt:(long)server_salt;
@end
	
@interface TGRpcResult : TLObject
@property long req_msg_id;
@property (nonatomic, strong) TGObject *result;
@end

@interface TL_rpc_result : TGRpcResult
+ (TL_rpc_result *)createWithReq_msg_id:(long)req_msg_id result:(TGObject *)result;
@end
	
@interface TGRpcError : TLObject
@property (nonatomic) int error_code;
@property (nonatomic, strong) NSString *error_message;
@end

@interface TL_rpc_error : TGRpcError
+ (TL_rpc_error *)createWithError_code:(int)error_code error_message:(NSString *)error_message;
@end
	
@interface TGRSAPublicKey : TLObject
@property (nonatomic, strong) NSData *n;
@property (nonatomic, strong) NSData *e;
@end

@interface TL_rsa_public_key : TGRSAPublicKey
+ (TL_rsa_public_key *)createWithN:(NSData *)n e:(NSData *)e;
@end
	
@interface TGMsgsAck : TLObject
@property (nonatomic, strong) NSMutableArray *msg_ids;
@end

@interface TL_msgs_ack : TGMsgsAck
+ (TL_msgs_ack *)createWithMsg_ids:(NSMutableArray *)msg_ids;
@end
	
@interface TGRpcDropAnswer : TLObject
@property long req_msg_id;
@property long msg_id;
@property (nonatomic) int seq_no;
@property (nonatomic) int bytes;
@end

@interface TL_rpc_drop_answer : TGRpcDropAnswer
+ (TL_rpc_drop_answer *)createWithReq_msg_id:(long)req_msg_id;
@end
@interface TL_rpc_answer_unknown : TGRpcDropAnswer
+ (TL_rpc_answer_unknown *)create;
@end
@interface TL_rpc_answer_dropped_running : TGRpcDropAnswer
+ (TL_rpc_answer_dropped_running *)create;
@end
@interface TL_rpc_answer_dropped : TGRpcDropAnswer
+ (TL_rpc_answer_dropped *)createWithMsg_id:(long)msg_id seq_no:(int)seq_no bytes:(int)bytes;
@end
	
@interface TGFutureSalts : TLObject
@property (nonatomic) int num;
@property long req_msg_id;
@property (nonatomic) int now;
@property (nonatomic, strong) NSMutableArray *salts;
@end

@interface TL_get_future_salts : TGFutureSalts
+ (TL_get_future_salts *)createWithNum:(int)num;
@end
@interface TL_future_salts : TGFutureSalts
+ (TL_future_salts *)createWithReq_msg_id:(long)req_msg_id now:(int)now salts:(NSMutableArray *)salts;
@end
	
@interface TGFutureSalt : TLObject
@property (nonatomic) int valid_since;
@property (nonatomic) int valid_until;
@property long salt;
@end

@interface TL_future_salt : TGFutureSalt
+ (TL_future_salt *)createWithValid_since:(int)valid_since valid_until:(int)valid_until salt:(long)salt;
@end
	
@interface TGDestroySessionRes : TLObject
@property long session_id;
@end

@interface TL_destroy_session : TGDestroySessionRes
+ (TL_destroy_session *)createWithSession_id:(long)session_id;
@end
@interface TL_destroy_session_ok : TGDestroySessionRes
+ (TL_destroy_session_ok *)createWithSession_id:(long)session_id;
@end
@interface TL_destroy_session_none : TGDestroySessionRes
+ (TL_destroy_session_none *)createWithSession_id:(long)session_id;
@end
	
@interface TGProtoMessageCopy : TLObject
@property (nonatomic, strong) TGProtoMessage *orig_message;
@end

@interface TL_msg_copy : TGProtoMessageCopy
+ (TL_msg_copy *)createWithOrig_message:(TGProtoMessage *)orig_message;
@end
	
@interface TGObject : TLObject
@property (nonatomic, strong) NSData *packed_data;
@end

@interface TL_gzip_packed : TGObject
+ (TL_gzip_packed *)createWithPacked_data:(NSData *)packed_data;
@end
	
@interface TGHttpWait : TLObject
@property (nonatomic) int max_delay;
@property (nonatomic) int wait_after;
@property (nonatomic) int max_wait;
@end

@interface TL_http_wait : TGHttpWait
+ (TL_http_wait *)createWithMax_delay:(int)max_delay wait_after:(int)wait_after max_wait:(int)max_wait;
@end
	
@interface TGMsgsStateReq : TLObject
@property (nonatomic, strong) NSMutableArray *msg_ids;
@end

@interface TL_msgs_state_req : TGMsgsStateReq
+ (TL_msgs_state_req *)createWithMsg_ids:(NSMutableArray *)msg_ids;
@end
	
@interface TGMsgsStateInfo : TLObject
@property long req_msg_id;
@property (nonatomic, strong) NSData *info;
@end

@interface TL_msgs_state_info : TGMsgsStateInfo
+ (TL_msgs_state_info *)createWithReq_msg_id:(long)req_msg_id info:(NSData *)info;
@end
	
@interface TGMsgsAllInfo : TLObject
@property (nonatomic, strong) NSMutableArray *msg_ids;
@property (nonatomic, strong) NSData *info;
@end

@interface TL_msgs_all_info : TGMsgsAllInfo
+ (TL_msgs_all_info *)createWithMsg_ids:(NSMutableArray *)msg_ids info:(NSData *)info;
@end
	
@interface TGMsgDetailedInfo : TLObject
@property long msg_id;
@property long answer_msg_id;
@property (nonatomic) int bytes;
@property (nonatomic) int status;
@end

@interface TL_msg_detailed_info : TGMsgDetailedInfo
+ (TL_msg_detailed_info *)createWithMsg_id:(long)msg_id answer_msg_id:(long)answer_msg_id bytes:(int)bytes status:(int)status;
@end
@interface TL_msg_new_detailed_info : TGMsgDetailedInfo
+ (TL_msg_new_detailed_info *)createWithAnswer_msg_id:(long)answer_msg_id bytes:(int)bytes status:(int)status;
@end
	
@interface TGMsgResendReq : TLObject
@property (nonatomic, strong) NSMutableArray *msg_ids;
@end

@interface TL_msg_resend_req : TGMsgResendReq
+ (TL_msg_resend_req *)createWithMsg_ids:(NSMutableArray *)msg_ids;
@end


@interface TL_ping_delay_disconnect : TGPong
@property (nonatomic) int delay_disconnect;
+ (TL_ping_delay_disconnect *)createWithPing_id:(long)ping_id delay_disconnect:(int)delay_disconnect;
@end

@interface TL_boolFalse : TLObject
+ (TL_boolFalse *)create;
@end

@interface TL_boolTrue : TLObject
+ (TL_boolTrue *)create;
@end

@interface TGPrivacyKey : TLObject

@end

@interface TGInputPrivacyRule : TLObject
@property (nonatomic,strong) NSMutableArray *users; // inputUsers
@end

@interface TGPrivacyRule : TLObject
@property (nonatomic,strong) NSMutableArray *users; // int vector
@end

@interface TGInputPrivacyKey : TLObject

@end