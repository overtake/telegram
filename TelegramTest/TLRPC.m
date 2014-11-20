//
//  TLRPC.m
//  Telegram
//
//  Auto created by Dmitry Kondratyev on 07.04.14.
//  Copyright (c) 2013 Telegram for OS X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLRPC.h"
#import "TLClassStore.h"

@implementation TL_boolFalse
+ (TL_boolFalse *)create {
	TL_boolFalse* obj = [[TL_boolFalse alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData*)stream {
	// [stream writeInt:[[self class] constructor]];
}
- (void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_boolTrue
+ (TL_boolTrue *)create {
	TL_boolTrue *obj = [[TL_boolTrue alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	// [stream writeInt:[[self class] constructor]];
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_ping_delay_disconnect
+ (TL_ping_delay_disconnect *)createWithPing_id:(long)ping_id delay_disconnect:(int)delay_disconnect {
	TL_ping_delay_disconnect *obj = [[TL_ping_delay_disconnect alloc] init];
	obj.ping_id = ping_id;
    obj.delay_disconnect = delay_disconnect;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	// [stream writeInt:[[self class] constructor]];
    
	[stream writeLong:self.ping_id];
    [stream writeInt:self.delay_disconnect];
}
- (void)unserialize:(SerializedData *)stream {
	self.ping_id = [stream readLong];
}
@end




@implementation TGDecryptedMessageMedia
@end

@implementation TL_decryptedMessageMediaAudio_12
+ (TL_decryptedMessageMediaAudio_12 *)createWithDuration:(int)duration size:(int)size key:(NSData *)key iv:(NSData *)iv {
	TL_decryptedMessageMediaAudio_12 *obj = [[TL_decryptedMessageMediaAudio_12 alloc] init];
	obj.duration = duration;
	obj.size = size;
	obj.key = key;
	obj.iv = iv;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.duration];
	[stream writeInt:self.size];
	[stream writeByteArray:self.key];
	[stream writeByteArray:self.iv];
}
- (void)unserialize:(SerializedData *)stream {
	self.duration = [stream readInt];
	self.size = [stream readInt];
	self.key = [stream readByteArray];
	self.iv = [stream readByteArray];
}
@end

@implementation TL_decryptedMessageMediaVideo_12
+ (TL_decryptedMessageMediaVideo_12 *)createWithThumb:(NSData *)thumb thumb_w:(int)thumb_w thumb_h:(int)thumb_h duration:(int)duration w:(int)w h:(int)h size:(int)size key:(NSData *)key iv:(NSData *)iv {
	TL_decryptedMessageMediaVideo_12 *obj = [[TL_decryptedMessageMediaVideo_12 alloc] init];
	obj.thumb = thumb;
	obj.thumb_w = thumb_w;
	obj.thumb_h = thumb_h;
	obj.duration = duration;
	obj.w = w;
	obj.h = h;
	obj.size = size;
	obj.key = key;
	obj.iv = iv;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeByteArray:self.thumb];
	[stream writeInt:self.thumb_w];
	[stream writeInt:self.thumb_h];
	[stream writeInt:self.duration];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeInt:self.size];
	[stream writeByteArray:self.key];
	[stream writeByteArray:self.iv];
}
- (void)unserialize:(SerializedData *)stream {
	self.thumb = [stream readByteArray];
	self.thumb_w = [stream readInt];
	self.thumb_h = [stream readInt];
	self.duration = [stream readInt];
	self.w = [stream readInt];
	self.h = [stream readInt];
	self.size = [stream readInt];
	self.key = [stream readByteArray];
	self.iv = [stream readByteArray];
}
@end

@implementation TL_decryptedMessageMediaEmpty
+ (TL_decryptedMessageMediaEmpty *)create {
	TL_decryptedMessageMediaEmpty *obj = [[TL_decryptedMessageMediaEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_decryptedMessageMediaPhoto
+ (TL_decryptedMessageMediaPhoto *)createWithThumb:(NSData *)thumb thumb_w:(int)thumb_w thumb_h:(int)thumb_h w:(int)w h:(int)h size:(int)size key:(NSData *)key iv:(NSData *)iv {
	TL_decryptedMessageMediaPhoto *obj = [[TL_decryptedMessageMediaPhoto alloc] init];
	obj.thumb = thumb;
	obj.thumb_w = thumb_w;
	obj.thumb_h = thumb_h;
	obj.w = w;
	obj.h = h;
	obj.size = size;
	obj.key = key;
	obj.iv = iv;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeByteArray:self.thumb];
	[stream writeInt:self.thumb_w];
	[stream writeInt:self.thumb_h];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeInt:self.size];
	[stream writeByteArray:self.key];
	[stream writeByteArray:self.iv];
}
- (void)unserialize:(SerializedData *)stream {
	self.thumb = [stream readByteArray];
	self.thumb_w = [stream readInt];
	self.thumb_h = [stream readInt];
	self.w = [stream readInt];
	self.h = [stream readInt];
	self.size = [stream readInt];
	self.key = [stream readByteArray];
	self.iv = [stream readByteArray];
}
@end

@implementation TL_decryptedMessageMediaVideo
+ (TL_decryptedMessageMediaVideo *)createWithThumb:(NSData *)thumb thumb_w:(int)thumb_w thumb_h:(int)thumb_h duration:(int)duration mime_type:(NSString *)mime_type w:(int)w h:(int)h size:(int)size key:(NSData *)key iv:(NSData *)iv {
	TL_decryptedMessageMediaVideo *obj = [[TL_decryptedMessageMediaVideo alloc] init];
	obj.thumb = thumb;
	obj.thumb_w = thumb_w;
	obj.thumb_h = thumb_h;
	obj.duration = duration;
	obj.mime_type = mime_type;
	obj.w = w;
	obj.h = h;
	obj.size = size;
	obj.key = key;
	obj.iv = iv;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeByteArray:self.thumb];
	[stream writeInt:self.thumb_w];
	[stream writeInt:self.thumb_h];
	[stream writeInt:self.duration];
	[stream writeString:self.mime_type];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeInt:self.size];
	[stream writeByteArray:self.key];
	[stream writeByteArray:self.iv];
}
- (void)unserialize:(SerializedData *)stream {
	self.thumb = [stream readByteArray];
	self.thumb_w = [stream readInt];
	self.thumb_h = [stream readInt];
	self.duration = [stream readInt];
	self.mime_type = [stream readString];
	self.w = [stream readInt];
	self.h = [stream readInt];
	self.size = [stream readInt];
	self.key = [stream readByteArray];
	self.iv = [stream readByteArray];
}
@end

@implementation TL_decryptedMessageMediaGeoPoint
+ (TL_decryptedMessageMediaGeoPoint *)createWithLat:(double)lat n_long:(double)n_long {
	TL_decryptedMessageMediaGeoPoint *obj = [[TL_decryptedMessageMediaGeoPoint alloc] init];
	obj.lat = lat;
	obj.n_long = n_long;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeDouble:self.lat];
	[stream writeDouble:self.n_long];
}
- (void)unserialize:(SerializedData *)stream {
	self.lat = [stream readDouble];
	self.n_long = [stream readDouble];
}
@end

@implementation TL_decryptedMessageMediaContact
+ (TL_decryptedMessageMediaContact *)createWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(int)user_id {
	TL_decryptedMessageMediaContact *obj = [[TL_decryptedMessageMediaContact alloc] init];
	obj.phone_number = phone_number;
	obj.first_name = first_name;
	obj.last_name = last_name;
	obj.user_id = user_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeString:self.phone_number];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
	[stream writeInt:self.user_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.phone_number = [stream readString];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
	self.user_id = [stream readInt];
}
@end

@implementation TL_decryptedMessageMediaDocument
+ (TL_decryptedMessageMediaDocument *)createWithThumb:(NSData *)thumb thumb_w:(int)thumb_w thumb_h:(int)thumb_h file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(int)size key:(NSData *)key iv:(NSData *)iv {
	TL_decryptedMessageMediaDocument *obj = [[TL_decryptedMessageMediaDocument alloc] init];
	obj.thumb = thumb;
	obj.thumb_w = thumb_w;
	obj.thumb_h = thumb_h;
	obj.file_name = file_name;
	obj.mime_type = mime_type;
	obj.size = size;
	obj.key = key;
	obj.iv = iv;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeByteArray:self.thumb];
	[stream writeInt:self.thumb_w];
	[stream writeInt:self.thumb_h];
	[stream writeString:self.file_name];
	[stream writeString:self.mime_type];
	[stream writeInt:self.size];
	[stream writeByteArray:self.key];
	[stream writeByteArray:self.iv];
}
- (void)unserialize:(SerializedData *)stream {
	self.thumb = [stream readByteArray];
	self.thumb_w = [stream readInt];
	self.thumb_h = [stream readInt];
	self.file_name = [stream readString];
	self.mime_type = [stream readString];
	self.size = [stream readInt];
	self.key = [stream readByteArray];
	self.iv = [stream readByteArray];
}
@end

@implementation TL_decryptedMessageMediaAudio
+ (TL_decryptedMessageMediaAudio *)createWithDuration:(int)duration mime_type:(NSString *)mime_type size:(int)size key:(NSData *)key iv:(NSData *)iv {
	TL_decryptedMessageMediaAudio *obj = [[TL_decryptedMessageMediaAudio alloc] init];
	obj.duration = duration;
	obj.mime_type = mime_type;
	obj.size = size;
	obj.key = key;
	obj.iv = iv;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.duration];
	[stream writeString:self.mime_type];
	[stream writeInt:self.size];
	[stream writeByteArray:self.key];
	[stream writeByteArray:self.iv];
}
- (void)unserialize:(SerializedData *)stream {
	self.duration = [stream readInt];
	self.mime_type = [stream readString];
	self.size = [stream readInt];
	self.key = [stream readByteArray];
	self.iv = [stream readByteArray];
}
@end



@implementation TGInputPeer
@end

@implementation TL_inputPeerEmpty
+ (TL_inputPeerEmpty *)create {
	TL_inputPeerEmpty *obj = [[TL_inputPeerEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputPeerSelf
+ (TL_inputPeerSelf *)create {
	TL_inputPeerSelf *obj = [[TL_inputPeerSelf alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputPeerContact
+ (TL_inputPeerContact *)createWithUser_id:(int)user_id {
	TL_inputPeerContact *obj = [[TL_inputPeerContact alloc] init];
	obj.user_id = user_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
}
@end

@implementation TL_inputPeerForeign
+ (TL_inputPeerForeign *)createWithUser_id:(int)user_id access_hash:(long)access_hash {
	TL_inputPeerForeign *obj = [[TL_inputPeerForeign alloc] init];
	obj.user_id = user_id;
	obj.access_hash = access_hash;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
	[stream writeLong:self.access_hash];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
	self.access_hash = [stream readLong];
}
@end

@implementation TL_inputPeerChat
+ (TL_inputPeerChat *)createWithChat_id:(int)chat_id {
	TL_inputPeerChat *obj = [[TL_inputPeerChat alloc] init];
	obj.chat_id = chat_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.chat_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat_id = [stream readInt];
}
@end



@implementation TGInputUser
@end

@implementation TL_inputUserEmpty
+ (TL_inputUserEmpty *)create {
	TL_inputUserEmpty *obj = [[TL_inputUserEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputUserSelf
+ (TL_inputUserSelf *)create {
	TL_inputUserSelf *obj = [[TL_inputUserSelf alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputUserContact
+ (TL_inputUserContact *)createWithUser_id:(int)user_id {
	TL_inputUserContact *obj = [[TL_inputUserContact alloc] init];
	obj.user_id = user_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
}
@end

@implementation TL_inputUserForeign
+ (TL_inputUserForeign *)createWithUser_id:(int)user_id access_hash:(long)access_hash {
	TL_inputUserForeign *obj = [[TL_inputUserForeign alloc] init];
	obj.user_id = user_id;
	obj.access_hash = access_hash;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
	[stream writeLong:self.access_hash];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
	self.access_hash = [stream readLong];
}
@end



@implementation TGInputContact
@end

@implementation TL_inputPhoneContact
+ (TL_inputPhoneContact *)createWithClient_id:(long)client_id phone:(NSString *)phone first_name:(NSString *)first_name last_name:(NSString *)last_name {
	TL_inputPhoneContact *obj = [[TL_inputPhoneContact alloc] init];
	obj.client_id = client_id;
	obj.phone = phone;
	obj.first_name = first_name;
	obj.last_name = last_name;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.client_id];
	[stream writeString:self.phone];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
}
- (void)unserialize:(SerializedData *)stream {
	self.client_id = [stream readLong];
	self.phone = [stream readString];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
}
@end



@implementation TGInputFile
@end

@implementation TL_inputFile
+ (TL_inputFile *)createWithN_id:(long)n_id parts:(int)parts name:(NSString *)name md5_checksum:(NSString *)md5_checksum {
	TL_inputFile *obj = [[TL_inputFile alloc] init];
	obj.n_id = n_id;
	obj.parts = parts;
	obj.name = name;
	obj.md5_checksum = md5_checksum;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeInt:self.parts];
	[stream writeString:self.name];
	[stream writeString:self.md5_checksum];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.parts = [stream readInt];
	self.name = [stream readString];
	self.md5_checksum = [stream readString];
}
@end

@implementation TL_inputFileBig
+ (TL_inputFileBig *)createWithN_id:(long)n_id parts:(int)parts name:(NSString *)name {
	TL_inputFileBig *obj = [[TL_inputFileBig alloc] init];
	obj.n_id = n_id;
	obj.parts = parts;
	obj.name = name;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeInt:self.parts];
	[stream writeString:self.name];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.parts = [stream readInt];
	self.name = [stream readString];
}
@end



@implementation TGInputMedia
@end

@implementation TL_inputMediaEmpty
+ (TL_inputMediaEmpty *)create {
	TL_inputMediaEmpty *obj = [[TL_inputMediaEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputMediaUploadedPhoto
+ (TL_inputMediaUploadedPhoto *)createWithFile:(TGInputFile *)file {
	TL_inputMediaUploadedPhoto *obj = [[TL_inputMediaUploadedPhoto alloc] init];
	obj.file = file;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.file stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.file = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_inputMediaPhoto
+ (TL_inputMediaPhoto *)createWithPhoto_id:(TGInputPhoto *)photo_id {
	TL_inputMediaPhoto *obj = [[TL_inputMediaPhoto alloc] init];
	obj.photo_id = photo_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.photo_id stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.photo_id = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_inputMediaGeoPoint
+ (TL_inputMediaGeoPoint *)createWithGeo_point:(TGInputGeoPoint *)geo_point {
	TL_inputMediaGeoPoint *obj = [[TL_inputMediaGeoPoint alloc] init];
	obj.geo_point = geo_point;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.geo_point stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.geo_point = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_inputMediaContact
+ (TL_inputMediaContact *)createWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name {
	TL_inputMediaContact *obj = [[TL_inputMediaContact alloc] init];
	obj.phone_number = phone_number;
	obj.first_name = first_name;
	obj.last_name = last_name;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeString:self.phone_number];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
}
- (void)unserialize:(SerializedData *)stream {
	self.phone_number = [stream readString];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
}
@end

@implementation TL_inputMediaUploadedVideo
+ (TL_inputMediaUploadedVideo *)createWithFile:(TGInputFile *)file duration:(int)duration w:(int)w h:(int)h mime_type:(NSString *)mime_type {
	TL_inputMediaUploadedVideo *obj = [[TL_inputMediaUploadedVideo alloc] init];
	obj.file = file;
	obj.duration = duration;
	obj.w = w;
	obj.h = h;
	obj.mime_type = mime_type;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.file stream:stream];
	[stream writeInt:self.duration];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeString:self.mime_type];
}
- (void)unserialize:(SerializedData *)stream {
	self.file = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.duration = [stream readInt];
	self.w = [stream readInt];
	self.h = [stream readInt];
	self.mime_type = [stream readString];
}
@end

@implementation TL_inputMediaUploadedThumbVideo
+ (TL_inputMediaUploadedThumbVideo *)createWithFile:(TGInputFile *)file thumb:(TGInputFile *)thumb duration:(int)duration w:(int)w h:(int)h mime_type:(NSString *)mime_type {
	TL_inputMediaUploadedThumbVideo *obj = [[TL_inputMediaUploadedThumbVideo alloc] init];
	obj.file = file;
	obj.thumb = thumb;
	obj.duration = duration;
	obj.w = w;
	obj.h = h;
	obj.mime_type = mime_type;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.file stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.thumb stream:stream];
	[stream writeInt:self.duration];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeString:self.mime_type];
}
- (void)unserialize:(SerializedData *)stream {
	self.file = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.thumb = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.duration = [stream readInt];
	self.w = [stream readInt];
	self.h = [stream readInt];
	self.mime_type = [stream readString];
}
@end

@implementation TL_inputMediaVideo
+ (TL_inputMediaVideo *)createWithVideo_id:(TGInputVideo *)video_id {
	TL_inputMediaVideo *obj = [[TL_inputMediaVideo alloc] init];
	obj.video_id = video_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.video_id stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.video_id = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_inputMediaUploadedAudio
+ (TL_inputMediaUploadedAudio *)createWithFile:(TGInputFile *)file duration:(int)duration mime_type:(NSString *)mime_type {
	TL_inputMediaUploadedAudio *obj = [[TL_inputMediaUploadedAudio alloc] init];
	obj.file = file;
	obj.duration = duration;
	obj.mime_type = mime_type;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.file stream:stream];
	[stream writeInt:self.duration];
	[stream writeString:self.mime_type];
}
- (void)unserialize:(SerializedData *)stream {
	self.file = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.duration = [stream readInt];
	self.mime_type = [stream readString];
}
@end

@implementation TL_inputMediaAudio
+ (TL_inputMediaAudio *)createWithAudio_id:(TGInputAudio *)audio_id {
	TL_inputMediaAudio *obj = [[TL_inputMediaAudio alloc] init];
	obj.audio_id = audio_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.audio_id stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.audio_id = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_inputMediaUploadedDocument
+ (TL_inputMediaUploadedDocument *)createWithFile:(TGInputFile *)file file_name:(NSString *)file_name mime_type:(NSString *)mime_type {
	TL_inputMediaUploadedDocument *obj = [[TL_inputMediaUploadedDocument alloc] init];
	obj.file = file;
	obj.file_name = file_name;
	obj.mime_type = mime_type;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.file stream:stream];
	[stream writeString:self.file_name];
	[stream writeString:self.mime_type];
}
- (void)unserialize:(SerializedData *)stream {
	self.file = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.file_name = [stream readString];
	self.mime_type = [stream readString];
}
@end

@implementation TL_inputMediaUploadedThumbDocument
+ (TL_inputMediaUploadedThumbDocument *)createWithFile:(TGInputFile *)file thumb:(TGInputFile *)thumb file_name:(NSString *)file_name mime_type:(NSString *)mime_type {
	TL_inputMediaUploadedThumbDocument *obj = [[TL_inputMediaUploadedThumbDocument alloc] init];
	obj.file = file;
	obj.thumb = thumb;
	obj.file_name = file_name;
	obj.mime_type = mime_type;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.file stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.thumb stream:stream];
	[stream writeString:self.file_name];
	[stream writeString:self.mime_type];
}
- (void)unserialize:(SerializedData *)stream {
	self.file = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.thumb = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.file_name = [stream readString];
	self.mime_type = [stream readString];
}
@end

@implementation TL_inputMediaDocument
+ (TL_inputMediaDocument *)createWithDocument_id:(TGInputDocument *)document_id {
	TL_inputMediaDocument *obj = [[TL_inputMediaDocument alloc] init];
	obj.document_id = document_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.document_id stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.document_id = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGInputChatPhoto
@end

@implementation TL_inputChatPhotoEmpty
+ (TL_inputChatPhotoEmpty *)create {
	TL_inputChatPhotoEmpty *obj = [[TL_inputChatPhotoEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputChatUploadedPhoto
+ (TL_inputChatUploadedPhoto *)createWithFile:(TGInputFile *)file crop:(TGInputPhotoCrop *)crop {
	TL_inputChatUploadedPhoto *obj = [[TL_inputChatUploadedPhoto alloc] init];
	obj.file = file;
	obj.crop = crop;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.file stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.crop stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.file = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.crop = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_inputChatPhoto
+ (TL_inputChatPhoto *)createWithN_id:(TGInputPhoto *)n_id crop:(TGInputPhotoCrop *)crop {
	TL_inputChatPhoto *obj = [[TL_inputChatPhoto alloc] init];
	obj.n_id = n_id;
	obj.crop = crop;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.n_id stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.crop stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.crop = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGInputGeoPoint
@end

@implementation TL_inputGeoPointEmpty
+ (TL_inputGeoPointEmpty *)create {
	TL_inputGeoPointEmpty *obj = [[TL_inputGeoPointEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputGeoPoint
+ (TL_inputGeoPoint *)createWithLat:(double)lat n_long:(double)n_long {
	TL_inputGeoPoint *obj = [[TL_inputGeoPoint alloc] init];
	obj.lat = lat;
	obj.n_long = n_long;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeDouble:self.lat];
	[stream writeDouble:self.n_long];
}
- (void)unserialize:(SerializedData *)stream {
	self.lat = [stream readDouble];
	self.n_long = [stream readDouble];
}
@end



@implementation TGInputPhoto
@end

@implementation TL_inputPhotoEmpty
+ (TL_inputPhotoEmpty *)create {
	TL_inputPhotoEmpty *obj = [[TL_inputPhotoEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputPhoto
+ (TL_inputPhoto *)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputPhoto *obj = [[TL_inputPhoto alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end



@implementation TGInputVideo
@end

@implementation TL_inputVideoEmpty
+ (TL_inputVideoEmpty *)create {
	TL_inputVideoEmpty *obj = [[TL_inputVideoEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputVideo
+ (TL_inputVideo *)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputVideo *obj = [[TL_inputVideo alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end



@implementation TGInputFileLocation
@end

@implementation TL_inputFileLocation
+ (TL_inputFileLocation *)createWithVolume_id:(long)volume_id local_id:(int)local_id secret:(long)secret {
	TL_inputFileLocation *obj = [[TL_inputFileLocation alloc] init];
	obj.volume_id = volume_id;
	obj.local_id = local_id;
	obj.secret = secret;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.volume_id];
	[stream writeInt:self.local_id];
	[stream writeLong:self.secret];
}
- (void)unserialize:(SerializedData *)stream {
	self.volume_id = [stream readLong];
	self.local_id = [stream readInt];
	self.secret = [stream readLong];
}
@end

@implementation TL_inputVideoFileLocation
+ (TL_inputVideoFileLocation *)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputVideoFileLocation *obj = [[TL_inputVideoFileLocation alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end

@implementation TL_inputEncryptedFileLocation
+ (TL_inputEncryptedFileLocation *)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputEncryptedFileLocation *obj = [[TL_inputEncryptedFileLocation alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end

@implementation TL_inputAudioFileLocation
+ (TL_inputAudioFileLocation *)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputAudioFileLocation *obj = [[TL_inputAudioFileLocation alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end

@implementation TL_inputDocumentFileLocation
+ (TL_inputDocumentFileLocation *)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputDocumentFileLocation *obj = [[TL_inputDocumentFileLocation alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end



@implementation TGInputPhotoCrop
@end

@implementation TL_inputPhotoCropAuto
+ (TL_inputPhotoCropAuto *)create {
	TL_inputPhotoCropAuto *obj = [[TL_inputPhotoCropAuto alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputPhotoCrop
+ (TL_inputPhotoCrop *)createWithCrop_left:(double)crop_left crop_top:(double)crop_top crop_width:(double)crop_width {
	TL_inputPhotoCrop *obj = [[TL_inputPhotoCrop alloc] init];
	obj.crop_left = crop_left;
	obj.crop_top = crop_top;
	obj.crop_width = crop_width;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeDouble:self.crop_left];
	[stream writeDouble:self.crop_top];
	[stream writeDouble:self.crop_width];
}
- (void)unserialize:(SerializedData *)stream {
	self.crop_left = [stream readDouble];
	self.crop_top = [stream readDouble];
	self.crop_width = [stream readDouble];
}
@end



@implementation TGInputAppEvent
@end

@implementation TL_inputAppEvent
+ (TL_inputAppEvent *)createWithTime:(double)time type:(NSString *)type peer:(long)peer data:(NSString *)data {
	TL_inputAppEvent *obj = [[TL_inputAppEvent alloc] init];
	obj.time = time;
	obj.type = type;
	obj.peer = peer;
	obj.data = data;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeDouble:self.time];
	[stream writeString:self.type];
	[stream writeLong:self.peer];
	[stream writeString:self.data];
}
- (void)unserialize:(SerializedData *)stream {
	self.time = [stream readDouble];
	self.type = [stream readString];
	self.peer = [stream readLong];
	self.data = [stream readString];
}
@end



@implementation TGPeer
@end

@implementation TL_peerUser
+ (TL_peerUser *)createWithUser_id:(int)user_id {
	TL_peerUser *obj = [[TL_peerUser alloc] init];
	obj.user_id = user_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
}
@end

@implementation TL_peerChat
+ (TL_peerChat *)createWithChat_id:(int)chat_id {
	TL_peerChat *obj = [[TL_peerChat alloc] init];
	obj.chat_id = chat_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.chat_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat_id = [stream readInt];
}
@end



@implementation TGstorage_FileType
@end

@implementation TL_storage_fileUnknown
+ (TL_storage_fileUnknown *)create {
	TL_storage_fileUnknown *obj = [[TL_storage_fileUnknown alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_storage_fileJpeg
+ (TL_storage_fileJpeg *)create {
	TL_storage_fileJpeg *obj = [[TL_storage_fileJpeg alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_storage_fileGif
+ (TL_storage_fileGif *)create {
	TL_storage_fileGif *obj = [[TL_storage_fileGif alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_storage_filePng
+ (TL_storage_filePng *)create {
	TL_storage_filePng *obj = [[TL_storage_filePng alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_storage_filePdf
+ (TL_storage_filePdf *)create {
	TL_storage_filePdf *obj = [[TL_storage_filePdf alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_storage_fileMp3
+ (TL_storage_fileMp3 *)create {
	TL_storage_fileMp3 *obj = [[TL_storage_fileMp3 alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_storage_fileMov
+ (TL_storage_fileMov *)create {
	TL_storage_fileMov *obj = [[TL_storage_fileMov alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_storage_filePartial
+ (TL_storage_filePartial *)create {
	TL_storage_filePartial *obj = [[TL_storage_filePartial alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_storage_fileMp4
+ (TL_storage_fileMp4 *)create {
	TL_storage_fileMp4 *obj = [[TL_storage_fileMp4 alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_storage_fileWebp
+ (TL_storage_fileWebp *)create {
	TL_storage_fileWebp *obj = [[TL_storage_fileWebp alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end



@implementation TGFileLocation
@end

@implementation TL_fileLocationUnavailable
+ (TL_fileLocationUnavailable *)createWithVolume_id:(long)volume_id local_id:(int)local_id secret:(long)secret {
	TL_fileLocationUnavailable *obj = [[TL_fileLocationUnavailable alloc] init];
	obj.volume_id = volume_id;
	obj.local_id = local_id;
	obj.secret = secret;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.volume_id];
	[stream writeInt:self.local_id];
	[stream writeLong:self.secret];
}
- (void)unserialize:(SerializedData *)stream {
	self.volume_id = [stream readLong];
	self.local_id = [stream readInt];
	self.secret = [stream readLong];
}
@end

@implementation TL_fileLocation
+ (TL_fileLocation *)createWithDc_id:(int)dc_id volume_id:(long)volume_id local_id:(int)local_id secret:(long)secret {
	TL_fileLocation *obj = [[TL_fileLocation alloc] init];
	obj.dc_id = dc_id;
	obj.volume_id = volume_id;
	obj.local_id = local_id;
	obj.secret = secret;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.dc_id];
	[stream writeLong:self.volume_id];
	[stream writeInt:self.local_id];
	[stream writeLong:self.secret];
}
- (void)unserialize:(SerializedData *)stream {
	self.dc_id = [stream readInt];
	self.volume_id = [stream readLong];
	self.local_id = [stream readInt];
	self.secret = [stream readLong];
}
@end



@implementation TGUser
@end

@implementation TL_userEmpty
+ (TL_userEmpty *)createWithN_id:(int)n_id {
	TL_userEmpty *obj = [[TL_userEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
}
@end

@implementation TL_userSelf
+ (TL_userSelf *)createWithN_id:(int)n_id first_name:(NSString *)first_name last_name:(NSString *)last_name user_name:(NSString *)user_name phone:(NSString *)phone photo:(TGUserProfilePhoto *)photo status:(TGUserStatus *)status inactive:(BOOL)inactive {
	TL_userSelf *obj = [[TL_userSelf alloc] init];
	obj.n_id = n_id;
	obj.first_name = first_name;
	obj.last_name = last_name;
    obj.user_name = user_name;
	obj.phone = phone;
	obj.photo = photo;
	obj.status = status;
	obj.inactive = inactive;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
    [stream writeString:self.user_name];
	[stream writeString:self.phone];
	[[TLClassStore sharedManager] TLSerialize:self.photo stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.status stream:stream];
	[stream writeBool:self.inactive];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
    self.user_name = [stream readString];
	self.phone = [stream readString];
	self.photo = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.status = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.inactive = [stream readBool];
}
@end

@implementation TL_userContact
+ (TL_userContact *)createWithN_id:(int)n_id first_name:(NSString *)first_name last_name:(NSString *)last_name user_name:(NSString *)user_name access_hash:(long)access_hash phone:(NSString *)phone photo:(TGUserProfilePhoto *)photo status:(TGUserStatus *)status {
	TL_userContact *obj = [[TL_userContact alloc] init];
	obj.n_id = n_id;
	obj.first_name = first_name;
	obj.last_name = last_name;
    obj.user_name = user_name;
	obj.access_hash = access_hash;
	obj.phone = phone;
	obj.photo = photo;
	obj.status = status;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
    [stream writeString:self.user_name];
	[stream writeLong:self.access_hash];
	[stream writeString:self.phone];
	[[TLClassStore sharedManager] TLSerialize:self.photo stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.status stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
    self.user_name = [stream readString];
	self.access_hash = [stream readLong];
	self.phone = [stream readString];
	self.photo = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.status = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_userRequest
+ (TL_userRequest *)createWithN_id:(int)n_id first_name:(NSString *)first_name last_name:(NSString *)last_name user_name:(NSString *)user_name access_hash:(long)access_hash phone:(NSString *)phone photo:(TGUserProfilePhoto *)photo status:(TGUserStatus *)status {
	TL_userRequest *obj = [[TL_userRequest alloc] init];
	obj.n_id = n_id;
	obj.first_name = first_name;
	obj.last_name = last_name;
    obj.user_name = user_name;
	obj.access_hash = access_hash;
	obj.phone = phone;
	obj.photo = photo;
	obj.status = status;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
    [stream writeString:self.user_name];
	[stream writeLong:self.access_hash];
	[stream writeString:self.phone];
	[[TLClassStore sharedManager] TLSerialize:self.photo stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.status stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
    self.user_name = [stream readString];
	self.access_hash = [stream readLong];
	self.phone = [stream readString];
	self.photo = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.status = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_userForeign
+ (TL_userForeign *)createWithN_id:(int)n_id first_name:(NSString *)first_name last_name:(NSString *)last_name user_name:(NSString *)user_name access_hash:(long)access_hash photo:(TGUserProfilePhoto *)photo status:(TGUserStatus *)status {
	TL_userForeign *obj = [[TL_userForeign alloc] init];
	obj.n_id = n_id;
	obj.first_name = first_name;
	obj.last_name = last_name;
    obj.user_name = user_name;
	obj.access_hash = access_hash;
	obj.photo = photo;
	obj.status = status;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
    [stream writeString:self.user_name];
	[stream writeLong:self.access_hash];
	[[TLClassStore sharedManager] TLSerialize:self.photo stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.status stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
    self.user_name = [stream readString];
	self.access_hash = [stream readLong];
	self.photo = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.status = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_userDeleted
+ (TL_userDeleted *)createWithN_id:(int)n_id first_name:(NSString *)first_name last_name:(NSString *)last_name user_name:(NSString *)user_name {
	TL_userDeleted *obj = [[TL_userDeleted alloc] init];
	obj.n_id = n_id;
	obj.first_name = first_name;
	obj.last_name = last_name;
    obj.user_name = user_name;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
    self.user_name = [stream readString];
}
@end



@implementation TGUserProfilePhoto
@end

@implementation TL_userProfilePhotoEmpty
+ (TL_userProfilePhotoEmpty *)create {
	TL_userProfilePhotoEmpty *obj = [[TL_userProfilePhotoEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_userProfilePhoto
+ (TL_userProfilePhoto *)createWithPhoto_id:(long)photo_id photo_small:(TGFileLocation *)photo_small photo_big:(TGFileLocation *)photo_big {
	TL_userProfilePhoto *obj = [[TL_userProfilePhoto alloc] init];
	obj.photo_id = photo_id;
	obj.photo_small = photo_small;
	obj.photo_big = photo_big;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.photo_id];
	[[TLClassStore sharedManager] TLSerialize:self.photo_small stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.photo_big stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.photo_id = [stream readLong];
	self.photo_small = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.photo_big = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGUserStatus
@end

@implementation TL_userStatusEmpty
+ (TL_userStatusEmpty *)create {
	TL_userStatusEmpty *obj = [[TL_userStatusEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_userStatusOnline
+ (TL_userStatusOnline *)createWithExpires:(int)expires {
	TL_userStatusOnline *obj = [[TL_userStatusOnline alloc] init];
	obj.expires = expires;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.expires];
}
- (void)unserialize:(SerializedData *)stream {
	self.expires = [stream readInt];
}
@end

@implementation TL_userStatusOffline
+ (TL_userStatusOffline *)createWithWas_online:(int)was_online {
	TL_userStatusOffline *obj = [[TL_userStatusOffline alloc] init];
	obj.was_online = was_online;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.was_online];
}
- (void)unserialize:(SerializedData *)stream {
	self.was_online = [stream readInt];
}
@end



@implementation TGChat
@end

@implementation TL_chatEmpty
+ (TL_chatEmpty *)createWithN_id:(int)n_id {
	TL_chatEmpty *obj = [[TL_chatEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
}
@end

@implementation TL_chat
+ (TL_chat *)createWithN_id:(int)n_id title:(NSString *)title photo:(TGChatPhoto *)photo participants_count:(int)participants_count date:(int)date left:(BOOL)left version:(int)version {
	TL_chat *obj = [[TL_chat alloc] init];
	obj.n_id = n_id;
	obj.title = title;
	obj.photo = photo;
	obj.participants_count = participants_count;
	obj.date = date;
	obj.left = left;
	obj.version = version;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.title];
	[[TLClassStore sharedManager] TLSerialize:self.photo stream:stream];
	[stream writeInt:self.participants_count];
	[stream writeInt:self.date];
	[stream writeBool:self.left];
	[stream writeInt:self.version];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.title = [stream readString];
	self.photo = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.participants_count = [stream readInt];
	self.date = [stream readInt];
	self.left = [stream readBool];
	self.version = [stream readInt];
}
@end

@implementation TL_chatForbidden
+ (TL_chatForbidden *)createWithN_id:(int)n_id title:(NSString *)title date:(int)date {
	TL_chatForbidden *obj = [[TL_chatForbidden alloc] init];
	obj.n_id = n_id;
	obj.title = title;
	obj.date = date;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.title];
	[stream writeInt:self.date];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.title = [stream readString];
	self.date = [stream readInt];
}
@end

@implementation TL_geoChat
+ (TL_geoChat *)createWithN_id:(int)n_id access_hash:(long)access_hash title:(NSString *)title address:(NSString *)address venue:(NSString *)venue geo:(TGGeoPoint *)geo photo:(TGChatPhoto *)photo participants_count:(int)participants_count date:(int)date checked_in:(BOOL)checked_in version:(int)version {
	TL_geoChat *obj = [[TL_geoChat alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.title = title;
	obj.address = address;
	obj.venue = venue;
	obj.geo = geo;
	obj.photo = photo;
	obj.participants_count = participants_count;
	obj.date = date;
	obj.checked_in = checked_in;
	obj.version = version;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeString:self.title];
	[stream writeString:self.address];
	[stream writeString:self.venue];
	[[TLClassStore sharedManager] TLSerialize:self.geo stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.photo stream:stream];
	[stream writeInt:self.participants_count];
	[stream writeInt:self.date];
	[stream writeBool:self.checked_in];
	[stream writeInt:self.version];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.access_hash = [stream readLong];
	self.title = [stream readString];
	self.address = [stream readString];
	self.venue = [stream readString];
	self.geo = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.photo = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.participants_count = [stream readInt];
	self.date = [stream readInt];
	self.checked_in = [stream readBool];
	self.version = [stream readInt];
}
@end



@implementation TGChatFull
@end

@implementation TL_chatFull
+ (TL_chatFull *)createWithN_id:(int)n_id participants:(TGChatParticipants *)participants chat_photo:(TGPhoto *)chat_photo notify_settings:(TGPeerNotifySettings *)notify_settings {
	TL_chatFull *obj = [[TL_chatFull alloc] init];
	obj.n_id = n_id;
	obj.participants = participants;
	obj.chat_photo = chat_photo;
	obj.notify_settings = notify_settings;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[[TLClassStore sharedManager] TLSerialize:self.participants stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.chat_photo stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.notify_settings stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.participants = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.chat_photo = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.notify_settings = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGChatParticipant
@end

@implementation TL_chatParticipant
+ (TL_chatParticipant *)createWithUser_id:(int)user_id inviter_id:(int)inviter_id date:(int)date {
	TL_chatParticipant *obj = [[TL_chatParticipant alloc] init];
	obj.user_id = user_id;
	obj.inviter_id = inviter_id;
	obj.date = date;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
	[stream writeInt:self.inviter_id];
	[stream writeInt:self.date];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
	self.inviter_id = [stream readInt];
	self.date = [stream readInt];
}
@end



@implementation TGChatParticipants
@end

@implementation TL_chatParticipantsForbidden
+ (TL_chatParticipantsForbidden *)createWithChat_id:(int)chat_id {
	TL_chatParticipantsForbidden *obj = [[TL_chatParticipantsForbidden alloc] init];
	obj.chat_id = chat_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.chat_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat_id = [stream readInt];
}
@end

@implementation TL_chatParticipants
+ (TL_chatParticipants *)createWithChat_id:(int)chat_id admin_id:(int)admin_id participants:(NSMutableArray *)participants version:(int)version {
	TL_chatParticipants *obj = [[TL_chatParticipants alloc] init];
	obj.chat_id = chat_id;
	obj.admin_id = admin_id;
	obj.participants = participants;
	obj.version = version;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.admin_id];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.participants count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChatParticipant* obj = [self.participants objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.version];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat_id = [stream readInt];
	self.admin_id = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.participants)
			self.participants = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChatParticipant* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.participants addObject:obj];
		}
	}
	self.version = [stream readInt];
}
@end



@implementation TGChatPhoto
@end

@implementation TL_chatPhotoEmpty
+ (TL_chatPhotoEmpty *)create {
	TL_chatPhotoEmpty *obj = [[TL_chatPhotoEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_chatPhoto
+ (TL_chatPhoto *)createWithPhoto_small:(TGFileLocation *)photo_small photo_big:(TGFileLocation *)photo_big {
	TL_chatPhoto *obj = [[TL_chatPhoto alloc] init];
	obj.photo_small = photo_small;
	obj.photo_big = photo_big;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.photo_small stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.photo_big stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.photo_small = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.photo_big = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGMessage
@end

@implementation TL_messageEmpty
+ (TL_messageEmpty *)createWithN_id:(int)n_id {
	TL_messageEmpty *obj = [[TL_messageEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
}
@end

@implementation TL_message
+ (TL_message *)createWithN_id:(int)n_id  flags:(int)flags from_id:(int)from_id to_id:(TGPeer *)to_id date:(int)date message:(NSString *)message media:(TGMessageMedia *)media {
	TL_message *obj = [[TL_message alloc] init];
    obj.flags = flags;
	obj.n_id = n_id;
	obj.from_id = from_id;
	obj.to_id = to_id;
	obj.date = date;
	obj.message = message;
	obj.media = media;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
    [stream writeInt:self.flags];
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[[TLClassStore sharedManager] TLSerialize:self.to_id stream:stream];
	[stream writeInt:self.date];
	[stream writeString:self.message];
	[[TLClassStore sharedManager] TLSerialize:self.media stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
    self.flags = [stream readInt];
	self.n_id = [stream readInt];
	self.from_id = [stream readInt];
	self.to_id = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.date = [stream readInt];
	self.message = [stream readString];
	self.media = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_messageForwarded
+ (TL_messageForwarded *)createWithN_id:(int)n_id flags:(int)flags fwd_from_id:(int)fwd_from_id fwd_date:(int)fwd_date from_id:(int)from_id to_id:(TGPeer *)to_id date:(int)date message:(NSString *)message media:(TGMessageMedia *)media {
	TL_messageForwarded *obj = [[TL_messageForwarded alloc] init];
    obj.flags = flags;
	obj.n_id = n_id;
	obj.fwd_from_id = fwd_from_id;
	obj.fwd_date = fwd_date;
	obj.from_id = from_id;
	obj.to_id = to_id;
	obj.date = date;
	obj.message = message;
	obj.media = media;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
    [stream writeInt:self.flags];
	[stream writeInt:self.n_id];
	[stream writeInt:self.fwd_from_id];
	[stream writeInt:self.fwd_date];
	[stream writeInt:self.from_id];
	[[TLClassStore sharedManager] TLSerialize:self.to_id stream:stream];
	[stream writeInt:self.date];
	[stream writeString:self.message];
	[[TLClassStore sharedManager] TLSerialize:self.media stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
    self.flags = [stream readInt];
	self.n_id = [stream readInt];
	self.fwd_from_id = [stream readInt];
	self.fwd_date = [stream readInt];
	self.from_id = [stream readInt];
	self.to_id = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.date = [stream readInt];
	self.message = [stream readString];
	self.media = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_messageService
+ (TL_messageService *)createWithN_id:(int)n_id flags:(int)flags from_id:(int)from_id to_id:(TGPeer *)to_id date:(int)date action:(TGMessageAction *)action {
	TL_messageService *obj = [[TL_messageService alloc] init];
    obj.flags = flags;
	obj.n_id = n_id;
	obj.from_id = from_id;
	obj.to_id = to_id;
	obj.date = date;
	obj.action = action;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
    [stream writeInt:self.flags];
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[[TLClassStore sharedManager] TLSerialize:self.to_id stream:stream];
	[stream writeInt:self.date];
	[[TLClassStore sharedManager] TLSerialize:self.action stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
    self.flags = [stream readInt];
	self.n_id = [stream readInt];
	self.from_id = [stream readInt];
	self.to_id = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.date = [stream readInt];
	self.action = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGMessageMedia
@end

@implementation TL_messageMediaEmpty
+ (TL_messageMediaEmpty *)create {
	TL_messageMediaEmpty *obj = [[TL_messageMediaEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_messageMediaPhoto
+ (TL_messageMediaPhoto *)createWithPhoto:(TGPhoto *)photo {
	TL_messageMediaPhoto *obj = [[TL_messageMediaPhoto alloc] init];
	obj.photo = photo;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.photo stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.photo = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_messageMediaVideo
+ (TL_messageMediaVideo *)createWithVideo:(TGVideo *)video {
	TL_messageMediaVideo *obj = [[TL_messageMediaVideo alloc] init];
	obj.video = video;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.video stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.video = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_messageMediaGeo
+ (TL_messageMediaGeo *)createWithGeo:(TGGeoPoint *)geo {
	TL_messageMediaGeo *obj = [[TL_messageMediaGeo alloc] init];
	obj.geo = geo;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.geo stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.geo = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_messageMediaContact
+ (TL_messageMediaContact *)createWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(int)user_id {
	TL_messageMediaContact *obj = [[TL_messageMediaContact alloc] init];
	obj.phone_number = phone_number;
	obj.first_name = first_name;
	obj.last_name = last_name;
	obj.user_id = user_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeString:self.phone_number];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
	[stream writeInt:self.user_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.phone_number = [stream readString];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
	self.user_id = [stream readInt];
}
@end

@implementation TL_messageMediaUnsupported
+ (TL_messageMediaUnsupported *)createWithBytes:(NSData *)bytes {
	TL_messageMediaUnsupported *obj = [[TL_messageMediaUnsupported alloc] init];
	obj.bytes = bytes;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeByteArray:self.bytes];
}
- (void)unserialize:(SerializedData *)stream {
	self.bytes = [stream readByteArray];
}
@end

@implementation TL_messageMediaDocument
+ (TL_messageMediaDocument *)createWithDocument:(TGDocument *)document {
	TL_messageMediaDocument *obj = [[TL_messageMediaDocument alloc] init];
	obj.document = document;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.document stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.document = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_messageMediaAudio
+ (TL_messageMediaAudio *)createWithAudio:(TGAudio *)audio {
	TL_messageMediaAudio *obj = [[TL_messageMediaAudio alloc] init];
	obj.audio = audio;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.audio stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.audio = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGMessageAction
@end

@implementation TL_messageActionEmpty
+ (TL_messageActionEmpty *)create {
	TL_messageActionEmpty *obj = [[TL_messageActionEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_messageActionChatCreate
+ (TL_messageActionChatCreate *)createWithTitle:(NSString *)title users:(NSMutableArray *)users {
	TL_messageActionChatCreate *obj = [[TL_messageActionChatCreate alloc] init];
	obj.title = title;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeString:self.title];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.users objectAtIndex:i];
			[stream writeInt:[obj intValue]];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	self.title = [stream readString];
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			int obj = [stream readInt];
			[self.users addObject:[[NSNumber alloc] initWithInt:obj]];
		}
	}
}
@end

@implementation TL_messageActionChatEditTitle
+ (TL_messageActionChatEditTitle *)createWithTitle:(NSString *)title {
	TL_messageActionChatEditTitle *obj = [[TL_messageActionChatEditTitle alloc] init];
	obj.title = title;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeString:self.title];
}
- (void)unserialize:(SerializedData *)stream {
	self.title = [stream readString];
}
@end

@implementation TL_messageActionChatEditPhoto
+ (TL_messageActionChatEditPhoto *)createWithPhoto:(TGPhoto *)photo {
	TL_messageActionChatEditPhoto *obj = [[TL_messageActionChatEditPhoto alloc] init];
	obj.photo = photo;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.photo stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.photo = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_messageActionChatDeletePhoto
+ (TL_messageActionChatDeletePhoto *)create {
	TL_messageActionChatDeletePhoto *obj = [[TL_messageActionChatDeletePhoto alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_messageActionChatAddUser
+ (TL_messageActionChatAddUser *)createWithUser_id:(int)user_id {
	TL_messageActionChatAddUser *obj = [[TL_messageActionChatAddUser alloc] init];
	obj.user_id = user_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
}
@end

@implementation TL_messageActionChatDeleteUser
+ (TL_messageActionChatDeleteUser *)createWithUser_id:(int)user_id {
	TL_messageActionChatDeleteUser *obj = [[TL_messageActionChatDeleteUser alloc] init];
	obj.user_id = user_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
}
@end

@implementation TL_messageActionGeoChatCreate
+ (TL_messageActionGeoChatCreate *)createWithTitle:(NSString *)title address:(NSString *)address {
	TL_messageActionGeoChatCreate *obj = [[TL_messageActionGeoChatCreate alloc] init];
	obj.title = title;
	obj.address = address;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeString:self.title];
	[stream writeString:self.address];
}
- (void)unserialize:(SerializedData *)stream {
	self.title = [stream readString];
	self.address = [stream readString];
}
@end

@implementation TL_messageActionGeoChatCheckin
+ (TL_messageActionGeoChatCheckin *)create {
	TL_messageActionGeoChatCheckin *obj = [[TL_messageActionGeoChatCheckin alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end



@implementation TGDialog
@end

@implementation TL_dialog
+ (TL_dialog *)createWithPeer:(TGPeer *)peer top_message:(int)top_message unread_count:(int)unread_count notify_settings:(TGPeerNotifySettings *)notify_settings {
	TL_dialog *obj = [[TL_dialog alloc] init];
	obj.peer = peer;
	obj.top_message = top_message;
	obj.unread_count = unread_count;
	obj.notify_settings = notify_settings;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeInt:self.top_message];
	[stream writeInt:self.unread_count];
	[[TLClassStore sharedManager] TLSerialize:self.notify_settings stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.peer = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.top_message = [stream readInt];
	self.unread_count = [stream readInt];
	self.notify_settings = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGPhoto
@end

@implementation TL_photoEmpty
+ (TL_photoEmpty *)createWithN_id:(long)n_id {
	TL_photoEmpty *obj = [[TL_photoEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
}
@end

@implementation TL_photo
+ (TL_photo *)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date caption:(NSString *)caption geo:(TGGeoPoint *)geo sizes:(NSMutableArray *)sizes {
	TL_photo *obj = [[TL_photo alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.user_id = user_id;
	obj.date = date;
	obj.caption = caption;
	obj.geo = geo;
	obj.sizes = sizes;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
	[stream writeString:self.caption];
	[[TLClassStore sharedManager] TLSerialize:self.geo stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.sizes count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGPhotoSize* obj = [self.sizes objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
	self.user_id = [stream readInt];
	self.date = [stream readInt];
	self.caption = [stream readString];
	self.geo = [[TLClassStore sharedManager] TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.sizes)
			self.sizes = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGPhotoSize* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.sizes addObject:obj];
		}
	}
}
@end



@implementation TGPhotoSize
@end

@implementation TL_photoSizeEmpty
+ (TL_photoSizeEmpty *)createWithType:(NSString *)type {
	TL_photoSizeEmpty *obj = [[TL_photoSizeEmpty alloc] init];
	obj.type = type;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeString:self.type];
}
- (void)unserialize:(SerializedData *)stream {
	self.type = [stream readString];
}
@end

@implementation TL_photoSize
+ (TL_photoSize *)createWithType:(NSString *)type location:(TGFileLocation *)location w:(int)w h:(int)h size:(int)size {
	TL_photoSize *obj = [[TL_photoSize alloc] init];
	obj.type = type;
	obj.location = location;
	obj.w = w;
	obj.h = h;
	obj.size = size;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeString:self.type];
	[[TLClassStore sharedManager] TLSerialize:self.location stream:stream];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeInt:self.size];
}
- (void)unserialize:(SerializedData *)stream {
	self.type = [stream readString];
	self.location = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.w = [stream readInt];
	self.h = [stream readInt];
	self.size = [stream readInt];
}
@end

@implementation TL_photoCachedSize
+ (TL_photoCachedSize *)createWithType:(NSString *)type location:(TGFileLocation *)location w:(int)w h:(int)h bytes:(NSData *)bytes {
	TL_photoCachedSize *obj = [[TL_photoCachedSize alloc] init];
	obj.type = type;
	obj.location = location;
	obj.w = w;
	obj.h = h;
	obj.bytes = bytes;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeString:self.type];
	[[TLClassStore sharedManager] TLSerialize:self.location stream:stream];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeByteArray:self.bytes];
}
- (void)unserialize:(SerializedData *)stream {
	self.type = [stream readString];
	self.location = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.w = [stream readInt];
	self.h = [stream readInt];
	self.bytes = [stream readByteArray];
}
@end



@implementation TGVideo
@end

@implementation TL_videoEmpty
+ (TL_videoEmpty *)createWithN_id:(long)n_id {
	TL_videoEmpty *obj = [[TL_videoEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
}
@end

@implementation TL_video
+ (TL_video *)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date caption:(NSString *)caption duration:(int)duration mime_type:(NSString *)mime_type size:(int)size thumb:(TGPhotoSize *)thumb dc_id:(int)dc_id w:(int)w h:(int)h {
	TL_video *obj = [[TL_video alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.user_id = user_id;
	obj.date = date;
	obj.caption = caption;
	obj.duration = duration;
	obj.mime_type = mime_type;
	obj.size = size;
	obj.thumb = thumb;
	obj.dc_id = dc_id;
	obj.w = w;
	obj.h = h;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
	[stream writeString:self.caption];
	[stream writeInt:self.duration];
	[stream writeString:self.mime_type];
	[stream writeInt:self.size];
	[[TLClassStore sharedManager] TLSerialize:self.thumb stream:stream];
	[stream writeInt:self.dc_id];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
	self.user_id = [stream readInt];
	self.date = [stream readInt];
	self.caption = [stream readString];
	self.duration = [stream readInt];
	self.mime_type = [stream readString];
	self.size = [stream readInt];
	self.thumb = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.dc_id = [stream readInt];
	self.w = [stream readInt];
	self.h = [stream readInt];
}
@end



@implementation TGGeoPoint
@end

@implementation TL_geoPointEmpty
+ (TL_geoPointEmpty *)create {
	TL_geoPointEmpty *obj = [[TL_geoPointEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_geoPoint
+ (TL_geoPoint *)createWithN_long:(double)n_long lat:(double)lat {
	TL_geoPoint *obj = [[TL_geoPoint alloc] init];
	obj.n_long = n_long;
	obj.lat = lat;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeDouble:self.n_long];
	[stream writeDouble:self.lat];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_long = [stream readDouble];
	self.lat = [stream readDouble];
}
@end



@implementation TGauth_CheckedPhone
@end

@implementation TL_auth_checkedPhone
+ (TL_auth_checkedPhone *)createWithPhone_registered:(BOOL)phone_registered phone_invited:(BOOL)phone_invited {
	TL_auth_checkedPhone *obj = [[TL_auth_checkedPhone alloc] init];
	obj.phone_registered = phone_registered;
	obj.phone_invited = phone_invited;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeBool:self.phone_registered];
	[stream writeBool:self.phone_invited];
}
- (void)unserialize:(SerializedData *)stream {
	self.phone_registered = [stream readBool];
	self.phone_invited = [stream readBool];
}
@end



@implementation TGauth_SentCode
@end

@implementation TL_auth_sentCode
+ (TL_auth_sentCode *)createWithPhone_registered:(BOOL)phone_registered phone_code_hash:(NSString *)phone_code_hash send_call_timeout:(int)send_call_timeout is_password:(BOOL)is_password {
	TL_auth_sentCode *obj = [[TL_auth_sentCode alloc] init];
	obj.phone_registered = phone_registered;
	obj.phone_code_hash = phone_code_hash;
	obj.send_call_timeout = send_call_timeout;
	obj.is_password = is_password;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeBool:self.phone_registered];
	[stream writeString:self.phone_code_hash];
	[stream writeInt:self.send_call_timeout];
	[stream writeBool:self.is_password];
}
- (void)unserialize:(SerializedData *)stream {
	self.phone_registered = [stream readBool];
	self.phone_code_hash = [stream readString];
	self.send_call_timeout = [stream readInt];
	self.is_password = [stream readBool];
}
@end



@implementation TGauth_Authorization
@end

@implementation TL_auth_authorization
+ (TL_auth_authorization *)createWithExpires:(int)expires user:(TGUser *)user {
	TL_auth_authorization *obj = [[TL_auth_authorization alloc] init];
	obj.expires = expires;
	obj.user = user;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.expires];
	[[TLClassStore sharedManager] TLSerialize:self.user stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.expires = [stream readInt];
	self.user = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGauth_ExportedAuthorization
@end

@implementation TL_auth_exportedAuthorization
+ (TL_auth_exportedAuthorization *)createWithN_id:(int)n_id bytes:(NSData *)bytes {
	TL_auth_exportedAuthorization *obj = [[TL_auth_exportedAuthorization alloc] init];
	obj.n_id = n_id;
	obj.bytes = bytes;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeByteArray:self.bytes];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.bytes = [stream readByteArray];
}
@end



@implementation TGInputNotifyPeer
@end

@implementation TL_inputNotifyPeer
+ (TL_inputNotifyPeer *)createWithPeer:(TGInputPeer *)peer {
	TL_inputNotifyPeer *obj = [[TL_inputNotifyPeer alloc] init];
	obj.peer = peer;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.peer = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_inputNotifyUsers
+ (TL_inputNotifyUsers *)create {
	TL_inputNotifyUsers *obj = [[TL_inputNotifyUsers alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputNotifyChats
+ (TL_inputNotifyChats *)create {
	TL_inputNotifyChats *obj = [[TL_inputNotifyChats alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputNotifyAll
+ (TL_inputNotifyAll *)create {
	TL_inputNotifyAll *obj = [[TL_inputNotifyAll alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputNotifyGeoChatPeer
+ (TL_inputNotifyGeoChatPeer *)createWithGeo_peer:(TGInputGeoChat *)geo_peer {
	TL_inputNotifyGeoChatPeer *obj = [[TL_inputNotifyGeoChatPeer alloc] init];
	obj.geo_peer = geo_peer;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.geo_peer stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.geo_peer = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGInputPeerNotifyEvents
@end

@implementation TL_inputPeerNotifyEventsEmpty
+ (TL_inputPeerNotifyEventsEmpty *)create {
	TL_inputPeerNotifyEventsEmpty *obj = [[TL_inputPeerNotifyEventsEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputPeerNotifyEventsAll
+ (TL_inputPeerNotifyEventsAll *)create {
	TL_inputPeerNotifyEventsAll *obj = [[TL_inputPeerNotifyEventsAll alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end



@implementation TGInputPeerNotifySettings
@end

@implementation TL_inputPeerNotifySettings
+ (TL_inputPeerNotifySettings *)createWithMute_until:(int)mute_until sound:(NSString *)sound show_previews:(BOOL)show_previews events_mask:(int)events_mask {
	TL_inputPeerNotifySettings *obj = [[TL_inputPeerNotifySettings alloc] init];
	obj.mute_until = mute_until;
	obj.sound = sound;
	obj.show_previews = show_previews;
	obj.events_mask = events_mask;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.mute_until];
	[stream writeString:self.sound];
	[stream writeBool:self.show_previews];
	[stream writeInt:self.events_mask];
}
- (void)unserialize:(SerializedData *)stream {
	self.mute_until = [stream readInt];
	self.sound = [stream readString];
	self.show_previews = [stream readBool];
	self.events_mask = [stream readInt];
}
@end



@implementation TGPeerNotifyEvents
@end

@implementation TL_peerNotifyEventsEmpty
+ (TL_peerNotifyEventsEmpty *)create {
	TL_peerNotifyEventsEmpty *obj = [[TL_peerNotifyEventsEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_peerNotifyEventsAll
+ (TL_peerNotifyEventsAll *)create {
	TL_peerNotifyEventsAll *obj = [[TL_peerNotifyEventsAll alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end



@implementation TGPeerNotifySettings
@end

@implementation TL_peerNotifySettingsEmpty
+ (TL_peerNotifySettingsEmpty *)create {
	TL_peerNotifySettingsEmpty *obj = [[TL_peerNotifySettingsEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_peerNotifySettings
+ (TL_peerNotifySettings *)createWithMute_until:(int)mute_until sound:(NSString *)sound show_previews:(BOOL)show_previews events_mask:(int)events_mask {
	TL_peerNotifySettings *obj = [[TL_peerNotifySettings alloc] init];
	obj.mute_until = mute_until;
	obj.sound = sound;
	obj.show_previews = show_previews;
	obj.events_mask = events_mask;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.mute_until];
	[stream writeString:self.sound];
	[stream writeBool:self.show_previews];
	[stream writeInt:self.events_mask];
}
- (void)unserialize:(SerializedData *)stream {
	self.mute_until = [stream readInt];
	self.sound = [stream readString];
	self.show_previews = [stream readBool];
	self.events_mask = [stream readInt];
}
@end



@implementation TGWallPaper
@end

@implementation TL_wallPaper
+ (TL_wallPaper *)createWithN_id:(int)n_id title:(NSString *)title sizes:(NSMutableArray *)sizes color:(int)color {
	TL_wallPaper *obj = [[TL_wallPaper alloc] init];
	obj.n_id = n_id;
	obj.title = title;
	obj.sizes = sizes;
	obj.color = color;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.title];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.sizes count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGPhotoSize* obj = [self.sizes objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.color];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.title = [stream readString];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.sizes)
			self.sizes = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGPhotoSize* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.sizes addObject:obj];
		}
	}
	self.color = [stream readInt];
}
@end

@implementation TL_wallPaperSolid
+ (TL_wallPaperSolid *)createWithN_id:(int)n_id title:(NSString *)title bg_color:(int)bg_color color:(int)color {
	TL_wallPaperSolid *obj = [[TL_wallPaperSolid alloc] init];
	obj.n_id = n_id;
	obj.title = title;
	obj.bg_color = bg_color;
	obj.color = color;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.title];
	[stream writeInt:self.bg_color];
	[stream writeInt:self.color];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.title = [stream readString];
	self.bg_color = [stream readInt];
	self.color = [stream readInt];
}
@end



@implementation TGUserFull
@end

@implementation TL_userFull
+ (TL_userFull *)createWithUser:(TGUser *)user link:(TGcontacts_Link *)link profile_photo:(TGPhoto *)profile_photo notify_settings:(TGPeerNotifySettings *)notify_settings blocked:(BOOL)blocked real_first_name:(NSString *)real_first_name real_last_name:(NSString *)real_last_name {
	TL_userFull *obj = [[TL_userFull alloc] init];
	obj.user = user;
	obj.link = link;
	obj.profile_photo = profile_photo;
	obj.notify_settings = notify_settings;
	obj.blocked = blocked;
	obj.real_first_name = real_first_name;
	obj.real_last_name = real_last_name;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.user stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.link stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.profile_photo stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.notify_settings stream:stream];
	[stream writeBool:self.blocked];
	[stream writeString:self.real_first_name];
	[stream writeString:self.real_last_name];
}
- (void)unserialize:(SerializedData *)stream {
	self.user = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.link = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.profile_photo = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.notify_settings = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.blocked = [stream readBool];
	self.real_first_name = [stream readString];
	self.real_last_name = [stream readString];
}
@end



@implementation TGContact
@end

@implementation TL_contact
+ (TL_contact *)createWithUser_id:(int)user_id mutual:(BOOL)mutual {
	TL_contact *obj = [[TL_contact alloc] init];
	obj.user_id = user_id;
	obj.mutual = mutual;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
	[stream writeBool:self.mutual];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
	self.mutual = [stream readBool];
}
@end



@implementation TGImportedContact
@end

@implementation TL_importedContact
+ (TL_importedContact *)createWithUser_id:(int)user_id client_id:(long)client_id {
	TL_importedContact *obj = [[TL_importedContact alloc] init];
	obj.user_id = user_id;
	obj.client_id = client_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
	[stream writeLong:self.client_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
	self.client_id = [stream readLong];
}
@end



@implementation TGContactBlocked
@end

@implementation TL_contactBlocked
+ (TL_contactBlocked *)createWithUser_id:(int)user_id date:(int)date {
	TL_contactBlocked *obj = [[TL_contactBlocked alloc] init];
	obj.user_id = user_id;
	obj.date = date;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
	self.date = [stream readInt];
}
@end



@implementation TGContactFound
@end

@implementation TL_contactFound
+ (TL_contactFound *)createWithUser_id:(int)user_id {
	TL_contactFound *obj = [[TL_contactFound alloc] init];
	obj.user_id = user_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
}
@end



@implementation TGContactSuggested
@end

@implementation TL_contactSuggested
+ (TL_contactSuggested *)createWithUser_id:(int)user_id mutual_contacts:(int)mutual_contacts {
	TL_contactSuggested *obj = [[TL_contactSuggested alloc] init];
	obj.user_id = user_id;
	obj.mutual_contacts = mutual_contacts;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
	[stream writeInt:self.mutual_contacts];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
	self.mutual_contacts = [stream readInt];
}
@end



@implementation TGContactStatus
@end

@implementation TL_contactStatus
+ (TL_contactStatus *)createWithUser_id:(int)user_id status:(TGUserStatus *)status {
	TL_contactStatus *obj = [[TL_contactStatus alloc] init];
	obj.user_id = user_id;
	obj.status = status;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
    [[TLClassStore sharedManager] TLSerialize:self.status stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
    self.status = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGChatLocated
@end

@implementation TL_chatLocated
+ (TL_chatLocated *)createWithChat_id:(int)chat_id distance:(int)distance {
	TL_chatLocated *obj = [[TL_chatLocated alloc] init];
	obj.chat_id = chat_id;
	obj.distance = distance;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.distance];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat_id = [stream readInt];
	self.distance = [stream readInt];
}
@end



@implementation TGcontacts_ForeignLink
@end

@implementation TL_contacts_foreignLinkUnknown
+ (TL_contacts_foreignLinkUnknown *)create {
	TL_contacts_foreignLinkUnknown *obj = [[TL_contacts_foreignLinkUnknown alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_contacts_foreignLinkRequested
+ (TL_contacts_foreignLinkRequested *)createWithHas_phone:(BOOL)has_phone {
	TL_contacts_foreignLinkRequested *obj = [[TL_contacts_foreignLinkRequested alloc] init];
	obj.has_phone = has_phone;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeBool:self.has_phone];
}
- (void)unserialize:(SerializedData *)stream {
	self.has_phone = [stream readBool];
}
@end

@implementation TL_contacts_foreignLinkMutual
+ (TL_contacts_foreignLinkMutual *)create {
	TL_contacts_foreignLinkMutual *obj = [[TL_contacts_foreignLinkMutual alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end



@implementation TGcontacts_MyLink
@end

@implementation TL_contacts_myLinkEmpty
+ (TL_contacts_myLinkEmpty *)create {
	TL_contacts_myLinkEmpty *obj = [[TL_contacts_myLinkEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_contacts_myLinkRequested
+ (TL_contacts_myLinkRequested *)createWithContact:(BOOL)contact {
	TL_contacts_myLinkRequested *obj = [[TL_contacts_myLinkRequested alloc] init];
	obj.contact = contact;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeBool:self.contact];
}
- (void)unserialize:(SerializedData *)stream {
	self.contact = [stream readBool];
}
@end

@implementation TL_contacts_myLinkContact
+ (TL_contacts_myLinkContact *)create {
	TL_contacts_myLinkContact *obj = [[TL_contacts_myLinkContact alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end



@implementation TGcontacts_Link
@end

@implementation TL_contacts_link
+ (TL_contacts_link *)createWithMy_link:(TGcontacts_MyLink *)my_link foreign_link:(TGcontacts_ForeignLink *)foreign_link user:(TGUser *)user {
	TL_contacts_link *obj = [[TL_contacts_link alloc] init];
	obj.my_link = my_link;
	obj.foreign_link = foreign_link;
	obj.user = user;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.my_link stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.foreign_link stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.user stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.my_link = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.foreign_link = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.user = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGcontacts_Contacts
@end

@implementation TL_contacts_contacts
+ (TL_contacts_contacts *)createWithContacts:(NSMutableArray *)contacts users:(NSMutableArray *)users {
	TL_contacts_contacts *obj = [[TL_contacts_contacts alloc] init];
	obj.contacts = contacts;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.contacts count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGContact* obj = [self.contacts objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.contacts)
			self.contacts = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGContact* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.contacts addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end

@implementation TL_contacts_contactsNotModified
+ (TL_contacts_contactsNotModified *)create {
	TL_contacts_contactsNotModified *obj = [[TL_contacts_contactsNotModified alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end



@implementation TGcontacts_ImportedContacts
@end

@implementation TL_contacts_importedContacts
+ (TL_contacts_importedContacts *)createWithImported:(NSMutableArray *)imported retry_contacts:(NSMutableArray *)retry_contacts users:(NSMutableArray *)users {
	TL_contacts_importedContacts *obj = [[TL_contacts_importedContacts alloc] init];
	obj.imported = imported;
	obj.retry_contacts = retry_contacts;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.imported count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGImportedContact* obj = [self.imported objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.retry_contacts count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.retry_contacts objectAtIndex:i];
			[stream writeLong:[obj longValue]];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.imported)
			self.imported = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGImportedContact* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.imported addObject:obj];
		}
	}
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.retry_contacts)
			self.retry_contacts = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			long obj = [stream readLong];
			[self.retry_contacts addObject:[[NSNumber alloc] initWithLong:obj]];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TGcontacts_Blocked
@end

@implementation TL_contacts_blocked
+ (TL_contacts_blocked *)createWithBlocked:(NSMutableArray *)blocked users:(NSMutableArray *)users {
	TL_contacts_blocked *obj = [[TL_contacts_blocked alloc] init];
	obj.blocked = blocked;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.blocked count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGContactBlocked* obj = [self.blocked objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.blocked)
			self.blocked = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGContactBlocked* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.blocked addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end

@implementation TL_contacts_blockedSlice
+ (TL_contacts_blockedSlice *)createWithN_count:(int)n_count blocked:(NSMutableArray *)blocked users:(NSMutableArray *)users {
	TL_contacts_blockedSlice *obj = [[TL_contacts_blockedSlice alloc] init];
	obj.n_count = n_count;
	obj.blocked = blocked;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_count];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.blocked count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGContactBlocked* obj = [self.blocked objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	self.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.blocked)
			self.blocked = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGContactBlocked* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.blocked addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TGcontacts_Found
@end

@implementation TL_contacts_found
+ (TL_contacts_found *)createWithResults:(NSMutableArray *)results users:(NSMutableArray *)users {
	TL_contacts_found *obj = [[TL_contacts_found alloc] init];
	obj.results = results;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.results count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGContactFound* obj = [self.results objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.results)
			self.results = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGContactFound* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.results addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TGcontacts_Suggested
@end

@implementation TL_contacts_suggested
+ (TL_contacts_suggested *)createWithResults:(NSMutableArray *)results users:(NSMutableArray *)users {
	TL_contacts_suggested *obj = [[TL_contacts_suggested alloc] init];
	obj.results = results;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.results count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGContactSuggested* obj = [self.results objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.results)
			self.results = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGContactSuggested* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.results addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TGmessages_Dialogs
@end

@implementation TL_messages_dialogs
+ (TL_messages_dialogs *)createWithDialogs:(NSMutableArray *)dialogs messages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users {
	TL_messages_dialogs *obj = [[TL_messages_dialogs alloc] init];
	obj.dialogs = dialogs;
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.dialogs count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGDialog* obj = [self.dialogs objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGMessage* obj = [self.messages objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.dialogs)
			self.dialogs = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGDialog* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.dialogs addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGMessage* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.messages addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end

@implementation TL_messages_dialogsSlice
+ (TL_messages_dialogsSlice *)createWithN_count:(int)n_count dialogs:(NSMutableArray *)dialogs messages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users {
	TL_messages_dialogsSlice *obj = [[TL_messages_dialogsSlice alloc] init];
	obj.n_count = n_count;
	obj.dialogs = dialogs;
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_count];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.dialogs count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGDialog* obj = [self.dialogs objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGMessage* obj = [self.messages objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	self.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.dialogs)
			self.dialogs = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGDialog* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.dialogs addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGMessage* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.messages addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TGmessages_Messages
@end

@implementation TL_messages_messages
+ (TL_messages_messages *)createWithMessages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users {
	TL_messages_messages *obj = [[TL_messages_messages alloc] init];
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGMessage* obj = [self.messages objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGMessage* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.messages addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end

@implementation TL_messages_messagesSlice
+ (TL_messages_messagesSlice *)createWithN_count:(int)n_count messages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users {
	TL_messages_messagesSlice *obj = [[TL_messages_messagesSlice alloc] init];
	obj.n_count = n_count;
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_count];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGMessage* obj = [self.messages objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	self.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGMessage* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.messages addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TGmessages_Message
@end

@implementation TL_messages_messageEmpty
+ (TL_messages_messageEmpty *)create {
	TL_messages_messageEmpty *obj = [[TL_messages_messageEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_messages_message
+ (TL_messages_message *)createWithMessage:(TGMessage *)message chats:(NSMutableArray *)chats users:(NSMutableArray *)users {
	TL_messages_message *obj = [[TL_messages_message alloc] init];
	obj.message = message;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.message stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	self.message = [[TLClassStore sharedManager] TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TGmessages_StatedMessages
@end

@implementation TL_messages_statedMessages
+ (TL_messages_statedMessages *)createWithMessages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users pts:(int)pts seq:(int)seq {
	TL_messages_statedMessages *obj = [[TL_messages_statedMessages alloc] init];
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	obj.pts = pts;
	obj.seq = seq;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGMessage* obj = [self.messages objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.pts];
	[stream writeInt:self.seq];
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGMessage* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.messages addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
	self.pts = [stream readInt];
	self.seq = [stream readInt];
}
@end

@implementation TL_messages_statedMessagesLinks
+ (TL_messages_statedMessagesLinks *)createWithMessages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users links:(NSMutableArray *)links pts:(int)pts seq:(int)seq {
	TL_messages_statedMessagesLinks *obj = [[TL_messages_statedMessagesLinks alloc] init];
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	obj.links = links;
	obj.pts = pts;
	obj.seq = seq;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGMessage* obj = [self.messages objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.links count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGcontacts_Link* obj = [self.links objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.pts];
	[stream writeInt:self.seq];
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGMessage* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.messages addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.links)
			self.links = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGcontacts_Link* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.links addObject:obj];
		}
	}
	self.pts = [stream readInt];
	self.seq = [stream readInt];
}
@end



@implementation TGmessages_StatedMessage
@end

@implementation TL_messages_statedMessage
+ (TL_messages_statedMessage *)createWithMessage:(TGMessage *)message chats:(NSMutableArray *)chats users:(NSMutableArray *)users pts:(int)pts seq:(int)seq {
	TL_messages_statedMessage *obj = [[TL_messages_statedMessage alloc] init];
	obj.message = message;
	obj.chats = chats;
	obj.users = users;
	obj.pts = pts;
	obj.seq = seq;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.message stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.pts];
	[stream writeInt:self.seq];
}
- (void)unserialize:(SerializedData *)stream {
	self.message = [[TLClassStore sharedManager] TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
	self.pts = [stream readInt];
	self.seq = [stream readInt];
}
@end

@implementation TL_messages_statedMessageLink
+ (TL_messages_statedMessageLink *)createWithMessage:(TGMessage *)message chats:(NSMutableArray *)chats users:(NSMutableArray *)users links:(NSMutableArray *)links pts:(int)pts seq:(int)seq {
	TL_messages_statedMessageLink *obj = [[TL_messages_statedMessageLink alloc] init];
	obj.message = message;
	obj.chats = chats;
	obj.users = users;
	obj.links = links;
	obj.pts = pts;
	obj.seq = seq;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.message stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.links count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGcontacts_Link* obj = [self.links objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.pts];
	[stream writeInt:self.seq];
}
- (void)unserialize:(SerializedData *)stream {
	self.message = [[TLClassStore sharedManager] TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.links)
			self.links = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGcontacts_Link* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.links addObject:obj];
		}
	}
	self.pts = [stream readInt];
	self.seq = [stream readInt];
}
@end



@implementation TGmessages_SentMessage
@end

@implementation TL_messages_sentMessage
+ (TL_messages_sentMessage *)createWithN_id:(int)n_id date:(int)date pts:(int)pts seq:(int)seq {
	TL_messages_sentMessage *obj = [[TL_messages_sentMessage alloc] init];
	obj.n_id = n_id;
	obj.date = date;
	obj.pts = pts;
	obj.seq = seq;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeInt:self.date];
	[stream writeInt:self.pts];
	[stream writeInt:self.seq];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.date = [stream readInt];
	self.pts = [stream readInt];
	self.seq = [stream readInt];
}
@end

@implementation TL_messages_sentMessageLink
+ (TL_messages_sentMessageLink *)createWithN_id:(int)n_id date:(int)date pts:(int)pts seq:(int)seq links:(NSMutableArray *)links {
	TL_messages_sentMessageLink *obj = [[TL_messages_sentMessageLink alloc] init];
	obj.n_id = n_id;
	obj.date = date;
	obj.pts = pts;
	obj.seq = seq;
	obj.links = links;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeInt:self.date];
	[stream writeInt:self.pts];
	[stream writeInt:self.seq];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.links count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGcontacts_Link* obj = [self.links objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.date = [stream readInt];
	self.pts = [stream readInt];
	self.seq = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.links)
			self.links = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGcontacts_Link* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.links addObject:obj];
		}
	}
}
@end



@implementation TGmessages_Chat
@end

@implementation TL_messages_chat
+ (TL_messages_chat *)createWithChat:(TGChat *)chat users:(NSMutableArray *)users {
	TL_messages_chat *obj = [[TL_messages_chat alloc] init];
	obj.chat = chat;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.chat stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	self.chat = [[TLClassStore sharedManager] TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TGmessages_Chats
@end

@implementation TL_messages_chats
+ (TL_messages_chats *)createWithChats:(NSMutableArray *)chats users:(NSMutableArray *)users {
	TL_messages_chats *obj = [[TL_messages_chats alloc] init];
	obj.chats = chats;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TGmessages_ChatFull
@end

@implementation TL_messages_chatFull
+ (TL_messages_chatFull *)createWithFull_chat:(TGChatFull *)full_chat chats:(NSMutableArray *)chats users:(NSMutableArray *)users {
	TL_messages_chatFull *obj = [[TL_messages_chatFull alloc] init];
	obj.full_chat = full_chat;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.full_chat stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	self.full_chat = [[TLClassStore sharedManager] TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TGmessages_AffectedHistory
@end

@implementation TL_messages_affectedHistory
+ (TL_messages_affectedHistory *)createWithPts:(int)pts seq:(int)seq offset:(int)offset {
	TL_messages_affectedHistory *obj = [[TL_messages_affectedHistory alloc] init];
	obj.pts = pts;
	obj.seq = seq;
	obj.offset = offset;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.pts];
	[stream writeInt:self.seq];
	[stream writeInt:self.offset];
}
- (void)unserialize:(SerializedData *)stream {
	self.pts = [stream readInt];
	self.seq = [stream readInt];
	self.offset = [stream readInt];
}
@end



@implementation TGMessagesFilter
@end

@implementation TL_inputMessagesFilterEmpty
+ (TL_inputMessagesFilterEmpty *)create {
	TL_inputMessagesFilterEmpty *obj = [[TL_inputMessagesFilterEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputMessagesFilterPhotos
+ (TL_inputMessagesFilterPhotos *)create {
	TL_inputMessagesFilterPhotos *obj = [[TL_inputMessagesFilterPhotos alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputMessagesFilterVideo
+ (TL_inputMessagesFilterVideo *)create {
	TL_inputMessagesFilterVideo *obj = [[TL_inputMessagesFilterVideo alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputMessagesFilterPhotoVideo
+ (TL_inputMessagesFilterPhotoVideo *)create {
	TL_inputMessagesFilterPhotoVideo *obj = [[TL_inputMessagesFilterPhotoVideo alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputMessagesFilterDocument
+ (TL_inputMessagesFilterDocument *)create {
	TL_inputMessagesFilterDocument *obj = [[TL_inputMessagesFilterDocument alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end



@implementation TGUpdate
@end

@implementation TL_updateNewMessage
+ (TL_updateNewMessage *)createWithMessage:(TGMessage *)message pts:(int)pts {
	TL_updateNewMessage *obj = [[TL_updateNewMessage alloc] init];
	obj.message = message;
	obj.pts = pts;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.message stream:stream];
	[stream writeInt:self.pts];
}
- (void)unserialize:(SerializedData *)stream {
	self.message = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.pts = [stream readInt];
}
@end

@implementation TL_updateMessageID
+ (TL_updateMessageID *)createWithN_id:(int)n_id random_id:(long)random_id {
	TL_updateMessageID *obj = [[TL_updateMessageID alloc] init];
	obj.n_id = n_id;
	obj.random_id = random_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeLong:self.random_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.random_id = [stream readLong];
}
@end

@implementation TL_updateReadMessages
+ (TL_updateReadMessages *)createWithMessages:(NSMutableArray *)messages pts:(int)pts {
	TL_updateReadMessages *obj = [[TL_updateReadMessages alloc] init];
	obj.messages = messages;
	obj.pts = pts;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.messages objectAtIndex:i];
			[stream writeInt:[obj intValue]];
		}
	}
	[stream writeInt:self.pts];
}
- (void)unserialize:(SerializedData *)stream {
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			int obj = [stream readInt];
			[self.messages addObject:[[NSNumber alloc] initWithInt:obj]];
		}
	}
	self.pts = [stream readInt];
}
@end

@implementation TL_updateDeleteMessages
+ (TL_updateDeleteMessages *)createWithMessages:(NSMutableArray *)messages pts:(int)pts {
	TL_updateDeleteMessages *obj = [[TL_updateDeleteMessages alloc] init];
	obj.messages = messages;
	obj.pts = pts;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.messages objectAtIndex:i];
			[stream writeInt:[obj intValue]];
		}
	}
	[stream writeInt:self.pts];
}
- (void)unserialize:(SerializedData *)stream {
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			int obj = [stream readInt];
			[self.messages addObject:[[NSNumber alloc] initWithInt:obj]];
		}
	}
	self.pts = [stream readInt];
}
@end

@implementation TL_updateRestoreMessages
+ (TL_updateRestoreMessages *)createWithMessages:(NSMutableArray *)messages pts:(int)pts {
	TL_updateRestoreMessages *obj = [[TL_updateRestoreMessages alloc] init];
	obj.messages = messages;
	obj.pts = pts;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.messages objectAtIndex:i];
			[stream writeInt:[obj intValue]];
		}
	}
	[stream writeInt:self.pts];
}
- (void)unserialize:(SerializedData *)stream {
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			int obj = [stream readInt];
			[self.messages addObject:[[NSNumber alloc] initWithInt:obj]];
		}
	}
	self.pts = [stream readInt];
}
@end

@implementation TL_updateUserTyping
+ (TL_updateUserTyping *)createWithUser_id:(int)user_id action:(TL_SendMessageAction *)action {
	TL_updateUserTyping *obj = [[TL_updateUserTyping alloc] init];
	obj.user_id = user_id;
    obj.action = action;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
    [[TLClassStore sharedManager] TLSerialize:self.action stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
    self.action = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_updateChatUserTyping
+ (TL_updateChatUserTyping *)createWithChat_id:(int)chat_id user_id:(int)user_id action:(TL_SendMessageAction *)action {
	TL_updateChatUserTyping *obj = [[TL_updateChatUserTyping alloc] init];
	obj.chat_id = chat_id;
	obj.user_id = user_id;
    obj.action = action;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.user_id];
    [[TLClassStore sharedManager] TLSerialize:self.action stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat_id = [stream readInt];
	self.user_id = [stream readInt];
    self.action = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_updateChatParticipants
+ (TL_updateChatParticipants *)createWithParticipants:(TGChatParticipants *)participants {
	TL_updateChatParticipants *obj = [[TL_updateChatParticipants alloc] init];
	obj.participants = participants;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.participants stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.participants = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_updateUserStatus
+ (TL_updateUserStatus *)createWithUser_id:(int)user_id status:(TGUserStatus *)status {
	TL_updateUserStatus *obj = [[TL_updateUserStatus alloc] init];
	obj.user_id = user_id;
	obj.status = status;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
	[[TLClassStore sharedManager] TLSerialize:self.status stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
	self.status = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_updateUserName
+ (TL_updateUserName *)createWithUser_id:(int)user_id first_name:(NSString *)first_name last_name:(NSString *)last_name user_name:(NSString *)user_name {
	TL_updateUserName *obj = [[TL_updateUserName alloc] init];
	obj.user_id = user_id;
	obj.first_name = first_name;
	obj.last_name = last_name;
    obj.user_name = user_name;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
    [stream writeString:self.user_name];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
    self.user_name = [stream readString];
}
@end

@implementation TL_updateUserPhoto
+ (TL_updateUserPhoto *)createWithUser_id:(int)user_id date:(int)date photo:(TGUserProfilePhoto *)photo previous:(BOOL)previous {
	TL_updateUserPhoto *obj = [[TL_updateUserPhoto alloc] init];
	obj.user_id = user_id;
	obj.date = date;
	obj.photo = photo;
	obj.previous = previous;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
	[[TLClassStore sharedManager] TLSerialize:self.photo stream:stream];
	[stream writeBool:self.previous];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
	self.date = [stream readInt];
	self.photo = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.previous = [stream readBool];
}
@end

@implementation TL_updateContactRegistered
+ (TL_updateContactRegistered *)createWithUser_id:(int)user_id date:(int)date {
	TL_updateContactRegistered *obj = [[TL_updateContactRegistered alloc] init];
	obj.user_id = user_id;
	obj.date = date;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
	self.date = [stream readInt];
}
@end

@implementation TL_updateContactLink
+ (TL_updateContactLink *)createWithUser_id:(int)user_id my_link:(TGcontacts_MyLink *)my_link foreign_link:(TGcontacts_ForeignLink *)foreign_link {
	TL_updateContactLink *obj = [[TL_updateContactLink alloc] init];
	obj.user_id = user_id;
	obj.my_link = my_link;
	obj.foreign_link = foreign_link;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
	[[TLClassStore sharedManager] TLSerialize:self.my_link stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.foreign_link stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
	self.my_link = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.foreign_link = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_updateActivation
+ (TL_updateActivation *)createWithUser_id:(int)user_id {
	TL_updateActivation *obj = [[TL_updateActivation alloc] init];
	obj.user_id = user_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
}
@end

@implementation TL_updateNewAuthorization
+ (TL_updateNewAuthorization *)createWithAuth_key_id:(long)auth_key_id date:(int)date device:(NSString *)device location:(NSString *)location {
	TL_updateNewAuthorization *obj = [[TL_updateNewAuthorization alloc] init];
	obj.auth_key_id = auth_key_id;
	obj.date = date;
	obj.device = device;
	obj.location = location;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.auth_key_id];
	[stream writeInt:self.date];
	[stream writeString:self.device];
	[stream writeString:self.location];
}
- (void)unserialize:(SerializedData *)stream {
	self.auth_key_id = [stream readLong];
	self.date = [stream readInt];
	self.device = [stream readString];
	self.location = [stream readString];
}
@end

@implementation TL_updateNewGeoChatMessage
+ (TL_updateNewGeoChatMessage *)createWithGeo_message:(TGGeoChatMessage *)geo_message {
	TL_updateNewGeoChatMessage *obj = [[TL_updateNewGeoChatMessage alloc] init];
	obj.geo_message = geo_message;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.geo_message stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.geo_message = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_updateNewEncryptedMessage
+ (TL_updateNewEncryptedMessage *)createWithEncrypted_message:(TGEncryptedMessage *)encrypted_message qts:(int)qts {
	TL_updateNewEncryptedMessage *obj = [[TL_updateNewEncryptedMessage alloc] init];
	obj.encrypted_message = encrypted_message;
	obj.qts = qts;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.encrypted_message stream:stream];
	[stream writeInt:self.qts];
}
- (void)unserialize:(SerializedData *)stream {
	self.encrypted_message = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.qts = [stream readInt];
}
@end

@implementation TL_updateEncryptedChatTyping
+ (TL_updateEncryptedChatTyping *)createWithChat_id:(int)chat_id {
	TL_updateEncryptedChatTyping *obj = [[TL_updateEncryptedChatTyping alloc] init];
	obj.chat_id = chat_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.chat_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat_id = [stream readInt];
}
@end

@implementation TL_updateEncryption
+ (TL_updateEncryption *)createWithChat:(TGEncryptedChat *)chat date:(int)date {
	TL_updateEncryption *obj = [[TL_updateEncryption alloc] init];
	obj.chat = chat;
	obj.date = date;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.chat stream:stream];
	[stream writeInt:self.date];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.date = [stream readInt];
}
@end

@implementation TL_updateEncryptedMessagesRead
+ (TL_updateEncryptedMessagesRead *)createWithChat_id:(int)chat_id max_date:(int)max_date date:(int)date {
	TL_updateEncryptedMessagesRead *obj = [[TL_updateEncryptedMessagesRead alloc] init];
	obj.chat_id = chat_id;
	obj.max_date = max_date;
	obj.date = date;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.max_date];
	[stream writeInt:self.date];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat_id = [stream readInt];
	self.max_date = [stream readInt];
	self.date = [stream readInt];
}
@end

@implementation TL_updateChatParticipantAdd
+ (TL_updateChatParticipantAdd *)createWithChat_id:(int)chat_id user_id:(int)user_id inviter_id:(int)inviter_id version:(int)version {
	TL_updateChatParticipantAdd *obj = [[TL_updateChatParticipantAdd alloc] init];
	obj.chat_id = chat_id;
	obj.user_id = user_id;
	obj.inviter_id = inviter_id;
	obj.version = version;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.user_id];
	[stream writeInt:self.inviter_id];
	[stream writeInt:self.version];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat_id = [stream readInt];
	self.user_id = [stream readInt];
	self.inviter_id = [stream readInt];
	self.version = [stream readInt];
}
@end

@implementation TL_updateChatParticipantDelete
+ (TL_updateChatParticipantDelete *)createWithChat_id:(int)chat_id user_id:(int)user_id version:(int)version {
	TL_updateChatParticipantDelete *obj = [[TL_updateChatParticipantDelete alloc] init];
	obj.chat_id = chat_id;
	obj.user_id = user_id;
	obj.version = version;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.user_id];
	[stream writeInt:self.version];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat_id = [stream readInt];
	self.user_id = [stream readInt];
	self.version = [stream readInt];
}
@end

@implementation TL_updateDcOptions
+ (TL_updateDcOptions *)createWithDc_options:(NSMutableArray *)dc_options {
	TL_updateDcOptions *obj = [[TL_updateDcOptions alloc] init];
	obj.dc_options = dc_options;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.dc_options count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGDcOption* obj = [self.dc_options objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.dc_options)
			self.dc_options = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGDcOption* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.dc_options addObject:obj];
		}
	}
}
@end

@implementation TL_updateUserBlocked
+ (TL_updateUserBlocked *)createWithUser_id:(int)user_id blocked:(BOOL)blocked {
	TL_updateUserBlocked *obj = [[TL_updateUserBlocked alloc] init];
	obj.user_id = user_id;
	obj.blocked = blocked;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.user_id];
	[stream writeBool:self.blocked];
}
- (void)unserialize:(SerializedData *)stream {
	self.user_id = [stream readInt];
	self.blocked = [stream readBool];
}
@end

@implementation TL_updateNotifySettings
+ (TL_updateNotifySettings *)createWithPeer:(TGNotifyPeer *)peer notify_settings:(TGPeerNotifySettings *)notify_settings {
	TL_updateNotifySettings *obj = [[TL_updateNotifySettings alloc] init];
	obj.peer = peer;
	obj.notify_settings = notify_settings;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[[TLClassStore sharedManager] TLSerialize:self.notify_settings stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.peer = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.notify_settings = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGupdates_State
@end

@implementation TL_updates_state
+ (TL_updates_state *)createWithPts:(int)pts qts:(int)qts date:(int)date seq:(int)seq unread_count:(int)unread_count {
	TL_updates_state *obj = [[TL_updates_state alloc] init];
	obj.pts = pts;
	obj.qts = qts;
	obj.date = date;
	obj.seq = seq;
	obj.unread_count = unread_count;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.pts];
	[stream writeInt:self.qts];
	[stream writeInt:self.date];
	[stream writeInt:self.seq];
	[stream writeInt:self.unread_count];
}
- (void)unserialize:(SerializedData *)stream {
	self.pts = [stream readInt];
	self.qts = [stream readInt];
	self.date = [stream readInt];
	self.seq = [stream readInt];
	self.unread_count = [stream readInt];
}
@end



@implementation TGupdates_Difference
@end

@implementation TL_updates_differenceEmpty
+ (TL_updates_differenceEmpty *)createWithDate:(int)date seq:(int)seq {
	TL_updates_differenceEmpty *obj = [[TL_updates_differenceEmpty alloc] init];
	obj.date = date;
	obj.seq = seq;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.date];
	[stream writeInt:self.seq];
}
- (void)unserialize:(SerializedData *)stream {
	self.date = [stream readInt];
	self.seq = [stream readInt];
}
@end

@implementation TL_updates_difference
+ (TL_updates_difference *)createWithN_messages:(NSMutableArray *)n_messages n_encrypted_messages:(NSMutableArray *)n_encrypted_messages other_updates:(NSMutableArray *)other_updates chats:(NSMutableArray *)chats users:(NSMutableArray *)users state:(TGupdates_State *)state {
	TL_updates_difference *obj = [[TL_updates_difference alloc] init];
	obj.n_messages = n_messages;
	obj.n_encrypted_messages = n_encrypted_messages;
	obj.other_updates = other_updates;
	obj.chats = chats;
	obj.users = users;
	obj.state = state;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGMessage* obj = [self.n_messages objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_encrypted_messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGEncryptedMessage* obj = [self.n_encrypted_messages objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.other_updates count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUpdate* obj = [self.other_updates objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	[[TLClassStore sharedManager] TLSerialize:self.state stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.n_messages)
			self.n_messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGMessage* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.n_messages addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.n_encrypted_messages)
			self.n_encrypted_messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGEncryptedMessage* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.n_encrypted_messages addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.other_updates)
			self.other_updates = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUpdate* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.other_updates addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
	self.state = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_updates_differenceSlice
+ (TL_updates_differenceSlice *)createWithN_messages:(NSMutableArray *)n_messages n_encrypted_messages:(NSMutableArray *)n_encrypted_messages other_updates:(NSMutableArray *)other_updates chats:(NSMutableArray *)chats users:(NSMutableArray *)users intermediate_state:(TGupdates_State *)intermediate_state {
	TL_updates_differenceSlice *obj = [[TL_updates_differenceSlice alloc] init];
	obj.n_messages = n_messages;
	obj.n_encrypted_messages = n_encrypted_messages;
	obj.other_updates = other_updates;
	obj.chats = chats;
	obj.users = users;
	obj.intermediate_state = intermediate_state;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGMessage* obj = [self.n_messages objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_encrypted_messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGEncryptedMessage* obj = [self.n_encrypted_messages objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.other_updates count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUpdate* obj = [self.other_updates objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	[[TLClassStore sharedManager] TLSerialize:self.intermediate_state stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.n_messages)
			self.n_messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGMessage* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.n_messages addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.n_encrypted_messages)
			self.n_encrypted_messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGEncryptedMessage* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.n_encrypted_messages addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.other_updates)
			self.other_updates = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUpdate* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.other_updates addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
	self.intermediate_state = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGUpdates
@end

@implementation TL_updatesTooLong
+ (TL_updatesTooLong *)create {
	TL_updatesTooLong *obj = [[TL_updatesTooLong alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_updateShortMessage
+ (TL_updateShortMessage *)createWithN_id:(int)n_id from_id:(int)from_id message:(NSString *)message pts:(int)pts date:(int)date seq:(int)seq {
	TL_updateShortMessage *obj = [[TL_updateShortMessage alloc] init];
	obj.n_id = n_id;
	obj.from_id = from_id;
	obj.message = message;
	obj.pts = pts;
	obj.date = date;
	obj.seq = seq;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[stream writeString:self.message];
	[stream writeInt:self.pts];
	[stream writeInt:self.date];
	[stream writeInt:self.seq];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.from_id = [stream readInt];
	self.message = [stream readString];
	self.pts = [stream readInt];
	self.date = [stream readInt];
	self.seq = [stream readInt];
}
@end

@implementation TL_updateShortChatMessage
+ (TL_updateShortChatMessage *)createWithN_id:(int)n_id from_id:(int)from_id chat_id:(int)chat_id message:(NSString *)message pts:(int)pts date:(int)date seq:(int)seq {
	TL_updateShortChatMessage *obj = [[TL_updateShortChatMessage alloc] init];
	obj.n_id = n_id;
	obj.from_id = from_id;
	obj.chat_id = chat_id;
	obj.message = message;
	obj.pts = pts;
	obj.date = date;
	obj.seq = seq;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[stream writeInt:self.chat_id];
	[stream writeString:self.message];
	[stream writeInt:self.pts];
	[stream writeInt:self.date];
	[stream writeInt:self.seq];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.from_id = [stream readInt];
	self.chat_id = [stream readInt];
	self.message = [stream readString];
	self.pts = [stream readInt];
	self.date = [stream readInt];
	self.seq = [stream readInt];
}
@end

@implementation TL_updateShort
+ (TL_updateShort *)createWithUpdate:(TGUpdate *)update date:(int)date {
	TL_updateShort *obj = [[TL_updateShort alloc] init];
	obj.update = update;
	obj.date = date;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.update stream:stream];
	[stream writeInt:self.date];
}
- (void)unserialize:(SerializedData *)stream {
	self.update = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.date = [stream readInt];
}
@end

@implementation TL_updatesCombined
+ (TL_updatesCombined *)createWithUpdates:(NSMutableArray *)updates users:(NSMutableArray *)users chats:(NSMutableArray *)chats date:(int)date seq_start:(int)seq_start seq:(int)seq {
	TL_updatesCombined *obj = [[TL_updatesCombined alloc] init];
	obj.updates = updates;
	obj.users = users;
	obj.chats = chats;
	obj.date = date;
	obj.seq_start = seq_start;
	obj.seq = seq;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.updates count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUpdate* obj = [self.updates objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.date];
	[stream writeInt:self.seq_start];
	[stream writeInt:self.seq];
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.updates)
			self.updates = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUpdate* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.updates addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	self.date = [stream readInt];
	self.seq_start = [stream readInt];
	self.seq = [stream readInt];
}
@end

@implementation TL_updates
+ (TL_updates *)createWithUpdates:(NSMutableArray *)updates users:(NSMutableArray *)users chats:(NSMutableArray *)chats date:(int)date seq:(int)seq {
	TL_updates *obj = [[TL_updates alloc] init];
	obj.updates = updates;
	obj.users = users;
	obj.chats = chats;
	obj.date = date;
	obj.seq = seq;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.updates count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUpdate* obj = [self.updates objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.date];
	[stream writeInt:self.seq];
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.updates)
			self.updates = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUpdate* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.updates addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	self.date = [stream readInt];
	self.seq = [stream readInt];
}
@end



@implementation TGphotos_Photos
@end

@implementation TL_photos_photos
+ (TL_photos_photos *)createWithPhotos:(NSMutableArray *)photos users:(NSMutableArray *)users {
	TL_photos_photos *obj = [[TL_photos_photos alloc] init];
	obj.photos = photos;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.photos count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGPhoto* obj = [self.photos objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.photos)
			self.photos = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGPhoto* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.photos addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end

@implementation TL_photos_photosSlice
+ (TL_photos_photosSlice *)createWithN_count:(int)n_count photos:(NSMutableArray *)photos users:(NSMutableArray *)users {
	TL_photos_photosSlice *obj = [[TL_photos_photosSlice alloc] init];
	obj.n_count = n_count;
	obj.photos = photos;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_count];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.photos count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGPhoto* obj = [self.photos objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	self.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.photos)
			self.photos = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGPhoto* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.photos addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TGphotos_Photo
@end

@implementation TL_photos_photo
+ (TL_photos_photo *)createWithPhoto:(TGPhoto *)photo users:(NSMutableArray *)users {
	TL_photos_photo *obj = [[TL_photos_photo alloc] init];
	obj.photo = photo;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.photo stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	self.photo = [[TLClassStore sharedManager] TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TGupload_File
@end

@implementation TL_upload_file
+ (TL_upload_file *)createWithType:(TGstorage_FileType *)type mtime:(int)mtime bytes:(NSData *)bytes {
	TL_upload_file *obj = [[TL_upload_file alloc] init];
	obj.type = type;
	obj.mtime = mtime;
	obj.bytes = bytes;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.type stream:stream];
	[stream writeInt:self.mtime];
	[stream writeByteArray:self.bytes];
}
- (void)unserialize:(SerializedData *)stream {
	self.type = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.mtime = [stream readInt];
	self.bytes = [stream readByteArray];
}
@end



@implementation TGDcOption
@end

@implementation TL_dcOption
+ (TL_dcOption *)createWithN_id:(int)n_id hostname:(NSString *)hostname ip_address:(NSString *)ip_address port:(int)port {
	TL_dcOption *obj = [[TL_dcOption alloc] init];
	obj.n_id = n_id;
	obj.hostname = hostname;
	obj.ip_address = ip_address;
	obj.port = port;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.hostname];
	[stream writeString:self.ip_address];
	[stream writeInt:self.port];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.hostname = [stream readString];
	self.ip_address = [stream readString];
	self.port = [stream readInt];
}
@end



@implementation TGConfig
@end

@implementation TL_config
+ (TL_config *)createWithDate:(int)date test_mode:(BOOL)test_mode this_dc:(int)this_dc dc_options:(NSMutableArray *)dc_options chat_size_max:(int)chat_size_max broadcast_size_max:(int)broadcast_size_max {
	TL_config *obj = [[TL_config alloc] init];
	obj.date = date;
	obj.test_mode = test_mode;
	obj.this_dc = this_dc;
	obj.dc_options = dc_options;
	obj.chat_size_max = chat_size_max;
	obj.broadcast_size_max = broadcast_size_max;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.date];
	[stream writeBool:self.test_mode];
	[stream writeInt:self.this_dc];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.dc_options count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGDcOption* obj = [self.dc_options objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.chat_size_max];
	[stream writeInt:self.broadcast_size_max];
}
- (void)unserialize:(SerializedData *)stream {
	self.date = [stream readInt];
	self.test_mode = [stream readBool];
	self.this_dc = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.dc_options)
			self.dc_options = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGDcOption* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.dc_options addObject:obj];
		}
	}
	self.chat_size_max = [stream readInt];
	self.broadcast_size_max = [stream readInt];
}
@end



@implementation TGNearestDc
@end

@implementation TL_nearestDc
+ (TL_nearestDc *)createWithCountry:(NSString *)country this_dc:(int)this_dc nearest_dc:(int)nearest_dc {
	TL_nearestDc *obj = [[TL_nearestDc alloc] init];
	obj.country = country;
	obj.this_dc = this_dc;
	obj.nearest_dc = nearest_dc;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeString:self.country];
	[stream writeInt:self.this_dc];
	[stream writeInt:self.nearest_dc];
}
- (void)unserialize:(SerializedData *)stream {
	self.country = [stream readString];
	self.this_dc = [stream readInt];
	self.nearest_dc = [stream readInt];
}
@end



@implementation TGhelp_AppUpdate
@end

@implementation TL_help_appUpdate
+ (TL_help_appUpdate *)createWithN_id:(int)n_id critical:(BOOL)critical url:(NSString *)url text:(NSString *)text {
	TL_help_appUpdate *obj = [[TL_help_appUpdate alloc] init];
	obj.n_id = n_id;
	obj.critical = critical;
	obj.url = url;
	obj.text = text;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeBool:self.critical];
	[stream writeString:self.url];
	[stream writeString:self.text];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.critical = [stream readBool];
	self.url = [stream readString];
	self.text = [stream readString];
}
@end

@implementation TL_help_noAppUpdate
+ (TL_help_noAppUpdate *)create {
	TL_help_noAppUpdate *obj = [[TL_help_noAppUpdate alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end



@implementation TGhelp_InviteText
@end

@implementation TL_help_inviteText
+ (TL_help_inviteText *)createWithMessage:(NSString *)message {
	TL_help_inviteText *obj = [[TL_help_inviteText alloc] init];
	obj.message = message;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeString:self.message];
}
- (void)unserialize:(SerializedData *)stream {
	self.message = [stream readString];
}
@end



@implementation TGInputGeoChat
@end

@implementation TL_inputGeoChat
+ (TL_inputGeoChat *)createWithChat_id:(int)chat_id access_hash:(long)access_hash {
	TL_inputGeoChat *obj = [[TL_inputGeoChat alloc] init];
	obj.chat_id = chat_id;
	obj.access_hash = access_hash;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.chat_id];
	[stream writeLong:self.access_hash];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat_id = [stream readInt];
	self.access_hash = [stream readLong];
}
@end



@implementation TGGeoChatMessage
@end

@implementation TL_geoChatMessageEmpty
+ (TL_geoChatMessageEmpty *)createWithChat_id:(int)chat_id n_id:(int)n_id {
	TL_geoChatMessageEmpty *obj = [[TL_geoChatMessageEmpty alloc] init];
	obj.chat_id = chat_id;
	obj.n_id = n_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.n_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat_id = [stream readInt];
	self.n_id = [stream readInt];
}
@end

@implementation TL_geoChatMessage
+ (TL_geoChatMessage *)createWithChat_id:(int)chat_id n_id:(int)n_id from_id:(int)from_id date:(int)date message:(NSString *)message media:(TGMessageMedia *)media {
	TL_geoChatMessage *obj = [[TL_geoChatMessage alloc] init];
	obj.chat_id = chat_id;
	obj.n_id = n_id;
	obj.from_id = from_id;
	obj.date = date;
	obj.message = message;
	obj.media = media;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[stream writeInt:self.date];
	[stream writeString:self.message];
	[[TLClassStore sharedManager] TLSerialize:self.media stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat_id = [stream readInt];
	self.n_id = [stream readInt];
	self.from_id = [stream readInt];
	self.date = [stream readInt];
	self.message = [stream readString];
	self.media = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_geoChatMessageService
+ (TL_geoChatMessageService *)createWithChat_id:(int)chat_id n_id:(int)n_id from_id:(int)from_id date:(int)date action:(TGMessageAction *)action {
	TL_geoChatMessageService *obj = [[TL_geoChatMessageService alloc] init];
	obj.chat_id = chat_id;
	obj.n_id = n_id;
	obj.from_id = from_id;
	obj.date = date;
	obj.action = action;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[stream writeInt:self.date];
	[[TLClassStore sharedManager] TLSerialize:self.action stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat_id = [stream readInt];
	self.n_id = [stream readInt];
	self.from_id = [stream readInt];
	self.date = [stream readInt];
	self.action = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGgeochats_StatedMessage
@end

@implementation TL_geochats_statedMessage
+ (TL_geochats_statedMessage *)createWithMessage:(TGGeoChatMessage *)message chats:(NSMutableArray *)chats users:(NSMutableArray *)users seq:(int)seq {
	TL_geochats_statedMessage *obj = [[TL_geochats_statedMessage alloc] init];
	obj.message = message;
	obj.chats = chats;
	obj.users = users;
	obj.seq = seq;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.message stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.seq];
}
- (void)unserialize:(SerializedData *)stream {
	self.message = [[TLClassStore sharedManager] TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
	self.seq = [stream readInt];
}
@end



@implementation TGgeochats_Located
@end

@implementation TL_geochats_located
+ (TL_geochats_located *)createWithResults:(NSMutableArray *)results messages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users {
	TL_geochats_located *obj = [[TL_geochats_located alloc] init];
	obj.results = results;
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.results count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChatLocated* obj = [self.results objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGGeoChatMessage* obj = [self.messages objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.results)
			self.results = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChatLocated* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.results addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGGeoChatMessage* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.messages addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TGgeochats_Messages
@end

@implementation TL_geochats_messages
+ (TL_geochats_messages *)createWithMessages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users {
	TL_geochats_messages *obj = [[TL_geochats_messages alloc] init];
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGGeoChatMessage* obj = [self.messages objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGGeoChatMessage* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.messages addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end

@implementation TL_geochats_messagesSlice
+ (TL_geochats_messagesSlice *)createWithN_count:(int)n_count messages:(NSMutableArray *)messages chats:(NSMutableArray *)chats users:(NSMutableArray *)users {
	TL_geochats_messagesSlice *obj = [[TL_geochats_messagesSlice alloc] init];
	obj.n_count = n_count;
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_count];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGGeoChatMessage* obj = [self.messages objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGChat* obj = [self.chats objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TGUser* obj = [self.users objectAtIndex:i];
			[[TLClassStore sharedManager] TLSerialize:obj stream:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	self.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGGeoChatMessage* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.messages addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGChat* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TGUser* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TGEncryptedChat
@end

@implementation TL_encryptedChatEmpty
+ (TL_encryptedChatEmpty *)createWithN_id:(int)n_id {
	TL_encryptedChatEmpty *obj = [[TL_encryptedChatEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
}
@end

@implementation TL_encryptedChatWaiting
+ (TL_encryptedChatWaiting *)createWithN_id:(int)n_id access_hash:(long)access_hash date:(int)date admin_id:(int)admin_id participant_id:(int)participant_id {
	TL_encryptedChatWaiting *obj = [[TL_encryptedChatWaiting alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.date = date;
	obj.admin_id = admin_id;
	obj.participant_id = participant_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.date];
	[stream writeInt:self.admin_id];
	[stream writeInt:self.participant_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.access_hash = [stream readLong];
	self.date = [stream readInt];
	self.admin_id = [stream readInt];
	self.participant_id = [stream readInt];
}
@end

@implementation TL_encryptedChatRequested
+ (TL_encryptedChatRequested *)createWithN_id:(int)n_id access_hash:(long)access_hash date:(int)date admin_id:(int)admin_id participant_id:(int)participant_id g_a:(NSData *)g_a {
	TL_encryptedChatRequested *obj = [[TL_encryptedChatRequested alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.date = date;
	obj.admin_id = admin_id;
	obj.participant_id = participant_id;
	obj.g_a = g_a;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.date];
	[stream writeInt:self.admin_id];
	[stream writeInt:self.participant_id];
	[stream writeByteArray:self.g_a];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.access_hash = [stream readLong];
	self.date = [stream readInt];
	self.admin_id = [stream readInt];
	self.participant_id = [stream readInt];
	self.g_a = [stream readByteArray];
}
@end

@implementation TL_encryptedChat
+ (TL_encryptedChat *)createWithN_id:(int)n_id access_hash:(long)access_hash date:(int)date admin_id:(int)admin_id participant_id:(int)participant_id g_a_or_b:(NSData *)g_a_or_b key_fingerprint:(long)key_fingerprint {
	TL_encryptedChat *obj = [[TL_encryptedChat alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.date = date;
	obj.admin_id = admin_id;
	obj.participant_id = participant_id;
	obj.g_a_or_b = g_a_or_b;
	obj.key_fingerprint = key_fingerprint;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.date];
	[stream writeInt:self.admin_id];
	[stream writeInt:self.participant_id];
	[stream writeByteArray:self.g_a_or_b];
	[stream writeLong:self.key_fingerprint];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
	self.access_hash = [stream readLong];
	self.date = [stream readInt];
	self.admin_id = [stream readInt];
	self.participant_id = [stream readInt];
	self.g_a_or_b = [stream readByteArray];
	self.key_fingerprint = [stream readLong];
}
@end

@implementation TL_encryptedChatDiscarded
+ (TL_encryptedChatDiscarded *)createWithN_id:(int)n_id {
	TL_encryptedChatDiscarded *obj = [[TL_encryptedChatDiscarded alloc] init];
	obj.n_id = n_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
}
@end



@implementation TGInputEncryptedChat
@end

@implementation TL_inputEncryptedChat
+ (TL_inputEncryptedChat *)createWithChat_id:(int)chat_id access_hash:(long)access_hash {
	TL_inputEncryptedChat *obj = [[TL_inputEncryptedChat alloc] init];
	obj.chat_id = chat_id;
	obj.access_hash = access_hash;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.chat_id];
	[stream writeLong:self.access_hash];
}
- (void)unserialize:(SerializedData *)stream {
	self.chat_id = [stream readInt];
	self.access_hash = [stream readLong];
}
@end



@implementation TGEncryptedFile
@end

@implementation TL_encryptedFileEmpty
+ (TL_encryptedFileEmpty *)create {
	TL_encryptedFileEmpty *obj = [[TL_encryptedFileEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_encryptedFile
+ (TL_encryptedFile *)createWithN_id:(long)n_id access_hash:(long)access_hash size:(int)size dc_id:(int)dc_id key_fingerprint:(int)key_fingerprint {
	TL_encryptedFile *obj = [[TL_encryptedFile alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.size = size;
	obj.dc_id = dc_id;
	obj.key_fingerprint = key_fingerprint;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.size];
	[stream writeInt:self.dc_id];
	[stream writeInt:self.key_fingerprint];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
	self.size = [stream readInt];
	self.dc_id = [stream readInt];
	self.key_fingerprint = [stream readInt];
}
@end



@implementation TGInputEncryptedFile
@end

@implementation TL_inputEncryptedFileEmpty
+ (TL_inputEncryptedFileEmpty *)create {
	TL_inputEncryptedFileEmpty *obj = [[TL_inputEncryptedFileEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputEncryptedFileUploaded
+ (TL_inputEncryptedFileUploaded *)createWithN_id:(long)n_id parts:(int)parts md5_checksum:(NSString *)md5_checksum key_fingerprint:(int)key_fingerprint {
	TL_inputEncryptedFileUploaded *obj = [[TL_inputEncryptedFileUploaded alloc] init];
	obj.n_id = n_id;
	obj.parts = parts;
	obj.md5_checksum = md5_checksum;
	obj.key_fingerprint = key_fingerprint;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeInt:self.parts];
	[stream writeString:self.md5_checksum];
	[stream writeInt:self.key_fingerprint];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.parts = [stream readInt];
	self.md5_checksum = [stream readString];
	self.key_fingerprint = [stream readInt];
}
@end

@implementation TL_inputEncryptedFile
+ (TL_inputEncryptedFile *)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputEncryptedFile *obj = [[TL_inputEncryptedFile alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end

@implementation TL_inputEncryptedFileBigUploaded
+ (TL_inputEncryptedFileBigUploaded *)createWithN_id:(long)n_id parts:(int)parts key_fingerprint:(int)key_fingerprint {
	TL_inputEncryptedFileBigUploaded *obj = [[TL_inputEncryptedFileBigUploaded alloc] init];
	obj.n_id = n_id;
	obj.parts = parts;
	obj.key_fingerprint = key_fingerprint;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeInt:self.parts];
	[stream writeInt:self.key_fingerprint];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.parts = [stream readInt];
	self.key_fingerprint = [stream readInt];
}
@end



@implementation TGEncryptedMessage
@end

@implementation TL_encryptedMessage
+ (TL_encryptedMessage *)createWithRandom_id:(long)random_id chat_id:(int)chat_id date:(int)date bytes:(NSData *)bytes file:(TGEncryptedFile *)file {
	TL_encryptedMessage *obj = [[TL_encryptedMessage alloc] init];
	obj.random_id = random_id;
	obj.chat_id = chat_id;
	obj.date = date;
	obj.bytes = bytes;
	obj.file = file;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.random_id];
	[stream writeInt:self.chat_id];
	[stream writeInt:self.date];
	[stream writeByteArray:self.bytes];
	[[TLClassStore sharedManager] TLSerialize:self.file stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.random_id = [stream readLong];
	self.chat_id = [stream readInt];
	self.date = [stream readInt];
	self.bytes = [stream readByteArray];
	self.file = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_encryptedMessageService
+ (TL_encryptedMessageService *)createWithRandom_id:(long)random_id chat_id:(int)chat_id date:(int)date bytes:(NSData *)bytes {
	TL_encryptedMessageService *obj = [[TL_encryptedMessageService alloc] init];
	obj.random_id = random_id;
	obj.chat_id = chat_id;
	obj.date = date;
	obj.bytes = bytes;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.random_id];
	[stream writeInt:self.chat_id];
	[stream writeInt:self.date];
	[stream writeByteArray:self.bytes];
}
- (void)unserialize:(SerializedData *)stream {
	self.random_id = [stream readLong];
	self.chat_id = [stream readInt];
	self.date = [stream readInt];
	self.bytes = [stream readByteArray];
}
@end



@implementation TGDecryptedMessageLayer
@end

@implementation TL_decryptedMessageLayer
+ (TL_decryptedMessageLayer *)createWithLayer:(int)layer message:(TGDecryptedMessage *)message {
	TL_decryptedMessageLayer *obj = [[TL_decryptedMessageLayer alloc] init];
	obj.layer = layer;
	obj.message = message;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.layer];
	[[TLClassStore sharedManager] TLSerialize:self.message stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.layer = [stream readInt];
	self.message = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGDecryptedMessage
@end

@implementation TL_decryptedMessage
+ (TL_decryptedMessage *)createWithRandom_id:(long)random_id random_bytes:(NSData *)random_bytes message:(NSString *)message media:(TGDecryptedMessageMedia *)media {
	TL_decryptedMessage *obj = [[TL_decryptedMessage alloc] init];
	obj.random_id = random_id;
	obj.random_bytes = random_bytes;
	obj.message = message;
	obj.media = media;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.random_id];
	[stream writeByteArray:self.random_bytes];
	[stream writeString:self.message];
	[[TLClassStore sharedManager] TLSerialize:self.media stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.random_id = [stream readLong];
	self.random_bytes = [stream readByteArray];
	self.message = [stream readString];
	self.media = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_decryptedMessageService
+ (TL_decryptedMessageService *)createWithRandom_id:(long)random_id random_bytes:(NSData *)random_bytes action:(TGDecryptedMessageAction *)action {
	TL_decryptedMessageService *obj = [[TL_decryptedMessageService alloc] init];
	obj.random_id = random_id;
	obj.random_bytes = random_bytes;
	obj.action = action;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.random_id];
	[stream writeByteArray:self.random_bytes];
	[[TLClassStore sharedManager] TLSerialize:self.action stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.random_id = [stream readLong];
	self.random_bytes = [stream readByteArray];
	self.action = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGDecryptedMessageAction
@end

@implementation TL_decryptedMessageActionSetMessageTTL
+ (TL_decryptedMessageActionSetMessageTTL *)createWithTtl_seconds:(int)ttl_seconds {
	TL_decryptedMessageActionSetMessageTTL *obj = [[TL_decryptedMessageActionSetMessageTTL alloc] init];
	obj.ttl_seconds = ttl_seconds;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.ttl_seconds];
}
- (void)unserialize:(SerializedData *)stream {
	self.ttl_seconds = [stream readInt];
}
@end

@implementation TL_decryptedMessageActionReadMessages
+ (TL_decryptedMessageActionReadMessages *)createWithRandom_ids:(NSMutableArray *)random_ids {
	TL_decryptedMessageActionReadMessages *obj = [[TL_decryptedMessageActionReadMessages alloc] init];
	obj.random_ids = random_ids;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.random_ids count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.random_ids objectAtIndex:i];
			[stream writeLong:[obj longValue]];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.random_ids)
			self.random_ids = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			long obj = [stream readLong];
			[self.random_ids addObject:[[NSNumber alloc] initWithLong:obj]];
		}
	}
}
@end

@implementation TL_decryptedMessageActionDeleteMessages
+ (TL_decryptedMessageActionDeleteMessages *)createWithRandom_ids:(NSMutableArray *)random_ids {
	TL_decryptedMessageActionDeleteMessages *obj = [[TL_decryptedMessageActionDeleteMessages alloc] init];
	obj.random_ids = random_ids;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.random_ids count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.random_ids objectAtIndex:i];
			[stream writeLong:[obj longValue]];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.random_ids)
			self.random_ids = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			long obj = [stream readLong];
			[self.random_ids addObject:[[NSNumber alloc] initWithLong:obj]];
		}
	}
}
@end

@implementation TL_decryptedMessageActionScreenshotMessages
+ (TL_decryptedMessageActionScreenshotMessages *)createWithRandom_ids:(NSMutableArray *)random_ids {
	TL_decryptedMessageActionScreenshotMessages *obj = [[TL_decryptedMessageActionScreenshotMessages alloc] init];
	obj.random_ids = random_ids;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.random_ids count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.random_ids objectAtIndex:i];
			[stream writeLong:[obj longValue]];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.random_ids)
			self.random_ids = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			long obj = [stream readLong];
			[self.random_ids addObject:[[NSNumber alloc] initWithLong:obj]];
		}
	}
}
@end

@implementation TL_decryptedMessageActionFlushHistory
+ (TL_decryptedMessageActionFlushHistory *)create {
	TL_decryptedMessageActionFlushHistory *obj = [[TL_decryptedMessageActionFlushHistory alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_decryptedMessageActionNotifyLayer
+ (TL_decryptedMessageActionNotifyLayer *)createWithLayer:(int)layer {
	TL_decryptedMessageActionNotifyLayer *obj = [[TL_decryptedMessageActionNotifyLayer alloc] init];
	obj.layer = layer;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.layer];
}
- (void)unserialize:(SerializedData *)stream {
	self.layer = [stream readInt];
}
@end



@implementation TGmessages_DhConfig
@end

@implementation TL_messages_dhConfigNotModified
+ (TL_messages_dhConfigNotModified *)createWithRandom:(NSData *)random {
	TL_messages_dhConfigNotModified *obj = [[TL_messages_dhConfigNotModified alloc] init];
	obj.random = random;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeByteArray:self.random];
}
- (void)unserialize:(SerializedData *)stream {
	self.random = [stream readByteArray];
}
@end

@implementation TL_messages_dhConfig
+ (TL_messages_dhConfig *)createWithG:(int)g p:(NSData *)p version:(int)version random:(NSData *)random {
	TL_messages_dhConfig *obj = [[TL_messages_dhConfig alloc] init];
	obj.g = g;
	obj.p = p;
	obj.version = version;
	obj.random = random;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.g];
	[stream writeByteArray:self.p];
	[stream writeInt:self.version];
	[stream writeByteArray:self.random];
}
- (void)unserialize:(SerializedData *)stream {
	self.g = [stream readInt];
	self.p = [stream readByteArray];
	self.version = [stream readInt];
	self.random = [stream readByteArray];
}
@end



@implementation TGmessages_SentEncryptedMessage
@end

@implementation TL_messages_sentEncryptedMessage
+ (TL_messages_sentEncryptedMessage *)createWithDate:(int)date {
	TL_messages_sentEncryptedMessage *obj = [[TL_messages_sentEncryptedMessage alloc] init];
	obj.date = date;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.date];
}
- (void)unserialize:(SerializedData *)stream {
	self.date = [stream readInt];
}
@end

@implementation TL_messages_sentEncryptedFile
+ (TL_messages_sentEncryptedFile *)createWithDate:(int)date file:(TGEncryptedFile *)file {
	TL_messages_sentEncryptedFile *obj = [[TL_messages_sentEncryptedFile alloc] init];
	obj.date = date;
	obj.file = file;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.date];
	[[TLClassStore sharedManager] TLSerialize:self.file stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.date = [stream readInt];
	self.file = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGInputAudio
@end

@implementation TL_inputAudioEmpty
+ (TL_inputAudioEmpty *)create {
	TL_inputAudioEmpty *obj = [[TL_inputAudioEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputAudio
+ (TL_inputAudio *)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputAudio *obj = [[TL_inputAudio alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end



@implementation TGInputDocument
@end

@implementation TL_inputDocumentEmpty
+ (TL_inputDocumentEmpty *)create {
	TL_inputDocumentEmpty *obj = [[TL_inputDocumentEmpty alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_inputDocument
+ (TL_inputDocument *)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputDocument *obj = [[TL_inputDocument alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end



@implementation TGAudio
@end

@implementation TL_audioEmpty
+ (TL_audioEmpty *)createWithN_id:(long)n_id {
	TL_audioEmpty *obj = [[TL_audioEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
}
@end

@implementation TL_audio
+ (TL_audio *)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date duration:(int)duration mime_type:(NSString *)mime_type size:(int)size dc_id:(int)dc_id {
	TL_audio *obj = [[TL_audio alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.user_id = user_id;
	obj.date = date;
	obj.duration = duration;
	obj.mime_type = mime_type;
	obj.size = size;
	obj.dc_id = dc_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
	[stream writeInt:self.duration];
	[stream writeString:self.mime_type];
	[stream writeInt:self.size];
	[stream writeInt:self.dc_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
	self.user_id = [stream readInt];
	self.date = [stream readInt];
	self.duration = [stream readInt];
	self.mime_type = [stream readString];
	self.size = [stream readInt];
	self.dc_id = [stream readInt];
}
@end



@implementation TGDocument
@end

@implementation TL_documentEmpty
+ (TL_documentEmpty *)createWithN_id:(long)n_id {
	TL_documentEmpty *obj = [[TL_documentEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
}
@end

@implementation TL_document
+ (TL_document *)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(int)size thumb:(TGPhotoSize *)thumb dc_id:(int)dc_id {
	TL_document *obj = [[TL_document alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.user_id = user_id;
	obj.date = date;
	obj.file_name = file_name;
	obj.mime_type = mime_type;
	obj.size = size;
	obj.thumb = thumb;
	obj.dc_id = dc_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
	[stream writeString:self.file_name];
	[stream writeString:self.mime_type];
	[stream writeInt:self.size];
	[[TLClassStore sharedManager] TLSerialize:self.thumb stream:stream];
	[stream writeInt:self.dc_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
	self.user_id = [stream readInt];
	self.date = [stream readInt];
	self.file_name = [stream readString];
	self.mime_type = [stream readString];
	self.size = [stream readInt];
	self.thumb = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.dc_id = [stream readInt];
}
@end



@implementation TGhelp_Support
@end

@implementation TL_help_support
+ (TL_help_support *)createWithPhone_number:(NSString *)phone_number user:(TGUser *)user {
	TL_help_support *obj = [[TL_help_support alloc] init];
	obj.phone_number = phone_number;
	obj.user = user;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeString:self.phone_number];
	[[TLClassStore sharedManager] TLSerialize:self.user stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.phone_number = [stream readString];
	self.user = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGNotifyPeer
@end

@implementation TL_notifyPeer
+ (TL_notifyPeer *)createWithPeer:(TGPeer *)peer {
	TL_notifyPeer *obj = [[TL_notifyPeer alloc] init];
	obj.peer = peer;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.peer = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end

@implementation TL_notifyUsers
+ (TL_notifyUsers *)create {
	TL_notifyUsers *obj = [[TL_notifyUsers alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_notifyChats
+ (TL_notifyChats *)create {
	TL_notifyChats *obj = [[TL_notifyChats alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_notifyAll
+ (TL_notifyAll *)create {
	TL_notifyAll *obj = [[TL_notifyAll alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end



@implementation TGProtoMessage
@end

@implementation TL_proto_message
+ (TL_proto_message *)createWithMsg_id:(long)msg_id seqno:(int)seqno bytes:(int)bytes body:(TGObject *)body {
	TL_proto_message *obj = [[TL_proto_message alloc] init];
	obj.msg_id = msg_id;
	obj.seqno = seqno;
	obj.bytes = bytes;
	obj.body = body;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.msg_id];
	[stream writeInt:self.seqno];
	[stream writeInt:self.bytes];
	[[TLClassStore sharedManager] TLSerialize:self.body stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.msg_id = [stream readLong];
	self.seqno = [stream readInt];
	self.bytes = [stream readInt];
	self.body = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGProtoMessageContainer
@end

@implementation TL_msg_container
+ (TL_msg_container *)createWithMessages:(NSMutableArray *)messages {
	TL_msg_container *obj = [[TL_msg_container alloc] init];
	obj.messages = messages;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize ShortVector (custom class) proto_message //TODO
	// [stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TL_proto_message* obj = [self.messages objectAtIndex:i];
			[obj serialize:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS ShortVector (custom class) //TODO
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			TL_proto_message* obj = [[TL_proto_message alloc] init];
			// TL_proto_message* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[obj unserialize:stream];
			[self.messages addObject:obj];
		}
	}
}
@end



@implementation TGResPQ
@end

@implementation TL_req_pq
+ (TL_req_pq *)createWithNonce:(NSData *)nonce {
	TL_req_pq *obj = [[TL_req_pq alloc] init];
	obj.nonce = nonce;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeData:self.nonce];
}
- (void)unserialize:(SerializedData *)stream {
	self.nonce = [stream readData:16];
}
@end

@implementation TL_resPQ
+ (TL_resPQ *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce pq:(NSData *)pq server_public_key_fingerprints:(NSMutableArray *)server_public_key_fingerprints {
	TL_resPQ *obj = [[TL_resPQ alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.pq = pq;
	obj.server_public_key_fingerprints = server_public_key_fingerprints;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeByteArray:self.pq];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.server_public_key_fingerprints count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.server_public_key_fingerprints objectAtIndex:i];
			[stream writeLong:[obj longValue]];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.pq = [stream readByteArray];
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.server_public_key_fingerprints)
			self.server_public_key_fingerprints = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			long obj = [stream readLong];
			[self.server_public_key_fingerprints addObject:[[NSNumber alloc] initWithLong:obj]];
		}
	}
}
@end



@implementation TGServer_DH_inner_data
@end

@implementation TL_server_DH_inner_data
+ (TL_server_DH_inner_data *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce g:(int)g dh_prime:(NSData *)dh_prime g_a:(NSData *)g_a server_time:(int)server_time {
	TL_server_DH_inner_data *obj = [[TL_server_DH_inner_data alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.g = g;
	obj.dh_prime = dh_prime;
	obj.g_a = g_a;
	obj.server_time = server_time;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeInt:self.g];
	[stream writeByteArray:self.dh_prime];
	[stream writeByteArray:self.g_a];
	[stream writeInt:self.server_time];
}
- (void)unserialize:(SerializedData *)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.g = [stream readInt];
	self.dh_prime = [stream readByteArray];
	self.g_a = [stream readByteArray];
	self.server_time = [stream readInt];
}
@end



@implementation TGP_Q_inner_data
@end

@implementation TL_p_q_inner_data
+ (TL_p_q_inner_data *)createWithPq:(NSData *)pq p:(NSData *)p q:(NSData *)q nonce:(NSData *)nonce server_nonce:(NSData *)server_nonce n_nonce:(NSData *)n_nonce {
	TL_p_q_inner_data *obj = [[TL_p_q_inner_data alloc] init];
	obj.pq = pq;
	obj.p = p;
	obj.q = q;
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.n_nonce = n_nonce;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeByteArray:self.pq];
	[stream writeByteArray:self.p];
	[stream writeByteArray:self.q];
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeData:self.n_nonce];
}
- (void)unserialize:(SerializedData *)stream {
	self.pq = [stream readByteArray];
	self.p = [stream readByteArray];
	self.q = [stream readByteArray];
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.n_nonce = [stream readData:32];
}
@end



@implementation TGServer_DH_Params
@end

@implementation TL_req_DH_params
+ (TL_req_DH_params *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce p:(NSData *)p q:(NSData *)q public_key_fingerprint:(long)public_key_fingerprint encrypted_data:(NSData *)encrypted_data {
	TL_req_DH_params *obj = [[TL_req_DH_params alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.p = p;
	obj.q = q;
	obj.public_key_fingerprint = public_key_fingerprint;
	obj.encrypted_data = encrypted_data;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeByteArray:self.p];
	[stream writeByteArray:self.q];
	[stream writeLong:self.public_key_fingerprint];
	[stream writeByteArray:self.encrypted_data];
}
- (void)unserialize:(SerializedData *)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.p = [stream readByteArray];
	self.q = [stream readByteArray];
	self.public_key_fingerprint = [stream readLong];
	self.encrypted_data = [stream readByteArray];
}
@end

@implementation TL_server_DH_params_fail
+ (TL_server_DH_params_fail *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce n_nonce_hash:(NSData *)n_nonce_hash {
	TL_server_DH_params_fail *obj = [[TL_server_DH_params_fail alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.n_nonce_hash = n_nonce_hash;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeData:self.n_nonce_hash];
}
- (void)unserialize:(SerializedData *)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.n_nonce_hash = [stream readData:16];
}
@end

@implementation TL_server_DH_params_ok
+ (TL_server_DH_params_ok *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce encrypted_answer:(NSData *)encrypted_answer {
	TL_server_DH_params_ok *obj = [[TL_server_DH_params_ok alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.encrypted_answer = encrypted_answer;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeByteArray:self.encrypted_answer];
}
- (void)unserialize:(SerializedData *)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.encrypted_answer = [stream readByteArray];
}
@end



@implementation TGClient_DH_Inner_Data
@end

@implementation TL_client_DH_inner_data
+ (TL_client_DH_inner_data *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce retry_id:(long)retry_id g_b:(NSData *)g_b {
	TL_client_DH_inner_data *obj = [[TL_client_DH_inner_data alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.retry_id = retry_id;
	obj.g_b = g_b;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeLong:self.retry_id];
	[stream writeByteArray:self.g_b];
}
- (void)unserialize:(SerializedData *)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.retry_id = [stream readLong];
	self.g_b = [stream readByteArray];
}
@end



@implementation TGSet_client_DH_params_answer
@end

@implementation TL_set_client_DH_params
+ (TL_set_client_DH_params *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce encrypted_data:(NSData *)encrypted_data {
	TL_set_client_DH_params *obj = [[TL_set_client_DH_params alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.encrypted_data = encrypted_data;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeByteArray:self.encrypted_data];
}
- (void)unserialize:(SerializedData *)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.encrypted_data = [stream readByteArray];
}
@end

@implementation TL_dh_gen_ok
+ (TL_dh_gen_ok *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce n_nonce_hash1:(NSData *)n_nonce_hash1 {
	TL_dh_gen_ok *obj = [[TL_dh_gen_ok alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.n_nonce_hash1 = n_nonce_hash1;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeData:self.n_nonce_hash1];
}
- (void)unserialize:(SerializedData *)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.n_nonce_hash1 = [stream readData:16];
}
@end

@implementation TL_dh_gen_retry
+ (TL_dh_gen_retry *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce n_nonce_hash2:(NSData *)n_nonce_hash2 {
	TL_dh_gen_retry *obj = [[TL_dh_gen_retry alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.n_nonce_hash2 = n_nonce_hash2;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeData:self.n_nonce_hash2];
}
- (void)unserialize:(SerializedData *)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.n_nonce_hash2 = [stream readData:16];
}
@end

@implementation TL_dh_gen_fail
+ (TL_dh_gen_fail *)createWithNonce:(NSData *)nonce server_nonce:(NSData *)server_nonce n_nonce_hash3:(NSData *)n_nonce_hash3 {
	TL_dh_gen_fail *obj = [[TL_dh_gen_fail alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.n_nonce_hash3 = n_nonce_hash3;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeData:self.n_nonce_hash3];
}
- (void)unserialize:(SerializedData *)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.n_nonce_hash3 = [stream readData:16];
}
@end



@implementation TGPong
@end

@implementation TL_ping
+ (TL_ping *)createWithPing_id:(long)ping_id {
	TL_ping *obj = [[TL_ping alloc] init];
	obj.ping_id = ping_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.ping_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.ping_id = [stream readLong];
}
@end

@implementation TL_pong
+ (TL_pong *)createWithMsg_id:(long)msg_id ping_id:(long)ping_id {
	TL_pong *obj = [[TL_pong alloc] init];
	obj.msg_id = msg_id;
	obj.ping_id = ping_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.msg_id];
	[stream writeLong:self.ping_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.msg_id = [stream readLong];
	self.ping_id = [stream readLong];
}
@end



@implementation TGBadMsgNotification
@end

@implementation TL_bad_msg_notification
+ (TL_bad_msg_notification *)createWithBad_msg_id:(long)bad_msg_id bad_msg_seqno:(int)bad_msg_seqno error_code:(int)error_code {
	TL_bad_msg_notification *obj = [[TL_bad_msg_notification alloc] init];
	obj.bad_msg_id = bad_msg_id;
	obj.bad_msg_seqno = bad_msg_seqno;
	obj.error_code = error_code;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.bad_msg_id];
	[stream writeInt:self.bad_msg_seqno];
	[stream writeInt:self.error_code];
}
- (void)unserialize:(SerializedData *)stream {
	self.bad_msg_id = [stream readLong];
	self.bad_msg_seqno = [stream readInt];
	self.error_code = [stream readInt];
}
@end

@implementation TL_bad_server_salt
+ (TL_bad_server_salt *)createWithBad_msg_id:(long)bad_msg_id bad_msg_seqno:(int)bad_msg_seqno error_code:(int)error_code new_server_salt:(long)new_server_salt {
	TL_bad_server_salt *obj = [[TL_bad_server_salt alloc] init];
	obj.bad_msg_id = bad_msg_id;
	obj.bad_msg_seqno = bad_msg_seqno;
	obj.error_code = error_code;
	obj.new_server_salt = new_server_salt;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.bad_msg_id];
	[stream writeInt:self.bad_msg_seqno];
	[stream writeInt:self.error_code];
	[stream writeLong:self.new_server_salt];
}
- (void)unserialize:(SerializedData *)stream {
	self.bad_msg_id = [stream readLong];
	self.bad_msg_seqno = [stream readInt];
	self.error_code = [stream readInt];
	self.new_server_salt = [stream readLong];
}
@end



@implementation TGNewSession
@end

@implementation TL_new_session_created
+ (TL_new_session_created *)createWithFirst_msg_id:(long)first_msg_id unique_id:(long)unique_id server_salt:(long)server_salt {
	TL_new_session_created *obj = [[TL_new_session_created alloc] init];
	obj.first_msg_id = first_msg_id;
	obj.unique_id = unique_id;
	obj.server_salt = server_salt;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.first_msg_id];
	[stream writeLong:self.unique_id];
	[stream writeLong:self.server_salt];
}
- (void)unserialize:(SerializedData *)stream {
	self.first_msg_id = [stream readLong];
	self.unique_id = [stream readLong];
	self.server_salt = [stream readLong];
}
@end



@implementation TGRpcResult
@end

@implementation TL_rpc_result
+ (TL_rpc_result *)createWithReq_msg_id:(long)req_msg_id result:(TGObject *)result {
	TL_rpc_result *obj = [[TL_rpc_result alloc] init];
	obj.req_msg_id = req_msg_id;
	obj.result = result;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.req_msg_id];
	[[TLClassStore sharedManager] TLSerialize:self.result stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.req_msg_id = [stream readLong];
	self.result = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGRpcError
@end

@implementation TL_rpc_error
+ (TL_rpc_error *)createWithError_code:(int)error_code error_message:(NSString *)error_message {
	TL_rpc_error *obj = [[TL_rpc_error alloc] init];
	obj.error_code = error_code;
	obj.error_message = error_message;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.error_code];
	[stream writeString:self.error_message];
}
- (void)unserialize:(SerializedData *)stream {
	self.error_code = [stream readInt];
	self.error_message = [stream readString];
}
@end



@implementation TGRSAPublicKey
@end

@implementation TL_rsa_public_key
+ (TL_rsa_public_key *)createWithN:(NSData *)n e:(NSData *)e {
	TL_rsa_public_key *obj = [[TL_rsa_public_key alloc] init];
	obj.n = n;
	obj.e = e;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeByteArray:self.n];
	[stream writeByteArray:self.e];
}
- (void)unserialize:(SerializedData *)stream {
	self.n = [stream readByteArray];
	self.e = [stream readByteArray];
}
@end



@implementation TGMsgsAck
@end

@implementation TL_msgs_ack
+ (TL_msgs_ack *)createWithMsg_ids:(NSMutableArray *)msg_ids {
	TL_msgs_ack *obj = [[TL_msgs_ack alloc] init];
	obj.msg_ids = msg_ids;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.msg_ids count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.msg_ids objectAtIndex:i];
			[stream writeLong:[obj longValue]];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.msg_ids)
			self.msg_ids = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			long obj = [stream readLong];
			[self.msg_ids addObject:[[NSNumber alloc] initWithLong:obj]];
		}
	}
}
@end



@implementation TGRpcDropAnswer
@end

@implementation TL_rpc_drop_answer
+ (TL_rpc_drop_answer *)createWithReq_msg_id:(long)req_msg_id {
	TL_rpc_drop_answer *obj = [[TL_rpc_drop_answer alloc] init];
	obj.req_msg_id = req_msg_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.req_msg_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.req_msg_id = [stream readLong];
}
@end

@implementation TL_rpc_answer_unknown
+ (TL_rpc_answer_unknown *)create {
	TL_rpc_answer_unknown *obj = [[TL_rpc_answer_unknown alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_rpc_answer_dropped_running
+ (TL_rpc_answer_dropped_running *)create {
	TL_rpc_answer_dropped_running *obj = [[TL_rpc_answer_dropped_running alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end

@implementation TL_rpc_answer_dropped
+ (TL_rpc_answer_dropped *)createWithMsg_id:(long)msg_id seq_no:(int)seq_no bytes:(int)bytes {
	TL_rpc_answer_dropped *obj = [[TL_rpc_answer_dropped alloc] init];
	obj.msg_id = msg_id;
	obj.seq_no = seq_no;
	obj.bytes = bytes;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.msg_id];
	[stream writeInt:self.seq_no];
	[stream writeInt:self.bytes];
}
- (void)unserialize:(SerializedData *)stream {
	self.msg_id = [stream readLong];
	self.seq_no = [stream readInt];
	self.bytes = [stream readInt];
}
@end



@implementation TGFutureSalts
@end

@implementation TL_get_future_salts
+ (TL_get_future_salts *)createWithNum:(int)num {
	TL_get_future_salts *obj = [[TL_get_future_salts alloc] init];
	obj.num = num;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.num];
}
- (void)unserialize:(SerializedData *)stream {
	self.num = [stream readInt];
}
@end

@implementation TL_future_salts
+ (TL_future_salts *)createWithReq_msg_id:(long)req_msg_id now:(int)now salts:(NSMutableArray *)salts {
	TL_future_salts *obj = [[TL_future_salts alloc] init];
	obj.req_msg_id = req_msg_id;
	obj.now = now;
	obj.salts = salts;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.req_msg_id];
	[stream writeInt:self.now];
	//Serialize ShortVector (custom class) future_salt //TODO
	// [stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.salts count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TL_future_salt* obj = [self.salts objectAtIndex:i];
			[obj serialize:stream];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	self.req_msg_id = [stream readLong];
	self.now = [stream readInt];
	//UNS ShortVector (custom class) //TODO
	{
		if(!self.salts)
			self.salts = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			TL_future_salt* obj = [[TL_future_salt alloc] init];
			// TL_future_salt* obj = [[TLClassStore sharedManager] TLDeserialize:stream];
			[obj unserialize:stream];
			[self.salts addObject:obj];
		}
	}
}
@end



@implementation TGFutureSalt
@end

@implementation TL_future_salt
+ (TL_future_salt *)createWithValid_since:(int)valid_since valid_until:(int)valid_until salt:(long)salt {
	TL_future_salt *obj = [[TL_future_salt alloc] init];
	obj.valid_since = valid_since;
	obj.valid_until = valid_until;
	obj.salt = salt;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.valid_since];
	[stream writeInt:self.valid_until];
	[stream writeLong:self.salt];
}
- (void)unserialize:(SerializedData *)stream {
	self.valid_since = [stream readInt];
	self.valid_until = [stream readInt];
	self.salt = [stream readLong];
}
@end



@implementation TGDestroySessionRes
@end

@implementation TL_destroy_session
+ (TL_destroy_session *)createWithSession_id:(long)session_id {
	TL_destroy_session *obj = [[TL_destroy_session alloc] init];
	obj.session_id = session_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.session_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.session_id = [stream readLong];
}
@end

@implementation TL_destroy_session_ok
+ (TL_destroy_session_ok *)createWithSession_id:(long)session_id {
	TL_destroy_session_ok *obj = [[TL_destroy_session_ok alloc] init];
	obj.session_id = session_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.session_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.session_id = [stream readLong];
}
@end

@implementation TL_destroy_session_none
+ (TL_destroy_session_none *)createWithSession_id:(long)session_id {
	TL_destroy_session_none *obj = [[TL_destroy_session_none alloc] init];
	obj.session_id = session_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.session_id];
}
- (void)unserialize:(SerializedData *)stream {
	self.session_id = [stream readLong];
}
@end



@implementation TGProtoMessageCopy
@end

@implementation TL_msg_copy
+ (TL_msg_copy *)createWithOrig_message:(TGProtoMessage *)orig_message {
	TL_msg_copy *obj = [[TL_msg_copy alloc] init];
	obj.orig_message = orig_message;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[[TLClassStore sharedManager] TLSerialize:self.orig_message stream:stream];
}
- (void)unserialize:(SerializedData *)stream {
	self.orig_message = [[TLClassStore sharedManager] TLDeserialize:stream];
}
@end



@implementation TGObject
@end

@implementation TL_gzip_packed
+ (TL_gzip_packed *)createWithPacked_data:(NSData *)packed_data {
	TL_gzip_packed *obj = [[TL_gzip_packed alloc] init];
	obj.packed_data = packed_data;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeByteArray:self.packed_data];
}
- (void)unserialize:(SerializedData *)stream {
	self.packed_data = [stream readByteArray];
}
@end



@implementation TGHttpWait
@end

@implementation TL_http_wait
+ (TL_http_wait *)createWithMax_delay:(int)max_delay wait_after:(int)wait_after max_wait:(int)max_wait {
	TL_http_wait *obj = [[TL_http_wait alloc] init];
	obj.max_delay = max_delay;
	obj.wait_after = wait_after;
	obj.max_wait = max_wait;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.max_delay];
	[stream writeInt:self.wait_after];
	[stream writeInt:self.max_wait];
}
- (void)unserialize:(SerializedData *)stream {
	self.max_delay = [stream readInt];
	self.wait_after = [stream readInt];
	self.max_wait = [stream readInt];
}
@end



@implementation TGMsgsStateReq
@end

@implementation TL_msgs_state_req
+ (TL_msgs_state_req *)createWithMsg_ids:(NSMutableArray *)msg_ids {
	TL_msgs_state_req *obj = [[TL_msgs_state_req alloc] init];
	obj.msg_ids = msg_ids;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.msg_ids count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.msg_ids objectAtIndex:i];
			[stream writeLong:[obj longValue]];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.msg_ids)
			self.msg_ids = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			long obj = [stream readLong];
			[self.msg_ids addObject:[[NSNumber alloc] initWithLong:obj]];
		}
	}
}
@end



@implementation TGMsgsStateInfo
@end

@implementation TL_msgs_state_info
+ (TL_msgs_state_info *)createWithReq_msg_id:(long)req_msg_id info:(NSData *)info {
	TL_msgs_state_info *obj = [[TL_msgs_state_info alloc] init];
	obj.req_msg_id = req_msg_id;
	obj.info = info;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.req_msg_id];
	[stream writeByteArray:self.info];
}
- (void)unserialize:(SerializedData *)stream {
	self.req_msg_id = [stream readLong];
	self.info = [stream readByteArray];
}
@end



@implementation TGMsgsAllInfo
@end

@implementation TL_msgs_all_info
+ (TL_msgs_all_info *)createWithMsg_ids:(NSMutableArray *)msg_ids info:(NSData *)info {
	TL_msgs_all_info *obj = [[TL_msgs_all_info alloc] init];
	obj.msg_ids = msg_ids;
	obj.info = info;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.msg_ids count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.msg_ids objectAtIndex:i];
			[stream writeLong:[obj longValue]];
		}
	}
	[stream writeByteArray:self.info];
}
- (void)unserialize:(SerializedData *)stream {
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.msg_ids)
			self.msg_ids = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			long obj = [stream readLong];
			[self.msg_ids addObject:[[NSNumber alloc] initWithLong:obj]];
		}
	}
	self.info = [stream readByteArray];
}
@end



@implementation TGMsgDetailedInfo
@end

@implementation TL_msg_detailed_info
+ (TL_msg_detailed_info *)createWithMsg_id:(long)msg_id answer_msg_id:(long)answer_msg_id bytes:(int)bytes status:(int)status {
	TL_msg_detailed_info *obj = [[TL_msg_detailed_info alloc] init];
	obj.msg_id = msg_id;
	obj.answer_msg_id = answer_msg_id;
	obj.bytes = bytes;
	obj.status = status;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.msg_id];
	[stream writeLong:self.answer_msg_id];
	[stream writeInt:self.bytes];
	[stream writeInt:self.status];
}
- (void)unserialize:(SerializedData *)stream {
	self.msg_id = [stream readLong];
	self.answer_msg_id = [stream readLong];
	self.bytes = [stream readInt];
	self.status = [stream readInt];
}
@end

@implementation TL_msg_new_detailed_info
+ (TL_msg_new_detailed_info *)createWithAnswer_msg_id:(long)answer_msg_id bytes:(int)bytes status:(int)status {
	TL_msg_new_detailed_info *obj = [[TL_msg_new_detailed_info alloc] init];
	obj.answer_msg_id = answer_msg_id;
	obj.bytes = bytes;
	obj.status = status;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.answer_msg_id];
	[stream writeInt:self.bytes];
	[stream writeInt:self.status];
}
- (void)unserialize:(SerializedData *)stream {
	self.answer_msg_id = [stream readLong];
	self.bytes = [stream readInt];
	self.status = [stream readInt];
}
@end



@implementation TGMsgResendReq
@end

@implementation TL_msg_resend_req
+ (TL_msg_resend_req *)createWithMsg_ids:(NSMutableArray *)msg_ids {
	TL_msg_resend_req *obj = [[TL_msg_resend_req alloc] init];
	obj.msg_ids = msg_ids;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.msg_ids count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			NSNumber* obj = [self.msg_ids objectAtIndex:i];
			[stream writeLong:[obj longValue]];
		}
	}
}
- (void)unserialize:(SerializedData *)stream {
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.msg_ids)
			self.msg_ids = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			long obj = [stream readLong];
			[self.msg_ids addObject:[[NSNumber alloc] initWithLong:obj]];
		}
	}
}
@end


@implementation TGPrivacyKey
@end

@implementation TGInputPrivacyRule
@end

@implementation TGPrivacyRule
@end

@implementation TGInputPrivacyKey
@end
