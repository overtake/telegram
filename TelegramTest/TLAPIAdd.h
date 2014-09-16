//
//  TLAPIAdd.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLApiObject.h"
@interface TL_initConnection : TLObject
@property int api_id;
@property (nonatomic, strong) NSString *device_model;
@property (nonatomic, strong) NSString *system_version;
@property (nonatomic, strong) NSString *app_version;
@property (nonatomic, strong) NSString *lang_code;
@property (nonatomic, strong) id query;
@end


@interface TL_invokeAfter : TLObject
@property long msg_id;
@property (nonatomic, strong) id query;
@end


//auth.sendSms phone_number:string phone_code_hash:string = Bool;
@interface TLAPI_auth_sendSms : TLApiObject

@property (nonatomic,strong) NSString *phone_number;
@property (nonatomic,strong) NSString *phone_code_hash;

+ (TLAPI_auth_sendSms *)createWithPhoneNumber:(NSString *)phone_number phone_code_hash:(NSString *)phone_code_hash;

@end

//auth.sentAppCode phone_registered:Bool phone_code_hash:string send_call_timeout:int is_password:Bool = auth.SentCode;
@interface TL_sentAppCode : TLObject
@property (nonatomic,assign) BOOL phone_registered;
@property (nonatomic,strong) NSString *phone_code_hash;
@property (nonatomic,assign) int send_call_timeout;
@property (nonatomic,assign) BOOL is_password;
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






