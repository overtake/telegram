//
//  TLAPIAdd.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLAPIAdd.h"

@implementation TL_initConnection

- (NSData*)getData {
    SerializedData* stream = [TLClassStore streamWithConstuctor:1769565673];
    
    [stream writeInt:API_ID];
    [stream writeString:self.device_model];
    [stream writeString:self.system_version];
    [stream writeString:self.app_version];
    [stream writeString:self.lang_code];
    
    [stream writeData:[self.query getData]];
    
	return [stream getOutput];
}
@end

//
//@implementation TL_invokeAfter
//
//
//-(void)serialize:(SerializedData *)stream {
//    [stream writeLong:self.msg_id];
//    [stream writeData:[self.query getData:NO]];
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    self.msg_id = [stream readLong];
//    self.query = [TLClassStore TLDeserialize:stream];
//}
//
//@end
//
//
//
////constructors
//
//@implementation TL_sentAppCode
////auth.sentAppCode phone_registered:Bool phone_code_hash:string send_call_timeout:int is_password:Bool = auth.SentCode;
//-(void)serialize:(SerializedData *)stream {
//    [stream writeBool:self.phone_registered];
//    [stream writeString:self.phone_code_hash];
//    [stream writeInt:self.send_call_timeout];
//    [stream writeBool:self.is_password];
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    self.phone_registered = [stream readBool];
//    self.phone_code_hash = [stream readString];
//    self.send_call_timeout = [stream readInt];
//    self.is_password = [stream readBool];
//}
//
//@end
//
//
//
//@implementation TL_SendMessageAction
//
//
//@end
//
//@implementation TL_sendMessageTypingAction
//-(void)serialize:(SerializedData *)stream {}
//-(void)unserialize:(SerializedData *)stream {}
//
//+ (TL_sendMessageTypingAction *)create {
//    TL_sendMessageTypingAction *obj = [[TL_sendMessageTypingAction alloc] init];
//    return obj;
//}
//
//@end
//@implementation TL_sendMessageCancelAction
//-(void)serialize:(SerializedData *)stream {}
//-(void)unserialize:(SerializedData *)stream {}
//
//+ (TL_sendMessageCancelAction *)create {
//    TL_sendMessageCancelAction *obj = [[TL_sendMessageCancelAction alloc] init];
//    return obj;
//}
//@end
//@implementation TL_sendMessageRecordVideoAction
//-(void)serialize:(SerializedData *)stream {}
//-(void)unserialize:(SerializedData *)stream {}
//
//+ (TL_sendMessageRecordVideoAction *)create {
//    TL_sendMessageRecordVideoAction *obj = [[TL_sendMessageRecordVideoAction alloc] init];
//    return obj;
//}
//@end
//@implementation TL_sendMessageUploadVideoAction
//-(void)serialize:(SerializedData *)stream {}
//-(void)unserialize:(SerializedData *)stream {}
//
//+ (TL_sendMessageUploadVideoAction *)create {
//    TL_sendMessageUploadVideoAction *obj = [[TL_sendMessageUploadVideoAction alloc] init];
//    return obj;
//}
//@end
//@implementation TL_sendMessageRecordAudioAction
//-(void)serialize:(SerializedData *)stream {}
//-(void)unserialize:(SerializedData *)stream {}
//
//+ (TL_sendMessageRecordAudioAction *)create {
//    TL_sendMessageRecordAudioAction *obj = [[TL_sendMessageRecordAudioAction alloc] init];
//    return obj;
//}
//@end
//@implementation TL_sendMessageUploadAudioAction
//-(void)serialize:(SerializedData *)stream {}
//-(void)unserialize:(SerializedData *)stream {}
//
//+ (TL_sendMessageUploadAudioAction *)create {
//    TL_sendMessageUploadAudioAction *obj = [[TL_sendMessageUploadAudioAction alloc] init];
//    return obj;
//}
//@end
//@implementation TL_sendMessageUploadPhotoAction
//-(void)serialize:(SerializedData *)stream {}
//-(void)unserialize:(SerializedData *)stream {}
//
//+ (TL_sendMessageUploadPhotoAction *)create {
//    TL_sendMessageUploadPhotoAction *obj = [[TL_sendMessageUploadPhotoAction alloc] init];
//    return obj;
//}
//@end
//@implementation TL_sendMessageUploadDocumentAction
//-(void)serialize:(SerializedData *)stream {}
//-(void)unserialize:(SerializedData *)stream {}
//
//+ (TL_sendMessageUploadDocumentAction *)create {
//    TL_sendMessageUploadDocumentAction *obj = [[TL_sendMessageUploadDocumentAction alloc] init];
//    return obj;
//}
//@end
//@implementation TL_sendMessageGeoLocationAction
//-(void)serialize:(SerializedData *)stream {}
//-(void)unserialize:(SerializedData *)stream {}
//
//+ (TL_sendMessageGeoLocationAction *)create {
//    TL_sendMessageGeoLocationAction *obj = [[TL_sendMessageGeoLocationAction alloc] init];
//    return obj;
//}
//@end
//@implementation TL_sendMessageChooseContactAction
//-(void)serialize:(SerializedData *)stream {}
//-(void)unserialize:(SerializedData *)stream {}
//
//+ (TL_sendMessageChooseContactAction *)create {
//    TL_sendMessageChooseContactAction *obj = [[TL_sendMessageChooseContactAction alloc] init];
//    return obj;
//}
//@end
//
//@implementation TL_updateServiceNotification
//
//+ (TL_updateServiceNotification *)createType:(NSString *)type message:(NSString *)message media:(TLMessageMedia *)media popup:(BOOL)popup {
//    TL_updateServiceNotification *obj = [[TL_updateServiceNotification alloc] init];
//    
//    obj.type = type;
//    obj.message = message;
//    obj.media = media;
//    obj.popup = popup;
//    
//    return obj;
//}
//
//-(void)serialize:(SerializedData *)stream {
//    [stream writeString:self.type];
//    [stream writeString:self.message];
//    [TLClassStore TLSerialize:self.media stream:stream];
//    [stream writeBool:self.popup];
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    self.type = [stream readString];
//    self.message = [stream readString];
//    [TLClassStore TLDeserialize:stream];
//    self.popup = [stream readBool];
//}
//
//@end
//
//
//
//// ---- functions ----
//
//
//
//@implementation TLAPI_account_updateUsername
//
//+ (TLAPI_account_updateUsername *)createWithUsername:(NSString *)username {
//    TLAPI_account_updateUsername *obj = [[TLAPI_account_updateUsername alloc] init];
//    obj.username = username;
//    return obj;
//}
//
//-(NSData *)getData:(BOOL)isFirstRequest {
//    SerializedData* stream = [TLClassStorestreamWithConstuctor:0x3e0bdd7c isFirstRequest:isFirstRequest];
//    [stream writeString:self.username];
//    return [stream getOutput];
//}
//
//@end
//
//
//@implementation TLAPI_account_checkUsername
//
//+ (TLAPI_account_checkUsername *)createWithUsername:(NSString *)username {
//    TLAPI_account_checkUsername *obj = [[TLAPI_account_checkUsername alloc] init];
//    obj.username = username;
//    return obj;
//}
//
//-(NSData *)getData:(BOOL)isFirstRequest {
//    SerializedData* stream = [TLClassStorestreamWithConstuctor:0x2714d86c isFirstRequest:isFirstRequest];
//    [stream writeString:self.username];
//    return [stream getOutput];
//}
//
//@end
//
//
//@implementation TLAPI_contactsSearch
//
//+ (TLAPI_contactsSearch *)createWithQ:(NSString *)query limit:(int)limit {
//    TLAPI_contactsSearch *obj = [[TLAPI_contactsSearch alloc] init];
//    obj.query = query;
//    obj.limit = limit;
//    return obj;
//}
//
//-(NSData *)getData:(BOOL)isFirstRequest {
//    SerializedData* stream = [TLClassStorestreamWithConstuctor:0x11f812d8 isFirstRequest:isFirstRequest];
//    [stream writeString:self.query];
//    [stream writeInt:self.limit];
//    return [stream getOutput];
//}
//
//@end
//
//
//@implementation TLAPI_auth_sendSms
//
//+ (TLAPI_auth_sendSms *)createWithPhoneNumber:(NSString *)phone_number phone_code_hash:(NSString *)phone_code_hash {
//    TLAPI_auth_sendSms *object = [[TLAPI_auth_sendSms alloc] init];
//    object.phone_number = phone_number;
//    object.phone_code_hash = phone_code_hash;
//    return object;
//}
//
//- (NSData *)getData:(BOOL)isFirstRequest {
//    SerializedData* stream = [TLClassStorestreamWithConstuctor:0xda9f3e8 isFirstRequest:isFirstRequest];
//    
//    [stream writeString:self.phone_number];
//    [stream writeString:self.phone_code_hash];
//    
//    return [stream getOutput];
//
//}
//
//@end
//
//
//@implementation TLAPI_contactsExportCard
//
//+ (TLAPI_contactsExportCard *)create {
//    TLAPI_contactsExportCard *object = [[TLAPI_contactsExportCard alloc] init];
//    
//    return object;
//}
//
//-(NSData *)getData:(BOOL)isFirstRequest {
//    return [[TLClassStorestreamWithConstuctor:0x84e53737 isFirstRequest:isFirstRequest] getOutput];
//}
//
//
//@end
//
//
//@implementation TLAPI_contactsImportCard
//+ (TLAPI_contactsImportCard *)createWithExportCard:(NSArray *)exportCard {
//    TLAPI_contactsImportCard *object = [[TLAPI_contactsImportCard alloc] init];
//    object.exportCard = exportCard;
//    
//    return object;
//}
//
//
//-(NSData *)getData:(BOOL)isFirstRequest {
//    SerializedData *stream = [TLClassStorestreamWithConstuctor:0x4fe196fe isFirstRequest:isFirstRequest];
//	[stream writeInt:0x1cb5c415];
//	{
//		NSInteger tl_count = [self.exportCard count];
//		[stream writeInt:(int)tl_count];
//		for(int i = 0; i < (int)tl_count; i++) {
//			NSNumber* obj = [self.exportCard objectAtIndex:i];
//			[stream writeInt:[obj intValue]];
//		}
//	}
//	return [stream getOutput];
//}
//
//
//@end
//
//
//
//@implementation TL_userStatusRecently
//+ (TL_userStatusRecently *)create {
//    return [[TL_userStatusRecently alloc] init];
//}
//
//-(void)serialize:(SerializedData *)stream {
//    
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    
//}
//
//@end
//@implementation TL_userStatusLastWeek
//+ (TL_userStatusLastWeek *)create {
//    return [[TL_userStatusLastWeek alloc] init];
//}
//-(void)serialize:(SerializedData *)stream {
//    
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    
//}
//
//@end
//@implementation TL_userStatusLastMonth
//+ (TL_userStatusLastMonth *)create {
//    return [[TL_userStatusLastMonth alloc] init];
//}
//-(void)serialize:(SerializedData *)stream {
//    
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    
//}
//@end
//
//
//@implementation TL_inputPrivacyKeyStatusTimestamp
//+(TL_inputPrivacyKeyStatusTimestamp *)create {
//    return [[TL_inputPrivacyKeyStatusTimestamp alloc] init];
//}
//-(void)serialize:(SerializedData *)stream {
//    
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    
//}
//@end
//
//@implementation TL_privacyKeyStatusTimestamp
//+(TL_privacyKeyStatusTimestamp *)create {
//    return [[TL_privacyKeyStatusTimestamp alloc] init];
//}
//-(void)serialize:(SerializedData *)stream {
//    
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    
//}
//@end
//
//@implementation TL_updatePrivacy : TLUpdate
//+(TL_updatePrivacy *)createWithKey:(TGPrivacyKey *)key rules:(NSMutableArray *)rules {
//    TL_updatePrivacy *obj = [[TL_updatePrivacy alloc] init];
//    obj.key = key;
//    obj.rules = rules;
//    return obj;
//}
//
//-(void)serialize:(SerializedData *)stream {
//    [TLClassStore TLSerialize:self.key stream:stream];
//    
//    [stream writeInt:0x1cb5c415];
//    {
//        NSInteger tl_count = [self.rules count];
//        [stream writeInt:(int)tl_count];
//        for(int i = 0; i < (int)tl_count; i++) {
//            id obj = [self.rules objectAtIndex:i];
//            [TLClassStore TLSerialize:obj stream:stream];
//        }
//    }
//
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    self.key = [TLClassStore TLDeserialize:stream];
//    
//    [stream readInt];
//    {
//        if(!self.rules)
//            self.rules = [[NSMutableArray alloc] init];
//        int count = [stream readInt];
//        for(int i = 0; i < count; i++) {
//            id obj = [TLClassStore TLDeserialize:stream];
//            [self.rules addObject:obj];
//        }
//    }
//}
//@end
//
//
//
//@implementation TL_inputPrivacyValueAllowContacts : TLInputPrivacyRule
//+(TL_inputPrivacyValueAllowContacts *)create {
//    return [[TL_inputPrivacyValueAllowContacts alloc] init];
//}
//-(void)serialize:(SerializedData *)stream {
//    
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    
//}
//@end
//@implementation TL_inputPrivacyValueAllowAll : TLInputPrivacyRule
//+(TL_inputPrivacyValueAllowAll *)create {
//    return [[TL_inputPrivacyValueAllowAll alloc] init];
//}
//-(void)serialize:(SerializedData *)stream {
//    
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    
//}
//@end
//@implementation TL_inputPrivacyValueAllowUsers : TLInputPrivacyRule
//+(TL_inputPrivacyValueAllowUsers *)create:(NSMutableArray *)users {
//    TL_inputPrivacyValueAllowUsers *obj = [[TL_inputPrivacyValueAllowUsers alloc] init];
//    obj.users = users;
//    return obj;
//}
//-(void)serialize:(SerializedData *)stream {
//    
//    [stream writeInt:0x1cb5c415];
//    {
//        NSInteger tl_count = [self.users count];
//        [stream writeInt:(int)tl_count];
//        for(int i = 0; i < (int)tl_count; i++) {
//            TLInputUser *obj = [self.users objectAtIndex:i];
//            [TLClassStore TLSerialize:obj stream:stream];
//        }
//    }
//    
//    
//    
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    [stream readInt];
//    {
//        if(!self.users)
//            self.users = [[NSMutableArray alloc] init];
//        int count = [stream readInt];
//        for(int i = 0; i < count; i++) {
//            TLInputUser *obj = [TLClassStore TLDeserialize:stream];
//            [self.users addObject:obj];
//        }
//    }
//}
//@end
//@implementation TL_inputPrivacyValueDisallowContacts : TLInputPrivacyRule
//+(TL_inputPrivacyValueDisallowContacts *)create {
//    return [[TL_inputPrivacyValueDisallowContacts alloc] init];
//}
//-(void)serialize:(SerializedData *)stream {
//    
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    
//}
//@end
//@implementation TL_inputPrivacyValueDisallowAll : TLInputPrivacyRule
//+(TL_inputPrivacyValueDisallowAll *)create {
//    return [[TL_inputPrivacyValueDisallowAll alloc] init];
//}
//-(void)serialize:(SerializedData *)stream {
//    
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    
//}
//@end
//@implementation TL_inputPrivacyValueDisallowUsers : TLInputPrivacyRule
//+(TL_inputPrivacyValueDisallowUsers *)create:(NSMutableArray *)users {
//    TL_inputPrivacyValueDisallowUsers *obj = [[TL_inputPrivacyValueDisallowUsers alloc] init];
//    obj.users = users;
//    return obj;
//}
//-(void)serialize:(SerializedData *)stream {
//    
//    [stream writeInt:0x1cb5c415];
//    {
//        NSInteger tl_count = [self.users count];
//        [stream writeInt:(int)tl_count];
//        for(int i = 0; i < (int)tl_count; i++) {
//            TLInputUser *obj = [self.users objectAtIndex:i];
//            [TLClassStore TLSerialize:obj stream:stream];
//        }
//    }
//    
//    
//    
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    [stream readInt];
//    {
//        if(!self.users)
//            self.users = [[NSMutableArray alloc] init];
//        int count = [stream readInt];
//        for(int i = 0; i < count; i++) {
//            TLInputUser *obj = [TLClassStore TLDeserialize:stream];
//            [self.users addObject:obj];
//        }
//    }
//}
//@end
//
//
//@implementation TL_privacyValueAllowContacts : TGPrivacyRule
//+(TL_privacyValueAllowContacts *)create {
//    return [[TL_privacyValueAllowContacts alloc] init];
//}
//-(void)serialize:(SerializedData *)stream {
//    
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    
//}
//@end
//@implementation TL_privacyValueAllowAll : TGPrivacyRule
//+(TL_privacyValueAllowAll *)create {
//return [[TL_privacyValueAllowAll alloc] init];
//}
//-(void)serialize:(SerializedData *)stream {
//    
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    
//}
//@end
//@implementation TL_privacyValueAllowUsers : TGPrivacyRule
//+(TL_privacyValueAllowUsers *)create:(NSMutableArray *)users {
//    TL_privacyValueAllowUsers *obj = [[TL_privacyValueAllowUsers alloc] init];
//    obj.users = users;
//    return obj;
//}
//- (void)serialize:(SerializedData *)stream {
//    //Serialize ShortVector
//    [stream writeInt:0x1cb5c415];
//    {
//        NSInteger tl_count = [self.users count];
//        [stream writeInt:(int)tl_count];
//        for(int i = 0; i < (int)tl_count; i++) {
//            NSNumber* obj = [self.users objectAtIndex:i];
//            [stream writeInt:[obj intValue]];
//        }
//    }
//}
//- (void)unserialize:(SerializedData *)stream {
//    //UNS ShortVector
//    [stream readInt];
//    {
//        if(!self.users)
//            self.users = [[NSMutableArray alloc] init];
//        int tl_count = [stream readInt];
//        for(int i = 0; i < tl_count; i++) {
//            int obj = [stream readInt];
//            [self.users addObject:[[NSNumber alloc] initWithInt:obj]];
//        }
//    }
//}
//@end
//@implementation TL_privacyValueDisallowContacts : TGPrivacyRule
//+(TL_privacyValueDisallowContacts *)create {
//    return [[TL_privacyValueDisallowContacts alloc] init];
//}
//-(void)serialize:(SerializedData *)stream {
//    
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    
//}
//@end
//@implementation TL_privacyValueDisallowAll : TGPrivacyRule
//+(TL_privacyValueDisallowAll *)create {
//    return [[TL_privacyValueDisallowAll alloc] init];
//}
//-(void)serialize:(SerializedData *)stream {
//    
//}
//
//-(void)unserialize:(SerializedData *)stream {
//    
//}
//@end
//@implementation TL_privacyValueDisallowUsers : TGPrivacyRule
//+(TL_privacyValueDisallowUsers *)create:(NSMutableArray *)users {
//    TL_privacyValueDisallowUsers *obj = [[TL_privacyValueDisallowUsers alloc] init];
//    obj.users = users;
//    return obj;
//}
//- (void)serialize:(SerializedData *)stream {
//    
//    [stream writeInt:0x1cb5c415];
//    {
//        NSInteger tl_count = [self.users count];
//        [stream writeInt:(int)tl_count];
//        for(int i = 0; i < (int)tl_count; i++) {
//            id obj = [self.users objectAtIndex:i];
//            [TLClassStore TLSerialize:obj stream:stream];
//        }
//    }
//}
//- (void)unserialize:(SerializedData *)stream {
//   
//    [stream readInt];
//    {
//        if(!self.users)
//            self.users = [[NSMutableArray alloc] init];
//        int tl_count = [stream readInt];
//        for(int i = 0; i < tl_count; i++) {
//            int obj = [stream readInt];
//            [self.users addObject:[[NSNumber alloc] initWithInt:obj]];
//        }
//    }
//}
//@end
//
////account.privacyRules#554abb6f rules:Vector<PrivacyRule> users:Vector<User> = account.PrivacyRules;
//
//@implementation TL_account_privacyRules
//+(TL_account_privacyRules *)createWithRules:(NSMutableArray *)rules users:(NSMutableArray *)users {
//    TL_account_privacyRules *obj = [[TL_account_privacyRules alloc] init];
//    obj.rules = rules;
//    obj.users = users;
//    return obj;
//}
//
//- (void)serialize:(SerializedData *)stream {
//    
//    [stream writeInt:0x1cb5c415];
//    {
//        NSInteger tl_count = [self.rules count];
//        [stream writeInt:(int)tl_count];
//        for(int i = 0; i < (int)tl_count; i++) {
//            id obj = [self.rules objectAtIndex:i];
//            [TLClassStore TLSerialize:obj stream:stream];
//        }
//    }
//    
//    [stream writeInt:0x1cb5c415];
//    {
//        NSInteger tl_count = [self.users count];
//        [stream writeInt:(int)tl_count];
//        for(int i = 0; i < (int)tl_count; i++) {
//            id obj = [self.users objectAtIndex:i];
//            [TLClassStore TLSerialize:obj stream:stream];
//        }
//    }
//}
//- (void)unserialize:(SerializedData *)stream {
//    
//    
//    [stream readInt];
//    {
//        if(!self.rules)
//            self.rules = [[NSMutableArray alloc] init];
//        int count = [stream readInt];
//        for(int i = 0; i < count; i++) {
//            id obj = [TLClassStore TLDeserialize:stream];
//            [self.rules addObject:obj];
//        }
//    }
//    
//    [stream readInt];
//    {
//        if(!self.users)
//            self.users = [[NSMutableArray alloc] init];
//        int count = [stream readInt];
//        for(int i = 0; i < count; i++) {
//            id obj = [TLClassStore TLDeserialize:stream];
//            [self.users addObject:obj];
//        }
//    }
//}
//
//@end
//
//
//
//@implementation TLAPI_account_getPrivacy
//
//
//
//
//+(TLAPI_account_getPrivacy *)createWithKey:(TLInputPrivacyKey *)key {
//    TLAPI_account_getPrivacy *obj = [[TLAPI_account_getPrivacy alloc] init];
//    obj.key = key;
//    return obj;
//}
//
//-(NSData *)getData:(BOOL)isFirstRequest {
//    SerializedData *stream = [TLClassStorestreamWithConstuctor:0xdadbc950 isFirstRequest:isFirstRequest];
//    
//    [TLClassStore TLSerialize:self.key stream:stream];
//    
//    return [stream getOutput];
//}
//
//@end
//
//@implementation TLAPI_account_setPrivacy
//  
//+(TLAPI_account_setPrivacy *)createWithInputPrivacyKey:(TLInputPrivacyKey *)inputPrivacyKey rules:(NSMutableArray *)rules  {
//    TLAPI_account_setPrivacy *obj = [[TLAPI_account_setPrivacy alloc] init];
//    obj.inputPrivacyKey = inputPrivacyKey;
//    obj.rules = rules;
//    
//    return obj;
//}
//
//-(NSData *)getData:(BOOL)isFirstRequest {
//    SerializedData *stream = [TLClassStorestreamWithConstuctor:0xc9f81ce8 isFirstRequest:isFirstRequest];
//    
//    [TLClassStore TLSerialize:self.inputPrivacyKey stream:stream];
//    
//    [stream writeInt:0x1cb5c415];
//    {
//        NSInteger tl_count = [self.rules count];
//        [stream writeInt:(int)tl_count];
//        for(int i = 0; i < (int)tl_count; i++) {
//            id obj = [self.rules objectAtIndex:i];
//            [TLClassStore TLSerialize:obj stream:stream];
//        }
//    }
//    return [stream getOutput];
//}

//@end





