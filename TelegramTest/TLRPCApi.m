//
//  TLRPCApi.m
//  Telegram
//
//  Auto created by Dmitry Kondratyev on 07.04.14..
//  Copyright (c) 2013 Telegram for OS X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLRPCApi.h"

@implementation TLAPI_auth_checkPhone
+ (TLAPI_auth_checkPhone *)createWithPhone_number:(NSString *)phone_number {
    TLAPI_auth_checkPhone *obj = [[TLAPI_auth_checkPhone alloc] init];
    obj.phone_number = phone_number;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1877286395 isFirstRequest:isFirstRequest];
	[stream writeString:self.phone_number];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_sendCode
+ (TLAPI_auth_sendCode *)createWithPhone_number:(NSString *)phone_number sms_type:(int)sms_type api_id:(int)api_id api_hash:(NSString *)api_hash lang_code:(NSString *)lang_code {
    TLAPI_auth_sendCode *obj = [[TLAPI_auth_sendCode alloc] init];
    obj.phone_number = phone_number;
	obj.sms_type = sms_type;
	obj.api_id = api_id;
	obj.api_hash = api_hash;
	obj.lang_code = lang_code;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1988976461 isFirstRequest:isFirstRequest];
	[stream writeString:self.phone_number];
	[stream writeInt:self.sms_type];
	[stream writeInt:self.api_id];
	[stream writeString:self.api_hash];
	[stream writeString:self.lang_code];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_sendCall
+ (TLAPI_auth_sendCall *)createWithPhone_number:(NSString *)phone_number phone_code_hash:(NSString *)phone_code_hash {
    TLAPI_auth_sendCall *obj = [[TLAPI_auth_sendCall alloc] init];
    obj.phone_number = phone_number;
	obj.phone_code_hash = phone_code_hash;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:63247716 isFirstRequest:isFirstRequest];
	[stream writeString:self.phone_number];
	[stream writeString:self.phone_code_hash];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_signUp
+ (TLAPI_auth_signUp *)createWithPhone_number:(NSString *)phone_number phone_code_hash:(NSString *)phone_code_hash phone_code:(NSString *)phone_code first_name:(NSString *)first_name last_name:(NSString *)last_name {
    TLAPI_auth_signUp *obj = [[TLAPI_auth_signUp alloc] init];
    obj.phone_number = phone_number;
	obj.phone_code_hash = phone_code_hash;
	obj.phone_code = phone_code;
	obj.first_name = first_name;
	obj.last_name = last_name;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:453408308 isFirstRequest:isFirstRequest];
	[stream writeString:self.phone_number];
	[stream writeString:self.phone_code_hash];
	[stream writeString:self.phone_code];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_signIn
+ (TLAPI_auth_signIn *)createWithPhone_number:(NSString *)phone_number phone_code_hash:(NSString *)phone_code_hash phone_code:(NSString *)phone_code {
    TLAPI_auth_signIn *obj = [[TLAPI_auth_signIn alloc] init];
    obj.phone_number = phone_number;
	obj.phone_code_hash = phone_code_hash;
	obj.phone_code = phone_code;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1126886015 isFirstRequest:isFirstRequest];
	[stream writeString:self.phone_number];
	[stream writeString:self.phone_code_hash];
	[stream writeString:self.phone_code];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_logOut
+ (TLAPI_auth_logOut *)create {
    TLAPI_auth_logOut *obj = [[TLAPI_auth_logOut alloc] init];
    
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1461180992 isFirstRequest:isFirstRequest];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_resetAuthorizations
+ (TLAPI_auth_resetAuthorizations *)create {
    TLAPI_auth_resetAuthorizations *obj = [[TLAPI_auth_resetAuthorizations alloc] init];
    
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1616179942 isFirstRequest:isFirstRequest];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_sendInvites
+ (TLAPI_auth_sendInvites *)createWithPhone_numbers:(NSMutableArray *)phone_numbers message:(NSString *)message {
    TLAPI_auth_sendInvites *obj = [[TLAPI_auth_sendInvites alloc] init];
    obj.phone_numbers = phone_numbers;
	obj.message = message;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1998331287 isFirstRequest:isFirstRequest];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.phone_numbers count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSString* obj = [self.phone_numbers objectAtIndex:i];
			[stream writeString:obj];
		}
	}
	[stream writeString:self.message];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_exportAuthorization
+ (TLAPI_auth_exportAuthorization *)createWithDc_id:(int)dc_id {
    TLAPI_auth_exportAuthorization *obj = [[TLAPI_auth_exportAuthorization alloc] init];
    obj.dc_id = dc_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-440401971 isFirstRequest:isFirstRequest];
	[stream writeInt:self.dc_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_auth_importAuthorization
+ (TLAPI_auth_importAuthorization *)createWithN_id:(int)n_id bytes:(NSData *)bytes {
    TLAPI_auth_importAuthorization *obj = [[TLAPI_auth_importAuthorization alloc] init];
    obj.n_id = n_id;
	obj.bytes = bytes;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-470837741 isFirstRequest:isFirstRequest];
	[stream writeInt:self.n_id];
	[stream writeByteArray:self.bytes];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_registerDevice
+ (TLAPI_account_registerDevice *)createWithToken_type:(int)token_type token:(NSString *)token device_model:(NSString *)device_model system_version:(NSString *)system_version app_version:(NSString *)app_version app_sandbox:(BOOL)app_sandbox lang_code:(NSString *)lang_code {
    TLAPI_account_registerDevice *obj = [[TLAPI_account_registerDevice alloc] init];
    obj.token_type = token_type;
	obj.token = token;
	obj.device_model = device_model;
	obj.system_version = system_version;
	obj.app_version = app_version;
	obj.app_sandbox = app_sandbox;
	obj.lang_code = lang_code;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1147957548 isFirstRequest:isFirstRequest];
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
+ (TLAPI_account_unregisterDevice *)createWithToken_type:(int)token_type token:(NSString *)token {
    TLAPI_account_unregisterDevice *obj = [[TLAPI_account_unregisterDevice alloc] init];
    obj.token_type = token_type;
	obj.token = token;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1707432768 isFirstRequest:isFirstRequest];
	[stream writeInt:self.token_type];
	[stream writeString:self.token];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_updateNotifySettings
+ (TLAPI_account_updateNotifySettings *)createWithPeer:(TGInputNotifyPeer *)peer settings:(TGInputPeerNotifySettings *)settings {
    TLAPI_account_updateNotifySettings *obj = [[TLAPI_account_updateNotifySettings alloc] init];
    obj.peer = peer;
	obj.settings = settings;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-2067899501 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.settings stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_getNotifySettings
+ (TLAPI_account_getNotifySettings *)createWithPeer:(TGInputNotifyPeer *)peer {
    TLAPI_account_getNotifySettings *obj = [[TLAPI_account_getNotifySettings alloc] init];
    obj.peer = peer;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:313765169 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_resetNotifySettings
+ (TLAPI_account_resetNotifySettings *)create {
    TLAPI_account_resetNotifySettings *obj = [[TLAPI_account_resetNotifySettings alloc] init];
    
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-612493497 isFirstRequest:isFirstRequest];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_account_updateProfile
+ (TLAPI_account_updateProfile *)createWithFirst_name:(NSString *)first_name last_name:(NSString *)last_name {
    TLAPI_account_updateProfile *obj = [[TLAPI_account_updateProfile alloc] init];
    obj.first_name = first_name;
	obj.last_name = last_name;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-259486360 isFirstRequest:isFirstRequest];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_updateStatus
+ (TLAPI_account_updateStatus *)createWithOffline:(BOOL)offline {
    TLAPI_account_updateStatus *obj = [[TLAPI_account_updateStatus alloc] init];
    obj.offline = offline;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1713919532 isFirstRequest:isFirstRequest];
	[stream writeBool:self.offline];
	return [stream getOutput];
}
@end

@implementation TLAPI_account_getWallPapers
+ (TLAPI_account_getWallPapers *)create {
    TLAPI_account_getWallPapers *obj = [[TLAPI_account_getWallPapers alloc] init];
    
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1068696894 isFirstRequest:isFirstRequest];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_users_getUsers
+ (TLAPI_users_getUsers *)createWithN_id:(NSMutableArray *)n_id {
    TLAPI_users_getUsers *obj = [[TLAPI_users_getUsers alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:227648840 isFirstRequest:isFirstRequest];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGInputUser* obj = [self.n_id objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_users_getFullUser
+ (TLAPI_users_getFullUser *)createWithN_id:(TGInputUser *)n_id {
    TLAPI_users_getFullUser *obj = [[TLAPI_users_getFullUser alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-902781519 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.n_id stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_getStatuses
+ (TLAPI_contacts_getStatuses *)create {
    TLAPI_contacts_getStatuses *obj = [[TLAPI_contacts_getStatuses alloc] init];
    
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-995929106 isFirstRequest:isFirstRequest];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_getContacts
+ (TLAPI_contacts_getContacts *)createWithHash:(NSString *)hash {
    TLAPI_contacts_getContacts *obj = [[TLAPI_contacts_getContacts alloc] init];
    obj.hash = hash;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:583445000 isFirstRequest:isFirstRequest];
	[stream writeString:self.hash];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_importContacts
+ (TLAPI_contacts_importContacts *)createWithContacts:(NSMutableArray *)contacts replace:(BOOL)replace {
    TLAPI_contacts_importContacts *obj = [[TLAPI_contacts_importContacts alloc] init];
    obj.contacts = contacts;
	obj.replace = replace;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-634342611 isFirstRequest:isFirstRequest];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.contacts count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGInputContact* obj = [self.contacts objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	[stream writeBool:self.replace];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_search
+ (TLAPI_contacts_search *)createWithQ:(NSString *)q limit:(int)limit {
    TLAPI_contacts_search *obj = [[TLAPI_contacts_search alloc] init];
    obj.q = q;
	obj.limit = limit;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:301470424 isFirstRequest:isFirstRequest];
	[stream writeString:self.q];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_getSuggested
+ (TLAPI_contacts_getSuggested *)createWithLimit:(int)limit {
    TLAPI_contacts_getSuggested *obj = [[TLAPI_contacts_getSuggested alloc] init];
    obj.limit = limit;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-847825880 isFirstRequest:isFirstRequest];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_deleteContact
+ (TLAPI_contacts_deleteContact *)createWithN_id:(TGInputUser *)n_id {
    TLAPI_contacts_deleteContact *obj = [[TLAPI_contacts_deleteContact alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1902823612 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.n_id stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_deleteContacts
+ (TLAPI_contacts_deleteContacts *)createWithN_id:(NSMutableArray *)n_id {
    TLAPI_contacts_deleteContacts *obj = [[TLAPI_contacts_deleteContacts alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1504393374 isFirstRequest:isFirstRequest];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGInputUser* obj = [self.n_id objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_block
+ (TLAPI_contacts_block *)createWithN_id:(TGInputUser *)n_id {
    TLAPI_contacts_block *obj = [[TLAPI_contacts_block alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:858475004 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.n_id stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_unblock
+ (TLAPI_contacts_unblock *)createWithN_id:(TGInputUser *)n_id {
    TLAPI_contacts_unblock *obj = [[TLAPI_contacts_unblock alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-448724803 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.n_id stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_contacts_getBlocked
+ (TLAPI_contacts_getBlocked *)createWithOffset:(int)offset limit:(int)limit {
    TLAPI_contacts_getBlocked *obj = [[TLAPI_contacts_getBlocked alloc] init];
    obj.offset = offset;
	obj.limit = limit;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-176409329 isFirstRequest:isFirstRequest];
	[stream writeInt:self.offset];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getMessages
+ (TLAPI_messages_getMessages *)createWithN_id:(NSMutableArray *)n_id {
    TLAPI_messages_getMessages *obj = [[TLAPI_messages_getMessages alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1109588596 isFirstRequest:isFirstRequest];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.n_id objectAtIndex:i];
			[stream writeInt:[obj intValue]];
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getDialogs
+ (TLAPI_messages_getDialogs *)createWithOffset:(int)offset max_id:(int)max_id limit:(int)limit {
    TLAPI_messages_getDialogs *obj = [[TLAPI_messages_getDialogs alloc] init];
    obj.offset = offset;
	obj.max_id = max_id;
	obj.limit = limit;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-321970698 isFirstRequest:isFirstRequest];
	[stream writeInt:self.offset];
	[stream writeInt:self.max_id];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getHistory
+ (TLAPI_messages_getHistory *)createWithPeer:(TGInputPeer *)peer offset:(int)offset max_id:(int)max_id limit:(int)limit {
    TLAPI_messages_getHistory *obj = [[TLAPI_messages_getHistory alloc] init];
    obj.peer = peer;
	obj.offset = offset;
	obj.max_id = max_id;
	obj.limit = limit;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1834885329 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeInt:self.offset];
	[stream writeInt:self.max_id];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_search
+ (TLAPI_messages_search *)createWithPeer:(TGInputPeer *)peer q:(NSString *)q filter:(TGMessagesFilter *)filter min_date:(int)min_date max_date:(int)max_date offset:(int)offset max_id:(int)max_id limit:(int)limit {
    TLAPI_messages_search *obj = [[TLAPI_messages_search alloc] init];
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
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:132772523 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeString:self.q];
	[[TLClassStore sharedManager] TLSerialize:self.filter stream:stream];
	[stream writeInt:self.min_date];
	[stream writeInt:self.max_date];
	[stream writeInt:self.offset];
	[stream writeInt:self.max_id];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_readHistory
+ (TLAPI_messages_readHistory *)createWithPeer:(TGInputPeer *)peer max_id:(int)max_id offset:(int)offset read_contents:(BOOL)read_contents {
    TLAPI_messages_readHistory *obj = [[TLAPI_messages_readHistory alloc] init];
    obj.peer = peer;
	obj.max_id = max_id;
	obj.offset = offset;
    obj.read_contents = read_contents;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:0xeed884c6 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeInt:self.max_id];
	[stream writeInt:self.offset];
    [stream writeBool:self.read_contents];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_deleteHistory
+ (TLAPI_messages_deleteHistory *)createWithPeer:(TGInputPeer *)peer offset:(int)offset {
    TLAPI_messages_deleteHistory *obj = [[TLAPI_messages_deleteHistory alloc] init];
    obj.peer = peer;
	obj.offset = offset;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-185009311 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeInt:self.offset];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_deleteMessages
+ (TLAPI_messages_deleteMessages *)createWithN_id:(NSMutableArray *)n_id {
    TLAPI_messages_deleteMessages *obj = [[TLAPI_messages_deleteMessages alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:351460618 isFirstRequest:isFirstRequest];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.n_id objectAtIndex:i];
			[stream writeInt:[obj intValue]];
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_restoreMessages
+ (TLAPI_messages_restoreMessages *)createWithN_id:(NSMutableArray *)n_id {
    TLAPI_messages_restoreMessages *obj = [[TLAPI_messages_restoreMessages alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:962567550 isFirstRequest:isFirstRequest];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.n_id objectAtIndex:i];
			[stream writeInt:[obj intValue]];
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_receivedMessages
+ (TLAPI_messages_receivedMessages *)createWithMax_id:(int)max_id {
    TLAPI_messages_receivedMessages *obj = [[TLAPI_messages_receivedMessages alloc] init];
    obj.max_id = max_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:682347368 isFirstRequest:isFirstRequest];
	[stream writeInt:self.max_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_setTyping
+ (TLAPI_messages_setTyping *)createWithPeer:(TGInputPeer *)peer action:(TL_SendMessageAction *)action {
    TLAPI_messages_setTyping *obj = [[TLAPI_messages_setTyping alloc] init];
    obj.peer = peer;
    obj.action = action;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:0xa3825e50 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
    [[TLClassStore sharedManager] TLSerialize:self.action stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_sendMessage
+ (TLAPI_messages_sendMessage *)createWithPeer:(TGInputPeer *)peer message:(NSString *)message random_id:(long)random_id {
    TLAPI_messages_sendMessage *obj = [[TLAPI_messages_sendMessage alloc] init];
    obj.peer = peer;
	obj.message = message;
	obj.random_id = random_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1289620139 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeString:self.message];
	[stream writeLong:self.random_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_sendMedia
+ (TLAPI_messages_sendMedia *)createWithPeer:(TGInputPeer *)peer media:(TGInputMedia *)media random_id:(long)random_id {
    TLAPI_messages_sendMedia *obj = [[TLAPI_messages_sendMedia alloc] init];
    obj.peer = peer;
	obj.media = media;
	obj.random_id = random_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1547149962 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.media stream:stream];
	[stream writeLong:self.random_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_forwardMessages
+ (TLAPI_messages_forwardMessages *)createWithPeer:(TGInputPeer *)peer n_id:(NSMutableArray *)n_id {
    TLAPI_messages_forwardMessages *obj = [[TLAPI_messages_forwardMessages alloc] init];
    obj.peer = peer;
	obj.n_id = n_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1363988751 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.n_id objectAtIndex:i];
			[stream writeInt:[obj intValue]];
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getChats
+ (TLAPI_messages_getChats *)createWithN_id:(NSMutableArray *)n_id {
    TLAPI_messages_getChats *obj = [[TLAPI_messages_getChats alloc] init];
    obj.n_id = n_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1013621127 isFirstRequest:isFirstRequest];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_id count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.n_id objectAtIndex:i];
			[stream writeInt:[obj intValue]];
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getFullChat
+ (TLAPI_messages_getFullChat *)createWithChat_id:(int)chat_id {
    TLAPI_messages_getFullChat *obj = [[TLAPI_messages_getFullChat alloc] init];
    obj.chat_id = chat_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:998448230 isFirstRequest:isFirstRequest];
	[stream writeInt:self.chat_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_editChatTitle
+ (TLAPI_messages_editChatTitle *)createWithChat_id:(int)chat_id title:(NSString *)title {
    TLAPI_messages_editChatTitle *obj = [[TLAPI_messages_editChatTitle alloc] init];
    obj.chat_id = chat_id;
	obj.title = title;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1262720843 isFirstRequest:isFirstRequest];
	[stream writeInt:self.chat_id];
	[stream writeString:self.title];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_editChatPhoto
+ (TLAPI_messages_editChatPhoto *)createWithChat_id:(int)chat_id photo:(TGInputChatPhoto *)photo {
    TLAPI_messages_editChatPhoto *obj = [[TLAPI_messages_editChatPhoto alloc] init];
    obj.chat_id = chat_id;
	obj.photo = photo;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-662601187 isFirstRequest:isFirstRequest];
	[stream writeInt:self.chat_id];
	[[TLClassStore sharedManager] TLSerialize:self.photo stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_addChatUser
+ (TLAPI_messages_addChatUser *)createWithChat_id:(int)chat_id user_id:(TGInputUser *)user_id fwd_limit:(int)fwd_limit {
    TLAPI_messages_addChatUser *obj = [[TLAPI_messages_addChatUser alloc] init];
    obj.chat_id = chat_id;
	obj.user_id = user_id;
	obj.fwd_limit = fwd_limit;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:787082910 isFirstRequest:isFirstRequest];
	[stream writeInt:self.chat_id];
	[[TLClassStore sharedManager] TLSerialize:self.user_id stream:stream];
	[stream writeInt:self.fwd_limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_deleteChatUser
+ (TLAPI_messages_deleteChatUser *)createWithChat_id:(int)chat_id user_id:(TGInputUser *)user_id {
    TLAPI_messages_deleteChatUser *obj = [[TLAPI_messages_deleteChatUser alloc] init];
    obj.chat_id = chat_id;
	obj.user_id = user_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1010447069 isFirstRequest:isFirstRequest];
	[stream writeInt:self.chat_id];
	[[TLClassStore sharedManager] TLSerialize:self.user_id stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_createChat
+ (TLAPI_messages_createChat *)createWithUsers:(NSMutableArray *)users title:(NSString *)title {
    TLAPI_messages_createChat *obj = [[TLAPI_messages_createChat alloc] init];
    obj.users = users;
	obj.title = title;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1100847854 isFirstRequest:isFirstRequest];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGInputUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	[stream writeString:self.title];
	return [stream getOutput];
}
@end

@implementation TLAPI_updates_getState
+ (TLAPI_updates_getState *)create {
    TLAPI_updates_getState *obj = [[TLAPI_updates_getState alloc] init];
    
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-304838614 isFirstRequest:isFirstRequest];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_updates_getDifference
+ (TLAPI_updates_getDifference *)createWithPts:(int)pts date:(int)date qts:(int)qts {
    TLAPI_updates_getDifference *obj = [[TLAPI_updates_getDifference alloc] init];
    obj.pts = pts;
	obj.date = date;
	obj.qts = qts;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:168039573 isFirstRequest:isFirstRequest];
	[stream writeInt:self.pts];
	[stream writeInt:self.date];
	[stream writeInt:self.qts];
	return [stream getOutput];
}
@end

@implementation TLAPI_photos_updateProfilePhoto
+ (TLAPI_photos_updateProfilePhoto *)createWithN_id:(TGInputPhoto *)n_id crop:(TGInputPhotoCrop *)crop {
    TLAPI_photos_updateProfilePhoto *obj = [[TLAPI_photos_updateProfilePhoto alloc] init];
    obj.n_id = n_id;
	obj.crop = crop;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-285902432 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.n_id stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.crop stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_photos_uploadProfilePhoto
+ (TLAPI_photos_uploadProfilePhoto *)createWithFile:(TGInputFile *)file caption:(NSString *)caption geo_point:(TGInputGeoPoint *)geo_point crop:(TGInputPhotoCrop *)crop {
    TLAPI_photos_uploadProfilePhoto *obj = [[TLAPI_photos_uploadProfilePhoto alloc] init];
    obj.file = file;
	obj.caption = caption;
	obj.geo_point = geo_point;
	obj.crop = crop;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-720397176 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.file stream:stream];
	[stream writeString:self.caption];
	[[TLClassStore sharedManager] TLSerialize:self.geo_point stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.crop stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_upload_saveFilePart
+ (TLAPI_upload_saveFilePart *)createWithFile_id:(long)file_id file_part:(int)file_part bytes:(NSData *)bytes {
    TLAPI_upload_saveFilePart *obj = [[TLAPI_upload_saveFilePart alloc] init];
    obj.file_id = file_id;
	obj.file_part = file_part;
	obj.bytes = bytes;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1291540959 isFirstRequest:isFirstRequest];
	[stream writeLong:self.file_id];
	[stream writeInt:self.file_part];
	[stream writeByteArray:self.bytes];
	return [stream getOutput];
}
@end

@implementation TLAPI_upload_getFile
+ (TLAPI_upload_getFile *)createWithLocation:(TGInputFileLocation *)location offset:(int)offset limit:(int)limit {
    TLAPI_upload_getFile *obj = [[TLAPI_upload_getFile alloc] init];
    obj.location = location;
	obj.offset = offset;
	obj.limit = limit;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-475607115 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.location stream:stream];
	[stream writeInt:self.offset];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_help_getConfig
+ (TLAPI_help_getConfig *)create {
    TLAPI_help_getConfig *obj = [[TLAPI_help_getConfig alloc] init];
    
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-990308245 isFirstRequest:isFirstRequest];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_help_getNearestDc
+ (TLAPI_help_getNearestDc *)create {
    TLAPI_help_getNearestDc *obj = [[TLAPI_help_getNearestDc alloc] init];
    
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:531836966 isFirstRequest:isFirstRequest];
	
	return [stream getOutput];
}
@end

@implementation TLAPI_help_getAppUpdate
+ (TLAPI_help_getAppUpdate *)createWithDevice_model:(NSString *)device_model system_version:(NSString *)system_version app_version:(NSString *)app_version lang_code:(NSString *)lang_code {
    TLAPI_help_getAppUpdate *obj = [[TLAPI_help_getAppUpdate alloc] init];
    obj.device_model = device_model;
	obj.system_version = system_version;
	obj.app_version = app_version;
	obj.lang_code = lang_code;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-938300290 isFirstRequest:isFirstRequest];
	[stream writeString:self.device_model];
	[stream writeString:self.system_version];
	[stream writeString:self.app_version];
	[stream writeString:self.lang_code];
	return [stream getOutput];
}
@end

@implementation TLAPI_help_saveAppLog
+ (TLAPI_help_saveAppLog *)createWithEvents:(NSMutableArray *)events {
    TLAPI_help_saveAppLog *obj = [[TLAPI_help_saveAppLog alloc] init];
    obj.events = events;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1862465352 isFirstRequest:isFirstRequest];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.events count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGInputAppEvent* obj = [self.events objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	return [stream getOutput];
}
@end

@implementation TLAPI_help_getInviteText
+ (TLAPI_help_getInviteText *)createWithLang_code:(NSString *)lang_code {
    TLAPI_help_getInviteText *obj = [[TLAPI_help_getInviteText alloc] init];
    obj.lang_code = lang_code;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1532407418 isFirstRequest:isFirstRequest];
	[stream writeString:self.lang_code];
	return [stream getOutput];
}
@end

@implementation TLAPI_photos_getUserPhotos
+ (TLAPI_photos_getUserPhotos *)createWithUser_id:(TGInputUser *)user_id offset:(int)offset max_id:(int)max_id limit:(int)limit {
    TLAPI_photos_getUserPhotos *obj = [[TLAPI_photos_getUserPhotos alloc] init];
    obj.user_id = user_id;
	obj.offset = offset;
	obj.max_id = max_id;
	obj.limit = limit;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1209117380 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.user_id stream:stream];
	[stream writeInt:self.offset];
	[stream writeInt:self.max_id];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_forwardMessage
+ (TLAPI_messages_forwardMessage *)createWithPeer:(TGInputPeer *)peer n_id:(int)n_id random_id:(long)random_id {
    TLAPI_messages_forwardMessage *obj = [[TLAPI_messages_forwardMessage alloc] init];
    obj.peer = peer;
	obj.n_id = n_id;
	obj.random_id = random_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:66319602 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeInt:self.n_id];
	[stream writeLong:self.random_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_sendBroadcast
+ (TLAPI_messages_sendBroadcast *)createWithContacts:(NSMutableArray *)contacts message:(NSString *)message media:(TGInputMedia *)media {
    TLAPI_messages_sendBroadcast *obj = [[TLAPI_messages_sendBroadcast alloc] init];
    obj.contacts = contacts;
	obj.message = message;
	obj.media = media;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1102776690 isFirstRequest:isFirstRequest];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.contacts count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGInputUser* obj = [self.contacts objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	[stream writeString:self.message];
	[[TLClassStore sharedManager] TLSerialize:self.media stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_geochats_getLocated
+ (TLAPI_geochats_getLocated *)createWithGeo_point:(TGInputGeoPoint *)geo_point radius:(int)radius limit:(int)limit {
    TLAPI_geochats_getLocated *obj = [[TLAPI_geochats_getLocated alloc] init];
    obj.geo_point = geo_point;
	obj.radius = radius;
	obj.limit = limit;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:2132356495 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.geo_point stream:stream];
	[stream writeInt:self.radius];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_geochats_getRecents
+ (TLAPI_geochats_getRecents *)createWithOffset:(int)offset limit:(int)limit {
    TLAPI_geochats_getRecents *obj = [[TLAPI_geochats_getRecents alloc] init];
    obj.offset = offset;
	obj.limit = limit;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-515735953 isFirstRequest:isFirstRequest];
	[stream writeInt:self.offset];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_geochats_checkin
+ (TLAPI_geochats_checkin *)createWithPeer:(TGInputGeoChat *)peer {
    TLAPI_geochats_checkin *obj = [[TLAPI_geochats_checkin alloc] init];
    obj.peer = peer;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1437853947 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_geochats_getFullChat
+ (TLAPI_geochats_getFullChat *)createWithPeer:(TGInputGeoChat *)peer {
    TLAPI_geochats_getFullChat *obj = [[TLAPI_geochats_getFullChat alloc] init];
    obj.peer = peer;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1730338159 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_geochats_editChatTitle
+ (TLAPI_geochats_editChatTitle *)createWithPeer:(TGInputGeoChat *)peer title:(NSString *)title address:(NSString *)address {
    TLAPI_geochats_editChatTitle *obj = [[TLAPI_geochats_editChatTitle alloc] init];
    obj.peer = peer;
	obj.title = title;
	obj.address = address;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1284383347 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeString:self.title];
	[stream writeString:self.address];
	return [stream getOutput];
}
@end

@implementation TLAPI_geochats_editChatPhoto
+ (TLAPI_geochats_editChatPhoto *)createWithPeer:(TGInputGeoChat *)peer photo:(TGInputChatPhoto *)photo {
    TLAPI_geochats_editChatPhoto *obj = [[TLAPI_geochats_editChatPhoto alloc] init];
    obj.peer = peer;
	obj.photo = photo;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:903355029 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.photo stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_geochats_search
+ (TLAPI_geochats_search *)createWithPeer:(TGInputGeoChat *)peer q:(NSString *)q filter:(TGMessagesFilter *)filter min_date:(int)min_date max_date:(int)max_date offset:(int)offset max_id:(int)max_id limit:(int)limit {
    TLAPI_geochats_search *obj = [[TLAPI_geochats_search alloc] init];
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
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-808598451 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeString:self.q];
	[[TLClassStore sharedManager] TLSerialize:self.filter stream:stream];
	[stream writeInt:self.min_date];
	[stream writeInt:self.max_date];
	[stream writeInt:self.offset];
	[stream writeInt:self.max_id];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_geochats_getHistory
+ (TLAPI_geochats_getHistory *)createWithPeer:(TGInputGeoChat *)peer offset:(int)offset max_id:(int)max_id limit:(int)limit {
    TLAPI_geochats_getHistory *obj = [[TLAPI_geochats_getHistory alloc] init];
    obj.peer = peer;
	obj.offset = offset;
	obj.max_id = max_id;
	obj.limit = limit;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1254131096 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeInt:self.offset];
	[stream writeInt:self.max_id];
	[stream writeInt:self.limit];
	return [stream getOutput];
}
@end

@implementation TLAPI_geochats_setTyping
+ (TLAPI_geochats_setTyping *)createWithPeer:(TGInputGeoChat *)peer typing:(BOOL)typing {
    TLAPI_geochats_setTyping *obj = [[TLAPI_geochats_setTyping alloc] init];
    obj.peer = peer;
	obj.typing = typing;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:146319145 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeBool:self.typing];
	return [stream getOutput];
}
@end

@implementation TLAPI_geochats_sendMessage
+ (TLAPI_geochats_sendMessage *)createWithPeer:(TGInputGeoChat *)peer message:(NSString *)message random_id:(long)random_id {
    TLAPI_geochats_sendMessage *obj = [[TLAPI_geochats_sendMessage alloc] init];
    obj.peer = peer;
	obj.message = message;
	obj.random_id = random_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:102432836 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeString:self.message];
	[stream writeLong:self.random_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_geochats_sendMedia
+ (TLAPI_geochats_sendMedia *)createWithPeer:(TGInputGeoChat *)peer media:(TGInputMedia *)media random_id:(long)random_id {
    TLAPI_geochats_sendMedia *obj = [[TLAPI_geochats_sendMedia alloc] init];
    obj.peer = peer;
	obj.media = media;
	obj.random_id = random_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1192173825 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.media stream:stream];
	[stream writeLong:self.random_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_geochats_createGeoChat
+ (TLAPI_geochats_createGeoChat *)createWithTitle:(NSString *)title geo_point:(TGInputGeoPoint *)geo_point address:(NSString *)address venue:(NSString *)venue {
    TLAPI_geochats_createGeoChat *obj = [[TLAPI_geochats_createGeoChat alloc] init];
    obj.title = title;
	obj.geo_point = geo_point;
	obj.address = address;
	obj.venue = venue;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:235482646 isFirstRequest:isFirstRequest];
	[stream writeString:self.title];
	[[TLClassStore sharedManager] TLSerialize:self.geo_point stream:stream];
	[stream writeString:self.address];
	[stream writeString:self.venue];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_getDhConfig
+ (TLAPI_messages_getDhConfig *)createWithVersion:(int)version random_length:(int)random_length {
    TLAPI_messages_getDhConfig *obj = [[TLAPI_messages_getDhConfig alloc] init];
    obj.version = version;
	obj.random_length = random_length;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:651135312 isFirstRequest:isFirstRequest];
	[stream writeInt:self.version];
	[stream writeInt:self.random_length];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_requestEncryption
+ (TLAPI_messages_requestEncryption *)createWithUser_id:(TGInputUser *)user_id random_id:(int)random_id g_a:(NSData *)g_a {
    TLAPI_messages_requestEncryption *obj = [[TLAPI_messages_requestEncryption alloc] init];
    obj.user_id = user_id;
	obj.random_id = random_id;
	obj.g_a = g_a;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-162681021 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.user_id stream:stream];
	[stream writeInt:self.random_id];
	[stream writeByteArray:self.g_a];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_acceptEncryption
+ (TLAPI_messages_acceptEncryption *)createWithPeer:(TGInputEncryptedChat *)peer g_b:(NSData *)g_b key_fingerprint:(long)key_fingerprint {
    TLAPI_messages_acceptEncryption *obj = [[TLAPI_messages_acceptEncryption alloc] init];
    obj.peer = peer;
	obj.g_b = g_b;
	obj.key_fingerprint = key_fingerprint;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1035731989 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeByteArray:self.g_b];
	[stream writeLong:self.key_fingerprint];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_discardEncryption
+ (TLAPI_messages_discardEncryption *)createWithChat_id:(int)chat_id {
    TLAPI_messages_discardEncryption *obj = [[TLAPI_messages_discardEncryption alloc] init];
    obj.chat_id = chat_id;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-304536635 isFirstRequest:isFirstRequest];
	[stream writeInt:self.chat_id];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_setEncryptedTyping
+ (TLAPI_messages_setEncryptedTyping *)createWithPeer:(TGInputEncryptedChat *)peer typing:(BOOL)typing {
    TLAPI_messages_setEncryptedTyping *obj = [[TLAPI_messages_setEncryptedTyping alloc] init];
    obj.peer = peer;
	obj.typing = typing;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:2031374829 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeBool:self.typing];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_readEncryptedHistory
+ (TLAPI_messages_readEncryptedHistory *)createWithPeer:(TGInputEncryptedChat *)peer max_date:(int)max_date {
    TLAPI_messages_readEncryptedHistory *obj = [[TLAPI_messages_readEncryptedHistory alloc] init];
    obj.peer = peer;
	obj.max_date = max_date;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:2135648522 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeInt:self.max_date];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_sendEncrypted
+ (TLAPI_messages_sendEncrypted *)createWithPeer:(TGInputEncryptedChat *)peer random_id:(long)random_id data:(NSData *)data {
    TLAPI_messages_sendEncrypted *obj = [[TLAPI_messages_sendEncrypted alloc] init];
    obj.peer = peer;
	obj.random_id = random_id;
	obj.data = data;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1451792525 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeLong:self.random_id];
	[stream writeByteArray:self.data];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_sendEncryptedFile
+ (TLAPI_messages_sendEncryptedFile *)createWithPeer:(TGInputEncryptedChat *)peer random_id:(long)random_id data:(NSData *)data file:(TGInputEncryptedFile *)file {
    TLAPI_messages_sendEncryptedFile *obj = [[TLAPI_messages_sendEncryptedFile alloc] init];
    obj.peer = peer;
	obj.random_id = random_id;
	obj.data = data;
	obj.file = file;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1701831834 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeLong:self.random_id];
	[stream writeByteArray:self.data];
	[[TLClassStore sharedManager] TLSerialize:self.file stream:stream];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_sendEncryptedService
+ (TLAPI_messages_sendEncryptedService *)createWithPeer:(TGInputEncryptedChat *)peer random_id:(long)random_id data:(NSData *)data {
    TLAPI_messages_sendEncryptedService *obj = [[TLAPI_messages_sendEncryptedService alloc] init];
    obj.peer = peer;
	obj.random_id = random_id;
	obj.data = data;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:852769188 isFirstRequest:isFirstRequest];
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeLong:self.random_id];
	[stream writeByteArray:self.data];
	return [stream getOutput];
}
@end

@implementation TLAPI_messages_receivedQueue
+ (TLAPI_messages_receivedQueue *)createWithMax_qts:(int)max_qts {
    TLAPI_messages_receivedQueue *obj = [[TLAPI_messages_receivedQueue alloc] init];
    obj.max_qts = max_qts;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:1436924774 isFirstRequest:isFirstRequest];
	[stream writeInt:self.max_qts];
	return [stream getOutput];
}
@end

@implementation TLAPI_upload_saveBigFilePart
+ (TLAPI_upload_saveBigFilePart *)createWithFile_id:(long)file_id file_part:(int)file_part file_total_parts:(int)file_total_parts bytes:(NSData *)bytes {
    TLAPI_upload_saveBigFilePart *obj = [[TLAPI_upload_saveBigFilePart alloc] init];
    obj.file_id = file_id;
	obj.file_part = file_part;
	obj.file_total_parts = file_total_parts;
	obj.bytes = bytes;
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-562337987 isFirstRequest:isFirstRequest];
	[stream writeLong:self.file_id];
	[stream writeInt:self.file_part];
	[stream writeInt:self.file_total_parts];
	[stream writeByteArray:self.bytes];
	return [stream getOutput];
}
@end

@implementation TLAPI_help_getSupport
+ (TLAPI_help_getSupport *)create {
    TLAPI_help_getSupport *obj = [[TLAPI_help_getSupport alloc] init];
    
    return obj;
}
- (NSData *)getData:(BOOL)isFirstRequest {
	SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:-1663104819 isFirstRequest:isFirstRequest];
	
	return [stream getOutput];
}
@end