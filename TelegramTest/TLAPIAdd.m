//
//  TLAPIAdd.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLAPIAdd.h"

@implementation TL_initConnection

- (NSData*)getData:(BOOL)isFirstRequest {
    SerializedData* stream = [[TLClassStore sharedManager] streamWithConstuctor:1769565673 isFirstRequest:isFirstRequest];
    
    [stream writeInt:API_ID];
    [stream writeString:self.device_model];
    [stream writeString:self.system_version];
    [stream writeString:self.app_version];
    [stream writeString:self.lang_code];
    
    [stream writeData:[self.query getData:NO]];
    
	return [stream getOutput];
}
@end


@implementation TL_invokeAfter


-(void)serialize:(SerializedData *)stream {
    [stream writeLong:self.msg_id];
    [stream writeData:[self.query getData:NO]];
}

-(void)unserialize:(SerializedData *)stream {
    self.msg_id = [stream readLong];
    self.query = [[TLClassStore sharedManager] TLDeserialize:stream];
}

@end


@implementation TL_sentAppCode
//auth.sentAppCode phone_registered:Bool phone_code_hash:string send_call_timeout:int is_password:Bool = auth.SentCode;
-(void)serialize:(SerializedData *)stream {
    [stream writeBool:self.phone_registered];
    [stream writeString:self.phone_code_hash];
    [stream writeInt:self.send_call_timeout];
    [stream writeBool:self.is_password];
}

-(void)unserialize:(SerializedData *)stream {
    self.phone_registered = [stream readBool];
    self.phone_code_hash = [stream readString];
    self.send_call_timeout = [stream readInt];
    self.is_password = [stream readBool];
}

@end


@implementation TLAPI_auth_sendSms

+ (TLAPI_auth_sendSms *)createWithPhoneNumber:(NSString *)phone_number phone_code_hash:(NSString *)phone_code_hash {
    TLAPI_auth_sendSms *object = [[TLAPI_auth_sendSms alloc] init];
    object.phone_number = phone_number;
    object.phone_code_hash = phone_code_hash;
    return object;
}

- (NSData *)getData:(BOOL)isFirstRequest {
    SerializedData* stream = [[TLClassStore sharedManager] streamWithConstuctor:0xda9f3e8 isFirstRequest:isFirstRequest];
    
    [stream writeString:self.phone_number];
    [stream writeString:self.phone_code_hash];
    
    return [stream getOutput];

}

@end


@implementation TLAPI_contactsExportCard

+ (TLAPI_contactsExportCard *)create {
    TLAPI_contactsExportCard *object = [[TLAPI_contactsExportCard alloc] init];
    
    return object;
}

-(NSData *)getData:(BOOL)isFirstRequest {
    return [[[TLClassStore sharedManager] streamWithConstuctor:0x84e53737 isFirstRequest:isFirstRequest] getOutput];
}


@end


@implementation TLAPI_contactsImportCard
+ (TLAPI_contactsImportCard *)createWithExportCard:(NSArray *)exportCard {
    TLAPI_contactsImportCard *object = [[TLAPI_contactsImportCard alloc] init];
    object.exportCard = exportCard;
    
    return object;
}


-(NSData *)getData:(BOOL)isFirstRequest {
    SerializedData *stream = [[TLClassStore sharedManager] streamWithConstuctor:0x4fe196fe isFirstRequest:isFirstRequest];
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.exportCard count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.exportCard objectAtIndex:i];
			[stream writeInt:[obj intValue]];
		}
	}
	return [stream getOutput];
}

@end



