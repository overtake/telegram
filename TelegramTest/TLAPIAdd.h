//
//  TLAPIAdd.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLApiObject.h"

@class TGMessageMedia;


@interface TL_initConnection : TLObject
@property int api_id;
@property (nonatomic, strong) NSString *device_model;
@property (nonatomic, strong) NSString *system_version;
@property (nonatomic, strong) NSString *app_version;
@property (nonatomic, strong) NSString *lang_code;
@property (nonatomic, strong) id query;
@end




//auth.sendSms phone_number:string phone_code_hash:string = Bool;
@interface TLAPI_auth_sendSms : TLApiObject

@property (nonatomic,strong) NSString *phone_number;
@property (nonatomic,strong) NSString *phone_code_hash;

+ (TLAPI_auth_sendSms *)createWithPhoneNumber:(NSString *)phone_number phone_code_hash:(NSString *)phone_code_hash;

@end



// constructors

@interface TL_invokeAfter : TLObject
@property long msg_id;
@property (nonatomic, strong) id query;
@end


//auth.sentAppCode phone_registered:Bool phone_code_hash:string send_call_timeout:int is_password:Bool = auth.SentCode;
@interface TL_sentAppCode : TLObject
@property (nonatomic,assign) BOOL phone_registered;
@property (nonatomic,strong) NSString *phone_code_hash;
@property (nonatomic,assign) int send_call_timeout;
@property (nonatomic,assign) BOOL is_password;
@end


@interface TL_SendMessageAction : TLObject

@end


@interface TL_sendMessageTypingAction : TL_SendMessageAction
+ (TL_sendMessageTypingAction *)create;
@end
@interface TL_sendMessageCancelAction : TL_SendMessageAction
+ (TL_sendMessageCancelAction *)create;
@end
@interface TL_sendMessageRecordVideoAction : TL_SendMessageAction
+ (TL_sendMessageRecordVideoAction *)create;
@end
@interface TL_sendMessageUploadVideoAction : TL_SendMessageAction
+ (TL_sendMessageUploadVideoAction *)create;
@end
@interface TL_sendMessageRecordAudioAction : TL_SendMessageAction
+ (TL_sendMessageRecordAudioAction *)create;
@end
@interface TL_sendMessageUploadAudioAction : TL_SendMessageAction
+ (TL_sendMessageUploadAudioAction *)create;
@end
@interface TL_sendMessageUploadPhotoAction : TL_SendMessageAction
+ (TL_sendMessageUploadPhotoAction *)create;
@end
@interface TL_sendMessageUploadDocumentAction : TL_SendMessageAction
+ (TL_sendMessageUploadDocumentAction *)create;
@end
@interface TL_sendMessageGeoLocationAction : TL_SendMessageAction
+ (TL_sendMessageGeoLocationAction *)create;
@end
@interface TL_sendMessageChooseContactAction : TL_SendMessageAction
+ (TL_sendMessageChooseContactAction *)create;
@end


//updateServiceNotification type:string message:string media:MessageMedia popup:Bool = Update;
@interface TL_updateServiceNotification : TGUpdate
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *message;
@property (nonatomic,strong) TGMessageMedia *media;
@property (nonatomic,assign) BOOL popup;

+ (TL_updateServiceNotification *)createType:(NSString *)type message:(NSString *)message media:(TGMessageMedia *)media popup:(BOOL)popup;


@end






//-----functions


@interface TLAPI_account_updateUsername : TLApiObject
@property (nonatomic,strong) NSString *username;
+ (TLAPI_account_updateUsername *)createWithUsername:(NSString *)username;
@end


@interface TLAPI_account_checkUsername : TLApiObject
@property (nonatomic,strong) NSString *username;
+ (TLAPI_account_checkUsername *)createWithUsername:(NSString *)username;
@end


@interface TLAPI_contactsSearch : TLApiObject
@property (nonatomic,strong) NSString *query;
@property (nonatomic,assign) int limit;
+ (TLAPI_contactsSearch *)createWithQ:(NSString *)query limit:(int)limit;
@end




//contacts.exportCard#84e53737 = Vector<int>;
@interface TLAPI_contactsExportCard : TLApiObject
+ (TLAPI_contactsExportCard *)create;
@end


//contacts.importCard#4fe196fe export_card:Vector<int> = User;
@interface TLAPI_contactsImportCard : TLApiObject
@property (nonatomic,strong) NSArray *exportCard;
+ (TLAPI_contactsImportCard *)createWithExportCard:(NSArray *)exportCard;
@end






