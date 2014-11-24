//
//  TLAPIAdd.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLApiObject.h"

@class TLMessageMedia;
@class TLUserStatus;
@class TGPrivacyKey;
@class TGPrivacyRule;
@class TLInputPrivacyRule;
@class TLInputPrivacyKey;

@interface TL_initConnection : TLObject
@property int api_id;
@property (nonatomic, strong) NSString *device_model;
@property (nonatomic, strong) NSString *system_version;
@property (nonatomic, strong) NSString *app_version;
@property (nonatomic, strong) NSString *lang_code;
@property (nonatomic, strong) id query;
@end


//
//
////auth.sendSms phone_number:string phone_code_hash:string = Bool;
//@interface TLAPI_auth_sendSms : TLApiObject
//
//@property (nonatomic,strong) NSString *phone_number;
//@property (nonatomic,strong) NSString *phone_code_hash;
//
//+ (TLAPI_auth_sendSms *)createWithPhoneNumber:(NSString *)phone_number phone_code_hash:(NSString *)phone_code_hash;
//
//@end
//
//
//
//// constructors
//
//@interface TL_invokeAfter : TLObject
//@property long msg_id;
//@property (nonatomic, strong) id query;
//@end
//
//
////auth.sentAppCode phone_registered:Bool phone_code_hash:string send_call_timeout:int is_password:Bool = auth.SentCode;
//@interface TL_sentAppCode : TLObject
//@property (nonatomic,assign) BOOL phone_registered;
//@property (nonatomic,strong) NSString *phone_code_hash;
//@property (nonatomic,assign) int send_call_timeout;
//@property (nonatomic,assign) BOOL is_password;
//@end
//
//
//@interface TL_SendMessageAction : TLObject
//
//@end
//
//
//@interface TL_sendMessageTypingAction : TL_SendMessageAction
//+ (TL_sendMessageTypingAction *)create;
//@end
//@interface TL_sendMessageCancelAction : TL_SendMessageAction
//+ (TL_sendMessageCancelAction *)create;
//@end
//@interface TL_sendMessageRecordVideoAction : TL_SendMessageAction
//+ (TL_sendMessageRecordVideoAction *)create;
//@end
//@interface TL_sendMessageUploadVideoAction : TL_SendMessageAction
//+ (TL_sendMessageUploadVideoAction *)create;
//@end
//@interface TL_sendMessageRecordAudioAction : TL_SendMessageAction
//+ (TL_sendMessageRecordAudioAction *)create;
//@end
//@interface TL_sendMessageUploadAudioAction : TL_SendMessageAction
//+ (TL_sendMessageUploadAudioAction *)create;
//@end
//@interface TL_sendMessageUploadPhotoAction : TL_SendMessageAction
//+ (TL_sendMessageUploadPhotoAction *)create;
//@end
//@interface TL_sendMessageUploadDocumentAction : TL_SendMessageAction
//+ (TL_sendMessageUploadDocumentAction *)create;
//@end
//@interface TL_sendMessageGeoLocationAction : TL_SendMessageAction
//+ (TL_sendMessageGeoLocationAction *)create;
//@end
//@interface TL_sendMessageChooseContactAction : TL_SendMessageAction
//+ (TL_sendMessageChooseContactAction *)create;
//@end
//
//
////updateServiceNotification type:string message:string media:MessageMedia popup:Bool = Update;
//@interface TL_updateServiceNotification : TLUpdate
//@property (nonatomic,strong) NSString *type;
//@property (nonatomic,strong) NSString *message;
//@property (nonatomic,strong) TLMessageMedia *media;
//@property (nonatomic,assign) BOOL popup;
//
//+ (TL_updateServiceNotification *)createType:(NSString *)type message:(NSString *)message media:(TLMessageMedia *)media popup:(BOOL)popup;
//
//
//@end
//
//
//
//
//
//
////-----functions
//
//
//@interface TLAPI_account_updateUsername : TLApiObject
//@property (nonatomic,strong) NSString *username;
//+ (TLAPI_account_updateUsername *)createWithUsername:(NSString *)username;
//@end
//
//
//@interface TLAPI_account_checkUsername : TLApiObject
//@property (nonatomic,strong) NSString *username;
//+ (TLAPI_account_checkUsername *)createWithUsername:(NSString *)username;
//@end
//
//
//@interface TLAPI_contactsSearch : TLApiObject
//@property (nonatomic,strong) NSString *query;
//@property (nonatomic,assign) int limit;
//+ (TLAPI_contactsSearch *)createWithQ:(NSString *)query limit:(int)limit;
//@end
//
//
//
//
////contacts.exportCard#84e53737 = Vector<int>;
//@interface TLAPI_contactsExportCard : TLApiObject
//+ (TLAPI_contactsExportCard *)create;
//@end
//
//
////contacts.importCard#4fe196fe export_card:Vector<int> = User;
//@interface TLAPI_contactsImportCard : TLApiObject
//@property (nonatomic,strong) NSArray *exportCard;
//+ (TLAPI_contactsImportCard *)createWithExportCard:(NSArray *)exportCard;
//@end
//
//
//
//
//@interface TL_userStatusRecently : TLUserStatus
//+ (TL_userStatusRecently *)create;
//@end
//@interface TL_userStatusLastWeek : TLUserStatus
//+ (TL_userStatusLastWeek *)create;
//@end
//@interface TL_userStatusLastMonth : TLUserStatus
//+ (TL_userStatusLastMonth *)create;
//@end
//
//
//@interface TL_inputPrivacyKeyStatusTimestamp : TLInputPrivacyKey
//+(TL_inputPrivacyKeyStatusTimestamp *)create;
//@end
//
//@interface TL_privacyKeyStatusTimestamp : TGPrivacyKey
//+(TL_privacyKeyStatusTimestamp *)create;
//@end
//
//@interface TL_updatePrivacy : TLUpdate
//@property (nonatomic,strong) TGPrivacyKey *key;
//@property (nonatomic,strong) NSMutableArray *rules;
//+(TL_updatePrivacy *)createWithKey:(TGPrivacyKey *)key rules:(NSMutableArray *)rules;
//@end
//
//
//
//@interface TL_inputPrivacyValueAllowContacts : TLInputPrivacyRule
//+(TL_inputPrivacyValueAllowContacts *)create;
//@end
//@interface TL_inputPrivacyValueAllowAll : TLInputPrivacyRule
//+(TL_inputPrivacyValueAllowAll *)create;
//@end
//@interface TL_inputPrivacyValueAllowUsers : TLInputPrivacyRule
//+(TL_inputPrivacyValueAllowUsers *)create:(NSMutableArray *)users;
//@end
//@interface TL_inputPrivacyValueDisallowContacts : TLInputPrivacyRule
//+(TL_inputPrivacyValueDisallowContacts *)create;
//@end
//@interface TL_inputPrivacyValueDisallowAll : TLInputPrivacyRule
//+(TL_inputPrivacyValueDisallowAll *)create;
//@end
//@interface TL_inputPrivacyValueDisallowUsers : TLInputPrivacyRule
//+(TL_inputPrivacyValueDisallowUsers *)create:(NSMutableArray *)users;
//@end
//
//
//@interface TL_privacyValueAllowContacts : TGPrivacyRule
//+(TL_privacyValueAllowContacts *)create;
//@end
//@interface TL_privacyValueAllowAll : TGPrivacyRule
//+(TL_privacyValueAllowAll *)create;
//@end
//@interface TL_privacyValueAllowUsers : TGPrivacyRule
//+(TL_privacyValueAllowUsers *)create:(NSMutableArray *)users;
//@end
//@interface TL_privacyValueDisallowContacts : TGPrivacyRule
//+(TL_privacyValueDisallowContacts *)create;
//@end
//@interface TL_privacyValueDisallowAll : TGPrivacyRule
//+(TL_privacyValueDisallowAll *)create;
//@end
//@interface TL_privacyValueDisallowUsers : TGPrivacyRule
//+(TL_privacyValueDisallowUsers *)create:(NSMutableArray *)users;
//@end
//
//
//
//@interface TL_account_privacyRules : TLObject
//@property (nonatomic,strong) NSMutableArray *rules;
//@property (nonatomic,strong) NSMutableArray *users;
//+(TL_account_privacyRules *)createWithRules:(NSMutableArray *)rules users:(NSMutableArray *)users;
//@end
//
//
//
//@interface TLAPI_account_getPrivacy : TLApiObject
//
//@property (nonatomic,strong) TLInputPrivacyKey *key;
//
//+(TLAPI_account_getPrivacy *)createWithKey:(TLInputPrivacyKey *)key;
//
//@end
//
//@interface TLAPI_account_setPrivacy : TLApiObject
//@property (nonatomic,strong) TLInputPrivacyKey *inputPrivacyKey;
//@property (nonatomic,strong) NSMutableArray *rules;//TLInputPrivacyRule
//+(TLAPI_account_setPrivacy *)createWithInputPrivacyKey:(TLInputPrivacyKey *)inputPrivacyKey rules:(NSMutableArray *)rules;

//@end



