//
//  TLRPCApi.h
//  Telegram
//
//  Auto created by Dmitry Kondratyev on 07.04.14.
//  Copyright (c) 2013 Telegram for OS X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLRPC.h"
#import "TLApiObject.h"

@interface TLAPI_auth_checkPhone : TLApiObject
@property (nonatomic, strong) NSString *phone_number;

+ (TLAPI_auth_checkPhone *)createWithPhone_number:(NSString *)phone_number;
@end

@interface TLAPI_auth_sendCode : TLApiObject
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic) int sms_type;
@property (nonatomic) int api_id;
@property (nonatomic, strong) NSString *api_hash;
@property (nonatomic, strong) NSString *lang_code;

+ (TLAPI_auth_sendCode *)createWithPhone_number:(NSString *)phone_number sms_type:(int)sms_type api_id:(int)api_id api_hash:(NSString *)api_hash lang_code:(NSString *)lang_code;
@end

@interface TLAPI_auth_sendCall : TLApiObject
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic, strong) NSString *phone_code_hash;

+ (TLAPI_auth_sendCall *)createWithPhone_number:(NSString *)phone_number phone_code_hash:(NSString *)phone_code_hash;
@end

@interface TLAPI_auth_signUp : TLApiObject
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic, strong) NSString *phone_code_hash;
@property (nonatomic, strong) NSString *phone_code;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;

+ (TLAPI_auth_signUp *)createWithPhone_number:(NSString *)phone_number phone_code_hash:(NSString *)phone_code_hash phone_code:(NSString *)phone_code first_name:(NSString *)first_name last_name:(NSString *)last_name;
@end

@interface TLAPI_auth_signIn : TLApiObject
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic, strong) NSString *phone_code_hash;
@property (nonatomic, strong) NSString *phone_code;

+ (TLAPI_auth_signIn *)createWithPhone_number:(NSString *)phone_number phone_code_hash:(NSString *)phone_code_hash phone_code:(NSString *)phone_code;
@end

@interface TLAPI_auth_logOut : TLApiObject


+ (TLAPI_auth_logOut *)create;
@end

@interface TLAPI_auth_resetAuthorizations : TLApiObject


+ (TLAPI_auth_resetAuthorizations *)create;
@end

@interface TLAPI_auth_sendInvites : TLApiObject
@property (nonatomic, strong) NSMutableArray *phone_numbers;
@property (nonatomic, strong) NSString *message;

+ (TLAPI_auth_sendInvites *)createWithPhone_numbers:(NSMutableArray *)phone_numbers message:(NSString *)message;
@end

@interface TLAPI_auth_exportAuthorization : TLApiObject
@property (nonatomic) int dc_id;

+ (TLAPI_auth_exportAuthorization *)createWithDc_id:(int)dc_id;
@end

@interface TLAPI_auth_importAuthorization : TLApiObject
@property (nonatomic) int n_id;
@property (nonatomic, strong) NSData *bytes;

+ (TLAPI_auth_importAuthorization *)createWithN_id:(int)n_id bytes:(NSData *)bytes;
@end

@interface TLAPI_account_registerDevice : TLApiObject
@property (nonatomic) int token_type;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *device_model;
@property (nonatomic, strong) NSString *system_version;
@property (nonatomic, strong) NSString *app_version;
@property BOOL app_sandbox;
@property (nonatomic, strong) NSString *lang_code;

+ (TLAPI_account_registerDevice *)createWithToken_type:(int)token_type token:(NSString *)token device_model:(NSString *)device_model system_version:(NSString *)system_version app_version:(NSString *)app_version app_sandbox:(BOOL)app_sandbox lang_code:(NSString *)lang_code;
@end

@interface TLAPI_account_unregisterDevice : TLApiObject
@property (nonatomic) int token_type;
@property (nonatomic, strong) NSString *token;

+ (TLAPI_account_unregisterDevice *)createWithToken_type:(int)token_type token:(NSString *)token;
@end

@interface TLAPI_account_updateNotifySettings : TLApiObject
@property (nonatomic, strong) TGInputNotifyPeer *peer;
@property (nonatomic, strong) TGInputPeerNotifySettings *settings;

+ (TLAPI_account_updateNotifySettings *)createWithPeer:(TGInputNotifyPeer *)peer settings:(TGInputPeerNotifySettings *)settings;
@end

@interface TLAPI_account_getNotifySettings : TLApiObject
@property (nonatomic, strong) TGInputNotifyPeer *peer;

+ (TLAPI_account_getNotifySettings *)createWithPeer:(TGInputNotifyPeer *)peer;
@end

@interface TLAPI_account_resetNotifySettings : TLApiObject


+ (TLAPI_account_resetNotifySettings *)create;
@end

@interface TLAPI_account_updateProfile : TLApiObject
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;

+ (TLAPI_account_updateProfile *)createWithFirst_name:(NSString *)first_name last_name:(NSString *)last_name;
@end

@interface TLAPI_account_updateStatus : TLApiObject
@property BOOL offline;

+ (TLAPI_account_updateStatus *)createWithOffline:(BOOL)offline;
@end

@interface TLAPI_account_getWallPapers : TLApiObject


+ (TLAPI_account_getWallPapers *)create;
@end

@interface TLAPI_users_getUsers : TLApiObject
@property (nonatomic, strong) NSMutableArray *n_id;

+ (TLAPI_users_getUsers *)createWithN_id:(NSMutableArray *)n_id;
@end

@interface TLAPI_users_getFullUser : TLApiObject
@property (nonatomic, strong) TGInputUser *n_id;

+ (TLAPI_users_getFullUser *)createWithN_id:(TGInputUser *)n_id;
@end

@interface TLAPI_contacts_getStatuses : TLApiObject


+ (TLAPI_contacts_getStatuses *)create;
@end

@interface TLAPI_contacts_getContacts : TLApiObject
@property (nonatomic, strong) NSString *hash;

+ (TLAPI_contacts_getContacts *)createWithHash:(NSString *)hash;
@end

@interface TLAPI_contacts_importContacts : TLApiObject
@property (nonatomic, strong) NSMutableArray *contacts;
@property BOOL replace;

+ (TLAPI_contacts_importContacts *)createWithContacts:(NSMutableArray *)contacts replace:(BOOL)replace;
@end

@interface TLAPI_contacts_search : TLApiObject
@property (nonatomic, strong) NSString *q;
@property (nonatomic) int limit;

+ (TLAPI_contacts_search *)createWithQ:(NSString *)q limit:(int)limit;
@end

@interface TLAPI_contacts_getSuggested : TLApiObject
@property (nonatomic) int limit;

+ (TLAPI_contacts_getSuggested *)createWithLimit:(int)limit;
@end

@interface TLAPI_contacts_deleteContact : TLApiObject
@property (nonatomic, strong) TGInputUser *n_id;

+ (TLAPI_contacts_deleteContact *)createWithN_id:(TGInputUser *)n_id;
@end

@interface TLAPI_contacts_deleteContacts : TLApiObject
@property (nonatomic, strong) NSMutableArray *n_id;

+ (TLAPI_contacts_deleteContacts *)createWithN_id:(NSMutableArray *)n_id;
@end

@interface TLAPI_contacts_block : TLApiObject
@property (nonatomic, strong) TGInputUser *n_id;

+ (TLAPI_contacts_block *)createWithN_id:(TGInputUser *)n_id;
@end

@interface TLAPI_contacts_unblock : TLApiObject
@property (nonatomic, strong) TGInputUser *n_id;

+ (TLAPI_contacts_unblock *)createWithN_id:(TGInputUser *)n_id;
@end

@interface TLAPI_contacts_getBlocked : TLApiObject
@property (nonatomic) int offset;
@property (nonatomic) int limit;

+ (TLAPI_contacts_getBlocked *)createWithOffset:(int)offset limit:(int)limit;
@end

@interface TLAPI_messages_getMessages : TLApiObject
@property (nonatomic, strong) NSMutableArray *n_id;

+ (TLAPI_messages_getMessages *)createWithN_id:(NSMutableArray *)n_id;
@end

@interface TLAPI_messages_getDialogs : TLApiObject
@property (nonatomic) int offset;
@property (nonatomic) int max_id;
@property (nonatomic) int limit;

+ (TLAPI_messages_getDialogs *)createWithOffset:(int)offset max_id:(int)max_id limit:(int)limit;
@end

@interface TLAPI_messages_getHistory : TLApiObject
@property (nonatomic, strong) TGInputPeer *peer;
@property (nonatomic) int offset;
@property (nonatomic) int max_id;
@property (nonatomic) int limit;

+ (TLAPI_messages_getHistory *)createWithPeer:(TGInputPeer *)peer offset:(int)offset max_id:(int)max_id limit:(int)limit;
@end

@interface TLAPI_messages_search : TLApiObject
@property (nonatomic, strong) TGInputPeer *peer;
@property (nonatomic, strong) NSString *q;
@property (nonatomic, strong) TGMessagesFilter *filter;
@property (nonatomic) int min_date;
@property (nonatomic) int max_date;
@property (nonatomic) int offset;
@property (nonatomic) int max_id;
@property (nonatomic) int limit;

+ (TLAPI_messages_search *)createWithPeer:(TGInputPeer *)peer q:(NSString *)q filter:(TGMessagesFilter *)filter min_date:(int)min_date max_date:(int)max_date offset:(int)offset max_id:(int)max_id limit:(int)limit;
@end

@interface TLAPI_messages_readHistory : TLApiObject
@property (nonatomic, strong) TGInputPeer *peer;
@property (nonatomic) int max_id;
@property (nonatomic) int offset;

+ (TLAPI_messages_readHistory *)createWithPeer:(TGInputPeer *)peer max_id:(int)max_id offset:(int)offset;
@end

@interface TLAPI_messages_deleteHistory : TLApiObject
@property (nonatomic, strong) TGInputPeer *peer;
@property (nonatomic) int offset;

+ (TLAPI_messages_deleteHistory *)createWithPeer:(TGInputPeer *)peer offset:(int)offset;
@end

@interface TLAPI_messages_deleteMessages : TLApiObject
@property (nonatomic, strong) NSMutableArray *n_id;

+ (TLAPI_messages_deleteMessages *)createWithN_id:(NSMutableArray *)n_id;
@end

@interface TLAPI_messages_restoreMessages : TLApiObject
@property (nonatomic, strong) NSMutableArray *n_id;

+ (TLAPI_messages_restoreMessages *)createWithN_id:(NSMutableArray *)n_id;
@end

@interface TLAPI_messages_receivedMessages : TLApiObject
@property (nonatomic) int max_id;

+ (TLAPI_messages_receivedMessages *)createWithMax_id:(int)max_id;
@end

@interface TLAPI_messages_setTyping : TLApiObject
@property (nonatomic, strong) TGInputPeer *peer;
@property BOOL typing;

+ (TLAPI_messages_setTyping *)createWithPeer:(TGInputPeer *)peer typing:(BOOL)typing;
@end

@interface TLAPI_messages_sendMessage : TLApiObject
@property (nonatomic, strong) TGInputPeer *peer;
@property (nonatomic, strong) NSString *message;
@property long random_id;

+ (TLAPI_messages_sendMessage *)createWithPeer:(TGInputPeer *)peer message:(NSString *)message random_id:(long)random_id;
@end

@interface TLAPI_messages_sendMedia : TLApiObject
@property (nonatomic, strong) TGInputPeer *peer;
@property (nonatomic, strong) TGInputMedia *media;
@property long random_id;

+ (TLAPI_messages_sendMedia *)createWithPeer:(TGInputPeer *)peer media:(TGInputMedia *)media random_id:(long)random_id;
@end

@interface TLAPI_messages_forwardMessages : TLApiObject
@property (nonatomic, strong) TGInputPeer *peer;
@property (nonatomic, strong) NSMutableArray *n_id;

+ (TLAPI_messages_forwardMessages *)createWithPeer:(TGInputPeer *)peer n_id:(NSMutableArray *)n_id;
@end

@interface TLAPI_messages_getChats : TLApiObject
@property (nonatomic, strong) NSMutableArray *n_id;

+ (TLAPI_messages_getChats *)createWithN_id:(NSMutableArray *)n_id;
@end

@interface TLAPI_messages_getFullChat : TLApiObject
@property (nonatomic) int chat_id;

+ (TLAPI_messages_getFullChat *)createWithChat_id:(int)chat_id;
@end

@interface TLAPI_messages_editChatTitle : TLApiObject
@property (nonatomic) int chat_id;
@property (nonatomic, strong) NSString *title;

+ (TLAPI_messages_editChatTitle *)createWithChat_id:(int)chat_id title:(NSString *)title;
@end

@interface TLAPI_messages_editChatPhoto : TLApiObject
@property (nonatomic) int chat_id;
@property (nonatomic, strong) TGInputChatPhoto *photo;

+ (TLAPI_messages_editChatPhoto *)createWithChat_id:(int)chat_id photo:(TGInputChatPhoto *)photo;
@end

@interface TLAPI_messages_addChatUser : TLApiObject
@property (nonatomic) int chat_id;
@property (nonatomic, strong) TGInputUser *user_id;
@property (nonatomic) int fwd_limit;

+ (TLAPI_messages_addChatUser *)createWithChat_id:(int)chat_id user_id:(TGInputUser *)user_id fwd_limit:(int)fwd_limit;
@end

@interface TLAPI_messages_deleteChatUser : TLApiObject
@property (nonatomic) int chat_id;
@property (nonatomic, strong) TGInputUser *user_id;

+ (TLAPI_messages_deleteChatUser *)createWithChat_id:(int)chat_id user_id:(TGInputUser *)user_id;
@end

@interface TLAPI_messages_createChat : TLApiObject
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSString *title;

+ (TLAPI_messages_createChat *)createWithUsers:(NSMutableArray *)users title:(NSString *)title;
@end

@interface TLAPI_updates_getState : TLApiObject


+ (TLAPI_updates_getState *)create;
@end

@interface TLAPI_updates_getDifference : TLApiObject
@property (nonatomic) int pts;
@property (nonatomic) int date;
@property (nonatomic) int qts;

+ (TLAPI_updates_getDifference *)createWithPts:(int)pts date:(int)date qts:(int)qts;
@end

@interface TLAPI_photos_updateProfilePhoto : TLApiObject
@property (nonatomic, strong) TGInputPhoto *n_id;
@property (nonatomic, strong) TGInputPhotoCrop *crop;

+ (TLAPI_photos_updateProfilePhoto *)createWithN_id:(TGInputPhoto *)n_id crop:(TGInputPhotoCrop *)crop;
@end

@interface TLAPI_photos_uploadProfilePhoto : TLApiObject
@property (nonatomic, strong) TGInputFile *file;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) TGInputGeoPoint *geo_point;
@property (nonatomic, strong) TGInputPhotoCrop *crop;

+ (TLAPI_photos_uploadProfilePhoto *)createWithFile:(TGInputFile *)file caption:(NSString *)caption geo_point:(TGInputGeoPoint *)geo_point crop:(TGInputPhotoCrop *)crop;
@end

@interface TLAPI_upload_saveFilePart : TLApiObject
@property long file_id;
@property (nonatomic) int file_part;
@property (nonatomic, strong) NSData *bytes;

+ (TLAPI_upload_saveFilePart *)createWithFile_id:(long)file_id file_part:(int)file_part bytes:(NSData *)bytes;
@end

@interface TLAPI_upload_getFile : TLApiObject
@property (nonatomic, strong) TGInputFileLocation *location;
@property (nonatomic) int offset;
@property (nonatomic) int limit;

+ (TLAPI_upload_getFile *)createWithLocation:(TGInputFileLocation *)location offset:(int)offset limit:(int)limit;
@end

@interface TLAPI_help_getConfig : TLApiObject


+ (TLAPI_help_getConfig *)create;
@end

@interface TLAPI_help_getNearestDc : TLApiObject


+ (TLAPI_help_getNearestDc *)create;
@end

@interface TLAPI_help_getAppUpdate : TLApiObject
@property (nonatomic, strong) NSString *device_model;
@property (nonatomic, strong) NSString *system_version;
@property (nonatomic, strong) NSString *app_version;
@property (nonatomic, strong) NSString *lang_code;

+ (TLAPI_help_getAppUpdate *)createWithDevice_model:(NSString *)device_model system_version:(NSString *)system_version app_version:(NSString *)app_version lang_code:(NSString *)lang_code;
@end

@interface TLAPI_help_saveAppLog : TLApiObject
@property (nonatomic, strong) NSMutableArray *events;

+ (TLAPI_help_saveAppLog *)createWithEvents:(NSMutableArray *)events;
@end

@interface TLAPI_help_getInviteText : TLApiObject
@property (nonatomic, strong) NSString *lang_code;

+ (TLAPI_help_getInviteText *)createWithLang_code:(NSString *)lang_code;
@end

@interface TLAPI_photos_getUserPhotos : TLApiObject
@property (nonatomic, strong) TGInputUser *user_id;
@property (nonatomic) int offset;
@property (nonatomic) int max_id;
@property (nonatomic) int limit;

+ (TLAPI_photos_getUserPhotos *)createWithUser_id:(TGInputUser *)user_id offset:(int)offset max_id:(int)max_id limit:(int)limit;
@end

@interface TLAPI_messages_forwardMessage : TLApiObject
@property (nonatomic, strong) TGInputPeer *peer;
@property (nonatomic) int n_id;
@property long random_id;

+ (TLAPI_messages_forwardMessage *)createWithPeer:(TGInputPeer *)peer n_id:(int)n_id random_id:(long)random_id;
@end

@interface TLAPI_messages_sendBroadcast : TLApiObject
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) TGInputMedia *media;

+ (TLAPI_messages_sendBroadcast *)createWithContacts:(NSMutableArray *)contacts message:(NSString *)message media:(TGInputMedia *)media;
@end

@interface TLAPI_geochats_getLocated : TLApiObject
@property (nonatomic, strong) TGInputGeoPoint *geo_point;
@property (nonatomic) int radius;
@property (nonatomic) int limit;

+ (TLAPI_geochats_getLocated *)createWithGeo_point:(TGInputGeoPoint *)geo_point radius:(int)radius limit:(int)limit;
@end

@interface TLAPI_geochats_getRecents : TLApiObject
@property (nonatomic) int offset;
@property (nonatomic) int limit;

+ (TLAPI_geochats_getRecents *)createWithOffset:(int)offset limit:(int)limit;
@end

@interface TLAPI_geochats_checkin : TLApiObject
@property (nonatomic, strong) TGInputGeoChat *peer;

+ (TLAPI_geochats_checkin *)createWithPeer:(TGInputGeoChat *)peer;
@end

@interface TLAPI_geochats_getFullChat : TLApiObject
@property (nonatomic, strong) TGInputGeoChat *peer;

+ (TLAPI_geochats_getFullChat *)createWithPeer:(TGInputGeoChat *)peer;
@end

@interface TLAPI_geochats_editChatTitle : TLApiObject
@property (nonatomic, strong) TGInputGeoChat *peer;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *address;

+ (TLAPI_geochats_editChatTitle *)createWithPeer:(TGInputGeoChat *)peer title:(NSString *)title address:(NSString *)address;
@end

@interface TLAPI_geochats_editChatPhoto : TLApiObject
@property (nonatomic, strong) TGInputGeoChat *peer;
@property (nonatomic, strong) TGInputChatPhoto *photo;

+ (TLAPI_geochats_editChatPhoto *)createWithPeer:(TGInputGeoChat *)peer photo:(TGInputChatPhoto *)photo;
@end

@interface TLAPI_geochats_search : TLApiObject
@property (nonatomic, strong) TGInputGeoChat *peer;
@property (nonatomic, strong) NSString *q;
@property (nonatomic, strong) TGMessagesFilter *filter;
@property (nonatomic) int min_date;
@property (nonatomic) int max_date;
@property (nonatomic) int offset;
@property (nonatomic) int max_id;
@property (nonatomic) int limit;

+ (TLAPI_geochats_search *)createWithPeer:(TGInputGeoChat *)peer q:(NSString *)q filter:(TGMessagesFilter *)filter min_date:(int)min_date max_date:(int)max_date offset:(int)offset max_id:(int)max_id limit:(int)limit;
@end

@interface TLAPI_geochats_getHistory : TLApiObject
@property (nonatomic, strong) TGInputGeoChat *peer;
@property (nonatomic) int offset;
@property (nonatomic) int max_id;
@property (nonatomic) int limit;

+ (TLAPI_geochats_getHistory *)createWithPeer:(TGInputGeoChat *)peer offset:(int)offset max_id:(int)max_id limit:(int)limit;
@end

@interface TLAPI_geochats_setTyping : TLApiObject
@property (nonatomic, strong) TGInputGeoChat *peer;
@property BOOL typing;

+ (TLAPI_geochats_setTyping *)createWithPeer:(TGInputGeoChat *)peer typing:(BOOL)typing;
@end

@interface TLAPI_geochats_sendMessage : TLApiObject
@property (nonatomic, strong) TGInputGeoChat *peer;
@property (nonatomic, strong) NSString *message;
@property long random_id;

+ (TLAPI_geochats_sendMessage *)createWithPeer:(TGInputGeoChat *)peer message:(NSString *)message random_id:(long)random_id;
@end

@interface TLAPI_geochats_sendMedia : TLApiObject
@property (nonatomic, strong) TGInputGeoChat *peer;
@property (nonatomic, strong) TGInputMedia *media;
@property long random_id;

+ (TLAPI_geochats_sendMedia *)createWithPeer:(TGInputGeoChat *)peer media:(TGInputMedia *)media random_id:(long)random_id;
@end

@interface TLAPI_geochats_createGeoChat : TLApiObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) TGInputGeoPoint *geo_point;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *venue;

+ (TLAPI_geochats_createGeoChat *)createWithTitle:(NSString *)title geo_point:(TGInputGeoPoint *)geo_point address:(NSString *)address venue:(NSString *)venue;
@end

@interface TLAPI_messages_getDhConfig : TLApiObject
@property (nonatomic) int version;
@property (nonatomic) int random_length;

+ (TLAPI_messages_getDhConfig *)createWithVersion:(int)version random_length:(int)random_length;
@end

@interface TLAPI_messages_requestEncryption : TLApiObject
@property (nonatomic, strong) TGInputUser *user_id;
@property (nonatomic) int random_id;
@property (nonatomic, strong) NSData *g_a;

+ (TLAPI_messages_requestEncryption *)createWithUser_id:(TGInputUser *)user_id random_id:(int)random_id g_a:(NSData *)g_a;
@end

@interface TLAPI_messages_acceptEncryption : TLApiObject
@property (nonatomic, strong) TGInputEncryptedChat *peer;
@property (nonatomic, strong) NSData *g_b;
@property long key_fingerprint;

+ (TLAPI_messages_acceptEncryption *)createWithPeer:(TGInputEncryptedChat *)peer g_b:(NSData *)g_b key_fingerprint:(long)key_fingerprint;
@end

@interface TLAPI_messages_discardEncryption : TLApiObject
@property (nonatomic) int chat_id;

+ (TLAPI_messages_discardEncryption *)createWithChat_id:(int)chat_id;
@end

@interface TLAPI_messages_setEncryptedTyping : TLApiObject
@property (nonatomic, strong) TGInputEncryptedChat *peer;
@property BOOL typing;

+ (TLAPI_messages_setEncryptedTyping *)createWithPeer:(TGInputEncryptedChat *)peer typing:(BOOL)typing;
@end

@interface TLAPI_messages_readEncryptedHistory : TLApiObject
@property (nonatomic, strong) TGInputEncryptedChat *peer;
@property (nonatomic) int max_date;

+ (TLAPI_messages_readEncryptedHistory *)createWithPeer:(TGInputEncryptedChat *)peer max_date:(int)max_date;
@end

@interface TLAPI_messages_sendEncrypted : TLApiObject
@property (nonatomic, strong) TGInputEncryptedChat *peer;
@property long random_id;
@property (nonatomic, strong) NSData *data;

+ (TLAPI_messages_sendEncrypted *)createWithPeer:(TGInputEncryptedChat *)peer random_id:(long)random_id data:(NSData *)data;
@end

@interface TLAPI_messages_sendEncryptedFile : TLApiObject
@property (nonatomic, strong) TGInputEncryptedChat *peer;
@property long random_id;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) TGInputEncryptedFile *file;

+ (TLAPI_messages_sendEncryptedFile *)createWithPeer:(TGInputEncryptedChat *)peer random_id:(long)random_id data:(NSData *)data file:(TGInputEncryptedFile *)file;
@end

@interface TLAPI_messages_sendEncryptedService : TLApiObject
@property (nonatomic, strong) TGInputEncryptedChat *peer;
@property long random_id;
@property (nonatomic, strong) NSData *data;

+ (TLAPI_messages_sendEncryptedService *)createWithPeer:(TGInputEncryptedChat *)peer random_id:(long)random_id data:(NSData *)data;
@end

@interface TLAPI_messages_receivedQueue : TLApiObject
@property (nonatomic) int max_qts;

+ (TLAPI_messages_receivedQueue *)createWithMax_qts:(int)max_qts;
@end

@interface TLAPI_upload_saveBigFilePart : TLApiObject
@property long file_id;
@property (nonatomic) int file_part;
@property (nonatomic) int file_total_parts;
@property (nonatomic, strong) NSData *bytes;

+ (TLAPI_upload_saveBigFilePart *)createWithFile_id:(long)file_id file_part:(int)file_part file_total_parts:(int)file_total_parts bytes:(NSData *)bytes;
@end

@interface TLAPI_help_getSupport : TLApiObject


+ (TLAPI_help_getSupport *)create;
@end

@interface TLAPI_initConnection : TLApiObject
@property (nonatomic) int api_id;
@property (nonatomic, strong) NSString *device_model;
@property (nonatomic, strong) NSString *system_version;
@property (nonatomic, strong) NSString *app_version;
@property (nonatomic, strong) NSString *lang_code;

@end
