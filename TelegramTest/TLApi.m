//
//  TLApi.m
//  Telegram
//
//  Auto created by Mikhail Filimonov on 27.11.15..
//  Copyright (c) 2013 Telegram for OS X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLApi.h"

@implementation TLAPI_auth_checkPhone
+(TLAPI_auth_checkPhone*)createWithPhone_number:(NSString*)phone_number {
    TLAPI_auth_checkPhone* obj = [[TLAPI_auth_checkPhone alloc] init];
    obj.phone_number = phone_number;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1877286395];
	[stream writeString:self.phone_number];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_sendCode
+(TLAPI_auth_sendCode*)createWithPhone_number:(NSString*)phone_number sms_type:(int)sms_type api_id:(int)api_id api_hash:(NSString*)api_hash lang_code:(NSString*)lang_code {
    TLAPI_auth_sendCode* obj = [[TLAPI_auth_sendCode alloc] init];
    obj.phone_number = phone_number;
	obj.sms_type = sms_type;
	obj.api_id = api_id;
	obj.api_hash = api_hash;
	obj.lang_code = lang_code;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1988976461];
	[stream writeString:self.phone_number];
	[stream writeInt:self.sms_type];
	[stream writeInt:self.api_id];
	[stream writeString:self.api_hash];
	[stream writeString:self.lang_code];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_sendCall
+(TLAPI_auth_sendCall*)createWithPhone_number:(NSString*)phone_number phone_code_hash:(NSString*)phone_code_hash {
    TLAPI_auth_sendCall* obj = [[TLAPI_auth_sendCall alloc] init];
    obj.phone_number = phone_number;
	obj.phone_code_hash = phone_code_hash;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:63247716];
	[stream writeString:self.phone_number];
	[stream writeString:self.phone_code_hash];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_signUp
+(TLAPI_auth_signUp*)createWithPhone_number:(NSString*)phone_number phone_code_hash:(NSString*)phone_code_hash phone_code:(NSString*)phone_code first_name:(NSString*)first_name last_name:(NSString*)last_name {
    TLAPI_auth_signUp* obj = [[TLAPI_auth_signUp alloc] init];
    obj.phone_number = phone_number;
	obj.phone_code_hash = phone_code_hash;
	obj.phone_code = phone_code;
	obj.first_name = first_name;
	obj.last_name = last_name;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:453408308];
	[stream writeString:self.phone_number];
	[stream writeString:self.phone_code_hash];
	[stream writeString:self.phone_code];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_signIn
+(TLAPI_auth_signIn*)createWithPhone_number:(NSString*)phone_number phone_code_hash:(NSString*)phone_code_hash phone_code:(NSString*)phone_code {
    TLAPI_auth_signIn* obj = [[TLAPI_auth_signIn alloc] init];
    obj.phone_number = phone_number;
	obj.phone_code_hash = phone_code_hash;
	obj.phone_code = phone_code;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1126886015];
	[stream writeString:self.phone_number];
	[stream writeString:self.phone_code_hash];
	[stream writeString:self.phone_code];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_logOut
+(TLAPI_auth_logOut*)create {
    TLAPI_auth_logOut* obj = [[TLAPI_auth_logOut alloc] init];
    
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1461180992];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_resetAuthorizations
+(TLAPI_auth_resetAuthorizations*)create {
    TLAPI_auth_resetAuthorizations* obj = [[TLAPI_auth_resetAuthorizations alloc] init];
    
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1616179942];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_sendInvites
+(TLAPI_auth_sendInvites*)createWithPhone_numbers:(NSMutableArray*)phone_numbers message:(NSString*)message {
    TLAPI_auth_sendInvites* obj = [[TLAPI_auth_sendInvites alloc] init];
    obj.phone_numbers = phone_numbers;
	obj.message = message;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1998331287];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.phone_numbers count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.phone_numbers count] > i) {
                NSString* obj = [self.phone_numbers objectAtIndex:i];
			[stream writeString:obj];
            }  else
                break;
		}
	}
	[stream writeString:self.message];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_exportAuthorization
+(TLAPI_auth_exportAuthorization*)createWithDc_id:(int)dc_id {
    TLAPI_auth_exportAuthorization* obj = [[TLAPI_auth_exportAuthorization alloc] init];
    obj.dc_id = dc_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-440401971];
	[stream writeInt:self.dc_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_importAuthorization
+(TLAPI_auth_importAuthorization*)createWithN_id:(int)n_id bytes:(NSData*)bytes {
    TLAPI_auth_importAuthorization* obj = [[TLAPI_auth_importAuthorization alloc] init];
    obj.n_id = n_id;
	obj.bytes = bytes;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-470837741];
	[stream writeInt:self.n_id];
	[stream writeByteArray:self.bytes];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_bindTempAuthKey
+(TLAPI_auth_bindTempAuthKey*)createWithPerm_auth_key_id:(long)perm_auth_key_id nonce:(long)nonce expires_at:(int)expires_at encrypted_message:(NSData*)encrypted_message {
    TLAPI_auth_bindTempAuthKey* obj = [[TLAPI_auth_bindTempAuthKey alloc] init];
    obj.perm_auth_key_id = perm_auth_key_id;
	obj.nonce = nonce;
	obj.expires_at = expires_at;
	obj.encrypted_message = encrypted_message;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-841733627];
	[stream writeLong:self.perm_auth_key_id];
	[stream writeLong:self.nonce];
	[stream writeInt:self.expires_at];
	[stream writeByteArray:self.encrypted_message];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_registerDevice
+(TLAPI_account_registerDevice*)createWithToken_type:(int)token_type token:(NSString*)token device_model:(NSString*)device_model system_version:(NSString*)system_version app_version:(NSString*)app_version app_sandbox:(Boolean)app_sandbox lang_code:(NSString*)lang_code {
    TLAPI_account_registerDevice* obj = [[TLAPI_account_registerDevice alloc] init];
    obj.token_type = token_type;
	obj.token = token;
	obj.device_model = device_model;
	obj.system_version = system_version;
	obj.app_version = app_version;
	obj.app_sandbox = app_sandbox;
	obj.lang_code = lang_code;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1147957548];
	[stream writeInt:self.token_type];
	[stream writeString:self.token];
	[stream writeString:self.device_model];
	[stream writeString:self.system_version];
	[stream writeString:self.app_version];
	[stream writeBool:self.app_sandbox];
	[stream writeString:self.lang_code];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_unregisterDevice
+(TLAPI_account_unregisterDevice*)createWithToken_type:(int)token_type token:(NSString*)token {
    TLAPI_account_unregisterDevice* obj = [[TLAPI_account_unregisterDevice alloc] init];
    obj.token_type = token_type;
	obj.token = token;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1707432768];
	[stream writeInt:self.token_type];
	[stream writeString:self.token];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_updateNotifySettings
+(TLAPI_account_updateNotifySettings*)createWithPeer:(TLInputNotifyPeer*)peer settings:(TLInputPeerNotifySettings*)settings {
    TLAPI_account_updateNotifySettings* obj = [[TLAPI_account_updateNotifySettings alloc] init];
    obj.peer = peer;
	obj.settings = settings;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-2067899501];
	[ClassStore TLSerialize:self.peer stream:stream];
	[ClassStore TLSerialize:self.settings stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_getNotifySettings
+(TLAPI_account_getNotifySettings*)createWithPeer:(TLInputNotifyPeer*)peer {
    TLAPI_account_getNotifySettings* obj = [[TLAPI_account_getNotifySettings alloc] init];
    obj.peer = peer;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:313765169];
	[ClassStore TLSerialize:self.peer stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_resetNotifySettings
+(TLAPI_account_resetNotifySettings*)create {
    TLAPI_account_resetNotifySettings* obj = [[TLAPI_account_resetNotifySettings alloc] init];
    
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-612493497];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_account_updateProfile
+(TLAPI_account_updateProfile*)createWithFirst_name:(NSString*)first_name last_name:(NSString*)last_name {
    TLAPI_account_updateProfile* obj = [[TLAPI_account_updateProfile alloc] init];
    obj.first_name = first_name;
	obj.last_name = last_name;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-259486360];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_updateStatus
+(TLAPI_account_updateStatus*)createWithOffline:(Boolean)offline {
    TLAPI_account_updateStatus* obj = [[TLAPI_account_updateStatus alloc] init];
    obj.offline = offline;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1713919532];
	[stream writeBool:self.offline];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_getWallPapers
+(TLAPI_account_getWallPapers*)create {
    TLAPI_account_getWallPapers* obj = [[TLAPI_account_getWallPapers alloc] init];
    
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1068696894];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_account_reportPeer
+(TLAPI_account_reportPeer*)createWithPeer:(TLInputPeer*)peer reason:(TLReportReason*)reason {
    TLAPI_account_reportPeer* obj = [[TLAPI_account_reportPeer alloc] init];
    obj.peer = peer;
	obj.reason = reason;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1374118561];
	[ClassStore TLSerialize:self.peer stream:stream];
	[ClassStore TLSerialize:self.reason stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_users_getUsers
+(TLAPI_users_getUsers*)createWithN_id:(NSMutableArray*)n_id {
    TLAPI_users_getUsers* obj = [[TLAPI_users_getUsers alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:227648840];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLInputUser* obj = [self.n_id objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_users_getFullUser
+(TLAPI_users_getFullUser*)createWithN_id:(TLInputUser*)n_id {
    TLAPI_users_getFullUser* obj = [[TLAPI_users_getFullUser alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-902781519];
	[ClassStore TLSerialize:self.n_id stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_getStatuses
+(TLAPI_contacts_getStatuses*)create {
    TLAPI_contacts_getStatuses* obj = [[TLAPI_contacts_getStatuses alloc] init];
    
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-995929106];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_getContacts
+(TLAPI_contacts_getContacts*)createWithN_hash:(NSString*)n_hash {
    TLAPI_contacts_getContacts* obj = [[TLAPI_contacts_getContacts alloc] init];
    obj.n_hash = n_hash;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:583445000];
	[stream writeString:self.n_hash];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_importContacts
+(TLAPI_contacts_importContacts*)createWithContacts:(NSMutableArray*)contacts replace:(Boolean)replace {
    TLAPI_contacts_importContacts* obj = [[TLAPI_contacts_importContacts alloc] init];
    obj.contacts = contacts;
	obj.replace = replace;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-634342611];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.contacts count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLInputContact* obj = [self.contacts objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeBool:self.replace];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_getSuggested
+(TLAPI_contacts_getSuggested*)createWithLimit:(int)limit {
    TLAPI_contacts_getSuggested* obj = [[TLAPI_contacts_getSuggested alloc] init];
    obj.limit = limit;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-847825880];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_deleteContact
+(TLAPI_contacts_deleteContact*)createWithN_id:(TLInputUser*)n_id {
    TLAPI_contacts_deleteContact* obj = [[TLAPI_contacts_deleteContact alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1902823612];
	[ClassStore TLSerialize:self.n_id stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_deleteContacts
+(TLAPI_contacts_deleteContacts*)createWithN_id:(NSMutableArray*)n_id {
    TLAPI_contacts_deleteContacts* obj = [[TLAPI_contacts_deleteContacts alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1504393374];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLInputUser* obj = [self.n_id objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_block
+(TLAPI_contacts_block*)createWithN_id:(TLInputUser*)n_id {
    TLAPI_contacts_block* obj = [[TLAPI_contacts_block alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:858475004];
	[ClassStore TLSerialize:self.n_id stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_unblock
+(TLAPI_contacts_unblock*)createWithN_id:(TLInputUser*)n_id {
    TLAPI_contacts_unblock* obj = [[TLAPI_contacts_unblock alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-448724803];
	[ClassStore TLSerialize:self.n_id stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_getBlocked
+(TLAPI_contacts_getBlocked*)createWithOffset:(int)offset limit:(int)limit {
    TLAPI_contacts_getBlocked* obj = [[TLAPI_contacts_getBlocked alloc] init];
    obj.offset = offset;
	obj.limit = limit;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-176409329];
	[stream writeInt:self.offset];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_exportCard
+(TLAPI_contacts_exportCard*)create {
    TLAPI_contacts_exportCard* obj = [[TLAPI_contacts_exportCard alloc] init];
    
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-2065352905];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_importCard
+(TLAPI_contacts_importCard*)createWithExport_card:(NSMutableArray*)export_card {
    TLAPI_contacts_importCard* obj = [[TLAPI_contacts_importCard alloc] init];
    obj.export_card = export_card;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1340184318];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.export_card count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.export_card count] > i) {
                NSNumber* obj = [self.export_card objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getMessages
+(TLAPI_messages_getMessages*)createWithN_id:(NSMutableArray*)n_id {
    TLAPI_messages_getMessages* obj = [[TLAPI_messages_getMessages alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1109588596];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.n_id count] > i) {
                NSNumber* obj = [self.n_id objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getDialogs
+(TLAPI_messages_getDialogs*)createWithOffset_date:(int)offset_date offset_id:(int)offset_id offset_peer:(TLInputPeer*)offset_peer limit:(int)limit {
    TLAPI_messages_getDialogs* obj = [[TLAPI_messages_getDialogs alloc] init];
    obj.offset_date = offset_date;
	obj.offset_id = offset_id;
	obj.offset_peer = offset_peer;
	obj.limit = limit;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1799878989];
	[stream writeInt:self.offset_date];
	[stream writeInt:self.offset_id];
	[ClassStore TLSerialize:self.offset_peer stream:stream];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getHistory
+(TLAPI_messages_getHistory*)createWithPeer:(TLInputPeer*)peer offset_id:(int)offset_id add_offset:(int)add_offset limit:(int)limit max_id:(int)max_id min_id:(int)min_id {
    TLAPI_messages_getHistory* obj = [[TLAPI_messages_getHistory alloc] init];
    obj.peer = peer;
	obj.offset_id = offset_id;
	obj.add_offset = add_offset;
	obj.limit = limit;
	obj.max_id = max_id;
	obj.min_id = min_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1970355494];
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeInt:self.offset_id];
	[stream writeInt:self.add_offset];
	[stream writeInt:self.limit];
	[stream writeInt:self.max_id];
	[stream writeInt:self.min_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_search
+(TLAPI_messages_search*)createWithFlags:(int)flags  peer:(TLInputPeer*)peer q:(NSString*)q filter:(TLMessagesFilter*)filter min_date:(int)min_date max_date:(int)max_date offset:(int)offset max_id:(int)max_id limit:(int)limit {
    TLAPI_messages_search* obj = [[TLAPI_messages_search alloc] init];
    obj.flags = flags;
	
	obj.peer = peer;
	obj.q = q;
	obj.filter = filter;
	obj.min_date = min_date;
	obj.max_date = max_date;
	obj.offset = offset;
	obj.max_id = max_id;
	obj.limit = limit;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-732523960];
	[stream writeInt:self.flags];
	
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeString:self.q];
	[ClassStore TLSerialize:self.filter stream:stream];
	[stream writeInt:self.min_date];
	[stream writeInt:self.max_date];
	[stream writeInt:self.offset];
	[stream writeInt:self.max_id];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_readHistory
+(TLAPI_messages_readHistory*)createWithPeer:(TLInputPeer*)peer max_id:(int)max_id {
    TLAPI_messages_readHistory* obj = [[TLAPI_messages_readHistory alloc] init];
    obj.peer = peer;
	obj.max_id = max_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:238054714];
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeInt:self.max_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_deleteHistory
+(TLAPI_messages_deleteHistory*)createWithPeer:(TLInputPeer*)peer max_id:(int)max_id {
    TLAPI_messages_deleteHistory* obj = [[TLAPI_messages_deleteHistory alloc] init];
    obj.peer = peer;
	obj.max_id = max_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1212072999];
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeInt:self.max_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_deleteMessages
+(TLAPI_messages_deleteMessages*)createWithN_id:(NSMutableArray*)n_id {
    TLAPI_messages_deleteMessages* obj = [[TLAPI_messages_deleteMessages alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1510897371];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.n_id count] > i) {
                NSNumber* obj = [self.n_id objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_receivedMessages
+(TLAPI_messages_receivedMessages*)createWithMax_id:(int)max_id {
    TLAPI_messages_receivedMessages* obj = [[TLAPI_messages_receivedMessages alloc] init];
    obj.max_id = max_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:94983360];
	[stream writeInt:self.max_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_setTyping
+(TLAPI_messages_setTyping*)createWithPeer:(TLInputPeer*)peer action:(TLSendMessageAction*)action {
    TLAPI_messages_setTyping* obj = [[TLAPI_messages_setTyping alloc] init];
    obj.peer = peer;
	obj.action = action;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1551737264];
	[ClassStore TLSerialize:self.peer stream:stream];
	[ClassStore TLSerialize:self.action stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_sendMessage
+(TLAPI_messages_sendMessage*)createWithFlags:(int)flags   peer:(TLInputPeer*)peer reply_to_msg_id:(int)reply_to_msg_id message:(NSString*)message random_id:(long)random_id reply_markup:(TLReplyMarkup*)reply_markup entities:(NSMutableArray*)entities {
    TLAPI_messages_sendMessage* obj = [[TLAPI_messages_sendMessage alloc] init];
    obj.flags = flags;
	
	
	obj.peer = peer;
	obj.reply_to_msg_id = reply_to_msg_id;
	obj.message = message;
	obj.random_id = random_id;
	obj.reply_markup = reply_markup;
	obj.entities = entities;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-91733382];
	[stream writeInt:self.flags];
	
	
	[ClassStore TLSerialize:self.peer stream:stream];
	if(self.flags & (1 << 0)) {[stream writeInt:self.reply_to_msg_id];}
	[stream writeString:self.message];
	[stream writeLong:self.random_id];
	if(self.flags & (1 << 2)) {[ClassStore TLSerialize:self.reply_markup stream:stream];}
	if(self.flags & (1 << 3)) {//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.entities count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLMessageEntity* obj = [self.entities objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}}
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_sendMedia
+(TLAPI_messages_sendMedia*)createWithFlags:(int)flags  peer:(TLInputPeer*)peer reply_to_msg_id:(int)reply_to_msg_id media:(TLInputMedia*)media random_id:(long)random_id reply_markup:(TLReplyMarkup*)reply_markup {
    TLAPI_messages_sendMedia* obj = [[TLAPI_messages_sendMedia alloc] init];
    obj.flags = flags;
	
	obj.peer = peer;
	obj.reply_to_msg_id = reply_to_msg_id;
	obj.media = media;
	obj.random_id = random_id;
	obj.reply_markup = reply_markup;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-923703407];
	[stream writeInt:self.flags];
	
	[ClassStore TLSerialize:self.peer stream:stream];
	if(self.flags & (1 << 0)) {[stream writeInt:self.reply_to_msg_id];}
	[ClassStore TLSerialize:self.media stream:stream];
	[stream writeLong:self.random_id];
	if(self.flags & (1 << 2)) {[ClassStore TLSerialize:self.reply_markup stream:stream];}
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_forwardMessages
+(TLAPI_messages_forwardMessages*)createWithFlags:(int)flags  from_peer:(TLInputPeer*)from_peer n_id:(NSMutableArray*)n_id random_id:(NSMutableArray*)random_id to_peer:(TLInputPeer*)to_peer {
    TLAPI_messages_forwardMessages* obj = [[TLAPI_messages_forwardMessages alloc] init];
    obj.flags = flags;
	
	obj.from_peer = from_peer;
	obj.n_id = n_id;
	obj.random_id = random_id;
	obj.to_peer = to_peer;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1888354709];
	[stream writeInt:self.flags];
	
	[ClassStore TLSerialize:self.from_peer stream:stream];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.n_id count] > i) {
                NSNumber* obj = [self.n_id objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
		}
	}
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.random_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.random_id count] > i) {
                NSNumber* obj = [self.random_id objectAtIndex:i];
			[stream writeLong:[obj longValue]];
            }  else
                break;
		}
	}
	[ClassStore TLSerialize:self.to_peer stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_reportSpam
+(TLAPI_messages_reportSpam*)createWithPeer:(TLInputPeer*)peer {
    TLAPI_messages_reportSpam* obj = [[TLAPI_messages_reportSpam alloc] init];
    obj.peer = peer;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-820669733];
	[ClassStore TLSerialize:self.peer stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getChats
+(TLAPI_messages_getChats*)createWithN_id:(NSMutableArray*)n_id {
    TLAPI_messages_getChats* obj = [[TLAPI_messages_getChats alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1013621127];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.n_id count] > i) {
                NSNumber* obj = [self.n_id objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getFullChat
+(TLAPI_messages_getFullChat*)createWithChat_id:(int)chat_id {
    TLAPI_messages_getFullChat* obj = [[TLAPI_messages_getFullChat alloc] init];
    obj.chat_id = chat_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:998448230];
	[stream writeInt:self.chat_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_editChatTitle
+(TLAPI_messages_editChatTitle*)createWithChat_id:(int)chat_id title:(NSString*)title {
    TLAPI_messages_editChatTitle* obj = [[TLAPI_messages_editChatTitle alloc] init];
    obj.chat_id = chat_id;
	obj.title = title;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-599447467];
	[stream writeInt:self.chat_id];
	[stream writeString:self.title];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_editChatPhoto
+(TLAPI_messages_editChatPhoto*)createWithChat_id:(int)chat_id photo:(TLInputChatPhoto*)photo {
    TLAPI_messages_editChatPhoto* obj = [[TLAPI_messages_editChatPhoto alloc] init];
    obj.chat_id = chat_id;
	obj.photo = photo;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-900957736];
	[stream writeInt:self.chat_id];
	[ClassStore TLSerialize:self.photo stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_addChatUser
+(TLAPI_messages_addChatUser*)createWithChat_id:(int)chat_id user_id:(TLInputUser*)user_id fwd_limit:(int)fwd_limit {
    TLAPI_messages_addChatUser* obj = [[TLAPI_messages_addChatUser alloc] init];
    obj.chat_id = chat_id;
	obj.user_id = user_id;
	obj.fwd_limit = fwd_limit;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-106911223];
	[stream writeInt:self.chat_id];
	[ClassStore TLSerialize:self.user_id stream:stream];
	[stream writeInt:self.fwd_limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_deleteChatUser
+(TLAPI_messages_deleteChatUser*)createWithChat_id:(int)chat_id user_id:(TLInputUser*)user_id {
    TLAPI_messages_deleteChatUser* obj = [[TLAPI_messages_deleteChatUser alloc] init];
    obj.chat_id = chat_id;
	obj.user_id = user_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-530505962];
	[stream writeInt:self.chat_id];
	[ClassStore TLSerialize:self.user_id stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_createChat
+(TLAPI_messages_createChat*)createWithUsers:(NSMutableArray*)users title:(NSString*)title {
    TLAPI_messages_createChat* obj = [[TLAPI_messages_createChat alloc] init];
    obj.users = users;
	obj.title = title;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:164303470];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLInputUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeString:self.title];
	return [stream getOutput];
}
@end

@implementation TLAPI_updates_getState
+(TLAPI_updates_getState*)create {
    TLAPI_updates_getState* obj = [[TLAPI_updates_getState alloc] init];
    
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-304838614];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_updates_getDifference
+(TLAPI_updates_getDifference*)createWithPts:(int)pts date:(int)date qts:(int)qts {
    TLAPI_updates_getDifference* obj = [[TLAPI_updates_getDifference alloc] init];
    obj.pts = pts;
	obj.date = date;
	obj.qts = qts;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:168039573];
	[stream writeInt:self.pts];
	[stream writeInt:self.date];
	[stream writeInt:self.qts];
	return [stream getOutput];
}
@end

@implementation TLAPI_photos_updateProfilePhoto
+(TLAPI_photos_updateProfilePhoto*)createWithN_id:(TLInputPhoto*)n_id crop:(TLInputPhotoCrop*)crop {
    TLAPI_photos_updateProfilePhoto* obj = [[TLAPI_photos_updateProfilePhoto alloc] init];
    obj.n_id = n_id;
	obj.crop = crop;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-285902432];
	[ClassStore TLSerialize:self.n_id stream:stream];
	[ClassStore TLSerialize:self.crop stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_photos_uploadProfilePhoto
+(TLAPI_photos_uploadProfilePhoto*)createWithFile:(TLInputFile*)file caption:(NSString*)caption geo_point:(TLInputGeoPoint*)geo_point crop:(TLInputPhotoCrop*)crop {
    TLAPI_photos_uploadProfilePhoto* obj = [[TLAPI_photos_uploadProfilePhoto alloc] init];
    obj.file = file;
	obj.caption = caption;
	obj.geo_point = geo_point;
	obj.crop = crop;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-720397176];
	[ClassStore TLSerialize:self.file stream:stream];
	[stream writeString:self.caption];
	[ClassStore TLSerialize:self.geo_point stream:stream];
	[ClassStore TLSerialize:self.crop stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_photos_deletePhotos
+(TLAPI_photos_deletePhotos*)createWithN_id:(NSMutableArray*)n_id {
    TLAPI_photos_deletePhotos* obj = [[TLAPI_photos_deletePhotos alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-2016444625];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLInputPhoto* obj = [self.n_id objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_upload_saveFilePart
+(TLAPI_upload_saveFilePart*)createWithFile_id:(long)file_id file_part:(int)file_part bytes:(NSData*)bytes {
    TLAPI_upload_saveFilePart* obj = [[TLAPI_upload_saveFilePart alloc] init];
    obj.file_id = file_id;
	obj.file_part = file_part;
	obj.bytes = bytes;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1291540959];
	[stream writeLong:self.file_id];
	[stream writeInt:self.file_part];
	[stream writeByteArray:self.bytes];
	return [stream getOutput];
}
@end

@implementation TLAPI_upload_getFile
+(TLAPI_upload_getFile*)createWithLocation:(TLInputFileLocation*)location offset:(int)offset limit:(int)limit {
    TLAPI_upload_getFile* obj = [[TLAPI_upload_getFile alloc] init];
    obj.location = location;
	obj.offset = offset;
	obj.limit = limit;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-475607115];
	[ClassStore TLSerialize:self.location stream:stream];
	[stream writeInt:self.offset];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_help_getConfig
+(TLAPI_help_getConfig*)create {
    TLAPI_help_getConfig* obj = [[TLAPI_help_getConfig alloc] init];
    
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-990308245];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_help_getNearestDc
+(TLAPI_help_getNearestDc*)create {
    TLAPI_help_getNearestDc* obj = [[TLAPI_help_getNearestDc alloc] init];
    
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:531836966];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_help_getAppUpdate
+(TLAPI_help_getAppUpdate*)createWithDevice_model:(NSString*)device_model system_version:(NSString*)system_version app_version:(NSString*)app_version lang_code:(NSString*)lang_code {
    TLAPI_help_getAppUpdate* obj = [[TLAPI_help_getAppUpdate alloc] init];
    obj.device_model = device_model;
	obj.system_version = system_version;
	obj.app_version = app_version;
	obj.lang_code = lang_code;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-938300290];
	[stream writeString:self.device_model];
	[stream writeString:self.system_version];
	[stream writeString:self.app_version];
	[stream writeString:self.lang_code];
	return [stream getOutput];
}
@end

@implementation TLAPI_help_saveAppLog
+(TLAPI_help_saveAppLog*)createWithEvents:(NSMutableArray*)events {
    TLAPI_help_saveAppLog* obj = [[TLAPI_help_saveAppLog alloc] init];
    obj.events = events;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1862465352];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.events count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLInputAppEvent* obj = [self.events objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_help_getInviteText
+(TLAPI_help_getInviteText*)createWithLang_code:(NSString*)lang_code {
    TLAPI_help_getInviteText* obj = [[TLAPI_help_getInviteText alloc] init];
    obj.lang_code = lang_code;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1532407418];
	[stream writeString:self.lang_code];
	return [stream getOutput];
}
@end

@implementation TLAPI_photos_getUserPhotos
+(TLAPI_photos_getUserPhotos*)createWithUser_id:(TLInputUser*)user_id offset:(int)offset max_id:(long)max_id limit:(int)limit {
    TLAPI_photos_getUserPhotos* obj = [[TLAPI_photos_getUserPhotos alloc] init];
    obj.user_id = user_id;
	obj.offset = offset;
	obj.max_id = max_id;
	obj.limit = limit;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1848823128];
	[ClassStore TLSerialize:self.user_id stream:stream];
	[stream writeInt:self.offset];
	[stream writeLong:self.max_id];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_forwardMessage
+(TLAPI_messages_forwardMessage*)createWithPeer:(TLInputPeer*)peer n_id:(int)n_id random_id:(long)random_id {
    TLAPI_messages_forwardMessage* obj = [[TLAPI_messages_forwardMessage alloc] init];
    obj.peer = peer;
	obj.n_id = n_id;
	obj.random_id = random_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:865483769];
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeInt:self.n_id];
	[stream writeLong:self.random_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_sendBroadcast
+(TLAPI_messages_sendBroadcast*)createWithContacts:(NSMutableArray*)contacts random_id:(NSMutableArray*)random_id message:(NSString*)message media:(TLInputMedia*)media {
    TLAPI_messages_sendBroadcast* obj = [[TLAPI_messages_sendBroadcast alloc] init];
    obj.contacts = contacts;
	obj.random_id = random_id;
	obj.message = message;
	obj.media = media;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1082919718];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.contacts count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLInputUser* obj = [self.contacts objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.random_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.random_id count] > i) {
                NSNumber* obj = [self.random_id objectAtIndex:i];
			[stream writeLong:[obj longValue]];
            }  else
                break;
		}
	}
	[stream writeString:self.message];
	[ClassStore TLSerialize:self.media stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getDhConfig
+(TLAPI_messages_getDhConfig*)createWithVersion:(int)version random_length:(int)random_length {
    TLAPI_messages_getDhConfig* obj = [[TLAPI_messages_getDhConfig alloc] init];
    obj.version = version;
	obj.random_length = random_length;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:651135312];
	[stream writeInt:self.version];
	[stream writeInt:self.random_length];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_requestEncryption
+(TLAPI_messages_requestEncryption*)createWithUser_id:(TLInputUser*)user_id random_id:(int)random_id g_a:(NSData*)g_a {
    TLAPI_messages_requestEncryption* obj = [[TLAPI_messages_requestEncryption alloc] init];
    obj.user_id = user_id;
	obj.random_id = random_id;
	obj.g_a = g_a;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-162681021];
	[ClassStore TLSerialize:self.user_id stream:stream];
	[stream writeInt:self.random_id];
	[stream writeByteArray:self.g_a];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_acceptEncryption
+(TLAPI_messages_acceptEncryption*)createWithPeer:(TLInputEncryptedChat*)peer g_b:(NSData*)g_b key_fingerprint:(long)key_fingerprint {
    TLAPI_messages_acceptEncryption* obj = [[TLAPI_messages_acceptEncryption alloc] init];
    obj.peer = peer;
	obj.g_b = g_b;
	obj.key_fingerprint = key_fingerprint;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1035731989];
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeByteArray:self.g_b];
	[stream writeLong:self.key_fingerprint];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_discardEncryption
+(TLAPI_messages_discardEncryption*)createWithChat_id:(int)chat_id {
    TLAPI_messages_discardEncryption* obj = [[TLAPI_messages_discardEncryption alloc] init];
    obj.chat_id = chat_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-304536635];
	[stream writeInt:self.chat_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_setEncryptedTyping
+(TLAPI_messages_setEncryptedTyping*)createWithPeer:(TLInputEncryptedChat*)peer typing:(Boolean)typing {
    TLAPI_messages_setEncryptedTyping* obj = [[TLAPI_messages_setEncryptedTyping alloc] init];
    obj.peer = peer;
	obj.typing = typing;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:2031374829];
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeBool:self.typing];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_readEncryptedHistory
+(TLAPI_messages_readEncryptedHistory*)createWithPeer:(TLInputEncryptedChat*)peer max_date:(int)max_date {
    TLAPI_messages_readEncryptedHistory* obj = [[TLAPI_messages_readEncryptedHistory alloc] init];
    obj.peer = peer;
	obj.max_date = max_date;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:2135648522];
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeInt:self.max_date];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_sendEncrypted
+(TLAPI_messages_sendEncrypted*)createWithPeer:(TLInputEncryptedChat*)peer random_id:(long)random_id data:(NSData*)data {
    TLAPI_messages_sendEncrypted* obj = [[TLAPI_messages_sendEncrypted alloc] init];
    obj.peer = peer;
	obj.random_id = random_id;
	obj.data = data;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1451792525];
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeLong:self.random_id];
	[stream writeByteArray:self.data];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_sendEncryptedFile
+(TLAPI_messages_sendEncryptedFile*)createWithPeer:(TLInputEncryptedChat*)peer random_id:(long)random_id data:(NSData*)data file:(TLInputEncryptedFile*)file {
    TLAPI_messages_sendEncryptedFile* obj = [[TLAPI_messages_sendEncryptedFile alloc] init];
    obj.peer = peer;
	obj.random_id = random_id;
	obj.data = data;
	obj.file = file;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1701831834];
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeLong:self.random_id];
	[stream writeByteArray:self.data];
	[ClassStore TLSerialize:self.file stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_sendEncryptedService
+(TLAPI_messages_sendEncryptedService*)createWithPeer:(TLInputEncryptedChat*)peer random_id:(long)random_id data:(NSData*)data {
    TLAPI_messages_sendEncryptedService* obj = [[TLAPI_messages_sendEncryptedService alloc] init];
    obj.peer = peer;
	obj.random_id = random_id;
	obj.data = data;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:852769188];
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeLong:self.random_id];
	[stream writeByteArray:self.data];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_receivedQueue
+(TLAPI_messages_receivedQueue*)createWithMax_qts:(int)max_qts {
    TLAPI_messages_receivedQueue* obj = [[TLAPI_messages_receivedQueue alloc] init];
    obj.max_qts = max_qts;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1436924774];
	[stream writeInt:self.max_qts];
	return [stream getOutput];
}
@end

@implementation TLAPI_upload_saveBigFilePart
+(TLAPI_upload_saveBigFilePart*)createWithFile_id:(long)file_id file_part:(int)file_part file_total_parts:(int)file_total_parts bytes:(NSData*)bytes {
    TLAPI_upload_saveBigFilePart* obj = [[TLAPI_upload_saveBigFilePart alloc] init];
    obj.file_id = file_id;
	obj.file_part = file_part;
	obj.file_total_parts = file_total_parts;
	obj.bytes = bytes;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-562337987];
	[stream writeLong:self.file_id];
	[stream writeInt:self.file_part];
	[stream writeInt:self.file_total_parts];
	[stream writeByteArray:self.bytes];
	return [stream getOutput];
}
@end

@implementation TLAPI_help_getSupport
+(TLAPI_help_getSupport*)create {
    TLAPI_help_getSupport* obj = [[TLAPI_help_getSupport alloc] init];
    
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1663104819];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_sendSms
+(TLAPI_auth_sendSms*)createWithPhone_number:(NSString*)phone_number phone_code_hash:(NSString*)phone_code_hash {
    TLAPI_auth_sendSms* obj = [[TLAPI_auth_sendSms alloc] init];
    obj.phone_number = phone_number;
	obj.phone_code_hash = phone_code_hash;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:229241832];
	[stream writeString:self.phone_number];
	[stream writeString:self.phone_code_hash];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_readMessageContents
+(TLAPI_messages_readMessageContents*)createWithN_id:(NSMutableArray*)n_id {
    TLAPI_messages_readMessageContents* obj = [[TLAPI_messages_readMessageContents alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:916930423];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.n_id count] > i) {
                NSNumber* obj = [self.n_id objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_account_checkUsername
+(TLAPI_account_checkUsername*)createWithUsername:(NSString*)username {
    TLAPI_account_checkUsername* obj = [[TLAPI_account_checkUsername alloc] init];
    obj.username = username;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:655677548];
	[stream writeString:self.username];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_updateUsername
+(TLAPI_account_updateUsername*)createWithUsername:(NSString*)username {
    TLAPI_account_updateUsername* obj = [[TLAPI_account_updateUsername alloc] init];
    obj.username = username;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1040964988];
	[stream writeString:self.username];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_search
+(TLAPI_contacts_search*)createWithQ:(NSString*)q limit:(int)limit {
    TLAPI_contacts_search* obj = [[TLAPI_contacts_search alloc] init];
    obj.q = q;
	obj.limit = limit;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:301470424];
	[stream writeString:self.q];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_getPrivacy
+(TLAPI_account_getPrivacy*)createWithN_key:(TLInputPrivacyKey*)n_key {
    TLAPI_account_getPrivacy* obj = [[TLAPI_account_getPrivacy alloc] init];
    obj.n_key = n_key;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-623130288];
	[ClassStore TLSerialize:self.n_key stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_setPrivacy
+(TLAPI_account_setPrivacy*)createWithN_key:(TLInputPrivacyKey*)n_key rules:(NSMutableArray*)rules {
    TLAPI_account_setPrivacy* obj = [[TLAPI_account_setPrivacy alloc] init];
    obj.n_key = n_key;
	obj.rules = rules;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-906486552];
	[ClassStore TLSerialize:self.n_key stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.rules count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLInputPrivacyRule* obj = [self.rules objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_account_deleteAccount
+(TLAPI_account_deleteAccount*)createWithReason:(NSString*)reason {
    TLAPI_account_deleteAccount* obj = [[TLAPI_account_deleteAccount alloc] init];
    obj.reason = reason;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1099779595];
	[stream writeString:self.reason];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_getAccountTTL
+(TLAPI_account_getAccountTTL*)create {
    TLAPI_account_getAccountTTL* obj = [[TLAPI_account_getAccountTTL alloc] init];
    
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:150761757];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_account_setAccountTTL
+(TLAPI_account_setAccountTTL*)createWithTtl:(TLAccountDaysTTL*)ttl {
    TLAPI_account_setAccountTTL* obj = [[TLAPI_account_setAccountTTL alloc] init];
    obj.ttl = ttl;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:608323678];
	[ClassStore TLSerialize:self.ttl stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_resolveUsername
+(TLAPI_contacts_resolveUsername*)createWithUsername:(NSString*)username {
    TLAPI_contacts_resolveUsername* obj = [[TLAPI_contacts_resolveUsername alloc] init];
    obj.username = username;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-113456221];
	[stream writeString:self.username];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_sendChangePhoneCode
+(TLAPI_account_sendChangePhoneCode*)createWithPhone_number:(NSString*)phone_number {
    TLAPI_account_sendChangePhoneCode* obj = [[TLAPI_account_sendChangePhoneCode alloc] init];
    obj.phone_number = phone_number;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1543001868];
	[stream writeString:self.phone_number];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_changePhone
+(TLAPI_account_changePhone*)createWithPhone_number:(NSString*)phone_number phone_code_hash:(NSString*)phone_code_hash phone_code:(NSString*)phone_code {
    TLAPI_account_changePhone* obj = [[TLAPI_account_changePhone alloc] init];
    obj.phone_number = phone_number;
	obj.phone_code_hash = phone_code_hash;
	obj.phone_code = phone_code;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1891839707];
	[stream writeString:self.phone_number];
	[stream writeString:self.phone_code_hash];
	[stream writeString:self.phone_code];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getStickers
+(TLAPI_messages_getStickers*)createWithEmoticon:(NSString*)emoticon n_hash:(NSString*)n_hash {
    TLAPI_messages_getStickers* obj = [[TLAPI_messages_getStickers alloc] init];
    obj.emoticon = emoticon;
	obj.n_hash = n_hash;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1373446075];
	[stream writeString:self.emoticon];
	[stream writeString:self.n_hash];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getAllStickers
+(TLAPI_messages_getAllStickers*)createWithN_hash:(int)n_hash {
    TLAPI_messages_getAllStickers* obj = [[TLAPI_messages_getAllStickers alloc] init];
    obj.n_hash = n_hash;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:479598769];
	[stream writeInt:self.n_hash];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_updateDeviceLocked
+(TLAPI_account_updateDeviceLocked*)createWithPeriod:(int)period {
    TLAPI_account_updateDeviceLocked* obj = [[TLAPI_account_updateDeviceLocked alloc] init];
    obj.period = period;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:954152242];
	[stream writeInt:self.period];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_importBotAuthorization
+(TLAPI_auth_importBotAuthorization*)createWithFlags:(int)flags api_id:(int)api_id api_hash:(NSString*)api_hash bot_auth_token:(NSString*)bot_auth_token {
    TLAPI_auth_importBotAuthorization* obj = [[TLAPI_auth_importBotAuthorization alloc] init];
    obj.flags = flags;
	obj.api_id = api_id;
	obj.api_hash = api_hash;
	obj.bot_auth_token = bot_auth_token;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1738800940];
	[stream writeInt:self.flags];
	[stream writeInt:self.api_id];
	[stream writeString:self.api_hash];
	[stream writeString:self.bot_auth_token];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getWebPagePreview
+(TLAPI_messages_getWebPagePreview*)createWithMessage:(NSString*)message {
    TLAPI_messages_getWebPagePreview* obj = [[TLAPI_messages_getWebPagePreview alloc] init];
    obj.message = message;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:623001124];
	[stream writeString:self.message];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_getAuthorizations
+(TLAPI_account_getAuthorizations*)create {
    TLAPI_account_getAuthorizations* obj = [[TLAPI_account_getAuthorizations alloc] init];
    
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-484392616];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_account_resetAuthorization
+(TLAPI_account_resetAuthorization*)createWithN_hash:(long)n_hash {
    TLAPI_account_resetAuthorization* obj = [[TLAPI_account_resetAuthorization alloc] init];
    obj.n_hash = n_hash;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-545786948];
	[stream writeLong:self.n_hash];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_getPassword
+(TLAPI_account_getPassword*)create {
    TLAPI_account_getPassword* obj = [[TLAPI_account_getPassword alloc] init];
    
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1418342645];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_account_getPasswordSettings
+(TLAPI_account_getPasswordSettings*)createWithCurrent_password_hash:(NSData*)current_password_hash {
    TLAPI_account_getPasswordSettings* obj = [[TLAPI_account_getPasswordSettings alloc] init];
    obj.current_password_hash = current_password_hash;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1131605573];
	[stream writeByteArray:self.current_password_hash];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_updatePasswordSettings
+(TLAPI_account_updatePasswordSettings*)createWithCurrent_password_hash:(NSData*)current_password_hash n_settings:(TLaccount_PasswordInputSettings*)n_settings {
    TLAPI_account_updatePasswordSettings* obj = [[TLAPI_account_updatePasswordSettings alloc] init];
    obj.current_password_hash = current_password_hash;
	obj.n_settings = n_settings;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-92517498];
	[stream writeByteArray:self.current_password_hash];
	[ClassStore TLSerialize:self.n_settings stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_checkPassword
+(TLAPI_auth_checkPassword*)createWithPassword_hash:(NSData*)password_hash {
    TLAPI_auth_checkPassword* obj = [[TLAPI_auth_checkPassword alloc] init];
    obj.password_hash = password_hash;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:174260510];
	[stream writeByteArray:self.password_hash];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_requestPasswordRecovery
+(TLAPI_auth_requestPasswordRecovery*)create {
    TLAPI_auth_requestPasswordRecovery* obj = [[TLAPI_auth_requestPasswordRecovery alloc] init];
    
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-661144474];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_recoverPassword
+(TLAPI_auth_recoverPassword*)createWithCode:(NSString*)code {
    TLAPI_auth_recoverPassword* obj = [[TLAPI_auth_recoverPassword alloc] init];
    obj.code = code;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1319464594];
	[stream writeString:self.code];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_exportChatInvite
+(TLAPI_messages_exportChatInvite*)createWithChat_id:(int)chat_id {
    TLAPI_messages_exportChatInvite* obj = [[TLAPI_messages_exportChatInvite alloc] init];
    obj.chat_id = chat_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:2106086025];
	[stream writeInt:self.chat_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_checkChatInvite
+(TLAPI_messages_checkChatInvite*)createWithN_hash:(NSString*)n_hash {
    TLAPI_messages_checkChatInvite* obj = [[TLAPI_messages_checkChatInvite alloc] init];
    obj.n_hash = n_hash;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1051570619];
	[stream writeString:self.n_hash];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_importChatInvite
+(TLAPI_messages_importChatInvite*)createWithN_hash:(NSString*)n_hash {
    TLAPI_messages_importChatInvite* obj = [[TLAPI_messages_importChatInvite alloc] init];
    obj.n_hash = n_hash;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1817183516];
	[stream writeString:self.n_hash];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getStickerSet
+(TLAPI_messages_getStickerSet*)createWithStickerset:(TLInputStickerSet*)stickerset {
    TLAPI_messages_getStickerSet* obj = [[TLAPI_messages_getStickerSet alloc] init];
    obj.stickerset = stickerset;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:639215886];
	[ClassStore TLSerialize:self.stickerset stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_installStickerSet
+(TLAPI_messages_installStickerSet*)createWithStickerset:(TLInputStickerSet*)stickerset disabled:(Boolean)disabled {
    TLAPI_messages_installStickerSet* obj = [[TLAPI_messages_installStickerSet alloc] init];
    obj.stickerset = stickerset;
	obj.disabled = disabled;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:2066793382];
	[ClassStore TLSerialize:self.stickerset stream:stream];
	[stream writeBool:self.disabled];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_uninstallStickerSet
+(TLAPI_messages_uninstallStickerSet*)createWithStickerset:(TLInputStickerSet*)stickerset {
    TLAPI_messages_uninstallStickerSet* obj = [[TLAPI_messages_uninstallStickerSet alloc] init];
    obj.stickerset = stickerset;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-110209570];
	[ClassStore TLSerialize:self.stickerset stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_startBot
+(TLAPI_messages_startBot*)createWithBot:(TLInputUser*)bot peer:(TLInputPeer*)peer random_id:(long)random_id start_param:(NSString*)start_param {
    TLAPI_messages_startBot* obj = [[TLAPI_messages_startBot alloc] init];
    obj.bot = bot;
	obj.peer = peer;
	obj.random_id = random_id;
	obj.start_param = start_param;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-421563528];
	[ClassStore TLSerialize:self.bot stream:stream];
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeLong:self.random_id];
	[stream writeString:self.start_param];
	return [stream getOutput];
}
@end

@implementation TLAPI_help_getAppChangelog
+(TLAPI_help_getAppChangelog*)createWithDevice_model:(NSString*)device_model system_version:(NSString*)system_version app_version:(NSString*)app_version lang_code:(NSString*)lang_code {
    TLAPI_help_getAppChangelog* obj = [[TLAPI_help_getAppChangelog alloc] init];
    obj.device_model = device_model;
	obj.system_version = system_version;
	obj.app_version = app_version;
	obj.lang_code = lang_code;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1537966002];
	[stream writeString:self.device_model];
	[stream writeString:self.system_version];
	[stream writeString:self.app_version];
	[stream writeString:self.lang_code];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getMessagesViews
+(TLAPI_messages_getMessagesViews*)createWithPeer:(TLInputPeer*)peer n_id:(NSMutableArray*)n_id increment:(Boolean)increment {
    TLAPI_messages_getMessagesViews* obj = [[TLAPI_messages_getMessagesViews alloc] init];
    obj.peer = peer;
	obj.n_id = n_id;
	obj.increment = increment;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-993483427];
	[ClassStore TLSerialize:self.peer stream:stream];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.n_id count] > i) {
                NSNumber* obj = [self.n_id objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
		}
	}
	[stream writeBool:self.increment];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_getDialogs
+(TLAPI_channels_getDialogs*)createWithOffset:(int)offset limit:(int)limit {
    TLAPI_channels_getDialogs* obj = [[TLAPI_channels_getDialogs alloc] init];
    obj.offset = offset;
	obj.limit = limit;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1445735863];
	[stream writeInt:self.offset];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_getImportantHistory
+(TLAPI_channels_getImportantHistory*)createWithChannel:(TLInputChannel*)channel offset_id:(int)offset_id add_offset:(int)add_offset limit:(int)limit max_id:(int)max_id min_id:(int)min_id {
    TLAPI_channels_getImportantHistory* obj = [[TLAPI_channels_getImportantHistory alloc] init];
    obj.channel = channel;
	obj.offset_id = offset_id;
	obj.add_offset = add_offset;
	obj.limit = limit;
	obj.max_id = max_id;
	obj.min_id = min_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-575067701];
	[ClassStore TLSerialize:self.channel stream:stream];
	[stream writeInt:self.offset_id];
	[stream writeInt:self.add_offset];
	[stream writeInt:self.limit];
	[stream writeInt:self.max_id];
	[stream writeInt:self.min_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_readHistory
+(TLAPI_channels_readHistory*)createWithChannel:(TLInputChannel*)channel max_id:(int)max_id {
    TLAPI_channels_readHistory* obj = [[TLAPI_channels_readHistory alloc] init];
    obj.channel = channel;
	obj.max_id = max_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-871347913];
	[ClassStore TLSerialize:self.channel stream:stream];
	[stream writeInt:self.max_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_deleteMessages
+(TLAPI_channels_deleteMessages*)createWithChannel:(TLInputChannel*)channel n_id:(NSMutableArray*)n_id {
    TLAPI_channels_deleteMessages* obj = [[TLAPI_channels_deleteMessages alloc] init];
    obj.channel = channel;
	obj.n_id = n_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-2067661490];
	[ClassStore TLSerialize:self.channel stream:stream];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.n_id count] > i) {
                NSNumber* obj = [self.n_id objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_deleteUserHistory
+(TLAPI_channels_deleteUserHistory*)createWithChannel:(TLInputChannel*)channel user_id:(TLInputUser*)user_id {
    TLAPI_channels_deleteUserHistory* obj = [[TLAPI_channels_deleteUserHistory alloc] init];
    obj.channel = channel;
	obj.user_id = user_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-787622117];
	[ClassStore TLSerialize:self.channel stream:stream];
	[ClassStore TLSerialize:self.user_id stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_reportSpam
+(TLAPI_channels_reportSpam*)createWithChannel:(TLInputChannel*)channel user_id:(TLInputUser*)user_id n_id:(NSMutableArray*)n_id {
    TLAPI_channels_reportSpam* obj = [[TLAPI_channels_reportSpam alloc] init];
    obj.channel = channel;
	obj.user_id = user_id;
	obj.n_id = n_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-32999408];
	[ClassStore TLSerialize:self.channel stream:stream];
	[ClassStore TLSerialize:self.user_id stream:stream];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.n_id count] > i) {
                NSNumber* obj = [self.n_id objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_getMessages
+(TLAPI_channels_getMessages*)createWithChannel:(TLInputChannel*)channel n_id:(NSMutableArray*)n_id {
    TLAPI_channels_getMessages* obj = [[TLAPI_channels_getMessages alloc] init];
    obj.channel = channel;
	obj.n_id = n_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1814580409];
	[ClassStore TLSerialize:self.channel stream:stream];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.n_id count] > i) {
                NSNumber* obj = [self.n_id objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_getParticipants
+(TLAPI_channels_getParticipants*)createWithChannel:(TLInputChannel*)channel filter:(TLChannelParticipantsFilter*)filter offset:(int)offset limit:(int)limit {
    TLAPI_channels_getParticipants* obj = [[TLAPI_channels_getParticipants alloc] init];
    obj.channel = channel;
	obj.filter = filter;
	obj.offset = offset;
	obj.limit = limit;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:618237842];
	[ClassStore TLSerialize:self.channel stream:stream];
	[ClassStore TLSerialize:self.filter stream:stream];
	[stream writeInt:self.offset];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_getParticipant
+(TLAPI_channels_getParticipant*)createWithChannel:(TLInputChannel*)channel user_id:(TLInputUser*)user_id {
    TLAPI_channels_getParticipant* obj = [[TLAPI_channels_getParticipant alloc] init];
    obj.channel = channel;
	obj.user_id = user_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1416484774];
	[ClassStore TLSerialize:self.channel stream:stream];
	[ClassStore TLSerialize:self.user_id stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_getChannels
+(TLAPI_channels_getChannels*)createWithN_id:(NSMutableArray*)n_id {
    TLAPI_channels_getChannels* obj = [[TLAPI_channels_getChannels alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:176122811];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLInputChannel* obj = [self.n_id objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_getFullChannel
+(TLAPI_channels_getFullChannel*)createWithChannel:(TLInputChannel*)channel {
    TLAPI_channels_getFullChannel* obj = [[TLAPI_channels_getFullChannel alloc] init];
    obj.channel = channel;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:141781513];
	[ClassStore TLSerialize:self.channel stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_createChannel
+(TLAPI_channels_createChannel*)createWithFlags:(int)flags   title:(NSString*)title about:(NSString*)about {
    TLAPI_channels_createChannel* obj = [[TLAPI_channels_createChannel alloc] init];
    obj.flags = flags;
	
	
	obj.title = title;
	obj.about = about;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-192332417];
	[stream writeInt:self.flags];
	
	
	[stream writeString:self.title];
	[stream writeString:self.about];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_editAbout
+(TLAPI_channels_editAbout*)createWithChannel:(TLInputChannel*)channel about:(NSString*)about {
    TLAPI_channels_editAbout* obj = [[TLAPI_channels_editAbout alloc] init];
    obj.channel = channel;
	obj.about = about;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:333610782];
	[ClassStore TLSerialize:self.channel stream:stream];
	[stream writeString:self.about];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_editAdmin
+(TLAPI_channels_editAdmin*)createWithChannel:(TLInputChannel*)channel user_id:(TLInputUser*)user_id role:(TLChannelParticipantRole*)role {
    TLAPI_channels_editAdmin* obj = [[TLAPI_channels_editAdmin alloc] init];
    obj.channel = channel;
	obj.user_id = user_id;
	obj.role = role;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-344583728];
	[ClassStore TLSerialize:self.channel stream:stream];
	[ClassStore TLSerialize:self.user_id stream:stream];
	[ClassStore TLSerialize:self.role stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_editTitle
+(TLAPI_channels_editTitle*)createWithChannel:(TLInputChannel*)channel title:(NSString*)title {
    TLAPI_channels_editTitle* obj = [[TLAPI_channels_editTitle alloc] init];
    obj.channel = channel;
	obj.title = title;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:1450044624];
	[ClassStore TLSerialize:self.channel stream:stream];
	[stream writeString:self.title];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_editPhoto
+(TLAPI_channels_editPhoto*)createWithChannel:(TLInputChannel*)channel photo:(TLInputChatPhoto*)photo {
    TLAPI_channels_editPhoto* obj = [[TLAPI_channels_editPhoto alloc] init];
    obj.channel = channel;
	obj.photo = photo;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-248621111];
	[ClassStore TLSerialize:self.channel stream:stream];
	[ClassStore TLSerialize:self.photo stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_toggleComments
+(TLAPI_channels_toggleComments*)createWithChannel:(TLInputChannel*)channel enabled:(Boolean)enabled {
    TLAPI_channels_toggleComments* obj = [[TLAPI_channels_toggleComments alloc] init];
    obj.channel = channel;
	obj.enabled = enabled;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1432183160];
	[ClassStore TLSerialize:self.channel stream:stream];
	[stream writeBool:self.enabled];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_checkUsername
+(TLAPI_channels_checkUsername*)createWithChannel:(TLInputChannel*)channel username:(NSString*)username {
    TLAPI_channels_checkUsername* obj = [[TLAPI_channels_checkUsername alloc] init];
    obj.channel = channel;
	obj.username = username;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:283557164];
	[ClassStore TLSerialize:self.channel stream:stream];
	[stream writeString:self.username];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_updateUsername
+(TLAPI_channels_updateUsername*)createWithChannel:(TLInputChannel*)channel username:(NSString*)username {
    TLAPI_channels_updateUsername* obj = [[TLAPI_channels_updateUsername alloc] init];
    obj.channel = channel;
	obj.username = username;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:890549214];
	[ClassStore TLSerialize:self.channel stream:stream];
	[stream writeString:self.username];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_joinChannel
+(TLAPI_channels_joinChannel*)createWithChannel:(TLInputChannel*)channel {
    TLAPI_channels_joinChannel* obj = [[TLAPI_channels_joinChannel alloc] init];
    obj.channel = channel;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:615851205];
	[ClassStore TLSerialize:self.channel stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_leaveChannel
+(TLAPI_channels_leaveChannel*)createWithChannel:(TLInputChannel*)channel {
    TLAPI_channels_leaveChannel* obj = [[TLAPI_channels_leaveChannel alloc] init];
    obj.channel = channel;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-130635115];
	[ClassStore TLSerialize:self.channel stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_inviteToChannel
+(TLAPI_channels_inviteToChannel*)createWithChannel:(TLInputChannel*)channel users:(NSMutableArray*)users {
    TLAPI_channels_inviteToChannel* obj = [[TLAPI_channels_inviteToChannel alloc] init];
    obj.channel = channel;
	obj.users = users;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:429865580];
	[ClassStore TLSerialize:self.channel stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLInputUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_kickFromChannel
+(TLAPI_channels_kickFromChannel*)createWithChannel:(TLInputChannel*)channel user_id:(TLInputUser*)user_id kicked:(Boolean)kicked {
    TLAPI_channels_kickFromChannel* obj = [[TLAPI_channels_kickFromChannel alloc] init];
    obj.channel = channel;
	obj.user_id = user_id;
	obj.kicked = kicked;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1502421484];
	[ClassStore TLSerialize:self.channel stream:stream];
	[ClassStore TLSerialize:self.user_id stream:stream];
	[stream writeBool:self.kicked];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_exportInvite
+(TLAPI_channels_exportInvite*)createWithChannel:(TLInputChannel*)channel {
    TLAPI_channels_exportInvite* obj = [[TLAPI_channels_exportInvite alloc] init];
    obj.channel = channel;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-950663035];
	[ClassStore TLSerialize:self.channel stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_channels_deleteChannel
+(TLAPI_channels_deleteChannel*)createWithChannel:(TLInputChannel*)channel {
    TLAPI_channels_deleteChannel* obj = [[TLAPI_channels_deleteChannel alloc] init];
    obj.channel = channel;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1072619549];
	[ClassStore TLSerialize:self.channel stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_updates_getChannelDifference
+(TLAPI_updates_getChannelDifference*)createWithChannel:(TLInputChannel*)channel filter:(TLChannelMessagesFilter*)filter pts:(int)pts limit:(int)limit {
    TLAPI_updates_getChannelDifference* obj = [[TLAPI_updates_getChannelDifference alloc] init];
    obj.channel = channel;
	obj.filter = filter;
	obj.pts = pts;
	obj.limit = limit;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1154295872];
	[ClassStore TLSerialize:self.channel stream:stream];
	[ClassStore TLSerialize:self.filter stream:stream];
	[stream writeInt:self.pts];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_toggleChatAdmins
+(TLAPI_messages_toggleChatAdmins*)createWithChat_id:(int)chat_id enabled:(Boolean)enabled {
    TLAPI_messages_toggleChatAdmins* obj = [[TLAPI_messages_toggleChatAdmins alloc] init];
    obj.chat_id = chat_id;
	obj.enabled = enabled;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-326379039];
	[stream writeInt:self.chat_id];
	[stream writeBool:self.enabled];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_editChatAdmin
+(TLAPI_messages_editChatAdmin*)createWithChat_id:(int)chat_id user_id:(TLInputUser*)user_id is_admin:(Boolean)is_admin {
    TLAPI_messages_editChatAdmin* obj = [[TLAPI_messages_editChatAdmin alloc] init];
    obj.chat_id = chat_id;
	obj.user_id = user_id;
	obj.is_admin = is_admin;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1444503762];
	[stream writeInt:self.chat_id];
	[ClassStore TLSerialize:self.user_id stream:stream];
	[stream writeBool:self.is_admin];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_migrateChat
+(TLAPI_messages_migrateChat*)createWithChat_id:(int)chat_id {
    TLAPI_messages_migrateChat* obj = [[TLAPI_messages_migrateChat alloc] init];
    obj.chat_id = chat_id;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:363051235];
	[stream writeInt:self.chat_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_searchGlobal
+(TLAPI_messages_searchGlobal*)createWithQ:(NSString*)q offset_date:(int)offset_date offset_peer:(TLInputPeer*)offset_peer offset_id:(int)offset_id limit:(int)limit {
    TLAPI_messages_searchGlobal* obj = [[TLAPI_messages_searchGlobal alloc] init];
    obj.q = q;
	obj.offset_date = offset_date;
	obj.offset_peer = offset_peer;
	obj.offset_id = offset_id;
	obj.limit = limit;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1640190800];
	[stream writeString:self.q];
	[stream writeInt:self.offset_date];
	[ClassStore TLSerialize:self.offset_peer stream:stream];
	[stream writeInt:self.offset_id];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_help_getTermsOfService
+(TLAPI_help_getTermsOfService*)createWithLang_code:(NSString*)lang_code {
    TLAPI_help_getTermsOfService* obj = [[TLAPI_help_getTermsOfService alloc] init];
    obj.lang_code = lang_code;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:936873859];
	[stream writeString:self.lang_code];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_reorderStickerSets
+(TLAPI_messages_reorderStickerSets*)createWithOrder:(NSMutableArray*)order {
    TLAPI_messages_reorderStickerSets* obj = [[TLAPI_messages_reorderStickerSets alloc] init];
    obj.order = order;
    return obj;
}
- (NSData*)getData {
	SerializedData* stream = [ClassStore streamWithConstuctor:-1613775824];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.order count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.order count] > i) {
                NSNumber* obj = [self.order objectAtIndex:i];
			[stream writeLong:[obj longValue]];
            }  else
                break;
		}
	}
	return [stream getOutput];
}
@end