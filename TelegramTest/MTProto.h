//
//  MTProto.h
//  Telegram
//
//  Auto created by Mikhail Filimonov on 27.11.15.
//  Copyright (c) 2013 Telegram for OS X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLObject.h"
	
@interface TLTrue : TLObject
@end
	
@interface TLInputPeer : TLObject
@end
	
@interface TLInputUser : TLObject
@end
	
@interface TLInputContact : TLObject
@end
	
@interface TLInputFile : TLObject
@end
	
@interface TLInputMedia : TLObject
@end
	
@interface TLInputChatPhoto : TLObject
@end
	
@interface TLInputGeoPoint : TLObject
@end
	
@interface TLInputPhoto : TLObject
@end
	
@interface TLInputVideo : TLObject
@end
	
@interface TLInputFileLocation : TLObject
@end
	
@interface TLInputPhotoCrop : TLObject
@end
	
@interface TLInputAppEvent : TLObject
@end
	
@interface TLPeer : TLObject
@end
	
@interface TLstorage_FileType : TLObject
@end
	
@interface TLFileLocation : TLObject
@end
	
@interface TLUser : TLObject
@end
	
@interface TLUserProfilePhoto : TLObject
@end
	
@interface TLUserStatus : TLObject
@end
	
@interface TLChat : TLObject
@end
	
@interface TLChatFull : TLObject
@end
	
@interface TLChatParticipant : TLObject
@end
	
@interface TLChatParticipants : TLObject
@end
	
@interface TLChatPhoto : TLObject
@end
	
@interface TLMessage : TLObject
@end
	
@interface TLMessageMedia : TLObject
@end
	
@interface TLMessageAction : TLObject
@end
	
@interface TLDialog : TLObject
@end
	
@interface TLPhoto : TLObject
@end
	
@interface TLPhotoSize : TLObject
@end
	
@interface TLVideo : TLObject
@end
	
@interface TLGeoPoint : TLObject
@end
	
@interface TLauth_CheckedPhone : TLObject
@end
	
@interface TLauth_SentCode : TLObject
@end
	
@interface TLauth_Authorization : TLObject
@end
	
@interface TLauth_ExportedAuthorization : TLObject
@end
	
@interface TLInputNotifyPeer : TLObject
@end
	
@interface TLInputPeerNotifyEvents : TLObject
@end
	
@interface TLInputPeerNotifySettings : TLObject
@end
	
@interface TLPeerNotifyEvents : TLObject
@end
	
@interface TLPeerNotifySettings : TLObject
@end
	
@interface TLWallPaper : TLObject
@end
	
@interface TLReportReason : TLObject
@end
	
@interface TLUserFull : TLObject
@end
	
@interface TLContact : TLObject
@end
	
@interface TLImportedContact : TLObject
@end
	
@interface TLContactBlocked : TLObject
@end
	
@interface TLContactSuggested : TLObject
@end
	
@interface TLContactStatus : TLObject
@end
	
@interface TLcontacts_Link : TLObject
@end
	
@interface TLcontacts_Contacts : TLObject
@end
	
@interface TLcontacts_ImportedContacts : TLObject
@end
	
@interface TLcontacts_Blocked : TLObject
@end
	
@interface TLcontacts_Suggested : TLObject
@end
	
@interface TLmessages_Dialogs : TLObject
@end
	
@interface TLmessages_Messages : TLObject
@end
	
@interface TLmessages_Chats : TLObject
@end
	
@interface TLmessages_ChatFull : TLObject
@end
	
@interface TLmessages_AffectedHistory : TLObject
@end
	
@interface TLMessagesFilter : TLObject
@end
	
@interface TLUpdate : TLObject
@end
	
@interface TLupdates_State : TLObject
@end
	
@interface TLupdates_Difference : TLObject
@end
	
@interface TLUpdates : TLObject
@end
	
@interface TLphotos_Photos : TLObject
@end
	
@interface TLphotos_Photo : TLObject
@end
	
@interface TLupload_File : TLObject
@end
	
@interface TLDcOption : TLObject
@end
	
@interface TLConfig : TLObject
@end
	
@interface TLNearestDc : TLObject
@end
	
@interface TLhelp_AppUpdate : TLObject
@end
	
@interface TLhelp_InviteText : TLObject
@end
	
@interface TLEncryptedChat : TLObject
@end
	
@interface TLInputEncryptedChat : TLObject
@end
	
@interface TLEncryptedFile : TLObject
@end
	
@interface TLInputEncryptedFile : TLObject
@end
	
@interface TLEncryptedMessage : TLObject
@end
	
@interface TLmessages_DhConfig : TLObject
@end
	
@interface TLmessages_SentEncryptedMessage : TLObject
@end
	
@interface TLInputAudio : TLObject
@end
	
@interface TLInputDocument : TLObject
@end
	
@interface TLAudio : TLObject
@end
	
@interface TLDocument : TLObject
@end
	
@interface TLhelp_Support : TLObject
@end
	
@interface TLNotifyPeer : TLObject
@end
	
@interface TLSendMessageAction : TLObject
@end
	
@interface TLcontacts_Found : TLObject
@end
	
@interface TLInputPrivacyKey : TLObject
@end
	
@interface TLPrivacyKey : TLObject
@end
	
@interface TLInputPrivacyRule : TLObject
@end
	
@interface TLPrivacyRule : TLObject
@end
	
@interface TLaccount_PrivacyRules : TLObject
@end
	
@interface TLAccountDaysTTL : TLObject
@end
	
@interface TLaccount_SentChangePhoneCode : TLObject
@end
	
@interface TLDocumentAttribute : TLObject
@end
	
@interface TLmessages_Stickers : TLObject
@end
	
@interface TLStickerPack : TLObject
@end
	
@interface TLmessages_AllStickers : TLObject
@end
	
@interface TLDisabledFeature : TLObject
@end
	
@interface TLmessages_AffectedMessages : TLObject
@end
	
@interface TLContactLink : TLObject
@end
	
@interface TLWebPage : TLObject
@end
	
@interface TLAuthorization : TLObject
@end
	
@interface TLaccount_Authorizations : TLObject
@end
	
@interface TLaccount_Password : TLObject
@end
	
@interface TLaccount_PasswordSettings : TLObject
@end
	
@interface TLaccount_PasswordInputSettings : TLObject
@end
	
@interface TLauth_PasswordRecovery : TLObject
@end
	
@interface TLReceivedNotifyMessage : TLObject
@end
	
@interface TLExportedChatInvite : TLObject
@end
	
@interface TLChatInvite : TLObject
@end
	
@interface TLInputStickerSet : TLObject
@end
	
@interface TLStickerSet : TLObject
@end
	
@interface TLmessages_StickerSet : TLObject
@end
	
@interface TLBotCommand : TLObject
@end
	
@interface TLBotInfo : TLObject
@end
	
@interface TLKeyboardButton : TLObject
@end
	
@interface TLKeyboardButtonRow : TLObject
@end
	
@interface TLReplyMarkup : TLObject
@end
	
@interface TLhelp_AppChangelog : TLObject
@end
	
@interface TLMessageEntity : TLObject
@end
	
@interface TLInputChannel : TLObject
@end
	
@interface TLcontacts_ResolvedPeer : TLObject
@end
	
@interface TLMessageRange : TLObject
@end
	
@interface TLMessageGroup : TLObject
@end
	
@interface TLupdates_ChannelDifference : TLObject
@end
	
@interface TLChannelMessagesFilter : TLObject
@end
	
@interface TLChannelParticipant : TLObject
@end
	
@interface TLChannelParticipantsFilter : TLObject
@end
	
@interface TLChannelParticipantRole : TLObject
@end
	
@interface TLchannels_ChannelParticipants : TLObject
@end
	
@interface TLchannels_ChannelParticipant : TLObject
@end
	
@interface TLhelp_TermsOfService : TLObject
@end
	
@interface TLProtoMessage : TLObject
@end
	
@interface TLProtoMessageContainer : TLObject
@end
	
@interface TLResPQ : TLObject
@end
	
@interface TLServer_DH_inner_data : TLObject
@end
	
@interface TLP_Q_inner_data : TLObject
@end
	
@interface TLServer_DH_Params : TLObject
@end
	
@interface TLClient_DH_Inner_Data : TLObject
@end
	
@interface TLSet_client_DH_params_answer : TLObject
@end
	
@interface TLPong : TLObject
@end
	
@interface TLBadMsgNotification : TLObject
@end
	
@interface TLNewSession : TLObject
@end
	
@interface TLRpcResult : TLObject
@end
	
@interface TLRpcError : TLObject
@end
	
@interface TLRSAPublicKey : TLObject
@end
	
@interface TLMsgsAck : TLObject
@end
	
@interface TLRpcDropAnswer : TLObject
@end
	
@interface TLFutureSalts : TLObject
@end
	
@interface TLFutureSalt : TLObject
@end
	
@interface TLDestroySessionRes : TLObject
@end
	
@interface TLProtoMessageCopy : TLObject
@end
	
@interface TLHttpWait : TLObject
@end
	
@interface TLMsgsStateReq : TLObject
@end
	
@interface TLMsgsStateInfo : TLObject
@end
	
@interface TLMsgsAllInfo : TLObject
@end
	
@interface TLMsgDetailedInfo : TLObject
@end
	
@interface TLMsgResendReq : TLObject
@end

@interface TL_boolFalse : TLObject
+(TL_boolFalse*)create;
@end

@interface TL_boolTrue : TLObject
+(TL_boolTrue*)create;
@end


	
@interface TLTrue()

@end

@interface TL_true : TLTrue<NSCoding>
+(TL_true*)create;
@end
	
@interface TLInputPeer()
@property int chat_id;
@property int user_id;
@property long access_hash;
@property int channel_id;
@end

@interface TL_inputPeerEmpty : TLInputPeer<NSCoding>
+(TL_inputPeerEmpty*)create;
@end
@interface TL_inputPeerSelf : TLInputPeer<NSCoding>
+(TL_inputPeerSelf*)create;
@end
@interface TL_inputPeerChat : TLInputPeer<NSCoding>
+(TL_inputPeerChat*)createWithChat_id:(int)chat_id;
@end
@interface TL_inputPeerUser : TLInputPeer<NSCoding>
+(TL_inputPeerUser*)createWithUser_id:(int)user_id access_hash:(long)access_hash;
@end
@interface TL_inputPeerChannel : TLInputPeer<NSCoding>
+(TL_inputPeerChannel*)createWithChannel_id:(int)channel_id access_hash:(long)access_hash;
@end
	
@interface TLInputUser()
@property int user_id;
@property long access_hash;
@end

@interface TL_inputUserEmpty : TLInputUser<NSCoding>
+(TL_inputUserEmpty*)create;
@end
@interface TL_inputUserSelf : TLInputUser<NSCoding>
+(TL_inputUserSelf*)create;
@end
@interface TL_inputUser : TLInputUser<NSCoding>
+(TL_inputUser*)createWithUser_id:(int)user_id access_hash:(long)access_hash;
@end
	
@interface TLInputContact()
@property long client_id;
@property (nonatomic, strong) NSString* phone;
@property (nonatomic, strong) NSString* first_name;
@property (nonatomic, strong) NSString* last_name;
@end

@interface TL_inputPhoneContact : TLInputContact<NSCoding>
+(TL_inputPhoneContact*)createWithClient_id:(long)client_id phone:(NSString*)phone first_name:(NSString*)first_name last_name:(NSString*)last_name;
@end
	
@interface TLInputFile()
@property long n_id;
@property int parts;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* md5_checksum;
@end

@interface TL_inputFile : TLInputFile<NSCoding>
+(TL_inputFile*)createWithN_id:(long)n_id parts:(int)parts name:(NSString*)name md5_checksum:(NSString*)md5_checksum;
@end
@interface TL_inputFileBig : TLInputFile<NSCoding>
+(TL_inputFileBig*)createWithN_id:(long)n_id parts:(int)parts name:(NSString*)name;
@end
	
@interface TLInputMedia()
@property (nonatomic, strong) TLInputFile* file;
@property (nonatomic, strong) NSString* caption;
@property (nonatomic, strong) TLInputDocument* n_id;
@property (nonatomic, strong) TLInputGeoPoint* geo_point;
@property (nonatomic, strong) NSString* phone_number;
@property (nonatomic, strong) NSString* first_name;
@property (nonatomic, strong) NSString* last_name;
@property int duration;
@property int w;
@property int h;
@property (nonatomic, strong) NSString* mime_type;
@property (nonatomic, strong) TLInputFile* thumb;
@property (nonatomic, strong) NSMutableArray* attributes;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSString* provider;
@property (nonatomic, strong) NSString* venue_id;
@end

@interface TL_inputMediaEmpty : TLInputMedia<NSCoding>
+(TL_inputMediaEmpty*)create;
@end
@interface TL_inputMediaUploadedPhoto : TLInputMedia<NSCoding>
+(TL_inputMediaUploadedPhoto*)createWithFile:(TLInputFile*)file caption:(NSString*)caption;
@end
@interface TL_inputMediaPhoto : TLInputMedia<NSCoding>
+(TL_inputMediaPhoto*)createWithN_id:(TLInputPhoto*)n_id caption:(NSString*)caption;
@end
@interface TL_inputMediaGeoPoint : TLInputMedia<NSCoding>
+(TL_inputMediaGeoPoint*)createWithGeo_point:(TLInputGeoPoint*)geo_point;
@end
@interface TL_inputMediaContact : TLInputMedia<NSCoding>
+(TL_inputMediaContact*)createWithPhone_number:(NSString*)phone_number first_name:(NSString*)first_name last_name:(NSString*)last_name;
@end
@interface TL_inputMediaUploadedVideo : TLInputMedia<NSCoding>
+(TL_inputMediaUploadedVideo*)createWithFile:(TLInputFile*)file duration:(int)duration w:(int)w h:(int)h mime_type:(NSString*)mime_type caption:(NSString*)caption;
@end
@interface TL_inputMediaUploadedThumbVideo : TLInputMedia<NSCoding>
+(TL_inputMediaUploadedThumbVideo*)createWithFile:(TLInputFile*)file thumb:(TLInputFile*)thumb duration:(int)duration w:(int)w h:(int)h mime_type:(NSString*)mime_type caption:(NSString*)caption;
@end
@interface TL_inputMediaVideo : TLInputMedia<NSCoding>
+(TL_inputMediaVideo*)createWithN_id:(TLInputVideo*)n_id caption:(NSString*)caption;
@end
@interface TL_inputMediaUploadedAudio : TLInputMedia<NSCoding>
+(TL_inputMediaUploadedAudio*)createWithFile:(TLInputFile*)file duration:(int)duration mime_type:(NSString*)mime_type;
@end
@interface TL_inputMediaAudio : TLInputMedia<NSCoding>
+(TL_inputMediaAudio*)createWithN_id:(TLInputAudio*)n_id;
@end
@interface TL_inputMediaUploadedDocument : TLInputMedia<NSCoding>
+(TL_inputMediaUploadedDocument*)createWithFile:(TLInputFile*)file mime_type:(NSString*)mime_type attributes:(NSMutableArray*)attributes;
@end
@interface TL_inputMediaUploadedThumbDocument : TLInputMedia<NSCoding>
+(TL_inputMediaUploadedThumbDocument*)createWithFile:(TLInputFile*)file thumb:(TLInputFile*)thumb mime_type:(NSString*)mime_type attributes:(NSMutableArray*)attributes;
@end
@interface TL_inputMediaDocument : TLInputMedia<NSCoding>
+(TL_inputMediaDocument*)createWithN_id:(TLInputDocument*)n_id;
@end
@interface TL_inputMediaVenue : TLInputMedia<NSCoding>
+(TL_inputMediaVenue*)createWithGeo_point:(TLInputGeoPoint*)geo_point title:(NSString*)title address:(NSString*)address provider:(NSString*)provider venue_id:(NSString*)venue_id;
@end
@interface TL_inputMediaUploadedVideo_old34 : TLInputMedia<NSCoding>
+(TL_inputMediaUploadedVideo_old34*)createWithFile:(TLInputFile*)file duration:(int)duration w:(int)w h:(int)h caption:(NSString*)caption;
@end
@interface TL_inputMediaUploadedThumbVideo_old32 : TLInputMedia<NSCoding>
+(TL_inputMediaUploadedThumbVideo_old32*)createWithFile:(TLInputFile*)file thumb:(TLInputFile*)thumb duration:(int)duration w:(int)w h:(int)h caption:(NSString*)caption;
@end
	
@interface TLInputChatPhoto()
@property (nonatomic, strong) TLInputFile* file;
@property (nonatomic, strong) TLInputPhotoCrop* crop;
@property (nonatomic, strong) TLInputPhoto* n_id;
@end

@interface TL_inputChatPhotoEmpty : TLInputChatPhoto<NSCoding>
+(TL_inputChatPhotoEmpty*)create;
@end
@interface TL_inputChatUploadedPhoto : TLInputChatPhoto<NSCoding>
+(TL_inputChatUploadedPhoto*)createWithFile:(TLInputFile*)file crop:(TLInputPhotoCrop*)crop;
@end
@interface TL_inputChatPhoto : TLInputChatPhoto<NSCoding>
+(TL_inputChatPhoto*)createWithN_id:(TLInputPhoto*)n_id crop:(TLInputPhotoCrop*)crop;
@end
	
@interface TLInputGeoPoint()
@property double lat;
@property double n_long;
@end

@interface TL_inputGeoPointEmpty : TLInputGeoPoint<NSCoding>
+(TL_inputGeoPointEmpty*)create;
@end
@interface TL_inputGeoPoint : TLInputGeoPoint<NSCoding>
+(TL_inputGeoPoint*)createWithLat:(double)lat n_long:(double)n_long;
@end
	
@interface TLInputPhoto()
@property long n_id;
@property long access_hash;
@end

@interface TL_inputPhotoEmpty : TLInputPhoto<NSCoding>
+(TL_inputPhotoEmpty*)create;
@end
@interface TL_inputPhoto : TLInputPhoto<NSCoding>
+(TL_inputPhoto*)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
	
@interface TLInputVideo()
@property long n_id;
@property long access_hash;
@end

@interface TL_inputVideoEmpty : TLInputVideo<NSCoding>
+(TL_inputVideoEmpty*)create;
@end
@interface TL_inputVideo : TLInputVideo<NSCoding>
+(TL_inputVideo*)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
	
@interface TLInputFileLocation()
@property long volume_id;
@property int local_id;
@property long secret;
@property long n_id;
@property long access_hash;
@end

@interface TL_inputFileLocation : TLInputFileLocation<NSCoding>
+(TL_inputFileLocation*)createWithVolume_id:(long)volume_id local_id:(int)local_id secret:(long)secret;
@end
@interface TL_inputVideoFileLocation : TLInputFileLocation<NSCoding>
+(TL_inputVideoFileLocation*)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
@interface TL_inputEncryptedFileLocation : TLInputFileLocation<NSCoding>
+(TL_inputEncryptedFileLocation*)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
@interface TL_inputAudioFileLocation : TLInputFileLocation<NSCoding>
+(TL_inputAudioFileLocation*)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
@interface TL_inputDocumentFileLocation : TLInputFileLocation<NSCoding>
+(TL_inputDocumentFileLocation*)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
	
@interface TLInputPhotoCrop()
@property double crop_left;
@property double crop_top;
@property double crop_width;
@end

@interface TL_inputPhotoCropAuto : TLInputPhotoCrop<NSCoding>
+(TL_inputPhotoCropAuto*)create;
@end
@interface TL_inputPhotoCrop : TLInputPhotoCrop<NSCoding>
+(TL_inputPhotoCrop*)createWithCrop_left:(double)crop_left crop_top:(double)crop_top crop_width:(double)crop_width;
@end
	
@interface TLInputAppEvent()
@property double time;
@property (nonatomic, strong) NSString* type;
@property long peer;
@property (nonatomic, strong) NSString* data;
@end

@interface TL_inputAppEvent : TLInputAppEvent<NSCoding>
+(TL_inputAppEvent*)createWithTime:(double)time type:(NSString*)type peer:(long)peer data:(NSString*)data;
@end
	
@interface TLPeer()
@property int user_id;
@property int chat_id;
@property int channel_id;
@end

@interface TL_peerUser : TLPeer<NSCoding>
+(TL_peerUser*)createWithUser_id:(int)user_id;
@end
@interface TL_peerChat : TLPeer<NSCoding>
+(TL_peerChat*)createWithChat_id:(int)chat_id;
@end
@interface TL_peerChannel : TLPeer<NSCoding>
+(TL_peerChannel*)createWithChannel_id:(int)channel_id;
@end
	
@interface TLstorage_FileType()

@end

@interface TL_storage_fileUnknown : TLstorage_FileType<NSCoding>
+(TL_storage_fileUnknown*)create;
@end
@interface TL_storage_fileJpeg : TLstorage_FileType<NSCoding>
+(TL_storage_fileJpeg*)create;
@end
@interface TL_storage_fileGif : TLstorage_FileType<NSCoding>
+(TL_storage_fileGif*)create;
@end
@interface TL_storage_filePng : TLstorage_FileType<NSCoding>
+(TL_storage_filePng*)create;
@end
@interface TL_storage_filePdf : TLstorage_FileType<NSCoding>
+(TL_storage_filePdf*)create;
@end
@interface TL_storage_fileMp3 : TLstorage_FileType<NSCoding>
+(TL_storage_fileMp3*)create;
@end
@interface TL_storage_fileMov : TLstorage_FileType<NSCoding>
+(TL_storage_fileMov*)create;
@end
@interface TL_storage_filePartial : TLstorage_FileType<NSCoding>
+(TL_storage_filePartial*)create;
@end
@interface TL_storage_fileMp4 : TLstorage_FileType<NSCoding>
+(TL_storage_fileMp4*)create;
@end
@interface TL_storage_fileWebp : TLstorage_FileType<NSCoding>
+(TL_storage_fileWebp*)create;
@end
	
@interface TLFileLocation()
@property long volume_id;
@property int local_id;
@property long secret;
@property int dc_id;
@end

@interface TL_fileLocationUnavailable : TLFileLocation<NSCoding>
+(TL_fileLocationUnavailable*)createWithVolume_id:(long)volume_id local_id:(int)local_id secret:(long)secret;
@end
@interface TL_fileLocation : TLFileLocation<NSCoding>
+(TL_fileLocation*)createWithDc_id:(int)dc_id volume_id:(long)volume_id local_id:(int)local_id secret:(long)secret;
@end
	
@interface TLUser()
@property int n_id;
@property int flags;
@property (nonatomic,assign,readonly) BOOL isSelf;
@property (nonatomic,assign,readonly) BOOL isContact;
@property (nonatomic,assign,readonly) BOOL isMutual_contact;
@property (nonatomic,assign,readonly) BOOL isDeleted;
@property (nonatomic,assign,readonly) BOOL isBot;
@property (nonatomic,assign,readonly) BOOL isBot_chat_history;
@property (nonatomic,assign,readonly) BOOL isBot_nochats;
@property (nonatomic,assign,readonly) BOOL isVerified;
@property long access_hash;
@property (nonatomic, strong) NSString* first_name;
@property (nonatomic, strong) NSString* last_name;
@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* phone;
@property (nonatomic, strong) TLUserProfilePhoto* photo;
@property (nonatomic, strong) TLUserStatus* status;
@property int bot_info_version;
@end

@interface TL_userEmpty : TLUser<NSCoding>
+(TL_userEmpty*)createWithN_id:(int)n_id;
@end
@interface TL_user : TLUser<NSCoding>
+(TL_user*)createWithFlags:(int)flags         n_id:(int)n_id access_hash:(long)access_hash first_name:(NSString*)first_name last_name:(NSString*)last_name username:(NSString*)username phone:(NSString*)phone photo:(TLUserProfilePhoto*)photo status:(TLUserStatus*)status bot_info_version:(int)bot_info_version;
@end
@interface TL_userSelf : TLUser<NSCoding>
+(TL_userSelf*)createWithN_id:(int)n_id first_name:(NSString*)first_name last_name:(NSString*)last_name username:(NSString*)username phone:(NSString*)phone photo:(TLUserProfilePhoto*)photo status:(TLUserStatus*)status;
@end
@interface TL_userContact : TLUser<NSCoding>
+(TL_userContact*)createWithN_id:(int)n_id first_name:(NSString*)first_name last_name:(NSString*)last_name username:(NSString*)username access_hash:(long)access_hash phone:(NSString*)phone photo:(TLUserProfilePhoto*)photo status:(TLUserStatus*)status;
@end
@interface TL_userRequest : TLUser<NSCoding>
+(TL_userRequest*)createWithN_id:(int)n_id first_name:(NSString*)first_name last_name:(NSString*)last_name username:(NSString*)username access_hash:(long)access_hash phone:(NSString*)phone photo:(TLUserProfilePhoto*)photo status:(TLUserStatus*)status;
@end
@interface TL_userForeign : TLUser<NSCoding>
+(TL_userForeign*)createWithN_id:(int)n_id first_name:(NSString*)first_name last_name:(NSString*)last_name username:(NSString*)username access_hash:(long)access_hash photo:(TLUserProfilePhoto*)photo status:(TLUserStatus*)status;
@end
@interface TL_userDeleted : TLUser<NSCoding>
+(TL_userDeleted*)createWithN_id:(int)n_id first_name:(NSString*)first_name last_name:(NSString*)last_name username:(NSString*)username;
@end
	
@interface TLUserProfilePhoto()
@property long photo_id;
@property (nonatomic, strong) TLFileLocation* photo_small;
@property (nonatomic, strong) TLFileLocation* photo_big;
@end

@interface TL_userProfilePhotoEmpty : TLUserProfilePhoto<NSCoding>
+(TL_userProfilePhotoEmpty*)create;
@end
@interface TL_userProfilePhoto : TLUserProfilePhoto<NSCoding>
+(TL_userProfilePhoto*)createWithPhoto_id:(long)photo_id photo_small:(TLFileLocation*)photo_small photo_big:(TLFileLocation*)photo_big;
@end
	
@interface TLUserStatus()
@property int expires;
@property int was_online;
@end

@interface TL_userStatusEmpty : TLUserStatus<NSCoding>
+(TL_userStatusEmpty*)create;
@end
@interface TL_userStatusOnline : TLUserStatus<NSCoding>
+(TL_userStatusOnline*)createWithExpires:(int)expires;
@end
@interface TL_userStatusOffline : TLUserStatus<NSCoding>
+(TL_userStatusOffline*)createWithWas_online:(int)was_online;
@end
@interface TL_userStatusRecently : TLUserStatus<NSCoding>
+(TL_userStatusRecently*)create;
@end
@interface TL_userStatusLastWeek : TLUserStatus<NSCoding>
+(TL_userStatusLastWeek*)create;
@end
@interface TL_userStatusLastMonth : TLUserStatus<NSCoding>
+(TL_userStatusLastMonth*)create;
@end
	
@interface TLChat()
@property int n_id;
@property int flags;
@property (nonatomic,assign,readonly) BOOL isCreator;
@property (nonatomic,assign,readonly) BOOL isKicked;
@property Boolean left;
@property (nonatomic,assign,readonly) BOOL isAdmins_enabled;
@property (nonatomic,assign,readonly) BOOL isAdmin;
@property (nonatomic,assign,readonly) BOOL isDeactivated;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) TLChatPhoto* photo;
@property int participants_count;
@property int date;
@property int version;
@property (nonatomic, strong) TLInputChannel* migrated_to;
@property (nonatomic,assign,readonly) BOOL isEditor;
@property (nonatomic,assign,readonly) BOOL isModerator;
@property (nonatomic,assign,readonly) BOOL isBroadcast;
@property (nonatomic,assign,readonly) BOOL isVerified;
@property (nonatomic,assign,readonly) BOOL isMegagroup;
@property long access_hash;
@property (nonatomic, strong) NSString* username;
@end

@interface TL_chatEmpty : TLChat<NSCoding>
+(TL_chatEmpty*)createWithN_id:(int)n_id;
@end
@interface TL_chat : TLChat<NSCoding>
+(TL_chat*)createWithFlags:(int)flags       n_id:(int)n_id title:(NSString*)title photo:(TLChatPhoto*)photo participants_count:(int)participants_count date:(int)date version:(int)version migrated_to:(TLInputChannel*)migrated_to;
@end
@interface TL_chatForbidden : TLChat<NSCoding>
+(TL_chatForbidden*)createWithN_id:(int)n_id title:(NSString*)title;
@end
@interface TL_channel : TLChat<NSCoding>
+(TL_channel*)createWithFlags:(int)flags         n_id:(int)n_id access_hash:(long)access_hash title:(NSString*)title username:(NSString*)username photo:(TLChatPhoto*)photo date:(int)date version:(int)version;
@end
@interface TL_channelForbidden : TLChat<NSCoding>
+(TL_channelForbidden*)createWithN_id:(int)n_id access_hash:(long)access_hash title:(NSString*)title;
@end
@interface TL_chat_old34 : TLChat<NSCoding>
+(TL_chat_old34*)createWithN_id:(int)n_id title:(NSString*)title photo:(TLChatPhoto*)photo participants_count:(int)participants_count date:(int)date left:(Boolean)left version:(int)version;
@end
@interface TL_chatForbidden_old34 : TLChat<NSCoding>
+(TL_chatForbidden_old34*)createWithN_id:(int)n_id title:(NSString*)title date:(int)date;
@end
@interface TL_chat_old38 : TLChat<NSCoding>
+(TL_chat_old38*)createWithFlags:(int)flags n_id:(int)n_id title:(NSString*)title photo:(TLChatPhoto*)photo participants_count:(int)participants_count date:(int)date version:(int)version;
@end
	
@interface TLChatFull()
@property int n_id;
@property (nonatomic, strong) TLChatParticipants* participants;
@property (nonatomic, strong) TLPhoto* chat_photo;
@property (nonatomic, strong) TLPeerNotifySettings* notify_settings;
@property (nonatomic, strong) TLExportedChatInvite* exported_invite;
@property (nonatomic, strong) NSMutableArray* bot_info;
@property int flags;
@property (nonatomic,assign,readonly) BOOL isCan_view_participants;
@property (nonatomic, strong) NSString* about;
@property int participants_count;
@property int admins_count;
@property int kicked_count;
@property int read_inbox_max_id;
@property int unread_count;
@property int unread_important_count;
@property int migrated_from_chat_id;
@property int migrated_from_max_id;
@end

@interface TL_chatFull : TLChatFull<NSCoding>
+(TL_chatFull*)createWithN_id:(int)n_id participants:(TLChatParticipants*)participants chat_photo:(TLPhoto*)chat_photo notify_settings:(TLPeerNotifySettings*)notify_settings exported_invite:(TLExportedChatInvite*)exported_invite bot_info:(NSMutableArray*)bot_info;
@end
@interface TL_channelFull : TLChatFull<NSCoding>
+(TL_channelFull*)createWithFlags:(int)flags  n_id:(int)n_id about:(NSString*)about participants_count:(int)participants_count admins_count:(int)admins_count kicked_count:(int)kicked_count read_inbox_max_id:(int)read_inbox_max_id unread_count:(int)unread_count unread_important_count:(int)unread_important_count chat_photo:(TLPhoto*)chat_photo notify_settings:(TLPeerNotifySettings*)notify_settings exported_invite:(TLExportedChatInvite*)exported_invite bot_info:(NSMutableArray*)bot_info migrated_from_chat_id:(int)migrated_from_chat_id migrated_from_max_id:(int)migrated_from_max_id;
@end
@interface TL_chatFull_old29 : TLChatFull<NSCoding>
+(TL_chatFull_old29*)createWithN_id:(int)n_id participants:(TLChatParticipants*)participants chat_photo:(TLPhoto*)chat_photo notify_settings:(TLPeerNotifySettings*)notify_settings exported_invite:(TLExportedChatInvite*)exported_invite;
@end
@interface TL_channelFull_old39 : TLChatFull<NSCoding>
+(TL_channelFull_old39*)createWithFlags:(int)flags  n_id:(int)n_id about:(NSString*)about participants_count:(int)participants_count admins_count:(int)admins_count kicked_count:(int)kicked_count read_inbox_max_id:(int)read_inbox_max_id unread_count:(int)unread_count unread_important_count:(int)unread_important_count chat_photo:(TLPhoto*)chat_photo notify_settings:(TLPeerNotifySettings*)notify_settings exported_invite:(TLExportedChatInvite*)exported_invite;
@end
	
@interface TLChatParticipant()
@property int user_id;
@property int inviter_id;
@property int date;
@end

@interface TL_chatParticipant : TLChatParticipant<NSCoding>
+(TL_chatParticipant*)createWithUser_id:(int)user_id inviter_id:(int)inviter_id date:(int)date;
@end
@interface TL_chatParticipantCreator : TLChatParticipant<NSCoding>
+(TL_chatParticipantCreator*)createWithUser_id:(int)user_id;
@end
@interface TL_chatParticipantAdmin : TLChatParticipant<NSCoding>
+(TL_chatParticipantAdmin*)createWithUser_id:(int)user_id inviter_id:(int)inviter_id date:(int)date;
@end
	
@interface TLChatParticipants()
@property int flags;
@property int chat_id;
@property (nonatomic, strong) TLChatParticipant* self_participant;
@property (nonatomic, strong) NSMutableArray* participants;
@property int version;
@property int admin_id;
@end

@interface TL_chatParticipantsForbidden : TLChatParticipants<NSCoding>
+(TL_chatParticipantsForbidden*)createWithFlags:(int)flags chat_id:(int)chat_id self_participant:(TLChatParticipant*)self_participant;
@end
@interface TL_chatParticipants : TLChatParticipants<NSCoding>
+(TL_chatParticipants*)createWithChat_id:(int)chat_id participants:(NSMutableArray*)participants version:(int)version;
@end
@interface TL_chatParticipantsForbidden_old34 : TLChatParticipants<NSCoding>
+(TL_chatParticipantsForbidden_old34*)createWithChat_id:(int)chat_id;
@end
@interface TL_chatParticipants_old38 : TLChatParticipants<NSCoding>
+(TL_chatParticipants_old38*)createWithChat_id:(int)chat_id admin_id:(int)admin_id participants:(NSMutableArray*)participants version:(int)version;
@end
@interface TL_chatParticipants_old39 : TLChatParticipants<NSCoding>
+(TL_chatParticipants_old39*)createWithChat_id:(int)chat_id admin_id:(int)admin_id participants:(NSMutableArray*)participants version:(int)version;
@end
	
@interface TLChatPhoto()
@property (nonatomic, strong) TLFileLocation* photo_small;
@property (nonatomic, strong) TLFileLocation* photo_big;
@end

@interface TL_chatPhotoEmpty : TLChatPhoto<NSCoding>
+(TL_chatPhotoEmpty*)create;
@end
@interface TL_chatPhoto : TLChatPhoto<NSCoding>
+(TL_chatPhoto*)createWithPhoto_small:(TLFileLocation*)photo_small photo_big:(TLFileLocation*)photo_big;
@end
	
@interface TLMessage()
@property int n_id;
@property int flags;
@property (nonatomic,assign,readonly) BOOL isUnread;
@property (nonatomic,assign,readonly) BOOL isN_out;
@property (nonatomic,assign,readonly) BOOL isMentioned;
@property (nonatomic,assign,readonly) BOOL isMedia_unread;
@property int from_id;
@property (nonatomic, strong) TLPeer* to_id;
@property (nonatomic, strong) TLPeer* fwd_from_id;
@property int fwd_date;
@property int reply_to_msg_id;
@property int date;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) TLMessageMedia* media;
@property (nonatomic, strong) TLReplyMarkup* reply_markup;
@property (nonatomic, strong) NSMutableArray* entities;
@property int views;
@property (nonatomic, strong) TLMessageAction* action;
@end

@interface TL_messageEmpty : TLMessage<NSCoding>
+(TL_messageEmpty*)createWithN_id:(int)n_id;
@end
@interface TL_message : TLMessage<NSCoding>
+(TL_message*)createWithFlags:(int)flags     n_id:(int)n_id from_id:(int)from_id to_id:(TLPeer*)to_id fwd_from_id:(TLPeer*)fwd_from_id fwd_date:(int)fwd_date reply_to_msg_id:(int)reply_to_msg_id date:(int)date message:(NSString*)message media:(TLMessageMedia*)media reply_markup:(TLReplyMarkup*)reply_markup entities:(NSMutableArray*)entities views:(int)views;
@end
@interface TL_messageService : TLMessage<NSCoding>
+(TL_messageService*)createWithFlags:(int)flags     n_id:(int)n_id from_id:(int)from_id to_id:(TLPeer*)to_id date:(int)date action:(TLMessageAction*)action;
@end
	
@interface TLMessageMedia()
@property (nonatomic, strong) TLPhoto* photo;
@property (nonatomic, strong) NSString* caption;
@property (nonatomic, strong) TLVideo* video;
@property (nonatomic, strong) TLGeoPoint* geo;
@property (nonatomic, strong) NSString* phone_number;
@property (nonatomic, strong) NSString* first_name;
@property (nonatomic, strong) NSString* last_name;
@property int user_id;
@property (nonatomic, strong) TLDocument* document;
@property (nonatomic, strong) TLAudio* audio;
@property (nonatomic, strong) TLWebPage* webpage;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSString* provider;
@property (nonatomic, strong) NSString* venue_id;
@end

@interface TL_messageMediaEmpty : TLMessageMedia<NSCoding>
+(TL_messageMediaEmpty*)create;
@end
@interface TL_messageMediaPhoto : TLMessageMedia<NSCoding>
+(TL_messageMediaPhoto*)createWithPhoto:(TLPhoto*)photo caption:(NSString*)caption;
@end
@interface TL_messageMediaVideo : TLMessageMedia<NSCoding>
+(TL_messageMediaVideo*)createWithVideo:(TLVideo*)video caption:(NSString*)caption;
@end
@interface TL_messageMediaGeo : TLMessageMedia<NSCoding>
+(TL_messageMediaGeo*)createWithGeo:(TLGeoPoint*)geo;
@end
@interface TL_messageMediaContact : TLMessageMedia<NSCoding>
+(TL_messageMediaContact*)createWithPhone_number:(NSString*)phone_number first_name:(NSString*)first_name last_name:(NSString*)last_name user_id:(int)user_id;
@end
@interface TL_messageMediaUnsupported : TLMessageMedia<NSCoding>
+(TL_messageMediaUnsupported*)create;
@end
@interface TL_messageMediaDocument : TLMessageMedia<NSCoding>
+(TL_messageMediaDocument*)createWithDocument:(TLDocument*)document;
@end
@interface TL_messageMediaAudio : TLMessageMedia<NSCoding>
+(TL_messageMediaAudio*)createWithAudio:(TLAudio*)audio;
@end
@interface TL_messageMediaWebPage : TLMessageMedia<NSCoding>
+(TL_messageMediaWebPage*)createWithWebpage:(TLWebPage*)webpage;
@end
@interface TL_messageMediaVenue : TLMessageMedia<NSCoding>
+(TL_messageMediaVenue*)createWithGeo:(TLGeoPoint*)geo title:(NSString*)title address:(NSString*)address provider:(NSString*)provider venue_id:(NSString*)venue_id;
@end
	
@interface TLMessageAction()
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSMutableArray* users;
@property (nonatomic, strong) TLPhoto* photo;
@property int user_id;
@property int inviter_id;
@property int channel_id;
@property int chat_id;
@end

@interface TL_messageActionEmpty : TLMessageAction<NSCoding>
+(TL_messageActionEmpty*)create;
@end
@interface TL_messageActionChatCreate : TLMessageAction<NSCoding>
+(TL_messageActionChatCreate*)createWithTitle:(NSString*)title users:(NSMutableArray*)users;
@end
@interface TL_messageActionChatEditTitle : TLMessageAction<NSCoding>
+(TL_messageActionChatEditTitle*)createWithTitle:(NSString*)title;
@end
@interface TL_messageActionChatEditPhoto : TLMessageAction<NSCoding>
+(TL_messageActionChatEditPhoto*)createWithPhoto:(TLPhoto*)photo;
@end
@interface TL_messageActionChatDeletePhoto : TLMessageAction<NSCoding>
+(TL_messageActionChatDeletePhoto*)create;
@end
@interface TL_messageActionChatAddUser : TLMessageAction<NSCoding>
+(TL_messageActionChatAddUser*)createWithUsers:(NSMutableArray*)users;
@end
@interface TL_messageActionChatDeleteUser : TLMessageAction<NSCoding>
+(TL_messageActionChatDeleteUser*)createWithUser_id:(int)user_id;
@end
@interface TL_messageActionChatJoinedByLink : TLMessageAction<NSCoding>
+(TL_messageActionChatJoinedByLink*)createWithInviter_id:(int)inviter_id;
@end
@interface TL_messageActionChannelCreate : TLMessageAction<NSCoding>
+(TL_messageActionChannelCreate*)createWithTitle:(NSString*)title;
@end
@interface TL_messageActionChatMigrateTo : TLMessageAction<NSCoding>
+(TL_messageActionChatMigrateTo*)createWithChannel_id:(int)channel_id;
@end
@interface TL_messageActionChannelMigrateFrom : TLMessageAction<NSCoding>
+(TL_messageActionChannelMigrateFrom*)createWithTitle:(NSString*)title chat_id:(int)chat_id;
@end
@interface TL_messageActionChatAddUser_old40 : TLMessageAction<NSCoding>
+(TL_messageActionChatAddUser_old40*)createWithUser_id:(int)user_id;
@end
	
@interface TLDialog()
@property (nonatomic, strong) TLPeer* peer;
@property int top_message;
@property int read_inbox_max_id;
@property int unread_count;
@property (nonatomic, strong) TLPeerNotifySettings* notify_settings;
@property int top_important_message;
@property int unread_important_count;
@property int pts;
@end

@interface TL_dialog : TLDialog<NSCoding>
+(TL_dialog*)createWithPeer:(TLPeer*)peer top_message:(int)top_message read_inbox_max_id:(int)read_inbox_max_id unread_count:(int)unread_count notify_settings:(TLPeerNotifySettings*)notify_settings;
@end
@interface TL_dialogChannel : TLDialog<NSCoding>
+(TL_dialogChannel*)createWithPeer:(TLPeer*)peer top_message:(int)top_message top_important_message:(int)top_important_message read_inbox_max_id:(int)read_inbox_max_id unread_count:(int)unread_count unread_important_count:(int)unread_important_count notify_settings:(TLPeerNotifySettings*)notify_settings pts:(int)pts;
@end
	
@interface TLPhoto()
@property long n_id;
@property long access_hash;
@property int date;
@property (nonatomic, strong) NSMutableArray* sizes;
@property int user_id;
@property (nonatomic, strong) TLGeoPoint* geo;
@end

@interface TL_photoEmpty : TLPhoto<NSCoding>
+(TL_photoEmpty*)createWithN_id:(long)n_id;
@end
@interface TL_photo : TLPhoto<NSCoding>
+(TL_photo*)createWithN_id:(long)n_id access_hash:(long)access_hash date:(int)date sizes:(NSMutableArray*)sizes;
@end
@interface TL_photo_old31 : TLPhoto<NSCoding>
+(TL_photo_old31*)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date geo:(TLGeoPoint*)geo sizes:(NSMutableArray*)sizes;
@end
	
@interface TLPhotoSize()
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) TLFileLocation* location;
@property int w;
@property int h;
@property int size;
@property (nonatomic, strong) NSData* bytes;
@end

@interface TL_photoSizeEmpty : TLPhotoSize<NSCoding>
+(TL_photoSizeEmpty*)createWithType:(NSString*)type;
@end
@interface TL_photoSize : TLPhotoSize<NSCoding>
+(TL_photoSize*)createWithType:(NSString*)type location:(TLFileLocation*)location w:(int)w h:(int)h size:(int)size;
@end
@interface TL_photoCachedSize : TLPhotoSize<NSCoding>
+(TL_photoCachedSize*)createWithType:(NSString*)type location:(TLFileLocation*)location w:(int)w h:(int)h bytes:(NSData*)bytes;
@end
	
@interface TLVideo()
@property long n_id;
@property long access_hash;
@property int date;
@property int duration;
@property (nonatomic, strong) NSString* mime_type;
@property int size;
@property (nonatomic, strong) TLPhotoSize* thumb;
@property int dc_id;
@property int w;
@property int h;
@property int user_id;
@end

@interface TL_videoEmpty : TLVideo<NSCoding>
+(TL_videoEmpty*)createWithN_id:(long)n_id;
@end
@interface TL_video : TLVideo<NSCoding>
+(TL_video*)createWithN_id:(long)n_id access_hash:(long)access_hash date:(int)date duration:(int)duration mime_type:(NSString*)mime_type size:(int)size thumb:(TLPhotoSize*)thumb dc_id:(int)dc_id w:(int)w h:(int)h;
@end
@interface TL_video_old29 : TLVideo<NSCoding>
+(TL_video_old29*)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date duration:(int)duration size:(int)size thumb:(TLPhotoSize*)thumb dc_id:(int)dc_id w:(int)w h:(int)h;
@end
	
@interface TLGeoPoint()
@property double n_long;
@property double lat;
@end

@interface TL_geoPointEmpty : TLGeoPoint<NSCoding>
+(TL_geoPointEmpty*)create;
@end
@interface TL_geoPoint : TLGeoPoint<NSCoding>
+(TL_geoPoint*)createWithN_long:(double)n_long lat:(double)lat;
@end
	
@interface TLauth_CheckedPhone()
@property Boolean phone_registered;
@end

@interface TL_auth_checkedPhone : TLauth_CheckedPhone<NSCoding>
+(TL_auth_checkedPhone*)createWithPhone_registered:(Boolean)phone_registered;
@end
	
@interface TLauth_SentCode()
@property Boolean phone_registered;
@property (nonatomic, strong) NSString* phone_code_hash;
@property int send_call_timeout;
@property Boolean is_password;
@end

@interface TL_auth_sentCode : TLauth_SentCode<NSCoding>
+(TL_auth_sentCode*)createWithPhone_registered:(Boolean)phone_registered phone_code_hash:(NSString*)phone_code_hash send_call_timeout:(int)send_call_timeout is_password:(Boolean)is_password;
@end
@interface TL_auth_sentAppCode : TLauth_SentCode<NSCoding>
+(TL_auth_sentAppCode*)createWithPhone_registered:(Boolean)phone_registered phone_code_hash:(NSString*)phone_code_hash send_call_timeout:(int)send_call_timeout is_password:(Boolean)is_password;
@end
	
@interface TLauth_Authorization()
@property (nonatomic, strong) TLUser* user;
@end

@interface TL_auth_authorization : TLauth_Authorization<NSCoding>
+(TL_auth_authorization*)createWithUser:(TLUser*)user;
@end
	
@interface TLauth_ExportedAuthorization()
@property int n_id;
@property (nonatomic, strong) NSData* bytes;
@end

@interface TL_auth_exportedAuthorization : TLauth_ExportedAuthorization<NSCoding>
+(TL_auth_exportedAuthorization*)createWithN_id:(int)n_id bytes:(NSData*)bytes;
@end
	
@interface TLInputNotifyPeer()
@property (nonatomic, strong) TLInputPeer* peer;
@end

@interface TL_inputNotifyPeer : TLInputNotifyPeer<NSCoding>
+(TL_inputNotifyPeer*)createWithPeer:(TLInputPeer*)peer;
@end
@interface TL_inputNotifyUsers : TLInputNotifyPeer<NSCoding>
+(TL_inputNotifyUsers*)create;
@end
@interface TL_inputNotifyChats : TLInputNotifyPeer<NSCoding>
+(TL_inputNotifyChats*)create;
@end
@interface TL_inputNotifyAll : TLInputNotifyPeer<NSCoding>
+(TL_inputNotifyAll*)create;
@end
	
@interface TLInputPeerNotifyEvents()

@end

@interface TL_inputPeerNotifyEventsEmpty : TLInputPeerNotifyEvents<NSCoding>
+(TL_inputPeerNotifyEventsEmpty*)create;
@end
@interface TL_inputPeerNotifyEventsAll : TLInputPeerNotifyEvents<NSCoding>
+(TL_inputPeerNotifyEventsAll*)create;
@end
	
@interface TLInputPeerNotifySettings()
@property int mute_until;
@property (nonatomic, strong) NSString* sound;
@property Boolean show_previews;
@property int events_mask;
@end

@interface TL_inputPeerNotifySettings : TLInputPeerNotifySettings<NSCoding>
+(TL_inputPeerNotifySettings*)createWithMute_until:(int)mute_until sound:(NSString*)sound show_previews:(Boolean)show_previews events_mask:(int)events_mask;
@end
	
@interface TLPeerNotifyEvents()

@end

@interface TL_peerNotifyEventsEmpty : TLPeerNotifyEvents<NSCoding>
+(TL_peerNotifyEventsEmpty*)create;
@end
@interface TL_peerNotifyEventsAll : TLPeerNotifyEvents<NSCoding>
+(TL_peerNotifyEventsAll*)create;
@end
	
@interface TLPeerNotifySettings()
@property int mute_until;
@property (nonatomic, strong) NSString* sound;
@property Boolean show_previews;
@property int events_mask;
@end

@interface TL_peerNotifySettingsEmpty : TLPeerNotifySettings<NSCoding>
+(TL_peerNotifySettingsEmpty*)create;
@end
@interface TL_peerNotifySettings : TLPeerNotifySettings<NSCoding>
+(TL_peerNotifySettings*)createWithMute_until:(int)mute_until sound:(NSString*)sound show_previews:(Boolean)show_previews events_mask:(int)events_mask;
@end
	
@interface TLWallPaper()
@property int n_id;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSMutableArray* sizes;
@property int color;
@property int bg_color;
@end

@interface TL_wallPaper : TLWallPaper<NSCoding>
+(TL_wallPaper*)createWithN_id:(int)n_id title:(NSString*)title sizes:(NSMutableArray*)sizes color:(int)color;
@end
@interface TL_wallPaperSolid : TLWallPaper<NSCoding>
+(TL_wallPaperSolid*)createWithN_id:(int)n_id title:(NSString*)title bg_color:(int)bg_color color:(int)color;
@end
	
@interface TLReportReason()
@property (nonatomic, strong) NSString* text;
@end

@interface TL_inputReportReasonSpam : TLReportReason<NSCoding>
+(TL_inputReportReasonSpam*)create;
@end
@interface TL_inputReportReasonViolence : TLReportReason<NSCoding>
+(TL_inputReportReasonViolence*)create;
@end
@interface TL_inputReportReasonPornography : TLReportReason<NSCoding>
+(TL_inputReportReasonPornography*)create;
@end
@interface TL_inputReportReasonOther : TLReportReason<NSCoding>
+(TL_inputReportReasonOther*)createWithText:(NSString*)text;
@end
	
@interface TLUserFull()
@property (nonatomic, strong) TLUser* user;
@property (nonatomic, strong) TLcontacts_Link* link;
@property (nonatomic, strong) TLPhoto* profile_photo;
@property (nonatomic, strong) TLPeerNotifySettings* notify_settings;
@property Boolean blocked;
@property (nonatomic, strong) TLBotInfo* bot_info;
@end

@interface TL_userFull : TLUserFull<NSCoding>
+(TL_userFull*)createWithUser:(TLUser*)user link:(TLcontacts_Link*)link profile_photo:(TLPhoto*)profile_photo notify_settings:(TLPeerNotifySettings*)notify_settings blocked:(Boolean)blocked bot_info:(TLBotInfo*)bot_info;
@end
	
@interface TLContact()
@property int user_id;
@property Boolean mutual;
@end

@interface TL_contact : TLContact<NSCoding>
+(TL_contact*)createWithUser_id:(int)user_id mutual:(Boolean)mutual;
@end
	
@interface TLImportedContact()
@property int user_id;
@property long client_id;
@end

@interface TL_importedContact : TLImportedContact<NSCoding>
+(TL_importedContact*)createWithUser_id:(int)user_id client_id:(long)client_id;
@end
	
@interface TLContactBlocked()
@property int user_id;
@property int date;
@end

@interface TL_contactBlocked : TLContactBlocked<NSCoding>
+(TL_contactBlocked*)createWithUser_id:(int)user_id date:(int)date;
@end
	
@interface TLContactSuggested()
@property int user_id;
@property int mutual_contacts;
@end

@interface TL_contactSuggested : TLContactSuggested<NSCoding>
+(TL_contactSuggested*)createWithUser_id:(int)user_id mutual_contacts:(int)mutual_contacts;
@end
	
@interface TLContactStatus()
@property int user_id;
@property (nonatomic, strong) TLUserStatus* status;
@end

@interface TL_contactStatus : TLContactStatus<NSCoding>
+(TL_contactStatus*)createWithUser_id:(int)user_id status:(TLUserStatus*)status;
@end
	
@interface TLcontacts_Link()
@property (nonatomic, strong) TLContactLink* my_link;
@property (nonatomic, strong) TLContactLink* foreign_link;
@property (nonatomic, strong) TLUser* user;
@end

@interface TL_contacts_link : TLcontacts_Link<NSCoding>
+(TL_contacts_link*)createWithMy_link:(TLContactLink*)my_link foreign_link:(TLContactLink*)foreign_link user:(TLUser*)user;
@end
	
@interface TLcontacts_Contacts()
@property (nonatomic, strong) NSMutableArray* contacts;
@property (nonatomic, strong) NSMutableArray* users;
@end

@interface TL_contacts_contactsNotModified : TLcontacts_Contacts<NSCoding>
+(TL_contacts_contactsNotModified*)create;
@end
@interface TL_contacts_contacts : TLcontacts_Contacts<NSCoding>
+(TL_contacts_contacts*)createWithContacts:(NSMutableArray*)contacts users:(NSMutableArray*)users;
@end
	
@interface TLcontacts_ImportedContacts()
@property (nonatomic, strong) NSMutableArray* imported;
@property (nonatomic, strong) NSMutableArray* retry_contacts;
@property (nonatomic, strong) NSMutableArray* users;
@end

@interface TL_contacts_importedContacts : TLcontacts_ImportedContacts<NSCoding>
+(TL_contacts_importedContacts*)createWithImported:(NSMutableArray*)imported retry_contacts:(NSMutableArray*)retry_contacts users:(NSMutableArray*)users;
@end
	
@interface TLcontacts_Blocked()
@property (nonatomic, strong) NSMutableArray* blocked;
@property (nonatomic, strong) NSMutableArray* users;
@property int n_count;
@end

@interface TL_contacts_blocked : TLcontacts_Blocked<NSCoding>
+(TL_contacts_blocked*)createWithBlocked:(NSMutableArray*)blocked users:(NSMutableArray*)users;
@end
@interface TL_contacts_blockedSlice : TLcontacts_Blocked<NSCoding>
+(TL_contacts_blockedSlice*)createWithN_count:(int)n_count blocked:(NSMutableArray*)blocked users:(NSMutableArray*)users;
@end
	
@interface TLcontacts_Suggested()
@property (nonatomic, strong) NSMutableArray* results;
@property (nonatomic, strong) NSMutableArray* users;
@end

@interface TL_contacts_suggested : TLcontacts_Suggested<NSCoding>
+(TL_contacts_suggested*)createWithResults:(NSMutableArray*)results users:(NSMutableArray*)users;
@end
	
@interface TLmessages_Dialogs()
@property (nonatomic, strong) NSMutableArray* dialogs;
@property (nonatomic, strong) NSMutableArray* messages;
@property (nonatomic, strong) NSMutableArray* chats;
@property (nonatomic, strong) NSMutableArray* users;
@property int n_count;
@end

@interface TL_messages_dialogs : TLmessages_Dialogs<NSCoding>
+(TL_messages_dialogs*)createWithDialogs:(NSMutableArray*)dialogs messages:(NSMutableArray*)messages chats:(NSMutableArray*)chats users:(NSMutableArray*)users;
@end
@interface TL_messages_dialogsSlice : TLmessages_Dialogs<NSCoding>
+(TL_messages_dialogsSlice*)createWithN_count:(int)n_count dialogs:(NSMutableArray*)dialogs messages:(NSMutableArray*)messages chats:(NSMutableArray*)chats users:(NSMutableArray*)users;
@end
	
@interface TLmessages_Messages()
@property (nonatomic, strong) NSMutableArray* messages;
@property (nonatomic, strong) NSMutableArray* chats;
@property (nonatomic, strong) NSMutableArray* users;
@property int n_count;
@property int flags;
@property int pts;
@property (nonatomic, strong) NSMutableArray* collapsed;
@end

@interface TL_messages_messages : TLmessages_Messages<NSCoding>
+(TL_messages_messages*)createWithMessages:(NSMutableArray*)messages chats:(NSMutableArray*)chats users:(NSMutableArray*)users;
@end
@interface TL_messages_messagesSlice : TLmessages_Messages<NSCoding>
+(TL_messages_messagesSlice*)createWithN_count:(int)n_count messages:(NSMutableArray*)messages chats:(NSMutableArray*)chats users:(NSMutableArray*)users;
@end
@interface TL_messages_channelMessages : TLmessages_Messages<NSCoding>
+(TL_messages_channelMessages*)createWithFlags:(int)flags pts:(int)pts n_count:(int)n_count messages:(NSMutableArray*)messages collapsed:(NSMutableArray*)collapsed chats:(NSMutableArray*)chats users:(NSMutableArray*)users;
@end
	
@interface TLmessages_Chats()
@property (nonatomic, strong) NSMutableArray* chats;
@end

@interface TL_messages_chats : TLmessages_Chats<NSCoding>
+(TL_messages_chats*)createWithChats:(NSMutableArray*)chats;
@end
	
@interface TLmessages_ChatFull()
@property (nonatomic, strong) TLChatFull* full_chat;
@property (nonatomic, strong) NSMutableArray* chats;
@property (nonatomic, strong) NSMutableArray* users;
@end

@interface TL_messages_chatFull : TLmessages_ChatFull<NSCoding>
+(TL_messages_chatFull*)createWithFull_chat:(TLChatFull*)full_chat chats:(NSMutableArray*)chats users:(NSMutableArray*)users;
@end
	
@interface TLmessages_AffectedHistory()
@property int pts;
@property int pts_count;
@property int offset;
@end

@interface TL_messages_affectedHistory : TLmessages_AffectedHistory<NSCoding>
+(TL_messages_affectedHistory*)createWithPts:(int)pts pts_count:(int)pts_count offset:(int)offset;
@end
	
@interface TLMessagesFilter()

@end

@interface TL_inputMessagesFilterEmpty : TLMessagesFilter<NSCoding>
+(TL_inputMessagesFilterEmpty*)create;
@end
@interface TL_inputMessagesFilterPhotos : TLMessagesFilter<NSCoding>
+(TL_inputMessagesFilterPhotos*)create;
@end
@interface TL_inputMessagesFilterVideo : TLMessagesFilter<NSCoding>
+(TL_inputMessagesFilterVideo*)create;
@end
@interface TL_inputMessagesFilterPhotoVideo : TLMessagesFilter<NSCoding>
+(TL_inputMessagesFilterPhotoVideo*)create;
@end
@interface TL_inputMessagesFilterPhotoVideoDocuments : TLMessagesFilter<NSCoding>
+(TL_inputMessagesFilterPhotoVideoDocuments*)create;
@end
@interface TL_inputMessagesFilterDocument : TLMessagesFilter<NSCoding>
+(TL_inputMessagesFilterDocument*)create;
@end
@interface TL_inputMessagesFilterAudio : TLMessagesFilter<NSCoding>
+(TL_inputMessagesFilterAudio*)create;
@end
@interface TL_inputMessagesFilterAudioDocuments : TLMessagesFilter<NSCoding>
+(TL_inputMessagesFilterAudioDocuments*)create;
@end
@interface TL_inputMessagesFilterUrl : TLMessagesFilter<NSCoding>
+(TL_inputMessagesFilterUrl*)create;
@end
	
@interface TLUpdate()
@property (nonatomic, strong) TLMessage* message;
@property int pts;
@property int pts_count;
@property int n_id;
@property long random_id;
@property (nonatomic, strong) NSMutableArray* messages;
@property int user_id;
@property (nonatomic, strong) TLSendMessageAction* action;
@property int chat_id;
@property (nonatomic, strong) TLChatParticipants* participants;
@property (nonatomic, strong) TLUserStatus* status;
@property (nonatomic, strong) NSString* first_name;
@property (nonatomic, strong) NSString* last_name;
@property (nonatomic, strong) NSString* username;
@property int date;
@property (nonatomic, strong) TLUserProfilePhoto* photo;
@property Boolean previous;
@property (nonatomic, strong) TLContactLink* my_link;
@property (nonatomic, strong) TLContactLink* foreign_link;
@property long auth_key_id;
@property (nonatomic, strong) NSString* device;
@property (nonatomic, strong) NSString* location;
@property int qts;
@property (nonatomic, strong) TLEncryptedChat* chat;
@property int max_date;
@property int inviter_id;
@property int version;
@property (nonatomic, strong) NSMutableArray* dc_options;
@property Boolean blocked;
@property (nonatomic, strong) TLPeer* peer;
@property (nonatomic, strong) TLPeerNotifySettings* notify_settings;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) TLMessageMedia* media;
@property Boolean popup;
@property (nonatomic, strong) TLPrivacyKey* n_key;
@property (nonatomic, strong) NSMutableArray* rules;
@property (nonatomic, strong) NSString* phone;
@property int max_id;
@property (nonatomic, strong) TLWebPage* webpage;
@property int channel_id;
@property (nonatomic, strong) TLMessageGroup* group;
@property int views;
@property Boolean enabled;
@property Boolean is_admin;
@property (nonatomic, strong) TLmessages_StickerSet* stickerset;
@property (nonatomic, strong) NSMutableArray* order;
@end

@interface TL_updateNewMessage : TLUpdate<NSCoding>
+(TL_updateNewMessage*)createWithMessage:(TLMessage*)message pts:(int)pts pts_count:(int)pts_count;
@end
@interface TL_updateMessageID : TLUpdate<NSCoding>
+(TL_updateMessageID*)createWithN_id:(int)n_id random_id:(long)random_id;
@end
@interface TL_updateDeleteMessages : TLUpdate<NSCoding>
+(TL_updateDeleteMessages*)createWithMessages:(NSMutableArray*)messages pts:(int)pts pts_count:(int)pts_count;
@end
@interface TL_updateUserTyping : TLUpdate<NSCoding>
+(TL_updateUserTyping*)createWithUser_id:(int)user_id action:(TLSendMessageAction*)action;
@end
@interface TL_updateChatUserTyping : TLUpdate<NSCoding>
+(TL_updateChatUserTyping*)createWithChat_id:(int)chat_id user_id:(int)user_id action:(TLSendMessageAction*)action;
@end
@interface TL_updateChatParticipants : TLUpdate<NSCoding>
+(TL_updateChatParticipants*)createWithParticipants:(TLChatParticipants*)participants;
@end
@interface TL_updateUserStatus : TLUpdate<NSCoding>
+(TL_updateUserStatus*)createWithUser_id:(int)user_id status:(TLUserStatus*)status;
@end
@interface TL_updateUserName : TLUpdate<NSCoding>
+(TL_updateUserName*)createWithUser_id:(int)user_id first_name:(NSString*)first_name last_name:(NSString*)last_name username:(NSString*)username;
@end
@interface TL_updateUserPhoto : TLUpdate<NSCoding>
+(TL_updateUserPhoto*)createWithUser_id:(int)user_id date:(int)date photo:(TLUserProfilePhoto*)photo previous:(Boolean)previous;
@end
@interface TL_updateContactRegistered : TLUpdate<NSCoding>
+(TL_updateContactRegistered*)createWithUser_id:(int)user_id date:(int)date;
@end
@interface TL_updateContactLink : TLUpdate<NSCoding>
+(TL_updateContactLink*)createWithUser_id:(int)user_id my_link:(TLContactLink*)my_link foreign_link:(TLContactLink*)foreign_link;
@end
@interface TL_updateNewAuthorization : TLUpdate<NSCoding>
+(TL_updateNewAuthorization*)createWithAuth_key_id:(long)auth_key_id date:(int)date device:(NSString*)device location:(NSString*)location;
@end
@interface TL_updateNewEncryptedMessage : TLUpdate<NSCoding>
+(TL_updateNewEncryptedMessage*)createWithMessage:(TLEncryptedMessage*)message qts:(int)qts;
@end
@interface TL_updateEncryptedChatTyping : TLUpdate<NSCoding>
+(TL_updateEncryptedChatTyping*)createWithChat_id:(int)chat_id;
@end
@interface TL_updateEncryption : TLUpdate<NSCoding>
+(TL_updateEncryption*)createWithChat:(TLEncryptedChat*)chat date:(int)date;
@end
@interface TL_updateEncryptedMessagesRead : TLUpdate<NSCoding>
+(TL_updateEncryptedMessagesRead*)createWithChat_id:(int)chat_id max_date:(int)max_date date:(int)date;
@end
@interface TL_updateChatParticipantAdd : TLUpdate<NSCoding>
+(TL_updateChatParticipantAdd*)createWithChat_id:(int)chat_id user_id:(int)user_id inviter_id:(int)inviter_id date:(int)date version:(int)version;
@end
@interface TL_updateChatParticipantDelete : TLUpdate<NSCoding>
+(TL_updateChatParticipantDelete*)createWithChat_id:(int)chat_id user_id:(int)user_id version:(int)version;
@end
@interface TL_updateDcOptions : TLUpdate<NSCoding>
+(TL_updateDcOptions*)createWithDc_options:(NSMutableArray*)dc_options;
@end
@interface TL_updateUserBlocked : TLUpdate<NSCoding>
+(TL_updateUserBlocked*)createWithUser_id:(int)user_id blocked:(Boolean)blocked;
@end
@interface TL_updateNotifySettings : TLUpdate<NSCoding>
+(TL_updateNotifySettings*)createWithPeer:(TLNotifyPeer*)peer notify_settings:(TLPeerNotifySettings*)notify_settings;
@end
@interface TL_updateServiceNotification : TLUpdate<NSCoding>
+(TL_updateServiceNotification*)createWithType:(NSString*)type message:(NSString*)message media:(TLMessageMedia*)media popup:(Boolean)popup;
@end
@interface TL_updatePrivacy : TLUpdate<NSCoding>
+(TL_updatePrivacy*)createWithN_key:(TLPrivacyKey*)n_key rules:(NSMutableArray*)rules;
@end
@interface TL_updateUserPhone : TLUpdate<NSCoding>
+(TL_updateUserPhone*)createWithUser_id:(int)user_id phone:(NSString*)phone;
@end
@interface TL_updateReadHistoryInbox : TLUpdate<NSCoding>
+(TL_updateReadHistoryInbox*)createWithPeer:(TLPeer*)peer max_id:(int)max_id pts:(int)pts pts_count:(int)pts_count;
@end
@interface TL_updateReadHistoryOutbox : TLUpdate<NSCoding>
+(TL_updateReadHistoryOutbox*)createWithPeer:(TLPeer*)peer max_id:(int)max_id pts:(int)pts pts_count:(int)pts_count;
@end
@interface TL_updateWebPage : TLUpdate<NSCoding>
+(TL_updateWebPage*)createWithWebpage:(TLWebPage*)webpage pts:(int)pts pts_count:(int)pts_count;
@end
@interface TL_updateReadMessagesContents : TLUpdate<NSCoding>
+(TL_updateReadMessagesContents*)createWithMessages:(NSMutableArray*)messages pts:(int)pts pts_count:(int)pts_count;
@end
@interface TL_updateChannelTooLong : TLUpdate<NSCoding>
+(TL_updateChannelTooLong*)createWithChannel_id:(int)channel_id;
@end
@interface TL_updateChannel : TLUpdate<NSCoding>
+(TL_updateChannel*)createWithChannel_id:(int)channel_id;
@end
@interface TL_updateChannelGroup : TLUpdate<NSCoding>
+(TL_updateChannelGroup*)createWithChannel_id:(int)channel_id group:(TLMessageGroup*)group;
@end
@interface TL_updateNewChannelMessage : TLUpdate<NSCoding>
+(TL_updateNewChannelMessage*)createWithMessage:(TLMessage*)message pts:(int)pts pts_count:(int)pts_count;
@end
@interface TL_updateReadChannelInbox : TLUpdate<NSCoding>
+(TL_updateReadChannelInbox*)createWithChannel_id:(int)channel_id max_id:(int)max_id;
@end
@interface TL_updateDeleteChannelMessages : TLUpdate<NSCoding>
+(TL_updateDeleteChannelMessages*)createWithChannel_id:(int)channel_id messages:(NSMutableArray*)messages pts:(int)pts pts_count:(int)pts_count;
@end
@interface TL_updateChannelMessageViews : TLUpdate<NSCoding>
+(TL_updateChannelMessageViews*)createWithChannel_id:(int)channel_id n_id:(int)n_id views:(int)views;
@end
@interface TL_updateChatAdmins : TLUpdate<NSCoding>
+(TL_updateChatAdmins*)createWithChat_id:(int)chat_id enabled:(Boolean)enabled version:(int)version;
@end
@interface TL_updateChatParticipantAdmin : TLUpdate<NSCoding>
+(TL_updateChatParticipantAdmin*)createWithChat_id:(int)chat_id user_id:(int)user_id is_admin:(Boolean)is_admin version:(int)version;
@end
@interface TL_updateNewStickerSet : TLUpdate<NSCoding>
+(TL_updateNewStickerSet*)createWithStickerset:(TLmessages_StickerSet*)stickerset;
@end
@interface TL_updateStickerSetsOrder : TLUpdate<NSCoding>
+(TL_updateStickerSetsOrder*)createWithOrder:(NSMutableArray*)order;
@end
@interface TL_updateStickerSets : TLUpdate<NSCoding>
+(TL_updateStickerSets*)create;
@end
	
@interface TLupdates_State()
@property int pts;
@property int qts;
@property int date;
@property int seq;
@property int unread_count;
@end

@interface TL_updates_state : TLupdates_State<NSCoding>
+(TL_updates_state*)createWithPts:(int)pts qts:(int)qts date:(int)date seq:(int)seq unread_count:(int)unread_count;
@end
	
@interface TLupdates_Difference()
@property int date;
@property int seq;
@property (nonatomic, strong) NSMutableArray* n_messages;
@property (nonatomic, strong) NSMutableArray* n_encrypted_messages;
@property (nonatomic, strong) NSMutableArray* other_updates;
@property (nonatomic, strong) NSMutableArray* chats;
@property (nonatomic, strong) NSMutableArray* users;
@property (nonatomic, strong) TLupdates_State* state;
@property (nonatomic, strong) TLupdates_State* intermediate_state;
@end

@interface TL_updates_differenceEmpty : TLupdates_Difference<NSCoding>
+(TL_updates_differenceEmpty*)createWithDate:(int)date seq:(int)seq;
@end
@interface TL_updates_difference : TLupdates_Difference<NSCoding>
+(TL_updates_difference*)createWithN_messages:(NSMutableArray*)n_messages n_encrypted_messages:(NSMutableArray*)n_encrypted_messages other_updates:(NSMutableArray*)other_updates chats:(NSMutableArray*)chats users:(NSMutableArray*)users state:(TLupdates_State*)state;
@end
@interface TL_updates_differenceSlice : TLupdates_Difference<NSCoding>
+(TL_updates_differenceSlice*)createWithN_messages:(NSMutableArray*)n_messages n_encrypted_messages:(NSMutableArray*)n_encrypted_messages other_updates:(NSMutableArray*)other_updates chats:(NSMutableArray*)chats users:(NSMutableArray*)users intermediate_state:(TLupdates_State*)intermediate_state;
@end
	
@interface TLUpdates()
@property int flags;
@property (nonatomic,assign,readonly) BOOL isUnread;
@property (nonatomic,assign,readonly) BOOL isN_out;
@property (nonatomic,assign,readonly) BOOL isMentioned;
@property (nonatomic,assign,readonly) BOOL isMedia_unread;
@property int n_id;
@property int user_id;
@property (nonatomic, strong) NSString* message;
@property int pts;
@property int pts_count;
@property int date;
@property (nonatomic, strong) TLPeer* fwd_from_id;
@property int fwd_date;
@property int reply_to_msg_id;
@property (nonatomic, strong) NSMutableArray* entities;
@property int from_id;
@property int chat_id;
@property (nonatomic, strong) TLUpdate* update;
@property (nonatomic, strong) NSMutableArray* updates;
@property (nonatomic, strong) NSMutableArray* users;
@property (nonatomic, strong) NSMutableArray* chats;
@property int seq_start;
@property int seq;
@property (nonatomic, strong) TLMessageMedia* media;
@end

@interface TL_updatesTooLong : TLUpdates<NSCoding>
+(TL_updatesTooLong*)create;
@end
@interface TL_updateShortMessage : TLUpdates<NSCoding>
+(TL_updateShortMessage*)createWithFlags:(int)flags     n_id:(int)n_id user_id:(int)user_id message:(NSString*)message pts:(int)pts pts_count:(int)pts_count date:(int)date fwd_from_id:(TLPeer*)fwd_from_id fwd_date:(int)fwd_date reply_to_msg_id:(int)reply_to_msg_id entities:(NSMutableArray*)entities;
@end
@interface TL_updateShortChatMessage : TLUpdates<NSCoding>
+(TL_updateShortChatMessage*)createWithFlags:(int)flags     n_id:(int)n_id from_id:(int)from_id chat_id:(int)chat_id message:(NSString*)message pts:(int)pts pts_count:(int)pts_count date:(int)date fwd_from_id:(TLPeer*)fwd_from_id fwd_date:(int)fwd_date reply_to_msg_id:(int)reply_to_msg_id entities:(NSMutableArray*)entities;
@end
@interface TL_updateShort : TLUpdates<NSCoding>
+(TL_updateShort*)createWithUpdate:(TLUpdate*)update date:(int)date;
@end
@interface TL_updatesCombined : TLUpdates<NSCoding>
+(TL_updatesCombined*)createWithUpdates:(NSMutableArray*)updates users:(NSMutableArray*)users chats:(NSMutableArray*)chats date:(int)date seq_start:(int)seq_start seq:(int)seq;
@end
@interface TL_updates : TLUpdates<NSCoding>
+(TL_updates*)createWithUpdates:(NSMutableArray*)updates users:(NSMutableArray*)users chats:(NSMutableArray*)chats date:(int)date seq:(int)seq;
@end
@interface TL_updateShortSentMessage : TLUpdates<NSCoding>
+(TL_updateShortSentMessage*)createWithFlags:(int)flags   n_id:(int)n_id pts:(int)pts pts_count:(int)pts_count date:(int)date media:(TLMessageMedia*)media entities:(NSMutableArray*)entities;
@end
	
@interface TLphotos_Photos()
@property (nonatomic, strong) NSMutableArray* photos;
@property (nonatomic, strong) NSMutableArray* users;
@property int n_count;
@end

@interface TL_photos_photos : TLphotos_Photos<NSCoding>
+(TL_photos_photos*)createWithPhotos:(NSMutableArray*)photos users:(NSMutableArray*)users;
@end
@interface TL_photos_photosSlice : TLphotos_Photos<NSCoding>
+(TL_photos_photosSlice*)createWithN_count:(int)n_count photos:(NSMutableArray*)photos users:(NSMutableArray*)users;
@end
	
@interface TLphotos_Photo()
@property (nonatomic, strong) TLPhoto* photo;
@property (nonatomic, strong) NSMutableArray* users;
@end

@interface TL_photos_photo : TLphotos_Photo<NSCoding>
+(TL_photos_photo*)createWithPhoto:(TLPhoto*)photo users:(NSMutableArray*)users;
@end
	
@interface TLupload_File()
@property (nonatomic, strong) TLstorage_FileType* type;
@property int mtime;
@property (nonatomic, strong) NSData* bytes;
@end

@interface TL_upload_file : TLupload_File<NSCoding>
+(TL_upload_file*)createWithType:(TLstorage_FileType*)type mtime:(int)mtime bytes:(NSData*)bytes;
@end
	
@interface TLDcOption()
@property int flags;
@property (nonatomic,assign,readonly) BOOL isIpv6;
@property (nonatomic,assign,readonly) BOOL isMedia_only;
@property int n_id;
@property (nonatomic, strong) NSString* ip_address;
@property int port;
@end

@interface TL_dcOption : TLDcOption<NSCoding>
+(TL_dcOption*)createWithFlags:(int)flags   n_id:(int)n_id ip_address:(NSString*)ip_address port:(int)port;
@end
	
@interface TLConfig()
@property int date;
@property int expires;
@property Boolean test_mode;
@property int this_dc;
@property (nonatomic, strong) NSMutableArray* dc_options;
@property int chat_size_max;
@property int megagroup_size_max;
@property int forwarded_count_max;
@property int online_update_period_ms;
@property int offline_blur_timeout_ms;
@property int offline_idle_timeout_ms;
@property int online_cloud_timeout_ms;
@property int notify_cloud_delay_ms;
@property int notify_default_delay_ms;
@property int chat_big_size;
@property int push_chat_period_ms;
@property int push_chat_limit;
@property (nonatomic, strong) NSMutableArray* disabled_features;
@end

@interface TL_config : TLConfig<NSCoding>
+(TL_config*)createWithDate:(int)date expires:(int)expires test_mode:(Boolean)test_mode this_dc:(int)this_dc dc_options:(NSMutableArray*)dc_options chat_size_max:(int)chat_size_max megagroup_size_max:(int)megagroup_size_max forwarded_count_max:(int)forwarded_count_max online_update_period_ms:(int)online_update_period_ms offline_blur_timeout_ms:(int)offline_blur_timeout_ms offline_idle_timeout_ms:(int)offline_idle_timeout_ms online_cloud_timeout_ms:(int)online_cloud_timeout_ms notify_cloud_delay_ms:(int)notify_cloud_delay_ms notify_default_delay_ms:(int)notify_default_delay_ms chat_big_size:(int)chat_big_size push_chat_period_ms:(int)push_chat_period_ms push_chat_limit:(int)push_chat_limit disabled_features:(NSMutableArray*)disabled_features;
@end
	
@interface TLNearestDc()
@property (nonatomic, strong) NSString* country;
@property int this_dc;
@property int nearest_dc;
@end

@interface TL_nearestDc : TLNearestDc<NSCoding>
+(TL_nearestDc*)createWithCountry:(NSString*)country this_dc:(int)this_dc nearest_dc:(int)nearest_dc;
@end
	
@interface TLhelp_AppUpdate()
@property int n_id;
@property Boolean critical;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* text;
@end

@interface TL_help_appUpdate : TLhelp_AppUpdate<NSCoding>
+(TL_help_appUpdate*)createWithN_id:(int)n_id critical:(Boolean)critical url:(NSString*)url text:(NSString*)text;
@end
@interface TL_help_noAppUpdate : TLhelp_AppUpdate<NSCoding>
+(TL_help_noAppUpdate*)create;
@end
	
@interface TLhelp_InviteText()
@property (nonatomic, strong) NSString* message;
@end

@interface TL_help_inviteText : TLhelp_InviteText<NSCoding>
+(TL_help_inviteText*)createWithMessage:(NSString*)message;
@end
	
@interface TLEncryptedChat()
@property int n_id;
@property long access_hash;
@property int date;
@property int admin_id;
@property int participant_id;
@property (nonatomic, strong) NSData* g_a;
@property (nonatomic, strong) NSData* g_a_or_b;
@property long key_fingerprint;
@end

@interface TL_encryptedChatEmpty : TLEncryptedChat<NSCoding>
+(TL_encryptedChatEmpty*)createWithN_id:(int)n_id;
@end
@interface TL_encryptedChatWaiting : TLEncryptedChat<NSCoding>
+(TL_encryptedChatWaiting*)createWithN_id:(int)n_id access_hash:(long)access_hash date:(int)date admin_id:(int)admin_id participant_id:(int)participant_id;
@end
@interface TL_encryptedChatRequested : TLEncryptedChat<NSCoding>
+(TL_encryptedChatRequested*)createWithN_id:(int)n_id access_hash:(long)access_hash date:(int)date admin_id:(int)admin_id participant_id:(int)participant_id g_a:(NSData*)g_a;
@end
@interface TL_encryptedChat : TLEncryptedChat<NSCoding>
+(TL_encryptedChat*)createWithN_id:(int)n_id access_hash:(long)access_hash date:(int)date admin_id:(int)admin_id participant_id:(int)participant_id g_a_or_b:(NSData*)g_a_or_b key_fingerprint:(long)key_fingerprint;
@end
@interface TL_encryptedChatDiscarded : TLEncryptedChat<NSCoding>
+(TL_encryptedChatDiscarded*)createWithN_id:(int)n_id;
@end
	
@interface TLInputEncryptedChat()
@property int chat_id;
@property long access_hash;
@end

@interface TL_inputEncryptedChat : TLInputEncryptedChat<NSCoding>
+(TL_inputEncryptedChat*)createWithChat_id:(int)chat_id access_hash:(long)access_hash;
@end
	
@interface TLEncryptedFile()
@property long n_id;
@property long access_hash;
@property int size;
@property int dc_id;
@property int key_fingerprint;
@end

@interface TL_encryptedFileEmpty : TLEncryptedFile<NSCoding>
+(TL_encryptedFileEmpty*)create;
@end
@interface TL_encryptedFile : TLEncryptedFile<NSCoding>
+(TL_encryptedFile*)createWithN_id:(long)n_id access_hash:(long)access_hash size:(int)size dc_id:(int)dc_id key_fingerprint:(int)key_fingerprint;
@end
	
@interface TLInputEncryptedFile()
@property long n_id;
@property int parts;
@property (nonatomic, strong) NSString* md5_checksum;
@property int key_fingerprint;
@property long access_hash;
@end

@interface TL_inputEncryptedFileEmpty : TLInputEncryptedFile<NSCoding>
+(TL_inputEncryptedFileEmpty*)create;
@end
@interface TL_inputEncryptedFileUploaded : TLInputEncryptedFile<NSCoding>
+(TL_inputEncryptedFileUploaded*)createWithN_id:(long)n_id parts:(int)parts md5_checksum:(NSString*)md5_checksum key_fingerprint:(int)key_fingerprint;
@end
@interface TL_inputEncryptedFile : TLInputEncryptedFile<NSCoding>
+(TL_inputEncryptedFile*)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
@interface TL_inputEncryptedFileBigUploaded : TLInputEncryptedFile<NSCoding>
+(TL_inputEncryptedFileBigUploaded*)createWithN_id:(long)n_id parts:(int)parts key_fingerprint:(int)key_fingerprint;
@end
	
@interface TLEncryptedMessage()
@property long random_id;
@property int chat_id;
@property int date;
@property (nonatomic, strong) NSData* bytes;
@property (nonatomic, strong) TLEncryptedFile* file;
@end

@interface TL_encryptedMessage : TLEncryptedMessage<NSCoding>
+(TL_encryptedMessage*)createWithRandom_id:(long)random_id chat_id:(int)chat_id date:(int)date bytes:(NSData*)bytes file:(TLEncryptedFile*)file;
@end
@interface TL_encryptedMessageService : TLEncryptedMessage<NSCoding>
+(TL_encryptedMessageService*)createWithRandom_id:(long)random_id chat_id:(int)chat_id date:(int)date bytes:(NSData*)bytes;
@end
	
@interface TLmessages_DhConfig()
@property (nonatomic, strong) NSData* random;
@property int g;
@property (nonatomic, strong) NSData* p;
@property int version;
@end

@interface TL_messages_dhConfigNotModified : TLmessages_DhConfig<NSCoding>
+(TL_messages_dhConfigNotModified*)createWithRandom:(NSData*)random;
@end
@interface TL_messages_dhConfig : TLmessages_DhConfig<NSCoding>
+(TL_messages_dhConfig*)createWithG:(int)g p:(NSData*)p version:(int)version random:(NSData*)random;
@end
	
@interface TLmessages_SentEncryptedMessage()
@property int date;
@property (nonatomic, strong) TLEncryptedFile* file;
@end

@interface TL_messages_sentEncryptedMessage : TLmessages_SentEncryptedMessage<NSCoding>
+(TL_messages_sentEncryptedMessage*)createWithDate:(int)date;
@end
@interface TL_messages_sentEncryptedFile : TLmessages_SentEncryptedMessage<NSCoding>
+(TL_messages_sentEncryptedFile*)createWithDate:(int)date file:(TLEncryptedFile*)file;
@end
	
@interface TLInputAudio()
@property long n_id;
@property long access_hash;
@end

@interface TL_inputAudioEmpty : TLInputAudio<NSCoding>
+(TL_inputAudioEmpty*)create;
@end
@interface TL_inputAudio : TLInputAudio<NSCoding>
+(TL_inputAudio*)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
	
@interface TLInputDocument()
@property long n_id;
@property long access_hash;
@end

@interface TL_inputDocumentEmpty : TLInputDocument<NSCoding>
+(TL_inputDocumentEmpty*)create;
@end
@interface TL_inputDocument : TLInputDocument<NSCoding>
+(TL_inputDocument*)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
	
@interface TLAudio()
@property long n_id;
@property long access_hash;
@property int date;
@property int duration;
@property (nonatomic, strong) NSString* mime_type;
@property int size;
@property int dc_id;
@property int user_id;
@end

@interface TL_audioEmpty : TLAudio<NSCoding>
+(TL_audioEmpty*)createWithN_id:(long)n_id;
@end
@interface TL_audio : TLAudio<NSCoding>
+(TL_audio*)createWithN_id:(long)n_id access_hash:(long)access_hash date:(int)date duration:(int)duration mime_type:(NSString*)mime_type size:(int)size dc_id:(int)dc_id;
@end
@interface TL_audio_old29 : TLAudio<NSCoding>
+(TL_audio_old29*)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date duration:(int)duration mime_type:(NSString*)mime_type size:(int)size dc_id:(int)dc_id;
@end
	
@interface TLDocument()
@property long n_id;
@property long access_hash;
@property int date;
@property (nonatomic, strong) NSString* mime_type;
@property int size;
@property (nonatomic, strong) TLPhotoSize* thumb;
@property int dc_id;
@property (nonatomic, strong) NSMutableArray* attributes;
@end

@interface TL_documentEmpty : TLDocument<NSCoding>
+(TL_documentEmpty*)createWithN_id:(long)n_id;
@end
@interface TL_document : TLDocument<NSCoding>
+(TL_document*)createWithN_id:(long)n_id access_hash:(long)access_hash date:(int)date mime_type:(NSString*)mime_type size:(int)size thumb:(TLPhotoSize*)thumb dc_id:(int)dc_id attributes:(NSMutableArray*)attributes;
@end
	
@interface TLhelp_Support()
@property (nonatomic, strong) NSString* phone_number;
@property (nonatomic, strong) TLUser* user;
@end

@interface TL_help_support : TLhelp_Support<NSCoding>
+(TL_help_support*)createWithPhone_number:(NSString*)phone_number user:(TLUser*)user;
@end
	
@interface TLNotifyPeer()
@property (nonatomic, strong) TLPeer* peer;
@end

@interface TL_notifyPeer : TLNotifyPeer<NSCoding>
+(TL_notifyPeer*)createWithPeer:(TLPeer*)peer;
@end
@interface TL_notifyUsers : TLNotifyPeer<NSCoding>
+(TL_notifyUsers*)create;
@end
@interface TL_notifyChats : TLNotifyPeer<NSCoding>
+(TL_notifyChats*)create;
@end
@interface TL_notifyAll : TLNotifyPeer<NSCoding>
+(TL_notifyAll*)create;
@end
	
@interface TLSendMessageAction()
@property int progress;
@end

@interface TL_sendMessageTypingAction : TLSendMessageAction<NSCoding>
+(TL_sendMessageTypingAction*)create;
@end
@interface TL_sendMessageCancelAction : TLSendMessageAction<NSCoding>
+(TL_sendMessageCancelAction*)create;
@end
@interface TL_sendMessageRecordVideoAction : TLSendMessageAction<NSCoding>
+(TL_sendMessageRecordVideoAction*)create;
@end
@interface TL_sendMessageUploadVideoAction : TLSendMessageAction<NSCoding>
+(TL_sendMessageUploadVideoAction*)createWithProgress:(int)progress;
@end
@interface TL_sendMessageRecordAudioAction : TLSendMessageAction<NSCoding>
+(TL_sendMessageRecordAudioAction*)create;
@end
@interface TL_sendMessageUploadAudioAction : TLSendMessageAction<NSCoding>
+(TL_sendMessageUploadAudioAction*)createWithProgress:(int)progress;
@end
@interface TL_sendMessageUploadPhotoAction : TLSendMessageAction<NSCoding>
+(TL_sendMessageUploadPhotoAction*)createWithProgress:(int)progress;
@end
@interface TL_sendMessageUploadDocumentAction : TLSendMessageAction<NSCoding>
+(TL_sendMessageUploadDocumentAction*)createWithProgress:(int)progress;
@end
@interface TL_sendMessageGeoLocationAction : TLSendMessageAction<NSCoding>
+(TL_sendMessageGeoLocationAction*)create;
@end
@interface TL_sendMessageChooseContactAction : TLSendMessageAction<NSCoding>
+(TL_sendMessageChooseContactAction*)create;
@end
	
@interface TLcontacts_Found()
@property (nonatomic, strong) NSMutableArray* results;
@property (nonatomic, strong) NSMutableArray* chats;
@property (nonatomic, strong) NSMutableArray* users;
@end

@interface TL_contacts_found : TLcontacts_Found<NSCoding>
+(TL_contacts_found*)createWithResults:(NSMutableArray*)results chats:(NSMutableArray*)chats users:(NSMutableArray*)users;
@end
	
@interface TLInputPrivacyKey()

@end

@interface TL_inputPrivacyKeyStatusTimestamp : TLInputPrivacyKey<NSCoding>
+(TL_inputPrivacyKeyStatusTimestamp*)create;
@end
	
@interface TLPrivacyKey()

@end

@interface TL_privacyKeyStatusTimestamp : TLPrivacyKey<NSCoding>
+(TL_privacyKeyStatusTimestamp*)create;
@end
	
@interface TLInputPrivacyRule()
@property (nonatomic, strong) NSMutableArray* users;
@end

@interface TL_inputPrivacyValueAllowContacts : TLInputPrivacyRule<NSCoding>
+(TL_inputPrivacyValueAllowContacts*)create;
@end
@interface TL_inputPrivacyValueAllowAll : TLInputPrivacyRule<NSCoding>
+(TL_inputPrivacyValueAllowAll*)create;
@end
@interface TL_inputPrivacyValueAllowUsers : TLInputPrivacyRule<NSCoding>
+(TL_inputPrivacyValueAllowUsers*)createWithUsers:(NSMutableArray*)users;
@end
@interface TL_inputPrivacyValueDisallowContacts : TLInputPrivacyRule<NSCoding>
+(TL_inputPrivacyValueDisallowContacts*)create;
@end
@interface TL_inputPrivacyValueDisallowAll : TLInputPrivacyRule<NSCoding>
+(TL_inputPrivacyValueDisallowAll*)create;
@end
@interface TL_inputPrivacyValueDisallowUsers : TLInputPrivacyRule<NSCoding>
+(TL_inputPrivacyValueDisallowUsers*)createWithUsers:(NSMutableArray*)users;
@end
	
@interface TLPrivacyRule()
@property (nonatomic, strong) NSMutableArray* users;
@end

@interface TL_privacyValueAllowContacts : TLPrivacyRule<NSCoding>
+(TL_privacyValueAllowContacts*)create;
@end
@interface TL_privacyValueAllowAll : TLPrivacyRule<NSCoding>
+(TL_privacyValueAllowAll*)create;
@end
@interface TL_privacyValueAllowUsers : TLPrivacyRule<NSCoding>
+(TL_privacyValueAllowUsers*)createWithUsers:(NSMutableArray*)users;
@end
@interface TL_privacyValueDisallowContacts : TLPrivacyRule<NSCoding>
+(TL_privacyValueDisallowContacts*)create;
@end
@interface TL_privacyValueDisallowAll : TLPrivacyRule<NSCoding>
+(TL_privacyValueDisallowAll*)create;
@end
@interface TL_privacyValueDisallowUsers : TLPrivacyRule<NSCoding>
+(TL_privacyValueDisallowUsers*)createWithUsers:(NSMutableArray*)users;
@end
	
@interface TLaccount_PrivacyRules()
@property (nonatomic, strong) NSMutableArray* rules;
@property (nonatomic, strong) NSMutableArray* users;
@end

@interface TL_account_privacyRules : TLaccount_PrivacyRules<NSCoding>
+(TL_account_privacyRules*)createWithRules:(NSMutableArray*)rules users:(NSMutableArray*)users;
@end
	
@interface TLAccountDaysTTL()
@property int days;
@end

@interface TL_accountDaysTTL : TLAccountDaysTTL<NSCoding>
+(TL_accountDaysTTL*)createWithDays:(int)days;
@end
	
@interface TLaccount_SentChangePhoneCode()
@property (nonatomic, strong) NSString* phone_code_hash;
@property int send_call_timeout;
@end

@interface TL_account_sentChangePhoneCode : TLaccount_SentChangePhoneCode<NSCoding>
+(TL_account_sentChangePhoneCode*)createWithPhone_code_hash:(NSString*)phone_code_hash send_call_timeout:(int)send_call_timeout;
@end
	
@interface TLDocumentAttribute()
@property int w;
@property int h;
@property (nonatomic, strong) NSString* alt;
@property (nonatomic, strong) TLInputStickerSet* stickerset;
@property int duration;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* performer;
@property (nonatomic, strong) NSString* file_name;
@end

@interface TL_documentAttributeImageSize : TLDocumentAttribute<NSCoding>
+(TL_documentAttributeImageSize*)createWithW:(int)w h:(int)h;
@end
@interface TL_documentAttributeAnimated : TLDocumentAttribute<NSCoding>
+(TL_documentAttributeAnimated*)create;
@end
@interface TL_documentAttributeSticker : TLDocumentAttribute<NSCoding>
+(TL_documentAttributeSticker*)createWithAlt:(NSString*)alt stickerset:(TLInputStickerSet*)stickerset;
@end
@interface TL_documentAttributeVideo : TLDocumentAttribute<NSCoding>
+(TL_documentAttributeVideo*)createWithDuration:(int)duration w:(int)w h:(int)h;
@end
@interface TL_documentAttributeAudio : TLDocumentAttribute<NSCoding>
+(TL_documentAttributeAudio*)createWithDuration:(int)duration title:(NSString*)title performer:(NSString*)performer;
@end
@interface TL_documentAttributeFilename : TLDocumentAttribute<NSCoding>
+(TL_documentAttributeFilename*)createWithFile_name:(NSString*)file_name;
@end
@interface TL_documentAttributeAudio_old31 : TLDocumentAttribute<NSCoding>
+(TL_documentAttributeAudio_old31*)createWithDuration:(int)duration;
@end
	
@interface TLmessages_Stickers()
@property (nonatomic, strong) NSString* n_hash;
@property (nonatomic, strong) NSMutableArray* stickers;
@end

@interface TL_messages_stickersNotModified : TLmessages_Stickers<NSCoding>
+(TL_messages_stickersNotModified*)create;
@end
@interface TL_messages_stickers : TLmessages_Stickers<NSCoding>
+(TL_messages_stickers*)createWithN_hash:(NSString*)n_hash stickers:(NSMutableArray*)stickers;
@end
	
@interface TLStickerPack()
@property (nonatomic, strong) NSString* emoticon;
@property (nonatomic, strong) NSMutableArray* documents;
@end

@interface TL_stickerPack : TLStickerPack<NSCoding>
+(TL_stickerPack*)createWithEmoticon:(NSString*)emoticon documents:(NSMutableArray*)documents;
@end
	
@interface TLmessages_AllStickers()
@property int n_hash;
@property (nonatomic, strong) NSMutableArray* sets;
@end

@interface TL_messages_allStickersNotModified : TLmessages_AllStickers<NSCoding>
+(TL_messages_allStickersNotModified*)create;
@end
@interface TL_messages_allStickers : TLmessages_AllStickers<NSCoding>
+(TL_messages_allStickers*)createWithN_hash:(int)n_hash sets:(NSMutableArray*)sets;
@end
	
@interface TLDisabledFeature()
@property (nonatomic, strong) NSString* feature;
@property (nonatomic, strong) NSString* n_description;
@end

@interface TL_disabledFeature : TLDisabledFeature<NSCoding>
+(TL_disabledFeature*)createWithFeature:(NSString*)feature n_description:(NSString*)n_description;
@end
	
@interface TLmessages_AffectedMessages()
@property int pts;
@property int pts_count;
@end

@interface TL_messages_affectedMessages : TLmessages_AffectedMessages<NSCoding>
+(TL_messages_affectedMessages*)createWithPts:(int)pts pts_count:(int)pts_count;
@end
	
@interface TLContactLink()

@end

@interface TL_contactLinkUnknown : TLContactLink<NSCoding>
+(TL_contactLinkUnknown*)create;
@end
@interface TL_contactLinkNone : TLContactLink<NSCoding>
+(TL_contactLinkNone*)create;
@end
@interface TL_contactLinkHasPhone : TLContactLink<NSCoding>
+(TL_contactLinkHasPhone*)create;
@end
@interface TL_contactLinkContact : TLContactLink<NSCoding>
+(TL_contactLinkContact*)create;
@end
	
@interface TLWebPage()
@property long n_id;
@property int date;
@property int flags;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* display_url;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* site_name;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* n_description;
@property (nonatomic, strong) TLPhoto* photo;
@property (nonatomic, strong) NSString* embed_url;
@property (nonatomic, strong) NSString* embed_type;
@property int embed_width;
@property int embed_height;
@property int duration;
@property (nonatomic, strong) NSString* author;
@property (nonatomic, strong) TLDocument* document;
@end

@interface TL_webPageEmpty : TLWebPage<NSCoding>
+(TL_webPageEmpty*)createWithN_id:(long)n_id;
@end
@interface TL_webPagePending : TLWebPage<NSCoding>
+(TL_webPagePending*)createWithN_id:(long)n_id date:(int)date;
@end
@interface TL_webPage : TLWebPage<NSCoding>
+(TL_webPage*)createWithFlags:(int)flags n_id:(long)n_id url:(NSString*)url display_url:(NSString*)display_url type:(NSString*)type site_name:(NSString*)site_name title:(NSString*)title n_description:(NSString*)n_description photo:(TLPhoto*)photo embed_url:(NSString*)embed_url embed_type:(NSString*)embed_type embed_width:(int)embed_width embed_height:(int)embed_height duration:(int)duration author:(NSString*)author document:(TLDocument*)document;
@end
@interface TL_webPage_old34 : TLWebPage<NSCoding>
+(TL_webPage_old34*)createWithFlags:(int)flags n_id:(long)n_id url:(NSString*)url display_url:(NSString*)display_url type:(NSString*)type site_name:(NSString*)site_name title:(NSString*)title n_description:(NSString*)n_description photo:(TLPhoto*)photo embed_url:(NSString*)embed_url embed_type:(NSString*)embed_type embed_width:(int)embed_width embed_height:(int)embed_height duration:(int)duration author:(NSString*)author;
@end
	
@interface TLAuthorization()
@property long n_hash;
@property int flags;
@property (nonatomic, strong) NSString* device_model;
@property (nonatomic, strong) NSString* platform;
@property (nonatomic, strong) NSString* system_version;
@property int api_id;
@property (nonatomic, strong) NSString* app_name;
@property (nonatomic, strong) NSString* app_version;
@property int date_created;
@property int date_active;
@property (nonatomic, strong) NSString* ip;
@property (nonatomic, strong) NSString* country;
@property (nonatomic, strong) NSString* region;
@end

@interface TL_authorization : TLAuthorization<NSCoding>
+(TL_authorization*)createWithN_hash:(long)n_hash flags:(int)flags device_model:(NSString*)device_model platform:(NSString*)platform system_version:(NSString*)system_version api_id:(int)api_id app_name:(NSString*)app_name app_version:(NSString*)app_version date_created:(int)date_created date_active:(int)date_active ip:(NSString*)ip country:(NSString*)country region:(NSString*)region;
@end
	
@interface TLaccount_Authorizations()
@property (nonatomic, strong) NSMutableArray* authorizations;
@end

@interface TL_account_authorizations : TLaccount_Authorizations<NSCoding>
+(TL_account_authorizations*)createWithAuthorizations:(NSMutableArray*)authorizations;
@end
	
@interface TLaccount_Password()
@property (nonatomic, strong) NSData* n_salt;
@property (nonatomic, strong) NSString* email_unconfirmed_pattern;
@property (nonatomic, strong) NSData* current_salt;
@property (nonatomic, strong) NSString* hint;
@property Boolean has_recovery;
@end

@interface TL_account_noPassword : TLaccount_Password<NSCoding>
+(TL_account_noPassword*)createWithN_salt:(NSData*)n_salt email_unconfirmed_pattern:(NSString*)email_unconfirmed_pattern;
@end
@interface TL_account_password : TLaccount_Password<NSCoding>
+(TL_account_password*)createWithCurrent_salt:(NSData*)current_salt n_salt:(NSData*)n_salt hint:(NSString*)hint has_recovery:(Boolean)has_recovery email_unconfirmed_pattern:(NSString*)email_unconfirmed_pattern;
@end
	
@interface TLaccount_PasswordSettings()
@property (nonatomic, strong) NSString* email;
@end

@interface TL_account_passwordSettings : TLaccount_PasswordSettings<NSCoding>
+(TL_account_passwordSettings*)createWithEmail:(NSString*)email;
@end
	
@interface TLaccount_PasswordInputSettings()
@property int flags;
@property (nonatomic, strong) NSData* n_salt;
@property (nonatomic, strong) NSData* n_password_hash;
@property (nonatomic, strong) NSString* hint;
@property (nonatomic, strong) NSString* email;
@end

@interface TL_account_passwordInputSettings : TLaccount_PasswordInputSettings<NSCoding>
+(TL_account_passwordInputSettings*)createWithFlags:(int)flags n_salt:(NSData*)n_salt n_password_hash:(NSData*)n_password_hash hint:(NSString*)hint email:(NSString*)email;
@end
	
@interface TLauth_PasswordRecovery()
@property (nonatomic, strong) NSString* email_pattern;
@end

@interface TL_auth_passwordRecovery : TLauth_PasswordRecovery<NSCoding>
+(TL_auth_passwordRecovery*)createWithEmail_pattern:(NSString*)email_pattern;
@end
	
@interface TLReceivedNotifyMessage()
@property int n_id;
@property int flags;
@end

@interface TL_receivedNotifyMessage : TLReceivedNotifyMessage<NSCoding>
+(TL_receivedNotifyMessage*)createWithN_id:(int)n_id flags:(int)flags;
@end
	
@interface TLExportedChatInvite()
@property (nonatomic, strong) NSString* link;
@end

@interface TL_chatInviteEmpty : TLExportedChatInvite<NSCoding>
+(TL_chatInviteEmpty*)create;
@end
@interface TL_chatInviteExported : TLExportedChatInvite<NSCoding>
+(TL_chatInviteExported*)createWithLink:(NSString*)link;
@end
	
@interface TLChatInvite()
@property (nonatomic, strong) TLChat* chat;
@property int flags;
@property (nonatomic,assign,readonly) BOOL isChannel;
@property (nonatomic,assign,readonly) BOOL isBroadcast;
@property (nonatomic,assign,readonly) BOOL isPublic;
@property (nonatomic,assign,readonly) BOOL isMegagroup;
@property (nonatomic, strong) NSString* title;
@end

@interface TL_chatInviteAlready : TLChatInvite<NSCoding>
+(TL_chatInviteAlready*)createWithChat:(TLChat*)chat;
@end
@interface TL_chatInvite : TLChatInvite<NSCoding>
+(TL_chatInvite*)createWithFlags:(int)flags     title:(NSString*)title;
@end
	
@interface TLInputStickerSet()
@property long n_id;
@property long access_hash;
@property (nonatomic, strong) NSString* short_name;
@end

@interface TL_inputStickerSetEmpty : TLInputStickerSet<NSCoding>
+(TL_inputStickerSetEmpty*)create;
@end
@interface TL_inputStickerSetID : TLInputStickerSet<NSCoding>
+(TL_inputStickerSetID*)createWithN_id:(long)n_id access_hash:(long)access_hash;
@end
@interface TL_inputStickerSetShortName : TLInputStickerSet<NSCoding>
+(TL_inputStickerSetShortName*)createWithShort_name:(NSString*)short_name;
@end
	
@interface TLStickerSet()
@property int flags;
@property (nonatomic,assign,readonly) BOOL isInstalled;
@property (nonatomic,assign,readonly) BOOL isDisabled;
@property (nonatomic,assign,readonly) BOOL isOfficial;
@property long n_id;
@property long access_hash;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* short_name;
@property int n_count;
@property int n_hash;
@end

@interface TL_stickerSet : TLStickerSet<NSCoding>
+(TL_stickerSet*)createWithFlags:(int)flags    n_id:(long)n_id access_hash:(long)access_hash title:(NSString*)title short_name:(NSString*)short_name n_count:(int)n_count n_hash:(int)n_hash;
@end
	
@interface TLmessages_StickerSet()
@property (nonatomic, strong) TLStickerSet* set;
@property (nonatomic, strong) NSMutableArray* packs;
@property (nonatomic, strong) NSMutableArray* documents;
@end

@interface TL_messages_stickerSet : TLmessages_StickerSet<NSCoding>
+(TL_messages_stickerSet*)createWithSet:(TLStickerSet*)set packs:(NSMutableArray*)packs documents:(NSMutableArray*)documents;
@end
	
@interface TLBotCommand()
@property (nonatomic, strong) NSString* command;
@property (nonatomic, strong) NSString* n_description;
@end

@interface TL_botCommand : TLBotCommand<NSCoding>
+(TL_botCommand*)createWithCommand:(NSString*)command n_description:(NSString*)n_description;
@end
	
@interface TLBotInfo()
@property int user_id;
@property int version;
@property (nonatomic, strong) NSString* share_text;
@property (nonatomic, strong) NSString* n_description;
@property (nonatomic, strong) NSMutableArray* commands;
@end

@interface TL_botInfoEmpty : TLBotInfo<NSCoding>
+(TL_botInfoEmpty*)create;
@end
@interface TL_botInfo : TLBotInfo<NSCoding>
+(TL_botInfo*)createWithUser_id:(int)user_id version:(int)version share_text:(NSString*)share_text n_description:(NSString*)n_description commands:(NSMutableArray*)commands;
@end
	
@interface TLKeyboardButton()
@property (nonatomic, strong) NSString* text;
@end

@interface TL_keyboardButton : TLKeyboardButton<NSCoding>
+(TL_keyboardButton*)createWithText:(NSString*)text;
@end
	
@interface TLKeyboardButtonRow()
@property (nonatomic, strong) NSMutableArray* buttons;
@end

@interface TL_keyboardButtonRow : TLKeyboardButtonRow<NSCoding>
+(TL_keyboardButtonRow*)createWithButtons:(NSMutableArray*)buttons;
@end
	
@interface TLReplyMarkup()
@property int flags;
@property (nonatomic,assign,readonly) BOOL isSelective;
@property (nonatomic,assign,readonly) BOOL isSingle_use;
@property (nonatomic,assign,readonly) BOOL isResize;
@property (nonatomic, strong) NSMutableArray* rows;
@end

@interface TL_replyKeyboardHide : TLReplyMarkup<NSCoding>
+(TL_replyKeyboardHide*)createWithFlags:(int)flags ;
@end
@interface TL_replyKeyboardForceReply : TLReplyMarkup<NSCoding>
+(TL_replyKeyboardForceReply*)createWithFlags:(int)flags  ;
@end
@interface TL_replyKeyboardMarkup : TLReplyMarkup<NSCoding>
+(TL_replyKeyboardMarkup*)createWithFlags:(int)flags    rows:(NSMutableArray*)rows;
@end
	
@interface TLhelp_AppChangelog()
@property (nonatomic, strong) NSString* text;
@end

@interface TL_help_appChangelogEmpty : TLhelp_AppChangelog<NSCoding>
+(TL_help_appChangelogEmpty*)create;
@end
@interface TL_help_appChangelog : TLhelp_AppChangelog<NSCoding>
+(TL_help_appChangelog*)createWithText:(NSString*)text;
@end
	
@interface TLMessageEntity()
@property int offset;
@property int length;
@property (nonatomic, strong) NSString* language;
@property (nonatomic, strong) NSString* url;
@end

@interface TL_messageEntityUnknown : TLMessageEntity<NSCoding>
+(TL_messageEntityUnknown*)createWithOffset:(int)offset length:(int)length;
@end
@interface TL_messageEntityMention : TLMessageEntity<NSCoding>
+(TL_messageEntityMention*)createWithOffset:(int)offset length:(int)length;
@end
@interface TL_messageEntityHashtag : TLMessageEntity<NSCoding>
+(TL_messageEntityHashtag*)createWithOffset:(int)offset length:(int)length;
@end
@interface TL_messageEntityBotCommand : TLMessageEntity<NSCoding>
+(TL_messageEntityBotCommand*)createWithOffset:(int)offset length:(int)length;
@end
@interface TL_messageEntityUrl : TLMessageEntity<NSCoding>
+(TL_messageEntityUrl*)createWithOffset:(int)offset length:(int)length;
@end
@interface TL_messageEntityEmail : TLMessageEntity<NSCoding>
+(TL_messageEntityEmail*)createWithOffset:(int)offset length:(int)length;
@end
@interface TL_messageEntityBold : TLMessageEntity<NSCoding>
+(TL_messageEntityBold*)createWithOffset:(int)offset length:(int)length;
@end
@interface TL_messageEntityItalic : TLMessageEntity<NSCoding>
+(TL_messageEntityItalic*)createWithOffset:(int)offset length:(int)length;
@end
@interface TL_messageEntityCode : TLMessageEntity<NSCoding>
+(TL_messageEntityCode*)createWithOffset:(int)offset length:(int)length;
@end
@interface TL_messageEntityPre : TLMessageEntity<NSCoding>
+(TL_messageEntityPre*)createWithOffset:(int)offset length:(int)length language:(NSString*)language;
@end
@interface TL_messageEntityTextUrl : TLMessageEntity<NSCoding>
+(TL_messageEntityTextUrl*)createWithOffset:(int)offset length:(int)length url:(NSString*)url;
@end
	
@interface TLInputChannel()
@property int channel_id;
@property long access_hash;
@end

@interface TL_inputChannelEmpty : TLInputChannel<NSCoding>
+(TL_inputChannelEmpty*)create;
@end
@interface TL_inputChannel : TLInputChannel<NSCoding>
+(TL_inputChannel*)createWithChannel_id:(int)channel_id access_hash:(long)access_hash;
@end
	
@interface TLcontacts_ResolvedPeer()
@property (nonatomic, strong) TLPeer* peer;
@property (nonatomic, strong) NSMutableArray* chats;
@property (nonatomic, strong) NSMutableArray* users;
@end

@interface TL_contacts_resolvedPeer : TLcontacts_ResolvedPeer<NSCoding>
+(TL_contacts_resolvedPeer*)createWithPeer:(TLPeer*)peer chats:(NSMutableArray*)chats users:(NSMutableArray*)users;
@end
	
@interface TLMessageRange()
@property int min_id;
@property int max_id;
@end

@interface TL_messageRange : TLMessageRange<NSCoding>
+(TL_messageRange*)createWithMin_id:(int)min_id max_id:(int)max_id;
@end
	
@interface TLMessageGroup()
@property int min_id;
@property int max_id;
@property int n_count;
@property int date;
@end

@interface TL_messageGroup : TLMessageGroup<NSCoding>
+(TL_messageGroup*)createWithMin_id:(int)min_id max_id:(int)max_id n_count:(int)n_count date:(int)date;
@end
	
@interface TLupdates_ChannelDifference()
@property int flags;
@property (nonatomic,assign,readonly) BOOL isFinal;
@property int pts;
@property int timeout;
@property int top_message;
@property int top_important_message;
@property int read_inbox_max_id;
@property int unread_count;
@property int unread_important_count;
@property (nonatomic, strong) NSMutableArray* messages;
@property (nonatomic, strong) NSMutableArray* chats;
@property (nonatomic, strong) NSMutableArray* users;
@property (nonatomic, strong) NSMutableArray* n_messages;
@property (nonatomic, strong) NSMutableArray* other_updates;
@end

@interface TL_updates_channelDifferenceEmpty : TLupdates_ChannelDifference<NSCoding>
+(TL_updates_channelDifferenceEmpty*)createWithFlags:(int)flags  pts:(int)pts timeout:(int)timeout;
@end
@interface TL_updates_channelDifferenceTooLong : TLupdates_ChannelDifference<NSCoding>
+(TL_updates_channelDifferenceTooLong*)createWithFlags:(int)flags  pts:(int)pts timeout:(int)timeout top_message:(int)top_message top_important_message:(int)top_important_message read_inbox_max_id:(int)read_inbox_max_id unread_count:(int)unread_count unread_important_count:(int)unread_important_count messages:(NSMutableArray*)messages chats:(NSMutableArray*)chats users:(NSMutableArray*)users;
@end
@interface TL_updates_channelDifference : TLupdates_ChannelDifference<NSCoding>
+(TL_updates_channelDifference*)createWithFlags:(int)flags  pts:(int)pts timeout:(int)timeout n_messages:(NSMutableArray*)n_messages other_updates:(NSMutableArray*)other_updates chats:(NSMutableArray*)chats users:(NSMutableArray*)users;
@end
	
@interface TLChannelMessagesFilter()
@property int flags;
@property (nonatomic,assign,readonly) BOOL isImportant_only;
@property (nonatomic,assign,readonly) BOOL isExclude_new_messages;
@property (nonatomic, strong) NSMutableArray* ranges;
@end

@interface TL_channelMessagesFilterEmpty : TLChannelMessagesFilter<NSCoding>
+(TL_channelMessagesFilterEmpty*)create;
@end
@interface TL_channelMessagesFilter : TLChannelMessagesFilter<NSCoding>
+(TL_channelMessagesFilter*)createWithFlags:(int)flags   ranges:(NSMutableArray*)ranges;
@end
@interface TL_channelMessagesFilterCollapsed : TLChannelMessagesFilter<NSCoding>
+(TL_channelMessagesFilterCollapsed*)create;
@end
	
@interface TLChannelParticipant()
@property int user_id;
@property int date;
@property int inviter_id;
@property int kicked_by;
@end

@interface TL_channelParticipant : TLChannelParticipant<NSCoding>
+(TL_channelParticipant*)createWithUser_id:(int)user_id date:(int)date;
@end
@interface TL_channelParticipantSelf : TLChannelParticipant<NSCoding>
+(TL_channelParticipantSelf*)createWithUser_id:(int)user_id inviter_id:(int)inviter_id date:(int)date;
@end
@interface TL_channelParticipantModerator : TLChannelParticipant<NSCoding>
+(TL_channelParticipantModerator*)createWithUser_id:(int)user_id inviter_id:(int)inviter_id date:(int)date;
@end
@interface TL_channelParticipantEditor : TLChannelParticipant<NSCoding>
+(TL_channelParticipantEditor*)createWithUser_id:(int)user_id inviter_id:(int)inviter_id date:(int)date;
@end
@interface TL_channelParticipantKicked : TLChannelParticipant<NSCoding>
+(TL_channelParticipantKicked*)createWithUser_id:(int)user_id kicked_by:(int)kicked_by date:(int)date;
@end
@interface TL_channelParticipantCreator : TLChannelParticipant<NSCoding>
+(TL_channelParticipantCreator*)createWithUser_id:(int)user_id;
@end
	
@interface TLChannelParticipantsFilter()

@end

@interface TL_channelParticipantsRecent : TLChannelParticipantsFilter<NSCoding>
+(TL_channelParticipantsRecent*)create;
@end
@interface TL_channelParticipantsAdmins : TLChannelParticipantsFilter<NSCoding>
+(TL_channelParticipantsAdmins*)create;
@end
@interface TL_channelParticipantsKicked : TLChannelParticipantsFilter<NSCoding>
+(TL_channelParticipantsKicked*)create;
@end
@interface TL_channelParticipantsBots : TLChannelParticipantsFilter<NSCoding>
+(TL_channelParticipantsBots*)create;
@end
	
@interface TLChannelParticipantRole()

@end

@interface TL_channelRoleEmpty : TLChannelParticipantRole<NSCoding>
+(TL_channelRoleEmpty*)create;
@end
@interface TL_channelRoleModerator : TLChannelParticipantRole<NSCoding>
+(TL_channelRoleModerator*)create;
@end
@interface TL_channelRoleEditor : TLChannelParticipantRole<NSCoding>
+(TL_channelRoleEditor*)create;
@end
	
@interface TLchannels_ChannelParticipants()
@property int n_count;
@property (nonatomic, strong) NSMutableArray* participants;
@property (nonatomic, strong) NSMutableArray* users;
@end

@interface TL_channels_channelParticipants : TLchannels_ChannelParticipants<NSCoding>
+(TL_channels_channelParticipants*)createWithN_count:(int)n_count participants:(NSMutableArray*)participants users:(NSMutableArray*)users;
@end
	
@interface TLchannels_ChannelParticipant()
@property (nonatomic, strong) TLChannelParticipant* participant;
@property (nonatomic, strong) NSMutableArray* users;
@end

@interface TL_channels_channelParticipant : TLchannels_ChannelParticipant<NSCoding>
+(TL_channels_channelParticipant*)createWithParticipant:(TLChannelParticipant*)participant users:(NSMutableArray*)users;
@end
	
@interface TLhelp_TermsOfService()
@property (nonatomic, strong) NSString* text;
@end

@interface TL_help_termsOfService : TLhelp_TermsOfService<NSCoding>
+(TL_help_termsOfService*)createWithText:(NSString*)text;
@end
	
@interface TLProtoMessage()
@property long msg_id;
@property int seqno;
@property int bytes;
@property (nonatomic, strong) TLObject* body;
@end

@interface TL_proto_message : TLProtoMessage<NSCoding>
+(TL_proto_message*)createWithMsg_id:(long)msg_id seqno:(int)seqno bytes:(int)bytes body:(TLObject*)body;
@end
	
@interface TLProtoMessageContainer()
@property (nonatomic, strong) NSMutableArray* messages;
@end

@interface TL_msg_container : TLProtoMessageContainer<NSCoding>
+(TL_msg_container*)createWithMessages:(NSMutableArray*)messages;
@end
	
@interface TLResPQ()
@property (nonatomic, strong) NSData* nonce;
@property (nonatomic, strong) NSData* server_nonce;
@property (nonatomic, strong) NSData* pq;
@property (nonatomic, strong) NSMutableArray* server_public_key_fingerprints;
@end

@interface TL_req_pq : TLResPQ<NSCoding>
+(TL_req_pq*)createWithNonce:(NSData*)nonce;
@end
@interface TL_resPQ : TLResPQ<NSCoding>
+(TL_resPQ*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce pq:(NSData*)pq server_public_key_fingerprints:(NSMutableArray*)server_public_key_fingerprints;
@end
	
@interface TLServer_DH_inner_data()
@property (nonatomic, strong) NSData* nonce;
@property (nonatomic, strong) NSData* server_nonce;
@property int g;
@property (nonatomic, strong) NSData* dh_prime;
@property (nonatomic, strong) NSData* g_a;
@property int server_time;
@end

@interface TL_server_DH_inner_data : TLServer_DH_inner_data<NSCoding>
+(TL_server_DH_inner_data*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce g:(int)g dh_prime:(NSData*)dh_prime g_a:(NSData*)g_a server_time:(int)server_time;
@end
	
@interface TLP_Q_inner_data()
@property (nonatomic, strong) NSData* pq;
@property (nonatomic, strong) NSData* p;
@property (nonatomic, strong) NSData* q;
@property (nonatomic, strong) NSData* nonce;
@property (nonatomic, strong) NSData* server_nonce;
@property (nonatomic, strong) NSData* n_nonce;
@end

@interface TL_p_q_inner_data : TLP_Q_inner_data<NSCoding>
+(TL_p_q_inner_data*)createWithPq:(NSData*)pq p:(NSData*)p q:(NSData*)q nonce:(NSData*)nonce server_nonce:(NSData*)server_nonce n_nonce:(NSData*)n_nonce;
@end
	
@interface TLServer_DH_Params()
@property (nonatomic, strong) NSData* nonce;
@property (nonatomic, strong) NSData* server_nonce;
@property (nonatomic, strong) NSData* p;
@property (nonatomic, strong) NSData* q;
@property long public_key_fingerprint;
@property (nonatomic, strong) NSData* encrypted_data;
@property (nonatomic, strong) NSData* n_nonce_hash;
@property (nonatomic, strong) NSData* encrypted_answer;
@end

@interface TL_req_DH_params : TLServer_DH_Params<NSCoding>
+(TL_req_DH_params*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce p:(NSData*)p q:(NSData*)q public_key_fingerprint:(long)public_key_fingerprint encrypted_data:(NSData*)encrypted_data;
@end
@interface TL_server_DH_params_fail : TLServer_DH_Params<NSCoding>
+(TL_server_DH_params_fail*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce n_nonce_hash:(NSData*)n_nonce_hash;
@end
@interface TL_server_DH_params_ok : TLServer_DH_Params<NSCoding>
+(TL_server_DH_params_ok*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce encrypted_answer:(NSData*)encrypted_answer;
@end
	
@interface TLClient_DH_Inner_Data()
@property (nonatomic, strong) NSData* nonce;
@property (nonatomic, strong) NSData* server_nonce;
@property long retry_id;
@property (nonatomic, strong) NSData* g_b;
@end

@interface TL_client_DH_inner_data : TLClient_DH_Inner_Data<NSCoding>
+(TL_client_DH_inner_data*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce retry_id:(long)retry_id g_b:(NSData*)g_b;
@end
	
@interface TLSet_client_DH_params_answer()
@property (nonatomic, strong) NSData* nonce;
@property (nonatomic, strong) NSData* server_nonce;
@property (nonatomic, strong) NSData* encrypted_data;
@property (nonatomic, strong) NSData* n_nonce_hash1;
@property (nonatomic, strong) NSData* n_nonce_hash2;
@property (nonatomic, strong) NSData* n_nonce_hash3;
@end

@interface TL_set_client_DH_params : TLSet_client_DH_params_answer<NSCoding>
+(TL_set_client_DH_params*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce encrypted_data:(NSData*)encrypted_data;
@end
@interface TL_dh_gen_ok : TLSet_client_DH_params_answer<NSCoding>
+(TL_dh_gen_ok*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce n_nonce_hash1:(NSData*)n_nonce_hash1;
@end
@interface TL_dh_gen_retry : TLSet_client_DH_params_answer<NSCoding>
+(TL_dh_gen_retry*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce n_nonce_hash2:(NSData*)n_nonce_hash2;
@end
@interface TL_dh_gen_fail : TLSet_client_DH_params_answer<NSCoding>
+(TL_dh_gen_fail*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce n_nonce_hash3:(NSData*)n_nonce_hash3;
@end
	
@interface TLPong()
@property long ping_id;
@property long msg_id;
@end

@interface TL_ping : TLPong<NSCoding>
+(TL_ping*)createWithPing_id:(long)ping_id;
@end
@interface TL_pong : TLPong<NSCoding>
+(TL_pong*)createWithMsg_id:(long)msg_id ping_id:(long)ping_id;
@end
	
@interface TLBadMsgNotification()
@property long bad_msg_id;
@property int bad_msg_seqno;
@property int error_code;
@property long new_server_salt;
@end

@interface TL_bad_msg_notification : TLBadMsgNotification<NSCoding>
+(TL_bad_msg_notification*)createWithBad_msg_id:(long)bad_msg_id bad_msg_seqno:(int)bad_msg_seqno error_code:(int)error_code;
@end
@interface TL_bad_server_salt : TLBadMsgNotification<NSCoding>
+(TL_bad_server_salt*)createWithBad_msg_id:(long)bad_msg_id bad_msg_seqno:(int)bad_msg_seqno error_code:(int)error_code new_server_salt:(long)new_server_salt;
@end
	
@interface TLNewSession()
@property long first_msg_id;
@property long unique_id;
@property long server_salt;
@end

@interface TL_new_session_created : TLNewSession<NSCoding>
+(TL_new_session_created*)createWithFirst_msg_id:(long)first_msg_id unique_id:(long)unique_id server_salt:(long)server_salt;
@end
	
@interface TLRpcResult()
@property long req_msg_id;
@property (nonatomic, strong) TLObject* result;
@end

@interface TL_rpc_result : TLRpcResult<NSCoding>
+(TL_rpc_result*)createWithReq_msg_id:(long)req_msg_id result:(TLObject*)result;
@end
	
@interface TLRpcError()
@property int error_code;
@property (nonatomic, strong) NSString* error_message;
@end

@interface TL_rpc_error : TLRpcError<NSCoding>
+(TL_rpc_error*)createWithError_code:(int)error_code error_message:(NSString*)error_message;
@end
	
@interface TLRSAPublicKey()
@property (nonatomic, strong) NSData* n;
@property (nonatomic, strong) NSData* e;
@end

@interface TL_rsa_public_key : TLRSAPublicKey<NSCoding>
+(TL_rsa_public_key*)createWithN:(NSData*)n e:(NSData*)e;
@end
	
@interface TLMsgsAck()
@property (nonatomic, strong) NSMutableArray* msg_ids;
@end

@interface TL_msgs_ack : TLMsgsAck<NSCoding>
+(TL_msgs_ack*)createWithMsg_ids:(NSMutableArray*)msg_ids;
@end
	
@interface TLRpcDropAnswer()
@property long req_msg_id;
@property long msg_id;
@property int seq_no;
@property int bytes;
@end

@interface TL_rpc_drop_answer : TLRpcDropAnswer<NSCoding>
+(TL_rpc_drop_answer*)createWithReq_msg_id:(long)req_msg_id;
@end
@interface TL_rpc_answer_unknown : TLRpcDropAnswer<NSCoding>
+(TL_rpc_answer_unknown*)create;
@end
@interface TL_rpc_answer_dropped_running : TLRpcDropAnswer<NSCoding>
+(TL_rpc_answer_dropped_running*)create;
@end
@interface TL_rpc_answer_dropped : TLRpcDropAnswer<NSCoding>
+(TL_rpc_answer_dropped*)createWithMsg_id:(long)msg_id seq_no:(int)seq_no bytes:(int)bytes;
@end
	
@interface TLFutureSalts()
@property int num;
@property long req_msg_id;
@property int now;
@property (nonatomic, strong) NSMutableArray* salts;
@end

@interface TL_get_future_salts : TLFutureSalts<NSCoding>
+(TL_get_future_salts*)createWithNum:(int)num;
@end
@interface TL_future_salts : TLFutureSalts<NSCoding>
+(TL_future_salts*)createWithReq_msg_id:(long)req_msg_id now:(int)now salts:(NSMutableArray*)salts;
@end
	
@interface TLFutureSalt()
@property int valid_since;
@property int valid_until;
@property long salt;
@end

@interface TL_future_salt : TLFutureSalt<NSCoding>
+(TL_future_salt*)createWithValid_since:(int)valid_since valid_until:(int)valid_until salt:(long)salt;
@end
	
@interface TLDestroySessionRes()
@property long session_id;
@end

@interface TL_destroy_session : TLDestroySessionRes<NSCoding>
+(TL_destroy_session*)createWithSession_id:(long)session_id;
@end
@interface TL_destroy_session_ok : TLDestroySessionRes<NSCoding>
+(TL_destroy_session_ok*)createWithSession_id:(long)session_id;
@end
@interface TL_destroy_session_none : TLDestroySessionRes<NSCoding>
+(TL_destroy_session_none*)createWithSession_id:(long)session_id;
@end
	
@interface TLProtoMessageCopy()
@property (nonatomic, strong) TLProtoMessage* orig_message;
@end

@interface TL_msg_copy : TLProtoMessageCopy<NSCoding>
+(TL_msg_copy*)createWithOrig_message:(TLProtoMessage*)orig_message;
@end
	
@interface TLObject()
@property (nonatomic, strong) NSData* packed_data;
@end

@interface TL_gzip_packed : TLObject<NSCoding>
+(TL_gzip_packed*)createWithPacked_data:(NSData*)packed_data;
@end
	
@interface TLHttpWait()
@property int max_delay;
@property int wait_after;
@property int max_wait;
@end

@interface TL_http_wait : TLHttpWait<NSCoding>
+(TL_http_wait*)createWithMax_delay:(int)max_delay wait_after:(int)wait_after max_wait:(int)max_wait;
@end
	
@interface TLMsgsStateReq()
@property (nonatomic, strong) NSMutableArray* msg_ids;
@end

@interface TL_msgs_state_req : TLMsgsStateReq<NSCoding>
+(TL_msgs_state_req*)createWithMsg_ids:(NSMutableArray*)msg_ids;
@end
	
@interface TLMsgsStateInfo()
@property long req_msg_id;
@property (nonatomic, strong) NSData* info;
@end

@interface TL_msgs_state_info : TLMsgsStateInfo<NSCoding>
+(TL_msgs_state_info*)createWithReq_msg_id:(long)req_msg_id info:(NSData*)info;
@end
	
@interface TLMsgsAllInfo()
@property (nonatomic, strong) NSMutableArray* msg_ids;
@property (nonatomic, strong) NSData* info;
@end

@interface TL_msgs_all_info : TLMsgsAllInfo<NSCoding>
+(TL_msgs_all_info*)createWithMsg_ids:(NSMutableArray*)msg_ids info:(NSData*)info;
@end
	
@interface TLMsgDetailedInfo()
@property long msg_id;
@property long answer_msg_id;
@property int bytes;
@property int status;
@end

@interface TL_msg_detailed_info : TLMsgDetailedInfo<NSCoding>
+(TL_msg_detailed_info*)createWithMsg_id:(long)msg_id answer_msg_id:(long)answer_msg_id bytes:(int)bytes status:(int)status;
@end
@interface TL_msg_new_detailed_info : TLMsgDetailedInfo<NSCoding>
+(TL_msg_new_detailed_info*)createWithAnswer_msg_id:(long)answer_msg_id bytes:(int)bytes status:(int)status;
@end
	
@interface TLMsgResendReq()
@property (nonatomic, strong) NSMutableArray* msg_ids;
@end

@interface TL_msg_resend_req : TLMsgResendReq<NSCoding>
+(TL_msg_resend_req*)createWithMsg_ids:(NSMutableArray*)msg_ids;
@end
