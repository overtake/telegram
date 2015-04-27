//
//  TLApi.h
//  Telegram
//
//  Auto created by Mikhail Filimonov on 27.04.15.
//  Copyright (c) 2013 Telegram for OS X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLApi.h"
#import "TLApiObject.h"

@interface TLAPI_auth_checkPhone : TLApiObject
@property (nonatomic, strong) NSString* phone_number;

+(TLAPI_auth_checkPhone*)createWithPhone_number:(NSString*)phone_number;
@end

@interface TLAPI_auth_sendCode : TLApiObject
@property (nonatomic, strong) NSString* phone_number;
@property int sms_type;
@property int api_id;
@property (nonatomic, strong) NSString* api_hash;
@property (nonatomic, strong) NSString* lang_code;

+(TLAPI_auth_sendCode*)createWithPhone_number:(NSString*)phone_number sms_type:(int)sms_type api_id:(int)api_id api_hash:(NSString*)api_hash lang_code:(NSString*)lang_code;
@end

@interface TLAPI_auth_sendCall : TLApiObject
@property (nonatomic, strong) NSString* phone_number;
@property (nonatomic, strong) NSString* phone_code_hash;

+(TLAPI_auth_sendCall*)createWithPhone_number:(NSString*)phone_number phone_code_hash:(NSString*)phone_code_hash;
@end

@interface TLAPI_auth_signUp : TLApiObject
@property (nonatomic, strong) NSString* phone_number;
@property (nonatomic, strong) NSString* phone_code_hash;
@property (nonatomic, strong) NSString* phone_code;
@property (nonatomic, strong) NSString* first_name;
@property (nonatomic, strong) NSString* last_name;

+(TLAPI_auth_signUp*)createWithPhone_number:(NSString*)phone_number phone_code_hash:(NSString*)phone_code_hash phone_code:(NSString*)phone_code first_name:(NSString*)first_name last_name:(NSString*)last_name;
@end

@interface TLAPI_auth_signIn : TLApiObject
@property (nonatomic, strong) NSString* phone_number;
@property (nonatomic, strong) NSString* phone_code_hash;
@property (nonatomic, strong) NSString* phone_code;

+(TLAPI_auth_signIn*)createWithPhone_number:(NSString*)phone_number phone_code_hash:(NSString*)phone_code_hash phone_code:(NSString*)phone_code;
@end

@interface TLAPI_auth_logOut : TLApiObject


+(TLAPI_auth_logOut*)create;
@end

@interface TLAPI_auth_resetAuthorizations : TLApiObject


+(TLAPI_auth_resetAuthorizations*)create;
@end

@interface TLAPI_auth_sendInvites : TLApiObject
@property (nonatomic, strong) NSMutableArray* phone_numbers;
@property (nonatomic, strong) NSString* message;

+(TLAPI_auth_sendInvites*)createWithPhone_numbers:(NSMutableArray*)phone_numbers message:(NSString*)message;
@end

@interface TLAPI_auth_exportAuthorization : TLApiObject
@property int dc_id;

+(TLAPI_auth_exportAuthorization*)createWithDc_id:(int)dc_id;
@end

@interface TLAPI_auth_importAuthorization : TLApiObject
@property int n_id;
@property (nonatomic, strong) NSData* bytes;

+(TLAPI_auth_importAuthorization*)createWithN_id:(int)n_id bytes:(NSData*)bytes;
@end

@interface TLAPI_auth_bindTempAuthKey : TLApiObject
@property long perm_auth_key_id;
@property long nonce;
@property int expires_at;
@property (nonatomic, strong) NSData* encrypted_message;

+(TLAPI_auth_bindTempAuthKey*)createWithPerm_auth_key_id:(long)perm_auth_key_id nonce:(long)nonce expires_at:(int)expires_at encrypted_message:(NSData*)encrypted_message;
@end

@interface TLAPI_account_registerDevice : TLApiObject
@property int token_type;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) NSString* device_model;
@property (nonatomic, strong) NSString* system_version;
@property (nonatomic, strong) NSString* app_version;
@property Boolean app_sandbox;
@property (nonatomic, strong) NSString* lang_code;

+(TLAPI_account_registerDevice*)createWithToken_type:(int)token_type token:(NSString*)token device_model:(NSString*)device_model system_version:(NSString*)system_version app_version:(NSString*)app_version app_sandbox:(Boolean)app_sandbox lang_code:(NSString*)lang_code;
@end

@interface TLAPI_account_unregisterDevice : TLApiObject
@property int token_type;
@property (nonatomic, strong) NSString* token;

+(TLAPI_account_unregisterDevice*)createWithToken_type:(int)token_type token:(NSString*)token;
@end

@interface TLAPI_account_updateNotifySettings : TLApiObject
@property (nonatomic, strong) TLInputNotifyPeer* peer;
@property (nonatomic, strong) TLInputPeerNotifySettings* settings;

+(TLAPI_account_updateNotifySettings*)createWithPeer:(TLInputNotifyPeer*)peer settings:(TLInputPeerNotifySettings*)settings;
@end

@interface TLAPI_account_getNotifySettings : TLApiObject
@property (nonatomic, strong) TLInputNotifyPeer* peer;

+(TLAPI_account_getNotifySettings*)createWithPeer:(TLInputNotifyPeer*)peer;
@end

@interface TLAPI_account_resetNotifySettings : TLApiObject


+(TLAPI_account_resetNotifySettings*)create;
@end

@interface TLAPI_account_updateProfile : TLApiObject
@property (nonatomic, strong) NSString* first_name;
@property (nonatomic, strong) NSString* last_name;

+(TLAPI_account_updateProfile*)createWithFirst_name:(NSString*)first_name last_name:(NSString*)last_name;
@end

@interface TLAPI_account_updateStatus : TLApiObject
@property Boolean offline;

+(TLAPI_account_updateStatus*)createWithOffline:(Boolean)offline;
@end

@interface TLAPI_account_getWallPapers : TLApiObject


+(TLAPI_account_getWallPapers*)create;
@end

@interface TLAPI_users_getUsers : TLApiObject
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_users_getUsers*)createWithN_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_users_getFullUser : TLApiObject
@property (nonatomic, strong) TLInputUser* n_id;

+(TLAPI_users_getFullUser*)createWithN_id:(TLInputUser*)n_id;
@end

@interface TLAPI_contacts_getStatuses : TLApiObject


+(TLAPI_contacts_getStatuses*)create;
@end

@interface TLAPI_contacts_getContacts : TLApiObject
@property (nonatomic, strong) NSString* n_hash;

+(TLAPI_contacts_getContacts*)createWithN_hash:(NSString*)n_hash;
@end

@interface TLAPI_contacts_importContacts : TLApiObject
@property (nonatomic, strong) NSMutableArray* contacts;
@property Boolean replace;

+(TLAPI_contacts_importContacts*)createWithContacts:(NSMutableArray*)contacts replace:(Boolean)replace;
@end

@interface TLAPI_contacts_getSuggested : TLApiObject
@property int limit;

+(TLAPI_contacts_getSuggested*)createWithLimit:(int)limit;
@end

@interface TLAPI_contacts_deleteContact : TLApiObject
@property (nonatomic, strong) TLInputUser* n_id;

+(TLAPI_contacts_deleteContact*)createWithN_id:(TLInputUser*)n_id;
@end

@interface TLAPI_contacts_deleteContacts : TLApiObject
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_contacts_deleteContacts*)createWithN_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_contacts_block : TLApiObject
@property (nonatomic, strong) TLInputUser* n_id;

+(TLAPI_contacts_block*)createWithN_id:(TLInputUser*)n_id;
@end

@interface TLAPI_contacts_unblock : TLApiObject
@property (nonatomic, strong) TLInputUser* n_id;

+(TLAPI_contacts_unblock*)createWithN_id:(TLInputUser*)n_id;
@end

@interface TLAPI_contacts_getBlocked : TLApiObject
@property int offset;
@property int limit;

+(TLAPI_contacts_getBlocked*)createWithOffset:(int)offset limit:(int)limit;
@end

@interface TLAPI_contacts_exportCard : TLApiObject


+(TLAPI_contacts_exportCard*)create;
@end

@interface TLAPI_contacts_importCard : TLApiObject
@property (nonatomic, strong) NSMutableArray* export_card;

+(TLAPI_contacts_importCard*)createWithExport_card:(NSMutableArray*)export_card;
@end

@interface TLAPI_messages_getMessages : TLApiObject
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_messages_getMessages*)createWithN_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_messages_getDialogs : TLApiObject
@property int offset;
@property int max_id;
@property int limit;

+(TLAPI_messages_getDialogs*)createWithOffset:(int)offset max_id:(int)max_id limit:(int)limit;
@end

@interface TLAPI_messages_getHistory : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;
@property int offset;
@property int max_id;
@property int limit;

+(TLAPI_messages_getHistory*)createWithPeer:(TLInputPeer*)peer offset:(int)offset max_id:(int)max_id limit:(int)limit;
@end

@interface TLAPI_messages_search : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;
@property (nonatomic, strong) NSString* q;
@property (nonatomic, strong) TLMessagesFilter* filter;
@property int min_date;
@property int max_date;
@property int offset;
@property int max_id;
@property int limit;

+(TLAPI_messages_search*)createWithPeer:(TLInputPeer*)peer q:(NSString*)q filter:(TLMessagesFilter*)filter min_date:(int)min_date max_date:(int)max_date offset:(int)offset max_id:(int)max_id limit:(int)limit;
@end

@interface TLAPI_messages_readHistory : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;
@property int max_id;
@property int offset;

+(TLAPI_messages_readHistory*)createWithPeer:(TLInputPeer*)peer max_id:(int)max_id offset:(int)offset;
@end

@interface TLAPI_messages_deleteHistory : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;
@property int offset;

+(TLAPI_messages_deleteHistory*)createWithPeer:(TLInputPeer*)peer offset:(int)offset;
@end

@interface TLAPI_messages_deleteMessages : TLApiObject
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_messages_deleteMessages*)createWithN_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_messages_receivedMessages : TLApiObject
@property int max_id;

+(TLAPI_messages_receivedMessages*)createWithMax_id:(int)max_id;
@end

@interface TLAPI_messages_setTyping : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;
@property (nonatomic, strong) TLSendMessageAction* action;

+(TLAPI_messages_setTyping*)createWithPeer:(TLInputPeer*)peer action:(TLSendMessageAction*)action;
@end

@interface TLAPI_messages_sendMessage : TLApiObject
@property int flags;
@property (nonatomic, strong) TLInputPeer* peer;
@property int reply_to_msg_id;
@property (nonatomic, strong) NSString* message;
@property long random_id;

+(TLAPI_messages_sendMessage*)createWithFlags:(int)flags peer:(TLInputPeer*)peer reply_to_msg_id:(int)reply_to_msg_id message:(NSString*)message random_id:(long)random_id;
@end

@interface TLAPI_messages_sendMedia : TLApiObject
@property int flags;
@property (nonatomic, strong) TLInputPeer* peer;
@property int reply_to_msg_id;
@property (nonatomic, strong) TLInputMedia* media;
@property long random_id;

+(TLAPI_messages_sendMedia*)createWithFlags:(int)flags peer:(TLInputPeer*)peer reply_to_msg_id:(int)reply_to_msg_id media:(TLInputMedia*)media random_id:(long)random_id;
@end

@interface TLAPI_messages_forwardMessages : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;
@property (nonatomic, strong) NSMutableArray* n_id;
@property (nonatomic, strong) NSMutableArray* random_id;

+(TLAPI_messages_forwardMessages*)createWithPeer:(TLInputPeer*)peer n_id:(NSMutableArray*)n_id random_id:(NSMutableArray*)random_id;
@end

@interface TLAPI_messages_getChats : TLApiObject
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_messages_getChats*)createWithN_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_messages_getFullChat : TLApiObject
@property int chat_id;

+(TLAPI_messages_getFullChat*)createWithChat_id:(int)chat_id;
@end

@interface TLAPI_messages_editChatTitle : TLApiObject
@property int chat_id;
@property (nonatomic, strong) NSString* title;

+(TLAPI_messages_editChatTitle*)createWithChat_id:(int)chat_id title:(NSString*)title;
@end

@interface TLAPI_messages_editChatPhoto : TLApiObject
@property int chat_id;
@property (nonatomic, strong) TLInputChatPhoto* photo;

+(TLAPI_messages_editChatPhoto*)createWithChat_id:(int)chat_id photo:(TLInputChatPhoto*)photo;
@end

@interface TLAPI_messages_addChatUser : TLApiObject
@property int chat_id;
@property (nonatomic, strong) TLInputUser* user_id;
@property int fwd_limit;

+(TLAPI_messages_addChatUser*)createWithChat_id:(int)chat_id user_id:(TLInputUser*)user_id fwd_limit:(int)fwd_limit;
@end

@interface TLAPI_messages_deleteChatUser : TLApiObject
@property int chat_id;
@property (nonatomic, strong) TLInputUser* user_id;

+(TLAPI_messages_deleteChatUser*)createWithChat_id:(int)chat_id user_id:(TLInputUser*)user_id;
@end

@interface TLAPI_messages_createChat : TLApiObject
@property (nonatomic, strong) NSMutableArray* users;
@property (nonatomic, strong) NSString* title;

+(TLAPI_messages_createChat*)createWithUsers:(NSMutableArray*)users title:(NSString*)title;
@end

@interface TLAPI_updates_getState : TLApiObject


+(TLAPI_updates_getState*)create;
@end

@interface TLAPI_updates_getDifference : TLApiObject
@property int pts;
@property int date;
@property int qts;

+(TLAPI_updates_getDifference*)createWithPts:(int)pts date:(int)date qts:(int)qts;
@end

@interface TLAPI_photos_updateProfilePhoto : TLApiObject
@property (nonatomic, strong) TLInputPhoto* n_id;
@property (nonatomic, strong) TLInputPhotoCrop* crop;

+(TLAPI_photos_updateProfilePhoto*)createWithN_id:(TLInputPhoto*)n_id crop:(TLInputPhotoCrop*)crop;
@end

@interface TLAPI_photos_uploadProfilePhoto : TLApiObject
@property (nonatomic, strong) TLInputFile* file;
@property (nonatomic, strong) NSString* caption;
@property (nonatomic, strong) TLInputGeoPoint* geo_point;
@property (nonatomic, strong) TLInputPhotoCrop* crop;

+(TLAPI_photos_uploadProfilePhoto*)createWithFile:(TLInputFile*)file caption:(NSString*)caption geo_point:(TLInputGeoPoint*)geo_point crop:(TLInputPhotoCrop*)crop;
@end

@interface TLAPI_photos_deletePhotos : TLApiObject
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_photos_deletePhotos*)createWithN_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_upload_saveFilePart : TLApiObject
@property long file_id;
@property int file_part;
@property (nonatomic, strong) NSData* bytes;

+(TLAPI_upload_saveFilePart*)createWithFile_id:(long)file_id file_part:(int)file_part bytes:(NSData*)bytes;
@end

@interface TLAPI_upload_getFile : TLApiObject
@property (nonatomic, strong) TLInputFileLocation* location;
@property int offset;
@property int limit;

+(TLAPI_upload_getFile*)createWithLocation:(TLInputFileLocation*)location offset:(int)offset limit:(int)limit;
@end

@interface TLAPI_help_getConfig : TLApiObject


+(TLAPI_help_getConfig*)create;
@end

@interface TLAPI_help_getNearestDc : TLApiObject


+(TLAPI_help_getNearestDc*)create;
@end

@interface TLAPI_help_getAppUpdate : TLApiObject
@property (nonatomic, strong) NSString* device_model;
@property (nonatomic, strong) NSString* system_version;
@property (nonatomic, strong) NSString* app_version;
@property (nonatomic, strong) NSString* lang_code;

+(TLAPI_help_getAppUpdate*)createWithDevice_model:(NSString*)device_model system_version:(NSString*)system_version app_version:(NSString*)app_version lang_code:(NSString*)lang_code;
@end

@interface TLAPI_help_saveAppLog : TLApiObject
@property (nonatomic, strong) NSMutableArray* events;

+(TLAPI_help_saveAppLog*)createWithEvents:(NSMutableArray*)events;
@end

@interface TLAPI_help_getInviteText : TLApiObject
@property (nonatomic, strong) NSString* lang_code;

+(TLAPI_help_getInviteText*)createWithLang_code:(NSString*)lang_code;
@end

@interface TLAPI_photos_getUserPhotos : TLApiObject
@property (nonatomic, strong) TLInputUser* user_id;
@property int offset;
@property int max_id;
@property int limit;

+(TLAPI_photos_getUserPhotos*)createWithUser_id:(TLInputUser*)user_id offset:(int)offset max_id:(int)max_id limit:(int)limit;
@end

@interface TLAPI_messages_forwardMessage : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;
@property int n_id;
@property long random_id;

+(TLAPI_messages_forwardMessage*)createWithPeer:(TLInputPeer*)peer n_id:(int)n_id random_id:(long)random_id;
@end

@interface TLAPI_messages_sendBroadcast : TLApiObject
@property (nonatomic, strong) NSMutableArray* contacts;
@property (nonatomic, strong) NSMutableArray* random_id;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) TLInputMedia* media;

+(TLAPI_messages_sendBroadcast*)createWithContacts:(NSMutableArray*)contacts random_id:(NSMutableArray*)random_id message:(NSString*)message media:(TLInputMedia*)media;
@end

@interface TLAPI_geochats_getLocated : TLApiObject
@property (nonatomic, strong) TLInputGeoPoint* geo_point;
@property int radius;
@property int limit;

+(TLAPI_geochats_getLocated*)createWithGeo_point:(TLInputGeoPoint*)geo_point radius:(int)radius limit:(int)limit;
@end

@interface TLAPI_geochats_getRecents : TLApiObject
@property int offset;
@property int limit;

+(TLAPI_geochats_getRecents*)createWithOffset:(int)offset limit:(int)limit;
@end

@interface TLAPI_geochats_checkin : TLApiObject
@property (nonatomic, strong) TLInputGeoChat* peer;

+(TLAPI_geochats_checkin*)createWithPeer:(TLInputGeoChat*)peer;
@end

@interface TLAPI_geochats_getFullChat : TLApiObject
@property (nonatomic, strong) TLInputGeoChat* peer;

+(TLAPI_geochats_getFullChat*)createWithPeer:(TLInputGeoChat*)peer;
@end

@interface TLAPI_geochats_editChatTitle : TLApiObject
@property (nonatomic, strong) TLInputGeoChat* peer;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* address;

+(TLAPI_geochats_editChatTitle*)createWithPeer:(TLInputGeoChat*)peer title:(NSString*)title address:(NSString*)address;
@end

@interface TLAPI_geochats_editChatPhoto : TLApiObject
@property (nonatomic, strong) TLInputGeoChat* peer;
@property (nonatomic, strong) TLInputChatPhoto* photo;

+(TLAPI_geochats_editChatPhoto*)createWithPeer:(TLInputGeoChat*)peer photo:(TLInputChatPhoto*)photo;
@end

@interface TLAPI_geochats_search : TLApiObject
@property (nonatomic, strong) TLInputGeoChat* peer;
@property (nonatomic, strong) NSString* q;
@property (nonatomic, strong) TLMessagesFilter* filter;
@property int min_date;
@property int max_date;
@property int offset;
@property int max_id;
@property int limit;

+(TLAPI_geochats_search*)createWithPeer:(TLInputGeoChat*)peer q:(NSString*)q filter:(TLMessagesFilter*)filter min_date:(int)min_date max_date:(int)max_date offset:(int)offset max_id:(int)max_id limit:(int)limit;
@end

@interface TLAPI_geochats_getHistory : TLApiObject
@property (nonatomic, strong) TLInputGeoChat* peer;
@property int offset;
@property int max_id;
@property int limit;

+(TLAPI_geochats_getHistory*)createWithPeer:(TLInputGeoChat*)peer offset:(int)offset max_id:(int)max_id limit:(int)limit;
@end

@interface TLAPI_geochats_setTyping : TLApiObject
@property (nonatomic, strong) TLInputGeoChat* peer;
@property Boolean typing;

+(TLAPI_geochats_setTyping*)createWithPeer:(TLInputGeoChat*)peer typing:(Boolean)typing;
@end

@interface TLAPI_geochats_sendMessage : TLApiObject
@property (nonatomic, strong) TLInputGeoChat* peer;
@property (nonatomic, strong) NSString* message;
@property long random_id;

+(TLAPI_geochats_sendMessage*)createWithPeer:(TLInputGeoChat*)peer message:(NSString*)message random_id:(long)random_id;
@end

@interface TLAPI_geochats_sendMedia : TLApiObject
@property (nonatomic, strong) TLInputGeoChat* peer;
@property (nonatomic, strong) TLInputMedia* media;
@property long random_id;

+(TLAPI_geochats_sendMedia*)createWithPeer:(TLInputGeoChat*)peer media:(TLInputMedia*)media random_id:(long)random_id;
@end

@interface TLAPI_geochats_createGeoChat : TLApiObject
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) TLInputGeoPoint* geo_point;
@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSString* venue;

+(TLAPI_geochats_createGeoChat*)createWithTitle:(NSString*)title geo_point:(TLInputGeoPoint*)geo_point address:(NSString*)address venue:(NSString*)venue;
@end

@interface TLAPI_messages_getDhConfig : TLApiObject
@property int version;
@property int random_length;

+(TLAPI_messages_getDhConfig*)createWithVersion:(int)version random_length:(int)random_length;
@end

@interface TLAPI_messages_requestEncryption : TLApiObject
@property (nonatomic, strong) TLInputUser* user_id;
@property int random_id;
@property (nonatomic, strong) NSData* g_a;

+(TLAPI_messages_requestEncryption*)createWithUser_id:(TLInputUser*)user_id random_id:(int)random_id g_a:(NSData*)g_a;
@end

@interface TLAPI_messages_acceptEncryption : TLApiObject
@property (nonatomic, strong) TLInputEncryptedChat* peer;
@property (nonatomic, strong) NSData* g_b;
@property long key_fingerprint;

+(TLAPI_messages_acceptEncryption*)createWithPeer:(TLInputEncryptedChat*)peer g_b:(NSData*)g_b key_fingerprint:(long)key_fingerprint;
@end

@interface TLAPI_messages_discardEncryption : TLApiObject
@property int chat_id;

+(TLAPI_messages_discardEncryption*)createWithChat_id:(int)chat_id;
@end

@interface TLAPI_messages_setEncryptedTyping : TLApiObject
@property (nonatomic, strong) TLInputEncryptedChat* peer;
@property Boolean typing;

+(TLAPI_messages_setEncryptedTyping*)createWithPeer:(TLInputEncryptedChat*)peer typing:(Boolean)typing;
@end

@interface TLAPI_messages_readEncryptedHistory : TLApiObject
@property (nonatomic, strong) TLInputEncryptedChat* peer;
@property int max_date;

+(TLAPI_messages_readEncryptedHistory*)createWithPeer:(TLInputEncryptedChat*)peer max_date:(int)max_date;
@end

@interface TLAPI_messages_sendEncrypted : TLApiObject
@property (nonatomic, strong) TLInputEncryptedChat* peer;
@property long random_id;
@property (nonatomic, strong) NSData* data;

+(TLAPI_messages_sendEncrypted*)createWithPeer:(TLInputEncryptedChat*)peer random_id:(long)random_id data:(NSData*)data;
@end

@interface TLAPI_messages_sendEncryptedFile : TLApiObject
@property (nonatomic, strong) TLInputEncryptedChat* peer;
@property long random_id;
@property (nonatomic, strong) NSData* data;
@property (nonatomic, strong) TLInputEncryptedFile* file;

+(TLAPI_messages_sendEncryptedFile*)createWithPeer:(TLInputEncryptedChat*)peer random_id:(long)random_id data:(NSData*)data file:(TLInputEncryptedFile*)file;
@end

@interface TLAPI_messages_sendEncryptedService : TLApiObject
@property (nonatomic, strong) TLInputEncryptedChat* peer;
@property long random_id;
@property (nonatomic, strong) NSData* data;

+(TLAPI_messages_sendEncryptedService*)createWithPeer:(TLInputEncryptedChat*)peer random_id:(long)random_id data:(NSData*)data;
@end

@interface TLAPI_messages_receivedQueue : TLApiObject
@property int max_qts;

+(TLAPI_messages_receivedQueue*)createWithMax_qts:(int)max_qts;
@end

@interface TLAPI_upload_saveBigFilePart : TLApiObject
@property long file_id;
@property int file_part;
@property int file_total_parts;
@property (nonatomic, strong) NSData* bytes;

+(TLAPI_upload_saveBigFilePart*)createWithFile_id:(long)file_id file_part:(int)file_part file_total_parts:(int)file_total_parts bytes:(NSData*)bytes;
@end

@interface TLAPI_help_getSupport : TLApiObject


+(TLAPI_help_getSupport*)create;
@end

@interface TLAPI_auth_sendSms : TLApiObject
@property (nonatomic, strong) NSString* phone_number;
@property (nonatomic, strong) NSString* phone_code_hash;

+(TLAPI_auth_sendSms*)createWithPhone_number:(NSString*)phone_number phone_code_hash:(NSString*)phone_code_hash;
@end

@interface TLAPI_messages_readMessageContents : TLApiObject
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_messages_readMessageContents*)createWithN_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_account_checkUsername : TLApiObject
@property (nonatomic, strong) NSString* username;

+(TLAPI_account_checkUsername*)createWithUsername:(NSString*)username;
@end

@interface TLAPI_account_updateUsername : TLApiObject
@property (nonatomic, strong) NSString* username;

+(TLAPI_account_updateUsername*)createWithUsername:(NSString*)username;
@end

@interface TLAPI_contacts_search : TLApiObject
@property (nonatomic, strong) NSString* q;
@property int limit;

+(TLAPI_contacts_search*)createWithQ:(NSString*)q limit:(int)limit;
@end

@interface TLAPI_account_getPrivacy : TLApiObject
@property (nonatomic, strong) TLInputPrivacyKey* n_key;

+(TLAPI_account_getPrivacy*)createWithN_key:(TLInputPrivacyKey*)n_key;
@end

@interface TLAPI_account_setPrivacy : TLApiObject
@property (nonatomic, strong) TLInputPrivacyKey* n_key;
@property (nonatomic, strong) NSMutableArray* rules;

+(TLAPI_account_setPrivacy*)createWithN_key:(TLInputPrivacyKey*)n_key rules:(NSMutableArray*)rules;
@end

@interface TLAPI_account_deleteAccount : TLApiObject
@property (nonatomic, strong) NSString* reason;

+(TLAPI_account_deleteAccount*)createWithReason:(NSString*)reason;
@end

@interface TLAPI_account_getAccountTTL : TLApiObject


+(TLAPI_account_getAccountTTL*)create;
@end

@interface TLAPI_account_setAccountTTL : TLApiObject
@property (nonatomic, strong) TLAccountDaysTTL* ttl;

+(TLAPI_account_setAccountTTL*)createWithTtl:(TLAccountDaysTTL*)ttl;
@end

@interface TLAPI_contacts_resolveUsername : TLApiObject
@property (nonatomic, strong) NSString* username;

+(TLAPI_contacts_resolveUsername*)createWithUsername:(NSString*)username;
@end

@interface TLAPI_account_sendChangePhoneCode : TLApiObject
@property (nonatomic, strong) NSString* phone_number;

+(TLAPI_account_sendChangePhoneCode*)createWithPhone_number:(NSString*)phone_number;
@end

@interface TLAPI_account_changePhone : TLApiObject
@property (nonatomic, strong) NSString* phone_number;
@property (nonatomic, strong) NSString* phone_code_hash;
@property (nonatomic, strong) NSString* phone_code;

+(TLAPI_account_changePhone*)createWithPhone_number:(NSString*)phone_number phone_code_hash:(NSString*)phone_code_hash phone_code:(NSString*)phone_code;
@end

@interface TLAPI_messages_getStickers : TLApiObject
@property (nonatomic, strong) NSString* emoticon;
@property (nonatomic, strong) NSString* n_hash;

+(TLAPI_messages_getStickers*)createWithEmoticon:(NSString*)emoticon n_hash:(NSString*)n_hash;
@end

@interface TLAPI_messages_getAllStickers : TLApiObject
@property (nonatomic, strong) NSString* n_hash;

+(TLAPI_messages_getAllStickers*)createWithN_hash:(NSString*)n_hash;
@end

@interface TLAPI_account_updateDeviceLocked : TLApiObject
@property int period;

+(TLAPI_account_updateDeviceLocked*)createWithPeriod:(int)period;
@end

@interface TLAPI_messages_getWebPagePreview : TLApiObject
@property (nonatomic, strong) NSString* message;

+(TLAPI_messages_getWebPagePreview*)createWithMessage:(NSString*)message;
@end

@interface TLAPI_account_getAuthorizations : TLApiObject


+(TLAPI_account_getAuthorizations*)create;
@end

@interface TLAPI_account_resetAuthorization : TLApiObject
@property long n_hash;

+(TLAPI_account_resetAuthorization*)createWithN_hash:(long)n_hash;
@end

@interface TLAPI_account_getPassword : TLApiObject


+(TLAPI_account_getPassword*)create;
@end

@interface TLAPI_account_getPasswordSettings : TLApiObject
@property (nonatomic, strong) NSData* current_password_hash;

+(TLAPI_account_getPasswordSettings*)createWithCurrent_password_hash:(NSData*)current_password_hash;
@end

@interface TLAPI_account_updatePasswordSettings : TLApiObject
@property (nonatomic, strong) NSData* current_password_hash;
@property (nonatomic, strong) TLaccount_PasswordInputSettings* n_settings;

+(TLAPI_account_updatePasswordSettings*)createWithCurrent_password_hash:(NSData*)current_password_hash n_settings:(TLaccount_PasswordInputSettings*)n_settings;
@end

@interface TLAPI_auth_checkPassword : TLApiObject
@property (nonatomic, strong) NSData* password_hash;

+(TLAPI_auth_checkPassword*)createWithPassword_hash:(NSData*)password_hash;
@end

@interface TLAPI_auth_requestPasswordRecovery : TLApiObject


+(TLAPI_auth_requestPasswordRecovery*)create;
@end

@interface TLAPI_auth_recoverPassword : TLApiObject
@property (nonatomic, strong) NSString* code;

+(TLAPI_auth_recoverPassword*)createWithCode:(NSString*)code;
@end

@interface TLAPI_messages_exportChatInvite : TLApiObject
@property int chat_id;

+(TLAPI_messages_exportChatInvite*)createWithChat_id:(int)chat_id;
@end

@interface TLAPI_messages_checkChatInvite : TLApiObject
@property (nonatomic, strong) NSString* n_hash;

+(TLAPI_messages_checkChatInvite*)createWithN_hash:(NSString*)n_hash;
@end

@interface TLAPI_messages_importChatInvite : TLApiObject
@property (nonatomic, strong) NSString* n_hash;

+(TLAPI_messages_importChatInvite*)createWithN_hash:(NSString*)n_hash;
@end

