//
//  MTProto.m
//  Telegram
//
//  Auto created by Mikhail Filimonov on 15.12.14.
//  Copyright (c) 2013 Telegram for OS X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTProto.h"
#import "TLClassStore.h"

@implementation TL_boolFalse
+(TL_boolFalse *)create {
	TL_boolFalse* obj = [[TL_boolFalse alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	// [stream writeInt:[[self class] constructor]];
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_boolTrue
+(TL_boolTrue *)create {
	TL_boolTrue* obj = [[TL_boolTrue alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	// [stream writeInt:[[self class] constructor]];
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end




@implementation TLInputPeer
@end

@implementation TL_inputPeerEmpty
+(TL_inputPeerEmpty*)create {
	TL_inputPeerEmpty* obj = [[TL_inputPeerEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputPeerSelf
+(TL_inputPeerSelf*)create {
	TL_inputPeerSelf* obj = [[TL_inputPeerSelf alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputPeerContact
+(TL_inputPeerContact*)createWithUser_id:(int)user_id {
	TL_inputPeerContact* obj = [[TL_inputPeerContact alloc] init];
	obj.user_id = user_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
}
@end

@implementation TL_inputPeerForeign
+(TL_inputPeerForeign*)createWithUser_id:(int)user_id access_hash:(long)access_hash {
	TL_inputPeerForeign* obj = [[TL_inputPeerForeign alloc] init];
	obj.user_id = user_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.access_hash = [stream readLong];
}
@end

@implementation TL_inputPeerChat
+(TL_inputPeerChat*)createWithChat_id:(int)chat_id {
	TL_inputPeerChat* obj = [[TL_inputPeerChat alloc] init];
	obj.chat_id = chat_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat_id = [stream readInt];
}
@end



@implementation TLInputUser
@end

@implementation TL_inputUserEmpty
+(TL_inputUserEmpty*)create {
	TL_inputUserEmpty* obj = [[TL_inputUserEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputUserSelf
+(TL_inputUserSelf*)create {
	TL_inputUserSelf* obj = [[TL_inputUserSelf alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputUserContact
+(TL_inputUserContact*)createWithUser_id:(int)user_id {
	TL_inputUserContact* obj = [[TL_inputUserContact alloc] init];
	obj.user_id = user_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
}
@end

@implementation TL_inputUserForeign
+(TL_inputUserForeign*)createWithUser_id:(int)user_id access_hash:(long)access_hash {
	TL_inputUserForeign* obj = [[TL_inputUserForeign alloc] init];
	obj.user_id = user_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.access_hash = [stream readLong];
}
@end



@implementation TLInputContact
@end

@implementation TL_inputPhoneContact
+(TL_inputPhoneContact*)createWithClient_id:(long)client_id phone:(NSString*)phone first_name:(NSString*)first_name last_name:(NSString*)last_name {
	TL_inputPhoneContact* obj = [[TL_inputPhoneContact alloc] init];
	obj.client_id = client_id;
	obj.phone = phone;
	obj.first_name = first_name;
	obj.last_name = last_name;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.client_id];
	[stream writeString:self.phone];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
}
-(void)unserialize:(SerializedData*)stream {
	self.client_id = [stream readLong];
	self.phone = [stream readString];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
}
@end



@implementation TLInputFile
@end

@implementation TL_inputFile
+(TL_inputFile*)createWithN_id:(long)n_id parts:(int)parts name:(NSString*)name md5_checksum:(NSString*)md5_checksum {
	TL_inputFile* obj = [[TL_inputFile alloc] init];
	obj.n_id = n_id;
	obj.parts = parts;
	obj.name = name;
	obj.md5_checksum = md5_checksum;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeInt:self.parts];
	[stream writeString:self.name];
	[stream writeString:self.md5_checksum];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.parts = [stream readInt];
	self.name = [stream readString];
	self.md5_checksum = [stream readString];
}
@end

@implementation TL_inputFileBig
+(TL_inputFileBig*)createWithN_id:(long)n_id parts:(int)parts name:(NSString*)name {
	TL_inputFileBig* obj = [[TL_inputFileBig alloc] init];
	obj.n_id = n_id;
	obj.parts = parts;
	obj.name = name;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeInt:self.parts];
	[stream writeString:self.name];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.parts = [stream readInt];
	self.name = [stream readString];
}
@end



@implementation TLInputMedia
@end

@implementation TL_inputMediaEmpty
+(TL_inputMediaEmpty*)create {
	TL_inputMediaEmpty* obj = [[TL_inputMediaEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputMediaUploadedPhoto
+(TL_inputMediaUploadedPhoto*)createWithFile:(TLInputFile*)file {
	TL_inputMediaUploadedPhoto* obj = [[TL_inputMediaUploadedPhoto alloc] init];
	obj.file = file;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.file stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_inputMediaPhoto
+(TL_inputMediaPhoto*)createWithN_id:(TLInputPhoto*)n_id {
	TL_inputMediaPhoto* obj = [[TL_inputMediaPhoto alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.n_id stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_inputMediaGeoPoint
+(TL_inputMediaGeoPoint*)createWithGeo_point:(TLInputGeoPoint*)geo_point {
	TL_inputMediaGeoPoint* obj = [[TL_inputMediaGeoPoint alloc] init];
	obj.geo_point = geo_point;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.geo_point stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.geo_point = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_inputMediaContact
+(TL_inputMediaContact*)createWithPhone_number:(NSString*)phone_number first_name:(NSString*)first_name last_name:(NSString*)last_name {
	TL_inputMediaContact* obj = [[TL_inputMediaContact alloc] init];
	obj.phone_number = phone_number;
	obj.first_name = first_name;
	obj.last_name = last_name;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.phone_number];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
}
-(void)unserialize:(SerializedData*)stream {
	self.phone_number = [stream readString];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
}
@end

@implementation TL_inputMediaUploadedVideo
+(TL_inputMediaUploadedVideo*)createWithFile:(TLInputFile*)file duration:(int)duration w:(int)w h:(int)h mime_type:(NSString*)mime_type {
	TL_inputMediaUploadedVideo* obj = [[TL_inputMediaUploadedVideo alloc] init];
	obj.file = file;
	obj.duration = duration;
	obj.w = w;
	obj.h = h;
	obj.mime_type = mime_type;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.file stream:stream];
	[stream writeInt:self.duration];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeString:self.mime_type];
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [TLClassStore TLDeserialize:stream];
	self.duration = [stream readInt];
	self.w = [stream readInt];
	self.h = [stream readInt];
	self.mime_type = [stream readString];
}
@end

@implementation TL_inputMediaUploadedThumbVideo
+(TL_inputMediaUploadedThumbVideo*)createWithFile:(TLInputFile*)file thumb:(TLInputFile*)thumb duration:(int)duration w:(int)w h:(int)h mime_type:(NSString*)mime_type {
	TL_inputMediaUploadedThumbVideo* obj = [[TL_inputMediaUploadedThumbVideo alloc] init];
	obj.file = file;
	obj.thumb = thumb;
	obj.duration = duration;
	obj.w = w;
	obj.h = h;
	obj.mime_type = mime_type;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.file stream:stream];
	[TLClassStore TLSerialize:self.thumb stream:stream];
	[stream writeInt:self.duration];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeString:self.mime_type];
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [TLClassStore TLDeserialize:stream];
	self.thumb = [TLClassStore TLDeserialize:stream];
	self.duration = [stream readInt];
	self.w = [stream readInt];
	self.h = [stream readInt];
	self.mime_type = [stream readString];
}
@end

@implementation TL_inputMediaVideo
+(TL_inputMediaVideo*)createWithN_id:(TLInputVideo*)n_id {
	TL_inputMediaVideo* obj = [[TL_inputMediaVideo alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.n_id stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_inputMediaUploadedAudio
+(TL_inputMediaUploadedAudio*)createWithFile:(TLInputFile*)file duration:(int)duration mime_type:(NSString*)mime_type {
	TL_inputMediaUploadedAudio* obj = [[TL_inputMediaUploadedAudio alloc] init];
	obj.file = file;
	obj.duration = duration;
	obj.mime_type = mime_type;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.file stream:stream];
	[stream writeInt:self.duration];
	[stream writeString:self.mime_type];
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [TLClassStore TLDeserialize:stream];
	self.duration = [stream readInt];
	self.mime_type = [stream readString];
}
@end

@implementation TL_inputMediaAudio
+(TL_inputMediaAudio*)createWithN_id:(TLInputAudio*)n_id {
	TL_inputMediaAudio* obj = [[TL_inputMediaAudio alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.n_id stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_inputMediaUploadedDocument
+(TL_inputMediaUploadedDocument*)createWithFile:(TLInputFile*)file mime_type:(NSString*)mime_type attributes:(NSMutableArray*)attributes {
	TL_inputMediaUploadedDocument* obj = [[TL_inputMediaUploadedDocument alloc] init];
	obj.file = file;
	obj.mime_type = mime_type;
	obj.attributes = attributes;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.file stream:stream];
	[stream writeString:self.mime_type];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.attributes count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLDocumentAttribute* obj = [self.attributes objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [TLClassStore TLDeserialize:stream];
	self.mime_type = [stream readString];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.attributes)
			self.attributes = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLDocumentAttribute* obj = [TLClassStore TLDeserialize:stream];
			[self.attributes addObject:obj];
		}
	}
}
@end

@implementation TL_inputMediaUploadedThumbDocument
+(TL_inputMediaUploadedThumbDocument*)createWithFile:(TLInputFile*)file thumb:(TLInputFile*)thumb mime_type:(NSString*)mime_type attributes:(NSMutableArray*)attributes {
	TL_inputMediaUploadedThumbDocument* obj = [[TL_inputMediaUploadedThumbDocument alloc] init];
	obj.file = file;
	obj.thumb = thumb;
	obj.mime_type = mime_type;
	obj.attributes = attributes;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.file stream:stream];
	[TLClassStore TLSerialize:self.thumb stream:stream];
	[stream writeString:self.mime_type];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.attributes count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLDocumentAttribute* obj = [self.attributes objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [TLClassStore TLDeserialize:stream];
	self.thumb = [TLClassStore TLDeserialize:stream];
	self.mime_type = [stream readString];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.attributes)
			self.attributes = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLDocumentAttribute* obj = [TLClassStore TLDeserialize:stream];
			[self.attributes addObject:obj];
		}
	}
}
@end

@implementation TL_inputMediaDocument
+(TL_inputMediaDocument*)createWithN_id:(TLInputDocument*)n_id {
	TL_inputMediaDocument* obj = [[TL_inputMediaDocument alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.n_id stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLInputChatPhoto
@end

@implementation TL_inputChatPhotoEmpty
+(TL_inputChatPhotoEmpty*)create {
	TL_inputChatPhotoEmpty* obj = [[TL_inputChatPhotoEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputChatUploadedPhoto
+(TL_inputChatUploadedPhoto*)createWithFile:(TLInputFile*)file crop:(TLInputPhotoCrop*)crop {
	TL_inputChatUploadedPhoto* obj = [[TL_inputChatUploadedPhoto alloc] init];
	obj.file = file;
	obj.crop = crop;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.file stream:stream];
	[TLClassStore TLSerialize:self.crop stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [TLClassStore TLDeserialize:stream];
	self.crop = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_inputChatPhoto
+(TL_inputChatPhoto*)createWithN_id:(TLInputPhoto*)n_id crop:(TLInputPhotoCrop*)crop {
	TL_inputChatPhoto* obj = [[TL_inputChatPhoto alloc] init];
	obj.n_id = n_id;
	obj.crop = crop;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.n_id stream:stream];
	[TLClassStore TLSerialize:self.crop stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [TLClassStore TLDeserialize:stream];
	self.crop = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLInputGeoPoint
@end

@implementation TL_inputGeoPointEmpty
+(TL_inputGeoPointEmpty*)create {
	TL_inputGeoPointEmpty* obj = [[TL_inputGeoPointEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputGeoPoint
+(TL_inputGeoPoint*)createWithLat:(double)lat n_long:(double)n_long {
	TL_inputGeoPoint* obj = [[TL_inputGeoPoint alloc] init];
	obj.lat = lat;
	obj.n_long = n_long;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeDouble:self.lat];
	[stream writeDouble:self.n_long];
}
-(void)unserialize:(SerializedData*)stream {
	self.lat = [stream readDouble];
	self.n_long = [stream readDouble];
}
@end



@implementation TLInputPhoto
@end

@implementation TL_inputPhotoEmpty
+(TL_inputPhotoEmpty*)create {
	TL_inputPhotoEmpty* obj = [[TL_inputPhotoEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputPhoto
+(TL_inputPhoto*)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputPhoto* obj = [[TL_inputPhoto alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end



@implementation TLInputVideo
@end

@implementation TL_inputVideoEmpty
+(TL_inputVideoEmpty*)create {
	TL_inputVideoEmpty* obj = [[TL_inputVideoEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputVideo
+(TL_inputVideo*)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputVideo* obj = [[TL_inputVideo alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end



@implementation TLInputFileLocation
@end

@implementation TL_inputFileLocation
+(TL_inputFileLocation*)createWithVolume_id:(long)volume_id local_id:(int)local_id secret:(long)secret {
	TL_inputFileLocation* obj = [[TL_inputFileLocation alloc] init];
	obj.volume_id = volume_id;
	obj.local_id = local_id;
	obj.secret = secret;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.volume_id];
	[stream writeInt:self.local_id];
	[stream writeLong:self.secret];
}
-(void)unserialize:(SerializedData*)stream {
	self.volume_id = [stream readLong];
	self.local_id = [stream readInt];
	self.secret = [stream readLong];
}
@end

@implementation TL_inputVideoFileLocation
+(TL_inputVideoFileLocation*)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputVideoFileLocation* obj = [[TL_inputVideoFileLocation alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end

@implementation TL_inputEncryptedFileLocation
+(TL_inputEncryptedFileLocation*)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputEncryptedFileLocation* obj = [[TL_inputEncryptedFileLocation alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end

@implementation TL_inputAudioFileLocation
+(TL_inputAudioFileLocation*)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputAudioFileLocation* obj = [[TL_inputAudioFileLocation alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end

@implementation TL_inputDocumentFileLocation
+(TL_inputDocumentFileLocation*)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputDocumentFileLocation* obj = [[TL_inputDocumentFileLocation alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end



@implementation TLInputPhotoCrop
@end

@implementation TL_inputPhotoCropAuto
+(TL_inputPhotoCropAuto*)create {
	TL_inputPhotoCropAuto* obj = [[TL_inputPhotoCropAuto alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputPhotoCrop
+(TL_inputPhotoCrop*)createWithCrop_left:(double)crop_left crop_top:(double)crop_top crop_width:(double)crop_width {
	TL_inputPhotoCrop* obj = [[TL_inputPhotoCrop alloc] init];
	obj.crop_left = crop_left;
	obj.crop_top = crop_top;
	obj.crop_width = crop_width;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeDouble:self.crop_left];
	[stream writeDouble:self.crop_top];
	[stream writeDouble:self.crop_width];
}
-(void)unserialize:(SerializedData*)stream {
	self.crop_left = [stream readDouble];
	self.crop_top = [stream readDouble];
	self.crop_width = [stream readDouble];
}
@end



@implementation TLInputAppEvent
@end

@implementation TL_inputAppEvent
+(TL_inputAppEvent*)createWithTime:(double)time type:(NSString*)type peer:(long)peer data:(NSString*)data {
	TL_inputAppEvent* obj = [[TL_inputAppEvent alloc] init];
	obj.time = time;
	obj.type = type;
	obj.peer = peer;
	obj.data = data;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeDouble:self.time];
	[stream writeString:self.type];
	[stream writeLong:self.peer];
	[stream writeString:self.data];
}
-(void)unserialize:(SerializedData*)stream {
	self.time = [stream readDouble];
	self.type = [stream readString];
	self.peer = [stream readLong];
	self.data = [stream readString];
}
@end



@implementation TLPeer
@end

@implementation TL_peerUser
+(TL_peerUser*)createWithUser_id:(int)user_id {
	TL_peerUser* obj = [[TL_peerUser alloc] init];
	obj.user_id = user_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
}
@end

@implementation TL_peerChat
+(TL_peerChat*)createWithChat_id:(int)chat_id {
	TL_peerChat* obj = [[TL_peerChat alloc] init];
	obj.chat_id = chat_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat_id = [stream readInt];
}
@end



@implementation TLstorage_FileType
@end

@implementation TL_storage_fileUnknown
+(TL_storage_fileUnknown*)create {
	TL_storage_fileUnknown* obj = [[TL_storage_fileUnknown alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_storage_fileJpeg
+(TL_storage_fileJpeg*)create {
	TL_storage_fileJpeg* obj = [[TL_storage_fileJpeg alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_storage_fileGif
+(TL_storage_fileGif*)create {
	TL_storage_fileGif* obj = [[TL_storage_fileGif alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_storage_filePng
+(TL_storage_filePng*)create {
	TL_storage_filePng* obj = [[TL_storage_filePng alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_storage_filePdf
+(TL_storage_filePdf*)create {
	TL_storage_filePdf* obj = [[TL_storage_filePdf alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_storage_fileMp3
+(TL_storage_fileMp3*)create {
	TL_storage_fileMp3* obj = [[TL_storage_fileMp3 alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_storage_fileMov
+(TL_storage_fileMov*)create {
	TL_storage_fileMov* obj = [[TL_storage_fileMov alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_storage_filePartial
+(TL_storage_filePartial*)create {
	TL_storage_filePartial* obj = [[TL_storage_filePartial alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_storage_fileMp4
+(TL_storage_fileMp4*)create {
	TL_storage_fileMp4* obj = [[TL_storage_fileMp4 alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_storage_fileWebp
+(TL_storage_fileWebp*)create {
	TL_storage_fileWebp* obj = [[TL_storage_fileWebp alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end



@implementation TLFileLocation
@end

@implementation TL_fileLocationUnavailable
+(TL_fileLocationUnavailable*)createWithVolume_id:(long)volume_id local_id:(int)local_id secret:(long)secret {
	TL_fileLocationUnavailable* obj = [[TL_fileLocationUnavailable alloc] init];
	obj.volume_id = volume_id;
	obj.local_id = local_id;
	obj.secret = secret;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.volume_id];
	[stream writeInt:self.local_id];
	[stream writeLong:self.secret];
}
-(void)unserialize:(SerializedData*)stream {
	self.volume_id = [stream readLong];
	self.local_id = [stream readInt];
	self.secret = [stream readLong];
}
@end

@implementation TL_fileLocation
+(TL_fileLocation*)createWithDc_id:(int)dc_id volume_id:(long)volume_id local_id:(int)local_id secret:(long)secret {
	TL_fileLocation* obj = [[TL_fileLocation alloc] init];
	obj.dc_id = dc_id;
	obj.volume_id = volume_id;
	obj.local_id = local_id;
	obj.secret = secret;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.dc_id];
	[stream writeLong:self.volume_id];
	[stream writeInt:self.local_id];
	[stream writeLong:self.secret];
}
-(void)unserialize:(SerializedData*)stream {
	self.dc_id = [stream readInt];
	self.volume_id = [stream readLong];
	self.local_id = [stream readInt];
	self.secret = [stream readLong];
}
@end



@implementation TLUser
@end

@implementation TL_userEmpty
+(TL_userEmpty*)createWithN_id:(int)n_id {
	TL_userEmpty* obj = [[TL_userEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
}
@end

@implementation TL_userSelf
+(TL_userSelf*)createWithN_id:(int)n_id first_name:(NSString*)first_name last_name:(NSString*)last_name username:(NSString*)username phone:(NSString*)phone photo:(TLUserProfilePhoto*)photo status:(TLUserStatus*)status inactive:(Boolean)inactive {
	TL_userSelf* obj = [[TL_userSelf alloc] init];
	obj.n_id = n_id;
	obj.first_name = first_name;
	obj.last_name = last_name;
	obj.username = username;
	obj.phone = phone;
	obj.photo = photo;
	obj.status = status;
	obj.inactive = inactive;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
	[stream writeString:self.username];
	[stream writeString:self.phone];
	[TLClassStore TLSerialize:self.photo stream:stream];
	[TLClassStore TLSerialize:self.status stream:stream];
	[stream writeBool:self.inactive];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
	self.username = [stream readString];
	self.phone = [stream readString];
	self.photo = [TLClassStore TLDeserialize:stream];
	self.status = [TLClassStore TLDeserialize:stream];
	self.inactive = [stream readBool];
}
@end

@implementation TL_userContact
+(TL_userContact*)createWithN_id:(int)n_id first_name:(NSString*)first_name last_name:(NSString*)last_name username:(NSString*)username access_hash:(long)access_hash phone:(NSString*)phone photo:(TLUserProfilePhoto*)photo status:(TLUserStatus*)status {
	TL_userContact* obj = [[TL_userContact alloc] init];
	obj.n_id = n_id;
	obj.first_name = first_name;
	obj.last_name = last_name;
	obj.username = username;
	obj.access_hash = access_hash;
	obj.phone = phone;
	obj.photo = photo;
	obj.status = status;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
	[stream writeString:self.username];
	[stream writeLong:self.access_hash];
	[stream writeString:self.phone];
	[TLClassStore TLSerialize:self.photo stream:stream];
	[TLClassStore TLSerialize:self.status stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
	self.username = [stream readString];
	self.access_hash = [stream readLong];
	self.phone = [stream readString];
	self.photo = [TLClassStore TLDeserialize:stream];
	self.status = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_userRequest
+(TL_userRequest*)createWithN_id:(int)n_id first_name:(NSString*)first_name last_name:(NSString*)last_name username:(NSString*)username access_hash:(long)access_hash phone:(NSString*)phone photo:(TLUserProfilePhoto*)photo status:(TLUserStatus*)status {
	TL_userRequest* obj = [[TL_userRequest alloc] init];
	obj.n_id = n_id;
	obj.first_name = first_name;
	obj.last_name = last_name;
	obj.username = username;
	obj.access_hash = access_hash;
	obj.phone = phone;
	obj.photo = photo;
	obj.status = status;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
	[stream writeString:self.username];
	[stream writeLong:self.access_hash];
	[stream writeString:self.phone];
	[TLClassStore TLSerialize:self.photo stream:stream];
	[TLClassStore TLSerialize:self.status stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
	self.username = [stream readString];
	self.access_hash = [stream readLong];
	self.phone = [stream readString];
	self.photo = [TLClassStore TLDeserialize:stream];
	self.status = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_userForeign
+(TL_userForeign*)createWithN_id:(int)n_id first_name:(NSString*)first_name last_name:(NSString*)last_name username:(NSString*)username access_hash:(long)access_hash photo:(TLUserProfilePhoto*)photo status:(TLUserStatus*)status {
	TL_userForeign* obj = [[TL_userForeign alloc] init];
	obj.n_id = n_id;
	obj.first_name = first_name;
	obj.last_name = last_name;
	obj.username = username;
	obj.access_hash = access_hash;
	obj.photo = photo;
	obj.status = status;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
	[stream writeString:self.username];
	[stream writeLong:self.access_hash];
	[TLClassStore TLSerialize:self.photo stream:stream];
	[TLClassStore TLSerialize:self.status stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
	self.username = [stream readString];
	self.access_hash = [stream readLong];
	self.photo = [TLClassStore TLDeserialize:stream];
	self.status = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_userDeleted
+(TL_userDeleted*)createWithN_id:(int)n_id first_name:(NSString*)first_name last_name:(NSString*)last_name username:(NSString*)username {
	TL_userDeleted* obj = [[TL_userDeleted alloc] init];
	obj.n_id = n_id;
	obj.first_name = first_name;
	obj.last_name = last_name;
	obj.username = username;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
	[stream writeString:self.username];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
	self.username = [stream readString];
}
@end



@implementation TLUserProfilePhoto
@end

@implementation TL_userProfilePhotoEmpty
+(TL_userProfilePhotoEmpty*)create {
	TL_userProfilePhotoEmpty* obj = [[TL_userProfilePhotoEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_userProfilePhoto
+(TL_userProfilePhoto*)createWithPhoto_id:(long)photo_id photo_small:(TLFileLocation*)photo_small photo_big:(TLFileLocation*)photo_big {
	TL_userProfilePhoto* obj = [[TL_userProfilePhoto alloc] init];
	obj.photo_id = photo_id;
	obj.photo_small = photo_small;
	obj.photo_big = photo_big;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.photo_id];
	[TLClassStore TLSerialize:self.photo_small stream:stream];
	[TLClassStore TLSerialize:self.photo_big stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.photo_id = [stream readLong];
	self.photo_small = [TLClassStore TLDeserialize:stream];
	self.photo_big = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLUserStatus
@end

@implementation TL_userStatusEmpty
+(TL_userStatusEmpty*)create {
	TL_userStatusEmpty* obj = [[TL_userStatusEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_userStatusOnline
+(TL_userStatusOnline*)createWithExpires:(int)expires {
	TL_userStatusOnline* obj = [[TL_userStatusOnline alloc] init];
	obj.expires = expires;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.expires];
}
-(void)unserialize:(SerializedData*)stream {
	self.expires = [stream readInt];
}
@end

@implementation TL_userStatusOffline
+(TL_userStatusOffline*)createWithWas_online:(int)was_online {
	TL_userStatusOffline* obj = [[TL_userStatusOffline alloc] init];
	obj.was_online = was_online;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.was_online];
}
-(void)unserialize:(SerializedData*)stream {
	self.was_online = [stream readInt];
}
@end

@implementation TL_userStatusRecently
+(TL_userStatusRecently*)create {
	TL_userStatusRecently* obj = [[TL_userStatusRecently alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_userStatusLastWeek
+(TL_userStatusLastWeek*)create {
	TL_userStatusLastWeek* obj = [[TL_userStatusLastWeek alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_userStatusLastMonth
+(TL_userStatusLastMonth*)create {
	TL_userStatusLastMonth* obj = [[TL_userStatusLastMonth alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end



@implementation TLChat
@end

@implementation TL_chatEmpty
+(TL_chatEmpty*)createWithN_id:(int)n_id {
	TL_chatEmpty* obj = [[TL_chatEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
}
@end

@implementation TL_chat
+(TL_chat*)createWithN_id:(int)n_id title:(NSString*)title photo:(TLChatPhoto*)photo participants_count:(int)participants_count date:(int)date left:(Boolean)left version:(int)version {
	TL_chat* obj = [[TL_chat alloc] init];
	obj.n_id = n_id;
	obj.title = title;
	obj.photo = photo;
	obj.participants_count = participants_count;
	obj.date = date;
	obj.left = left;
	obj.version = version;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.title];
	[TLClassStore TLSerialize:self.photo stream:stream];
	[stream writeInt:self.participants_count];
	[stream writeInt:self.date];
	[stream writeBool:self.left];
	[stream writeInt:self.version];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.title = [stream readString];
	self.photo = [TLClassStore TLDeserialize:stream];
	self.participants_count = [stream readInt];
	self.date = [stream readInt];
	self.left = [stream readBool];
	self.version = [stream readInt];
}
@end

@implementation TL_chatForbidden
+(TL_chatForbidden*)createWithN_id:(int)n_id title:(NSString*)title date:(int)date {
	TL_chatForbidden* obj = [[TL_chatForbidden alloc] init];
	obj.n_id = n_id;
	obj.title = title;
	obj.date = date;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.title];
	[stream writeInt:self.date];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.title = [stream readString];
	self.date = [stream readInt];
}
@end

@implementation TL_geoChat
+(TL_geoChat*)createWithN_id:(int)n_id access_hash:(long)access_hash title:(NSString*)title address:(NSString*)address venue:(NSString*)venue geo:(TLGeoPoint*)geo photo:(TLChatPhoto*)photo participants_count:(int)participants_count date:(int)date checked_in:(Boolean)checked_in version:(int)version {
	TL_geoChat* obj = [[TL_geoChat alloc] init];
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
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeString:self.title];
	[stream writeString:self.address];
	[stream writeString:self.venue];
	[TLClassStore TLSerialize:self.geo stream:stream];
	[TLClassStore TLSerialize:self.photo stream:stream];
	[stream writeInt:self.participants_count];
	[stream writeInt:self.date];
	[stream writeBool:self.checked_in];
	[stream writeInt:self.version];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.access_hash = [stream readLong];
	self.title = [stream readString];
	self.address = [stream readString];
	self.venue = [stream readString];
	self.geo = [TLClassStore TLDeserialize:stream];
	self.photo = [TLClassStore TLDeserialize:stream];
	self.participants_count = [stream readInt];
	self.date = [stream readInt];
	self.checked_in = [stream readBool];
	self.version = [stream readInt];
}
@end



@implementation TLChatFull
@end

@implementation TL_chatFull
+(TL_chatFull*)createWithN_id:(int)n_id participants:(TLChatParticipants*)participants chat_photo:(TLPhoto*)chat_photo notify_settings:(TLPeerNotifySettings*)notify_settings {
	TL_chatFull* obj = [[TL_chatFull alloc] init];
	obj.n_id = n_id;
	obj.participants = participants;
	obj.chat_photo = chat_photo;
	obj.notify_settings = notify_settings;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[TLClassStore TLSerialize:self.participants stream:stream];
	[TLClassStore TLSerialize:self.chat_photo stream:stream];
	[TLClassStore TLSerialize:self.notify_settings stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.participants = [TLClassStore TLDeserialize:stream];
	self.chat_photo = [TLClassStore TLDeserialize:stream];
	self.notify_settings = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLChatParticipant
@end

@implementation TL_chatParticipant
+(TL_chatParticipant*)createWithUser_id:(int)user_id inviter_id:(int)inviter_id date:(int)date {
	TL_chatParticipant* obj = [[TL_chatParticipant alloc] init];
	obj.user_id = user_id;
	obj.inviter_id = inviter_id;
	obj.date = date;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeInt:self.inviter_id];
	[stream writeInt:self.date];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.inviter_id = [stream readInt];
	self.date = [stream readInt];
}
@end



@implementation TLChatParticipants
@end

@implementation TL_chatParticipantsForbidden
+(TL_chatParticipantsForbidden*)createWithChat_id:(int)chat_id {
	TL_chatParticipantsForbidden* obj = [[TL_chatParticipantsForbidden alloc] init];
	obj.chat_id = chat_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat_id = [stream readInt];
}
@end

@implementation TL_chatParticipants
+(TL_chatParticipants*)createWithChat_id:(int)chat_id admin_id:(int)admin_id participants:(NSMutableArray*)participants version:(int)version {
	TL_chatParticipants* obj = [[TL_chatParticipants alloc] init];
	obj.chat_id = chat_id;
	obj.admin_id = admin_id;
	obj.participants = participants;
	obj.version = version;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.admin_id];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.participants count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChatParticipant* obj = [self.participants objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.version];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat_id = [stream readInt];
	self.admin_id = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.participants)
			self.participants = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChatParticipant* obj = [TLClassStore TLDeserialize:stream];
			[self.participants addObject:obj];
		}
	}
	self.version = [stream readInt];
}
@end



@implementation TLChatPhoto
@end

@implementation TL_chatPhotoEmpty
+(TL_chatPhotoEmpty*)create {
	TL_chatPhotoEmpty* obj = [[TL_chatPhotoEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_chatPhoto
+(TL_chatPhoto*)createWithPhoto_small:(TLFileLocation*)photo_small photo_big:(TLFileLocation*)photo_big {
	TL_chatPhoto* obj = [[TL_chatPhoto alloc] init];
	obj.photo_small = photo_small;
	obj.photo_big = photo_big;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.photo_small stream:stream];
	[TLClassStore TLSerialize:self.photo_big stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.photo_small = [TLClassStore TLDeserialize:stream];
	self.photo_big = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLMessage
@end

@implementation TL_messageEmpty
+(TL_messageEmpty*)createWithN_id:(int)n_id {
	TL_messageEmpty* obj = [[TL_messageEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
}
@end

@implementation TL_message
+(TL_message*)createWithFlags:(int)flags n_id:(int)n_id from_id:(int)from_id to_id:(TLPeer*)to_id date:(int)date message:(NSString*)message media:(TLMessageMedia*)media {
	TL_message* obj = [[TL_message alloc] init];
	obj.flags = flags;
	obj.n_id = n_id;
	obj.from_id = from_id;
	obj.to_id = to_id;
	obj.date = date;
	obj.message = message;
	obj.media = media;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[TLClassStore TLSerialize:self.to_id stream:stream];
	[stream writeInt:self.date];
	[stream writeString:self.message];
	[TLClassStore TLSerialize:self.media stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.flags = [stream readInt];
	self.n_id = [stream readInt];
	self.from_id = [stream readInt];
	self.to_id = [TLClassStore TLDeserialize:stream];
	self.date = [stream readInt];
	self.message = [stream readString];
	self.media = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_messageForwarded
+(TL_messageForwarded*)createWithFlags:(int)flags n_id:(int)n_id fwd_from_id:(int)fwd_from_id fwd_date:(int)fwd_date from_id:(int)from_id to_id:(TLPeer*)to_id date:(int)date message:(NSString*)message media:(TLMessageMedia*)media {
	TL_messageForwarded* obj = [[TL_messageForwarded alloc] init];
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
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	[stream writeInt:self.n_id];
	[stream writeInt:self.fwd_from_id];
	[stream writeInt:self.fwd_date];
	[stream writeInt:self.from_id];
	[TLClassStore TLSerialize:self.to_id stream:stream];
	[stream writeInt:self.date];
	[stream writeString:self.message];
	[TLClassStore TLSerialize:self.media stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.flags = [stream readInt];
	self.n_id = [stream readInt];
	self.fwd_from_id = [stream readInt];
	self.fwd_date = [stream readInt];
	self.from_id = [stream readInt];
	self.to_id = [TLClassStore TLDeserialize:stream];
	self.date = [stream readInt];
	self.message = [stream readString];
	self.media = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_messageService
+(TL_messageService*)createWithFlags:(int)flags n_id:(int)n_id from_id:(int)from_id to_id:(TLPeer*)to_id date:(int)date action:(TLMessageAction*)action {
	TL_messageService* obj = [[TL_messageService alloc] init];
	obj.flags = flags;
	obj.n_id = n_id;
	obj.from_id = from_id;
	obj.to_id = to_id;
	obj.date = date;
	obj.action = action;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[TLClassStore TLSerialize:self.to_id stream:stream];
	[stream writeInt:self.date];
	[TLClassStore TLSerialize:self.action stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.flags = [stream readInt];
	self.n_id = [stream readInt];
	self.from_id = [stream readInt];
	self.to_id = [TLClassStore TLDeserialize:stream];
	self.date = [stream readInt];
	self.action = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLMessageMedia
@end

@implementation TL_messageMediaEmpty
+(TL_messageMediaEmpty*)create {
	TL_messageMediaEmpty* obj = [[TL_messageMediaEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_messageMediaPhoto
+(TL_messageMediaPhoto*)createWithPhoto:(TLPhoto*)photo {
	TL_messageMediaPhoto* obj = [[TL_messageMediaPhoto alloc] init];
	obj.photo = photo;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.photo stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.photo = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_messageMediaVideo
+(TL_messageMediaVideo*)createWithVideo:(TLVideo*)video {
	TL_messageMediaVideo* obj = [[TL_messageMediaVideo alloc] init];
	obj.video = video;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.video stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.video = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_messageMediaGeo
+(TL_messageMediaGeo*)createWithGeo:(TLGeoPoint*)geo {
	TL_messageMediaGeo* obj = [[TL_messageMediaGeo alloc] init];
	obj.geo = geo;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.geo stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.geo = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_messageMediaContact
+(TL_messageMediaContact*)createWithPhone_number:(NSString*)phone_number first_name:(NSString*)first_name last_name:(NSString*)last_name user_id:(int)user_id {
	TL_messageMediaContact* obj = [[TL_messageMediaContact alloc] init];
	obj.phone_number = phone_number;
	obj.first_name = first_name;
	obj.last_name = last_name;
	obj.user_id = user_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.phone_number];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
	[stream writeInt:self.user_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.phone_number = [stream readString];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
	self.user_id = [stream readInt];
}
@end

@implementation TL_messageMediaUnsupported
+(TL_messageMediaUnsupported*)createWithBytes:(NSData*)bytes {
	TL_messageMediaUnsupported* obj = [[TL_messageMediaUnsupported alloc] init];
	obj.bytes = bytes;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeByteArray:self.bytes];
}
-(void)unserialize:(SerializedData*)stream {
	self.bytes = [stream readByteArray];
}
@end

@implementation TL_messageMediaDocument
+(TL_messageMediaDocument*)createWithDocument:(TLDocument*)document {
	TL_messageMediaDocument* obj = [[TL_messageMediaDocument alloc] init];
	obj.document = document;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.document stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.document = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_messageMediaAudio
+(TL_messageMediaAudio*)createWithAudio:(TLAudio*)audio {
	TL_messageMediaAudio* obj = [[TL_messageMediaAudio alloc] init];
	obj.audio = audio;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.audio stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.audio = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLMessageAction
@end

@implementation TL_messageActionEmpty
+(TL_messageActionEmpty*)create {
	TL_messageActionEmpty* obj = [[TL_messageActionEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_messageActionChatCreate
+(TL_messageActionChatCreate*)createWithTitle:(NSString*)title users:(NSMutableArray*)users {
	TL_messageActionChatCreate* obj = [[TL_messageActionChatCreate alloc] init];
	obj.title = title;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
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
-(void)unserialize:(SerializedData*)stream {
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
+(TL_messageActionChatEditTitle*)createWithTitle:(NSString*)title {
	TL_messageActionChatEditTitle* obj = [[TL_messageActionChatEditTitle alloc] init];
	obj.title = title;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.title];
}
-(void)unserialize:(SerializedData*)stream {
	self.title = [stream readString];
}
@end

@implementation TL_messageActionChatEditPhoto
+(TL_messageActionChatEditPhoto*)createWithPhoto:(TLPhoto*)photo {
	TL_messageActionChatEditPhoto* obj = [[TL_messageActionChatEditPhoto alloc] init];
	obj.photo = photo;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.photo stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.photo = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_messageActionChatDeletePhoto
+(TL_messageActionChatDeletePhoto*)create {
	TL_messageActionChatDeletePhoto* obj = [[TL_messageActionChatDeletePhoto alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_messageActionChatAddUser
+(TL_messageActionChatAddUser*)createWithUser_id:(int)user_id {
	TL_messageActionChatAddUser* obj = [[TL_messageActionChatAddUser alloc] init];
	obj.user_id = user_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
}
@end

@implementation TL_messageActionChatDeleteUser
+(TL_messageActionChatDeleteUser*)createWithUser_id:(int)user_id {
	TL_messageActionChatDeleteUser* obj = [[TL_messageActionChatDeleteUser alloc] init];
	obj.user_id = user_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
}
@end

@implementation TL_messageActionGeoChatCreate
+(TL_messageActionGeoChatCreate*)createWithTitle:(NSString*)title address:(NSString*)address {
	TL_messageActionGeoChatCreate* obj = [[TL_messageActionGeoChatCreate alloc] init];
	obj.title = title;
	obj.address = address;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.title];
	[stream writeString:self.address];
}
-(void)unserialize:(SerializedData*)stream {
	self.title = [stream readString];
	self.address = [stream readString];
}
@end

@implementation TL_messageActionGeoChatCheckin
+(TL_messageActionGeoChatCheckin*)create {
	TL_messageActionGeoChatCheckin* obj = [[TL_messageActionGeoChatCheckin alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end



@implementation TLDialog
@end

@implementation TL_dialog
+(TL_dialog*)createWithPeer:(TLPeer*)peer top_message:(int)top_message unread_count:(int)unread_count notify_settings:(TLPeerNotifySettings*)notify_settings {
	TL_dialog* obj = [[TL_dialog alloc] init];
	obj.peer = peer;
	obj.top_message = top_message;
	obj.unread_count = unread_count;
	obj.notify_settings = notify_settings;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.peer stream:stream];
	[stream writeInt:self.top_message];
	[stream writeInt:self.unread_count];
	[TLClassStore TLSerialize:self.notify_settings stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.peer = [TLClassStore TLDeserialize:stream];
	self.top_message = [stream readInt];
	self.unread_count = [stream readInt];
	self.notify_settings = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLPhoto
@end

@implementation TL_photoEmpty
+(TL_photoEmpty*)createWithN_id:(long)n_id {
	TL_photoEmpty* obj = [[TL_photoEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
}
@end

@implementation TL_photo
+(TL_photo*)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date caption:(NSString*)caption geo:(TLGeoPoint*)geo sizes:(NSMutableArray*)sizes {
	TL_photo* obj = [[TL_photo alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.user_id = user_id;
	obj.date = date;
	obj.caption = caption;
	obj.geo = geo;
	obj.sizes = sizes;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
	[stream writeString:self.caption];
	[TLClassStore TLSerialize:self.geo stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.sizes count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLPhotoSize* obj = [self.sizes objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
	self.user_id = [stream readInt];
	self.date = [stream readInt];
	self.caption = [stream readString];
	self.geo = [TLClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.sizes)
			self.sizes = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLPhotoSize* obj = [TLClassStore TLDeserialize:stream];
			[self.sizes addObject:obj];
		}
	}
}
@end



@implementation TLPhotoSize
@end

@implementation TL_photoSizeEmpty
+(TL_photoSizeEmpty*)createWithType:(NSString*)type {
	TL_photoSizeEmpty* obj = [[TL_photoSizeEmpty alloc] init];
	obj.type = type;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.type];
}
-(void)unserialize:(SerializedData*)stream {
	self.type = [stream readString];
}
@end

@implementation TL_photoSize
+(TL_photoSize*)createWithType:(NSString*)type location:(TLFileLocation*)location w:(int)w h:(int)h size:(int)size {
	TL_photoSize* obj = [[TL_photoSize alloc] init];
	obj.type = type;
	obj.location = location;
	obj.w = w;
	obj.h = h;
	obj.size = size;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.type];
	[TLClassStore TLSerialize:self.location stream:stream];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeInt:self.size];
}
-(void)unserialize:(SerializedData*)stream {
	self.type = [stream readString];
	self.location = [TLClassStore TLDeserialize:stream];
	self.w = [stream readInt];
	self.h = [stream readInt];
	self.size = [stream readInt];
}
@end

@implementation TL_photoCachedSize
+(TL_photoCachedSize*)createWithType:(NSString*)type location:(TLFileLocation*)location w:(int)w h:(int)h bytes:(NSData*)bytes {
	TL_photoCachedSize* obj = [[TL_photoCachedSize alloc] init];
	obj.type = type;
	obj.location = location;
	obj.w = w;
	obj.h = h;
	obj.bytes = bytes;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.type];
	[TLClassStore TLSerialize:self.location stream:stream];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeByteArray:self.bytes];
}
-(void)unserialize:(SerializedData*)stream {
	self.type = [stream readString];
	self.location = [TLClassStore TLDeserialize:stream];
	self.w = [stream readInt];
	self.h = [stream readInt];
	self.bytes = [stream readByteArray];
}
@end



@implementation TLVideo
@end

@implementation TL_videoEmpty
+(TL_videoEmpty*)createWithN_id:(long)n_id {
	TL_videoEmpty* obj = [[TL_videoEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
}
@end

@implementation TL_video
+(TL_video*)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date caption:(NSString*)caption duration:(int)duration mime_type:(NSString*)mime_type size:(int)size thumb:(TLPhotoSize*)thumb dc_id:(int)dc_id w:(int)w h:(int)h {
	TL_video* obj = [[TL_video alloc] init];
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
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
	[stream writeString:self.caption];
	[stream writeInt:self.duration];
	[stream writeString:self.mime_type];
	[stream writeInt:self.size];
	[TLClassStore TLSerialize:self.thumb stream:stream];
	[stream writeInt:self.dc_id];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
	self.user_id = [stream readInt];
	self.date = [stream readInt];
	self.caption = [stream readString];
	self.duration = [stream readInt];
	self.mime_type = [stream readString];
	self.size = [stream readInt];
	self.thumb = [TLClassStore TLDeserialize:stream];
	self.dc_id = [stream readInt];
	self.w = [stream readInt];
	self.h = [stream readInt];
}
@end



@implementation TLGeoPoint
@end

@implementation TL_geoPointEmpty
+(TL_geoPointEmpty*)create {
	TL_geoPointEmpty* obj = [[TL_geoPointEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_geoPoint
+(TL_geoPoint*)createWithN_long:(double)n_long lat:(double)lat {
	TL_geoPoint* obj = [[TL_geoPoint alloc] init];
	obj.n_long = n_long;
	obj.lat = lat;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeDouble:self.n_long];
	[stream writeDouble:self.lat];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_long = [stream readDouble];
	self.lat = [stream readDouble];
}
@end



@implementation TLauth_CheckedPhone
@end

@implementation TL_auth_checkedPhone
+(TL_auth_checkedPhone*)createWithPhone_registered:(Boolean)phone_registered phone_invited:(Boolean)phone_invited {
	TL_auth_checkedPhone* obj = [[TL_auth_checkedPhone alloc] init];
	obj.phone_registered = phone_registered;
	obj.phone_invited = phone_invited;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeBool:self.phone_registered];
	[stream writeBool:self.phone_invited];
}
-(void)unserialize:(SerializedData*)stream {
	self.phone_registered = [stream readBool];
	self.phone_invited = [stream readBool];
}
@end



@implementation TLauth_SentCode
@end

@implementation TL_auth_sentCode
+(TL_auth_sentCode*)createWithPhone_registered:(Boolean)phone_registered phone_code_hash:(NSString*)phone_code_hash send_call_timeout:(int)send_call_timeout is_password:(Boolean)is_password {
	TL_auth_sentCode* obj = [[TL_auth_sentCode alloc] init];
	obj.phone_registered = phone_registered;
	obj.phone_code_hash = phone_code_hash;
	obj.send_call_timeout = send_call_timeout;
	obj.is_password = is_password;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeBool:self.phone_registered];
	[stream writeString:self.phone_code_hash];
	[stream writeInt:self.send_call_timeout];
	[stream writeBool:self.is_password];
}
-(void)unserialize:(SerializedData*)stream {
	self.phone_registered = [stream readBool];
	self.phone_code_hash = [stream readString];
	self.send_call_timeout = [stream readInt];
	self.is_password = [stream readBool];
}
@end

@implementation TL_auth_sentAppCode
+(TL_auth_sentAppCode*)createWithPhone_registered:(Boolean)phone_registered phone_code_hash:(NSString*)phone_code_hash send_call_timeout:(int)send_call_timeout is_password:(Boolean)is_password {
	TL_auth_sentAppCode* obj = [[TL_auth_sentAppCode alloc] init];
	obj.phone_registered = phone_registered;
	obj.phone_code_hash = phone_code_hash;
	obj.send_call_timeout = send_call_timeout;
	obj.is_password = is_password;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeBool:self.phone_registered];
	[stream writeString:self.phone_code_hash];
	[stream writeInt:self.send_call_timeout];
	[stream writeBool:self.is_password];
}
-(void)unserialize:(SerializedData*)stream {
	self.phone_registered = [stream readBool];
	self.phone_code_hash = [stream readString];
	self.send_call_timeout = [stream readInt];
	self.is_password = [stream readBool];
}
@end



@implementation TLauth_Authorization
@end

@implementation TL_auth_authorization
+(TL_auth_authorization*)createWithExpires:(int)expires user:(TLUser*)user {
	TL_auth_authorization* obj = [[TL_auth_authorization alloc] init];
	obj.expires = expires;
	obj.user = user;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.expires];
	[TLClassStore TLSerialize:self.user stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.expires = [stream readInt];
	self.user = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLauth_ExportedAuthorization
@end

@implementation TL_auth_exportedAuthorization
+(TL_auth_exportedAuthorization*)createWithN_id:(int)n_id bytes:(NSData*)bytes {
	TL_auth_exportedAuthorization* obj = [[TL_auth_exportedAuthorization alloc] init];
	obj.n_id = n_id;
	obj.bytes = bytes;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeByteArray:self.bytes];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.bytes = [stream readByteArray];
}
@end



@implementation TLInputNotifyPeer
@end

@implementation TL_inputNotifyPeer
+(TL_inputNotifyPeer*)createWithPeer:(TLInputPeer*)peer {
	TL_inputNotifyPeer* obj = [[TL_inputNotifyPeer alloc] init];
	obj.peer = peer;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.peer stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.peer = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_inputNotifyUsers
+(TL_inputNotifyUsers*)create {
	TL_inputNotifyUsers* obj = [[TL_inputNotifyUsers alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputNotifyChats
+(TL_inputNotifyChats*)create {
	TL_inputNotifyChats* obj = [[TL_inputNotifyChats alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputNotifyAll
+(TL_inputNotifyAll*)create {
	TL_inputNotifyAll* obj = [[TL_inputNotifyAll alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputNotifyGeoChatPeer
+(TL_inputNotifyGeoChatPeer*)createWithPeer:(TLInputGeoChat*)peer {
	TL_inputNotifyGeoChatPeer* obj = [[TL_inputNotifyGeoChatPeer alloc] init];
	obj.peer = peer;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.peer stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.peer = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLInputPeerNotifyEvents
@end

@implementation TL_inputPeerNotifyEventsEmpty
+(TL_inputPeerNotifyEventsEmpty*)create {
	TL_inputPeerNotifyEventsEmpty* obj = [[TL_inputPeerNotifyEventsEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputPeerNotifyEventsAll
+(TL_inputPeerNotifyEventsAll*)create {
	TL_inputPeerNotifyEventsAll* obj = [[TL_inputPeerNotifyEventsAll alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end



@implementation TLInputPeerNotifySettings
@end

@implementation TL_inputPeerNotifySettings
+(TL_inputPeerNotifySettings*)createWithMute_until:(int)mute_until sound:(NSString*)sound show_previews:(Boolean)show_previews events_mask:(int)events_mask {
	TL_inputPeerNotifySettings* obj = [[TL_inputPeerNotifySettings alloc] init];
	obj.mute_until = mute_until;
	obj.sound = sound;
	obj.show_previews = show_previews;
	obj.events_mask = events_mask;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.mute_until];
	[stream writeString:self.sound];
	[stream writeBool:self.show_previews];
	[stream writeInt:self.events_mask];
}
-(void)unserialize:(SerializedData*)stream {
	self.mute_until = [stream readInt];
	self.sound = [stream readString];
	self.show_previews = [stream readBool];
	self.events_mask = [stream readInt];
}
@end



@implementation TLPeerNotifyEvents
@end

@implementation TL_peerNotifyEventsEmpty
+(TL_peerNotifyEventsEmpty*)create {
	TL_peerNotifyEventsEmpty* obj = [[TL_peerNotifyEventsEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_peerNotifyEventsAll
+(TL_peerNotifyEventsAll*)create {
	TL_peerNotifyEventsAll* obj = [[TL_peerNotifyEventsAll alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end



@implementation TLPeerNotifySettings
@end

@implementation TL_peerNotifySettingsEmpty
+(TL_peerNotifySettingsEmpty*)create {
	TL_peerNotifySettingsEmpty* obj = [[TL_peerNotifySettingsEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_peerNotifySettings
+(TL_peerNotifySettings*)createWithMute_until:(int)mute_until sound:(NSString*)sound show_previews:(Boolean)show_previews events_mask:(int)events_mask {
	TL_peerNotifySettings* obj = [[TL_peerNotifySettings alloc] init];
	obj.mute_until = mute_until;
	obj.sound = sound;
	obj.show_previews = show_previews;
	obj.events_mask = events_mask;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.mute_until];
	[stream writeString:self.sound];
	[stream writeBool:self.show_previews];
	[stream writeInt:self.events_mask];
}
-(void)unserialize:(SerializedData*)stream {
	self.mute_until = [stream readInt];
	self.sound = [stream readString];
	self.show_previews = [stream readBool];
	self.events_mask = [stream readInt];
}
@end



@implementation TLGlobalPrivacySettings
@end

@implementation TL_globalPrivacySettings
+(TL_globalPrivacySettings*)createWithNo_suggestions:(Boolean)no_suggestions hide_contacts:(Boolean)hide_contacts hide_located:(Boolean)hide_located hide_last_visit:(Boolean)hide_last_visit {
	TL_globalPrivacySettings* obj = [[TL_globalPrivacySettings alloc] init];
	obj.no_suggestions = no_suggestions;
	obj.hide_contacts = hide_contacts;
	obj.hide_located = hide_located;
	obj.hide_last_visit = hide_last_visit;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeBool:self.no_suggestions];
	[stream writeBool:self.hide_contacts];
	[stream writeBool:self.hide_located];
	[stream writeBool:self.hide_last_visit];
}
-(void)unserialize:(SerializedData*)stream {
	self.no_suggestions = [stream readBool];
	self.hide_contacts = [stream readBool];
	self.hide_located = [stream readBool];
	self.hide_last_visit = [stream readBool];
}
@end



@implementation TLWallPaper
@end

@implementation TL_wallPaper
+(TL_wallPaper*)createWithN_id:(int)n_id title:(NSString*)title sizes:(NSMutableArray*)sizes color:(int)color {
	TL_wallPaper* obj = [[TL_wallPaper alloc] init];
	obj.n_id = n_id;
	obj.title = title;
	obj.sizes = sizes;
	obj.color = color;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.title];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.sizes count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLPhotoSize* obj = [self.sizes objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.color];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.title = [stream readString];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.sizes)
			self.sizes = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLPhotoSize* obj = [TLClassStore TLDeserialize:stream];
			[self.sizes addObject:obj];
		}
	}
	self.color = [stream readInt];
}
@end

@implementation TL_wallPaperSolid
+(TL_wallPaperSolid*)createWithN_id:(int)n_id title:(NSString*)title bg_color:(int)bg_color color:(int)color {
	TL_wallPaperSolid* obj = [[TL_wallPaperSolid alloc] init];
	obj.n_id = n_id;
	obj.title = title;
	obj.bg_color = bg_color;
	obj.color = color;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.title];
	[stream writeInt:self.bg_color];
	[stream writeInt:self.color];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.title = [stream readString];
	self.bg_color = [stream readInt];
	self.color = [stream readInt];
}
@end



@implementation TLUserFull
@end

@implementation TL_userFull
+(TL_userFull*)createWithUser:(TLUser*)user link:(TLcontacts_Link*)link profile_photo:(TLPhoto*)profile_photo notify_settings:(TLPeerNotifySettings*)notify_settings blocked:(Boolean)blocked real_first_name:(NSString*)real_first_name real_last_name:(NSString*)real_last_name {
	TL_userFull* obj = [[TL_userFull alloc] init];
	obj.user = user;
	obj.link = link;
	obj.profile_photo = profile_photo;
	obj.notify_settings = notify_settings;
	obj.blocked = blocked;
	obj.real_first_name = real_first_name;
	obj.real_last_name = real_last_name;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.user stream:stream];
	[TLClassStore TLSerialize:self.link stream:stream];
	[TLClassStore TLSerialize:self.profile_photo stream:stream];
	[TLClassStore TLSerialize:self.notify_settings stream:stream];
	[stream writeBool:self.blocked];
	[stream writeString:self.real_first_name];
	[stream writeString:self.real_last_name];
}
-(void)unserialize:(SerializedData*)stream {
	self.user = [TLClassStore TLDeserialize:stream];
	self.link = [TLClassStore TLDeserialize:stream];
	self.profile_photo = [TLClassStore TLDeserialize:stream];
	self.notify_settings = [TLClassStore TLDeserialize:stream];
	self.blocked = [stream readBool];
	self.real_first_name = [stream readString];
	self.real_last_name = [stream readString];
}
@end



@implementation TLContact
@end

@implementation TL_contact
+(TL_contact*)createWithUser_id:(int)user_id mutual:(Boolean)mutual {
	TL_contact* obj = [[TL_contact alloc] init];
	obj.user_id = user_id;
	obj.mutual = mutual;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeBool:self.mutual];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.mutual = [stream readBool];
}
@end



@implementation TLImportedContact
@end

@implementation TL_importedContact
+(TL_importedContact*)createWithUser_id:(int)user_id client_id:(long)client_id {
	TL_importedContact* obj = [[TL_importedContact alloc] init];
	obj.user_id = user_id;
	obj.client_id = client_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeLong:self.client_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.client_id = [stream readLong];
}
@end



@implementation TLContactBlocked
@end

@implementation TL_contactBlocked
+(TL_contactBlocked*)createWithUser_id:(int)user_id date:(int)date {
	TL_contactBlocked* obj = [[TL_contactBlocked alloc] init];
	obj.user_id = user_id;
	obj.date = date;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.date = [stream readInt];
}
@end



@implementation TLContactSuggested
@end

@implementation TL_contactSuggested
+(TL_contactSuggested*)createWithUser_id:(int)user_id mutual_contacts:(int)mutual_contacts {
	TL_contactSuggested* obj = [[TL_contactSuggested alloc] init];
	obj.user_id = user_id;
	obj.mutual_contacts = mutual_contacts;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeInt:self.mutual_contacts];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.mutual_contacts = [stream readInt];
}
@end



@implementation TLContactStatus
@end

@implementation TL_contactStatus
+(TL_contactStatus*)createWithUser_id:(int)user_id status:(TLUserStatus*)status {
	TL_contactStatus* obj = [[TL_contactStatus alloc] init];
	obj.user_id = user_id;
	obj.status = status;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[TLClassStore TLSerialize:self.status stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.status = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLChatLocated
@end

@implementation TL_chatLocated
+(TL_chatLocated*)createWithChat_id:(int)chat_id distance:(int)distance {
	TL_chatLocated* obj = [[TL_chatLocated alloc] init];
	obj.chat_id = chat_id;
	obj.distance = distance;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.distance];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat_id = [stream readInt];
	self.distance = [stream readInt];
}
@end



@implementation TLcontacts_ForeignLink
@end

@implementation TL_contacts_foreignLinkUnknown
+(TL_contacts_foreignLinkUnknown*)create {
	TL_contacts_foreignLinkUnknown* obj = [[TL_contacts_foreignLinkUnknown alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_contacts_foreignLinkRequested
+(TL_contacts_foreignLinkRequested*)createWithHas_phone:(Boolean)has_phone {
	TL_contacts_foreignLinkRequested* obj = [[TL_contacts_foreignLinkRequested alloc] init];
	obj.has_phone = has_phone;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeBool:self.has_phone];
}
-(void)unserialize:(SerializedData*)stream {
	self.has_phone = [stream readBool];
}
@end

@implementation TL_contacts_foreignLinkMutual
+(TL_contacts_foreignLinkMutual*)create {
	TL_contacts_foreignLinkMutual* obj = [[TL_contacts_foreignLinkMutual alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end



@implementation TLcontacts_MyLink
@end

@implementation TL_contacts_myLinkEmpty
+(TL_contacts_myLinkEmpty*)create {
	TL_contacts_myLinkEmpty* obj = [[TL_contacts_myLinkEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_contacts_myLinkRequested
+(TL_contacts_myLinkRequested*)createWithContact:(Boolean)contact {
	TL_contacts_myLinkRequested* obj = [[TL_contacts_myLinkRequested alloc] init];
	obj.contact = contact;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeBool:self.contact];
}
-(void)unserialize:(SerializedData*)stream {
	self.contact = [stream readBool];
}
@end

@implementation TL_contacts_myLinkContact
+(TL_contacts_myLinkContact*)create {
	TL_contacts_myLinkContact* obj = [[TL_contacts_myLinkContact alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end



@implementation TLcontacts_Link
@end

@implementation TL_contacts_link
+(TL_contacts_link*)createWithMy_link:(TLcontacts_MyLink*)my_link foreign_link:(TLcontacts_ForeignLink*)foreign_link user:(TLUser*)user {
	TL_contacts_link* obj = [[TL_contacts_link alloc] init];
	obj.my_link = my_link;
	obj.foreign_link = foreign_link;
	obj.user = user;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.my_link stream:stream];
	[TLClassStore TLSerialize:self.foreign_link stream:stream];
	[TLClassStore TLSerialize:self.user stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.my_link = [TLClassStore TLDeserialize:stream];
	self.foreign_link = [TLClassStore TLDeserialize:stream];
	self.user = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLcontacts_Contacts
@end

@implementation TL_contacts_contacts
+(TL_contacts_contacts*)createWithContacts:(NSMutableArray*)contacts users:(NSMutableArray*)users {
	TL_contacts_contacts* obj = [[TL_contacts_contacts alloc] init];
	obj.contacts = contacts;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.contacts count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLContact* obj = [self.contacts objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.contacts)
			self.contacts = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLContact* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end

@implementation TL_contacts_contactsNotModified
+(TL_contacts_contactsNotModified*)create {
	TL_contacts_contactsNotModified* obj = [[TL_contacts_contactsNotModified alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end



@implementation TLcontacts_ImportedContacts
@end

@implementation TL_contacts_importedContacts
+(TL_contacts_importedContacts*)createWithImported:(NSMutableArray*)imported retry_contacts:(NSMutableArray*)retry_contacts users:(NSMutableArray*)users {
	TL_contacts_importedContacts* obj = [[TL_contacts_importedContacts alloc] init];
	obj.imported = imported;
	obj.retry_contacts = retry_contacts;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.imported count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLImportedContact* obj = [self.imported objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
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
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.imported)
			self.imported = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLImportedContact* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLcontacts_Blocked
@end

@implementation TL_contacts_blocked
+(TL_contacts_blocked*)createWithBlocked:(NSMutableArray*)blocked users:(NSMutableArray*)users {
	TL_contacts_blocked* obj = [[TL_contacts_blocked alloc] init];
	obj.blocked = blocked;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.blocked count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLContactBlocked* obj = [self.blocked objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.blocked)
			self.blocked = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLContactBlocked* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end

@implementation TL_contacts_blockedSlice
+(TL_contacts_blockedSlice*)createWithN_count:(int)n_count blocked:(NSMutableArray*)blocked users:(NSMutableArray*)users {
	TL_contacts_blockedSlice* obj = [[TL_contacts_blockedSlice alloc] init];
	obj.n_count = n_count;
	obj.blocked = blocked;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_count];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.blocked count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLContactBlocked* obj = [self.blocked objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.blocked)
			self.blocked = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLContactBlocked* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLcontacts_Suggested
@end

@implementation TL_contacts_suggested
+(TL_contacts_suggested*)createWithResults:(NSMutableArray*)results users:(NSMutableArray*)users {
	TL_contacts_suggested* obj = [[TL_contacts_suggested alloc] init];
	obj.results = results;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.results count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLContactSuggested* obj = [self.results objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.results)
			self.results = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLContactSuggested* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLmessages_Dialogs
@end

@implementation TL_messages_dialogs
+(TL_messages_dialogs*)createWithDialogs:(NSMutableArray*)dialogs messages:(NSMutableArray*)messages chats:(NSMutableArray*)chats users:(NSMutableArray*)users {
	TL_messages_dialogs* obj = [[TL_messages_dialogs alloc] init];
	obj.dialogs = dialogs;
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.dialogs count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLDialog* obj = [self.dialogs objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLMessage* obj = [self.messages objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.dialogs)
			self.dialogs = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLDialog* obj = [TLClassStore TLDeserialize:stream];
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
			TLMessage* obj = [TLClassStore TLDeserialize:stream];
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
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end

@implementation TL_messages_dialogsSlice
+(TL_messages_dialogsSlice*)createWithN_count:(int)n_count dialogs:(NSMutableArray*)dialogs messages:(NSMutableArray*)messages chats:(NSMutableArray*)chats users:(NSMutableArray*)users {
	TL_messages_dialogsSlice* obj = [[TL_messages_dialogsSlice alloc] init];
	obj.n_count = n_count;
	obj.dialogs = dialogs;
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_count];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.dialogs count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLDialog* obj = [self.dialogs objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLMessage* obj = [self.messages objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.dialogs)
			self.dialogs = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLDialog* obj = [TLClassStore TLDeserialize:stream];
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
			TLMessage* obj = [TLClassStore TLDeserialize:stream];
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
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLmessages_Messages
@end

@implementation TL_messages_messages
+(TL_messages_messages*)createWithMessages:(NSMutableArray*)messages chats:(NSMutableArray*)chats users:(NSMutableArray*)users {
	TL_messages_messages* obj = [[TL_messages_messages alloc] init];
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLMessage* obj = [self.messages objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessage* obj = [TLClassStore TLDeserialize:stream];
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
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end

@implementation TL_messages_messagesSlice
+(TL_messages_messagesSlice*)createWithN_count:(int)n_count messages:(NSMutableArray*)messages chats:(NSMutableArray*)chats users:(NSMutableArray*)users {
	TL_messages_messagesSlice* obj = [[TL_messages_messagesSlice alloc] init];
	obj.n_count = n_count;
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_count];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLMessage* obj = [self.messages objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessage* obj = [TLClassStore TLDeserialize:stream];
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
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLmessages_Message
@end

@implementation TL_messages_messageEmpty
+(TL_messages_messageEmpty*)create {
	TL_messages_messageEmpty* obj = [[TL_messages_messageEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_messages_message
+(TL_messages_message*)createWithMessage:(TLMessage*)message chats:(NSMutableArray*)chats users:(NSMutableArray*)users {
	TL_messages_message* obj = [[TL_messages_message alloc] init];
	obj.message = message;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.message stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.message = [TLClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLmessages_StatedMessages
@end

@implementation TL_messages_statedMessages
+(TL_messages_statedMessages*)createWithMessages:(NSMutableArray*)messages chats:(NSMutableArray*)chats users:(NSMutableArray*)users pts:(int)pts seq:(int)seq {
	TL_messages_statedMessages* obj = [[TL_messages_statedMessages alloc] init];
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	obj.pts = pts;
	obj.seq = seq;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLMessage* obj = [self.messages objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.pts];
	[stream writeInt:self.seq];
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessage* obj = [TLClassStore TLDeserialize:stream];
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
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
	self.pts = [stream readInt];
	self.seq = [stream readInt];
}
@end

@implementation TL_messages_statedMessagesLinks
+(TL_messages_statedMessagesLinks*)createWithMessages:(NSMutableArray*)messages chats:(NSMutableArray*)chats users:(NSMutableArray*)users links:(NSMutableArray*)links pts:(int)pts seq:(int)seq {
	TL_messages_statedMessagesLinks* obj = [[TL_messages_statedMessagesLinks alloc] init];
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	obj.links = links;
	obj.pts = pts;
	obj.seq = seq;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLMessage* obj = [self.messages objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.links count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLcontacts_Link* obj = [self.links objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.pts];
	[stream writeInt:self.seq];
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessage* obj = [TLClassStore TLDeserialize:stream];
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
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
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
			TLcontacts_Link* obj = [TLClassStore TLDeserialize:stream];
			[self.links addObject:obj];
		}
	}
	self.pts = [stream readInt];
	self.seq = [stream readInt];
}
@end



@implementation TLmessages_StatedMessage
@end

@implementation TL_messages_statedMessage
+(TL_messages_statedMessage*)createWithMessage:(TLMessage*)message chats:(NSMutableArray*)chats users:(NSMutableArray*)users pts:(int)pts seq:(int)seq {
	TL_messages_statedMessage* obj = [[TL_messages_statedMessage alloc] init];
	obj.message = message;
	obj.chats = chats;
	obj.users = users;
	obj.pts = pts;
	obj.seq = seq;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.message stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.pts];
	[stream writeInt:self.seq];
}
-(void)unserialize:(SerializedData*)stream {
	self.message = [TLClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
	self.pts = [stream readInt];
	self.seq = [stream readInt];
}
@end

@implementation TL_messages_statedMessageLink
+(TL_messages_statedMessageLink*)createWithMessage:(TLMessage*)message chats:(NSMutableArray*)chats users:(NSMutableArray*)users links:(NSMutableArray*)links pts:(int)pts seq:(int)seq {
	TL_messages_statedMessageLink* obj = [[TL_messages_statedMessageLink alloc] init];
	obj.message = message;
	obj.chats = chats;
	obj.users = users;
	obj.links = links;
	obj.pts = pts;
	obj.seq = seq;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.message stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.links count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLcontacts_Link* obj = [self.links objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.pts];
	[stream writeInt:self.seq];
}
-(void)unserialize:(SerializedData*)stream {
	self.message = [TLClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
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
			TLcontacts_Link* obj = [TLClassStore TLDeserialize:stream];
			[self.links addObject:obj];
		}
	}
	self.pts = [stream readInt];
	self.seq = [stream readInt];
}
@end



@implementation TLmessages_SentMessage
@end

@implementation TL_messages_sentMessage
+(TL_messages_sentMessage*)createWithN_id:(int)n_id date:(int)date pts:(int)pts seq:(int)seq {
	TL_messages_sentMessage* obj = [[TL_messages_sentMessage alloc] init];
	obj.n_id = n_id;
	obj.date = date;
	obj.pts = pts;
	obj.seq = seq;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeInt:self.date];
	[stream writeInt:self.pts];
	[stream writeInt:self.seq];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.date = [stream readInt];
	self.pts = [stream readInt];
	self.seq = [stream readInt];
}
@end

@implementation TL_messages_sentMessageLink
+(TL_messages_sentMessageLink*)createWithN_id:(int)n_id date:(int)date pts:(int)pts seq:(int)seq links:(NSMutableArray*)links {
	TL_messages_sentMessageLink* obj = [[TL_messages_sentMessageLink alloc] init];
	obj.n_id = n_id;
	obj.date = date;
	obj.pts = pts;
	obj.seq = seq;
	obj.links = links;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
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
			TLcontacts_Link* obj = [self.links objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
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
			TLcontacts_Link* obj = [TLClassStore TLDeserialize:stream];
			[self.links addObject:obj];
		}
	}
}
@end



@implementation TLmessages_Chat
@end

@implementation TL_messages_chat
+(TL_messages_chat*)createWithChat:(TLChat*)chat users:(NSMutableArray*)users {
	TL_messages_chat* obj = [[TL_messages_chat alloc] init];
	obj.chat = chat;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.chat stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.chat = [TLClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLmessages_Chats
@end

@implementation TL_messages_chats
+(TL_messages_chats*)createWithChats:(NSMutableArray*)chats users:(NSMutableArray*)users {
	TL_messages_chats* obj = [[TL_messages_chats alloc] init];
	obj.chats = chats;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLmessages_ChatFull
@end

@implementation TL_messages_chatFull
+(TL_messages_chatFull*)createWithFull_chat:(TLChatFull*)full_chat chats:(NSMutableArray*)chats users:(NSMutableArray*)users {
	TL_messages_chatFull* obj = [[TL_messages_chatFull alloc] init];
	obj.full_chat = full_chat;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.full_chat stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.full_chat = [TLClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLmessages_AffectedHistory
@end

@implementation TL_messages_affectedHistory
+(TL_messages_affectedHistory*)createWithPts:(int)pts seq:(int)seq offset:(int)offset {
	TL_messages_affectedHistory* obj = [[TL_messages_affectedHistory alloc] init];
	obj.pts = pts;
	obj.seq = seq;
	obj.offset = offset;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.pts];
	[stream writeInt:self.seq];
	[stream writeInt:self.offset];
}
-(void)unserialize:(SerializedData*)stream {
	self.pts = [stream readInt];
	self.seq = [stream readInt];
	self.offset = [stream readInt];
}
@end



@implementation TLMessagesFilter
@end

@implementation TL_inputMessagesFilterEmpty
+(TL_inputMessagesFilterEmpty*)create {
	TL_inputMessagesFilterEmpty* obj = [[TL_inputMessagesFilterEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputMessagesFilterPhotos
+(TL_inputMessagesFilterPhotos*)create {
	TL_inputMessagesFilterPhotos* obj = [[TL_inputMessagesFilterPhotos alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputMessagesFilterVideo
+(TL_inputMessagesFilterVideo*)create {
	TL_inputMessagesFilterVideo* obj = [[TL_inputMessagesFilterVideo alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputMessagesFilterPhotoVideo
+(TL_inputMessagesFilterPhotoVideo*)create {
	TL_inputMessagesFilterPhotoVideo* obj = [[TL_inputMessagesFilterPhotoVideo alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputMessagesFilterDocument
+(TL_inputMessagesFilterDocument*)create {
	TL_inputMessagesFilterDocument* obj = [[TL_inputMessagesFilterDocument alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputMessagesFilterAudio
+(TL_inputMessagesFilterAudio*)create {
	TL_inputMessagesFilterAudio* obj = [[TL_inputMessagesFilterAudio alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end



@implementation TLUpdate
@end

@implementation TL_updateNewMessage
+(TL_updateNewMessage*)createWithMessage:(TLMessage*)message pts:(int)pts {
	TL_updateNewMessage* obj = [[TL_updateNewMessage alloc] init];
	obj.message = message;
	obj.pts = pts;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.message stream:stream];
	[stream writeInt:self.pts];
}
-(void)unserialize:(SerializedData*)stream {
	self.message = [TLClassStore TLDeserialize:stream];
	self.pts = [stream readInt];
}
@end

@implementation TL_updateMessageID
+(TL_updateMessageID*)createWithN_id:(int)n_id random_id:(long)random_id {
	TL_updateMessageID* obj = [[TL_updateMessageID alloc] init];
	obj.n_id = n_id;
	obj.random_id = random_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeLong:self.random_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.random_id = [stream readLong];
}
@end

@implementation TL_updateReadMessages
+(TL_updateReadMessages*)createWithMessages:(NSMutableArray*)messages pts:(int)pts {
	TL_updateReadMessages* obj = [[TL_updateReadMessages alloc] init];
	obj.messages = messages;
	obj.pts = pts;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
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
-(void)unserialize:(SerializedData*)stream {
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
+(TL_updateDeleteMessages*)createWithMessages:(NSMutableArray*)messages pts:(int)pts {
	TL_updateDeleteMessages* obj = [[TL_updateDeleteMessages alloc] init];
	obj.messages = messages;
	obj.pts = pts;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
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
-(void)unserialize:(SerializedData*)stream {
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
+(TL_updateRestoreMessages*)createWithMessages:(NSMutableArray*)messages pts:(int)pts {
	TL_updateRestoreMessages* obj = [[TL_updateRestoreMessages alloc] init];
	obj.messages = messages;
	obj.pts = pts;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
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
-(void)unserialize:(SerializedData*)stream {
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
+(TL_updateUserTyping*)createWithUser_id:(int)user_id action:(TLSendMessageAction*)action {
	TL_updateUserTyping* obj = [[TL_updateUserTyping alloc] init];
	obj.user_id = user_id;
	obj.action = action;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[TLClassStore TLSerialize:self.action stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.action = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_updateChatUserTyping
+(TL_updateChatUserTyping*)createWithChat_id:(int)chat_id user_id:(int)user_id action:(TLSendMessageAction*)action {
	TL_updateChatUserTyping* obj = [[TL_updateChatUserTyping alloc] init];
	obj.chat_id = chat_id;
	obj.user_id = user_id;
	obj.action = action;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.user_id];
	[TLClassStore TLSerialize:self.action stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat_id = [stream readInt];
	self.user_id = [stream readInt];
	self.action = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_updateChatParticipants
+(TL_updateChatParticipants*)createWithParticipants:(TLChatParticipants*)participants {
	TL_updateChatParticipants* obj = [[TL_updateChatParticipants alloc] init];
	obj.participants = participants;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.participants stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.participants = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_updateUserStatus
+(TL_updateUserStatus*)createWithUser_id:(int)user_id status:(TLUserStatus*)status {
	TL_updateUserStatus* obj = [[TL_updateUserStatus alloc] init];
	obj.user_id = user_id;
	obj.status = status;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[TLClassStore TLSerialize:self.status stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.status = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_updateUserName
+(TL_updateUserName*)createWithUser_id:(int)user_id first_name:(NSString*)first_name last_name:(NSString*)last_name username:(NSString*)username {
	TL_updateUserName* obj = [[TL_updateUserName alloc] init];
	obj.user_id = user_id;
	obj.first_name = first_name;
	obj.last_name = last_name;
	obj.username = username;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeString:self.first_name];
	[stream writeString:self.last_name];
	[stream writeString:self.username];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.first_name = [stream readString];
	self.last_name = [stream readString];
	self.username = [stream readString];
}
@end

@implementation TL_updateUserPhoto
+(TL_updateUserPhoto*)createWithUser_id:(int)user_id date:(int)date photo:(TLUserProfilePhoto*)photo previous:(Boolean)previous {
	TL_updateUserPhoto* obj = [[TL_updateUserPhoto alloc] init];
	obj.user_id = user_id;
	obj.date = date;
	obj.photo = photo;
	obj.previous = previous;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
	[TLClassStore TLSerialize:self.photo stream:stream];
	[stream writeBool:self.previous];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.date = [stream readInt];
	self.photo = [TLClassStore TLDeserialize:stream];
	self.previous = [stream readBool];
}
@end

@implementation TL_updateContactRegistered
+(TL_updateContactRegistered*)createWithUser_id:(int)user_id date:(int)date {
	TL_updateContactRegistered* obj = [[TL_updateContactRegistered alloc] init];
	obj.user_id = user_id;
	obj.date = date;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.date = [stream readInt];
}
@end

@implementation TL_updateContactLink
+(TL_updateContactLink*)createWithUser_id:(int)user_id my_link:(TLcontacts_MyLink*)my_link foreign_link:(TLcontacts_ForeignLink*)foreign_link {
	TL_updateContactLink* obj = [[TL_updateContactLink alloc] init];
	obj.user_id = user_id;
	obj.my_link = my_link;
	obj.foreign_link = foreign_link;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[TLClassStore TLSerialize:self.my_link stream:stream];
	[TLClassStore TLSerialize:self.foreign_link stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.my_link = [TLClassStore TLDeserialize:stream];
	self.foreign_link = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_updateActivation
+(TL_updateActivation*)createWithUser_id:(int)user_id {
	TL_updateActivation* obj = [[TL_updateActivation alloc] init];
	obj.user_id = user_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
}
@end

@implementation TL_updateNewAuthorization
+(TL_updateNewAuthorization*)createWithAuth_key_id:(long)auth_key_id date:(int)date device:(NSString*)device location:(NSString*)location {
	TL_updateNewAuthorization* obj = [[TL_updateNewAuthorization alloc] init];
	obj.auth_key_id = auth_key_id;
	obj.date = date;
	obj.device = device;
	obj.location = location;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.auth_key_id];
	[stream writeInt:self.date];
	[stream writeString:self.device];
	[stream writeString:self.location];
}
-(void)unserialize:(SerializedData*)stream {
	self.auth_key_id = [stream readLong];
	self.date = [stream readInt];
	self.device = [stream readString];
	self.location = [stream readString];
}
@end

@implementation TL_updateNewGeoChatMessage
+(TL_updateNewGeoChatMessage*)createWithMessage:(TLGeoChatMessage*)message {
	TL_updateNewGeoChatMessage* obj = [[TL_updateNewGeoChatMessage alloc] init];
	obj.message = message;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.message stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.message = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_updateNewEncryptedMessage
+(TL_updateNewEncryptedMessage*)createWithMessage:(TLEncryptedMessage*)message qts:(int)qts {
	TL_updateNewEncryptedMessage* obj = [[TL_updateNewEncryptedMessage alloc] init];
	obj.message = message;
	obj.qts = qts;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.message stream:stream];
	[stream writeInt:self.qts];
}
-(void)unserialize:(SerializedData*)stream {
	self.message = [TLClassStore TLDeserialize:stream];
	self.qts = [stream readInt];
}
@end

@implementation TL_updateEncryptedChatTyping
+(TL_updateEncryptedChatTyping*)createWithChat_id:(int)chat_id {
	TL_updateEncryptedChatTyping* obj = [[TL_updateEncryptedChatTyping alloc] init];
	obj.chat_id = chat_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat_id = [stream readInt];
}
@end

@implementation TL_updateEncryption
+(TL_updateEncryption*)createWithChat:(TLEncryptedChat*)chat date:(int)date {
	TL_updateEncryption* obj = [[TL_updateEncryption alloc] init];
	obj.chat = chat;
	obj.date = date;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.chat stream:stream];
	[stream writeInt:self.date];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat = [TLClassStore TLDeserialize:stream];
	self.date = [stream readInt];
}
@end

@implementation TL_updateEncryptedMessagesRead
+(TL_updateEncryptedMessagesRead*)createWithChat_id:(int)chat_id max_date:(int)max_date date:(int)date {
	TL_updateEncryptedMessagesRead* obj = [[TL_updateEncryptedMessagesRead alloc] init];
	obj.chat_id = chat_id;
	obj.max_date = max_date;
	obj.date = date;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.max_date];
	[stream writeInt:self.date];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat_id = [stream readInt];
	self.max_date = [stream readInt];
	self.date = [stream readInt];
}
@end

@implementation TL_updateChatParticipantAdd
+(TL_updateChatParticipantAdd*)createWithChat_id:(int)chat_id user_id:(int)user_id inviter_id:(int)inviter_id version:(int)version {
	TL_updateChatParticipantAdd* obj = [[TL_updateChatParticipantAdd alloc] init];
	obj.chat_id = chat_id;
	obj.user_id = user_id;
	obj.inviter_id = inviter_id;
	obj.version = version;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.user_id];
	[stream writeInt:self.inviter_id];
	[stream writeInt:self.version];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat_id = [stream readInt];
	self.user_id = [stream readInt];
	self.inviter_id = [stream readInt];
	self.version = [stream readInt];
}
@end

@implementation TL_updateChatParticipantDelete
+(TL_updateChatParticipantDelete*)createWithChat_id:(int)chat_id user_id:(int)user_id version:(int)version {
	TL_updateChatParticipantDelete* obj = [[TL_updateChatParticipantDelete alloc] init];
	obj.chat_id = chat_id;
	obj.user_id = user_id;
	obj.version = version;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.user_id];
	[stream writeInt:self.version];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat_id = [stream readInt];
	self.user_id = [stream readInt];
	self.version = [stream readInt];
}
@end

@implementation TL_updateDcOptions
+(TL_updateDcOptions*)createWithDc_options:(NSMutableArray*)dc_options {
	TL_updateDcOptions* obj = [[TL_updateDcOptions alloc] init];
	obj.dc_options = dc_options;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.dc_options count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLDcOption* obj = [self.dc_options objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.dc_options)
			self.dc_options = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLDcOption* obj = [TLClassStore TLDeserialize:stream];
			[self.dc_options addObject:obj];
		}
	}
}
@end

@implementation TL_updateUserBlocked
+(TL_updateUserBlocked*)createWithUser_id:(int)user_id blocked:(Boolean)blocked {
	TL_updateUserBlocked* obj = [[TL_updateUserBlocked alloc] init];
	obj.user_id = user_id;
	obj.blocked = blocked;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeBool:self.blocked];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.blocked = [stream readBool];
}
@end

@implementation TL_updateNotifySettings
+(TL_updateNotifySettings*)createWithPeer:(TLNotifyPeer*)peer notify_settings:(TLPeerNotifySettings*)notify_settings {
	TL_updateNotifySettings* obj = [[TL_updateNotifySettings alloc] init];
	obj.peer = peer;
	obj.notify_settings = notify_settings;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.peer stream:stream];
	[TLClassStore TLSerialize:self.notify_settings stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.peer = [TLClassStore TLDeserialize:stream];
	self.notify_settings = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_updateServiceNotification
+(TL_updateServiceNotification*)createWithType:(NSString*)type message:(NSString*)message media:(TLMessageMedia*)media popup:(Boolean)popup {
	TL_updateServiceNotification* obj = [[TL_updateServiceNotification alloc] init];
	obj.type = type;
	obj.message = message;
	obj.media = media;
	obj.popup = popup;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.type];
	[stream writeString:self.message];
	[TLClassStore TLSerialize:self.media stream:stream];
	[stream writeBool:self.popup];
}
-(void)unserialize:(SerializedData*)stream {
	self.type = [stream readString];
	self.message = [stream readString];
	self.media = [TLClassStore TLDeserialize:stream];
	self.popup = [stream readBool];
}
@end

@implementation TL_updatePrivacy
+(TL_updatePrivacy*)createWithN_key:(TLPrivacyKey*)n_key rules:(NSMutableArray*)rules {
	TL_updatePrivacy* obj = [[TL_updatePrivacy alloc] init];
	obj.n_key = n_key;
	obj.rules = rules;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.n_key stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.rules count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLPrivacyRule* obj = [self.rules objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.n_key = [TLClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.rules)
			self.rules = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLPrivacyRule* obj = [TLClassStore TLDeserialize:stream];
			[self.rules addObject:obj];
		}
	}
}
@end

@implementation TL_updateUserPhone
+(TL_updateUserPhone*)createWithUser_id:(int)user_id phone:(NSString*)phone {
	TL_updateUserPhone* obj = [[TL_updateUserPhone alloc] init];
	obj.user_id = user_id;
	obj.phone = phone;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeString:self.phone];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
	self.phone = [stream readString];
}
@end



@implementation TLupdates_State
@end

@implementation TL_updates_state
+(TL_updates_state*)createWithPts:(int)pts qts:(int)qts date:(int)date seq:(int)seq unread_count:(int)unread_count {
	TL_updates_state* obj = [[TL_updates_state alloc] init];
	obj.pts = pts;
	obj.qts = qts;
	obj.date = date;
	obj.seq = seq;
	obj.unread_count = unread_count;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.pts];
	[stream writeInt:self.qts];
	[stream writeInt:self.date];
	[stream writeInt:self.seq];
	[stream writeInt:self.unread_count];
}
-(void)unserialize:(SerializedData*)stream {
	self.pts = [stream readInt];
	self.qts = [stream readInt];
	self.date = [stream readInt];
	self.seq = [stream readInt];
	self.unread_count = [stream readInt];
}
@end



@implementation TLupdates_Difference
@end

@implementation TL_updates_differenceEmpty
+(TL_updates_differenceEmpty*)createWithDate:(int)date seq:(int)seq {
	TL_updates_differenceEmpty* obj = [[TL_updates_differenceEmpty alloc] init];
	obj.date = date;
	obj.seq = seq;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.date];
	[stream writeInt:self.seq];
}
-(void)unserialize:(SerializedData*)stream {
	self.date = [stream readInt];
	self.seq = [stream readInt];
}
@end

@implementation TL_updates_difference
+(TL_updates_difference*)createWithN_messages:(NSMutableArray*)n_messages n_encrypted_messages:(NSMutableArray*)n_encrypted_messages other_updates:(NSMutableArray*)other_updates chats:(NSMutableArray*)chats users:(NSMutableArray*)users state:(TLupdates_State*)state {
	TL_updates_difference* obj = [[TL_updates_difference alloc] init];
	obj.n_messages = n_messages;
	obj.n_encrypted_messages = n_encrypted_messages;
	obj.other_updates = other_updates;
	obj.chats = chats;
	obj.users = users;
	obj.state = state;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLMessage* obj = [self.n_messages objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_encrypted_messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLEncryptedMessage* obj = [self.n_encrypted_messages objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.other_updates count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUpdate* obj = [self.other_updates objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	[TLClassStore TLSerialize:self.state stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.n_messages)
			self.n_messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessage* obj = [TLClassStore TLDeserialize:stream];
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
			TLEncryptedMessage* obj = [TLClassStore TLDeserialize:stream];
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
			TLUpdate* obj = [TLClassStore TLDeserialize:stream];
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
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
	self.state = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_updates_differenceSlice
+(TL_updates_differenceSlice*)createWithN_messages:(NSMutableArray*)n_messages n_encrypted_messages:(NSMutableArray*)n_encrypted_messages other_updates:(NSMutableArray*)other_updates chats:(NSMutableArray*)chats users:(NSMutableArray*)users intermediate_state:(TLupdates_State*)intermediate_state {
	TL_updates_differenceSlice* obj = [[TL_updates_differenceSlice alloc] init];
	obj.n_messages = n_messages;
	obj.n_encrypted_messages = n_encrypted_messages;
	obj.other_updates = other_updates;
	obj.chats = chats;
	obj.users = users;
	obj.intermediate_state = intermediate_state;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLMessage* obj = [self.n_messages objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_encrypted_messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLEncryptedMessage* obj = [self.n_encrypted_messages objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.other_updates count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUpdate* obj = [self.other_updates objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	[TLClassStore TLSerialize:self.intermediate_state stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.n_messages)
			self.n_messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessage* obj = [TLClassStore TLDeserialize:stream];
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
			TLEncryptedMessage* obj = [TLClassStore TLDeserialize:stream];
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
			TLUpdate* obj = [TLClassStore TLDeserialize:stream];
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
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
	self.intermediate_state = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLUpdates
@end

@implementation TL_updatesTooLong
+(TL_updatesTooLong*)create {
	TL_updatesTooLong* obj = [[TL_updatesTooLong alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_updateShortMessage
+(TL_updateShortMessage*)createWithN_id:(int)n_id from_id:(int)from_id message:(NSString*)message pts:(int)pts date:(int)date seq:(int)seq {
	TL_updateShortMessage* obj = [[TL_updateShortMessage alloc] init];
	obj.n_id = n_id;
	obj.from_id = from_id;
	obj.message = message;
	obj.pts = pts;
	obj.date = date;
	obj.seq = seq;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[stream writeString:self.message];
	[stream writeInt:self.pts];
	[stream writeInt:self.date];
	[stream writeInt:self.seq];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.from_id = [stream readInt];
	self.message = [stream readString];
	self.pts = [stream readInt];
	self.date = [stream readInt];
	self.seq = [stream readInt];
}
@end

@implementation TL_updateShortChatMessage
+(TL_updateShortChatMessage*)createWithN_id:(int)n_id from_id:(int)from_id chat_id:(int)chat_id message:(NSString*)message pts:(int)pts date:(int)date seq:(int)seq {
	TL_updateShortChatMessage* obj = [[TL_updateShortChatMessage alloc] init];
	obj.n_id = n_id;
	obj.from_id = from_id;
	obj.chat_id = chat_id;
	obj.message = message;
	obj.pts = pts;
	obj.date = date;
	obj.seq = seq;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[stream writeInt:self.chat_id];
	[stream writeString:self.message];
	[stream writeInt:self.pts];
	[stream writeInt:self.date];
	[stream writeInt:self.seq];
}
-(void)unserialize:(SerializedData*)stream {
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
+(TL_updateShort*)createWithUpdate:(TLUpdate*)update date:(int)date {
	TL_updateShort* obj = [[TL_updateShort alloc] init];
	obj.update = update;
	obj.date = date;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.update stream:stream];
	[stream writeInt:self.date];
}
-(void)unserialize:(SerializedData*)stream {
	self.update = [TLClassStore TLDeserialize:stream];
	self.date = [stream readInt];
}
@end

@implementation TL_updatesCombined
+(TL_updatesCombined*)createWithUpdates:(NSMutableArray*)updates users:(NSMutableArray*)users chats:(NSMutableArray*)chats date:(int)date seq_start:(int)seq_start seq:(int)seq {
	TL_updatesCombined* obj = [[TL_updatesCombined alloc] init];
	obj.updates = updates;
	obj.users = users;
	obj.chats = chats;
	obj.date = date;
	obj.seq_start = seq_start;
	obj.seq = seq;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.updates count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUpdate* obj = [self.updates objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.date];
	[stream writeInt:self.seq_start];
	[stream writeInt:self.seq];
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.updates)
			self.updates = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUpdate* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
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
			TLChat* obj = [TLClassStore TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	self.date = [stream readInt];
	self.seq_start = [stream readInt];
	self.seq = [stream readInt];
}
@end

@implementation TL_updates
+(TL_updates*)createWithUpdates:(NSMutableArray*)updates users:(NSMutableArray*)users chats:(NSMutableArray*)chats date:(int)date seq:(int)seq {
	TL_updates* obj = [[TL_updates alloc] init];
	obj.updates = updates;
	obj.users = users;
	obj.chats = chats;
	obj.date = date;
	obj.seq = seq;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.updates count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUpdate* obj = [self.updates objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.date];
	[stream writeInt:self.seq];
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.updates)
			self.updates = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUpdate* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
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
			TLChat* obj = [TLClassStore TLDeserialize:stream];
			[self.chats addObject:obj];
		}
	}
	self.date = [stream readInt];
	self.seq = [stream readInt];
}
@end



@implementation TLphotos_Photos
@end

@implementation TL_photos_photos
+(TL_photos_photos*)createWithPhotos:(NSMutableArray*)photos users:(NSMutableArray*)users {
	TL_photos_photos* obj = [[TL_photos_photos alloc] init];
	obj.photos = photos;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.photos count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLPhoto* obj = [self.photos objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.photos)
			self.photos = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLPhoto* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end

@implementation TL_photos_photosSlice
+(TL_photos_photosSlice*)createWithN_count:(int)n_count photos:(NSMutableArray*)photos users:(NSMutableArray*)users {
	TL_photos_photosSlice* obj = [[TL_photos_photosSlice alloc] init];
	obj.n_count = n_count;
	obj.photos = photos;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_count];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.photos count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLPhoto* obj = [self.photos objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.photos)
			self.photos = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLPhoto* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLphotos_Photo
@end

@implementation TL_photos_photo
+(TL_photos_photo*)createWithPhoto:(TLPhoto*)photo users:(NSMutableArray*)users {
	TL_photos_photo* obj = [[TL_photos_photo alloc] init];
	obj.photo = photo;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.photo stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.photo = [TLClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLupload_File
@end

@implementation TL_upload_file
+(TL_upload_file*)createWithType:(TLstorage_FileType*)type mtime:(int)mtime bytes:(NSData*)bytes {
	TL_upload_file* obj = [[TL_upload_file alloc] init];
	obj.type = type;
	obj.mtime = mtime;
	obj.bytes = bytes;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.type stream:stream];
	[stream writeInt:self.mtime];
	[stream writeByteArray:self.bytes];
}
-(void)unserialize:(SerializedData*)stream {
	self.type = [TLClassStore TLDeserialize:stream];
	self.mtime = [stream readInt];
	self.bytes = [stream readByteArray];
}
@end



@implementation TLDcOption
@end

@implementation TL_dcOption
+(TL_dcOption*)createWithN_id:(int)n_id hostname:(NSString*)hostname ip_address:(NSString*)ip_address port:(int)port {
	TL_dcOption* obj = [[TL_dcOption alloc] init];
	obj.n_id = n_id;
	obj.hostname = hostname;
	obj.ip_address = ip_address;
	obj.port = port;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.hostname];
	[stream writeString:self.ip_address];
	[stream writeInt:self.port];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.hostname = [stream readString];
	self.ip_address = [stream readString];
	self.port = [stream readInt];
}
@end



@implementation TLConfig
@end

@implementation TL_config
+(TL_config*)createWithDate:(int)date test_mode:(Boolean)test_mode this_dc:(int)this_dc dc_options:(NSMutableArray*)dc_options chat_size_max:(int)chat_size_max broadcast_size_max:(int)broadcast_size_max {
	TL_config* obj = [[TL_config alloc] init];
	obj.date = date;
	obj.test_mode = test_mode;
	obj.this_dc = this_dc;
	obj.dc_options = dc_options;
	obj.chat_size_max = chat_size_max;
	obj.broadcast_size_max = broadcast_size_max;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.date];
	[stream writeBool:self.test_mode];
	[stream writeInt:self.this_dc];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.dc_options count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLDcOption* obj = [self.dc_options objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.chat_size_max];
	[stream writeInt:self.broadcast_size_max];
}
-(void)unserialize:(SerializedData*)stream {
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
			TLDcOption* obj = [TLClassStore TLDeserialize:stream];
			[self.dc_options addObject:obj];
		}
	}
	self.chat_size_max = [stream readInt];
	self.broadcast_size_max = [stream readInt];
}
@end



@implementation TLNearestDc
@end

@implementation TL_nearestDc
+(TL_nearestDc*)createWithCountry:(NSString*)country this_dc:(int)this_dc nearest_dc:(int)nearest_dc {
	TL_nearestDc* obj = [[TL_nearestDc alloc] init];
	obj.country = country;
	obj.this_dc = this_dc;
	obj.nearest_dc = nearest_dc;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.country];
	[stream writeInt:self.this_dc];
	[stream writeInt:self.nearest_dc];
}
-(void)unserialize:(SerializedData*)stream {
	self.country = [stream readString];
	self.this_dc = [stream readInt];
	self.nearest_dc = [stream readInt];
}
@end



@implementation TLhelp_AppUpdate
@end

@implementation TL_help_appUpdate
+(TL_help_appUpdate*)createWithN_id:(int)n_id critical:(Boolean)critical url:(NSString*)url text:(NSString*)text {
	TL_help_appUpdate* obj = [[TL_help_appUpdate alloc] init];
	obj.n_id = n_id;
	obj.critical = critical;
	obj.url = url;
	obj.text = text;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeBool:self.critical];
	[stream writeString:self.url];
	[stream writeString:self.text];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.critical = [stream readBool];
	self.url = [stream readString];
	self.text = [stream readString];
}
@end

@implementation TL_help_noAppUpdate
+(TL_help_noAppUpdate*)create {
	TL_help_noAppUpdate* obj = [[TL_help_noAppUpdate alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end



@implementation TLhelp_InviteText
@end

@implementation TL_help_inviteText
+(TL_help_inviteText*)createWithMessage:(NSString*)message {
	TL_help_inviteText* obj = [[TL_help_inviteText alloc] init];
	obj.message = message;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.message];
}
-(void)unserialize:(SerializedData*)stream {
	self.message = [stream readString];
}
@end



@implementation TLInputGeoChat
@end

@implementation TL_inputGeoChat
+(TL_inputGeoChat*)createWithChat_id:(int)chat_id access_hash:(long)access_hash {
	TL_inputGeoChat* obj = [[TL_inputGeoChat alloc] init];
	obj.chat_id = chat_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat_id = [stream readInt];
	self.access_hash = [stream readLong];
}
@end



@implementation TLGeoChatMessage
@end

@implementation TL_geoChatMessageEmpty
+(TL_geoChatMessageEmpty*)createWithChat_id:(int)chat_id n_id:(int)n_id {
	TL_geoChatMessageEmpty* obj = [[TL_geoChatMessageEmpty alloc] init];
	obj.chat_id = chat_id;
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.n_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat_id = [stream readInt];
	self.n_id = [stream readInt];
}
@end

@implementation TL_geoChatMessage
+(TL_geoChatMessage*)createWithChat_id:(int)chat_id n_id:(int)n_id from_id:(int)from_id date:(int)date message:(NSString*)message media:(TLMessageMedia*)media {
	TL_geoChatMessage* obj = [[TL_geoChatMessage alloc] init];
	obj.chat_id = chat_id;
	obj.n_id = n_id;
	obj.from_id = from_id;
	obj.date = date;
	obj.message = message;
	obj.media = media;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[stream writeInt:self.date];
	[stream writeString:self.message];
	[TLClassStore TLSerialize:self.media stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat_id = [stream readInt];
	self.n_id = [stream readInt];
	self.from_id = [stream readInt];
	self.date = [stream readInt];
	self.message = [stream readString];
	self.media = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_geoChatMessageService
+(TL_geoChatMessageService*)createWithChat_id:(int)chat_id n_id:(int)n_id from_id:(int)from_id date:(int)date action:(TLMessageAction*)action {
	TL_geoChatMessageService* obj = [[TL_geoChatMessageService alloc] init];
	obj.chat_id = chat_id;
	obj.n_id = n_id;
	obj.from_id = from_id;
	obj.date = date;
	obj.action = action;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[stream writeInt:self.date];
	[TLClassStore TLSerialize:self.action stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat_id = [stream readInt];
	self.n_id = [stream readInt];
	self.from_id = [stream readInt];
	self.date = [stream readInt];
	self.action = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLgeochats_StatedMessage
@end

@implementation TL_geochats_statedMessage
+(TL_geochats_statedMessage*)createWithMessage:(TLGeoChatMessage*)message chats:(NSMutableArray*)chats users:(NSMutableArray*)users seq:(int)seq {
	TL_geochats_statedMessage* obj = [[TL_geochats_statedMessage alloc] init];
	obj.message = message;
	obj.chats = chats;
	obj.users = users;
	obj.seq = seq;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.message stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.seq];
}
-(void)unserialize:(SerializedData*)stream {
	self.message = [TLClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
	self.seq = [stream readInt];
}
@end



@implementation TLgeochats_Located
@end

@implementation TL_geochats_located
+(TL_geochats_located*)createWithResults:(NSMutableArray*)results messages:(NSMutableArray*)messages chats:(NSMutableArray*)chats users:(NSMutableArray*)users {
	TL_geochats_located* obj = [[TL_geochats_located alloc] init];
	obj.results = results;
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.results count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChatLocated* obj = [self.results objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLGeoChatMessage* obj = [self.messages objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.results)
			self.results = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChatLocated* obj = [TLClassStore TLDeserialize:stream];
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
			TLGeoChatMessage* obj = [TLClassStore TLDeserialize:stream];
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
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLgeochats_Messages
@end

@implementation TL_geochats_messages
+(TL_geochats_messages*)createWithMessages:(NSMutableArray*)messages chats:(NSMutableArray*)chats users:(NSMutableArray*)users {
	TL_geochats_messages* obj = [[TL_geochats_messages alloc] init];
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLGeoChatMessage* obj = [self.messages objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLGeoChatMessage* obj = [TLClassStore TLDeserialize:stream];
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
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end

@implementation TL_geochats_messagesSlice
+(TL_geochats_messagesSlice*)createWithN_count:(int)n_count messages:(NSMutableArray*)messages chats:(NSMutableArray*)chats users:(NSMutableArray*)users {
	TL_geochats_messagesSlice* obj = [[TL_geochats_messagesSlice alloc] init];
	obj.n_count = n_count;
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_count];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLGeoChatMessage* obj = [self.messages objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLChat* obj = [self.chats objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLGeoChatMessage* obj = [TLClassStore TLDeserialize:stream];
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
			TLChat* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLEncryptedChat
@end

@implementation TL_encryptedChatEmpty
+(TL_encryptedChatEmpty*)createWithN_id:(int)n_id {
	TL_encryptedChatEmpty* obj = [[TL_encryptedChatEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
}
@end

@implementation TL_encryptedChatWaiting
+(TL_encryptedChatWaiting*)createWithN_id:(int)n_id access_hash:(long)access_hash date:(int)date admin_id:(int)admin_id participant_id:(int)participant_id {
	TL_encryptedChatWaiting* obj = [[TL_encryptedChatWaiting alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.date = date;
	obj.admin_id = admin_id;
	obj.participant_id = participant_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.date];
	[stream writeInt:self.admin_id];
	[stream writeInt:self.participant_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.access_hash = [stream readLong];
	self.date = [stream readInt];
	self.admin_id = [stream readInt];
	self.participant_id = [stream readInt];
}
@end

@implementation TL_encryptedChatRequested
+(TL_encryptedChatRequested*)createWithN_id:(int)n_id access_hash:(long)access_hash date:(int)date admin_id:(int)admin_id participant_id:(int)participant_id g_a:(NSData*)g_a {
	TL_encryptedChatRequested* obj = [[TL_encryptedChatRequested alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.date = date;
	obj.admin_id = admin_id;
	obj.participant_id = participant_id;
	obj.g_a = g_a;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.date];
	[stream writeInt:self.admin_id];
	[stream writeInt:self.participant_id];
	[stream writeByteArray:self.g_a];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.access_hash = [stream readLong];
	self.date = [stream readInt];
	self.admin_id = [stream readInt];
	self.participant_id = [stream readInt];
	self.g_a = [stream readByteArray];
}
@end

@implementation TL_encryptedChat
+(TL_encryptedChat*)createWithN_id:(int)n_id access_hash:(long)access_hash date:(int)date admin_id:(int)admin_id participant_id:(int)participant_id g_a_or_b:(NSData*)g_a_or_b key_fingerprint:(long)key_fingerprint {
	TL_encryptedChat* obj = [[TL_encryptedChat alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.date = date;
	obj.admin_id = admin_id;
	obj.participant_id = participant_id;
	obj.g_a_or_b = g_a_or_b;
	obj.key_fingerprint = key_fingerprint;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.date];
	[stream writeInt:self.admin_id];
	[stream writeInt:self.participant_id];
	[stream writeByteArray:self.g_a_or_b];
	[stream writeLong:self.key_fingerprint];
}
-(void)unserialize:(SerializedData*)stream {
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
+(TL_encryptedChatDiscarded*)createWithN_id:(int)n_id {
	TL_encryptedChatDiscarded* obj = [[TL_encryptedChatDiscarded alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
}
@end



@implementation TLInputEncryptedChat
@end

@implementation TL_inputEncryptedChat
+(TL_inputEncryptedChat*)createWithChat_id:(int)chat_id access_hash:(long)access_hash {
	TL_inputEncryptedChat* obj = [[TL_inputEncryptedChat alloc] init];
	obj.chat_id = chat_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat_id = [stream readInt];
	self.access_hash = [stream readLong];
}
@end



@implementation TLEncryptedFile
@end

@implementation TL_encryptedFileEmpty
+(TL_encryptedFileEmpty*)create {
	TL_encryptedFileEmpty* obj = [[TL_encryptedFileEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_encryptedFile
+(TL_encryptedFile*)createWithN_id:(long)n_id access_hash:(long)access_hash size:(int)size dc_id:(int)dc_id key_fingerprint:(int)key_fingerprint {
	TL_encryptedFile* obj = [[TL_encryptedFile alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.size = size;
	obj.dc_id = dc_id;
	obj.key_fingerprint = key_fingerprint;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.size];
	[stream writeInt:self.dc_id];
	[stream writeInt:self.key_fingerprint];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
	self.size = [stream readInt];
	self.dc_id = [stream readInt];
	self.key_fingerprint = [stream readInt];
}
@end



@implementation TLInputEncryptedFile
@end

@implementation TL_inputEncryptedFileEmpty
+(TL_inputEncryptedFileEmpty*)create {
	TL_inputEncryptedFileEmpty* obj = [[TL_inputEncryptedFileEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputEncryptedFileUploaded
+(TL_inputEncryptedFileUploaded*)createWithN_id:(long)n_id parts:(int)parts md5_checksum:(NSString*)md5_checksum key_fingerprint:(int)key_fingerprint {
	TL_inputEncryptedFileUploaded* obj = [[TL_inputEncryptedFileUploaded alloc] init];
	obj.n_id = n_id;
	obj.parts = parts;
	obj.md5_checksum = md5_checksum;
	obj.key_fingerprint = key_fingerprint;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeInt:self.parts];
	[stream writeString:self.md5_checksum];
	[stream writeInt:self.key_fingerprint];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.parts = [stream readInt];
	self.md5_checksum = [stream readString];
	self.key_fingerprint = [stream readInt];
}
@end

@implementation TL_inputEncryptedFile
+(TL_inputEncryptedFile*)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputEncryptedFile* obj = [[TL_inputEncryptedFile alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end

@implementation TL_inputEncryptedFileBigUploaded
+(TL_inputEncryptedFileBigUploaded*)createWithN_id:(long)n_id parts:(int)parts key_fingerprint:(int)key_fingerprint {
	TL_inputEncryptedFileBigUploaded* obj = [[TL_inputEncryptedFileBigUploaded alloc] init];
	obj.n_id = n_id;
	obj.parts = parts;
	obj.key_fingerprint = key_fingerprint;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeInt:self.parts];
	[stream writeInt:self.key_fingerprint];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.parts = [stream readInt];
	self.key_fingerprint = [stream readInt];
}
@end



@implementation TLEncryptedMessage
@end

@implementation TL_encryptedMessage
+(TL_encryptedMessage*)createWithRandom_id:(long)random_id chat_id:(int)chat_id date:(int)date bytes:(NSData*)bytes file:(TLEncryptedFile*)file {
	TL_encryptedMessage* obj = [[TL_encryptedMessage alloc] init];
	obj.random_id = random_id;
	obj.chat_id = chat_id;
	obj.date = date;
	obj.bytes = bytes;
	obj.file = file;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.random_id];
	[stream writeInt:self.chat_id];
	[stream writeInt:self.date];
	[stream writeByteArray:self.bytes];
	[TLClassStore TLSerialize:self.file stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.random_id = [stream readLong];
	self.chat_id = [stream readInt];
	self.date = [stream readInt];
	self.bytes = [stream readByteArray];
	self.file = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_encryptedMessageService
+(TL_encryptedMessageService*)createWithRandom_id:(long)random_id chat_id:(int)chat_id date:(int)date bytes:(NSData*)bytes {
	TL_encryptedMessageService* obj = [[TL_encryptedMessageService alloc] init];
	obj.random_id = random_id;
	obj.chat_id = chat_id;
	obj.date = date;
	obj.bytes = bytes;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.random_id];
	[stream writeInt:self.chat_id];
	[stream writeInt:self.date];
	[stream writeByteArray:self.bytes];
}
-(void)unserialize:(SerializedData*)stream {
	self.random_id = [stream readLong];
	self.chat_id = [stream readInt];
	self.date = [stream readInt];
	self.bytes = [stream readByteArray];
}
@end



@implementation TLmessages_DhConfig
@end

@implementation TL_messages_dhConfigNotModified
+(TL_messages_dhConfigNotModified*)createWithRandom:(NSData*)random {
	TL_messages_dhConfigNotModified* obj = [[TL_messages_dhConfigNotModified alloc] init];
	obj.random = random;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeByteArray:self.random];
}
-(void)unserialize:(SerializedData*)stream {
	self.random = [stream readByteArray];
}
@end

@implementation TL_messages_dhConfig
+(TL_messages_dhConfig*)createWithG:(int)g p:(NSData*)p version:(int)version random:(NSData*)random {
	TL_messages_dhConfig* obj = [[TL_messages_dhConfig alloc] init];
	obj.g = g;
	obj.p = p;
	obj.version = version;
	obj.random = random;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.g];
	[stream writeByteArray:self.p];
	[stream writeInt:self.version];
	[stream writeByteArray:self.random];
}
-(void)unserialize:(SerializedData*)stream {
	self.g = [stream readInt];
	self.p = [stream readByteArray];
	self.version = [stream readInt];
	self.random = [stream readByteArray];
}
@end



@implementation TLmessages_SentEncryptedMessage
@end

@implementation TL_messages_sentEncryptedMessage
+(TL_messages_sentEncryptedMessage*)createWithDate:(int)date {
	TL_messages_sentEncryptedMessage* obj = [[TL_messages_sentEncryptedMessage alloc] init];
	obj.date = date;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.date];
}
-(void)unserialize:(SerializedData*)stream {
	self.date = [stream readInt];
}
@end

@implementation TL_messages_sentEncryptedFile
+(TL_messages_sentEncryptedFile*)createWithDate:(int)date file:(TLEncryptedFile*)file {
	TL_messages_sentEncryptedFile* obj = [[TL_messages_sentEncryptedFile alloc] init];
	obj.date = date;
	obj.file = file;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.date];
	[TLClassStore TLSerialize:self.file stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.date = [stream readInt];
	self.file = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLInputAudio
@end

@implementation TL_inputAudioEmpty
+(TL_inputAudioEmpty*)create {
	TL_inputAudioEmpty* obj = [[TL_inputAudioEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputAudio
+(TL_inputAudio*)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputAudio* obj = [[TL_inputAudio alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end



@implementation TLInputDocument
@end

@implementation TL_inputDocumentEmpty
+(TL_inputDocumentEmpty*)create {
	TL_inputDocumentEmpty* obj = [[TL_inputDocumentEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputDocument
+(TL_inputDocument*)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputDocument* obj = [[TL_inputDocument alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
}
@end



@implementation TLAudio
@end

@implementation TL_audioEmpty
+(TL_audioEmpty*)createWithN_id:(long)n_id {
	TL_audioEmpty* obj = [[TL_audioEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
}
@end

@implementation TL_audio
+(TL_audio*)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date duration:(int)duration mime_type:(NSString*)mime_type size:(int)size dc_id:(int)dc_id {
	TL_audio* obj = [[TL_audio alloc] init];
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
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
	[stream writeInt:self.duration];
	[stream writeString:self.mime_type];
	[stream writeInt:self.size];
	[stream writeInt:self.dc_id];
}
-(void)unserialize:(SerializedData*)stream {
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



@implementation TLDocument
@end

@implementation TL_documentEmpty
+(TL_documentEmpty*)createWithN_id:(long)n_id {
	TL_documentEmpty* obj = [[TL_documentEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
}
@end

@implementation TL_document
+(TL_document*)createWithN_id:(long)n_id access_hash:(long)access_hash date:(int)date mime_type:(NSString*)mime_type size:(int)size thumb:(TLPhotoSize*)thumb dc_id:(int)dc_id attributes:(NSMutableArray*)attributes {
	TL_document* obj = [[TL_document alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.date = date;
	obj.mime_type = mime_type;
	obj.size = size;
	obj.thumb = thumb;
	obj.dc_id = dc_id;
	obj.attributes = attributes;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.date];
	[stream writeString:self.mime_type];
	[stream writeInt:self.size];
	[TLClassStore TLSerialize:self.thumb stream:stream];
	[stream writeInt:self.dc_id];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.attributes count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLDocumentAttribute* obj = [self.attributes objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
	self.date = [stream readInt];
	self.mime_type = [stream readString];
	self.size = [stream readInt];
	self.thumb = [TLClassStore TLDeserialize:stream];
	self.dc_id = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.attributes)
			self.attributes = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLDocumentAttribute* obj = [TLClassStore TLDeserialize:stream];
			[self.attributes addObject:obj];
		}
	}
}
@end



@implementation TLhelp_Support
@end

@implementation TL_help_support
+(TL_help_support*)createWithPhone_number:(NSString*)phone_number user:(TLUser*)user {
	TL_help_support* obj = [[TL_help_support alloc] init];
	obj.phone_number = phone_number;
	obj.user = user;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.phone_number];
	[TLClassStore TLSerialize:self.user stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.phone_number = [stream readString];
	self.user = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLNotifyPeer
@end

@implementation TL_notifyPeer
+(TL_notifyPeer*)createWithPeer:(TLPeer*)peer {
	TL_notifyPeer* obj = [[TL_notifyPeer alloc] init];
	obj.peer = peer;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.peer stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.peer = [TLClassStore TLDeserialize:stream];
}
@end

@implementation TL_notifyUsers
+(TL_notifyUsers*)create {
	TL_notifyUsers* obj = [[TL_notifyUsers alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_notifyChats
+(TL_notifyChats*)create {
	TL_notifyChats* obj = [[TL_notifyChats alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_notifyAll
+(TL_notifyAll*)create {
	TL_notifyAll* obj = [[TL_notifyAll alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end



@implementation TLSendMessageAction
@end

@implementation TL_sendMessageTypingAction
+(TL_sendMessageTypingAction*)create {
	TL_sendMessageTypingAction* obj = [[TL_sendMessageTypingAction alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_sendMessageCancelAction
+(TL_sendMessageCancelAction*)create {
	TL_sendMessageCancelAction* obj = [[TL_sendMessageCancelAction alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_sendMessageRecordVideoAction
+(TL_sendMessageRecordVideoAction*)create {
	TL_sendMessageRecordVideoAction* obj = [[TL_sendMessageRecordVideoAction alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_sendMessageUploadVideoAction
+(TL_sendMessageUploadVideoAction*)create {
	TL_sendMessageUploadVideoAction* obj = [[TL_sendMessageUploadVideoAction alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_sendMessageRecordAudioAction
+(TL_sendMessageRecordAudioAction*)create {
	TL_sendMessageRecordAudioAction* obj = [[TL_sendMessageRecordAudioAction alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_sendMessageUploadAudioAction
+(TL_sendMessageUploadAudioAction*)create {
	TL_sendMessageUploadAudioAction* obj = [[TL_sendMessageUploadAudioAction alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_sendMessageUploadPhotoAction
+(TL_sendMessageUploadPhotoAction*)create {
	TL_sendMessageUploadPhotoAction* obj = [[TL_sendMessageUploadPhotoAction alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_sendMessageUploadDocumentAction
+(TL_sendMessageUploadDocumentAction*)create {
	TL_sendMessageUploadDocumentAction* obj = [[TL_sendMessageUploadDocumentAction alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_sendMessageGeoLocationAction
+(TL_sendMessageGeoLocationAction*)create {
	TL_sendMessageGeoLocationAction* obj = [[TL_sendMessageGeoLocationAction alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_sendMessageChooseContactAction
+(TL_sendMessageChooseContactAction*)create {
	TL_sendMessageChooseContactAction* obj = [[TL_sendMessageChooseContactAction alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end



@implementation TLContactFound
@end

@implementation TL_contactFound
+(TL_contactFound*)createWithUser_id:(int)user_id {
	TL_contactFound* obj = [[TL_contactFound alloc] init];
	obj.user_id = user_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.user_id = [stream readInt];
}
@end



@implementation TLcontacts_Found
@end

@implementation TL_contacts_found
+(TL_contacts_found*)createWithResults:(NSMutableArray*)results users:(NSMutableArray*)users {
	TL_contacts_found* obj = [[TL_contacts_found alloc] init];
	obj.results = results;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.results count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLContactFound* obj = [self.results objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.results)
			self.results = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLContactFound* obj = [TLClassStore TLDeserialize:stream];
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
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLInputPrivacyKey
@end

@implementation TL_inputPrivacyKeyStatusTimestamp
+(TL_inputPrivacyKeyStatusTimestamp*)create {
	TL_inputPrivacyKeyStatusTimestamp* obj = [[TL_inputPrivacyKeyStatusTimestamp alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end



@implementation TLPrivacyKey
@end

@implementation TL_privacyKeyStatusTimestamp
+(TL_privacyKeyStatusTimestamp*)create {
	TL_privacyKeyStatusTimestamp* obj = [[TL_privacyKeyStatusTimestamp alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end



@implementation TLInputPrivacyRule
@end

@implementation TL_inputPrivacyValueAllowContacts
+(TL_inputPrivacyValueAllowContacts*)create {
	TL_inputPrivacyValueAllowContacts* obj = [[TL_inputPrivacyValueAllowContacts alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputPrivacyValueAllowAll
+(TL_inputPrivacyValueAllowAll*)create {
	TL_inputPrivacyValueAllowAll* obj = [[TL_inputPrivacyValueAllowAll alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputPrivacyValueAllowUsers
+(TL_inputPrivacyValueAllowUsers*)createWithUsers:(NSMutableArray*)users {
	TL_inputPrivacyValueAllowUsers* obj = [[TL_inputPrivacyValueAllowUsers alloc] init];
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLInputUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLInputUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end

@implementation TL_inputPrivacyValueDisallowContacts
+(TL_inputPrivacyValueDisallowContacts*)create {
	TL_inputPrivacyValueDisallowContacts* obj = [[TL_inputPrivacyValueDisallowContacts alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputPrivacyValueDisallowAll
+(TL_inputPrivacyValueDisallowAll*)create {
	TL_inputPrivacyValueDisallowAll* obj = [[TL_inputPrivacyValueDisallowAll alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_inputPrivacyValueDisallowUsers
+(TL_inputPrivacyValueDisallowUsers*)createWithUsers:(NSMutableArray*)users {
	TL_inputPrivacyValueDisallowUsers* obj = [[TL_inputPrivacyValueDisallowUsers alloc] init];
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLInputUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLInputUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLPrivacyRule
@end

@implementation TL_privacyValueAllowContacts
+(TL_privacyValueAllowContacts*)create {
	TL_privacyValueAllowContacts* obj = [[TL_privacyValueAllowContacts alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_privacyValueAllowAll
+(TL_privacyValueAllowAll*)create {
	TL_privacyValueAllowAll* obj = [[TL_privacyValueAllowAll alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_privacyValueAllowUsers
+(TL_privacyValueAllowUsers*)createWithUsers:(NSMutableArray*)users {
	TL_privacyValueAllowUsers* obj = [[TL_privacyValueAllowUsers alloc] init];
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
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
-(void)unserialize:(SerializedData*)stream {
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

@implementation TL_privacyValueDisallowContacts
+(TL_privacyValueDisallowContacts*)create {
	TL_privacyValueDisallowContacts* obj = [[TL_privacyValueDisallowContacts alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_privacyValueDisallowAll
+(TL_privacyValueDisallowAll*)create {
	TL_privacyValueDisallowAll* obj = [[TL_privacyValueDisallowAll alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_privacyValueDisallowUsers
+(TL_privacyValueDisallowUsers*)createWithUsers:(NSMutableArray*)users {
	TL_privacyValueDisallowUsers* obj = [[TL_privacyValueDisallowUsers alloc] init];
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
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
-(void)unserialize:(SerializedData*)stream {
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



@implementation TLaccount_PrivacyRules
@end

@implementation TL_account_privacyRules
+(TL_account_privacyRules*)createWithRules:(NSMutableArray*)rules users:(NSMutableArray*)users {
	TL_account_privacyRules* obj = [[TL_account_privacyRules alloc] init];
	obj.rules = rules;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.rules count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLPrivacyRule* obj = [self.rules objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
			TLUser* obj = [self.users objectAtIndex:i];
			[TLClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.rules)
			self.rules = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLPrivacyRule* obj = [TLClassStore TLDeserialize:stream];
			[self.rules addObject:obj];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [TLClassStore TLDeserialize:stream];
			[self.users addObject:obj];
		}
	}
}
@end



@implementation TLAccountDaysTTL
@end

@implementation TL_accountDaysTTL
+(TL_accountDaysTTL*)createWithDays:(int)days {
	TL_accountDaysTTL* obj = [[TL_accountDaysTTL alloc] init];
	obj.days = days;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.days];
}
-(void)unserialize:(SerializedData*)stream {
	self.days = [stream readInt];
}
@end



@implementation TLaccount_SentChangePhoneCode
@end

@implementation TL_account_sentChangePhoneCode
+(TL_account_sentChangePhoneCode*)createWithPhone_code_hash:(NSString*)phone_code_hash send_call_timeout:(int)send_call_timeout {
	TL_account_sentChangePhoneCode* obj = [[TL_account_sentChangePhoneCode alloc] init];
	obj.phone_code_hash = phone_code_hash;
	obj.send_call_timeout = send_call_timeout;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.phone_code_hash];
	[stream writeInt:self.send_call_timeout];
}
-(void)unserialize:(SerializedData*)stream {
	self.phone_code_hash = [stream readString];
	self.send_call_timeout = [stream readInt];
}
@end



@implementation TLaccount_Password
@end

@implementation TL_account_noPassword
+(TL_account_noPassword*)createWithN_salt:(NSData*)n_salt {
	TL_account_noPassword* obj = [[TL_account_noPassword alloc] init];
	obj.n_salt = n_salt;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeByteArray:self.n_salt];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_salt = [stream readByteArray];
}
@end

@implementation TL_account_password
+(TL_account_password*)createWithCurrent_salt:(NSData*)current_salt n_salt:(NSData*)n_salt hint:(NSString*)hint {
	TL_account_password* obj = [[TL_account_password alloc] init];
	obj.current_salt = current_salt;
	obj.n_salt = n_salt;
	obj.hint = hint;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeByteArray:self.current_salt];
	[stream writeByteArray:self.n_salt];
	[stream writeString:self.hint];
}
-(void)unserialize:(SerializedData*)stream {
	self.current_salt = [stream readByteArray];
	self.n_salt = [stream readByteArray];
	self.hint = [stream readString];
}
@end



@implementation TLDocumentAttribute
@end

@implementation TL_documentAttributeImageSize
+(TL_documentAttributeImageSize*)createWithW:(int)w h:(int)h {
	TL_documentAttributeImageSize* obj = [[TL_documentAttributeImageSize alloc] init];
	obj.w = w;
	obj.h = h;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.w];
	[stream writeInt:self.h];
}
-(void)unserialize:(SerializedData*)stream {
	self.w = [stream readInt];
	self.h = [stream readInt];
}
@end

@implementation TL_documentAttributeAnimated
+(TL_documentAttributeAnimated*)create {
	TL_documentAttributeAnimated* obj = [[TL_documentAttributeAnimated alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_documentAttributeSticker
+(TL_documentAttributeSticker*)create {
	TL_documentAttributeSticker* obj = [[TL_documentAttributeSticker alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_documentAttributeVideo
+(TL_documentAttributeVideo*)createWithDuration:(int)duration w:(int)w h:(int)h {
	TL_documentAttributeVideo* obj = [[TL_documentAttributeVideo alloc] init];
	obj.duration = duration;
	obj.w = w;
	obj.h = h;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.duration];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
}
-(void)unserialize:(SerializedData*)stream {
	self.duration = [stream readInt];
	self.w = [stream readInt];
	self.h = [stream readInt];
}
@end

@implementation TL_documentAttributeAudio
+(TL_documentAttributeAudio*)createWithDuration:(int)duration {
	TL_documentAttributeAudio* obj = [[TL_documentAttributeAudio alloc] init];
	obj.duration = duration;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.duration];
}
-(void)unserialize:(SerializedData*)stream {
	self.duration = [stream readInt];
}
@end

@implementation TL_documentAttributeFilename
+(TL_documentAttributeFilename*)createWithFile_name:(NSString*)file_name {
	TL_documentAttributeFilename* obj = [[TL_documentAttributeFilename alloc] init];
	obj.file_name = file_name;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.file_name];
}
-(void)unserialize:(SerializedData*)stream {
	self.file_name = [stream readString];
}
@end



@implementation TLProtoMessage
@end

@implementation TL_proto_message
+(TL_proto_message*)createWithMsg_id:(long)msg_id seqno:(int)seqno bytes:(int)bytes body:(TLObject*)body {
	TL_proto_message* obj = [[TL_proto_message alloc] init];
	obj.msg_id = msg_id;
	obj.seqno = seqno;
	obj.bytes = bytes;
	obj.body = body;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.msg_id];
	[stream writeInt:self.seqno];
	[stream writeInt:self.bytes];
	[TLClassStore TLSerialize:self.body stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.msg_id = [stream readLong];
	self.seqno = [stream readInt];
	self.bytes = [stream readInt];
	self.body = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLProtoMessageContainer
@end

@implementation TL_msg_container
+(TL_msg_container*)createWithMessages:(NSMutableArray*)messages {
	TL_msg_container* obj = [[TL_msg_container alloc] init];
	obj.messages = messages;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
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
-(void)unserialize:(SerializedData*)stream {
	//UNS ShortVector (custom class) //TODO
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			TL_proto_message* obj = [[TL_proto_message alloc] init];
			[obj unserialize:stream];
			[self.messages addObject:obj];
		}
	}
}
@end



@implementation TLResPQ
@end

@implementation TL_req_pq
+(TL_req_pq*)createWithNonce:(NSData*)nonce {
	TL_req_pq* obj = [[TL_req_pq alloc] init];
	obj.nonce = nonce;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeData:self.nonce];
}
-(void)unserialize:(SerializedData*)stream {
	self.nonce = [stream readData:16];
}
@end

@implementation TL_resPQ
+(TL_resPQ*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce pq:(NSData*)pq server_public_key_fingerprints:(NSMutableArray*)server_public_key_fingerprints {
	TL_resPQ* obj = [[TL_resPQ alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.pq = pq;
	obj.server_public_key_fingerprints = server_public_key_fingerprints;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
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
-(void)unserialize:(SerializedData*)stream {
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



@implementation TLServer_DH_inner_data
@end

@implementation TL_server_DH_inner_data
+(TL_server_DH_inner_data*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce g:(int)g dh_prime:(NSData*)dh_prime g_a:(NSData*)g_a server_time:(int)server_time {
	TL_server_DH_inner_data* obj = [[TL_server_DH_inner_data alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.g = g;
	obj.dh_prime = dh_prime;
	obj.g_a = g_a;
	obj.server_time = server_time;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeInt:self.g];
	[stream writeByteArray:self.dh_prime];
	[stream writeByteArray:self.g_a];
	[stream writeInt:self.server_time];
}
-(void)unserialize:(SerializedData*)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.g = [stream readInt];
	self.dh_prime = [stream readByteArray];
	self.g_a = [stream readByteArray];
	self.server_time = [stream readInt];
}
@end



@implementation TLP_Q_inner_data
@end

@implementation TL_p_q_inner_data
+(TL_p_q_inner_data*)createWithPq:(NSData*)pq p:(NSData*)p q:(NSData*)q nonce:(NSData*)nonce server_nonce:(NSData*)server_nonce n_nonce:(NSData*)n_nonce {
	TL_p_q_inner_data* obj = [[TL_p_q_inner_data alloc] init];
	obj.pq = pq;
	obj.p = p;
	obj.q = q;
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.n_nonce = n_nonce;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeByteArray:self.pq];
	[stream writeByteArray:self.p];
	[stream writeByteArray:self.q];
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeData:self.n_nonce];
}
-(void)unserialize:(SerializedData*)stream {
	self.pq = [stream readByteArray];
	self.p = [stream readByteArray];
	self.q = [stream readByteArray];
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.n_nonce = [stream readData:32];
}
@end



@implementation TLServer_DH_Params
@end

@implementation TL_req_DH_params
+(TL_req_DH_params*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce p:(NSData*)p q:(NSData*)q public_key_fingerprint:(long)public_key_fingerprint encrypted_data:(NSData*)encrypted_data {
	TL_req_DH_params* obj = [[TL_req_DH_params alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.p = p;
	obj.q = q;
	obj.public_key_fingerprint = public_key_fingerprint;
	obj.encrypted_data = encrypted_data;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeByteArray:self.p];
	[stream writeByteArray:self.q];
	[stream writeLong:self.public_key_fingerprint];
	[stream writeByteArray:self.encrypted_data];
}
-(void)unserialize:(SerializedData*)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.p = [stream readByteArray];
	self.q = [stream readByteArray];
	self.public_key_fingerprint = [stream readLong];
	self.encrypted_data = [stream readByteArray];
}
@end

@implementation TL_server_DH_params_fail
+(TL_server_DH_params_fail*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce n_nonce_hash:(NSData*)n_nonce_hash {
	TL_server_DH_params_fail* obj = [[TL_server_DH_params_fail alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.n_nonce_hash = n_nonce_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeData:self.n_nonce_hash];
}
-(void)unserialize:(SerializedData*)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.n_nonce_hash = [stream readData:16];
}
@end

@implementation TL_server_DH_params_ok
+(TL_server_DH_params_ok*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce encrypted_answer:(NSData*)encrypted_answer {
	TL_server_DH_params_ok* obj = [[TL_server_DH_params_ok alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.encrypted_answer = encrypted_answer;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeByteArray:self.encrypted_answer];
}
-(void)unserialize:(SerializedData*)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.encrypted_answer = [stream readByteArray];
}
@end



@implementation TLClient_DH_Inner_Data
@end

@implementation TL_client_DH_inner_data
+(TL_client_DH_inner_data*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce retry_id:(long)retry_id g_b:(NSData*)g_b {
	TL_client_DH_inner_data* obj = [[TL_client_DH_inner_data alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.retry_id = retry_id;
	obj.g_b = g_b;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeLong:self.retry_id];
	[stream writeByteArray:self.g_b];
}
-(void)unserialize:(SerializedData*)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.retry_id = [stream readLong];
	self.g_b = [stream readByteArray];
}
@end



@implementation TLSet_client_DH_params_answer
@end

@implementation TL_set_client_DH_params
+(TL_set_client_DH_params*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce encrypted_data:(NSData*)encrypted_data {
	TL_set_client_DH_params* obj = [[TL_set_client_DH_params alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.encrypted_data = encrypted_data;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeByteArray:self.encrypted_data];
}
-(void)unserialize:(SerializedData*)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.encrypted_data = [stream readByteArray];
}
@end

@implementation TL_dh_gen_ok
+(TL_dh_gen_ok*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce n_nonce_hash1:(NSData*)n_nonce_hash1 {
	TL_dh_gen_ok* obj = [[TL_dh_gen_ok alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.n_nonce_hash1 = n_nonce_hash1;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeData:self.n_nonce_hash1];
}
-(void)unserialize:(SerializedData*)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.n_nonce_hash1 = [stream readData:16];
}
@end

@implementation TL_dh_gen_retry
+(TL_dh_gen_retry*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce n_nonce_hash2:(NSData*)n_nonce_hash2 {
	TL_dh_gen_retry* obj = [[TL_dh_gen_retry alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.n_nonce_hash2 = n_nonce_hash2;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeData:self.n_nonce_hash2];
}
-(void)unserialize:(SerializedData*)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.n_nonce_hash2 = [stream readData:16];
}
@end

@implementation TL_dh_gen_fail
+(TL_dh_gen_fail*)createWithNonce:(NSData*)nonce server_nonce:(NSData*)server_nonce n_nonce_hash3:(NSData*)n_nonce_hash3 {
	TL_dh_gen_fail* obj = [[TL_dh_gen_fail alloc] init];
	obj.nonce = nonce;
	obj.server_nonce = server_nonce;
	obj.n_nonce_hash3 = n_nonce_hash3;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeData:self.nonce];
	[stream writeData:self.server_nonce];
	[stream writeData:self.n_nonce_hash3];
}
-(void)unserialize:(SerializedData*)stream {
	self.nonce = [stream readData:16];
	self.server_nonce = [stream readData:16];
	self.n_nonce_hash3 = [stream readData:16];
}
@end



@implementation TLPong
@end

@implementation TL_ping
+(TL_ping*)createWithPing_id:(long)ping_id {
	TL_ping* obj = [[TL_ping alloc] init];
	obj.ping_id = ping_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.ping_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.ping_id = [stream readLong];
}
@end

@implementation TL_pong
+(TL_pong*)createWithMsg_id:(long)msg_id ping_id:(long)ping_id {
	TL_pong* obj = [[TL_pong alloc] init];
	obj.msg_id = msg_id;
	obj.ping_id = ping_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.msg_id];
	[stream writeLong:self.ping_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.msg_id = [stream readLong];
	self.ping_id = [stream readLong];
}
@end



@implementation TLBadMsgNotification
@end

@implementation TL_bad_msg_notification
+(TL_bad_msg_notification*)createWithBad_msg_id:(long)bad_msg_id bad_msg_seqno:(int)bad_msg_seqno error_code:(int)error_code {
	TL_bad_msg_notification* obj = [[TL_bad_msg_notification alloc] init];
	obj.bad_msg_id = bad_msg_id;
	obj.bad_msg_seqno = bad_msg_seqno;
	obj.error_code = error_code;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.bad_msg_id];
	[stream writeInt:self.bad_msg_seqno];
	[stream writeInt:self.error_code];
}
-(void)unserialize:(SerializedData*)stream {
	self.bad_msg_id = [stream readLong];
	self.bad_msg_seqno = [stream readInt];
	self.error_code = [stream readInt];
}
@end

@implementation TL_bad_server_salt
+(TL_bad_server_salt*)createWithBad_msg_id:(long)bad_msg_id bad_msg_seqno:(int)bad_msg_seqno error_code:(int)error_code new_server_salt:(long)new_server_salt {
	TL_bad_server_salt* obj = [[TL_bad_server_salt alloc] init];
	obj.bad_msg_id = bad_msg_id;
	obj.bad_msg_seqno = bad_msg_seqno;
	obj.error_code = error_code;
	obj.new_server_salt = new_server_salt;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.bad_msg_id];
	[stream writeInt:self.bad_msg_seqno];
	[stream writeInt:self.error_code];
	[stream writeLong:self.new_server_salt];
}
-(void)unserialize:(SerializedData*)stream {
	self.bad_msg_id = [stream readLong];
	self.bad_msg_seqno = [stream readInt];
	self.error_code = [stream readInt];
	self.new_server_salt = [stream readLong];
}
@end



@implementation TLNewSession
@end

@implementation TL_new_session_created
+(TL_new_session_created*)createWithFirst_msg_id:(long)first_msg_id unique_id:(long)unique_id server_salt:(long)server_salt {
	TL_new_session_created* obj = [[TL_new_session_created alloc] init];
	obj.first_msg_id = first_msg_id;
	obj.unique_id = unique_id;
	obj.server_salt = server_salt;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.first_msg_id];
	[stream writeLong:self.unique_id];
	[stream writeLong:self.server_salt];
}
-(void)unserialize:(SerializedData*)stream {
	self.first_msg_id = [stream readLong];
	self.unique_id = [stream readLong];
	self.server_salt = [stream readLong];
}
@end



@implementation TLRpcResult
@end

@implementation TL_rpc_result
+(TL_rpc_result*)createWithReq_msg_id:(long)req_msg_id result:(TLObject*)result {
	TL_rpc_result* obj = [[TL_rpc_result alloc] init];
	obj.req_msg_id = req_msg_id;
	obj.result = result;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.req_msg_id];
	[TLClassStore TLSerialize:self.result stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.req_msg_id = [stream readLong];
	self.result = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TLRpcError
@end

@implementation TL_rpc_error
+(TL_rpc_error*)createWithError_code:(int)error_code error_message:(NSString*)error_message {
	TL_rpc_error* obj = [[TL_rpc_error alloc] init];
	obj.error_code = error_code;
	obj.error_message = error_message;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.error_code];
	[stream writeString:self.error_message];
}
-(void)unserialize:(SerializedData*)stream {
	self.error_code = [stream readInt];
	self.error_message = [stream readString];
}
@end



@implementation TLRSAPublicKey
@end

@implementation TL_rsa_public_key
+(TL_rsa_public_key*)createWithN:(NSData*)n e:(NSData*)e {
	TL_rsa_public_key* obj = [[TL_rsa_public_key alloc] init];
	obj.n = n;
	obj.e = e;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeByteArray:self.n];
	[stream writeByteArray:self.e];
}
-(void)unserialize:(SerializedData*)stream {
	self.n = [stream readByteArray];
	self.e = [stream readByteArray];
}
@end



@implementation TLMsgsAck
@end

@implementation TL_msgs_ack
+(TL_msgs_ack*)createWithMsg_ids:(NSMutableArray*)msg_ids {
	TL_msgs_ack* obj = [[TL_msgs_ack alloc] init];
	obj.msg_ids = msg_ids;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
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
-(void)unserialize:(SerializedData*)stream {
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



@implementation TLRpcDropAnswer
@end

@implementation TL_rpc_drop_answer
+(TL_rpc_drop_answer*)createWithReq_msg_id:(long)req_msg_id {
	TL_rpc_drop_answer* obj = [[TL_rpc_drop_answer alloc] init];
	obj.req_msg_id = req_msg_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.req_msg_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.req_msg_id = [stream readLong];
}
@end

@implementation TL_rpc_answer_unknown
+(TL_rpc_answer_unknown*)create {
	TL_rpc_answer_unknown* obj = [[TL_rpc_answer_unknown alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_rpc_answer_dropped_running
+(TL_rpc_answer_dropped_running*)create {
	TL_rpc_answer_dropped_running* obj = [[TL_rpc_answer_dropped_running alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
@end

@implementation TL_rpc_answer_dropped
+(TL_rpc_answer_dropped*)createWithMsg_id:(long)msg_id seq_no:(int)seq_no bytes:(int)bytes {
	TL_rpc_answer_dropped* obj = [[TL_rpc_answer_dropped alloc] init];
	obj.msg_id = msg_id;
	obj.seq_no = seq_no;
	obj.bytes = bytes;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.msg_id];
	[stream writeInt:self.seq_no];
	[stream writeInt:self.bytes];
}
-(void)unserialize:(SerializedData*)stream {
	self.msg_id = [stream readLong];
	self.seq_no = [stream readInt];
	self.bytes = [stream readInt];
}
@end



@implementation TLFutureSalts
@end

@implementation TL_get_future_salts
+(TL_get_future_salts*)createWithNum:(int)num {
	TL_get_future_salts* obj = [[TL_get_future_salts alloc] init];
	obj.num = num;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.num];
}
-(void)unserialize:(SerializedData*)stream {
	self.num = [stream readInt];
}
@end

@implementation TL_future_salts
+(TL_future_salts*)createWithReq_msg_id:(long)req_msg_id now:(int)now salts:(NSMutableArray*)salts {
	TL_future_salts* obj = [[TL_future_salts alloc] init];
	obj.req_msg_id = req_msg_id;
	obj.now = now;
	obj.salts = salts;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
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
-(void)unserialize:(SerializedData*)stream {
	self.req_msg_id = [stream readLong];
	self.now = [stream readInt];
	//UNS ShortVector (custom class) //TODO
	{
		if(!self.salts)
			self.salts = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			TL_future_salt* obj = [[TL_future_salt alloc] init];
			[obj unserialize:stream];
			[self.salts addObject:obj];
		}
	}
}
@end



@implementation TLFutureSalt
@end

@implementation TL_future_salt
+(TL_future_salt*)createWithValid_since:(int)valid_since valid_until:(int)valid_until salt:(long)salt {
	TL_future_salt* obj = [[TL_future_salt alloc] init];
	obj.valid_since = valid_since;
	obj.valid_until = valid_until;
	obj.salt = salt;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.valid_since];
	[stream writeInt:self.valid_until];
	[stream writeLong:self.salt];
}
-(void)unserialize:(SerializedData*)stream {
	self.valid_since = [stream readInt];
	self.valid_until = [stream readInt];
	self.salt = [stream readLong];
}
@end



@implementation TLDestroySessionRes
@end

@implementation TL_destroy_session
+(TL_destroy_session*)createWithSession_id:(long)session_id {
	TL_destroy_session* obj = [[TL_destroy_session alloc] init];
	obj.session_id = session_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.session_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.session_id = [stream readLong];
}
@end

@implementation TL_destroy_session_ok
+(TL_destroy_session_ok*)createWithSession_id:(long)session_id {
	TL_destroy_session_ok* obj = [[TL_destroy_session_ok alloc] init];
	obj.session_id = session_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.session_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.session_id = [stream readLong];
}
@end

@implementation TL_destroy_session_none
+(TL_destroy_session_none*)createWithSession_id:(long)session_id {
	TL_destroy_session_none* obj = [[TL_destroy_session_none alloc] init];
	obj.session_id = session_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.session_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.session_id = [stream readLong];
}
@end



@implementation TLProtoMessageCopy
@end

@implementation TL_msg_copy
+(TL_msg_copy*)createWithOrig_message:(TLProtoMessage*)orig_message {
	TL_msg_copy* obj = [[TL_msg_copy alloc] init];
	obj.orig_message = orig_message;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[TLClassStore TLSerialize:self.orig_message stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.orig_message = [TLClassStore TLDeserialize:stream];
}
@end



@implementation TL_gzip_packed
+(TL_gzip_packed*)createWithPacked_data:(NSData*)packed_data {
	TL_gzip_packed* obj = [[TL_gzip_packed alloc] init];
	obj.packed_data = packed_data;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeByteArray:self.packed_data];
}
-(void)unserialize:(SerializedData*)stream {
	self.packed_data = [stream readByteArray];
}
@end



@implementation TLHttpWait
@end

@implementation TL_http_wait
+(TL_http_wait*)createWithMax_delay:(int)max_delay wait_after:(int)wait_after max_wait:(int)max_wait {
	TL_http_wait* obj = [[TL_http_wait alloc] init];
	obj.max_delay = max_delay;
	obj.wait_after = wait_after;
	obj.max_wait = max_wait;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.max_delay];
	[stream writeInt:self.wait_after];
	[stream writeInt:self.max_wait];
}
-(void)unserialize:(SerializedData*)stream {
	self.max_delay = [stream readInt];
	self.wait_after = [stream readInt];
	self.max_wait = [stream readInt];
}
@end



@implementation TLMsgsStateReq
@end

@implementation TL_msgs_state_req
+(TL_msgs_state_req*)createWithMsg_ids:(NSMutableArray*)msg_ids {
	TL_msgs_state_req* obj = [[TL_msgs_state_req alloc] init];
	obj.msg_ids = msg_ids;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
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
-(void)unserialize:(SerializedData*)stream {
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



@implementation TLMsgsStateInfo
@end

@implementation TL_msgs_state_info
+(TL_msgs_state_info*)createWithReq_msg_id:(long)req_msg_id info:(NSData*)info {
	TL_msgs_state_info* obj = [[TL_msgs_state_info alloc] init];
	obj.req_msg_id = req_msg_id;
	obj.info = info;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.req_msg_id];
	[stream writeByteArray:self.info];
}
-(void)unserialize:(SerializedData*)stream {
	self.req_msg_id = [stream readLong];
	self.info = [stream readByteArray];
}
@end



@implementation TLMsgsAllInfo
@end

@implementation TL_msgs_all_info
+(TL_msgs_all_info*)createWithMsg_ids:(NSMutableArray*)msg_ids info:(NSData*)info {
	TL_msgs_all_info* obj = [[TL_msgs_all_info alloc] init];
	obj.msg_ids = msg_ids;
	obj.info = info;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
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
-(void)unserialize:(SerializedData*)stream {
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



@implementation TLMsgDetailedInfo
@end

@implementation TL_msg_detailed_info
+(TL_msg_detailed_info*)createWithMsg_id:(long)msg_id answer_msg_id:(long)answer_msg_id bytes:(int)bytes status:(int)status {
	TL_msg_detailed_info* obj = [[TL_msg_detailed_info alloc] init];
	obj.msg_id = msg_id;
	obj.answer_msg_id = answer_msg_id;
	obj.bytes = bytes;
	obj.status = status;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.msg_id];
	[stream writeLong:self.answer_msg_id];
	[stream writeInt:self.bytes];
	[stream writeInt:self.status];
}
-(void)unserialize:(SerializedData*)stream {
	self.msg_id = [stream readLong];
	self.answer_msg_id = [stream readLong];
	self.bytes = [stream readInt];
	self.status = [stream readInt];
}
@end

@implementation TL_msg_new_detailed_info
+(TL_msg_new_detailed_info*)createWithAnswer_msg_id:(long)answer_msg_id bytes:(int)bytes status:(int)status {
	TL_msg_new_detailed_info* obj = [[TL_msg_new_detailed_info alloc] init];
	obj.answer_msg_id = answer_msg_id;
	obj.bytes = bytes;
	obj.status = status;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.answer_msg_id];
	[stream writeInt:self.bytes];
	[stream writeInt:self.status];
}
-(void)unserialize:(SerializedData*)stream {
	self.answer_msg_id = [stream readLong];
	self.bytes = [stream readInt];
	self.status = [stream readInt];
}
@end



@implementation TLMsgResendReq
@end

@implementation TL_msg_resend_req
+(TL_msg_resend_req*)createWithMsg_ids:(NSMutableArray*)msg_ids {
	TL_msg_resend_req* obj = [[TL_msg_resend_req alloc] init];
	obj.msg_ids = msg_ids;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
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
-(void)unserialize:(SerializedData*)stream {
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

