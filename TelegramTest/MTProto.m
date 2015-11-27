//
//  MTProto.m
//  Telegram
//
//  Auto created by Mikhail Filimonov on 27.11.15.
//  Copyright (c) 2013 Telegram for OS X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTProto.h"
#import "ClassStore.h"

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


@implementation TLTrue

@end
        
@implementation TL_true
+(TL_true*)create {
	TL_true* obj = [[TL_true alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_true *)copy {
    
    TL_true *objc = [[TL_true alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputPeerEmpty *)copy {
    
    TL_inputPeerEmpty *objc = [[TL_inputPeerEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputPeerSelf *)copy {
    
    TL_inputPeerSelf *objc = [[TL_inputPeerSelf alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.chat_id = [stream readInt];
}
        
-(TL_inputPeerChat *)copy {
    
    TL_inputPeerChat *objc = [[TL_inputPeerChat alloc] init];
    
    objc.chat_id = self.chat_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputPeerUser
+(TL_inputPeerUser*)createWithUser_id:(int)user_id access_hash:(long)access_hash {
	TL_inputPeerUser* obj = [[TL_inputPeerUser alloc] init];
	obj.user_id = user_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	super.user_id = [stream readInt];
	super.access_hash = [stream readLong];
}
        
-(TL_inputPeerUser *)copy {
    
    TL_inputPeerUser *objc = [[TL_inputPeerUser alloc] init];
    
    objc.user_id = self.user_id;
    objc.access_hash = self.access_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputPeerChannel
+(TL_inputPeerChannel*)createWithChannel_id:(int)channel_id access_hash:(long)access_hash {
	TL_inputPeerChannel* obj = [[TL_inputPeerChannel alloc] init];
	obj.channel_id = channel_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.channel_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	super.channel_id = [stream readInt];
	super.access_hash = [stream readLong];
}
        
-(TL_inputPeerChannel *)copy {
    
    TL_inputPeerChannel *objc = [[TL_inputPeerChannel alloc] init];
    
    objc.channel_id = self.channel_id;
    objc.access_hash = self.access_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputUserEmpty *)copy {
    
    TL_inputUserEmpty *objc = [[TL_inputUserEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputUserSelf *)copy {
    
    TL_inputUserSelf *objc = [[TL_inputUserSelf alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputUser
+(TL_inputUser*)createWithUser_id:(int)user_id access_hash:(long)access_hash {
	TL_inputUser* obj = [[TL_inputUser alloc] init];
	obj.user_id = user_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	super.user_id = [stream readInt];
	super.access_hash = [stream readLong];
}
        
-(TL_inputUser *)copy {
    
    TL_inputUser *objc = [[TL_inputUser alloc] init];
    
    objc.user_id = self.user_id;
    objc.access_hash = self.access_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.client_id = [stream readLong];
	super.phone = [stream readString];
	super.first_name = [stream readString];
	super.last_name = [stream readString];
}
        
-(TL_inputPhoneContact *)copy {
    
    TL_inputPhoneContact *objc = [[TL_inputPhoneContact alloc] init];
    
    objc.client_id = self.client_id;
    objc.phone = self.phone;
    objc.first_name = self.first_name;
    objc.last_name = self.last_name;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
	super.parts = [stream readInt];
	super.name = [stream readString];
	super.md5_checksum = [stream readString];
}
        
-(TL_inputFile *)copy {
    
    TL_inputFile *objc = [[TL_inputFile alloc] init];
    
    objc.n_id = self.n_id;
    objc.parts = self.parts;
    objc.name = self.name;
    objc.md5_checksum = self.md5_checksum;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
	super.parts = [stream readInt];
	super.name = [stream readString];
}
        
-(TL_inputFileBig *)copy {
    
    TL_inputFileBig *objc = [[TL_inputFileBig alloc] init];
    
    objc.n_id = self.n_id;
    objc.parts = self.parts;
    objc.name = self.name;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputMediaEmpty *)copy {
    
    TL_inputMediaEmpty *objc = [[TL_inputMediaEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputMediaUploadedPhoto
+(TL_inputMediaUploadedPhoto*)createWithFile:(TLInputFile*)file caption:(NSString*)caption {
	TL_inputMediaUploadedPhoto* obj = [[TL_inputMediaUploadedPhoto alloc] init];
	obj.file = file;
	obj.caption = caption;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.file stream:stream];
	[stream writeString:self.caption];
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [ClassStore TLDeserialize:stream];
	super.caption = [stream readString];
}
        
-(TL_inputMediaUploadedPhoto *)copy {
    
    TL_inputMediaUploadedPhoto *objc = [[TL_inputMediaUploadedPhoto alloc] init];
    
    objc.file = [self.file copy];
    objc.caption = self.caption;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputMediaPhoto
+(TL_inputMediaPhoto*)createWithN_id:(TLInputPhoto*)n_id caption:(NSString*)caption {
	TL_inputMediaPhoto* obj = [[TL_inputMediaPhoto alloc] init];
	obj.n_id = n_id;
	obj.caption = caption;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.n_id stream:stream];
	[stream writeString:self.caption];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [ClassStore TLDeserialize:stream];
	super.caption = [stream readString];
}
        
-(TL_inputMediaPhoto *)copy {
    
    TL_inputMediaPhoto *objc = [[TL_inputMediaPhoto alloc] init];
    
    objc.n_id = [self.n_id copy];
    objc.caption = self.caption;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputMediaGeoPoint
+(TL_inputMediaGeoPoint*)createWithGeo_point:(TLInputGeoPoint*)geo_point {
	TL_inputMediaGeoPoint* obj = [[TL_inputMediaGeoPoint alloc] init];
	obj.geo_point = geo_point;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.geo_point stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.geo_point = [ClassStore TLDeserialize:stream];
}
        
-(TL_inputMediaGeoPoint *)copy {
    
    TL_inputMediaGeoPoint *objc = [[TL_inputMediaGeoPoint alloc] init];
    
    objc.geo_point = [self.geo_point copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.phone_number = [stream readString];
	super.first_name = [stream readString];
	super.last_name = [stream readString];
}
        
-(TL_inputMediaContact *)copy {
    
    TL_inputMediaContact *objc = [[TL_inputMediaContact alloc] init];
    
    objc.phone_number = self.phone_number;
    objc.first_name = self.first_name;
    objc.last_name = self.last_name;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputMediaUploadedVideo
+(TL_inputMediaUploadedVideo*)createWithFile:(TLInputFile*)file duration:(int)duration w:(int)w h:(int)h mime_type:(NSString*)mime_type caption:(NSString*)caption {
	TL_inputMediaUploadedVideo* obj = [[TL_inputMediaUploadedVideo alloc] init];
	obj.file = file;
	obj.duration = duration;
	obj.w = w;
	obj.h = h;
	obj.mime_type = mime_type;
	obj.caption = caption;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.file stream:stream];
	[stream writeInt:self.duration];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeString:self.mime_type];
	[stream writeString:self.caption];
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [ClassStore TLDeserialize:stream];
	super.duration = [stream readInt];
	super.w = [stream readInt];
	super.h = [stream readInt];
	super.mime_type = [stream readString];
	super.caption = [stream readString];
}
        
-(TL_inputMediaUploadedVideo *)copy {
    
    TL_inputMediaUploadedVideo *objc = [[TL_inputMediaUploadedVideo alloc] init];
    
    objc.file = [self.file copy];
    objc.duration = self.duration;
    objc.w = self.w;
    objc.h = self.h;
    objc.mime_type = self.mime_type;
    objc.caption = self.caption;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputMediaUploadedThumbVideo
+(TL_inputMediaUploadedThumbVideo*)createWithFile:(TLInputFile*)file thumb:(TLInputFile*)thumb duration:(int)duration w:(int)w h:(int)h mime_type:(NSString*)mime_type caption:(NSString*)caption {
	TL_inputMediaUploadedThumbVideo* obj = [[TL_inputMediaUploadedThumbVideo alloc] init];
	obj.file = file;
	obj.thumb = thumb;
	obj.duration = duration;
	obj.w = w;
	obj.h = h;
	obj.mime_type = mime_type;
	obj.caption = caption;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.file stream:stream];
	[ClassStore TLSerialize:self.thumb stream:stream];
	[stream writeInt:self.duration];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeString:self.mime_type];
	[stream writeString:self.caption];
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [ClassStore TLDeserialize:stream];
	self.thumb = [ClassStore TLDeserialize:stream];
	super.duration = [stream readInt];
	super.w = [stream readInt];
	super.h = [stream readInt];
	super.mime_type = [stream readString];
	super.caption = [stream readString];
}
        
-(TL_inputMediaUploadedThumbVideo *)copy {
    
    TL_inputMediaUploadedThumbVideo *objc = [[TL_inputMediaUploadedThumbVideo alloc] init];
    
    objc.file = [self.file copy];
    objc.thumb = [self.thumb copy];
    objc.duration = self.duration;
    objc.w = self.w;
    objc.h = self.h;
    objc.mime_type = self.mime_type;
    objc.caption = self.caption;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputMediaVideo
+(TL_inputMediaVideo*)createWithN_id:(TLInputVideo*)n_id caption:(NSString*)caption {
	TL_inputMediaVideo* obj = [[TL_inputMediaVideo alloc] init];
	obj.n_id = n_id;
	obj.caption = caption;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.n_id stream:stream];
	[stream writeString:self.caption];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [ClassStore TLDeserialize:stream];
	super.caption = [stream readString];
}
        
-(TL_inputMediaVideo *)copy {
    
    TL_inputMediaVideo *objc = [[TL_inputMediaVideo alloc] init];
    
    objc.n_id = [self.n_id copy];
    objc.caption = self.caption;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.file stream:stream];
	[stream writeInt:self.duration];
	[stream writeString:self.mime_type];
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [ClassStore TLDeserialize:stream];
	super.duration = [stream readInt];
	super.mime_type = [stream readString];
}
        
-(TL_inputMediaUploadedAudio *)copy {
    
    TL_inputMediaUploadedAudio *objc = [[TL_inputMediaUploadedAudio alloc] init];
    
    objc.file = [self.file copy];
    objc.duration = self.duration;
    objc.mime_type = self.mime_type;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputMediaAudio
+(TL_inputMediaAudio*)createWithN_id:(TLInputAudio*)n_id {
	TL_inputMediaAudio* obj = [[TL_inputMediaAudio alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.n_id stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [ClassStore TLDeserialize:stream];
}
        
-(TL_inputMediaAudio *)copy {
    
    TL_inputMediaAudio *objc = [[TL_inputMediaAudio alloc] init];
    
    objc.n_id = [self.n_id copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.file stream:stream];
	[stream writeString:self.mime_type];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.attributes count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLDocumentAttribute* obj = [self.attributes objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [ClassStore TLDeserialize:stream];
	super.mime_type = [stream readString];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.attributes)
			self.attributes = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLDocumentAttribute* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLDocumentAttribute class]])
                 [self.attributes addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_inputMediaUploadedDocument *)copy {
    
    TL_inputMediaUploadedDocument *objc = [[TL_inputMediaUploadedDocument alloc] init];
    
    objc.file = [self.file copy];
    objc.mime_type = self.mime_type;
    objc.attributes = [self.attributes copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.file stream:stream];
	[ClassStore TLSerialize:self.thumb stream:stream];
	[stream writeString:self.mime_type];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.attributes count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLDocumentAttribute* obj = [self.attributes objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [ClassStore TLDeserialize:stream];
	self.thumb = [ClassStore TLDeserialize:stream];
	super.mime_type = [stream readString];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.attributes)
			self.attributes = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLDocumentAttribute* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLDocumentAttribute class]])
                 [self.attributes addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_inputMediaUploadedThumbDocument *)copy {
    
    TL_inputMediaUploadedThumbDocument *objc = [[TL_inputMediaUploadedThumbDocument alloc] init];
    
    objc.file = [self.file copy];
    objc.thumb = [self.thumb copy];
    objc.mime_type = self.mime_type;
    objc.attributes = [self.attributes copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputMediaDocument
+(TL_inputMediaDocument*)createWithN_id:(TLInputDocument*)n_id {
	TL_inputMediaDocument* obj = [[TL_inputMediaDocument alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.n_id stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [ClassStore TLDeserialize:stream];
}
        
-(TL_inputMediaDocument *)copy {
    
    TL_inputMediaDocument *objc = [[TL_inputMediaDocument alloc] init];
    
    objc.n_id = [self.n_id copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputMediaVenue
+(TL_inputMediaVenue*)createWithGeo_point:(TLInputGeoPoint*)geo_point title:(NSString*)title address:(NSString*)address provider:(NSString*)provider venue_id:(NSString*)venue_id {
	TL_inputMediaVenue* obj = [[TL_inputMediaVenue alloc] init];
	obj.geo_point = geo_point;
	obj.title = title;
	obj.address = address;
	obj.provider = provider;
	obj.venue_id = venue_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.geo_point stream:stream];
	[stream writeString:self.title];
	[stream writeString:self.address];
	[stream writeString:self.provider];
	[stream writeString:self.venue_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.geo_point = [ClassStore TLDeserialize:stream];
	super.title = [stream readString];
	super.address = [stream readString];
	super.provider = [stream readString];
	super.venue_id = [stream readString];
}
        
-(TL_inputMediaVenue *)copy {
    
    TL_inputMediaVenue *objc = [[TL_inputMediaVenue alloc] init];
    
    objc.geo_point = [self.geo_point copy];
    objc.title = self.title;
    objc.address = self.address;
    objc.provider = self.provider;
    objc.venue_id = self.venue_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputMediaUploadedVideo_old34
+(TL_inputMediaUploadedVideo_old34*)createWithFile:(TLInputFile*)file duration:(int)duration w:(int)w h:(int)h caption:(NSString*)caption {
	TL_inputMediaUploadedVideo_old34* obj = [[TL_inputMediaUploadedVideo_old34 alloc] init];
	obj.file = file;
	obj.duration = duration;
	obj.w = w;
	obj.h = h;
	obj.caption = caption;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.file stream:stream];
	[stream writeInt:self.duration];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeString:self.caption];
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [ClassStore TLDeserialize:stream];
	super.duration = [stream readInt];
	super.w = [stream readInt];
	super.h = [stream readInt];
	super.caption = [stream readString];
}
        
-(TL_inputMediaUploadedVideo_old34 *)copy {
    
    TL_inputMediaUploadedVideo_old34 *objc = [[TL_inputMediaUploadedVideo_old34 alloc] init];
    
    objc.file = [self.file copy];
    objc.duration = self.duration;
    objc.w = self.w;
    objc.h = self.h;
    objc.caption = self.caption;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputMediaUploadedThumbVideo_old32
+(TL_inputMediaUploadedThumbVideo_old32*)createWithFile:(TLInputFile*)file thumb:(TLInputFile*)thumb duration:(int)duration w:(int)w h:(int)h caption:(NSString*)caption {
	TL_inputMediaUploadedThumbVideo_old32* obj = [[TL_inputMediaUploadedThumbVideo_old32 alloc] init];
	obj.file = file;
	obj.thumb = thumb;
	obj.duration = duration;
	obj.w = w;
	obj.h = h;
	obj.caption = caption;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.file stream:stream];
	[ClassStore TLSerialize:self.thumb stream:stream];
	[stream writeInt:self.duration];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeString:self.caption];
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [ClassStore TLDeserialize:stream];
	self.thumb = [ClassStore TLDeserialize:stream];
	super.duration = [stream readInt];
	super.w = [stream readInt];
	super.h = [stream readInt];
	super.caption = [stream readString];
}
        
-(TL_inputMediaUploadedThumbVideo_old32 *)copy {
    
    TL_inputMediaUploadedThumbVideo_old32 *objc = [[TL_inputMediaUploadedThumbVideo_old32 alloc] init];
    
    objc.file = [self.file copy];
    objc.thumb = [self.thumb copy];
    objc.duration = self.duration;
    objc.w = self.w;
    objc.h = self.h;
    objc.caption = self.caption;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputChatPhotoEmpty *)copy {
    
    TL_inputChatPhotoEmpty *objc = [[TL_inputChatPhotoEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.file stream:stream];
	[ClassStore TLSerialize:self.crop stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.file = [ClassStore TLDeserialize:stream];
	self.crop = [ClassStore TLDeserialize:stream];
}
        
-(TL_inputChatUploadedPhoto *)copy {
    
    TL_inputChatUploadedPhoto *objc = [[TL_inputChatUploadedPhoto alloc] init];
    
    objc.file = [self.file copy];
    objc.crop = [self.crop copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.n_id stream:stream];
	[ClassStore TLSerialize:self.crop stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [ClassStore TLDeserialize:stream];
	self.crop = [ClassStore TLDeserialize:stream];
}
        
-(TL_inputChatPhoto *)copy {
    
    TL_inputChatPhoto *objc = [[TL_inputChatPhoto alloc] init];
    
    objc.n_id = [self.n_id copy];
    objc.crop = [self.crop copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputGeoPointEmpty *)copy {
    
    TL_inputGeoPointEmpty *objc = [[TL_inputGeoPointEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.lat = [stream readDouble];
	super.n_long = [stream readDouble];
}
        
-(TL_inputGeoPoint *)copy {
    
    TL_inputGeoPoint *objc = [[TL_inputGeoPoint alloc] init];
    
    objc.lat = self.lat;
    objc.n_long = self.n_long;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputPhotoEmpty *)copy {
    
    TL_inputPhotoEmpty *objc = [[TL_inputPhotoEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
}
        
-(TL_inputPhoto *)copy {
    
    TL_inputPhoto *objc = [[TL_inputPhoto alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputVideoEmpty *)copy {
    
    TL_inputVideoEmpty *objc = [[TL_inputVideoEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
}
        
-(TL_inputVideo *)copy {
    
    TL_inputVideo *objc = [[TL_inputVideo alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.volume_id = [stream readLong];
	super.local_id = [stream readInt];
	super.secret = [stream readLong];
}
        
-(TL_inputFileLocation *)copy {
    
    TL_inputFileLocation *objc = [[TL_inputFileLocation alloc] init];
    
    objc.volume_id = self.volume_id;
    objc.local_id = self.local_id;
    objc.secret = self.secret;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
}
        
-(TL_inputVideoFileLocation *)copy {
    
    TL_inputVideoFileLocation *objc = [[TL_inputVideoFileLocation alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
}
        
-(TL_inputEncryptedFileLocation *)copy {
    
    TL_inputEncryptedFileLocation *objc = [[TL_inputEncryptedFileLocation alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
}
        
-(TL_inputAudioFileLocation *)copy {
    
    TL_inputAudioFileLocation *objc = [[TL_inputAudioFileLocation alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
}
        
-(TL_inputDocumentFileLocation *)copy {
    
    TL_inputDocumentFileLocation *objc = [[TL_inputDocumentFileLocation alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputPhotoCropAuto *)copy {
    
    TL_inputPhotoCropAuto *objc = [[TL_inputPhotoCropAuto alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.crop_left = [stream readDouble];
	super.crop_top = [stream readDouble];
	super.crop_width = [stream readDouble];
}
        
-(TL_inputPhotoCrop *)copy {
    
    TL_inputPhotoCrop *objc = [[TL_inputPhotoCrop alloc] init];
    
    objc.crop_left = self.crop_left;
    objc.crop_top = self.crop_top;
    objc.crop_width = self.crop_width;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.time = [stream readDouble];
	super.type = [stream readString];
	super.peer = [stream readLong];
	super.data = [stream readString];
}
        
-(TL_inputAppEvent *)copy {
    
    TL_inputAppEvent *objc = [[TL_inputAppEvent alloc] init];
    
    objc.time = self.time;
    objc.type = self.type;
    objc.peer = self.peer;
    objc.data = self.data;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.user_id = [stream readInt];
}
        
-(TL_peerUser *)copy {
    
    TL_peerUser *objc = [[TL_peerUser alloc] init];
    
    objc.user_id = self.user_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.chat_id = [stream readInt];
}
        
-(TL_peerChat *)copy {
    
    TL_peerChat *objc = [[TL_peerChat alloc] init];
    
    objc.chat_id = self.chat_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_peerChannel
+(TL_peerChannel*)createWithChannel_id:(int)channel_id {
	TL_peerChannel* obj = [[TL_peerChannel alloc] init];
	obj.channel_id = channel_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.channel_id];
}
-(void)unserialize:(SerializedData*)stream {
	super.channel_id = [stream readInt];
}
        
-(TL_peerChannel *)copy {
    
    TL_peerChannel *objc = [[TL_peerChannel alloc] init];
    
    objc.channel_id = self.channel_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_storage_fileUnknown *)copy {
    
    TL_storage_fileUnknown *objc = [[TL_storage_fileUnknown alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_storage_fileJpeg *)copy {
    
    TL_storage_fileJpeg *objc = [[TL_storage_fileJpeg alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_storage_fileGif *)copy {
    
    TL_storage_fileGif *objc = [[TL_storage_fileGif alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_storage_filePng *)copy {
    
    TL_storage_filePng *objc = [[TL_storage_filePng alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_storage_filePdf *)copy {
    
    TL_storage_filePdf *objc = [[TL_storage_filePdf alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_storage_fileMp3 *)copy {
    
    TL_storage_fileMp3 *objc = [[TL_storage_fileMp3 alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_storage_fileMov *)copy {
    
    TL_storage_fileMov *objc = [[TL_storage_fileMov alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_storage_filePartial *)copy {
    
    TL_storage_filePartial *objc = [[TL_storage_filePartial alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_storage_fileMp4 *)copy {
    
    TL_storage_fileMp4 *objc = [[TL_storage_fileMp4 alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_storage_fileWebp *)copy {
    
    TL_storage_fileWebp *objc = [[TL_storage_fileWebp alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.volume_id = [stream readLong];
	super.local_id = [stream readInt];
	super.secret = [stream readLong];
}
        
-(TL_fileLocationUnavailable *)copy {
    
    TL_fileLocationUnavailable *objc = [[TL_fileLocationUnavailable alloc] init];
    
    objc.volume_id = self.volume_id;
    objc.local_id = self.local_id;
    objc.secret = self.secret;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.dc_id = [stream readInt];
	super.volume_id = [stream readLong];
	super.local_id = [stream readInt];
	super.secret = [stream readLong];
}
        
-(TL_fileLocation *)copy {
    
    TL_fileLocation *objc = [[TL_fileLocation alloc] init];
    
    objc.dc_id = self.dc_id;
    objc.volume_id = self.volume_id;
    objc.local_id = self.local_id;
    objc.secret = self.secret;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLUser
            
-(BOOL)isSelf {return NO;}
                        
-(BOOL)isContact {return NO;}
                        
-(BOOL)isMutual_contact {return NO;}
                        
-(BOOL)isDeleted {return NO;}
                        
-(BOOL)isBot {return NO;}
                        
-(BOOL)isBot_chat_history {return NO;}
                        
-(BOOL)isBot_nochats {return NO;}
                        
-(BOOL)isVerified {return NO;}
            
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
	super.n_id = [stream readInt];
}
        
-(TL_userEmpty *)copy {
    
    TL_userEmpty *objc = [[TL_userEmpty alloc] init];
    
    objc.n_id = self.n_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_user
+(TL_user*)createWithFlags:(int)flags         n_id:(int)n_id access_hash:(long)access_hash first_name:(NSString*)first_name last_name:(NSString*)last_name username:(NSString*)username phone:(NSString*)phone photo:(TLUserProfilePhoto*)photo status:(TLUserStatus*)status bot_info_version:(int)bot_info_version {
	TL_user* obj = [[TL_user alloc] init];
	obj.flags = flags;
	
	
	
	
	
	
	
	
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.first_name = first_name;
	obj.last_name = last_name;
	obj.username = username;
	obj.phone = phone;
	obj.photo = photo;
	obj.status = status;
	obj.bot_info_version = bot_info_version;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	
	
	
	
	
	
	
	[stream writeInt:self.n_id];
	if(self.flags & (1 << 0)) {[stream writeLong:self.access_hash];}
	if(self.flags & (1 << 1)) {[stream writeString:self.first_name];}
	if(self.flags & (1 << 2)) {[stream writeString:self.last_name];}
	if(self.flags & (1 << 3)) {[stream writeString:self.username];}
	if(self.flags & (1 << 4)) {[stream writeString:self.phone];}
	if(self.flags & (1 << 5)) {[ClassStore TLSerialize:self.photo stream:stream];}
	if(self.flags & (1 << 6)) {[ClassStore TLSerialize:self.status stream:stream];}
	if(self.flags & (1 << 14)) {[stream writeInt:self.bot_info_version];}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	
	
	
	
	
	
	
	super.n_id = [stream readInt];
	if(self.flags & (1 << 0)) {super.access_hash = [stream readLong];}
	if(self.flags & (1 << 1)) {super.first_name = [stream readString];}
	if(self.flags & (1 << 2)) {super.last_name = [stream readString];}
	if(self.flags & (1 << 3)) {super.username = [stream readString];}
	if(self.flags & (1 << 4)) {super.phone = [stream readString];}
	if(self.flags & (1 << 5)) {self.photo = [ClassStore TLDeserialize:stream];}
	if(self.flags & (1 << 6)) {self.status = [ClassStore TLDeserialize:stream];}
	if(self.flags & (1 << 14)) {super.bot_info_version = [stream readInt];}
}
        
-(TL_user *)copy {
    
    TL_user *objc = [[TL_user alloc] init];
    
    objc.flags = self.flags;
    
    
    
    
    
    
    
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    objc.first_name = self.first_name;
    objc.last_name = self.last_name;
    objc.username = self.username;
    objc.phone = self.phone;
    objc.photo = [self.photo copy];
    objc.status = [self.status copy];
    objc.bot_info_version = self.bot_info_version;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isSelf {return (self.flags & (1 << 10)) > 0;}
                        
-(BOOL)isContact {return (self.flags & (1 << 11)) > 0;}
                        
-(BOOL)isMutual_contact {return (self.flags & (1 << 12)) > 0;}
                        
-(BOOL)isDeleted {return (self.flags & (1 << 13)) > 0;}
                        
-(BOOL)isBot {return (self.flags & (1 << 14)) > 0;}
                        
-(BOOL)isBot_chat_history {return (self.flags & (1 << 15)) > 0;}
                        
-(BOOL)isBot_nochats {return (self.flags & (1 << 16)) > 0;}
                        
-(BOOL)isVerified {return (self.flags & (1 << 17)) > 0;}
                        
-(void)setAccess_hash:(long)access_hash
{
   super.access_hash = access_hash;
                
    if(super.access_hash == 0)  { super.flags&= ~ (1 << 0) ;} else { super.flags|= (1 << 0); }
}            
-(void)setFirst_name:(NSString*)first_name
{
   super.first_name = first_name;
                
    if(super.first_name == nil)  { super.flags&= ~ (1 << 1) ;} else { super.flags|= (1 << 1); }
}            
-(void)setLast_name:(NSString*)last_name
{
   super.last_name = last_name;
                
    if(super.last_name == nil)  { super.flags&= ~ (1 << 2) ;} else { super.flags|= (1 << 2); }
}            
-(void)setUsername:(NSString*)username
{
   super.username = username;
                
    if(super.username == nil)  { super.flags&= ~ (1 << 3) ;} else { super.flags|= (1 << 3); }
}            
-(void)setPhone:(NSString*)phone
{
   super.phone = phone;
                
    if(super.phone == nil)  { super.flags&= ~ (1 << 4) ;} else { super.flags|= (1 << 4); }
}            
-(void)setPhoto:(TLUserProfilePhoto*)photo
{
   super.photo = photo;
                
    if(super.photo == nil)  { super.flags&= ~ (1 << 5) ;} else { super.flags|= (1 << 5); }
}            
-(void)setStatus:(TLUserStatus*)status
{
   super.status = status;
                
    if(super.status == nil)  { super.flags&= ~ (1 << 6) ;} else { super.flags|= (1 << 6); }
}            
-(void)setBot_info_version:(int)bot_info_version
{
   super.bot_info_version = bot_info_version;
                
    if(super.bot_info_version == 0)  { super.flags&= ~ (1 << 14) ;} else { super.flags|= (1 << 14); }
}
        
@end

@implementation TL_userSelf
+(TL_userSelf*)createWithN_id:(int)n_id first_name:(NSString*)first_name last_name:(NSString*)last_name username:(NSString*)username phone:(NSString*)phone photo:(TLUserProfilePhoto*)photo status:(TLUserStatus*)status {
	TL_userSelf* obj = [[TL_userSelf alloc] init];
	obj.n_id = n_id;
	obj.first_name = first_name;
	obj.last_name = last_name;
	obj.username = username;
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
	[stream writeString:self.phone];
	[ClassStore TLSerialize:self.photo stream:stream];
	[ClassStore TLSerialize:self.status stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readInt];
	super.first_name = [stream readString];
	super.last_name = [stream readString];
	super.username = [stream readString];
	super.phone = [stream readString];
	self.photo = [ClassStore TLDeserialize:stream];
	self.status = [ClassStore TLDeserialize:stream];
}
        
-(TL_userSelf *)copy {
    
    TL_userSelf *objc = [[TL_userSelf alloc] init];
    
    objc.n_id = self.n_id;
    objc.first_name = self.first_name;
    objc.last_name = self.last_name;
    objc.username = self.username;
    objc.phone = self.phone;
    objc.photo = [self.photo copy];
    objc.status = [self.status copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.photo stream:stream];
	[ClassStore TLSerialize:self.status stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readInt];
	super.first_name = [stream readString];
	super.last_name = [stream readString];
	super.username = [stream readString];
	super.access_hash = [stream readLong];
	super.phone = [stream readString];
	self.photo = [ClassStore TLDeserialize:stream];
	self.status = [ClassStore TLDeserialize:stream];
}
        
-(TL_userContact *)copy {
    
    TL_userContact *objc = [[TL_userContact alloc] init];
    
    objc.n_id = self.n_id;
    objc.first_name = self.first_name;
    objc.last_name = self.last_name;
    objc.username = self.username;
    objc.access_hash = self.access_hash;
    objc.phone = self.phone;
    objc.photo = [self.photo copy];
    objc.status = [self.status copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.photo stream:stream];
	[ClassStore TLSerialize:self.status stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readInt];
	super.first_name = [stream readString];
	super.last_name = [stream readString];
	super.username = [stream readString];
	super.access_hash = [stream readLong];
	super.phone = [stream readString];
	self.photo = [ClassStore TLDeserialize:stream];
	self.status = [ClassStore TLDeserialize:stream];
}
        
-(TL_userRequest *)copy {
    
    TL_userRequest *objc = [[TL_userRequest alloc] init];
    
    objc.n_id = self.n_id;
    objc.first_name = self.first_name;
    objc.last_name = self.last_name;
    objc.username = self.username;
    objc.access_hash = self.access_hash;
    objc.phone = self.phone;
    objc.photo = [self.photo copy];
    objc.status = [self.status copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.photo stream:stream];
	[ClassStore TLSerialize:self.status stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readInt];
	super.first_name = [stream readString];
	super.last_name = [stream readString];
	super.username = [stream readString];
	super.access_hash = [stream readLong];
	self.photo = [ClassStore TLDeserialize:stream];
	self.status = [ClassStore TLDeserialize:stream];
}
        
-(TL_userForeign *)copy {
    
    TL_userForeign *objc = [[TL_userForeign alloc] init];
    
    objc.n_id = self.n_id;
    objc.first_name = self.first_name;
    objc.last_name = self.last_name;
    objc.username = self.username;
    objc.access_hash = self.access_hash;
    objc.photo = [self.photo copy];
    objc.status = [self.status copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readInt];
	super.first_name = [stream readString];
	super.last_name = [stream readString];
	super.username = [stream readString];
}
        
-(TL_userDeleted *)copy {
    
    TL_userDeleted *objc = [[TL_userDeleted alloc] init];
    
    objc.n_id = self.n_id;
    objc.first_name = self.first_name;
    objc.last_name = self.last_name;
    objc.username = self.username;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_userProfilePhotoEmpty *)copy {
    
    TL_userProfilePhotoEmpty *objc = [[TL_userProfilePhotoEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.photo_small stream:stream];
	[ClassStore TLSerialize:self.photo_big stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.photo_id = [stream readLong];
	self.photo_small = [ClassStore TLDeserialize:stream];
	self.photo_big = [ClassStore TLDeserialize:stream];
}
        
-(TL_userProfilePhoto *)copy {
    
    TL_userProfilePhoto *objc = [[TL_userProfilePhoto alloc] init];
    
    objc.photo_id = self.photo_id;
    objc.photo_small = [self.photo_small copy];
    objc.photo_big = [self.photo_big copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_userStatusEmpty *)copy {
    
    TL_userStatusEmpty *objc = [[TL_userStatusEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.expires = [stream readInt];
}
        
-(TL_userStatusOnline *)copy {
    
    TL_userStatusOnline *objc = [[TL_userStatusOnline alloc] init];
    
    objc.expires = self.expires;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.was_online = [stream readInt];
}
        
-(TL_userStatusOffline *)copy {
    
    TL_userStatusOffline *objc = [[TL_userStatusOffline alloc] init];
    
    objc.was_online = self.was_online;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_userStatusRecently *)copy {
    
    TL_userStatusRecently *objc = [[TL_userStatusRecently alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_userStatusLastWeek *)copy {
    
    TL_userStatusLastWeek *objc = [[TL_userStatusLastWeek alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_userStatusLastMonth *)copy {
    
    TL_userStatusLastMonth *objc = [[TL_userStatusLastMonth alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLChat
            
-(BOOL)isCreator {return NO;}
                        
-(BOOL)isKicked {return NO;}
                        
-(BOOL)isLeft {return NO;}
                        
-(BOOL)isAdmins_enabled {return NO;}
                        
-(BOOL)isAdmin {return NO;}
                        
-(BOOL)isDeactivated {return NO;}
                        
-(BOOL)isEditor {return NO;}
                        
-(BOOL)isModerator {return NO;}
                        
-(BOOL)isBroadcast {return NO;}
                        
-(BOOL)isVerified {return NO;}
                        
-(BOOL)isMegagroup {return NO;}
            
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
	super.n_id = [stream readInt];
}
        
-(TL_chatEmpty *)copy {
    
    TL_chatEmpty *objc = [[TL_chatEmpty alloc] init];
    
    objc.n_id = self.n_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_chat
+(TL_chat*)createWithFlags:(int)flags       n_id:(int)n_id title:(NSString*)title photo:(TLChatPhoto*)photo participants_count:(int)participants_count date:(int)date version:(int)version migrated_to:(TLInputChannel*)migrated_to {
	TL_chat* obj = [[TL_chat alloc] init];
	obj.flags = flags;
	
	
	
	
	
	
	obj.n_id = n_id;
	obj.title = title;
	obj.photo = photo;
	obj.participants_count = participants_count;
	obj.date = date;
	obj.version = version;
	obj.migrated_to = migrated_to;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	
	
	
	
	
	[stream writeInt:self.n_id];
	[stream writeString:self.title];
	[ClassStore TLSerialize:self.photo stream:stream];
	[stream writeInt:self.participants_count];
	[stream writeInt:self.date];
	[stream writeInt:self.version];
	if(self.flags & (1 << 6)) {[ClassStore TLSerialize:self.migrated_to stream:stream];}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	
	
	
	
	
	super.n_id = [stream readInt];
	super.title = [stream readString];
	self.photo = [ClassStore TLDeserialize:stream];
	super.participants_count = [stream readInt];
	super.date = [stream readInt];
	super.version = [stream readInt];
	if(self.flags & (1 << 6)) {self.migrated_to = [ClassStore TLDeserialize:stream];}
}
        
-(TL_chat *)copy {
    
    TL_chat *objc = [[TL_chat alloc] init];
    
    objc.flags = self.flags;
    
    
    
    
    
    
    objc.n_id = self.n_id;
    objc.title = self.title;
    objc.photo = [self.photo copy];
    objc.participants_count = self.participants_count;
    objc.date = self.date;
    objc.version = self.version;
    objc.migrated_to = [self.migrated_to copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isCreator {return (self.flags & (1 << 0)) > 0;}
                        
-(BOOL)isKicked {return (self.flags & (1 << 1)) > 0;}
                        
-(BOOL)isLeft {return (self.flags & (1 << 2)) > 0;}
                        
-(BOOL)isAdmins_enabled {return (self.flags & (1 << 3)) > 0;}
                        
-(BOOL)isAdmin {return (self.flags & (1 << 4)) > 0;}
                        
-(BOOL)isDeactivated {return (self.flags & (1 << 5)) > 0;}
                        
-(void)setMigrated_to:(TLInputChannel*)migrated_to
{
   super.migrated_to = migrated_to;
                
    if(super.migrated_to == nil)  { super.flags&= ~ (1 << 6) ;} else { super.flags|= (1 << 6); }
}
        
@end

@implementation TL_chatForbidden
+(TL_chatForbidden*)createWithN_id:(int)n_id title:(NSString*)title {
	TL_chatForbidden* obj = [[TL_chatForbidden alloc] init];
	obj.n_id = n_id;
	obj.title = title;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeString:self.title];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readInt];
	super.title = [stream readString];
}
        
-(TL_chatForbidden *)copy {
    
    TL_chatForbidden *objc = [[TL_chatForbidden alloc] init];
    
    objc.n_id = self.n_id;
    objc.title = self.title;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_channel
+(TL_channel*)createWithFlags:(int)flags         n_id:(int)n_id access_hash:(long)access_hash title:(NSString*)title username:(NSString*)username photo:(TLChatPhoto*)photo date:(int)date version:(int)version {
	TL_channel* obj = [[TL_channel alloc] init];
	obj.flags = flags;
	
	
	
	
	
	
	
	
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.title = title;
	obj.username = username;
	obj.photo = photo;
	obj.date = date;
	obj.version = version;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	
	
	
	
	
	
	
	[stream writeInt:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeString:self.title];
	if(self.flags & (1 << 6)) {[stream writeString:self.username];}
	[ClassStore TLSerialize:self.photo stream:stream];
	[stream writeInt:self.date];
	[stream writeInt:self.version];
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	
	
	
	
	
	
	
	super.n_id = [stream readInt];
	super.access_hash = [stream readLong];
	super.title = [stream readString];
	if(self.flags & (1 << 6)) {super.username = [stream readString];}
	self.photo = [ClassStore TLDeserialize:stream];
	super.date = [stream readInt];
	super.version = [stream readInt];
}
        
-(TL_channel *)copy {
    
    TL_channel *objc = [[TL_channel alloc] init];
    
    objc.flags = self.flags;
    
    
    
    
    
    
    
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    objc.title = self.title;
    objc.username = self.username;
    objc.photo = [self.photo copy];
    objc.date = self.date;
    objc.version = self.version;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isCreator {return (self.flags & (1 << 0)) > 0;}
                        
-(BOOL)isKicked {return (self.flags & (1 << 1)) > 0;}
                        
-(BOOL)isLeft {return (self.flags & (1 << 2)) > 0;}
                        
-(BOOL)isEditor {return (self.flags & (1 << 3)) > 0;}
                        
-(BOOL)isModerator {return (self.flags & (1 << 4)) > 0;}
                        
-(BOOL)isBroadcast {return (self.flags & (1 << 5)) > 0;}
                        
-(BOOL)isVerified {return (self.flags & (1 << 7)) > 0;}
                        
-(BOOL)isMegagroup {return (self.flags & (1 << 8)) > 0;}
                        
-(void)setUsername:(NSString*)username
{
   super.username = username;
                
    if(super.username == nil)  { super.flags&= ~ (1 << 6) ;} else { super.flags|= (1 << 6); }
}
        
@end

@implementation TL_channelForbidden
+(TL_channelForbidden*)createWithN_id:(int)n_id access_hash:(long)access_hash title:(NSString*)title {
	TL_channelForbidden* obj = [[TL_channelForbidden alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.title = title;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeString:self.title];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readInt];
	super.access_hash = [stream readLong];
	super.title = [stream readString];
}
        
-(TL_channelForbidden *)copy {
    
    TL_channelForbidden *objc = [[TL_channelForbidden alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    objc.title = self.title;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_chat_old34
+(TL_chat_old34*)createWithN_id:(int)n_id title:(NSString*)title photo:(TLChatPhoto*)photo participants_count:(int)participants_count date:(int)date left:(Boolean)left version:(int)version {
	TL_chat_old34* obj = [[TL_chat_old34 alloc] init];
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
	[ClassStore TLSerialize:self.photo stream:stream];
	[stream writeInt:self.participants_count];
	[stream writeInt:self.date];
	[stream writeBool:self.left];
	[stream writeInt:self.version];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readInt];
	super.title = [stream readString];
	self.photo = [ClassStore TLDeserialize:stream];
	super.participants_count = [stream readInt];
	super.date = [stream readInt];
	super.left = [stream readBool];
	super.version = [stream readInt];
}
        
-(TL_chat_old34 *)copy {
    
    TL_chat_old34 *objc = [[TL_chat_old34 alloc] init];
    
    objc.n_id = self.n_id;
    objc.title = self.title;
    objc.photo = [self.photo copy];
    objc.participants_count = self.participants_count;
    objc.date = self.date;
    objc.left = self.left;
    objc.version = self.version;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_chatForbidden_old34
+(TL_chatForbidden_old34*)createWithN_id:(int)n_id title:(NSString*)title date:(int)date {
	TL_chatForbidden_old34* obj = [[TL_chatForbidden_old34 alloc] init];
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
	super.n_id = [stream readInt];
	super.title = [stream readString];
	super.date = [stream readInt];
}
        
-(TL_chatForbidden_old34 *)copy {
    
    TL_chatForbidden_old34 *objc = [[TL_chatForbidden_old34 alloc] init];
    
    objc.n_id = self.n_id;
    objc.title = self.title;
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_chat_old38
+(TL_chat_old38*)createWithFlags:(int)flags n_id:(int)n_id title:(NSString*)title photo:(TLChatPhoto*)photo participants_count:(int)participants_count date:(int)date version:(int)version {
	TL_chat_old38* obj = [[TL_chat_old38 alloc] init];
	obj.flags = flags;
	obj.n_id = n_id;
	obj.title = title;
	obj.photo = photo;
	obj.participants_count = participants_count;
	obj.date = date;
	obj.version = version;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	[stream writeInt:self.n_id];
	[stream writeString:self.title];
	[ClassStore TLSerialize:self.photo stream:stream];
	[stream writeInt:self.participants_count];
	[stream writeInt:self.date];
	[stream writeInt:self.version];
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	super.n_id = [stream readInt];
	super.title = [stream readString];
	self.photo = [ClassStore TLDeserialize:stream];
	super.participants_count = [stream readInt];
	super.date = [stream readInt];
	super.version = [stream readInt];
}
        
-(TL_chat_old38 *)copy {
    
    TL_chat_old38 *objc = [[TL_chat_old38 alloc] init];
    
    objc.flags = self.flags;
    objc.n_id = self.n_id;
    objc.title = self.title;
    objc.photo = [self.photo copy];
    objc.participants_count = self.participants_count;
    objc.date = self.date;
    objc.version = self.version;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLChatFull
            
-(BOOL)isCan_view_participants {return NO;}
            
@end
        
@implementation TL_chatFull
+(TL_chatFull*)createWithN_id:(int)n_id participants:(TLChatParticipants*)participants chat_photo:(TLPhoto*)chat_photo notify_settings:(TLPeerNotifySettings*)notify_settings exported_invite:(TLExportedChatInvite*)exported_invite bot_info:(NSMutableArray*)bot_info {
	TL_chatFull* obj = [[TL_chatFull alloc] init];
	obj.n_id = n_id;
	obj.participants = participants;
	obj.chat_photo = chat_photo;
	obj.notify_settings = notify_settings;
	obj.exported_invite = exported_invite;
	obj.bot_info = bot_info;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[ClassStore TLSerialize:self.participants stream:stream];
	[ClassStore TLSerialize:self.chat_photo stream:stream];
	[ClassStore TLSerialize:self.notify_settings stream:stream];
	[ClassStore TLSerialize:self.exported_invite stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.bot_info count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLBotInfo* obj = [self.bot_info objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readInt];
	self.participants = [ClassStore TLDeserialize:stream];
	self.chat_photo = [ClassStore TLDeserialize:stream];
	self.notify_settings = [ClassStore TLDeserialize:stream];
	self.exported_invite = [ClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.bot_info)
			self.bot_info = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLBotInfo* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLBotInfo class]])
                 [self.bot_info addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_chatFull *)copy {
    
    TL_chatFull *objc = [[TL_chatFull alloc] init];
    
    objc.n_id = self.n_id;
    objc.participants = [self.participants copy];
    objc.chat_photo = [self.chat_photo copy];
    objc.notify_settings = [self.notify_settings copy];
    objc.exported_invite = [self.exported_invite copy];
    objc.bot_info = [self.bot_info copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_channelFull
+(TL_channelFull*)createWithFlags:(int)flags  n_id:(int)n_id about:(NSString*)about participants_count:(int)participants_count admins_count:(int)admins_count kicked_count:(int)kicked_count read_inbox_max_id:(int)read_inbox_max_id unread_count:(int)unread_count unread_important_count:(int)unread_important_count chat_photo:(TLPhoto*)chat_photo notify_settings:(TLPeerNotifySettings*)notify_settings exported_invite:(TLExportedChatInvite*)exported_invite bot_info:(NSMutableArray*)bot_info migrated_from_chat_id:(int)migrated_from_chat_id migrated_from_max_id:(int)migrated_from_max_id {
	TL_channelFull* obj = [[TL_channelFull alloc] init];
	obj.flags = flags;
	
	obj.n_id = n_id;
	obj.about = about;
	obj.participants_count = participants_count;
	obj.admins_count = admins_count;
	obj.kicked_count = kicked_count;
	obj.read_inbox_max_id = read_inbox_max_id;
	obj.unread_count = unread_count;
	obj.unread_important_count = unread_important_count;
	obj.chat_photo = chat_photo;
	obj.notify_settings = notify_settings;
	obj.exported_invite = exported_invite;
	obj.bot_info = bot_info;
	obj.migrated_from_chat_id = migrated_from_chat_id;
	obj.migrated_from_max_id = migrated_from_max_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	[stream writeInt:self.n_id];
	[stream writeString:self.about];
	if(self.flags & (1 << 0)) {[stream writeInt:self.participants_count];}
	if(self.flags & (1 << 1)) {[stream writeInt:self.admins_count];}
	if(self.flags & (1 << 2)) {[stream writeInt:self.kicked_count];}
	[stream writeInt:self.read_inbox_max_id];
	[stream writeInt:self.unread_count];
	[stream writeInt:self.unread_important_count];
	[ClassStore TLSerialize:self.chat_photo stream:stream];
	[ClassStore TLSerialize:self.notify_settings stream:stream];
	[ClassStore TLSerialize:self.exported_invite stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.bot_info count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLBotInfo* obj = [self.bot_info objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	if(self.flags & (1 << 4)) {[stream writeInt:self.migrated_from_chat_id];}
	if(self.flags & (1 << 4)) {[stream writeInt:self.migrated_from_max_id];}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	super.n_id = [stream readInt];
	super.about = [stream readString];
	if(self.flags & (1 << 0)) {super.participants_count = [stream readInt];}
	if(self.flags & (1 << 1)) {super.admins_count = [stream readInt];}
	if(self.flags & (1 << 2)) {super.kicked_count = [stream readInt];}
	super.read_inbox_max_id = [stream readInt];
	super.unread_count = [stream readInt];
	super.unread_important_count = [stream readInt];
	self.chat_photo = [ClassStore TLDeserialize:stream];
	self.notify_settings = [ClassStore TLDeserialize:stream];
	self.exported_invite = [ClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.bot_info)
			self.bot_info = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLBotInfo* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLBotInfo class]])
                 [self.bot_info addObject:obj];
            else
                break;
		}
	}
	if(self.flags & (1 << 4)) {super.migrated_from_chat_id = [stream readInt];}
	if(self.flags & (1 << 4)) {super.migrated_from_max_id = [stream readInt];}
}
        
-(TL_channelFull *)copy {
    
    TL_channelFull *objc = [[TL_channelFull alloc] init];
    
    objc.flags = self.flags;
    
    objc.n_id = self.n_id;
    objc.about = self.about;
    objc.participants_count = self.participants_count;
    objc.admins_count = self.admins_count;
    objc.kicked_count = self.kicked_count;
    objc.read_inbox_max_id = self.read_inbox_max_id;
    objc.unread_count = self.unread_count;
    objc.unread_important_count = self.unread_important_count;
    objc.chat_photo = [self.chat_photo copy];
    objc.notify_settings = [self.notify_settings copy];
    objc.exported_invite = [self.exported_invite copy];
    objc.bot_info = [self.bot_info copy];
    objc.migrated_from_chat_id = self.migrated_from_chat_id;
    objc.migrated_from_max_id = self.migrated_from_max_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isCan_view_participants {return (self.flags & (1 << 3)) > 0;}
                        
-(void)setParticipants_count:(int)participants_count
{
   super.participants_count = participants_count;
                
    if(super.participants_count == 0)  { super.flags&= ~ (1 << 0) ;} else { super.flags|= (1 << 0); }
}            
-(void)setAdmins_count:(int)admins_count
{
   super.admins_count = admins_count;
                
    if(super.admins_count == 0)  { super.flags&= ~ (1 << 1) ;} else { super.flags|= (1 << 1); }
}            
-(void)setKicked_count:(int)kicked_count
{
   super.kicked_count = kicked_count;
                
    if(super.kicked_count == 0)  { super.flags&= ~ (1 << 2) ;} else { super.flags|= (1 << 2); }
}            
-(void)setMigrated_from_chat_id:(int)migrated_from_chat_id
{
   super.migrated_from_chat_id = migrated_from_chat_id;
                
    if(super.migrated_from_chat_id == 0)  { super.flags&= ~ (1 << 4) ;} else { super.flags|= (1 << 4); }
}            
-(void)setMigrated_from_max_id:(int)migrated_from_max_id
{
   super.migrated_from_max_id = migrated_from_max_id;
                
    if(super.migrated_from_max_id == 0)  { super.flags&= ~ (1 << 4) ;} else { super.flags|= (1 << 4); }
}
        
@end

@implementation TL_chatFull_old29
+(TL_chatFull_old29*)createWithN_id:(int)n_id participants:(TLChatParticipants*)participants chat_photo:(TLPhoto*)chat_photo notify_settings:(TLPeerNotifySettings*)notify_settings exported_invite:(TLExportedChatInvite*)exported_invite {
	TL_chatFull_old29* obj = [[TL_chatFull_old29 alloc] init];
	obj.n_id = n_id;
	obj.participants = participants;
	obj.chat_photo = chat_photo;
	obj.notify_settings = notify_settings;
	obj.exported_invite = exported_invite;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[ClassStore TLSerialize:self.participants stream:stream];
	[ClassStore TLSerialize:self.chat_photo stream:stream];
	[ClassStore TLSerialize:self.notify_settings stream:stream];
	[ClassStore TLSerialize:self.exported_invite stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readInt];
	self.participants = [ClassStore TLDeserialize:stream];
	self.chat_photo = [ClassStore TLDeserialize:stream];
	self.notify_settings = [ClassStore TLDeserialize:stream];
	self.exported_invite = [ClassStore TLDeserialize:stream];
}
        
-(TL_chatFull_old29 *)copy {
    
    TL_chatFull_old29 *objc = [[TL_chatFull_old29 alloc] init];
    
    objc.n_id = self.n_id;
    objc.participants = [self.participants copy];
    objc.chat_photo = [self.chat_photo copy];
    objc.notify_settings = [self.notify_settings copy];
    objc.exported_invite = [self.exported_invite copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_channelFull_old39
+(TL_channelFull_old39*)createWithFlags:(int)flags  n_id:(int)n_id about:(NSString*)about participants_count:(int)participants_count admins_count:(int)admins_count kicked_count:(int)kicked_count read_inbox_max_id:(int)read_inbox_max_id unread_count:(int)unread_count unread_important_count:(int)unread_important_count chat_photo:(TLPhoto*)chat_photo notify_settings:(TLPeerNotifySettings*)notify_settings exported_invite:(TLExportedChatInvite*)exported_invite {
	TL_channelFull_old39* obj = [[TL_channelFull_old39 alloc] init];
	obj.flags = flags;
	
	obj.n_id = n_id;
	obj.about = about;
	obj.participants_count = participants_count;
	obj.admins_count = admins_count;
	obj.kicked_count = kicked_count;
	obj.read_inbox_max_id = read_inbox_max_id;
	obj.unread_count = unread_count;
	obj.unread_important_count = unread_important_count;
	obj.chat_photo = chat_photo;
	obj.notify_settings = notify_settings;
	obj.exported_invite = exported_invite;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	[stream writeInt:self.n_id];
	[stream writeString:self.about];
	if(self.flags & (1 << 0)) {[stream writeInt:self.participants_count];}
	if(self.flags & (1 << 1)) {[stream writeInt:self.admins_count];}
	if(self.flags & (1 << 2)) {[stream writeInt:self.kicked_count];}
	[stream writeInt:self.read_inbox_max_id];
	[stream writeInt:self.unread_count];
	[stream writeInt:self.unread_important_count];
	[ClassStore TLSerialize:self.chat_photo stream:stream];
	[ClassStore TLSerialize:self.notify_settings stream:stream];
	[ClassStore TLSerialize:self.exported_invite stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	super.n_id = [stream readInt];
	super.about = [stream readString];
	if(self.flags & (1 << 0)) {super.participants_count = [stream readInt];}
	if(self.flags & (1 << 1)) {super.admins_count = [stream readInt];}
	if(self.flags & (1 << 2)) {super.kicked_count = [stream readInt];}
	super.read_inbox_max_id = [stream readInt];
	super.unread_count = [stream readInt];
	super.unread_important_count = [stream readInt];
	self.chat_photo = [ClassStore TLDeserialize:stream];
	self.notify_settings = [ClassStore TLDeserialize:stream];
	self.exported_invite = [ClassStore TLDeserialize:stream];
}
        
-(TL_channelFull_old39 *)copy {
    
    TL_channelFull_old39 *objc = [[TL_channelFull_old39 alloc] init];
    
    objc.flags = self.flags;
    
    objc.n_id = self.n_id;
    objc.about = self.about;
    objc.participants_count = self.participants_count;
    objc.admins_count = self.admins_count;
    objc.kicked_count = self.kicked_count;
    objc.read_inbox_max_id = self.read_inbox_max_id;
    objc.unread_count = self.unread_count;
    objc.unread_important_count = self.unread_important_count;
    objc.chat_photo = [self.chat_photo copy];
    objc.notify_settings = [self.notify_settings copy];
    objc.exported_invite = [self.exported_invite copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isCan_view_participants {return (self.flags & (1 << 3)) > 0;}
                        
-(void)setParticipants_count:(int)participants_count
{
   super.participants_count = participants_count;
                
    if(super.participants_count == 0)  { super.flags&= ~ (1 << 0) ;} else { super.flags|= (1 << 0); }
}            
-(void)setAdmins_count:(int)admins_count
{
   super.admins_count = admins_count;
                
    if(super.admins_count == 0)  { super.flags&= ~ (1 << 1) ;} else { super.flags|= (1 << 1); }
}            
-(void)setKicked_count:(int)kicked_count
{
   super.kicked_count = kicked_count;
                
    if(super.kicked_count == 0)  { super.flags&= ~ (1 << 2) ;} else { super.flags|= (1 << 2); }
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
	super.user_id = [stream readInt];
	super.inviter_id = [stream readInt];
	super.date = [stream readInt];
}
        
-(TL_chatParticipant *)copy {
    
    TL_chatParticipant *objc = [[TL_chatParticipant alloc] init];
    
    objc.user_id = self.user_id;
    objc.inviter_id = self.inviter_id;
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_chatParticipantCreator
+(TL_chatParticipantCreator*)createWithUser_id:(int)user_id {
	TL_chatParticipantCreator* obj = [[TL_chatParticipantCreator alloc] init];
	obj.user_id = user_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
}
-(void)unserialize:(SerializedData*)stream {
	super.user_id = [stream readInt];
}
        
-(TL_chatParticipantCreator *)copy {
    
    TL_chatParticipantCreator *objc = [[TL_chatParticipantCreator alloc] init];
    
    objc.user_id = self.user_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_chatParticipantAdmin
+(TL_chatParticipantAdmin*)createWithUser_id:(int)user_id inviter_id:(int)inviter_id date:(int)date {
	TL_chatParticipantAdmin* obj = [[TL_chatParticipantAdmin alloc] init];
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
	super.user_id = [stream readInt];
	super.inviter_id = [stream readInt];
	super.date = [stream readInt];
}
        
-(TL_chatParticipantAdmin *)copy {
    
    TL_chatParticipantAdmin *objc = [[TL_chatParticipantAdmin alloc] init];
    
    objc.user_id = self.user_id;
    objc.inviter_id = self.inviter_id;
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLChatParticipants

@end
        
@implementation TL_chatParticipantsForbidden
+(TL_chatParticipantsForbidden*)createWithFlags:(int)flags chat_id:(int)chat_id self_participant:(TLChatParticipant*)self_participant {
	TL_chatParticipantsForbidden* obj = [[TL_chatParticipantsForbidden alloc] init];
	obj.flags = flags;
	obj.chat_id = chat_id;
	obj.self_participant = self_participant;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	[stream writeInt:self.chat_id];
	if(self.flags & (1 << 0)) {[ClassStore TLSerialize:self.self_participant stream:stream];}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	super.chat_id = [stream readInt];
	if(self.flags & (1 << 0)) {self.self_participant = [ClassStore TLDeserialize:stream];}
}
        
-(TL_chatParticipantsForbidden *)copy {
    
    TL_chatParticipantsForbidden *objc = [[TL_chatParticipantsForbidden alloc] init];
    
    objc.flags = self.flags;
    objc.chat_id = self.chat_id;
    objc.self_participant = [self.self_participant copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(void)setSelf_participant:(TLChatParticipant*)self_participant
{
   super.self_participant = self_participant;
                
    if(super.self_participant == nil)  { super.flags&= ~ (1 << 0) ;} else { super.flags|= (1 << 0); }
}
        
@end

@implementation TL_chatParticipants
+(TL_chatParticipants*)createWithChat_id:(int)chat_id participants:(NSMutableArray*)participants version:(int)version {
	TL_chatParticipants* obj = [[TL_chatParticipants alloc] init];
	obj.chat_id = chat_id;
	obj.participants = participants;
	obj.version = version;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.participants count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChatParticipant* obj = [self.participants objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.version];
}
-(void)unserialize:(SerializedData*)stream {
	super.chat_id = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.participants)
			self.participants = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChatParticipant* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChatParticipant class]])
                 [self.participants addObject:obj];
            else
                break;
		}
	}
	super.version = [stream readInt];
}
        
-(TL_chatParticipants *)copy {
    
    TL_chatParticipants *objc = [[TL_chatParticipants alloc] init];
    
    objc.chat_id = self.chat_id;
    objc.participants = [self.participants copy];
    objc.version = self.version;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_chatParticipantsForbidden_old34
+(TL_chatParticipantsForbidden_old34*)createWithChat_id:(int)chat_id {
	TL_chatParticipantsForbidden_old34* obj = [[TL_chatParticipantsForbidden_old34 alloc] init];
	obj.chat_id = chat_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
}
-(void)unserialize:(SerializedData*)stream {
	super.chat_id = [stream readInt];
}
        
-(TL_chatParticipantsForbidden_old34 *)copy {
    
    TL_chatParticipantsForbidden_old34 *objc = [[TL_chatParticipantsForbidden_old34 alloc] init];
    
    objc.chat_id = self.chat_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_chatParticipants_old38
+(TL_chatParticipants_old38*)createWithChat_id:(int)chat_id admin_id:(int)admin_id participants:(NSMutableArray*)participants version:(int)version {
	TL_chatParticipants_old38* obj = [[TL_chatParticipants_old38 alloc] init];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.version];
}
-(void)unserialize:(SerializedData*)stream {
	super.chat_id = [stream readInt];
	super.admin_id = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.participants)
			self.participants = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChatParticipant* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChatParticipant class]])
                 [self.participants addObject:obj];
            else
                break;
		}
	}
	super.version = [stream readInt];
}
        
-(TL_chatParticipants_old38 *)copy {
    
    TL_chatParticipants_old38 *objc = [[TL_chatParticipants_old38 alloc] init];
    
    objc.chat_id = self.chat_id;
    objc.admin_id = self.admin_id;
    objc.participants = [self.participants copy];
    objc.version = self.version;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_chatParticipants_old39
+(TL_chatParticipants_old39*)createWithChat_id:(int)chat_id admin_id:(int)admin_id participants:(NSMutableArray*)participants version:(int)version {
	TL_chatParticipants_old39* obj = [[TL_chatParticipants_old39 alloc] init];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.version];
}
-(void)unserialize:(SerializedData*)stream {
	super.chat_id = [stream readInt];
	super.admin_id = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.participants)
			self.participants = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChatParticipant* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChatParticipant class]])
                 [self.participants addObject:obj];
            else
                break;
		}
	}
	super.version = [stream readInt];
}
        
-(TL_chatParticipants_old39 *)copy {
    
    TL_chatParticipants_old39 *objc = [[TL_chatParticipants_old39 alloc] init];
    
    objc.chat_id = self.chat_id;
    objc.admin_id = self.admin_id;
    objc.participants = [self.participants copy];
    objc.version = self.version;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_chatPhotoEmpty *)copy {
    
    TL_chatPhotoEmpty *objc = [[TL_chatPhotoEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.photo_small stream:stream];
	[ClassStore TLSerialize:self.photo_big stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.photo_small = [ClassStore TLDeserialize:stream];
	self.photo_big = [ClassStore TLDeserialize:stream];
}
        
-(TL_chatPhoto *)copy {
    
    TL_chatPhoto *objc = [[TL_chatPhoto alloc] init];
    
    objc.photo_small = [self.photo_small copy];
    objc.photo_big = [self.photo_big copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLMessage
            
-(BOOL)isUnread {return NO;}
                        
-(BOOL)isN_out {return NO;}
                        
-(BOOL)isMentioned {return NO;}
                        
-(BOOL)isMedia_unread {return NO;}
            
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
	super.n_id = [stream readInt];
}
        
-(TL_messageEmpty *)copy {
    
    TL_messageEmpty *objc = [[TL_messageEmpty alloc] init];
    
    objc.n_id = self.n_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_message
+(TL_message*)createWithFlags:(int)flags     n_id:(int)n_id from_id:(int)from_id to_id:(TLPeer*)to_id fwd_from_id:(TLPeer*)fwd_from_id fwd_date:(int)fwd_date reply_to_msg_id:(int)reply_to_msg_id date:(int)date message:(NSString*)message media:(TLMessageMedia*)media reply_markup:(TLReplyMarkup*)reply_markup entities:(NSMutableArray*)entities views:(int)views {
	TL_message* obj = [[TL_message alloc] init];
	obj.flags = flags;
	
	
	
	
	obj.n_id = n_id;
	obj.from_id = from_id;
	obj.to_id = to_id;
	obj.fwd_from_id = fwd_from_id;
	obj.fwd_date = fwd_date;
	obj.reply_to_msg_id = reply_to_msg_id;
	obj.date = date;
	obj.message = message;
	obj.media = media;
	obj.reply_markup = reply_markup;
	obj.entities = entities;
	obj.views = views;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	
	
	
	[stream writeInt:self.n_id];
	if(self.flags & (1 << 8)) {[stream writeInt:self.from_id];}
	[ClassStore TLSerialize:self.to_id stream:stream];
	if(self.flags & (1 << 2)) {[ClassStore TLSerialize:self.fwd_from_id stream:stream];}
	if(self.flags & (1 << 2)) {[stream writeInt:self.fwd_date];}
	if(self.flags & (1 << 3)) {[stream writeInt:self.reply_to_msg_id];}
	[stream writeInt:self.date];
	[stream writeString:self.message];
	if(self.flags & (1 << 9)) {[ClassStore TLSerialize:self.media stream:stream];}
	if(self.flags & (1 << 6)) {[ClassStore TLSerialize:self.reply_markup stream:stream];}
	if(self.flags & (1 << 7)) {//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.entities count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLMessageEntity* obj = [self.entities objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}}
	if(self.flags & (1 << 10)) {[stream writeInt:self.views];}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	
	
	
	super.n_id = [stream readInt];
	if(self.flags & (1 << 8)) {super.from_id = [stream readInt];}
	self.to_id = [ClassStore TLDeserialize:stream];
	if(self.flags & (1 << 2)) {self.fwd_from_id = [ClassStore TLDeserialize:stream];}
	if(self.flags & (1 << 2)) {super.fwd_date = [stream readInt];}
	if(self.flags & (1 << 3)) {super.reply_to_msg_id = [stream readInt];}
	super.date = [stream readInt];
	super.message = [stream readString];
	if(self.flags & (1 << 9)) {self.media = [ClassStore TLDeserialize:stream];}
	if(self.flags & (1 << 6)) {self.reply_markup = [ClassStore TLDeserialize:stream];}
	if(self.flags & (1 << 7)) {//UNS FullVector
	[stream readInt];
	{
		if(!self.entities)
			self.entities = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessageEntity* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLMessageEntity class]])
                 [self.entities addObject:obj];
            else
                break;
		}
	}}
	if(self.flags & (1 << 10)) {super.views = [stream readInt];}
}
        
-(TL_message *)copy {
    
    TL_message *objc = [[TL_message alloc] init];
    
    objc.flags = self.flags;
    
    
    
    
    objc.n_id = self.n_id;
    objc.from_id = self.from_id;
    objc.to_id = [self.to_id copy];
    objc.fwd_from_id = [self.fwd_from_id copy];
    objc.fwd_date = self.fwd_date;
    objc.reply_to_msg_id = self.reply_to_msg_id;
    objc.date = self.date;
    objc.message = self.message;
    objc.media = [self.media copy];
    objc.reply_markup = [self.reply_markup copy];
    objc.entities = [self.entities copy];
    objc.views = self.views;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isUnread {return (self.flags & (1 << 0)) > 0;}
                        
-(BOOL)isN_out {return (self.flags & (1 << 1)) > 0;}
                        
-(BOOL)isMentioned {return (self.flags & (1 << 4)) > 0;}
                        
-(BOOL)isMedia_unread {return (self.flags & (1 << 5)) > 0;}
                        
-(void)setFrom_id:(int)from_id
{
   super.from_id = from_id;
                
    if(super.from_id == 0)  { super.flags&= ~ (1 << 8) ;} else { super.flags|= (1 << 8); }
}            
-(void)setFwd_from_id:(TLPeer*)fwd_from_id
{
   super.fwd_from_id = fwd_from_id;
                
    if(super.fwd_from_id == nil)  { super.flags&= ~ (1 << 2) ;} else { super.flags|= (1 << 2); }
}            
-(void)setFwd_date:(int)fwd_date
{
   super.fwd_date = fwd_date;
                
    if(super.fwd_date == 0)  { super.flags&= ~ (1 << 2) ;} else { super.flags|= (1 << 2); }
}            
-(void)setReply_to_msg_id:(int)reply_to_msg_id
{
   super.reply_to_msg_id = reply_to_msg_id;
                
    if(super.reply_to_msg_id == 0)  { super.flags&= ~ (1 << 3) ;} else { super.flags|= (1 << 3); }
}            
-(void)setMedia:(TLMessageMedia*)media
{
   super.media = media;
                
    if(super.media == nil)  { super.flags&= ~ (1 << 9) ;} else { super.flags|= (1 << 9); }
}            
-(void)setReply_markup:(TLReplyMarkup*)reply_markup
{
   super.reply_markup = reply_markup;
                
    if(super.reply_markup == nil)  { super.flags&= ~ (1 << 6) ;} else { super.flags|= (1 << 6); }
}            
-(void)setEntities:(NSMutableArray*)entities
{
   super.entities = entities;
                
    if(super.entities == nil)  { super.flags&= ~ (1 << 7) ;} else { super.flags|= (1 << 7); }
}            
-(void)setViews:(int)views
{
   super.views = views;
                
    if(super.views == 0)  { super.flags&= ~ (1 << 10) ;} else { super.flags|= (1 << 10); }
}
        
@end

@implementation TL_messageService
+(TL_messageService*)createWithFlags:(int)flags     n_id:(int)n_id from_id:(int)from_id to_id:(TLPeer*)to_id date:(int)date action:(TLMessageAction*)action {
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
	if(self.flags & (1 << 8)) {[stream writeInt:self.from_id];}
	[ClassStore TLSerialize:self.to_id stream:stream];
	[stream writeInt:self.date];
	[ClassStore TLSerialize:self.action stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	
	
	
	super.n_id = [stream readInt];
	if(self.flags & (1 << 8)) {super.from_id = [stream readInt];}
	self.to_id = [ClassStore TLDeserialize:stream];
	super.date = [stream readInt];
	self.action = [ClassStore TLDeserialize:stream];
}
        
-(TL_messageService *)copy {
    
    TL_messageService *objc = [[TL_messageService alloc] init];
    
    objc.flags = self.flags;
    
    
    
    
    objc.n_id = self.n_id;
    objc.from_id = self.from_id;
    objc.to_id = [self.to_id copy];
    objc.date = self.date;
    objc.action = [self.action copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isUnread {return (self.flags & (1 << 0)) > 0;}
                        
-(BOOL)isN_out {return (self.flags & (1 << 1)) > 0;}
                        
-(BOOL)isMentioned {return (self.flags & (1 << 4)) > 0;}
                        
-(BOOL)isMedia_unread {return (self.flags & (1 << 5)) > 0;}
                        
-(void)setFrom_id:(int)from_id
{
   super.from_id = from_id;
                
    if(super.from_id == 0)  { super.flags&= ~ (1 << 8) ;} else { super.flags|= (1 << 8); }
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
        
-(TL_messageMediaEmpty *)copy {
    
    TL_messageMediaEmpty *objc = [[TL_messageMediaEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageMediaPhoto
+(TL_messageMediaPhoto*)createWithPhoto:(TLPhoto*)photo caption:(NSString*)caption {
	TL_messageMediaPhoto* obj = [[TL_messageMediaPhoto alloc] init];
	obj.photo = photo;
	obj.caption = caption;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.photo stream:stream];
	[stream writeString:self.caption];
}
-(void)unserialize:(SerializedData*)stream {
	self.photo = [ClassStore TLDeserialize:stream];
	super.caption = [stream readString];
}
        
-(TL_messageMediaPhoto *)copy {
    
    TL_messageMediaPhoto *objc = [[TL_messageMediaPhoto alloc] init];
    
    objc.photo = [self.photo copy];
    objc.caption = self.caption;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageMediaVideo
+(TL_messageMediaVideo*)createWithVideo:(TLVideo*)video caption:(NSString*)caption {
	TL_messageMediaVideo* obj = [[TL_messageMediaVideo alloc] init];
	obj.video = video;
	obj.caption = caption;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.video stream:stream];
	[stream writeString:self.caption];
}
-(void)unserialize:(SerializedData*)stream {
	self.video = [ClassStore TLDeserialize:stream];
	super.caption = [stream readString];
}
        
-(TL_messageMediaVideo *)copy {
    
    TL_messageMediaVideo *objc = [[TL_messageMediaVideo alloc] init];
    
    objc.video = [self.video copy];
    objc.caption = self.caption;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageMediaGeo
+(TL_messageMediaGeo*)createWithGeo:(TLGeoPoint*)geo {
	TL_messageMediaGeo* obj = [[TL_messageMediaGeo alloc] init];
	obj.geo = geo;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.geo stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.geo = [ClassStore TLDeserialize:stream];
}
        
-(TL_messageMediaGeo *)copy {
    
    TL_messageMediaGeo *objc = [[TL_messageMediaGeo alloc] init];
    
    objc.geo = [self.geo copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.phone_number = [stream readString];
	super.first_name = [stream readString];
	super.last_name = [stream readString];
	super.user_id = [stream readInt];
}
        
-(TL_messageMediaContact *)copy {
    
    TL_messageMediaContact *objc = [[TL_messageMediaContact alloc] init];
    
    objc.phone_number = self.phone_number;
    objc.first_name = self.first_name;
    objc.last_name = self.last_name;
    objc.user_id = self.user_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageMediaUnsupported
+(TL_messageMediaUnsupported*)create {
	TL_messageMediaUnsupported* obj = [[TL_messageMediaUnsupported alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_messageMediaUnsupported *)copy {
    
    TL_messageMediaUnsupported *objc = [[TL_messageMediaUnsupported alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageMediaDocument
+(TL_messageMediaDocument*)createWithDocument:(TLDocument*)document {
	TL_messageMediaDocument* obj = [[TL_messageMediaDocument alloc] init];
	obj.document = document;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.document stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.document = [ClassStore TLDeserialize:stream];
}
        
-(TL_messageMediaDocument *)copy {
    
    TL_messageMediaDocument *objc = [[TL_messageMediaDocument alloc] init];
    
    objc.document = [self.document copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageMediaAudio
+(TL_messageMediaAudio*)createWithAudio:(TLAudio*)audio {
	TL_messageMediaAudio* obj = [[TL_messageMediaAudio alloc] init];
	obj.audio = audio;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.audio stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.audio = [ClassStore TLDeserialize:stream];
}
        
-(TL_messageMediaAudio *)copy {
    
    TL_messageMediaAudio *objc = [[TL_messageMediaAudio alloc] init];
    
    objc.audio = [self.audio copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageMediaWebPage
+(TL_messageMediaWebPage*)createWithWebpage:(TLWebPage*)webpage {
	TL_messageMediaWebPage* obj = [[TL_messageMediaWebPage alloc] init];
	obj.webpage = webpage;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.webpage stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.webpage = [ClassStore TLDeserialize:stream];
}
        
-(TL_messageMediaWebPage *)copy {
    
    TL_messageMediaWebPage *objc = [[TL_messageMediaWebPage alloc] init];
    
    objc.webpage = [self.webpage copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageMediaVenue
+(TL_messageMediaVenue*)createWithGeo:(TLGeoPoint*)geo title:(NSString*)title address:(NSString*)address provider:(NSString*)provider venue_id:(NSString*)venue_id {
	TL_messageMediaVenue* obj = [[TL_messageMediaVenue alloc] init];
	obj.geo = geo;
	obj.title = title;
	obj.address = address;
	obj.provider = provider;
	obj.venue_id = venue_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.geo stream:stream];
	[stream writeString:self.title];
	[stream writeString:self.address];
	[stream writeString:self.provider];
	[stream writeString:self.venue_id];
}
-(void)unserialize:(SerializedData*)stream {
	self.geo = [ClassStore TLDeserialize:stream];
	super.title = [stream readString];
	super.address = [stream readString];
	super.provider = [stream readString];
	super.venue_id = [stream readString];
}
        
-(TL_messageMediaVenue *)copy {
    
    TL_messageMediaVenue *objc = [[TL_messageMediaVenue alloc] init];
    
    objc.geo = [self.geo copy];
    objc.title = self.title;
    objc.address = self.address;
    objc.provider = self.provider;
    objc.venue_id = self.venue_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_messageActionEmpty *)copy {
    
    TL_messageActionEmpty *objc = [[TL_messageActionEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            if([self.users count] > i) {
                NSNumber* obj = [self.users objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.title = [stream readString];
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			int obj = [stream readInt];
			[self.users addObject:@(obj)];
		}
	}
}
        
-(TL_messageActionChatCreate *)copy {
    
    TL_messageActionChatCreate *objc = [[TL_messageActionChatCreate alloc] init];
    
    objc.title = self.title;
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.title = [stream readString];
}
        
-(TL_messageActionChatEditTitle *)copy {
    
    TL_messageActionChatEditTitle *objc = [[TL_messageActionChatEditTitle alloc] init];
    
    objc.title = self.title;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageActionChatEditPhoto
+(TL_messageActionChatEditPhoto*)createWithPhoto:(TLPhoto*)photo {
	TL_messageActionChatEditPhoto* obj = [[TL_messageActionChatEditPhoto alloc] init];
	obj.photo = photo;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.photo stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.photo = [ClassStore TLDeserialize:stream];
}
        
-(TL_messageActionChatEditPhoto *)copy {
    
    TL_messageActionChatEditPhoto *objc = [[TL_messageActionChatEditPhoto alloc] init];
    
    objc.photo = [self.photo copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_messageActionChatDeletePhoto *)copy {
    
    TL_messageActionChatDeletePhoto *objc = [[TL_messageActionChatDeletePhoto alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageActionChatAddUser
+(TL_messageActionChatAddUser*)createWithUsers:(NSMutableArray*)users {
	TL_messageActionChatAddUser* obj = [[TL_messageActionChatAddUser alloc] init];
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
            if([self.users count] > i) {
                NSNumber* obj = [self.users objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
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
			[self.users addObject:@(obj)];
		}
	}
}
        
-(TL_messageActionChatAddUser *)copy {
    
    TL_messageActionChatAddUser *objc = [[TL_messageActionChatAddUser alloc] init];
    
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.user_id = [stream readInt];
}
        
-(TL_messageActionChatDeleteUser *)copy {
    
    TL_messageActionChatDeleteUser *objc = [[TL_messageActionChatDeleteUser alloc] init];
    
    objc.user_id = self.user_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageActionChatJoinedByLink
+(TL_messageActionChatJoinedByLink*)createWithInviter_id:(int)inviter_id {
	TL_messageActionChatJoinedByLink* obj = [[TL_messageActionChatJoinedByLink alloc] init];
	obj.inviter_id = inviter_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.inviter_id];
}
-(void)unserialize:(SerializedData*)stream {
	super.inviter_id = [stream readInt];
}
        
-(TL_messageActionChatJoinedByLink *)copy {
    
    TL_messageActionChatJoinedByLink *objc = [[TL_messageActionChatJoinedByLink alloc] init];
    
    objc.inviter_id = self.inviter_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageActionChannelCreate
+(TL_messageActionChannelCreate*)createWithTitle:(NSString*)title {
	TL_messageActionChannelCreate* obj = [[TL_messageActionChannelCreate alloc] init];
	obj.title = title;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.title];
}
-(void)unserialize:(SerializedData*)stream {
	super.title = [stream readString];
}
        
-(TL_messageActionChannelCreate *)copy {
    
    TL_messageActionChannelCreate *objc = [[TL_messageActionChannelCreate alloc] init];
    
    objc.title = self.title;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageActionChatMigrateTo
+(TL_messageActionChatMigrateTo*)createWithChannel_id:(int)channel_id {
	TL_messageActionChatMigrateTo* obj = [[TL_messageActionChatMigrateTo alloc] init];
	obj.channel_id = channel_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.channel_id];
}
-(void)unserialize:(SerializedData*)stream {
	super.channel_id = [stream readInt];
}
        
-(TL_messageActionChatMigrateTo *)copy {
    
    TL_messageActionChatMigrateTo *objc = [[TL_messageActionChatMigrateTo alloc] init];
    
    objc.channel_id = self.channel_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageActionChannelMigrateFrom
+(TL_messageActionChannelMigrateFrom*)createWithTitle:(NSString*)title chat_id:(int)chat_id {
	TL_messageActionChannelMigrateFrom* obj = [[TL_messageActionChannelMigrateFrom alloc] init];
	obj.title = title;
	obj.chat_id = chat_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.title];
	[stream writeInt:self.chat_id];
}
-(void)unserialize:(SerializedData*)stream {
	super.title = [stream readString];
	super.chat_id = [stream readInt];
}
        
-(TL_messageActionChannelMigrateFrom *)copy {
    
    TL_messageActionChannelMigrateFrom *objc = [[TL_messageActionChannelMigrateFrom alloc] init];
    
    objc.title = self.title;
    objc.chat_id = self.chat_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageActionChatAddUser_old40
+(TL_messageActionChatAddUser_old40*)createWithUser_id:(int)user_id {
	TL_messageActionChatAddUser_old40* obj = [[TL_messageActionChatAddUser_old40 alloc] init];
	obj.user_id = user_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
}
-(void)unserialize:(SerializedData*)stream {
	super.user_id = [stream readInt];
}
        
-(TL_messageActionChatAddUser_old40 *)copy {
    
    TL_messageActionChatAddUser_old40 *objc = [[TL_messageActionChatAddUser_old40 alloc] init];
    
    objc.user_id = self.user_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLDialog

@end
        
@implementation TL_dialog
+(TL_dialog*)createWithPeer:(TLPeer*)peer top_message:(int)top_message read_inbox_max_id:(int)read_inbox_max_id unread_count:(int)unread_count notify_settings:(TLPeerNotifySettings*)notify_settings {
	TL_dialog* obj = [[TL_dialog alloc] init];
	obj.peer = peer;
	obj.top_message = top_message;
	obj.read_inbox_max_id = read_inbox_max_id;
	obj.unread_count = unread_count;
	obj.notify_settings = notify_settings;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeInt:self.top_message];
	[stream writeInt:self.read_inbox_max_id];
	[stream writeInt:self.unread_count];
	[ClassStore TLSerialize:self.notify_settings stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.peer = [ClassStore TLDeserialize:stream];
	super.top_message = [stream readInt];
	super.read_inbox_max_id = [stream readInt];
	super.unread_count = [stream readInt];
	self.notify_settings = [ClassStore TLDeserialize:stream];
}
        
-(TL_dialog *)copy {
    
    TL_dialog *objc = [[TL_dialog alloc] init];
    
    objc.peer = [self.peer copy];
    objc.top_message = self.top_message;
    objc.read_inbox_max_id = self.read_inbox_max_id;
    objc.unread_count = self.unread_count;
    objc.notify_settings = [self.notify_settings copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_dialogChannel
+(TL_dialogChannel*)createWithPeer:(TLPeer*)peer top_message:(int)top_message top_important_message:(int)top_important_message read_inbox_max_id:(int)read_inbox_max_id unread_count:(int)unread_count unread_important_count:(int)unread_important_count notify_settings:(TLPeerNotifySettings*)notify_settings pts:(int)pts {
	TL_dialogChannel* obj = [[TL_dialogChannel alloc] init];
	obj.peer = peer;
	obj.top_message = top_message;
	obj.top_important_message = top_important_message;
	obj.read_inbox_max_id = read_inbox_max_id;
	obj.unread_count = unread_count;
	obj.unread_important_count = unread_important_count;
	obj.notify_settings = notify_settings;
	obj.pts = pts;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeInt:self.top_message];
	[stream writeInt:self.top_important_message];
	[stream writeInt:self.read_inbox_max_id];
	[stream writeInt:self.unread_count];
	[stream writeInt:self.unread_important_count];
	[ClassStore TLSerialize:self.notify_settings stream:stream];
	[stream writeInt:self.pts];
}
-(void)unserialize:(SerializedData*)stream {
	self.peer = [ClassStore TLDeserialize:stream];
	super.top_message = [stream readInt];
	super.top_important_message = [stream readInt];
	super.read_inbox_max_id = [stream readInt];
	super.unread_count = [stream readInt];
	super.unread_important_count = [stream readInt];
	self.notify_settings = [ClassStore TLDeserialize:stream];
	super.pts = [stream readInt];
}
        
-(TL_dialogChannel *)copy {
    
    TL_dialogChannel *objc = [[TL_dialogChannel alloc] init];
    
    objc.peer = [self.peer copy];
    objc.top_message = self.top_message;
    objc.top_important_message = self.top_important_message;
    objc.read_inbox_max_id = self.read_inbox_max_id;
    objc.unread_count = self.unread_count;
    objc.unread_important_count = self.unread_important_count;
    objc.notify_settings = [self.notify_settings copy];
    objc.pts = self.pts;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
}
        
-(TL_photoEmpty *)copy {
    
    TL_photoEmpty *objc = [[TL_photoEmpty alloc] init];
    
    objc.n_id = self.n_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_photo
+(TL_photo*)createWithN_id:(long)n_id access_hash:(long)access_hash date:(int)date sizes:(NSMutableArray*)sizes {
	TL_photo* obj = [[TL_photo alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.date = date;
	obj.sizes = sizes;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.date];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.sizes count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLPhotoSize* obj = [self.sizes objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
	super.date = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.sizes)
			self.sizes = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLPhotoSize* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLPhotoSize class]])
                 [self.sizes addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_photo *)copy {
    
    TL_photo *objc = [[TL_photo alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    objc.date = self.date;
    objc.sizes = [self.sizes copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_photo_old31
+(TL_photo_old31*)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date geo:(TLGeoPoint*)geo sizes:(NSMutableArray*)sizes {
	TL_photo_old31* obj = [[TL_photo_old31 alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.user_id = user_id;
	obj.date = date;
	obj.geo = geo;
	obj.sizes = sizes;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
	[ClassStore TLSerialize:self.geo stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.sizes count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLPhotoSize* obj = [self.sizes objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
	super.user_id = [stream readInt];
	super.date = [stream readInt];
	self.geo = [ClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.sizes)
			self.sizes = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLPhotoSize* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLPhotoSize class]])
                 [self.sizes addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_photo_old31 *)copy {
    
    TL_photo_old31 *objc = [[TL_photo_old31 alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    objc.user_id = self.user_id;
    objc.date = self.date;
    objc.geo = [self.geo copy];
    objc.sizes = [self.sizes copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.type = [stream readString];
}
        
-(TL_photoSizeEmpty *)copy {
    
    TL_photoSizeEmpty *objc = [[TL_photoSizeEmpty alloc] init];
    
    objc.type = self.type;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.location stream:stream];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeInt:self.size];
}
-(void)unserialize:(SerializedData*)stream {
	super.type = [stream readString];
	self.location = [ClassStore TLDeserialize:stream];
	super.w = [stream readInt];
	super.h = [stream readInt];
	super.size = [stream readInt];
}
        
-(TL_photoSize *)copy {
    
    TL_photoSize *objc = [[TL_photoSize alloc] init];
    
    objc.type = self.type;
    objc.location = [self.location copy];
    objc.w = self.w;
    objc.h = self.h;
    objc.size = self.size;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.location stream:stream];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
	[stream writeByteArray:self.bytes];
}
-(void)unserialize:(SerializedData*)stream {
	super.type = [stream readString];
	self.location = [ClassStore TLDeserialize:stream];
	super.w = [stream readInt];
	super.h = [stream readInt];
	super.bytes = [stream readByteArray];
}
        
-(TL_photoCachedSize *)copy {
    
    TL_photoCachedSize *objc = [[TL_photoCachedSize alloc] init];
    
    objc.type = self.type;
    objc.location = [self.location copy];
    objc.w = self.w;
    objc.h = self.h;
    objc.bytes = [self.bytes copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
}
        
-(TL_videoEmpty *)copy {
    
    TL_videoEmpty *objc = [[TL_videoEmpty alloc] init];
    
    objc.n_id = self.n_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_video
+(TL_video*)createWithN_id:(long)n_id access_hash:(long)access_hash date:(int)date duration:(int)duration mime_type:(NSString*)mime_type size:(int)size thumb:(TLPhotoSize*)thumb dc_id:(int)dc_id w:(int)w h:(int)h {
	TL_video* obj = [[TL_video alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.date = date;
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
	[stream writeInt:self.date];
	[stream writeInt:self.duration];
	[stream writeString:self.mime_type];
	[stream writeInt:self.size];
	[ClassStore TLSerialize:self.thumb stream:stream];
	[stream writeInt:self.dc_id];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
	super.date = [stream readInt];
	super.duration = [stream readInt];
	super.mime_type = [stream readString];
	super.size = [stream readInt];
	self.thumb = [ClassStore TLDeserialize:stream];
	super.dc_id = [stream readInt];
	super.w = [stream readInt];
	super.h = [stream readInt];
}
        
-(TL_video *)copy {
    
    TL_video *objc = [[TL_video alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    objc.date = self.date;
    objc.duration = self.duration;
    objc.mime_type = self.mime_type;
    objc.size = self.size;
    objc.thumb = [self.thumb copy];
    objc.dc_id = self.dc_id;
    objc.w = self.w;
    objc.h = self.h;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_video_old29
+(TL_video_old29*)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date duration:(int)duration size:(int)size thumb:(TLPhotoSize*)thumb dc_id:(int)dc_id w:(int)w h:(int)h {
	TL_video_old29* obj = [[TL_video_old29 alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.user_id = user_id;
	obj.date = date;
	obj.duration = duration;
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
	[stream writeInt:self.duration];
	[stream writeInt:self.size];
	[ClassStore TLSerialize:self.thumb stream:stream];
	[stream writeInt:self.dc_id];
	[stream writeInt:self.w];
	[stream writeInt:self.h];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
	super.user_id = [stream readInt];
	super.date = [stream readInt];
	super.duration = [stream readInt];
	super.size = [stream readInt];
	self.thumb = [ClassStore TLDeserialize:stream];
	super.dc_id = [stream readInt];
	super.w = [stream readInt];
	super.h = [stream readInt];
}
        
-(TL_video_old29 *)copy {
    
    TL_video_old29 *objc = [[TL_video_old29 alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    objc.user_id = self.user_id;
    objc.date = self.date;
    objc.duration = self.duration;
    objc.size = self.size;
    objc.thumb = [self.thumb copy];
    objc.dc_id = self.dc_id;
    objc.w = self.w;
    objc.h = self.h;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_geoPointEmpty *)copy {
    
    TL_geoPointEmpty *objc = [[TL_geoPointEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_long = [stream readDouble];
	super.lat = [stream readDouble];
}
        
-(TL_geoPoint *)copy {
    
    TL_geoPoint *objc = [[TL_geoPoint alloc] init];
    
    objc.n_long = self.n_long;
    objc.lat = self.lat;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLauth_CheckedPhone

@end
        
@implementation TL_auth_checkedPhone
+(TL_auth_checkedPhone*)createWithPhone_registered:(Boolean)phone_registered {
	TL_auth_checkedPhone* obj = [[TL_auth_checkedPhone alloc] init];
	obj.phone_registered = phone_registered;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeBool:self.phone_registered];
}
-(void)unserialize:(SerializedData*)stream {
	super.phone_registered = [stream readBool];
}
        
-(TL_auth_checkedPhone *)copy {
    
    TL_auth_checkedPhone *objc = [[TL_auth_checkedPhone alloc] init];
    
    objc.phone_registered = self.phone_registered;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.phone_registered = [stream readBool];
	super.phone_code_hash = [stream readString];
	super.send_call_timeout = [stream readInt];
	super.is_password = [stream readBool];
}
        
-(TL_auth_sentCode *)copy {
    
    TL_auth_sentCode *objc = [[TL_auth_sentCode alloc] init];
    
    objc.phone_registered = self.phone_registered;
    objc.phone_code_hash = self.phone_code_hash;
    objc.send_call_timeout = self.send_call_timeout;
    objc.is_password = self.is_password;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.phone_registered = [stream readBool];
	super.phone_code_hash = [stream readString];
	super.send_call_timeout = [stream readInt];
	super.is_password = [stream readBool];
}
        
-(TL_auth_sentAppCode *)copy {
    
    TL_auth_sentAppCode *objc = [[TL_auth_sentAppCode alloc] init];
    
    objc.phone_registered = self.phone_registered;
    objc.phone_code_hash = self.phone_code_hash;
    objc.send_call_timeout = self.send_call_timeout;
    objc.is_password = self.is_password;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLauth_Authorization

@end
        
@implementation TL_auth_authorization
+(TL_auth_authorization*)createWithUser:(TLUser*)user {
	TL_auth_authorization* obj = [[TL_auth_authorization alloc] init];
	obj.user = user;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.user stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.user = [ClassStore TLDeserialize:stream];
}
        
-(TL_auth_authorization *)copy {
    
    TL_auth_authorization *objc = [[TL_auth_authorization alloc] init];
    
    objc.user = [self.user copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readInt];
	super.bytes = [stream readByteArray];
}
        
-(TL_auth_exportedAuthorization *)copy {
    
    TL_auth_exportedAuthorization *objc = [[TL_auth_exportedAuthorization alloc] init];
    
    objc.n_id = self.n_id;
    objc.bytes = [self.bytes copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.peer stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.peer = [ClassStore TLDeserialize:stream];
}
        
-(TL_inputNotifyPeer *)copy {
    
    TL_inputNotifyPeer *objc = [[TL_inputNotifyPeer alloc] init];
    
    objc.peer = [self.peer copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputNotifyUsers *)copy {
    
    TL_inputNotifyUsers *objc = [[TL_inputNotifyUsers alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputNotifyChats *)copy {
    
    TL_inputNotifyChats *objc = [[TL_inputNotifyChats alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputNotifyAll *)copy {
    
    TL_inputNotifyAll *objc = [[TL_inputNotifyAll alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputPeerNotifyEventsEmpty *)copy {
    
    TL_inputPeerNotifyEventsEmpty *objc = [[TL_inputPeerNotifyEventsEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputPeerNotifyEventsAll *)copy {
    
    TL_inputPeerNotifyEventsAll *objc = [[TL_inputPeerNotifyEventsAll alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.mute_until = [stream readInt];
	super.sound = [stream readString];
	super.show_previews = [stream readBool];
	super.events_mask = [stream readInt];
}
        
-(TL_inputPeerNotifySettings *)copy {
    
    TL_inputPeerNotifySettings *objc = [[TL_inputPeerNotifySettings alloc] init];
    
    objc.mute_until = self.mute_until;
    objc.sound = self.sound;
    objc.show_previews = self.show_previews;
    objc.events_mask = self.events_mask;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_peerNotifyEventsEmpty *)copy {
    
    TL_peerNotifyEventsEmpty *objc = [[TL_peerNotifyEventsEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_peerNotifyEventsAll *)copy {
    
    TL_peerNotifyEventsAll *objc = [[TL_peerNotifyEventsAll alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_peerNotifySettingsEmpty *)copy {
    
    TL_peerNotifySettingsEmpty *objc = [[TL_peerNotifySettingsEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.mute_until = [stream readInt];
	super.sound = [stream readString];
	super.show_previews = [stream readBool];
	super.events_mask = [stream readInt];
}
        
-(TL_peerNotifySettings *)copy {
    
    TL_peerNotifySettings *objc = [[TL_peerNotifySettings alloc] init];
    
    objc.mute_until = self.mute_until;
    objc.sound = self.sound;
    objc.show_previews = self.show_previews;
    objc.events_mask = self.events_mask;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.color];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readInt];
	super.title = [stream readString];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.sizes)
			self.sizes = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLPhotoSize* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLPhotoSize class]])
                 [self.sizes addObject:obj];
            else
                break;
		}
	}
	super.color = [stream readInt];
}
        
-(TL_wallPaper *)copy {
    
    TL_wallPaper *objc = [[TL_wallPaper alloc] init];
    
    objc.n_id = self.n_id;
    objc.title = self.title;
    objc.sizes = [self.sizes copy];
    objc.color = self.color;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readInt];
	super.title = [stream readString];
	super.bg_color = [stream readInt];
	super.color = [stream readInt];
}
        
-(TL_wallPaperSolid *)copy {
    
    TL_wallPaperSolid *objc = [[TL_wallPaperSolid alloc] init];
    
    objc.n_id = self.n_id;
    objc.title = self.title;
    objc.bg_color = self.bg_color;
    objc.color = self.color;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLReportReason

@end
        
@implementation TL_inputReportReasonSpam
+(TL_inputReportReasonSpam*)create {
	TL_inputReportReasonSpam* obj = [[TL_inputReportReasonSpam alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_inputReportReasonSpam *)copy {
    
    TL_inputReportReasonSpam *objc = [[TL_inputReportReasonSpam alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputReportReasonViolence
+(TL_inputReportReasonViolence*)create {
	TL_inputReportReasonViolence* obj = [[TL_inputReportReasonViolence alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_inputReportReasonViolence *)copy {
    
    TL_inputReportReasonViolence *objc = [[TL_inputReportReasonViolence alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputReportReasonPornography
+(TL_inputReportReasonPornography*)create {
	TL_inputReportReasonPornography* obj = [[TL_inputReportReasonPornography alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_inputReportReasonPornography *)copy {
    
    TL_inputReportReasonPornography *objc = [[TL_inputReportReasonPornography alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputReportReasonOther
+(TL_inputReportReasonOther*)createWithText:(NSString*)text {
	TL_inputReportReasonOther* obj = [[TL_inputReportReasonOther alloc] init];
	obj.text = text;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.text];
}
-(void)unserialize:(SerializedData*)stream {
	super.text = [stream readString];
}
        
-(TL_inputReportReasonOther *)copy {
    
    TL_inputReportReasonOther *objc = [[TL_inputReportReasonOther alloc] init];
    
    objc.text = self.text;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLUserFull

@end
        
@implementation TL_userFull
+(TL_userFull*)createWithUser:(TLUser*)user link:(TLcontacts_Link*)link profile_photo:(TLPhoto*)profile_photo notify_settings:(TLPeerNotifySettings*)notify_settings blocked:(Boolean)blocked bot_info:(TLBotInfo*)bot_info {
	TL_userFull* obj = [[TL_userFull alloc] init];
	obj.user = user;
	obj.link = link;
	obj.profile_photo = profile_photo;
	obj.notify_settings = notify_settings;
	obj.blocked = blocked;
	obj.bot_info = bot_info;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.user stream:stream];
	[ClassStore TLSerialize:self.link stream:stream];
	[ClassStore TLSerialize:self.profile_photo stream:stream];
	[ClassStore TLSerialize:self.notify_settings stream:stream];
	[stream writeBool:self.blocked];
	[ClassStore TLSerialize:self.bot_info stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.user = [ClassStore TLDeserialize:stream];
	self.link = [ClassStore TLDeserialize:stream];
	self.profile_photo = [ClassStore TLDeserialize:stream];
	self.notify_settings = [ClassStore TLDeserialize:stream];
	super.blocked = [stream readBool];
	self.bot_info = [ClassStore TLDeserialize:stream];
}
        
-(TL_userFull *)copy {
    
    TL_userFull *objc = [[TL_userFull alloc] init];
    
    objc.user = [self.user copy];
    objc.link = [self.link copy];
    objc.profile_photo = [self.profile_photo copy];
    objc.notify_settings = [self.notify_settings copy];
    objc.blocked = self.blocked;
    objc.bot_info = [self.bot_info copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.user_id = [stream readInt];
	super.mutual = [stream readBool];
}
        
-(TL_contact *)copy {
    
    TL_contact *objc = [[TL_contact alloc] init];
    
    objc.user_id = self.user_id;
    objc.mutual = self.mutual;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.user_id = [stream readInt];
	super.client_id = [stream readLong];
}
        
-(TL_importedContact *)copy {
    
    TL_importedContact *objc = [[TL_importedContact alloc] init];
    
    objc.user_id = self.user_id;
    objc.client_id = self.client_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.user_id = [stream readInt];
	super.date = [stream readInt];
}
        
-(TL_contactBlocked *)copy {
    
    TL_contactBlocked *objc = [[TL_contactBlocked alloc] init];
    
    objc.user_id = self.user_id;
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.user_id = [stream readInt];
	super.mutual_contacts = [stream readInt];
}
        
-(TL_contactSuggested *)copy {
    
    TL_contactSuggested *objc = [[TL_contactSuggested alloc] init];
    
    objc.user_id = self.user_id;
    objc.mutual_contacts = self.mutual_contacts;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.status stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.user_id = [stream readInt];
	self.status = [ClassStore TLDeserialize:stream];
}
        
-(TL_contactStatus *)copy {
    
    TL_contactStatus *objc = [[TL_contactStatus alloc] init];
    
    objc.user_id = self.user_id;
    objc.status = [self.status copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLcontacts_Link

@end
        
@implementation TL_contacts_link
+(TL_contacts_link*)createWithMy_link:(TLContactLink*)my_link foreign_link:(TLContactLink*)foreign_link user:(TLUser*)user {
	TL_contacts_link* obj = [[TL_contacts_link alloc] init];
	obj.my_link = my_link;
	obj.foreign_link = foreign_link;
	obj.user = user;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.my_link stream:stream];
	[ClassStore TLSerialize:self.foreign_link stream:stream];
	[ClassStore TLSerialize:self.user stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.my_link = [ClassStore TLDeserialize:stream];
	self.foreign_link = [ClassStore TLDeserialize:stream];
	self.user = [ClassStore TLDeserialize:stream];
}
        
-(TL_contacts_link *)copy {
    
    TL_contacts_link *objc = [[TL_contacts_link alloc] init];
    
    objc.my_link = [self.my_link copy];
    objc.foreign_link = [self.foreign_link copy];
    objc.user = [self.user copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLcontacts_Contacts

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
        
-(TL_contacts_contactsNotModified *)copy {
    
    TL_contacts_contactsNotModified *objc = [[TL_contacts_contactsNotModified alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
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
			TLContact* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLContact class]])
                 [self.contacts addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_contacts_contacts *)copy {
    
    TL_contacts_contacts *objc = [[TL_contacts_contacts alloc] init];
    
    objc.contacts = [self.contacts copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.retry_contacts count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.retry_contacts count] > i) {
                NSNumber* obj = [self.retry_contacts objectAtIndex:i];
			[stream writeLong:[obj longValue]];
            }  else
                break;
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
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
			TLImportedContact* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLImportedContact class]])
                 [self.imported addObject:obj];
            else
                break;
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
			[self.retry_contacts addObject:@(obj)];
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_contacts_importedContacts *)copy {
    
    TL_contacts_importedContacts *objc = [[TL_contacts_importedContacts alloc] init];
    
    objc.imported = [self.imported copy];
    objc.retry_contacts = [self.retry_contacts copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
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
			TLContactBlocked* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLContactBlocked class]])
                 [self.blocked addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_contacts_blocked *)copy {
    
    TL_contacts_blocked *objc = [[TL_contacts_blocked alloc] init];
    
    objc.blocked = [self.blocked copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.blocked)
			self.blocked = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLContactBlocked* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLContactBlocked class]])
                 [self.blocked addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_contacts_blockedSlice *)copy {
    
    TL_contacts_blockedSlice *objc = [[TL_contacts_blockedSlice alloc] init];
    
    objc.n_count = self.n_count;
    objc.blocked = [self.blocked copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
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
			TLContactSuggested* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLContactSuggested class]])
                 [self.results addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_contacts_suggested *)copy {
    
    TL_contacts_suggested *objc = [[TL_contacts_suggested alloc] init];
    
    objc.results = [self.results copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLMessage* obj = [self.messages objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChat* obj = [self.chats objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
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
			TLDialog* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLDialog class]])
                 [self.dialogs addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessage* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLMessage class]])
                 [self.messages addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChat class]])
                 [self.chats addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_messages_dialogs *)copy {
    
    TL_messages_dialogs *objc = [[TL_messages_dialogs alloc] init];
    
    objc.dialogs = [self.dialogs copy];
    objc.messages = [self.messages copy];
    objc.chats = [self.chats copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLMessage* obj = [self.messages objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChat* obj = [self.chats objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.dialogs)
			self.dialogs = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLDialog* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLDialog class]])
                 [self.dialogs addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessage* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLMessage class]])
                 [self.messages addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChat class]])
                 [self.chats addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_messages_dialogsSlice *)copy {
    
    TL_messages_dialogsSlice *objc = [[TL_messages_dialogsSlice alloc] init];
    
    objc.n_count = self.n_count;
    objc.dialogs = [self.dialogs copy];
    objc.messages = [self.messages copy];
    objc.chats = [self.chats copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChat* obj = [self.chats objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
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
			TLMessage* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLMessage class]])
                 [self.messages addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChat class]])
                 [self.chats addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_messages_messages *)copy {
    
    TL_messages_messages *objc = [[TL_messages_messages alloc] init];
    
    objc.messages = [self.messages copy];
    objc.chats = [self.chats copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChat* obj = [self.chats objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessage* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLMessage class]])
                 [self.messages addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChat class]])
                 [self.chats addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_messages_messagesSlice *)copy {
    
    TL_messages_messagesSlice *objc = [[TL_messages_messagesSlice alloc] init];
    
    objc.n_count = self.n_count;
    objc.messages = [self.messages copy];
    objc.chats = [self.chats copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messages_channelMessages
+(TL_messages_channelMessages*)createWithFlags:(int)flags pts:(int)pts n_count:(int)n_count messages:(NSMutableArray*)messages collapsed:(NSMutableArray*)collapsed chats:(NSMutableArray*)chats users:(NSMutableArray*)users {
	TL_messages_channelMessages* obj = [[TL_messages_channelMessages alloc] init];
	obj.flags = flags;
	obj.pts = pts;
	obj.n_count = n_count;
	obj.messages = messages;
	obj.collapsed = collapsed;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	[stream writeInt:self.pts];
	[stream writeInt:self.n_count];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLMessage* obj = [self.messages objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	if(self.flags & (1 << 0)) {//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.collapsed count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLMessageGroup* obj = [self.collapsed objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChat* obj = [self.chats objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	super.pts = [stream readInt];
	super.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessage* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLMessage class]])
                 [self.messages addObject:obj];
            else
                break;
		}
	}
	if(self.flags & (1 << 0)) {//UNS FullVector
	[stream readInt];
	{
		if(!self.collapsed)
			self.collapsed = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessageGroup* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLMessageGroup class]])
                 [self.collapsed addObject:obj];
            else
                break;
		}
	}}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChat class]])
                 [self.chats addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_messages_channelMessages *)copy {
    
    TL_messages_channelMessages *objc = [[TL_messages_channelMessages alloc] init];
    
    objc.flags = self.flags;
    objc.pts = self.pts;
    objc.n_count = self.n_count;
    objc.messages = [self.messages copy];
    objc.collapsed = [self.collapsed copy];
    objc.chats = [self.chats copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(void)setCollapsed:(NSMutableArray*)collapsed
{
   super.collapsed = collapsed;
                
    if(super.collapsed == nil)  { super.flags&= ~ (1 << 0) ;} else { super.flags|= (1 << 0); }
}
        
@end

@implementation TLmessages_Chats

@end
        
@implementation TL_messages_chats
+(TL_messages_chats*)createWithChats:(NSMutableArray*)chats {
	TL_messages_chats* obj = [[TL_messages_chats alloc] init];
	obj.chats = chats;
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
            [ClassStore TLSerialize:obj stream:stream];
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
			TLChat* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChat class]])
                 [self.chats addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_messages_chats *)copy {
    
    TL_messages_chats *objc = [[TL_messages_chats alloc] init];
    
    objc.chats = [self.chats copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.full_chat stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChat* obj = [self.chats objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.full_chat = [ClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChat class]])
                 [self.chats addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_messages_chatFull *)copy {
    
    TL_messages_chatFull *objc = [[TL_messages_chatFull alloc] init];
    
    objc.full_chat = [self.full_chat copy];
    objc.chats = [self.chats copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLmessages_AffectedHistory

@end
        
@implementation TL_messages_affectedHistory
+(TL_messages_affectedHistory*)createWithPts:(int)pts pts_count:(int)pts_count offset:(int)offset {
	TL_messages_affectedHistory* obj = [[TL_messages_affectedHistory alloc] init];
	obj.pts = pts;
	obj.pts_count = pts_count;
	obj.offset = offset;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.pts];
	[stream writeInt:self.pts_count];
	[stream writeInt:self.offset];
}
-(void)unserialize:(SerializedData*)stream {
	super.pts = [stream readInt];
	super.pts_count = [stream readInt];
	super.offset = [stream readInt];
}
        
-(TL_messages_affectedHistory *)copy {
    
    TL_messages_affectedHistory *objc = [[TL_messages_affectedHistory alloc] init];
    
    objc.pts = self.pts;
    objc.pts_count = self.pts_count;
    objc.offset = self.offset;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputMessagesFilterEmpty *)copy {
    
    TL_inputMessagesFilterEmpty *objc = [[TL_inputMessagesFilterEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputMessagesFilterPhotos *)copy {
    
    TL_inputMessagesFilterPhotos *objc = [[TL_inputMessagesFilterPhotos alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputMessagesFilterVideo *)copy {
    
    TL_inputMessagesFilterVideo *objc = [[TL_inputMessagesFilterVideo alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputMessagesFilterPhotoVideo *)copy {
    
    TL_inputMessagesFilterPhotoVideo *objc = [[TL_inputMessagesFilterPhotoVideo alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputMessagesFilterPhotoVideoDocuments
+(TL_inputMessagesFilterPhotoVideoDocuments*)create {
	TL_inputMessagesFilterPhotoVideoDocuments* obj = [[TL_inputMessagesFilterPhotoVideoDocuments alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_inputMessagesFilterPhotoVideoDocuments *)copy {
    
    TL_inputMessagesFilterPhotoVideoDocuments *objc = [[TL_inputMessagesFilterPhotoVideoDocuments alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputMessagesFilterDocument *)copy {
    
    TL_inputMessagesFilterDocument *objc = [[TL_inputMessagesFilterDocument alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputMessagesFilterAudio *)copy {
    
    TL_inputMessagesFilterAudio *objc = [[TL_inputMessagesFilterAudio alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputMessagesFilterAudioDocuments
+(TL_inputMessagesFilterAudioDocuments*)create {
	TL_inputMessagesFilterAudioDocuments* obj = [[TL_inputMessagesFilterAudioDocuments alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_inputMessagesFilterAudioDocuments *)copy {
    
    TL_inputMessagesFilterAudioDocuments *objc = [[TL_inputMessagesFilterAudioDocuments alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputMessagesFilterUrl
+(TL_inputMessagesFilterUrl*)create {
	TL_inputMessagesFilterUrl* obj = [[TL_inputMessagesFilterUrl alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_inputMessagesFilterUrl *)copy {
    
    TL_inputMessagesFilterUrl *objc = [[TL_inputMessagesFilterUrl alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLUpdate

@end
        
@implementation TL_updateNewMessage
+(TL_updateNewMessage*)createWithMessage:(TLMessage*)message pts:(int)pts pts_count:(int)pts_count {
	TL_updateNewMessage* obj = [[TL_updateNewMessage alloc] init];
	obj.message = message;
	obj.pts = pts;
	obj.pts_count = pts_count;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.message stream:stream];
	[stream writeInt:self.pts];
	[stream writeInt:self.pts_count];
}
-(void)unserialize:(SerializedData*)stream {
	self.message = [ClassStore TLDeserialize:stream];
	super.pts = [stream readInt];
	super.pts_count = [stream readInt];
}
        
-(TL_updateNewMessage *)copy {
    
    TL_updateNewMessage *objc = [[TL_updateNewMessage alloc] init];
    
    objc.message = [self.message copy];
    objc.pts = self.pts;
    objc.pts_count = self.pts_count;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readInt];
	super.random_id = [stream readLong];
}
        
-(TL_updateMessageID *)copy {
    
    TL_updateMessageID *objc = [[TL_updateMessageID alloc] init];
    
    objc.n_id = self.n_id;
    objc.random_id = self.random_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateDeleteMessages
+(TL_updateDeleteMessages*)createWithMessages:(NSMutableArray*)messages pts:(int)pts pts_count:(int)pts_count {
	TL_updateDeleteMessages* obj = [[TL_updateDeleteMessages alloc] init];
	obj.messages = messages;
	obj.pts = pts;
	obj.pts_count = pts_count;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.messages count] > i) {
                NSNumber* obj = [self.messages objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
		}
	}
	[stream writeInt:self.pts];
	[stream writeInt:self.pts_count];
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
			[self.messages addObject:@(obj)];
		}
	}
	super.pts = [stream readInt];
	super.pts_count = [stream readInt];
}
        
-(TL_updateDeleteMessages *)copy {
    
    TL_updateDeleteMessages *objc = [[TL_updateDeleteMessages alloc] init];
    
    objc.messages = [self.messages copy];
    objc.pts = self.pts;
    objc.pts_count = self.pts_count;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.action stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.user_id = [stream readInt];
	self.action = [ClassStore TLDeserialize:stream];
}
        
-(TL_updateUserTyping *)copy {
    
    TL_updateUserTyping *objc = [[TL_updateUserTyping alloc] init];
    
    objc.user_id = self.user_id;
    objc.action = [self.action copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.action stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.chat_id = [stream readInt];
	super.user_id = [stream readInt];
	self.action = [ClassStore TLDeserialize:stream];
}
        
-(TL_updateChatUserTyping *)copy {
    
    TL_updateChatUserTyping *objc = [[TL_updateChatUserTyping alloc] init];
    
    objc.chat_id = self.chat_id;
    objc.user_id = self.user_id;
    objc.action = [self.action copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateChatParticipants
+(TL_updateChatParticipants*)createWithParticipants:(TLChatParticipants*)participants {
	TL_updateChatParticipants* obj = [[TL_updateChatParticipants alloc] init];
	obj.participants = participants;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.participants stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.participants = [ClassStore TLDeserialize:stream];
}
        
-(TL_updateChatParticipants *)copy {
    
    TL_updateChatParticipants *objc = [[TL_updateChatParticipants alloc] init];
    
    objc.participants = [self.participants copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.status stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.user_id = [stream readInt];
	self.status = [ClassStore TLDeserialize:stream];
}
        
-(TL_updateUserStatus *)copy {
    
    TL_updateUserStatus *objc = [[TL_updateUserStatus alloc] init];
    
    objc.user_id = self.user_id;
    objc.status = [self.status copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.user_id = [stream readInt];
	super.first_name = [stream readString];
	super.last_name = [stream readString];
	super.username = [stream readString];
}
        
-(TL_updateUserName *)copy {
    
    TL_updateUserName *objc = [[TL_updateUserName alloc] init];
    
    objc.user_id = self.user_id;
    objc.first_name = self.first_name;
    objc.last_name = self.last_name;
    objc.username = self.username;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.photo stream:stream];
	[stream writeBool:self.previous];
}
-(void)unserialize:(SerializedData*)stream {
	super.user_id = [stream readInt];
	super.date = [stream readInt];
	self.photo = [ClassStore TLDeserialize:stream];
	super.previous = [stream readBool];
}
        
-(TL_updateUserPhoto *)copy {
    
    TL_updateUserPhoto *objc = [[TL_updateUserPhoto alloc] init];
    
    objc.user_id = self.user_id;
    objc.date = self.date;
    objc.photo = [self.photo copy];
    objc.previous = self.previous;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.user_id = [stream readInt];
	super.date = [stream readInt];
}
        
-(TL_updateContactRegistered *)copy {
    
    TL_updateContactRegistered *objc = [[TL_updateContactRegistered alloc] init];
    
    objc.user_id = self.user_id;
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateContactLink
+(TL_updateContactLink*)createWithUser_id:(int)user_id my_link:(TLContactLink*)my_link foreign_link:(TLContactLink*)foreign_link {
	TL_updateContactLink* obj = [[TL_updateContactLink alloc] init];
	obj.user_id = user_id;
	obj.my_link = my_link;
	obj.foreign_link = foreign_link;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[ClassStore TLSerialize:self.my_link stream:stream];
	[ClassStore TLSerialize:self.foreign_link stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.user_id = [stream readInt];
	self.my_link = [ClassStore TLDeserialize:stream];
	self.foreign_link = [ClassStore TLDeserialize:stream];
}
        
-(TL_updateContactLink *)copy {
    
    TL_updateContactLink *objc = [[TL_updateContactLink alloc] init];
    
    objc.user_id = self.user_id;
    objc.my_link = [self.my_link copy];
    objc.foreign_link = [self.foreign_link copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.auth_key_id = [stream readLong];
	super.date = [stream readInt];
	super.device = [stream readString];
	super.location = [stream readString];
}
        
-(TL_updateNewAuthorization *)copy {
    
    TL_updateNewAuthorization *objc = [[TL_updateNewAuthorization alloc] init];
    
    objc.auth_key_id = self.auth_key_id;
    objc.date = self.date;
    objc.device = self.device;
    objc.location = self.location;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.message stream:stream];
	[stream writeInt:self.qts];
}
-(void)unserialize:(SerializedData*)stream {
	self.message = [ClassStore TLDeserialize:stream];
	super.qts = [stream readInt];
}
        
-(TL_updateNewEncryptedMessage *)copy {
    
    TL_updateNewEncryptedMessage *objc = [[TL_updateNewEncryptedMessage alloc] init];
    
    objc.message = [self.message copy];
    objc.qts = self.qts;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.chat_id = [stream readInt];
}
        
-(TL_updateEncryptedChatTyping *)copy {
    
    TL_updateEncryptedChatTyping *objc = [[TL_updateEncryptedChatTyping alloc] init];
    
    objc.chat_id = self.chat_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.chat stream:stream];
	[stream writeInt:self.date];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat = [ClassStore TLDeserialize:stream];
	super.date = [stream readInt];
}
        
-(TL_updateEncryption *)copy {
    
    TL_updateEncryption *objc = [[TL_updateEncryption alloc] init];
    
    objc.chat = [self.chat copy];
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.chat_id = [stream readInt];
	super.max_date = [stream readInt];
	super.date = [stream readInt];
}
        
-(TL_updateEncryptedMessagesRead *)copy {
    
    TL_updateEncryptedMessagesRead *objc = [[TL_updateEncryptedMessagesRead alloc] init];
    
    objc.chat_id = self.chat_id;
    objc.max_date = self.max_date;
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateChatParticipantAdd
+(TL_updateChatParticipantAdd*)createWithChat_id:(int)chat_id user_id:(int)user_id inviter_id:(int)inviter_id date:(int)date version:(int)version {
	TL_updateChatParticipantAdd* obj = [[TL_updateChatParticipantAdd alloc] init];
	obj.chat_id = chat_id;
	obj.user_id = user_id;
	obj.inviter_id = inviter_id;
	obj.date = date;
	obj.version = version;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.user_id];
	[stream writeInt:self.inviter_id];
	[stream writeInt:self.date];
	[stream writeInt:self.version];
}
-(void)unserialize:(SerializedData*)stream {
	super.chat_id = [stream readInt];
	super.user_id = [stream readInt];
	super.inviter_id = [stream readInt];
	super.date = [stream readInt];
	super.version = [stream readInt];
}
        
-(TL_updateChatParticipantAdd *)copy {
    
    TL_updateChatParticipantAdd *objc = [[TL_updateChatParticipantAdd alloc] init];
    
    objc.chat_id = self.chat_id;
    objc.user_id = self.user_id;
    objc.inviter_id = self.inviter_id;
    objc.date = self.date;
    objc.version = self.version;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.chat_id = [stream readInt];
	super.user_id = [stream readInt];
	super.version = [stream readInt];
}
        
-(TL_updateChatParticipantDelete *)copy {
    
    TL_updateChatParticipantDelete *objc = [[TL_updateChatParticipantDelete alloc] init];
    
    objc.chat_id = self.chat_id;
    objc.user_id = self.user_id;
    objc.version = self.version;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
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
			TLDcOption* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLDcOption class]])
                 [self.dc_options addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_updateDcOptions *)copy {
    
    TL_updateDcOptions *objc = [[TL_updateDcOptions alloc] init];
    
    objc.dc_options = [self.dc_options copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.user_id = [stream readInt];
	super.blocked = [stream readBool];
}
        
-(TL_updateUserBlocked *)copy {
    
    TL_updateUserBlocked *objc = [[TL_updateUserBlocked alloc] init];
    
    objc.user_id = self.user_id;
    objc.blocked = self.blocked;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.peer stream:stream];
	[ClassStore TLSerialize:self.notify_settings stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.peer = [ClassStore TLDeserialize:stream];
	self.notify_settings = [ClassStore TLDeserialize:stream];
}
        
-(TL_updateNotifySettings *)copy {
    
    TL_updateNotifySettings *objc = [[TL_updateNotifySettings alloc] init];
    
    objc.peer = [self.peer copy];
    objc.notify_settings = [self.notify_settings copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.media stream:stream];
	[stream writeBool:self.popup];
}
-(void)unserialize:(SerializedData*)stream {
	super.type = [stream readString];
	super.message = [stream readString];
	self.media = [ClassStore TLDeserialize:stream];
	super.popup = [stream readBool];
}
        
-(TL_updateServiceNotification *)copy {
    
    TL_updateServiceNotification *objc = [[TL_updateServiceNotification alloc] init];
    
    objc.type = self.type;
    objc.message = self.message;
    objc.media = [self.media copy];
    objc.popup = self.popup;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.n_key stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.rules count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLPrivacyRule* obj = [self.rules objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.n_key = [ClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.rules)
			self.rules = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLPrivacyRule* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLPrivacyRule class]])
                 [self.rules addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_updatePrivacy *)copy {
    
    TL_updatePrivacy *objc = [[TL_updatePrivacy alloc] init];
    
    objc.n_key = [self.n_key copy];
    objc.rules = [self.rules copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.user_id = [stream readInt];
	super.phone = [stream readString];
}
        
-(TL_updateUserPhone *)copy {
    
    TL_updateUserPhone *objc = [[TL_updateUserPhone alloc] init];
    
    objc.user_id = self.user_id;
    objc.phone = self.phone;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateReadHistoryInbox
+(TL_updateReadHistoryInbox*)createWithPeer:(TLPeer*)peer max_id:(int)max_id pts:(int)pts pts_count:(int)pts_count {
	TL_updateReadHistoryInbox* obj = [[TL_updateReadHistoryInbox alloc] init];
	obj.peer = peer;
	obj.max_id = max_id;
	obj.pts = pts;
	obj.pts_count = pts_count;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeInt:self.max_id];
	[stream writeInt:self.pts];
	[stream writeInt:self.pts_count];
}
-(void)unserialize:(SerializedData*)stream {
	self.peer = [ClassStore TLDeserialize:stream];
	super.max_id = [stream readInt];
	super.pts = [stream readInt];
	super.pts_count = [stream readInt];
}
        
-(TL_updateReadHistoryInbox *)copy {
    
    TL_updateReadHistoryInbox *objc = [[TL_updateReadHistoryInbox alloc] init];
    
    objc.peer = [self.peer copy];
    objc.max_id = self.max_id;
    objc.pts = self.pts;
    objc.pts_count = self.pts_count;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateReadHistoryOutbox
+(TL_updateReadHistoryOutbox*)createWithPeer:(TLPeer*)peer max_id:(int)max_id pts:(int)pts pts_count:(int)pts_count {
	TL_updateReadHistoryOutbox* obj = [[TL_updateReadHistoryOutbox alloc] init];
	obj.peer = peer;
	obj.max_id = max_id;
	obj.pts = pts;
	obj.pts_count = pts_count;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.peer stream:stream];
	[stream writeInt:self.max_id];
	[stream writeInt:self.pts];
	[stream writeInt:self.pts_count];
}
-(void)unserialize:(SerializedData*)stream {
	self.peer = [ClassStore TLDeserialize:stream];
	super.max_id = [stream readInt];
	super.pts = [stream readInt];
	super.pts_count = [stream readInt];
}
        
-(TL_updateReadHistoryOutbox *)copy {
    
    TL_updateReadHistoryOutbox *objc = [[TL_updateReadHistoryOutbox alloc] init];
    
    objc.peer = [self.peer copy];
    objc.max_id = self.max_id;
    objc.pts = self.pts;
    objc.pts_count = self.pts_count;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateWebPage
+(TL_updateWebPage*)createWithWebpage:(TLWebPage*)webpage pts:(int)pts pts_count:(int)pts_count {
	TL_updateWebPage* obj = [[TL_updateWebPage alloc] init];
	obj.webpage = webpage;
	obj.pts = pts;
	obj.pts_count = pts_count;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.webpage stream:stream];
	[stream writeInt:self.pts];
	[stream writeInt:self.pts_count];
}
-(void)unserialize:(SerializedData*)stream {
	self.webpage = [ClassStore TLDeserialize:stream];
	super.pts = [stream readInt];
	super.pts_count = [stream readInt];
}
        
-(TL_updateWebPage *)copy {
    
    TL_updateWebPage *objc = [[TL_updateWebPage alloc] init];
    
    objc.webpage = [self.webpage copy];
    objc.pts = self.pts;
    objc.pts_count = self.pts_count;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateReadMessagesContents
+(TL_updateReadMessagesContents*)createWithMessages:(NSMutableArray*)messages pts:(int)pts pts_count:(int)pts_count {
	TL_updateReadMessagesContents* obj = [[TL_updateReadMessagesContents alloc] init];
	obj.messages = messages;
	obj.pts = pts;
	obj.pts_count = pts_count;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.messages count] > i) {
                NSNumber* obj = [self.messages objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
		}
	}
	[stream writeInt:self.pts];
	[stream writeInt:self.pts_count];
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
			[self.messages addObject:@(obj)];
		}
	}
	super.pts = [stream readInt];
	super.pts_count = [stream readInt];
}
        
-(TL_updateReadMessagesContents *)copy {
    
    TL_updateReadMessagesContents *objc = [[TL_updateReadMessagesContents alloc] init];
    
    objc.messages = [self.messages copy];
    objc.pts = self.pts;
    objc.pts_count = self.pts_count;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateChannelTooLong
+(TL_updateChannelTooLong*)createWithChannel_id:(int)channel_id {
	TL_updateChannelTooLong* obj = [[TL_updateChannelTooLong alloc] init];
	obj.channel_id = channel_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.channel_id];
}
-(void)unserialize:(SerializedData*)stream {
	super.channel_id = [stream readInt];
}
        
-(TL_updateChannelTooLong *)copy {
    
    TL_updateChannelTooLong *objc = [[TL_updateChannelTooLong alloc] init];
    
    objc.channel_id = self.channel_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateChannel
+(TL_updateChannel*)createWithChannel_id:(int)channel_id {
	TL_updateChannel* obj = [[TL_updateChannel alloc] init];
	obj.channel_id = channel_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.channel_id];
}
-(void)unserialize:(SerializedData*)stream {
	super.channel_id = [stream readInt];
}
        
-(TL_updateChannel *)copy {
    
    TL_updateChannel *objc = [[TL_updateChannel alloc] init];
    
    objc.channel_id = self.channel_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateChannelGroup
+(TL_updateChannelGroup*)createWithChannel_id:(int)channel_id group:(TLMessageGroup*)group {
	TL_updateChannelGroup* obj = [[TL_updateChannelGroup alloc] init];
	obj.channel_id = channel_id;
	obj.group = group;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.channel_id];
	[ClassStore TLSerialize:self.group stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.channel_id = [stream readInt];
	self.group = [ClassStore TLDeserialize:stream];
}
        
-(TL_updateChannelGroup *)copy {
    
    TL_updateChannelGroup *objc = [[TL_updateChannelGroup alloc] init];
    
    objc.channel_id = self.channel_id;
    objc.group = [self.group copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateNewChannelMessage
+(TL_updateNewChannelMessage*)createWithMessage:(TLMessage*)message pts:(int)pts pts_count:(int)pts_count {
	TL_updateNewChannelMessage* obj = [[TL_updateNewChannelMessage alloc] init];
	obj.message = message;
	obj.pts = pts;
	obj.pts_count = pts_count;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.message stream:stream];
	[stream writeInt:self.pts];
	[stream writeInt:self.pts_count];
}
-(void)unserialize:(SerializedData*)stream {
	self.message = [ClassStore TLDeserialize:stream];
	super.pts = [stream readInt];
	super.pts_count = [stream readInt];
}
        
-(TL_updateNewChannelMessage *)copy {
    
    TL_updateNewChannelMessage *objc = [[TL_updateNewChannelMessage alloc] init];
    
    objc.message = [self.message copy];
    objc.pts = self.pts;
    objc.pts_count = self.pts_count;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateReadChannelInbox
+(TL_updateReadChannelInbox*)createWithChannel_id:(int)channel_id max_id:(int)max_id {
	TL_updateReadChannelInbox* obj = [[TL_updateReadChannelInbox alloc] init];
	obj.channel_id = channel_id;
	obj.max_id = max_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.channel_id];
	[stream writeInt:self.max_id];
}
-(void)unserialize:(SerializedData*)stream {
	super.channel_id = [stream readInt];
	super.max_id = [stream readInt];
}
        
-(TL_updateReadChannelInbox *)copy {
    
    TL_updateReadChannelInbox *objc = [[TL_updateReadChannelInbox alloc] init];
    
    objc.channel_id = self.channel_id;
    objc.max_id = self.max_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateDeleteChannelMessages
+(TL_updateDeleteChannelMessages*)createWithChannel_id:(int)channel_id messages:(NSMutableArray*)messages pts:(int)pts pts_count:(int)pts_count {
	TL_updateDeleteChannelMessages* obj = [[TL_updateDeleteChannelMessages alloc] init];
	obj.channel_id = channel_id;
	obj.messages = messages;
	obj.pts = pts;
	obj.pts_count = pts_count;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.channel_id];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.messages count] > i) {
                NSNumber* obj = [self.messages objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
		}
	}
	[stream writeInt:self.pts];
	[stream writeInt:self.pts_count];
}
-(void)unserialize:(SerializedData*)stream {
	super.channel_id = [stream readInt];
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			int obj = [stream readInt];
			[self.messages addObject:@(obj)];
		}
	}
	super.pts = [stream readInt];
	super.pts_count = [stream readInt];
}
        
-(TL_updateDeleteChannelMessages *)copy {
    
    TL_updateDeleteChannelMessages *objc = [[TL_updateDeleteChannelMessages alloc] init];
    
    objc.channel_id = self.channel_id;
    objc.messages = [self.messages copy];
    objc.pts = self.pts;
    objc.pts_count = self.pts_count;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateChannelMessageViews
+(TL_updateChannelMessageViews*)createWithChannel_id:(int)channel_id n_id:(int)n_id views:(int)views {
	TL_updateChannelMessageViews* obj = [[TL_updateChannelMessageViews alloc] init];
	obj.channel_id = channel_id;
	obj.n_id = n_id;
	obj.views = views;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.channel_id];
	[stream writeInt:self.n_id];
	[stream writeInt:self.views];
}
-(void)unserialize:(SerializedData*)stream {
	super.channel_id = [stream readInt];
	super.n_id = [stream readInt];
	super.views = [stream readInt];
}
        
-(TL_updateChannelMessageViews *)copy {
    
    TL_updateChannelMessageViews *objc = [[TL_updateChannelMessageViews alloc] init];
    
    objc.channel_id = self.channel_id;
    objc.n_id = self.n_id;
    objc.views = self.views;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateChatAdmins
+(TL_updateChatAdmins*)createWithChat_id:(int)chat_id enabled:(Boolean)enabled version:(int)version {
	TL_updateChatAdmins* obj = [[TL_updateChatAdmins alloc] init];
	obj.chat_id = chat_id;
	obj.enabled = enabled;
	obj.version = version;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
	[stream writeBool:self.enabled];
	[stream writeInt:self.version];
}
-(void)unserialize:(SerializedData*)stream {
	super.chat_id = [stream readInt];
	super.enabled = [stream readBool];
	super.version = [stream readInt];
}
        
-(TL_updateChatAdmins *)copy {
    
    TL_updateChatAdmins *objc = [[TL_updateChatAdmins alloc] init];
    
    objc.chat_id = self.chat_id;
    objc.enabled = self.enabled;
    objc.version = self.version;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateChatParticipantAdmin
+(TL_updateChatParticipantAdmin*)createWithChat_id:(int)chat_id user_id:(int)user_id is_admin:(Boolean)is_admin version:(int)version {
	TL_updateChatParticipantAdmin* obj = [[TL_updateChatParticipantAdmin alloc] init];
	obj.chat_id = chat_id;
	obj.user_id = user_id;
	obj.is_admin = is_admin;
	obj.version = version;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.chat_id];
	[stream writeInt:self.user_id];
	[stream writeBool:self.is_admin];
	[stream writeInt:self.version];
}
-(void)unserialize:(SerializedData*)stream {
	super.chat_id = [stream readInt];
	super.user_id = [stream readInt];
	super.is_admin = [stream readBool];
	super.version = [stream readInt];
}
        
-(TL_updateChatParticipantAdmin *)copy {
    
    TL_updateChatParticipantAdmin *objc = [[TL_updateChatParticipantAdmin alloc] init];
    
    objc.chat_id = self.chat_id;
    objc.user_id = self.user_id;
    objc.is_admin = self.is_admin;
    objc.version = self.version;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateNewStickerSet
+(TL_updateNewStickerSet*)createWithStickerset:(TLmessages_StickerSet*)stickerset {
	TL_updateNewStickerSet* obj = [[TL_updateNewStickerSet alloc] init];
	obj.stickerset = stickerset;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.stickerset stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.stickerset = [ClassStore TLDeserialize:stream];
}
        
-(TL_updateNewStickerSet *)copy {
    
    TL_updateNewStickerSet *objc = [[TL_updateNewStickerSet alloc] init];
    
    objc.stickerset = [self.stickerset copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateStickerSetsOrder
+(TL_updateStickerSetsOrder*)createWithOrder:(NSMutableArray*)order {
	TL_updateStickerSetsOrder* obj = [[TL_updateStickerSetsOrder alloc] init];
	obj.order = order;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
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
}
-(void)unserialize:(SerializedData*)stream {
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.order)
			self.order = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			long obj = [stream readLong];
			[self.order addObject:@(obj)];
		}
	}
}
        
-(TL_updateStickerSetsOrder *)copy {
    
    TL_updateStickerSetsOrder *objc = [[TL_updateStickerSetsOrder alloc] init];
    
    objc.order = [self.order copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateStickerSets
+(TL_updateStickerSets*)create {
	TL_updateStickerSets* obj = [[TL_updateStickerSets alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_updateStickerSets *)copy {
    
    TL_updateStickerSets *objc = [[TL_updateStickerSets alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.pts = [stream readInt];
	super.qts = [stream readInt];
	super.date = [stream readInt];
	super.seq = [stream readInt];
	super.unread_count = [stream readInt];
}
        
-(TL_updates_state *)copy {
    
    TL_updates_state *objc = [[TL_updates_state alloc] init];
    
    objc.pts = self.pts;
    objc.qts = self.qts;
    objc.date = self.date;
    objc.seq = self.seq;
    objc.unread_count = self.unread_count;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.date = [stream readInt];
	super.seq = [stream readInt];
}
        
-(TL_updates_differenceEmpty *)copy {
    
    TL_updates_differenceEmpty *objc = [[TL_updates_differenceEmpty alloc] init];
    
    objc.date = self.date;
    objc.seq = self.seq;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_encrypted_messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLEncryptedMessage* obj = [self.n_encrypted_messages objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.other_updates count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUpdate* obj = [self.other_updates objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChat* obj = [self.chats objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	[ClassStore TLSerialize:self.state stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.n_messages)
			self.n_messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessage* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLMessage class]])
                 [self.n_messages addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.n_encrypted_messages)
			self.n_encrypted_messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLEncryptedMessage* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLEncryptedMessage class]])
                 [self.n_encrypted_messages addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.other_updates)
			self.other_updates = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUpdate* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUpdate class]])
                 [self.other_updates addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChat class]])
                 [self.chats addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
	self.state = [ClassStore TLDeserialize:stream];
}
        
-(TL_updates_difference *)copy {
    
    TL_updates_difference *objc = [[TL_updates_difference alloc] init];
    
    objc.n_messages = [self.n_messages copy];
    objc.n_encrypted_messages = [self.n_encrypted_messages copy];
    objc.other_updates = [self.other_updates copy];
    objc.chats = [self.chats copy];
    objc.users = [self.users copy];
    objc.state = [self.state copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_encrypted_messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLEncryptedMessage* obj = [self.n_encrypted_messages objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.other_updates count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUpdate* obj = [self.other_updates objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChat* obj = [self.chats objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	[ClassStore TLSerialize:self.intermediate_state stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.n_messages)
			self.n_messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessage* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLMessage class]])
                 [self.n_messages addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.n_encrypted_messages)
			self.n_encrypted_messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLEncryptedMessage* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLEncryptedMessage class]])
                 [self.n_encrypted_messages addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.other_updates)
			self.other_updates = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUpdate* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUpdate class]])
                 [self.other_updates addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChat class]])
                 [self.chats addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
	self.intermediate_state = [ClassStore TLDeserialize:stream];
}
        
-(TL_updates_differenceSlice *)copy {
    
    TL_updates_differenceSlice *objc = [[TL_updates_differenceSlice alloc] init];
    
    objc.n_messages = [self.n_messages copy];
    objc.n_encrypted_messages = [self.n_encrypted_messages copy];
    objc.other_updates = [self.other_updates copy];
    objc.chats = [self.chats copy];
    objc.users = [self.users copy];
    objc.intermediate_state = [self.intermediate_state copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLUpdates
            
-(BOOL)isUnread {return NO;}
                        
-(BOOL)isN_out {return NO;}
                        
-(BOOL)isMentioned {return NO;}
                        
-(BOOL)isMedia_unread {return NO;}
            
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
        
-(TL_updatesTooLong *)copy {
    
    TL_updatesTooLong *objc = [[TL_updatesTooLong alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateShortMessage
+(TL_updateShortMessage*)createWithFlags:(int)flags     n_id:(int)n_id user_id:(int)user_id message:(NSString*)message pts:(int)pts pts_count:(int)pts_count date:(int)date fwd_from_id:(TLPeer*)fwd_from_id fwd_date:(int)fwd_date reply_to_msg_id:(int)reply_to_msg_id entities:(NSMutableArray*)entities {
	TL_updateShortMessage* obj = [[TL_updateShortMessage alloc] init];
	obj.flags = flags;
	
	
	
	
	obj.n_id = n_id;
	obj.user_id = user_id;
	obj.message = message;
	obj.pts = pts;
	obj.pts_count = pts_count;
	obj.date = date;
	obj.fwd_from_id = fwd_from_id;
	obj.fwd_date = fwd_date;
	obj.reply_to_msg_id = reply_to_msg_id;
	obj.entities = entities;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	
	
	
	[stream writeInt:self.n_id];
	[stream writeInt:self.user_id];
	[stream writeString:self.message];
	[stream writeInt:self.pts];
	[stream writeInt:self.pts_count];
	[stream writeInt:self.date];
	if(self.flags & (1 << 2)) {[ClassStore TLSerialize:self.fwd_from_id stream:stream];}
	if(self.flags & (1 << 2)) {[stream writeInt:self.fwd_date];}
	if(self.flags & (1 << 3)) {[stream writeInt:self.reply_to_msg_id];}
	if(self.flags & (1 << 7)) {//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.entities count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLMessageEntity* obj = [self.entities objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	
	
	
	super.n_id = [stream readInt];
	super.user_id = [stream readInt];
	super.message = [stream readString];
	super.pts = [stream readInt];
	super.pts_count = [stream readInt];
	super.date = [stream readInt];
	if(self.flags & (1 << 2)) {self.fwd_from_id = [ClassStore TLDeserialize:stream];}
	if(self.flags & (1 << 2)) {super.fwd_date = [stream readInt];}
	if(self.flags & (1 << 3)) {super.reply_to_msg_id = [stream readInt];}
	if(self.flags & (1 << 7)) {//UNS FullVector
	[stream readInt];
	{
		if(!self.entities)
			self.entities = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessageEntity* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLMessageEntity class]])
                 [self.entities addObject:obj];
            else
                break;
		}
	}}
}
        
-(TL_updateShortMessage *)copy {
    
    TL_updateShortMessage *objc = [[TL_updateShortMessage alloc] init];
    
    objc.flags = self.flags;
    
    
    
    
    objc.n_id = self.n_id;
    objc.user_id = self.user_id;
    objc.message = self.message;
    objc.pts = self.pts;
    objc.pts_count = self.pts_count;
    objc.date = self.date;
    objc.fwd_from_id = [self.fwd_from_id copy];
    objc.fwd_date = self.fwd_date;
    objc.reply_to_msg_id = self.reply_to_msg_id;
    objc.entities = [self.entities copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isUnread {return (self.flags & (1 << 0)) > 0;}
                        
-(BOOL)isN_out {return (self.flags & (1 << 1)) > 0;}
                        
-(BOOL)isMentioned {return (self.flags & (1 << 4)) > 0;}
                        
-(BOOL)isMedia_unread {return (self.flags & (1 << 5)) > 0;}
                        
-(void)setFwd_from_id:(TLPeer*)fwd_from_id
{
   super.fwd_from_id = fwd_from_id;
                
    if(super.fwd_from_id == nil)  { super.flags&= ~ (1 << 2) ;} else { super.flags|= (1 << 2); }
}            
-(void)setFwd_date:(int)fwd_date
{
   super.fwd_date = fwd_date;
                
    if(super.fwd_date == 0)  { super.flags&= ~ (1 << 2) ;} else { super.flags|= (1 << 2); }
}            
-(void)setReply_to_msg_id:(int)reply_to_msg_id
{
   super.reply_to_msg_id = reply_to_msg_id;
                
    if(super.reply_to_msg_id == 0)  { super.flags&= ~ (1 << 3) ;} else { super.flags|= (1 << 3); }
}            
-(void)setEntities:(NSMutableArray*)entities
{
   super.entities = entities;
                
    if(super.entities == nil)  { super.flags&= ~ (1 << 7) ;} else { super.flags|= (1 << 7); }
}
        
@end

@implementation TL_updateShortChatMessage
+(TL_updateShortChatMessage*)createWithFlags:(int)flags     n_id:(int)n_id from_id:(int)from_id chat_id:(int)chat_id message:(NSString*)message pts:(int)pts pts_count:(int)pts_count date:(int)date fwd_from_id:(TLPeer*)fwd_from_id fwd_date:(int)fwd_date reply_to_msg_id:(int)reply_to_msg_id entities:(NSMutableArray*)entities {
	TL_updateShortChatMessage* obj = [[TL_updateShortChatMessage alloc] init];
	obj.flags = flags;
	
	
	
	
	obj.n_id = n_id;
	obj.from_id = from_id;
	obj.chat_id = chat_id;
	obj.message = message;
	obj.pts = pts;
	obj.pts_count = pts_count;
	obj.date = date;
	obj.fwd_from_id = fwd_from_id;
	obj.fwd_date = fwd_date;
	obj.reply_to_msg_id = reply_to_msg_id;
	obj.entities = entities;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	
	
	
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[stream writeInt:self.chat_id];
	[stream writeString:self.message];
	[stream writeInt:self.pts];
	[stream writeInt:self.pts_count];
	[stream writeInt:self.date];
	if(self.flags & (1 << 2)) {[ClassStore TLSerialize:self.fwd_from_id stream:stream];}
	if(self.flags & (1 << 2)) {[stream writeInt:self.fwd_date];}
	if(self.flags & (1 << 3)) {[stream writeInt:self.reply_to_msg_id];}
	if(self.flags & (1 << 7)) {//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.entities count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLMessageEntity* obj = [self.entities objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	
	
	
	super.n_id = [stream readInt];
	super.from_id = [stream readInt];
	super.chat_id = [stream readInt];
	super.message = [stream readString];
	super.pts = [stream readInt];
	super.pts_count = [stream readInt];
	super.date = [stream readInt];
	if(self.flags & (1 << 2)) {self.fwd_from_id = [ClassStore TLDeserialize:stream];}
	if(self.flags & (1 << 2)) {super.fwd_date = [stream readInt];}
	if(self.flags & (1 << 3)) {super.reply_to_msg_id = [stream readInt];}
	if(self.flags & (1 << 7)) {//UNS FullVector
	[stream readInt];
	{
		if(!self.entities)
			self.entities = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessageEntity* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLMessageEntity class]])
                 [self.entities addObject:obj];
            else
                break;
		}
	}}
}
        
-(TL_updateShortChatMessage *)copy {
    
    TL_updateShortChatMessage *objc = [[TL_updateShortChatMessage alloc] init];
    
    objc.flags = self.flags;
    
    
    
    
    objc.n_id = self.n_id;
    objc.from_id = self.from_id;
    objc.chat_id = self.chat_id;
    objc.message = self.message;
    objc.pts = self.pts;
    objc.pts_count = self.pts_count;
    objc.date = self.date;
    objc.fwd_from_id = [self.fwd_from_id copy];
    objc.fwd_date = self.fwd_date;
    objc.reply_to_msg_id = self.reply_to_msg_id;
    objc.entities = [self.entities copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isUnread {return (self.flags & (1 << 0)) > 0;}
                        
-(BOOL)isN_out {return (self.flags & (1 << 1)) > 0;}
                        
-(BOOL)isMentioned {return (self.flags & (1 << 4)) > 0;}
                        
-(BOOL)isMedia_unread {return (self.flags & (1 << 5)) > 0;}
                        
-(void)setFwd_from_id:(TLPeer*)fwd_from_id
{
   super.fwd_from_id = fwd_from_id;
                
    if(super.fwd_from_id == nil)  { super.flags&= ~ (1 << 2) ;} else { super.flags|= (1 << 2); }
}            
-(void)setFwd_date:(int)fwd_date
{
   super.fwd_date = fwd_date;
                
    if(super.fwd_date == 0)  { super.flags&= ~ (1 << 2) ;} else { super.flags|= (1 << 2); }
}            
-(void)setReply_to_msg_id:(int)reply_to_msg_id
{
   super.reply_to_msg_id = reply_to_msg_id;
                
    if(super.reply_to_msg_id == 0)  { super.flags&= ~ (1 << 3) ;} else { super.flags|= (1 << 3); }
}            
-(void)setEntities:(NSMutableArray*)entities
{
   super.entities = entities;
                
    if(super.entities == nil)  { super.flags&= ~ (1 << 7) ;} else { super.flags|= (1 << 7); }
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
	[ClassStore TLSerialize:self.update stream:stream];
	[stream writeInt:self.date];
}
-(void)unserialize:(SerializedData*)stream {
	self.update = [ClassStore TLDeserialize:stream];
	super.date = [stream readInt];
}
        
-(TL_updateShort *)copy {
    
    TL_updateShort *objc = [[TL_updateShort alloc] init];
    
    objc.update = [self.update copy];
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChat* obj = [self.chats objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
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
			TLUpdate* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUpdate class]])
                 [self.updates addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChat class]])
                 [self.chats addObject:obj];
            else
                break;
		}
	}
	super.date = [stream readInt];
	super.seq_start = [stream readInt];
	super.seq = [stream readInt];
}
        
-(TL_updatesCombined *)copy {
    
    TL_updatesCombined *objc = [[TL_updatesCombined alloc] init];
    
    objc.updates = [self.updates copy];
    objc.users = [self.users copy];
    objc.chats = [self.chats copy];
    objc.date = self.date;
    objc.seq_start = self.seq_start;
    objc.seq = self.seq;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChat* obj = [self.chats objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
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
			TLUpdate* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUpdate class]])
                 [self.updates addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChat class]])
                 [self.chats addObject:obj];
            else
                break;
		}
	}
	super.date = [stream readInt];
	super.seq = [stream readInt];
}
        
-(TL_updates *)copy {
    
    TL_updates *objc = [[TL_updates alloc] init];
    
    objc.updates = [self.updates copy];
    objc.users = [self.users copy];
    objc.chats = [self.chats copy];
    objc.date = self.date;
    objc.seq = self.seq;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_updateShortSentMessage
+(TL_updateShortSentMessage*)createWithFlags:(int)flags   n_id:(int)n_id pts:(int)pts pts_count:(int)pts_count date:(int)date media:(TLMessageMedia*)media entities:(NSMutableArray*)entities {
	TL_updateShortSentMessage* obj = [[TL_updateShortSentMessage alloc] init];
	obj.flags = flags;
	
	
	obj.n_id = n_id;
	obj.pts = pts;
	obj.pts_count = pts_count;
	obj.date = date;
	obj.media = media;
	obj.entities = entities;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	
	[stream writeInt:self.n_id];
	[stream writeInt:self.pts];
	[stream writeInt:self.pts_count];
	[stream writeInt:self.date];
	if(self.flags & (1 << 9)) {[ClassStore TLSerialize:self.media stream:stream];}
	if(self.flags & (1 << 7)) {//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.entities count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLMessageEntity* obj = [self.entities objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	
	super.n_id = [stream readInt];
	super.pts = [stream readInt];
	super.pts_count = [stream readInt];
	super.date = [stream readInt];
	if(self.flags & (1 << 9)) {self.media = [ClassStore TLDeserialize:stream];}
	if(self.flags & (1 << 7)) {//UNS FullVector
	[stream readInt];
	{
		if(!self.entities)
			self.entities = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessageEntity* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLMessageEntity class]])
                 [self.entities addObject:obj];
            else
                break;
		}
	}}
}
        
-(TL_updateShortSentMessage *)copy {
    
    TL_updateShortSentMessage *objc = [[TL_updateShortSentMessage alloc] init];
    
    objc.flags = self.flags;
    
    
    objc.n_id = self.n_id;
    objc.pts = self.pts;
    objc.pts_count = self.pts_count;
    objc.date = self.date;
    objc.media = [self.media copy];
    objc.entities = [self.entities copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isUnread {return (self.flags & (1 << 0)) > 0;}
                        
-(BOOL)isN_out {return (self.flags & (1 << 1)) > 0;}
                        
-(void)setMedia:(TLMessageMedia*)media
{
   super.media = media;
                
    if(super.media == nil)  { super.flags&= ~ (1 << 9) ;} else { super.flags|= (1 << 9); }
}            
-(void)setEntities:(NSMutableArray*)entities
{
   super.entities = entities;
                
    if(super.entities == nil)  { super.flags&= ~ (1 << 7) ;} else { super.flags|= (1 << 7); }
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
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
			TLPhoto* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLPhoto class]])
                 [self.photos addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_photos_photos *)copy {
    
    TL_photos_photos *objc = [[TL_photos_photos alloc] init];
    
    objc.photos = [self.photos copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.photos)
			self.photos = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLPhoto* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLPhoto class]])
                 [self.photos addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_photos_photosSlice *)copy {
    
    TL_photos_photosSlice *objc = [[TL_photos_photosSlice alloc] init];
    
    objc.n_count = self.n_count;
    objc.photos = [self.photos copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.photo stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.photo = [ClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_photos_photo *)copy {
    
    TL_photos_photo *objc = [[TL_photos_photo alloc] init];
    
    objc.photo = [self.photo copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.type stream:stream];
	[stream writeInt:self.mtime];
	[stream writeByteArray:self.bytes];
}
-(void)unserialize:(SerializedData*)stream {
	self.type = [ClassStore TLDeserialize:stream];
	super.mtime = [stream readInt];
	super.bytes = [stream readByteArray];
}
        
-(TL_upload_file *)copy {
    
    TL_upload_file *objc = [[TL_upload_file alloc] init];
    
    objc.type = [self.type copy];
    objc.mtime = self.mtime;
    objc.bytes = [self.bytes copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLDcOption
            
-(BOOL)isIpv6 {return NO;}
                        
-(BOOL)isMedia_only {return NO;}
            
@end
        
@implementation TL_dcOption
+(TL_dcOption*)createWithFlags:(int)flags   n_id:(int)n_id ip_address:(NSString*)ip_address port:(int)port {
	TL_dcOption* obj = [[TL_dcOption alloc] init];
	obj.flags = flags;
	
	
	obj.n_id = n_id;
	obj.ip_address = ip_address;
	obj.port = port;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	
	[stream writeInt:self.n_id];
	[stream writeString:self.ip_address];
	[stream writeInt:self.port];
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	
	super.n_id = [stream readInt];
	super.ip_address = [stream readString];
	super.port = [stream readInt];
}
        
-(TL_dcOption *)copy {
    
    TL_dcOption *objc = [[TL_dcOption alloc] init];
    
    objc.flags = self.flags;
    
    
    objc.n_id = self.n_id;
    objc.ip_address = self.ip_address;
    objc.port = self.port;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isIpv6 {return (self.flags & (1 << 0)) > 0;}
                        
-(BOOL)isMedia_only {return (self.flags & (1 << 1)) > 0;}
            
        
@end

@implementation TLConfig

@end
        
@implementation TL_config
+(TL_config*)createWithDate:(int)date expires:(int)expires test_mode:(Boolean)test_mode this_dc:(int)this_dc dc_options:(NSMutableArray*)dc_options chat_size_max:(int)chat_size_max megagroup_size_max:(int)megagroup_size_max forwarded_count_max:(int)forwarded_count_max online_update_period_ms:(int)online_update_period_ms offline_blur_timeout_ms:(int)offline_blur_timeout_ms offline_idle_timeout_ms:(int)offline_idle_timeout_ms online_cloud_timeout_ms:(int)online_cloud_timeout_ms notify_cloud_delay_ms:(int)notify_cloud_delay_ms notify_default_delay_ms:(int)notify_default_delay_ms chat_big_size:(int)chat_big_size push_chat_period_ms:(int)push_chat_period_ms push_chat_limit:(int)push_chat_limit disabled_features:(NSMutableArray*)disabled_features {
	TL_config* obj = [[TL_config alloc] init];
	obj.date = date;
	obj.expires = expires;
	obj.test_mode = test_mode;
	obj.this_dc = this_dc;
	obj.dc_options = dc_options;
	obj.chat_size_max = chat_size_max;
	obj.megagroup_size_max = megagroup_size_max;
	obj.forwarded_count_max = forwarded_count_max;
	obj.online_update_period_ms = online_update_period_ms;
	obj.offline_blur_timeout_ms = offline_blur_timeout_ms;
	obj.offline_idle_timeout_ms = offline_idle_timeout_ms;
	obj.online_cloud_timeout_ms = online_cloud_timeout_ms;
	obj.notify_cloud_delay_ms = notify_cloud_delay_ms;
	obj.notify_default_delay_ms = notify_default_delay_ms;
	obj.chat_big_size = chat_big_size;
	obj.push_chat_period_ms = push_chat_period_ms;
	obj.push_chat_limit = push_chat_limit;
	obj.disabled_features = disabled_features;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.date];
	[stream writeInt:self.expires];
	[stream writeBool:self.test_mode];
	[stream writeInt:self.this_dc];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.dc_options count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLDcOption* obj = [self.dc_options objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	[stream writeInt:self.chat_size_max];
	[stream writeInt:self.megagroup_size_max];
	[stream writeInt:self.forwarded_count_max];
	[stream writeInt:self.online_update_period_ms];
	[stream writeInt:self.offline_blur_timeout_ms];
	[stream writeInt:self.offline_idle_timeout_ms];
	[stream writeInt:self.online_cloud_timeout_ms];
	[stream writeInt:self.notify_cloud_delay_ms];
	[stream writeInt:self.notify_default_delay_ms];
	[stream writeInt:self.chat_big_size];
	[stream writeInt:self.push_chat_period_ms];
	[stream writeInt:self.push_chat_limit];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.disabled_features count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLDisabledFeature* obj = [self.disabled_features objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.date = [stream readInt];
	super.expires = [stream readInt];
	super.test_mode = [stream readBool];
	super.this_dc = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.dc_options)
			self.dc_options = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLDcOption* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLDcOption class]])
                 [self.dc_options addObject:obj];
            else
                break;
		}
	}
	super.chat_size_max = [stream readInt];
	super.megagroup_size_max = [stream readInt];
	super.forwarded_count_max = [stream readInt];
	super.online_update_period_ms = [stream readInt];
	super.offline_blur_timeout_ms = [stream readInt];
	super.offline_idle_timeout_ms = [stream readInt];
	super.online_cloud_timeout_ms = [stream readInt];
	super.notify_cloud_delay_ms = [stream readInt];
	super.notify_default_delay_ms = [stream readInt];
	super.chat_big_size = [stream readInt];
	super.push_chat_period_ms = [stream readInt];
	super.push_chat_limit = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.disabled_features)
			self.disabled_features = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLDisabledFeature* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLDisabledFeature class]])
                 [self.disabled_features addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_config *)copy {
    
    TL_config *objc = [[TL_config alloc] init];
    
    objc.date = self.date;
    objc.expires = self.expires;
    objc.test_mode = self.test_mode;
    objc.this_dc = self.this_dc;
    objc.dc_options = [self.dc_options copy];
    objc.chat_size_max = self.chat_size_max;
    objc.megagroup_size_max = self.megagroup_size_max;
    objc.forwarded_count_max = self.forwarded_count_max;
    objc.online_update_period_ms = self.online_update_period_ms;
    objc.offline_blur_timeout_ms = self.offline_blur_timeout_ms;
    objc.offline_idle_timeout_ms = self.offline_idle_timeout_ms;
    objc.online_cloud_timeout_ms = self.online_cloud_timeout_ms;
    objc.notify_cloud_delay_ms = self.notify_cloud_delay_ms;
    objc.notify_default_delay_ms = self.notify_default_delay_ms;
    objc.chat_big_size = self.chat_big_size;
    objc.push_chat_period_ms = self.push_chat_period_ms;
    objc.push_chat_limit = self.push_chat_limit;
    objc.disabled_features = [self.disabled_features copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.country = [stream readString];
	super.this_dc = [stream readInt];
	super.nearest_dc = [stream readInt];
}
        
-(TL_nearestDc *)copy {
    
    TL_nearestDc *objc = [[TL_nearestDc alloc] init];
    
    objc.country = self.country;
    objc.this_dc = self.this_dc;
    objc.nearest_dc = self.nearest_dc;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readInt];
	super.critical = [stream readBool];
	super.url = [stream readString];
	super.text = [stream readString];
}
        
-(TL_help_appUpdate *)copy {
    
    TL_help_appUpdate *objc = [[TL_help_appUpdate alloc] init];
    
    objc.n_id = self.n_id;
    objc.critical = self.critical;
    objc.url = self.url;
    objc.text = self.text;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_help_noAppUpdate *)copy {
    
    TL_help_noAppUpdate *objc = [[TL_help_noAppUpdate alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.message = [stream readString];
}
        
-(TL_help_inviteText *)copy {
    
    TL_help_inviteText *objc = [[TL_help_inviteText alloc] init];
    
    objc.message = self.message;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readInt];
}
        
-(TL_encryptedChatEmpty *)copy {
    
    TL_encryptedChatEmpty *objc = [[TL_encryptedChatEmpty alloc] init];
    
    objc.n_id = self.n_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readInt];
	super.access_hash = [stream readLong];
	super.date = [stream readInt];
	super.admin_id = [stream readInt];
	super.participant_id = [stream readInt];
}
        
-(TL_encryptedChatWaiting *)copy {
    
    TL_encryptedChatWaiting *objc = [[TL_encryptedChatWaiting alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    objc.date = self.date;
    objc.admin_id = self.admin_id;
    objc.participant_id = self.participant_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readInt];
	super.access_hash = [stream readLong];
	super.date = [stream readInt];
	super.admin_id = [stream readInt];
	super.participant_id = [stream readInt];
	super.g_a = [stream readByteArray];
}
        
-(TL_encryptedChatRequested *)copy {
    
    TL_encryptedChatRequested *objc = [[TL_encryptedChatRequested alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    objc.date = self.date;
    objc.admin_id = self.admin_id;
    objc.participant_id = self.participant_id;
    objc.g_a = [self.g_a copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readInt];
	super.access_hash = [stream readLong];
	super.date = [stream readInt];
	super.admin_id = [stream readInt];
	super.participant_id = [stream readInt];
	super.g_a_or_b = [stream readByteArray];
	super.key_fingerprint = [stream readLong];
}
        
-(TL_encryptedChat *)copy {
    
    TL_encryptedChat *objc = [[TL_encryptedChat alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    objc.date = self.date;
    objc.admin_id = self.admin_id;
    objc.participant_id = self.participant_id;
    objc.g_a_or_b = [self.g_a_or_b copy];
    objc.key_fingerprint = self.key_fingerprint;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readInt];
}
        
-(TL_encryptedChatDiscarded *)copy {
    
    TL_encryptedChatDiscarded *objc = [[TL_encryptedChatDiscarded alloc] init];
    
    objc.n_id = self.n_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.chat_id = [stream readInt];
	super.access_hash = [stream readLong];
}
        
-(TL_inputEncryptedChat *)copy {
    
    TL_inputEncryptedChat *objc = [[TL_inputEncryptedChat alloc] init];
    
    objc.chat_id = self.chat_id;
    objc.access_hash = self.access_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_encryptedFileEmpty *)copy {
    
    TL_encryptedFileEmpty *objc = [[TL_encryptedFileEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
	super.size = [stream readInt];
	super.dc_id = [stream readInt];
	super.key_fingerprint = [stream readInt];
}
        
-(TL_encryptedFile *)copy {
    
    TL_encryptedFile *objc = [[TL_encryptedFile alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    objc.size = self.size;
    objc.dc_id = self.dc_id;
    objc.key_fingerprint = self.key_fingerprint;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputEncryptedFileEmpty *)copy {
    
    TL_inputEncryptedFileEmpty *objc = [[TL_inputEncryptedFileEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
	super.parts = [stream readInt];
	super.md5_checksum = [stream readString];
	super.key_fingerprint = [stream readInt];
}
        
-(TL_inputEncryptedFileUploaded *)copy {
    
    TL_inputEncryptedFileUploaded *objc = [[TL_inputEncryptedFileUploaded alloc] init];
    
    objc.n_id = self.n_id;
    objc.parts = self.parts;
    objc.md5_checksum = self.md5_checksum;
    objc.key_fingerprint = self.key_fingerprint;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
}
        
-(TL_inputEncryptedFile *)copy {
    
    TL_inputEncryptedFile *objc = [[TL_inputEncryptedFile alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
	super.parts = [stream readInt];
	super.key_fingerprint = [stream readInt];
}
        
-(TL_inputEncryptedFileBigUploaded *)copy {
    
    TL_inputEncryptedFileBigUploaded *objc = [[TL_inputEncryptedFileBigUploaded alloc] init];
    
    objc.n_id = self.n_id;
    objc.parts = self.parts;
    objc.key_fingerprint = self.key_fingerprint;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.file stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.random_id = [stream readLong];
	super.chat_id = [stream readInt];
	super.date = [stream readInt];
	super.bytes = [stream readByteArray];
	self.file = [ClassStore TLDeserialize:stream];
}
        
-(TL_encryptedMessage *)copy {
    
    TL_encryptedMessage *objc = [[TL_encryptedMessage alloc] init];
    
    objc.random_id = self.random_id;
    objc.chat_id = self.chat_id;
    objc.date = self.date;
    objc.bytes = [self.bytes copy];
    objc.file = [self.file copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.random_id = [stream readLong];
	super.chat_id = [stream readInt];
	super.date = [stream readInt];
	super.bytes = [stream readByteArray];
}
        
-(TL_encryptedMessageService *)copy {
    
    TL_encryptedMessageService *objc = [[TL_encryptedMessageService alloc] init];
    
    objc.random_id = self.random_id;
    objc.chat_id = self.chat_id;
    objc.date = self.date;
    objc.bytes = [self.bytes copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.random = [stream readByteArray];
}
        
-(TL_messages_dhConfigNotModified *)copy {
    
    TL_messages_dhConfigNotModified *objc = [[TL_messages_dhConfigNotModified alloc] init];
    
    objc.random = [self.random copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.g = [stream readInt];
	super.p = [stream readByteArray];
	super.version = [stream readInt];
	super.random = [stream readByteArray];
}
        
-(TL_messages_dhConfig *)copy {
    
    TL_messages_dhConfig *objc = [[TL_messages_dhConfig alloc] init];
    
    objc.g = self.g;
    objc.p = [self.p copy];
    objc.version = self.version;
    objc.random = [self.random copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.date = [stream readInt];
}
        
-(TL_messages_sentEncryptedMessage *)copy {
    
    TL_messages_sentEncryptedMessage *objc = [[TL_messages_sentEncryptedMessage alloc] init];
    
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.file stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.date = [stream readInt];
	self.file = [ClassStore TLDeserialize:stream];
}
        
-(TL_messages_sentEncryptedFile *)copy {
    
    TL_messages_sentEncryptedFile *objc = [[TL_messages_sentEncryptedFile alloc] init];
    
    objc.date = self.date;
    objc.file = [self.file copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputAudioEmpty *)copy {
    
    TL_inputAudioEmpty *objc = [[TL_inputAudioEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
}
        
-(TL_inputAudio *)copy {
    
    TL_inputAudio *objc = [[TL_inputAudio alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputDocumentEmpty *)copy {
    
    TL_inputDocumentEmpty *objc = [[TL_inputDocumentEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
}
        
-(TL_inputDocument *)copy {
    
    TL_inputDocument *objc = [[TL_inputDocument alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
}
        
-(TL_audioEmpty *)copy {
    
    TL_audioEmpty *objc = [[TL_audioEmpty alloc] init];
    
    objc.n_id = self.n_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_audio
+(TL_audio*)createWithN_id:(long)n_id access_hash:(long)access_hash date:(int)date duration:(int)duration mime_type:(NSString*)mime_type size:(int)size dc_id:(int)dc_id {
	TL_audio* obj = [[TL_audio alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
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
	[stream writeInt:self.date];
	[stream writeInt:self.duration];
	[stream writeString:self.mime_type];
	[stream writeInt:self.size];
	[stream writeInt:self.dc_id];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
	super.date = [stream readInt];
	super.duration = [stream readInt];
	super.mime_type = [stream readString];
	super.size = [stream readInt];
	super.dc_id = [stream readInt];
}
        
-(TL_audio *)copy {
    
    TL_audio *objc = [[TL_audio alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    objc.date = self.date;
    objc.duration = self.duration;
    objc.mime_type = self.mime_type;
    objc.size = self.size;
    objc.dc_id = self.dc_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_audio_old29
+(TL_audio_old29*)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date duration:(int)duration mime_type:(NSString*)mime_type size:(int)size dc_id:(int)dc_id {
	TL_audio_old29* obj = [[TL_audio_old29 alloc] init];
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
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
	super.user_id = [stream readInt];
	super.date = [stream readInt];
	super.duration = [stream readInt];
	super.mime_type = [stream readString];
	super.size = [stream readInt];
	super.dc_id = [stream readInt];
}
        
-(TL_audio_old29 *)copy {
    
    TL_audio_old29 *objc = [[TL_audio_old29 alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    objc.user_id = self.user_id;
    objc.date = self.date;
    objc.duration = self.duration;
    objc.mime_type = self.mime_type;
    objc.size = self.size;
    objc.dc_id = self.dc_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n_id = [stream readLong];
}
        
-(TL_documentEmpty *)copy {
    
    TL_documentEmpty *objc = [[TL_documentEmpty alloc] init];
    
    objc.n_id = self.n_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.thumb stream:stream];
	[stream writeInt:self.dc_id];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.attributes count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLDocumentAttribute* obj = [self.attributes objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
	super.date = [stream readInt];
	super.mime_type = [stream readString];
	super.size = [stream readInt];
	self.thumb = [ClassStore TLDeserialize:stream];
	super.dc_id = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.attributes)
			self.attributes = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLDocumentAttribute* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLDocumentAttribute class]])
                 [self.attributes addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_document *)copy {
    
    TL_document *objc = [[TL_document alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    objc.date = self.date;
    objc.mime_type = self.mime_type;
    objc.size = self.size;
    objc.thumb = [self.thumb copy];
    objc.dc_id = self.dc_id;
    objc.attributes = [self.attributes copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.user stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.phone_number = [stream readString];
	self.user = [ClassStore TLDeserialize:stream];
}
        
-(TL_help_support *)copy {
    
    TL_help_support *objc = [[TL_help_support alloc] init];
    
    objc.phone_number = self.phone_number;
    objc.user = [self.user copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.peer stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.peer = [ClassStore TLDeserialize:stream];
}
        
-(TL_notifyPeer *)copy {
    
    TL_notifyPeer *objc = [[TL_notifyPeer alloc] init];
    
    objc.peer = [self.peer copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_notifyUsers *)copy {
    
    TL_notifyUsers *objc = [[TL_notifyUsers alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_notifyChats *)copy {
    
    TL_notifyChats *objc = [[TL_notifyChats alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_notifyAll *)copy {
    
    TL_notifyAll *objc = [[TL_notifyAll alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_sendMessageTypingAction *)copy {
    
    TL_sendMessageTypingAction *objc = [[TL_sendMessageTypingAction alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_sendMessageCancelAction *)copy {
    
    TL_sendMessageCancelAction *objc = [[TL_sendMessageCancelAction alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_sendMessageRecordVideoAction *)copy {
    
    TL_sendMessageRecordVideoAction *objc = [[TL_sendMessageRecordVideoAction alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_sendMessageUploadVideoAction
+(TL_sendMessageUploadVideoAction*)createWithProgress:(int)progress {
	TL_sendMessageUploadVideoAction* obj = [[TL_sendMessageUploadVideoAction alloc] init];
	obj.progress = progress;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.progress];
}
-(void)unserialize:(SerializedData*)stream {
	super.progress = [stream readInt];
}
        
-(TL_sendMessageUploadVideoAction *)copy {
    
    TL_sendMessageUploadVideoAction *objc = [[TL_sendMessageUploadVideoAction alloc] init];
    
    objc.progress = self.progress;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_sendMessageRecordAudioAction *)copy {
    
    TL_sendMessageRecordAudioAction *objc = [[TL_sendMessageRecordAudioAction alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_sendMessageUploadAudioAction
+(TL_sendMessageUploadAudioAction*)createWithProgress:(int)progress {
	TL_sendMessageUploadAudioAction* obj = [[TL_sendMessageUploadAudioAction alloc] init];
	obj.progress = progress;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.progress];
}
-(void)unserialize:(SerializedData*)stream {
	super.progress = [stream readInt];
}
        
-(TL_sendMessageUploadAudioAction *)copy {
    
    TL_sendMessageUploadAudioAction *objc = [[TL_sendMessageUploadAudioAction alloc] init];
    
    objc.progress = self.progress;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_sendMessageUploadPhotoAction
+(TL_sendMessageUploadPhotoAction*)createWithProgress:(int)progress {
	TL_sendMessageUploadPhotoAction* obj = [[TL_sendMessageUploadPhotoAction alloc] init];
	obj.progress = progress;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.progress];
}
-(void)unserialize:(SerializedData*)stream {
	super.progress = [stream readInt];
}
        
-(TL_sendMessageUploadPhotoAction *)copy {
    
    TL_sendMessageUploadPhotoAction *objc = [[TL_sendMessageUploadPhotoAction alloc] init];
    
    objc.progress = self.progress;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_sendMessageUploadDocumentAction
+(TL_sendMessageUploadDocumentAction*)createWithProgress:(int)progress {
	TL_sendMessageUploadDocumentAction* obj = [[TL_sendMessageUploadDocumentAction alloc] init];
	obj.progress = progress;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.progress];
}
-(void)unserialize:(SerializedData*)stream {
	super.progress = [stream readInt];
}
        
-(TL_sendMessageUploadDocumentAction *)copy {
    
    TL_sendMessageUploadDocumentAction *objc = [[TL_sendMessageUploadDocumentAction alloc] init];
    
    objc.progress = self.progress;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_sendMessageGeoLocationAction *)copy {
    
    TL_sendMessageGeoLocationAction *objc = [[TL_sendMessageGeoLocationAction alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_sendMessageChooseContactAction *)copy {
    
    TL_sendMessageChooseContactAction *objc = [[TL_sendMessageChooseContactAction alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLcontacts_Found

@end
        
@implementation TL_contacts_found
+(TL_contacts_found*)createWithResults:(NSMutableArray*)results chats:(NSMutableArray*)chats users:(NSMutableArray*)users {
	TL_contacts_found* obj = [[TL_contacts_found alloc] init];
	obj.results = results;
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
            TLPeer* obj = [self.results objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChat* obj = [self.chats objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
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
			TLPeer* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLPeer class]])
                 [self.results addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChat class]])
                 [self.chats addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_contacts_found *)copy {
    
    TL_contacts_found *objc = [[TL_contacts_found alloc] init];
    
    objc.results = [self.results copy];
    objc.chats = [self.chats copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputPrivacyKeyStatusTimestamp *)copy {
    
    TL_inputPrivacyKeyStatusTimestamp *objc = [[TL_inputPrivacyKeyStatusTimestamp alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_privacyKeyStatusTimestamp *)copy {
    
    TL_privacyKeyStatusTimestamp *objc = [[TL_privacyKeyStatusTimestamp alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputPrivacyValueAllowContacts *)copy {
    
    TL_inputPrivacyValueAllowContacts *objc = [[TL_inputPrivacyValueAllowContacts alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputPrivacyValueAllowAll *)copy {
    
    TL_inputPrivacyValueAllowAll *objc = [[TL_inputPrivacyValueAllowAll alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
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
			TLInputUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLInputUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_inputPrivacyValueAllowUsers *)copy {
    
    TL_inputPrivacyValueAllowUsers *objc = [[TL_inputPrivacyValueAllowUsers alloc] init];
    
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputPrivacyValueDisallowContacts *)copy {
    
    TL_inputPrivacyValueDisallowContacts *objc = [[TL_inputPrivacyValueDisallowContacts alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_inputPrivacyValueDisallowAll *)copy {
    
    TL_inputPrivacyValueDisallowAll *objc = [[TL_inputPrivacyValueDisallowAll alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
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
			TLInputUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLInputUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_inputPrivacyValueDisallowUsers *)copy {
    
    TL_inputPrivacyValueDisallowUsers *objc = [[TL_inputPrivacyValueDisallowUsers alloc] init];
    
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_privacyValueAllowContacts *)copy {
    
    TL_privacyValueAllowContacts *objc = [[TL_privacyValueAllowContacts alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_privacyValueAllowAll *)copy {
    
    TL_privacyValueAllowAll *objc = [[TL_privacyValueAllowAll alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            if([self.users count] > i) {
                NSNumber* obj = [self.users objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
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
			[self.users addObject:@(obj)];
		}
	}
}
        
-(TL_privacyValueAllowUsers *)copy {
    
    TL_privacyValueAllowUsers *objc = [[TL_privacyValueAllowUsers alloc] init];
    
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_privacyValueDisallowContacts *)copy {
    
    TL_privacyValueDisallowContacts *objc = [[TL_privacyValueDisallowContacts alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_privacyValueDisallowAll *)copy {
    
    TL_privacyValueDisallowAll *objc = [[TL_privacyValueDisallowAll alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            if([self.users count] > i) {
                NSNumber* obj = [self.users objectAtIndex:i];
			[stream writeInt:[obj intValue]];
            }  else
                break;
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
			[self.users addObject:@(obj)];
		}
	}
}
        
-(TL_privacyValueDisallowUsers *)copy {
    
    TL_privacyValueDisallowUsers *objc = [[TL_privacyValueDisallowUsers alloc] init];
    
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
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
			TLPrivacyRule* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLPrivacyRule class]])
                 [self.rules addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_account_privacyRules *)copy {
    
    TL_account_privacyRules *objc = [[TL_account_privacyRules alloc] init];
    
    objc.rules = [self.rules copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.days = [stream readInt];
}
        
-(TL_accountDaysTTL *)copy {
    
    TL_accountDaysTTL *objc = [[TL_accountDaysTTL alloc] init];
    
    objc.days = self.days;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.phone_code_hash = [stream readString];
	super.send_call_timeout = [stream readInt];
}
        
-(TL_account_sentChangePhoneCode *)copy {
    
    TL_account_sentChangePhoneCode *objc = [[TL_account_sentChangePhoneCode alloc] init];
    
    objc.phone_code_hash = self.phone_code_hash;
    objc.send_call_timeout = self.send_call_timeout;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.w = [stream readInt];
	super.h = [stream readInt];
}
        
-(TL_documentAttributeImageSize *)copy {
    
    TL_documentAttributeImageSize *objc = [[TL_documentAttributeImageSize alloc] init];
    
    objc.w = self.w;
    objc.h = self.h;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_documentAttributeAnimated *)copy {
    
    TL_documentAttributeAnimated *objc = [[TL_documentAttributeAnimated alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_documentAttributeSticker
+(TL_documentAttributeSticker*)createWithAlt:(NSString*)alt stickerset:(TLInputStickerSet*)stickerset {
	TL_documentAttributeSticker* obj = [[TL_documentAttributeSticker alloc] init];
	obj.alt = alt;
	obj.stickerset = stickerset;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.alt];
	[ClassStore TLSerialize:self.stickerset stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.alt = [stream readString];
	self.stickerset = [ClassStore TLDeserialize:stream];
}
        
-(TL_documentAttributeSticker *)copy {
    
    TL_documentAttributeSticker *objc = [[TL_documentAttributeSticker alloc] init];
    
    objc.alt = self.alt;
    objc.stickerset = [self.stickerset copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.duration = [stream readInt];
	super.w = [stream readInt];
	super.h = [stream readInt];
}
        
-(TL_documentAttributeVideo *)copy {
    
    TL_documentAttributeVideo *objc = [[TL_documentAttributeVideo alloc] init];
    
    objc.duration = self.duration;
    objc.w = self.w;
    objc.h = self.h;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_documentAttributeAudio
+(TL_documentAttributeAudio*)createWithDuration:(int)duration title:(NSString*)title performer:(NSString*)performer {
	TL_documentAttributeAudio* obj = [[TL_documentAttributeAudio alloc] init];
	obj.duration = duration;
	obj.title = title;
	obj.performer = performer;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.duration];
	[stream writeString:self.title];
	[stream writeString:self.performer];
}
-(void)unserialize:(SerializedData*)stream {
	super.duration = [stream readInt];
	super.title = [stream readString];
	super.performer = [stream readString];
}
        
-(TL_documentAttributeAudio *)copy {
    
    TL_documentAttributeAudio *objc = [[TL_documentAttributeAudio alloc] init];
    
    objc.duration = self.duration;
    objc.title = self.title;
    objc.performer = self.performer;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.file_name = [stream readString];
}
        
-(TL_documentAttributeFilename *)copy {
    
    TL_documentAttributeFilename *objc = [[TL_documentAttributeFilename alloc] init];
    
    objc.file_name = self.file_name;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_documentAttributeAudio_old31
+(TL_documentAttributeAudio_old31*)createWithDuration:(int)duration {
	TL_documentAttributeAudio_old31* obj = [[TL_documentAttributeAudio_old31 alloc] init];
	obj.duration = duration;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.duration];
}
-(void)unserialize:(SerializedData*)stream {
	super.duration = [stream readInt];
}
        
-(TL_documentAttributeAudio_old31 *)copy {
    
    TL_documentAttributeAudio_old31 *objc = [[TL_documentAttributeAudio_old31 alloc] init];
    
    objc.duration = self.duration;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLmessages_Stickers

@end
        
@implementation TL_messages_stickersNotModified
+(TL_messages_stickersNotModified*)create {
	TL_messages_stickersNotModified* obj = [[TL_messages_stickersNotModified alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_messages_stickersNotModified *)copy {
    
    TL_messages_stickersNotModified *objc = [[TL_messages_stickersNotModified alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messages_stickers
+(TL_messages_stickers*)createWithN_hash:(NSString*)n_hash stickers:(NSMutableArray*)stickers {
	TL_messages_stickers* obj = [[TL_messages_stickers alloc] init];
	obj.n_hash = n_hash;
	obj.stickers = stickers;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.n_hash];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.stickers count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLDocument* obj = [self.stickers objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.n_hash = [stream readString];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.stickers)
			self.stickers = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLDocument* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLDocument class]])
                 [self.stickers addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_messages_stickers *)copy {
    
    TL_messages_stickers *objc = [[TL_messages_stickers alloc] init];
    
    objc.n_hash = self.n_hash;
    objc.stickers = [self.stickers copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLStickerPack

@end
        
@implementation TL_stickerPack
+(TL_stickerPack*)createWithEmoticon:(NSString*)emoticon documents:(NSMutableArray*)documents {
	TL_stickerPack* obj = [[TL_stickerPack alloc] init];
	obj.emoticon = emoticon;
	obj.documents = documents;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.emoticon];
	//Serialize ShortVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.documents count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            if([self.documents count] > i) {
                NSNumber* obj = [self.documents objectAtIndex:i];
			[stream writeLong:[obj longValue]];
            }  else
                break;
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.emoticon = [stream readString];
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.documents)
			self.documents = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			long obj = [stream readLong];
			[self.documents addObject:@(obj)];
		}
	}
}
        
-(TL_stickerPack *)copy {
    
    TL_stickerPack *objc = [[TL_stickerPack alloc] init];
    
    objc.emoticon = self.emoticon;
    objc.documents = [self.documents copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLmessages_AllStickers

@end
        
@implementation TL_messages_allStickersNotModified
+(TL_messages_allStickersNotModified*)create {
	TL_messages_allStickersNotModified* obj = [[TL_messages_allStickersNotModified alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_messages_allStickersNotModified *)copy {
    
    TL_messages_allStickersNotModified *objc = [[TL_messages_allStickersNotModified alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messages_allStickers
+(TL_messages_allStickers*)createWithN_hash:(int)n_hash sets:(NSMutableArray*)sets {
	TL_messages_allStickers* obj = [[TL_messages_allStickers alloc] init];
	obj.n_hash = n_hash;
	obj.sets = sets;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_hash];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.sets count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLStickerSet* obj = [self.sets objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.n_hash = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.sets)
			self.sets = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLStickerSet* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLStickerSet class]])
                 [self.sets addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_messages_allStickers *)copy {
    
    TL_messages_allStickers *objc = [[TL_messages_allStickers alloc] init];
    
    objc.n_hash = self.n_hash;
    objc.sets = [self.sets copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLDisabledFeature

@end
        
@implementation TL_disabledFeature
+(TL_disabledFeature*)createWithFeature:(NSString*)feature n_description:(NSString*)n_description {
	TL_disabledFeature* obj = [[TL_disabledFeature alloc] init];
	obj.feature = feature;
	obj.n_description = n_description;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.feature];
	[stream writeString:self.n_description];
}
-(void)unserialize:(SerializedData*)stream {
	super.feature = [stream readString];
	super.n_description = [stream readString];
}
        
-(TL_disabledFeature *)copy {
    
    TL_disabledFeature *objc = [[TL_disabledFeature alloc] init];
    
    objc.feature = self.feature;
    objc.n_description = self.n_description;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLmessages_AffectedMessages

@end
        
@implementation TL_messages_affectedMessages
+(TL_messages_affectedMessages*)createWithPts:(int)pts pts_count:(int)pts_count {
	TL_messages_affectedMessages* obj = [[TL_messages_affectedMessages alloc] init];
	obj.pts = pts;
	obj.pts_count = pts_count;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.pts];
	[stream writeInt:self.pts_count];
}
-(void)unserialize:(SerializedData*)stream {
	super.pts = [stream readInt];
	super.pts_count = [stream readInt];
}
        
-(TL_messages_affectedMessages *)copy {
    
    TL_messages_affectedMessages *objc = [[TL_messages_affectedMessages alloc] init];
    
    objc.pts = self.pts;
    objc.pts_count = self.pts_count;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLContactLink

@end
        
@implementation TL_contactLinkUnknown
+(TL_contactLinkUnknown*)create {
	TL_contactLinkUnknown* obj = [[TL_contactLinkUnknown alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_contactLinkUnknown *)copy {
    
    TL_contactLinkUnknown *objc = [[TL_contactLinkUnknown alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_contactLinkNone
+(TL_contactLinkNone*)create {
	TL_contactLinkNone* obj = [[TL_contactLinkNone alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_contactLinkNone *)copy {
    
    TL_contactLinkNone *objc = [[TL_contactLinkNone alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_contactLinkHasPhone
+(TL_contactLinkHasPhone*)create {
	TL_contactLinkHasPhone* obj = [[TL_contactLinkHasPhone alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_contactLinkHasPhone *)copy {
    
    TL_contactLinkHasPhone *objc = [[TL_contactLinkHasPhone alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_contactLinkContact
+(TL_contactLinkContact*)create {
	TL_contactLinkContact* obj = [[TL_contactLinkContact alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_contactLinkContact *)copy {
    
    TL_contactLinkContact *objc = [[TL_contactLinkContact alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLWebPage

@end
        
@implementation TL_webPageEmpty
+(TL_webPageEmpty*)createWithN_id:(long)n_id {
	TL_webPageEmpty* obj = [[TL_webPageEmpty alloc] init];
	obj.n_id = n_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readLong];
}
        
-(TL_webPageEmpty *)copy {
    
    TL_webPageEmpty *objc = [[TL_webPageEmpty alloc] init];
    
    objc.n_id = self.n_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_webPagePending
+(TL_webPagePending*)createWithN_id:(long)n_id date:(int)date {
	TL_webPagePending* obj = [[TL_webPagePending alloc] init];
	obj.n_id = n_id;
	obj.date = date;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeInt:self.date];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readLong];
	super.date = [stream readInt];
}
        
-(TL_webPagePending *)copy {
    
    TL_webPagePending *objc = [[TL_webPagePending alloc] init];
    
    objc.n_id = self.n_id;
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_webPage
+(TL_webPage*)createWithFlags:(int)flags n_id:(long)n_id url:(NSString*)url display_url:(NSString*)display_url type:(NSString*)type site_name:(NSString*)site_name title:(NSString*)title n_description:(NSString*)n_description photo:(TLPhoto*)photo embed_url:(NSString*)embed_url embed_type:(NSString*)embed_type embed_width:(int)embed_width embed_height:(int)embed_height duration:(int)duration author:(NSString*)author document:(TLDocument*)document {
	TL_webPage* obj = [[TL_webPage alloc] init];
	obj.flags = flags;
	obj.n_id = n_id;
	obj.url = url;
	obj.display_url = display_url;
	obj.type = type;
	obj.site_name = site_name;
	obj.title = title;
	obj.n_description = n_description;
	obj.photo = photo;
	obj.embed_url = embed_url;
	obj.embed_type = embed_type;
	obj.embed_width = embed_width;
	obj.embed_height = embed_height;
	obj.duration = duration;
	obj.author = author;
	obj.document = document;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	[stream writeLong:self.n_id];
	[stream writeString:self.url];
	[stream writeString:self.display_url];
	if(self.flags & (1 << 0)) {[stream writeString:self.type];}
	if(self.flags & (1 << 1)) {[stream writeString:self.site_name];}
	if(self.flags & (1 << 2)) {[stream writeString:self.title];}
	if(self.flags & (1 << 3)) {[stream writeString:self.n_description];}
	if(self.flags & (1 << 4)) {[ClassStore TLSerialize:self.photo stream:stream];}
	if(self.flags & (1 << 5)) {[stream writeString:self.embed_url];}
	if(self.flags & (1 << 5)) {[stream writeString:self.embed_type];}
	if(self.flags & (1 << 6)) {[stream writeInt:self.embed_width];}
	if(self.flags & (1 << 6)) {[stream writeInt:self.embed_height];}
	if(self.flags & (1 << 7)) {[stream writeInt:self.duration];}
	if(self.flags & (1 << 8)) {[stream writeString:self.author];}
	if(self.flags & (1 << 9)) {[ClassStore TLSerialize:self.document stream:stream];}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	super.n_id = [stream readLong];
	super.url = [stream readString];
	super.display_url = [stream readString];
	if(self.flags & (1 << 0)) {super.type = [stream readString];}
	if(self.flags & (1 << 1)) {super.site_name = [stream readString];}
	if(self.flags & (1 << 2)) {super.title = [stream readString];}
	if(self.flags & (1 << 3)) {super.n_description = [stream readString];}
	if(self.flags & (1 << 4)) {self.photo = [ClassStore TLDeserialize:stream];}
	if(self.flags & (1 << 5)) {super.embed_url = [stream readString];}
	if(self.flags & (1 << 5)) {super.embed_type = [stream readString];}
	if(self.flags & (1 << 6)) {super.embed_width = [stream readInt];}
	if(self.flags & (1 << 6)) {super.embed_height = [stream readInt];}
	if(self.flags & (1 << 7)) {super.duration = [stream readInt];}
	if(self.flags & (1 << 8)) {super.author = [stream readString];}
	if(self.flags & (1 << 9)) {self.document = [ClassStore TLDeserialize:stream];}
}
        
-(TL_webPage *)copy {
    
    TL_webPage *objc = [[TL_webPage alloc] init];
    
    objc.flags = self.flags;
    objc.n_id = self.n_id;
    objc.url = self.url;
    objc.display_url = self.display_url;
    objc.type = self.type;
    objc.site_name = self.site_name;
    objc.title = self.title;
    objc.n_description = self.n_description;
    objc.photo = [self.photo copy];
    objc.embed_url = self.embed_url;
    objc.embed_type = self.embed_type;
    objc.embed_width = self.embed_width;
    objc.embed_height = self.embed_height;
    objc.duration = self.duration;
    objc.author = self.author;
    objc.document = [self.document copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(void)setType:(NSString*)type
{
   super.type = type;
                
    if(super.type == nil)  { super.flags&= ~ (1 << 0) ;} else { super.flags|= (1 << 0); }
}            
-(void)setSite_name:(NSString*)site_name
{
   super.site_name = site_name;
                
    if(super.site_name == nil)  { super.flags&= ~ (1 << 1) ;} else { super.flags|= (1 << 1); }
}            
-(void)setTitle:(NSString*)title
{
   super.title = title;
                
    if(super.title == nil)  { super.flags&= ~ (1 << 2) ;} else { super.flags|= (1 << 2); }
}            
-(void)setN_description:(NSString*)n_description
{
   super.n_description = n_description;
                
    if(super.n_description == nil)  { super.flags&= ~ (1 << 3) ;} else { super.flags|= (1 << 3); }
}            
-(void)setPhoto:(TLPhoto*)photo
{
   super.photo = photo;
                
    if(super.photo == nil)  { super.flags&= ~ (1 << 4) ;} else { super.flags|= (1 << 4); }
}            
-(void)setEmbed_url:(NSString*)embed_url
{
   super.embed_url = embed_url;
                
    if(super.embed_url == nil)  { super.flags&= ~ (1 << 5) ;} else { super.flags|= (1 << 5); }
}            
-(void)setEmbed_type:(NSString*)embed_type
{
   super.embed_type = embed_type;
                
    if(super.embed_type == nil)  { super.flags&= ~ (1 << 5) ;} else { super.flags|= (1 << 5); }
}            
-(void)setEmbed_width:(int)embed_width
{
   super.embed_width = embed_width;
                
    if(super.embed_width == 0)  { super.flags&= ~ (1 << 6) ;} else { super.flags|= (1 << 6); }
}            
-(void)setEmbed_height:(int)embed_height
{
   super.embed_height = embed_height;
                
    if(super.embed_height == 0)  { super.flags&= ~ (1 << 6) ;} else { super.flags|= (1 << 6); }
}            
-(void)setDuration:(int)duration
{
   super.duration = duration;
                
    if(super.duration == 0)  { super.flags&= ~ (1 << 7) ;} else { super.flags|= (1 << 7); }
}            
-(void)setAuthor:(NSString*)author
{
   super.author = author;
                
    if(super.author == nil)  { super.flags&= ~ (1 << 8) ;} else { super.flags|= (1 << 8); }
}            
-(void)setDocument:(TLDocument*)document
{
   super.document = document;
                
    if(super.document == nil)  { super.flags&= ~ (1 << 9) ;} else { super.flags|= (1 << 9); }
}
        
@end

@implementation TL_webPage_old34
+(TL_webPage_old34*)createWithFlags:(int)flags n_id:(long)n_id url:(NSString*)url display_url:(NSString*)display_url type:(NSString*)type site_name:(NSString*)site_name title:(NSString*)title n_description:(NSString*)n_description photo:(TLPhoto*)photo embed_url:(NSString*)embed_url embed_type:(NSString*)embed_type embed_width:(int)embed_width embed_height:(int)embed_height duration:(int)duration author:(NSString*)author {
	TL_webPage_old34* obj = [[TL_webPage_old34 alloc] init];
	obj.flags = flags;
	obj.n_id = n_id;
	obj.url = url;
	obj.display_url = display_url;
	obj.type = type;
	obj.site_name = site_name;
	obj.title = title;
	obj.n_description = n_description;
	obj.photo = photo;
	obj.embed_url = embed_url;
	obj.embed_type = embed_type;
	obj.embed_width = embed_width;
	obj.embed_height = embed_height;
	obj.duration = duration;
	obj.author = author;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	[stream writeLong:self.n_id];
	[stream writeString:self.url];
	[stream writeString:self.display_url];
	if(self.flags & (1 << 0)) {[stream writeString:self.type];}
	if(self.flags & (1 << 1)) {[stream writeString:self.site_name];}
	if(self.flags & (1 << 2)) {[stream writeString:self.title];}
	if(self.flags & (1 << 3)) {[stream writeString:self.n_description];}
	if(self.flags & (1 << 4)) {[ClassStore TLSerialize:self.photo stream:stream];}
	if(self.flags & (1 << 5)) {[stream writeString:self.embed_url];}
	if(self.flags & (1 << 5)) {[stream writeString:self.embed_type];}
	if(self.flags & (1 << 6)) {[stream writeInt:self.embed_width];}
	if(self.flags & (1 << 6)) {[stream writeInt:self.embed_height];}
	if(self.flags & (1 << 7)) {[stream writeInt:self.duration];}
	if(self.flags & (1 << 8)) {[stream writeString:self.author];}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	super.n_id = [stream readLong];
	super.url = [stream readString];
	super.display_url = [stream readString];
	if(self.flags & (1 << 0)) {super.type = [stream readString];}
	if(self.flags & (1 << 1)) {super.site_name = [stream readString];}
	if(self.flags & (1 << 2)) {super.title = [stream readString];}
	if(self.flags & (1 << 3)) {super.n_description = [stream readString];}
	if(self.flags & (1 << 4)) {self.photo = [ClassStore TLDeserialize:stream];}
	if(self.flags & (1 << 5)) {super.embed_url = [stream readString];}
	if(self.flags & (1 << 5)) {super.embed_type = [stream readString];}
	if(self.flags & (1 << 6)) {super.embed_width = [stream readInt];}
	if(self.flags & (1 << 6)) {super.embed_height = [stream readInt];}
	if(self.flags & (1 << 7)) {super.duration = [stream readInt];}
	if(self.flags & (1 << 8)) {super.author = [stream readString];}
}
        
-(TL_webPage_old34 *)copy {
    
    TL_webPage_old34 *objc = [[TL_webPage_old34 alloc] init];
    
    objc.flags = self.flags;
    objc.n_id = self.n_id;
    objc.url = self.url;
    objc.display_url = self.display_url;
    objc.type = self.type;
    objc.site_name = self.site_name;
    objc.title = self.title;
    objc.n_description = self.n_description;
    objc.photo = [self.photo copy];
    objc.embed_url = self.embed_url;
    objc.embed_type = self.embed_type;
    objc.embed_width = self.embed_width;
    objc.embed_height = self.embed_height;
    objc.duration = self.duration;
    objc.author = self.author;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(void)setType:(NSString*)type
{
   super.type = type;
                
    if(super.type == nil)  { super.flags&= ~ (1 << 0) ;} else { super.flags|= (1 << 0); }
}            
-(void)setSite_name:(NSString*)site_name
{
   super.site_name = site_name;
                
    if(super.site_name == nil)  { super.flags&= ~ (1 << 1) ;} else { super.flags|= (1 << 1); }
}            
-(void)setTitle:(NSString*)title
{
   super.title = title;
                
    if(super.title == nil)  { super.flags&= ~ (1 << 2) ;} else { super.flags|= (1 << 2); }
}            
-(void)setN_description:(NSString*)n_description
{
   super.n_description = n_description;
                
    if(super.n_description == nil)  { super.flags&= ~ (1 << 3) ;} else { super.flags|= (1 << 3); }
}            
-(void)setPhoto:(TLPhoto*)photo
{
   super.photo = photo;
                
    if(super.photo == nil)  { super.flags&= ~ (1 << 4) ;} else { super.flags|= (1 << 4); }
}            
-(void)setEmbed_url:(NSString*)embed_url
{
   super.embed_url = embed_url;
                
    if(super.embed_url == nil)  { super.flags&= ~ (1 << 5) ;} else { super.flags|= (1 << 5); }
}            
-(void)setEmbed_type:(NSString*)embed_type
{
   super.embed_type = embed_type;
                
    if(super.embed_type == nil)  { super.flags&= ~ (1 << 5) ;} else { super.flags|= (1 << 5); }
}            
-(void)setEmbed_width:(int)embed_width
{
   super.embed_width = embed_width;
                
    if(super.embed_width == 0)  { super.flags&= ~ (1 << 6) ;} else { super.flags|= (1 << 6); }
}            
-(void)setEmbed_height:(int)embed_height
{
   super.embed_height = embed_height;
                
    if(super.embed_height == 0)  { super.flags&= ~ (1 << 6) ;} else { super.flags|= (1 << 6); }
}            
-(void)setDuration:(int)duration
{
   super.duration = duration;
                
    if(super.duration == 0)  { super.flags&= ~ (1 << 7) ;} else { super.flags|= (1 << 7); }
}            
-(void)setAuthor:(NSString*)author
{
   super.author = author;
                
    if(super.author == nil)  { super.flags&= ~ (1 << 8) ;} else { super.flags|= (1 << 8); }
}
        
@end

@implementation TLAuthorization

@end
        
@implementation TL_authorization
+(TL_authorization*)createWithN_hash:(long)n_hash flags:(int)flags device_model:(NSString*)device_model platform:(NSString*)platform system_version:(NSString*)system_version api_id:(int)api_id app_name:(NSString*)app_name app_version:(NSString*)app_version date_created:(int)date_created date_active:(int)date_active ip:(NSString*)ip country:(NSString*)country region:(NSString*)region {
	TL_authorization* obj = [[TL_authorization alloc] init];
	obj.n_hash = n_hash;
	obj.flags = flags;
	obj.device_model = device_model;
	obj.platform = platform;
	obj.system_version = system_version;
	obj.api_id = api_id;
	obj.app_name = app_name;
	obj.app_version = app_version;
	obj.date_created = date_created;
	obj.date_active = date_active;
	obj.ip = ip;
	obj.country = country;
	obj.region = region;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_hash];
	[stream writeInt:self.flags];
	[stream writeString:self.device_model];
	[stream writeString:self.platform];
	[stream writeString:self.system_version];
	[stream writeInt:self.api_id];
	[stream writeString:self.app_name];
	[stream writeString:self.app_version];
	[stream writeInt:self.date_created];
	[stream writeInt:self.date_active];
	[stream writeString:self.ip];
	[stream writeString:self.country];
	[stream writeString:self.region];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_hash = [stream readLong];
	super.flags = [stream readInt];
	super.device_model = [stream readString];
	super.platform = [stream readString];
	super.system_version = [stream readString];
	super.api_id = [stream readInt];
	super.app_name = [stream readString];
	super.app_version = [stream readString];
	super.date_created = [stream readInt];
	super.date_active = [stream readInt];
	super.ip = [stream readString];
	super.country = [stream readString];
	super.region = [stream readString];
}
        
-(TL_authorization *)copy {
    
    TL_authorization *objc = [[TL_authorization alloc] init];
    
    objc.n_hash = self.n_hash;
    objc.flags = self.flags;
    objc.device_model = self.device_model;
    objc.platform = self.platform;
    objc.system_version = self.system_version;
    objc.api_id = self.api_id;
    objc.app_name = self.app_name;
    objc.app_version = self.app_version;
    objc.date_created = self.date_created;
    objc.date_active = self.date_active;
    objc.ip = self.ip;
    objc.country = self.country;
    objc.region = self.region;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLaccount_Authorizations

@end
        
@implementation TL_account_authorizations
+(TL_account_authorizations*)createWithAuthorizations:(NSMutableArray*)authorizations {
	TL_account_authorizations* obj = [[TL_account_authorizations alloc] init];
	obj.authorizations = authorizations;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.authorizations count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLAuthorization* obj = [self.authorizations objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.authorizations)
			self.authorizations = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLAuthorization* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLAuthorization class]])
                 [self.authorizations addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_account_authorizations *)copy {
    
    TL_account_authorizations *objc = [[TL_account_authorizations alloc] init];
    
    objc.authorizations = [self.authorizations copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLaccount_Password

@end
        
@implementation TL_account_noPassword
+(TL_account_noPassword*)createWithN_salt:(NSData*)n_salt email_unconfirmed_pattern:(NSString*)email_unconfirmed_pattern {
	TL_account_noPassword* obj = [[TL_account_noPassword alloc] init];
	obj.n_salt = n_salt;
	obj.email_unconfirmed_pattern = email_unconfirmed_pattern;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeByteArray:self.n_salt];
	[stream writeString:self.email_unconfirmed_pattern];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_salt = [stream readByteArray];
	super.email_unconfirmed_pattern = [stream readString];
}
        
-(TL_account_noPassword *)copy {
    
    TL_account_noPassword *objc = [[TL_account_noPassword alloc] init];
    
    objc.n_salt = [self.n_salt copy];
    objc.email_unconfirmed_pattern = self.email_unconfirmed_pattern;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_account_password
+(TL_account_password*)createWithCurrent_salt:(NSData*)current_salt n_salt:(NSData*)n_salt hint:(NSString*)hint has_recovery:(Boolean)has_recovery email_unconfirmed_pattern:(NSString*)email_unconfirmed_pattern {
	TL_account_password* obj = [[TL_account_password alloc] init];
	obj.current_salt = current_salt;
	obj.n_salt = n_salt;
	obj.hint = hint;
	obj.has_recovery = has_recovery;
	obj.email_unconfirmed_pattern = email_unconfirmed_pattern;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeByteArray:self.current_salt];
	[stream writeByteArray:self.n_salt];
	[stream writeString:self.hint];
	[stream writeBool:self.has_recovery];
	[stream writeString:self.email_unconfirmed_pattern];
}
-(void)unserialize:(SerializedData*)stream {
	super.current_salt = [stream readByteArray];
	super.n_salt = [stream readByteArray];
	super.hint = [stream readString];
	super.has_recovery = [stream readBool];
	super.email_unconfirmed_pattern = [stream readString];
}
        
-(TL_account_password *)copy {
    
    TL_account_password *objc = [[TL_account_password alloc] init];
    
    objc.current_salt = [self.current_salt copy];
    objc.n_salt = [self.n_salt copy];
    objc.hint = self.hint;
    objc.has_recovery = self.has_recovery;
    objc.email_unconfirmed_pattern = self.email_unconfirmed_pattern;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLaccount_PasswordSettings

@end
        
@implementation TL_account_passwordSettings
+(TL_account_passwordSettings*)createWithEmail:(NSString*)email {
	TL_account_passwordSettings* obj = [[TL_account_passwordSettings alloc] init];
	obj.email = email;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.email];
}
-(void)unserialize:(SerializedData*)stream {
	super.email = [stream readString];
}
        
-(TL_account_passwordSettings *)copy {
    
    TL_account_passwordSettings *objc = [[TL_account_passwordSettings alloc] init];
    
    objc.email = self.email;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLaccount_PasswordInputSettings

@end
        
@implementation TL_account_passwordInputSettings
+(TL_account_passwordInputSettings*)createWithFlags:(int)flags n_salt:(NSData*)n_salt n_password_hash:(NSData*)n_password_hash hint:(NSString*)hint email:(NSString*)email {
	TL_account_passwordInputSettings* obj = [[TL_account_passwordInputSettings alloc] init];
	obj.flags = flags;
	obj.n_salt = n_salt;
	obj.n_password_hash = n_password_hash;
	obj.hint = hint;
	obj.email = email;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	if(self.flags & (1 << 0)) {[stream writeByteArray:self.n_salt];}
	if(self.flags & (1 << 0)) {[stream writeByteArray:self.n_password_hash];}
	if(self.flags & (1 << 0)) {[stream writeString:self.hint];}
	if(self.flags & (1 << 1)) {[stream writeString:self.email];}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	if(self.flags & (1 << 0)) {super.n_salt = [stream readByteArray];}
	if(self.flags & (1 << 0)) {super.n_password_hash = [stream readByteArray];}
	if(self.flags & (1 << 0)) {super.hint = [stream readString];}
	if(self.flags & (1 << 1)) {super.email = [stream readString];}
}
        
-(TL_account_passwordInputSettings *)copy {
    
    TL_account_passwordInputSettings *objc = [[TL_account_passwordInputSettings alloc] init];
    
    objc.flags = self.flags;
    objc.n_salt = [self.n_salt copy];
    objc.n_password_hash = [self.n_password_hash copy];
    objc.hint = self.hint;
    objc.email = self.email;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(void)setN_salt:(NSData*)n_salt
{
   super.n_salt = n_salt;
                
    if(super.n_salt == nil)  { super.flags&= ~ (1 << 0) ;} else { super.flags|= (1 << 0); }
}            
-(void)setN_password_hash:(NSData*)n_password_hash
{
   super.n_password_hash = n_password_hash;
                
    if(super.n_password_hash == nil)  { super.flags&= ~ (1 << 0) ;} else { super.flags|= (1 << 0); }
}            
-(void)setHint:(NSString*)hint
{
   super.hint = hint;
                
    if(super.hint == nil)  { super.flags&= ~ (1 << 0) ;} else { super.flags|= (1 << 0); }
}            
-(void)setEmail:(NSString*)email
{
   super.email = email;
                
    if(super.email == nil)  { super.flags&= ~ (1 << 1) ;} else { super.flags|= (1 << 1); }
}
        
@end

@implementation TLauth_PasswordRecovery

@end
        
@implementation TL_auth_passwordRecovery
+(TL_auth_passwordRecovery*)createWithEmail_pattern:(NSString*)email_pattern {
	TL_auth_passwordRecovery* obj = [[TL_auth_passwordRecovery alloc] init];
	obj.email_pattern = email_pattern;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.email_pattern];
}
-(void)unserialize:(SerializedData*)stream {
	super.email_pattern = [stream readString];
}
        
-(TL_auth_passwordRecovery *)copy {
    
    TL_auth_passwordRecovery *objc = [[TL_auth_passwordRecovery alloc] init];
    
    objc.email_pattern = self.email_pattern;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLReceivedNotifyMessage

@end
        
@implementation TL_receivedNotifyMessage
+(TL_receivedNotifyMessage*)createWithN_id:(int)n_id flags:(int)flags {
	TL_receivedNotifyMessage* obj = [[TL_receivedNotifyMessage alloc] init];
	obj.n_id = n_id;
	obj.flags = flags;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeInt:self.flags];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readInt];
	super.flags = [stream readInt];
}
        
-(TL_receivedNotifyMessage *)copy {
    
    TL_receivedNotifyMessage *objc = [[TL_receivedNotifyMessage alloc] init];
    
    objc.n_id = self.n_id;
    objc.flags = self.flags;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLExportedChatInvite

@end
        
@implementation TL_chatInviteEmpty
+(TL_chatInviteEmpty*)create {
	TL_chatInviteEmpty* obj = [[TL_chatInviteEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_chatInviteEmpty *)copy {
    
    TL_chatInviteEmpty *objc = [[TL_chatInviteEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_chatInviteExported
+(TL_chatInviteExported*)createWithLink:(NSString*)link {
	TL_chatInviteExported* obj = [[TL_chatInviteExported alloc] init];
	obj.link = link;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.link];
}
-(void)unserialize:(SerializedData*)stream {
	super.link = [stream readString];
}
        
-(TL_chatInviteExported *)copy {
    
    TL_chatInviteExported *objc = [[TL_chatInviteExported alloc] init];
    
    objc.link = self.link;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLChatInvite
            
-(BOOL)isChannel {return NO;}
                        
-(BOOL)isBroadcast {return NO;}
                        
-(BOOL)isPublic {return NO;}
                        
-(BOOL)isMegagroup {return NO;}
            
@end
        
@implementation TL_chatInviteAlready
+(TL_chatInviteAlready*)createWithChat:(TLChat*)chat {
	TL_chatInviteAlready* obj = [[TL_chatInviteAlready alloc] init];
	obj.chat = chat;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.chat stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.chat = [ClassStore TLDeserialize:stream];
}
        
-(TL_chatInviteAlready *)copy {
    
    TL_chatInviteAlready *objc = [[TL_chatInviteAlready alloc] init];
    
    objc.chat = [self.chat copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_chatInvite
+(TL_chatInvite*)createWithFlags:(int)flags     title:(NSString*)title {
	TL_chatInvite* obj = [[TL_chatInvite alloc] init];
	obj.flags = flags;
	
	
	
	
	obj.title = title;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	
	
	
	[stream writeString:self.title];
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	
	
	
	super.title = [stream readString];
}
        
-(TL_chatInvite *)copy {
    
    TL_chatInvite *objc = [[TL_chatInvite alloc] init];
    
    objc.flags = self.flags;
    
    
    
    
    objc.title = self.title;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isChannel {return (self.flags & (1 << 0)) > 0;}
                        
-(BOOL)isBroadcast {return (self.flags & (1 << 1)) > 0;}
                        
-(BOOL)isPublic {return (self.flags & (1 << 2)) > 0;}
                        
-(BOOL)isMegagroup {return (self.flags & (1 << 3)) > 0;}
            
        
@end

@implementation TLInputStickerSet

@end
        
@implementation TL_inputStickerSetEmpty
+(TL_inputStickerSetEmpty*)create {
	TL_inputStickerSetEmpty* obj = [[TL_inputStickerSetEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_inputStickerSetEmpty *)copy {
    
    TL_inputStickerSetEmpty *objc = [[TL_inputStickerSetEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputStickerSetID
+(TL_inputStickerSetID*)createWithN_id:(long)n_id access_hash:(long)access_hash {
	TL_inputStickerSetID* obj = [[TL_inputStickerSetID alloc] init];
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
}
        
-(TL_inputStickerSetID *)copy {
    
    TL_inputStickerSetID *objc = [[TL_inputStickerSetID alloc] init];
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputStickerSetShortName
+(TL_inputStickerSetShortName*)createWithShort_name:(NSString*)short_name {
	TL_inputStickerSetShortName* obj = [[TL_inputStickerSetShortName alloc] init];
	obj.short_name = short_name;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.short_name];
}
-(void)unserialize:(SerializedData*)stream {
	super.short_name = [stream readString];
}
        
-(TL_inputStickerSetShortName *)copy {
    
    TL_inputStickerSetShortName *objc = [[TL_inputStickerSetShortName alloc] init];
    
    objc.short_name = self.short_name;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLStickerSet
            
-(BOOL)isInstalled {return NO;}
                        
-(BOOL)isDisabled {return NO;}
                        
-(BOOL)isOfficial {return NO;}
            
@end
        
@implementation TL_stickerSet
+(TL_stickerSet*)createWithFlags:(int)flags    n_id:(long)n_id access_hash:(long)access_hash title:(NSString*)title short_name:(NSString*)short_name n_count:(int)n_count n_hash:(int)n_hash {
	TL_stickerSet* obj = [[TL_stickerSet alloc] init];
	obj.flags = flags;
	
	
	
	obj.n_id = n_id;
	obj.access_hash = access_hash;
	obj.title = title;
	obj.short_name = short_name;
	obj.n_count = n_count;
	obj.n_hash = n_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	
	
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeString:self.title];
	[stream writeString:self.short_name];
	[stream writeInt:self.n_count];
	[stream writeInt:self.n_hash];
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	
	
	super.n_id = [stream readLong];
	super.access_hash = [stream readLong];
	super.title = [stream readString];
	super.short_name = [stream readString];
	super.n_count = [stream readInt];
	super.n_hash = [stream readInt];
}
        
-(TL_stickerSet *)copy {
    
    TL_stickerSet *objc = [[TL_stickerSet alloc] init];
    
    objc.flags = self.flags;
    
    
    
    objc.n_id = self.n_id;
    objc.access_hash = self.access_hash;
    objc.title = self.title;
    objc.short_name = self.short_name;
    objc.n_count = self.n_count;
    objc.n_hash = self.n_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isInstalled {return (self.flags & (1 << 0)) > 0;}
                        
-(BOOL)isDisabled {return (self.flags & (1 << 1)) > 0;}
                        
-(BOOL)isOfficial {return (self.flags & (1 << 2)) > 0;}
            
        
@end

@implementation TLmessages_StickerSet

@end
        
@implementation TL_messages_stickerSet
+(TL_messages_stickerSet*)createWithSet:(TLStickerSet*)set packs:(NSMutableArray*)packs documents:(NSMutableArray*)documents {
	TL_messages_stickerSet* obj = [[TL_messages_stickerSet alloc] init];
	obj.set = set;
	obj.packs = packs;
	obj.documents = documents;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.set stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.packs count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLStickerPack* obj = [self.packs objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.documents count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLDocument* obj = [self.documents objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.set = [ClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.packs)
			self.packs = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLStickerPack* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLStickerPack class]])
                 [self.packs addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.documents)
			self.documents = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLDocument* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLDocument class]])
                 [self.documents addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_messages_stickerSet *)copy {
    
    TL_messages_stickerSet *objc = [[TL_messages_stickerSet alloc] init];
    
    objc.set = [self.set copy];
    objc.packs = [self.packs copy];
    objc.documents = [self.documents copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLBotCommand

@end
        
@implementation TL_botCommand
+(TL_botCommand*)createWithCommand:(NSString*)command n_description:(NSString*)n_description {
	TL_botCommand* obj = [[TL_botCommand alloc] init];
	obj.command = command;
	obj.n_description = n_description;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.command];
	[stream writeString:self.n_description];
}
-(void)unserialize:(SerializedData*)stream {
	super.command = [stream readString];
	super.n_description = [stream readString];
}
        
-(TL_botCommand *)copy {
    
    TL_botCommand *objc = [[TL_botCommand alloc] init];
    
    objc.command = self.command;
    objc.n_description = self.n_description;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLBotInfo

@end
        
@implementation TL_botInfoEmpty
+(TL_botInfoEmpty*)create {
	TL_botInfoEmpty* obj = [[TL_botInfoEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_botInfoEmpty *)copy {
    
    TL_botInfoEmpty *objc = [[TL_botInfoEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_botInfo
+(TL_botInfo*)createWithUser_id:(int)user_id version:(int)version share_text:(NSString*)share_text n_description:(NSString*)n_description commands:(NSMutableArray*)commands {
	TL_botInfo* obj = [[TL_botInfo alloc] init];
	obj.user_id = user_id;
	obj.version = version;
	obj.share_text = share_text;
	obj.n_description = n_description;
	obj.commands = commands;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeInt:self.version];
	[stream writeString:self.share_text];
	[stream writeString:self.n_description];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.commands count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLBotCommand* obj = [self.commands objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.user_id = [stream readInt];
	super.version = [stream readInt];
	super.share_text = [stream readString];
	super.n_description = [stream readString];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.commands)
			self.commands = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLBotCommand* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLBotCommand class]])
                 [self.commands addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_botInfo *)copy {
    
    TL_botInfo *objc = [[TL_botInfo alloc] init];
    
    objc.user_id = self.user_id;
    objc.version = self.version;
    objc.share_text = self.share_text;
    objc.n_description = self.n_description;
    objc.commands = [self.commands copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLKeyboardButton

@end
        
@implementation TL_keyboardButton
+(TL_keyboardButton*)createWithText:(NSString*)text {
	TL_keyboardButton* obj = [[TL_keyboardButton alloc] init];
	obj.text = text;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.text];
}
-(void)unserialize:(SerializedData*)stream {
	super.text = [stream readString];
}
        
-(TL_keyboardButton *)copy {
    
    TL_keyboardButton *objc = [[TL_keyboardButton alloc] init];
    
    objc.text = self.text;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLKeyboardButtonRow

@end
        
@implementation TL_keyboardButtonRow
+(TL_keyboardButtonRow*)createWithButtons:(NSMutableArray*)buttons {
	TL_keyboardButtonRow* obj = [[TL_keyboardButtonRow alloc] init];
	obj.buttons = buttons;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.buttons count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLKeyboardButton* obj = [self.buttons objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	//UNS FullVector
	[stream readInt];
	{
		if(!self.buttons)
			self.buttons = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLKeyboardButton* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLKeyboardButton class]])
                 [self.buttons addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_keyboardButtonRow *)copy {
    
    TL_keyboardButtonRow *objc = [[TL_keyboardButtonRow alloc] init];
    
    objc.buttons = [self.buttons copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLReplyMarkup
            
-(BOOL)isSelective {return NO;}
                        
-(BOOL)isSingle_use {return NO;}
                        
-(BOOL)isResize {return NO;}
            
@end
        
@implementation TL_replyKeyboardHide
+(TL_replyKeyboardHide*)createWithFlags:(int)flags  {
	TL_replyKeyboardHide* obj = [[TL_replyKeyboardHide alloc] init];
	obj.flags = flags;
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
}
        
-(TL_replyKeyboardHide *)copy {
    
    TL_replyKeyboardHide *objc = [[TL_replyKeyboardHide alloc] init];
    
    objc.flags = self.flags;
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isSelective {return (self.flags & (1 << 2)) > 0;}
            
        
@end

@implementation TL_replyKeyboardForceReply
+(TL_replyKeyboardForceReply*)createWithFlags:(int)flags   {
	TL_replyKeyboardForceReply* obj = [[TL_replyKeyboardForceReply alloc] init];
	obj.flags = flags;
	
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	
}
        
-(TL_replyKeyboardForceReply *)copy {
    
    TL_replyKeyboardForceReply *objc = [[TL_replyKeyboardForceReply alloc] init];
    
    objc.flags = self.flags;
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isSingle_use {return (self.flags & (1 << 1)) > 0;}
                        
-(BOOL)isSelective {return (self.flags & (1 << 2)) > 0;}
            
        
@end

@implementation TL_replyKeyboardMarkup
+(TL_replyKeyboardMarkup*)createWithFlags:(int)flags    rows:(NSMutableArray*)rows {
	TL_replyKeyboardMarkup* obj = [[TL_replyKeyboardMarkup alloc] init];
	obj.flags = flags;
	
	
	
	obj.rows = rows;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	
	
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.rows count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLKeyboardButtonRow* obj = [self.rows objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	
	
	//UNS FullVector
	[stream readInt];
	{
		if(!self.rows)
			self.rows = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLKeyboardButtonRow* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLKeyboardButtonRow class]])
                 [self.rows addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_replyKeyboardMarkup *)copy {
    
    TL_replyKeyboardMarkup *objc = [[TL_replyKeyboardMarkup alloc] init];
    
    objc.flags = self.flags;
    
    
    
    objc.rows = [self.rows copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isResize {return (self.flags & (1 << 0)) > 0;}
                        
-(BOOL)isSingle_use {return (self.flags & (1 << 1)) > 0;}
                        
-(BOOL)isSelective {return (self.flags & (1 << 2)) > 0;}
            
        
@end

@implementation TLhelp_AppChangelog

@end
        
@implementation TL_help_appChangelogEmpty
+(TL_help_appChangelogEmpty*)create {
	TL_help_appChangelogEmpty* obj = [[TL_help_appChangelogEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_help_appChangelogEmpty *)copy {
    
    TL_help_appChangelogEmpty *objc = [[TL_help_appChangelogEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_help_appChangelog
+(TL_help_appChangelog*)createWithText:(NSString*)text {
	TL_help_appChangelog* obj = [[TL_help_appChangelog alloc] init];
	obj.text = text;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.text];
}
-(void)unserialize:(SerializedData*)stream {
	super.text = [stream readString];
}
        
-(TL_help_appChangelog *)copy {
    
    TL_help_appChangelog *objc = [[TL_help_appChangelog alloc] init];
    
    objc.text = self.text;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLMessageEntity

@end
        
@implementation TL_messageEntityUnknown
+(TL_messageEntityUnknown*)createWithOffset:(int)offset length:(int)length {
	TL_messageEntityUnknown* obj = [[TL_messageEntityUnknown alloc] init];
	obj.offset = offset;
	obj.length = length;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.offset];
	[stream writeInt:self.length];
}
-(void)unserialize:(SerializedData*)stream {
	super.offset = [stream readInt];
	super.length = [stream readInt];
}
        
-(TL_messageEntityUnknown *)copy {
    
    TL_messageEntityUnknown *objc = [[TL_messageEntityUnknown alloc] init];
    
    objc.offset = self.offset;
    objc.length = self.length;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageEntityMention
+(TL_messageEntityMention*)createWithOffset:(int)offset length:(int)length {
	TL_messageEntityMention* obj = [[TL_messageEntityMention alloc] init];
	obj.offset = offset;
	obj.length = length;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.offset];
	[stream writeInt:self.length];
}
-(void)unserialize:(SerializedData*)stream {
	super.offset = [stream readInt];
	super.length = [stream readInt];
}
        
-(TL_messageEntityMention *)copy {
    
    TL_messageEntityMention *objc = [[TL_messageEntityMention alloc] init];
    
    objc.offset = self.offset;
    objc.length = self.length;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageEntityHashtag
+(TL_messageEntityHashtag*)createWithOffset:(int)offset length:(int)length {
	TL_messageEntityHashtag* obj = [[TL_messageEntityHashtag alloc] init];
	obj.offset = offset;
	obj.length = length;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.offset];
	[stream writeInt:self.length];
}
-(void)unserialize:(SerializedData*)stream {
	super.offset = [stream readInt];
	super.length = [stream readInt];
}
        
-(TL_messageEntityHashtag *)copy {
    
    TL_messageEntityHashtag *objc = [[TL_messageEntityHashtag alloc] init];
    
    objc.offset = self.offset;
    objc.length = self.length;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageEntityBotCommand
+(TL_messageEntityBotCommand*)createWithOffset:(int)offset length:(int)length {
	TL_messageEntityBotCommand* obj = [[TL_messageEntityBotCommand alloc] init];
	obj.offset = offset;
	obj.length = length;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.offset];
	[stream writeInt:self.length];
}
-(void)unserialize:(SerializedData*)stream {
	super.offset = [stream readInt];
	super.length = [stream readInt];
}
        
-(TL_messageEntityBotCommand *)copy {
    
    TL_messageEntityBotCommand *objc = [[TL_messageEntityBotCommand alloc] init];
    
    objc.offset = self.offset;
    objc.length = self.length;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageEntityUrl
+(TL_messageEntityUrl*)createWithOffset:(int)offset length:(int)length {
	TL_messageEntityUrl* obj = [[TL_messageEntityUrl alloc] init];
	obj.offset = offset;
	obj.length = length;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.offset];
	[stream writeInt:self.length];
}
-(void)unserialize:(SerializedData*)stream {
	super.offset = [stream readInt];
	super.length = [stream readInt];
}
        
-(TL_messageEntityUrl *)copy {
    
    TL_messageEntityUrl *objc = [[TL_messageEntityUrl alloc] init];
    
    objc.offset = self.offset;
    objc.length = self.length;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageEntityEmail
+(TL_messageEntityEmail*)createWithOffset:(int)offset length:(int)length {
	TL_messageEntityEmail* obj = [[TL_messageEntityEmail alloc] init];
	obj.offset = offset;
	obj.length = length;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.offset];
	[stream writeInt:self.length];
}
-(void)unserialize:(SerializedData*)stream {
	super.offset = [stream readInt];
	super.length = [stream readInt];
}
        
-(TL_messageEntityEmail *)copy {
    
    TL_messageEntityEmail *objc = [[TL_messageEntityEmail alloc] init];
    
    objc.offset = self.offset;
    objc.length = self.length;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageEntityBold
+(TL_messageEntityBold*)createWithOffset:(int)offset length:(int)length {
	TL_messageEntityBold* obj = [[TL_messageEntityBold alloc] init];
	obj.offset = offset;
	obj.length = length;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.offset];
	[stream writeInt:self.length];
}
-(void)unserialize:(SerializedData*)stream {
	super.offset = [stream readInt];
	super.length = [stream readInt];
}
        
-(TL_messageEntityBold *)copy {
    
    TL_messageEntityBold *objc = [[TL_messageEntityBold alloc] init];
    
    objc.offset = self.offset;
    objc.length = self.length;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageEntityItalic
+(TL_messageEntityItalic*)createWithOffset:(int)offset length:(int)length {
	TL_messageEntityItalic* obj = [[TL_messageEntityItalic alloc] init];
	obj.offset = offset;
	obj.length = length;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.offset];
	[stream writeInt:self.length];
}
-(void)unserialize:(SerializedData*)stream {
	super.offset = [stream readInt];
	super.length = [stream readInt];
}
        
-(TL_messageEntityItalic *)copy {
    
    TL_messageEntityItalic *objc = [[TL_messageEntityItalic alloc] init];
    
    objc.offset = self.offset;
    objc.length = self.length;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageEntityCode
+(TL_messageEntityCode*)createWithOffset:(int)offset length:(int)length {
	TL_messageEntityCode* obj = [[TL_messageEntityCode alloc] init];
	obj.offset = offset;
	obj.length = length;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.offset];
	[stream writeInt:self.length];
}
-(void)unserialize:(SerializedData*)stream {
	super.offset = [stream readInt];
	super.length = [stream readInt];
}
        
-(TL_messageEntityCode *)copy {
    
    TL_messageEntityCode *objc = [[TL_messageEntityCode alloc] init];
    
    objc.offset = self.offset;
    objc.length = self.length;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageEntityPre
+(TL_messageEntityPre*)createWithOffset:(int)offset length:(int)length language:(NSString*)language {
	TL_messageEntityPre* obj = [[TL_messageEntityPre alloc] init];
	obj.offset = offset;
	obj.length = length;
	obj.language = language;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.offset];
	[stream writeInt:self.length];
	[stream writeString:self.language];
}
-(void)unserialize:(SerializedData*)stream {
	super.offset = [stream readInt];
	super.length = [stream readInt];
	super.language = [stream readString];
}
        
-(TL_messageEntityPre *)copy {
    
    TL_messageEntityPre *objc = [[TL_messageEntityPre alloc] init];
    
    objc.offset = self.offset;
    objc.length = self.length;
    objc.language = self.language;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_messageEntityTextUrl
+(TL_messageEntityTextUrl*)createWithOffset:(int)offset length:(int)length url:(NSString*)url {
	TL_messageEntityTextUrl* obj = [[TL_messageEntityTextUrl alloc] init];
	obj.offset = offset;
	obj.length = length;
	obj.url = url;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.offset];
	[stream writeInt:self.length];
	[stream writeString:self.url];
}
-(void)unserialize:(SerializedData*)stream {
	super.offset = [stream readInt];
	super.length = [stream readInt];
	super.url = [stream readString];
}
        
-(TL_messageEntityTextUrl *)copy {
    
    TL_messageEntityTextUrl *objc = [[TL_messageEntityTextUrl alloc] init];
    
    objc.offset = self.offset;
    objc.length = self.length;
    objc.url = self.url;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLInputChannel

@end
        
@implementation TL_inputChannelEmpty
+(TL_inputChannelEmpty*)create {
	TL_inputChannelEmpty* obj = [[TL_inputChannelEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_inputChannelEmpty *)copy {
    
    TL_inputChannelEmpty *objc = [[TL_inputChannelEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_inputChannel
+(TL_inputChannel*)createWithChannel_id:(int)channel_id access_hash:(long)access_hash {
	TL_inputChannel* obj = [[TL_inputChannel alloc] init];
	obj.channel_id = channel_id;
	obj.access_hash = access_hash;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.channel_id];
	[stream writeLong:self.access_hash];
}
-(void)unserialize:(SerializedData*)stream {
	super.channel_id = [stream readInt];
	super.access_hash = [stream readLong];
}
        
-(TL_inputChannel *)copy {
    
    TL_inputChannel *objc = [[TL_inputChannel alloc] init];
    
    objc.channel_id = self.channel_id;
    objc.access_hash = self.access_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLcontacts_ResolvedPeer

@end
        
@implementation TL_contacts_resolvedPeer
+(TL_contacts_resolvedPeer*)createWithPeer:(TLPeer*)peer chats:(NSMutableArray*)chats users:(NSMutableArray*)users {
	TL_contacts_resolvedPeer* obj = [[TL_contacts_resolvedPeer alloc] init];
	obj.peer = peer;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.peer stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChat* obj = [self.chats objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.peer = [ClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChat class]])
                 [self.chats addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_contacts_resolvedPeer *)copy {
    
    TL_contacts_resolvedPeer *objc = [[TL_contacts_resolvedPeer alloc] init];
    
    objc.peer = [self.peer copy];
    objc.chats = [self.chats copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLMessageRange

@end
        
@implementation TL_messageRange
+(TL_messageRange*)createWithMin_id:(int)min_id max_id:(int)max_id {
	TL_messageRange* obj = [[TL_messageRange alloc] init];
	obj.min_id = min_id;
	obj.max_id = max_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.min_id];
	[stream writeInt:self.max_id];
}
-(void)unserialize:(SerializedData*)stream {
	super.min_id = [stream readInt];
	super.max_id = [stream readInt];
}
        
-(TL_messageRange *)copy {
    
    TL_messageRange *objc = [[TL_messageRange alloc] init];
    
    objc.min_id = self.min_id;
    objc.max_id = self.max_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLMessageGroup

@end
        
@implementation TL_messageGroup
+(TL_messageGroup*)createWithMin_id:(int)min_id max_id:(int)max_id n_count:(int)n_count date:(int)date {
	TL_messageGroup* obj = [[TL_messageGroup alloc] init];
	obj.min_id = min_id;
	obj.max_id = max_id;
	obj.n_count = n_count;
	obj.date = date;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.min_id];
	[stream writeInt:self.max_id];
	[stream writeInt:self.n_count];
	[stream writeInt:self.date];
}
-(void)unserialize:(SerializedData*)stream {
	super.min_id = [stream readInt];
	super.max_id = [stream readInt];
	super.n_count = [stream readInt];
	super.date = [stream readInt];
}
        
-(TL_messageGroup *)copy {
    
    TL_messageGroup *objc = [[TL_messageGroup alloc] init];
    
    objc.min_id = self.min_id;
    objc.max_id = self.max_id;
    objc.n_count = self.n_count;
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLupdates_ChannelDifference
            
-(BOOL)isFinal {return NO;}
            
@end
        
@implementation TL_updates_channelDifferenceEmpty
+(TL_updates_channelDifferenceEmpty*)createWithFlags:(int)flags  pts:(int)pts timeout:(int)timeout {
	TL_updates_channelDifferenceEmpty* obj = [[TL_updates_channelDifferenceEmpty alloc] init];
	obj.flags = flags;
	
	obj.pts = pts;
	obj.timeout = timeout;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	[stream writeInt:self.pts];
	if(self.flags & (1 << 1)) {[stream writeInt:self.timeout];}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	super.pts = [stream readInt];
	if(self.flags & (1 << 1)) {super.timeout = [stream readInt];}
}
        
-(TL_updates_channelDifferenceEmpty *)copy {
    
    TL_updates_channelDifferenceEmpty *objc = [[TL_updates_channelDifferenceEmpty alloc] init];
    
    objc.flags = self.flags;
    
    objc.pts = self.pts;
    objc.timeout = self.timeout;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isFinal {return (self.flags & (1 << 0)) > 0;}
                        
-(void)setTimeout:(int)timeout
{
   super.timeout = timeout;
                
    if(super.timeout == 0)  { super.flags&= ~ (1 << 1) ;} else { super.flags|= (1 << 1); }
}
        
@end

@implementation TL_updates_channelDifferenceTooLong
+(TL_updates_channelDifferenceTooLong*)createWithFlags:(int)flags  pts:(int)pts timeout:(int)timeout top_message:(int)top_message top_important_message:(int)top_important_message read_inbox_max_id:(int)read_inbox_max_id unread_count:(int)unread_count unread_important_count:(int)unread_important_count messages:(NSMutableArray*)messages chats:(NSMutableArray*)chats users:(NSMutableArray*)users {
	TL_updates_channelDifferenceTooLong* obj = [[TL_updates_channelDifferenceTooLong alloc] init];
	obj.flags = flags;
	
	obj.pts = pts;
	obj.timeout = timeout;
	obj.top_message = top_message;
	obj.top_important_message = top_important_message;
	obj.read_inbox_max_id = read_inbox_max_id;
	obj.unread_count = unread_count;
	obj.unread_important_count = unread_important_count;
	obj.messages = messages;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	[stream writeInt:self.pts];
	if(self.flags & (1 << 1)) {[stream writeInt:self.timeout];}
	[stream writeInt:self.top_message];
	[stream writeInt:self.top_important_message];
	[stream writeInt:self.read_inbox_max_id];
	[stream writeInt:self.unread_count];
	[stream writeInt:self.unread_important_count];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLMessage* obj = [self.messages objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChat* obj = [self.chats objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	super.pts = [stream readInt];
	if(self.flags & (1 << 1)) {super.timeout = [stream readInt];}
	super.top_message = [stream readInt];
	super.top_important_message = [stream readInt];
	super.read_inbox_max_id = [stream readInt];
	super.unread_count = [stream readInt];
	super.unread_important_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.messages)
			self.messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessage* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLMessage class]])
                 [self.messages addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChat class]])
                 [self.chats addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_updates_channelDifferenceTooLong *)copy {
    
    TL_updates_channelDifferenceTooLong *objc = [[TL_updates_channelDifferenceTooLong alloc] init];
    
    objc.flags = self.flags;
    
    objc.pts = self.pts;
    objc.timeout = self.timeout;
    objc.top_message = self.top_message;
    objc.top_important_message = self.top_important_message;
    objc.read_inbox_max_id = self.read_inbox_max_id;
    objc.unread_count = self.unread_count;
    objc.unread_important_count = self.unread_important_count;
    objc.messages = [self.messages copy];
    objc.chats = [self.chats copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isFinal {return (self.flags & (1 << 0)) > 0;}
                        
-(void)setTimeout:(int)timeout
{
   super.timeout = timeout;
                
    if(super.timeout == 0)  { super.flags&= ~ (1 << 1) ;} else { super.flags|= (1 << 1); }
}
        
@end

@implementation TL_updates_channelDifference
+(TL_updates_channelDifference*)createWithFlags:(int)flags  pts:(int)pts timeout:(int)timeout n_messages:(NSMutableArray*)n_messages other_updates:(NSMutableArray*)other_updates chats:(NSMutableArray*)chats users:(NSMutableArray*)users {
	TL_updates_channelDifference* obj = [[TL_updates_channelDifference alloc] init];
	obj.flags = flags;
	
	obj.pts = pts;
	obj.timeout = timeout;
	obj.n_messages = n_messages;
	obj.other_updates = other_updates;
	obj.chats = chats;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	[stream writeInt:self.pts];
	if(self.flags & (1 << 1)) {[stream writeInt:self.timeout];}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.n_messages count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLMessage* obj = [self.n_messages objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.other_updates count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUpdate* obj = [self.other_updates objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.chats count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChat* obj = [self.chats objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	super.pts = [stream readInt];
	if(self.flags & (1 << 1)) {super.timeout = [stream readInt];}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.n_messages)
			self.n_messages = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessage* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLMessage class]])
                 [self.n_messages addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.other_updates)
			self.other_updates = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUpdate* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUpdate class]])
                 [self.other_updates addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.chats)
			self.chats = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChat* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChat class]])
                 [self.chats addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_updates_channelDifference *)copy {
    
    TL_updates_channelDifference *objc = [[TL_updates_channelDifference alloc] init];
    
    objc.flags = self.flags;
    
    objc.pts = self.pts;
    objc.timeout = self.timeout;
    objc.n_messages = [self.n_messages copy];
    objc.other_updates = [self.other_updates copy];
    objc.chats = [self.chats copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isFinal {return (self.flags & (1 << 0)) > 0;}
                        
-(void)setTimeout:(int)timeout
{
   super.timeout = timeout;
                
    if(super.timeout == 0)  { super.flags&= ~ (1 << 1) ;} else { super.flags|= (1 << 1); }
}
        
@end

@implementation TLChannelMessagesFilter
            
-(BOOL)isImportant_only {return NO;}
                        
-(BOOL)isExclude_new_messages {return NO;}
            
@end
        
@implementation TL_channelMessagesFilterEmpty
+(TL_channelMessagesFilterEmpty*)create {
	TL_channelMessagesFilterEmpty* obj = [[TL_channelMessagesFilterEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_channelMessagesFilterEmpty *)copy {
    
    TL_channelMessagesFilterEmpty *objc = [[TL_channelMessagesFilterEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_channelMessagesFilter
+(TL_channelMessagesFilter*)createWithFlags:(int)flags   ranges:(NSMutableArray*)ranges {
	TL_channelMessagesFilter* obj = [[TL_channelMessagesFilter alloc] init];
	obj.flags = flags;
	
	
	obj.ranges = ranges;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.flags];
	
	
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.ranges count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLMessageRange* obj = [self.ranges objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.flags = [stream readInt];
	
	
	//UNS FullVector
	[stream readInt];
	{
		if(!self.ranges)
			self.ranges = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLMessageRange* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLMessageRange class]])
                 [self.ranges addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_channelMessagesFilter *)copy {
    
    TL_channelMessagesFilter *objc = [[TL_channelMessagesFilter alloc] init];
    
    objc.flags = self.flags;
    
    
    objc.ranges = [self.ranges copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        
            
-(BOOL)isImportant_only {return (self.flags & (1 << 0)) > 0;}
                        
-(BOOL)isExclude_new_messages {return (self.flags & (1 << 1)) > 0;}
            
        
@end

@implementation TL_channelMessagesFilterCollapsed
+(TL_channelMessagesFilterCollapsed*)create {
	TL_channelMessagesFilterCollapsed* obj = [[TL_channelMessagesFilterCollapsed alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_channelMessagesFilterCollapsed *)copy {
    
    TL_channelMessagesFilterCollapsed *objc = [[TL_channelMessagesFilterCollapsed alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLChannelParticipant

@end
        
@implementation TL_channelParticipant
+(TL_channelParticipant*)createWithUser_id:(int)user_id date:(int)date {
	TL_channelParticipant* obj = [[TL_channelParticipant alloc] init];
	obj.user_id = user_id;
	obj.date = date;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
}
-(void)unserialize:(SerializedData*)stream {
	super.user_id = [stream readInt];
	super.date = [stream readInt];
}
        
-(TL_channelParticipant *)copy {
    
    TL_channelParticipant *objc = [[TL_channelParticipant alloc] init];
    
    objc.user_id = self.user_id;
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_channelParticipantSelf
+(TL_channelParticipantSelf*)createWithUser_id:(int)user_id inviter_id:(int)inviter_id date:(int)date {
	TL_channelParticipantSelf* obj = [[TL_channelParticipantSelf alloc] init];
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
	super.user_id = [stream readInt];
	super.inviter_id = [stream readInt];
	super.date = [stream readInt];
}
        
-(TL_channelParticipantSelf *)copy {
    
    TL_channelParticipantSelf *objc = [[TL_channelParticipantSelf alloc] init];
    
    objc.user_id = self.user_id;
    objc.inviter_id = self.inviter_id;
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_channelParticipantModerator
+(TL_channelParticipantModerator*)createWithUser_id:(int)user_id inviter_id:(int)inviter_id date:(int)date {
	TL_channelParticipantModerator* obj = [[TL_channelParticipantModerator alloc] init];
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
	super.user_id = [stream readInt];
	super.inviter_id = [stream readInt];
	super.date = [stream readInt];
}
        
-(TL_channelParticipantModerator *)copy {
    
    TL_channelParticipantModerator *objc = [[TL_channelParticipantModerator alloc] init];
    
    objc.user_id = self.user_id;
    objc.inviter_id = self.inviter_id;
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_channelParticipantEditor
+(TL_channelParticipantEditor*)createWithUser_id:(int)user_id inviter_id:(int)inviter_id date:(int)date {
	TL_channelParticipantEditor* obj = [[TL_channelParticipantEditor alloc] init];
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
	super.user_id = [stream readInt];
	super.inviter_id = [stream readInt];
	super.date = [stream readInt];
}
        
-(TL_channelParticipantEditor *)copy {
    
    TL_channelParticipantEditor *objc = [[TL_channelParticipantEditor alloc] init];
    
    objc.user_id = self.user_id;
    objc.inviter_id = self.inviter_id;
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_channelParticipantKicked
+(TL_channelParticipantKicked*)createWithUser_id:(int)user_id kicked_by:(int)kicked_by date:(int)date {
	TL_channelParticipantKicked* obj = [[TL_channelParticipantKicked alloc] init];
	obj.user_id = user_id;
	obj.kicked_by = kicked_by;
	obj.date = date;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
	[stream writeInt:self.kicked_by];
	[stream writeInt:self.date];
}
-(void)unserialize:(SerializedData*)stream {
	super.user_id = [stream readInt];
	super.kicked_by = [stream readInt];
	super.date = [stream readInt];
}
        
-(TL_channelParticipantKicked *)copy {
    
    TL_channelParticipantKicked *objc = [[TL_channelParticipantKicked alloc] init];
    
    objc.user_id = self.user_id;
    objc.kicked_by = self.kicked_by;
    objc.date = self.date;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_channelParticipantCreator
+(TL_channelParticipantCreator*)createWithUser_id:(int)user_id {
	TL_channelParticipantCreator* obj = [[TL_channelParticipantCreator alloc] init];
	obj.user_id = user_id;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.user_id];
}
-(void)unserialize:(SerializedData*)stream {
	super.user_id = [stream readInt];
}
        
-(TL_channelParticipantCreator *)copy {
    
    TL_channelParticipantCreator *objc = [[TL_channelParticipantCreator alloc] init];
    
    objc.user_id = self.user_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLChannelParticipantsFilter

@end
        
@implementation TL_channelParticipantsRecent
+(TL_channelParticipantsRecent*)create {
	TL_channelParticipantsRecent* obj = [[TL_channelParticipantsRecent alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_channelParticipantsRecent *)copy {
    
    TL_channelParticipantsRecent *objc = [[TL_channelParticipantsRecent alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_channelParticipantsAdmins
+(TL_channelParticipantsAdmins*)create {
	TL_channelParticipantsAdmins* obj = [[TL_channelParticipantsAdmins alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_channelParticipantsAdmins *)copy {
    
    TL_channelParticipantsAdmins *objc = [[TL_channelParticipantsAdmins alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_channelParticipantsKicked
+(TL_channelParticipantsKicked*)create {
	TL_channelParticipantsKicked* obj = [[TL_channelParticipantsKicked alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_channelParticipantsKicked *)copy {
    
    TL_channelParticipantsKicked *objc = [[TL_channelParticipantsKicked alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_channelParticipantsBots
+(TL_channelParticipantsBots*)create {
	TL_channelParticipantsBots* obj = [[TL_channelParticipantsBots alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_channelParticipantsBots *)copy {
    
    TL_channelParticipantsBots *objc = [[TL_channelParticipantsBots alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLChannelParticipantRole

@end
        
@implementation TL_channelRoleEmpty
+(TL_channelRoleEmpty*)create {
	TL_channelRoleEmpty* obj = [[TL_channelRoleEmpty alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_channelRoleEmpty *)copy {
    
    TL_channelRoleEmpty *objc = [[TL_channelRoleEmpty alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_channelRoleModerator
+(TL_channelRoleModerator*)create {
	TL_channelRoleModerator* obj = [[TL_channelRoleModerator alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_channelRoleModerator *)copy {
    
    TL_channelRoleModerator *objc = [[TL_channelRoleModerator alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TL_channelRoleEditor
+(TL_channelRoleEditor*)create {
	TL_channelRoleEditor* obj = [[TL_channelRoleEditor alloc] init];
	
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	
}
-(void)unserialize:(SerializedData*)stream {
	
}
        
-(TL_channelRoleEditor *)copy {
    
    TL_channelRoleEditor *objc = [[TL_channelRoleEditor alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLchannels_ChannelParticipants

@end
        
@implementation TL_channels_channelParticipants
+(TL_channels_channelParticipants*)createWithN_count:(int)n_count participants:(NSMutableArray*)participants users:(NSMutableArray*)users {
	TL_channels_channelParticipants* obj = [[TL_channels_channelParticipants alloc] init];
	obj.n_count = n_count;
	obj.participants = participants;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_count];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.participants count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLChannelParticipant* obj = [self.participants objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.n_count = [stream readInt];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.participants)
			self.participants = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLChannelParticipant* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLChannelParticipant class]])
                 [self.participants addObject:obj];
            else
                break;
		}
	}
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_channels_channelParticipants *)copy {
    
    TL_channels_channelParticipants *objc = [[TL_channels_channelParticipants alloc] init];
    
    objc.n_count = self.n_count;
    objc.participants = [self.participants copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLchannels_ChannelParticipant

@end
        
@implementation TL_channels_channelParticipant
+(TL_channels_channelParticipant*)createWithParticipant:(TLChannelParticipant*)participant users:(NSMutableArray*)users {
	TL_channels_channelParticipant* obj = [[TL_channels_channelParticipant alloc] init];
	obj.participant = participant;
	obj.users = users;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[ClassStore TLSerialize:self.participant stream:stream];
	//Serialize FullVector
	[stream writeInt:0x1cb5c415];
	{
		NSInteger tl_count = [self.users count];
		[stream writeInt:(int)tl_count];
		for(int i = 0; i < (int)tl_count; i++) {
            TLUser* obj = [self.users objectAtIndex:i];
            [ClassStore TLSerialize:obj stream:stream];
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	self.participant = [ClassStore TLDeserialize:stream];
	//UNS FullVector
	[stream readInt];
	{
		if(!self.users)
			self.users = [[NSMutableArray alloc] init];
		int count = [stream readInt];
		for(int i = 0; i < count; i++) {
			TLUser* obj = [ClassStore TLDeserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TLUser class]])
                 [self.users addObject:obj];
            else
                break;
		}
	}
}
        
-(TL_channels_channelParticipant *)copy {
    
    TL_channels_channelParticipant *objc = [[TL_channels_channelParticipant alloc] init];
    
    objc.participant = [self.participant copy];
    objc.users = [self.users copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end

@implementation TLhelp_TermsOfService

@end
        
@implementation TL_help_termsOfService
+(TL_help_termsOfService*)createWithText:(NSString*)text {
	TL_help_termsOfService* obj = [[TL_help_termsOfService alloc] init];
	obj.text = text;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.text];
}
-(void)unserialize:(SerializedData*)stream {
	super.text = [stream readString];
}
        
-(TL_help_termsOfService *)copy {
    
    TL_help_termsOfService *objc = [[TL_help_termsOfService alloc] init];
    
    objc.text = self.text;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.body stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.msg_id = [stream readLong];
	super.seqno = [stream readInt];
	super.bytes = [stream readInt];
	self.body = [ClassStore TLDeserialize:stream];
}
        
-(TL_proto_message *)copy {
    
    TL_proto_message *objc = [[TL_proto_message alloc] init];
    
    objc.msg_id = self.msg_id;
    objc.seqno = self.seqno;
    objc.bytes = self.bytes;
    objc.body = [self.body copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            if(obj != nil && [obj isKindOfClass:[TL_proto_message class]])
                [self.messages addObject:obj];
            else break;
		}
	}
}
        
-(TL_msg_container *)copy {
    
    TL_msg_container *objc = [[TL_msg_container alloc] init];
    
    objc.messages = [self.messages copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.nonce = [stream readData:16];
}
        
-(TL_req_pq *)copy {
    
    TL_req_pq *objc = [[TL_req_pq alloc] init];
    
    objc.nonce = self.nonce;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            if([self.server_public_key_fingerprints count] > i) {
                NSNumber* obj = [self.server_public_key_fingerprints objectAtIndex:i];
			[stream writeLong:[obj longValue]];
            }  else
                break;
		}
	}
}
-(void)unserialize:(SerializedData*)stream {
	super.nonce = [stream readData:16];
	super.server_nonce = [stream readData:16];
	super.pq = [stream readByteArray];
	//UNS ShortVector
	[stream readInt];
	{
		if(!self.server_public_key_fingerprints)
			self.server_public_key_fingerprints = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			long obj = [stream readLong];
			[self.server_public_key_fingerprints addObject:@(obj)];
		}
	}
}
        
-(TL_resPQ *)copy {
    
    TL_resPQ *objc = [[TL_resPQ alloc] init];
    
    objc.nonce = self.nonce;
    objc.server_nonce = self.server_nonce;
    objc.pq = [self.pq copy];
    objc.server_public_key_fingerprints = [self.server_public_key_fingerprints copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.nonce = [stream readData:16];
	super.server_nonce = [stream readData:16];
	super.g = [stream readInt];
	super.dh_prime = [stream readByteArray];
	super.g_a = [stream readByteArray];
	super.server_time = [stream readInt];
}
        
-(TL_server_DH_inner_data *)copy {
    
    TL_server_DH_inner_data *objc = [[TL_server_DH_inner_data alloc] init];
    
    objc.nonce = self.nonce;
    objc.server_nonce = self.server_nonce;
    objc.g = self.g;
    objc.dh_prime = [self.dh_prime copy];
    objc.g_a = [self.g_a copy];
    objc.server_time = self.server_time;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.pq = [stream readByteArray];
	super.p = [stream readByteArray];
	super.q = [stream readByteArray];
	super.nonce = [stream readData:16];
	super.server_nonce = [stream readData:16];
	super.n_nonce = [stream readData:32];
}
        
-(TL_p_q_inner_data *)copy {
    
    TL_p_q_inner_data *objc = [[TL_p_q_inner_data alloc] init];
    
    objc.pq = [self.pq copy];
    objc.p = [self.p copy];
    objc.q = [self.q copy];
    objc.nonce = self.nonce;
    objc.server_nonce = self.server_nonce;
    objc.n_nonce = self.n_nonce;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.nonce = [stream readData:16];
	super.server_nonce = [stream readData:16];
	super.p = [stream readByteArray];
	super.q = [stream readByteArray];
	super.public_key_fingerprint = [stream readLong];
	super.encrypted_data = [stream readByteArray];
}
        
-(TL_req_DH_params *)copy {
    
    TL_req_DH_params *objc = [[TL_req_DH_params alloc] init];
    
    objc.nonce = self.nonce;
    objc.server_nonce = self.server_nonce;
    objc.p = [self.p copy];
    objc.q = [self.q copy];
    objc.public_key_fingerprint = self.public_key_fingerprint;
    objc.encrypted_data = [self.encrypted_data copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.nonce = [stream readData:16];
	super.server_nonce = [stream readData:16];
	super.n_nonce_hash = [stream readData:16];
}
        
-(TL_server_DH_params_fail *)copy {
    
    TL_server_DH_params_fail *objc = [[TL_server_DH_params_fail alloc] init];
    
    objc.nonce = self.nonce;
    objc.server_nonce = self.server_nonce;
    objc.n_nonce_hash = self.n_nonce_hash;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.nonce = [stream readData:16];
	super.server_nonce = [stream readData:16];
	super.encrypted_answer = [stream readByteArray];
}
        
-(TL_server_DH_params_ok *)copy {
    
    TL_server_DH_params_ok *objc = [[TL_server_DH_params_ok alloc] init];
    
    objc.nonce = self.nonce;
    objc.server_nonce = self.server_nonce;
    objc.encrypted_answer = [self.encrypted_answer copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.nonce = [stream readData:16];
	super.server_nonce = [stream readData:16];
	super.retry_id = [stream readLong];
	super.g_b = [stream readByteArray];
}
        
-(TL_client_DH_inner_data *)copy {
    
    TL_client_DH_inner_data *objc = [[TL_client_DH_inner_data alloc] init];
    
    objc.nonce = self.nonce;
    objc.server_nonce = self.server_nonce;
    objc.retry_id = self.retry_id;
    objc.g_b = [self.g_b copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.nonce = [stream readData:16];
	super.server_nonce = [stream readData:16];
	super.encrypted_data = [stream readByteArray];
}
        
-(TL_set_client_DH_params *)copy {
    
    TL_set_client_DH_params *objc = [[TL_set_client_DH_params alloc] init];
    
    objc.nonce = self.nonce;
    objc.server_nonce = self.server_nonce;
    objc.encrypted_data = [self.encrypted_data copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.nonce = [stream readData:16];
	super.server_nonce = [stream readData:16];
	super.n_nonce_hash1 = [stream readData:16];
}
        
-(TL_dh_gen_ok *)copy {
    
    TL_dh_gen_ok *objc = [[TL_dh_gen_ok alloc] init];
    
    objc.nonce = self.nonce;
    objc.server_nonce = self.server_nonce;
    objc.n_nonce_hash1 = self.n_nonce_hash1;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.nonce = [stream readData:16];
	super.server_nonce = [stream readData:16];
	super.n_nonce_hash2 = [stream readData:16];
}
        
-(TL_dh_gen_retry *)copy {
    
    TL_dh_gen_retry *objc = [[TL_dh_gen_retry alloc] init];
    
    objc.nonce = self.nonce;
    objc.server_nonce = self.server_nonce;
    objc.n_nonce_hash2 = self.n_nonce_hash2;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.nonce = [stream readData:16];
	super.server_nonce = [stream readData:16];
	super.n_nonce_hash3 = [stream readData:16];
}
        
-(TL_dh_gen_fail *)copy {
    
    TL_dh_gen_fail *objc = [[TL_dh_gen_fail alloc] init];
    
    objc.nonce = self.nonce;
    objc.server_nonce = self.server_nonce;
    objc.n_nonce_hash3 = self.n_nonce_hash3;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.ping_id = [stream readLong];
}
        
-(TL_ping *)copy {
    
    TL_ping *objc = [[TL_ping alloc] init];
    
    objc.ping_id = self.ping_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.msg_id = [stream readLong];
	super.ping_id = [stream readLong];
}
        
-(TL_pong *)copy {
    
    TL_pong *objc = [[TL_pong alloc] init];
    
    objc.msg_id = self.msg_id;
    objc.ping_id = self.ping_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.bad_msg_id = [stream readLong];
	super.bad_msg_seqno = [stream readInt];
	super.error_code = [stream readInt];
}
        
-(TL_bad_msg_notification *)copy {
    
    TL_bad_msg_notification *objc = [[TL_bad_msg_notification alloc] init];
    
    objc.bad_msg_id = self.bad_msg_id;
    objc.bad_msg_seqno = self.bad_msg_seqno;
    objc.error_code = self.error_code;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.bad_msg_id = [stream readLong];
	super.bad_msg_seqno = [stream readInt];
	super.error_code = [stream readInt];
	super.new_server_salt = [stream readLong];
}
        
-(TL_bad_server_salt *)copy {
    
    TL_bad_server_salt *objc = [[TL_bad_server_salt alloc] init];
    
    objc.bad_msg_id = self.bad_msg_id;
    objc.bad_msg_seqno = self.bad_msg_seqno;
    objc.error_code = self.error_code;
    objc.new_server_salt = self.new_server_salt;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.first_msg_id = [stream readLong];
	super.unique_id = [stream readLong];
	super.server_salt = [stream readLong];
}
        
-(TL_new_session_created *)copy {
    
    TL_new_session_created *objc = [[TL_new_session_created alloc] init];
    
    objc.first_msg_id = self.first_msg_id;
    objc.unique_id = self.unique_id;
    objc.server_salt = self.server_salt;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.result stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	super.req_msg_id = [stream readLong];
	self.result = [ClassStore TLDeserialize:stream];
}
        
-(TL_rpc_result *)copy {
    
    TL_rpc_result *objc = [[TL_rpc_result alloc] init];
    
    objc.req_msg_id = self.req_msg_id;
    objc.result = [self.result copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.error_code = [stream readInt];
	super.error_message = [stream readString];
}
        
-(TL_rpc_error *)copy {
    
    TL_rpc_error *objc = [[TL_rpc_error alloc] init];
    
    objc.error_code = self.error_code;
    objc.error_message = self.error_message;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.n = [stream readByteArray];
	super.e = [stream readByteArray];
}
        
-(TL_rsa_public_key *)copy {
    
    TL_rsa_public_key *objc = [[TL_rsa_public_key alloc] init];
    
    objc.n = [self.n copy];
    objc.e = [self.e copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            if([self.msg_ids count] > i) {
                NSNumber* obj = [self.msg_ids objectAtIndex:i];
			[stream writeLong:[obj longValue]];
            }  else
                break;
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
			[self.msg_ids addObject:@(obj)];
		}
	}
}
        
-(TL_msgs_ack *)copy {
    
    TL_msgs_ack *objc = [[TL_msgs_ack alloc] init];
    
    objc.msg_ids = [self.msg_ids copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.req_msg_id = [stream readLong];
}
        
-(TL_rpc_drop_answer *)copy {
    
    TL_rpc_drop_answer *objc = [[TL_rpc_drop_answer alloc] init];
    
    objc.req_msg_id = self.req_msg_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_rpc_answer_unknown *)copy {
    
    TL_rpc_answer_unknown *objc = [[TL_rpc_answer_unknown alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
        
-(TL_rpc_answer_dropped_running *)copy {
    
    TL_rpc_answer_dropped_running *objc = [[TL_rpc_answer_dropped_running alloc] init];
    
    
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.msg_id = [stream readLong];
	super.seq_no = [stream readInt];
	super.bytes = [stream readInt];
}
        
-(TL_rpc_answer_dropped *)copy {
    
    TL_rpc_answer_dropped *objc = [[TL_rpc_answer_dropped alloc] init];
    
    objc.msg_id = self.msg_id;
    objc.seq_no = self.seq_no;
    objc.bytes = self.bytes;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.num = [stream readInt];
}
        
-(TL_get_future_salts *)copy {
    
    TL_get_future_salts *objc = [[TL_get_future_salts alloc] init];
    
    objc.num = self.num;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.req_msg_id = [stream readLong];
	super.now = [stream readInt];
	//UNS ShortVector (custom class) //TODO
	{
		if(!self.salts)
			self.salts = [[NSMutableArray alloc] init];
		int tl_count = [stream readInt];
		for(int i = 0; i < tl_count; i++) {
			TL_future_salt* obj = [[TL_future_salt alloc] init];
			[obj unserialize:stream];
            if(obj != nil && [obj isKindOfClass:[TL_future_salt class]])
                [self.salts addObject:obj];
            else break;
		}
	}
}
        
-(TL_future_salts *)copy {
    
    TL_future_salts *objc = [[TL_future_salts alloc] init];
    
    objc.req_msg_id = self.req_msg_id;
    objc.now = self.now;
    objc.salts = [self.salts copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.valid_since = [stream readInt];
	super.valid_until = [stream readInt];
	super.salt = [stream readLong];
}
        
-(TL_future_salt *)copy {
    
    TL_future_salt *objc = [[TL_future_salt alloc] init];
    
    objc.valid_since = self.valid_since;
    objc.valid_until = self.valid_until;
    objc.salt = self.salt;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.session_id = [stream readLong];
}
        
-(TL_destroy_session *)copy {
    
    TL_destroy_session *objc = [[TL_destroy_session alloc] init];
    
    objc.session_id = self.session_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.session_id = [stream readLong];
}
        
-(TL_destroy_session_ok *)copy {
    
    TL_destroy_session_ok *objc = [[TL_destroy_session_ok alloc] init];
    
    objc.session_id = self.session_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.session_id = [stream readLong];
}
        
-(TL_destroy_session_none *)copy {
    
    TL_destroy_session_none *objc = [[TL_destroy_session_none alloc] init];
    
    objc.session_id = self.session_id;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	[ClassStore TLSerialize:self.orig_message stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
	self.orig_message = [ClassStore TLDeserialize:stream];
}
        
-(TL_msg_copy *)copy {
    
    TL_msg_copy *objc = [[TL_msg_copy alloc] init];
    
    objc.orig_message = [self.orig_message copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.packed_data = [stream readByteArray];
}
        
-(TL_gzip_packed *)copy {
    
    TL_gzip_packed *objc = [[TL_gzip_packed alloc] init];
    
    objc.packed_data = [self.packed_data copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.max_delay = [stream readInt];
	super.wait_after = [stream readInt];
	super.max_wait = [stream readInt];
}
        
-(TL_http_wait *)copy {
    
    TL_http_wait *objc = [[TL_http_wait alloc] init];
    
    objc.max_delay = self.max_delay;
    objc.wait_after = self.wait_after;
    objc.max_wait = self.max_wait;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            if([self.msg_ids count] > i) {
                NSNumber* obj = [self.msg_ids objectAtIndex:i];
			[stream writeLong:[obj longValue]];
            }  else
                break;
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
			[self.msg_ids addObject:@(obj)];
		}
	}
}
        
-(TL_msgs_state_req *)copy {
    
    TL_msgs_state_req *objc = [[TL_msgs_state_req alloc] init];
    
    objc.msg_ids = [self.msg_ids copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.req_msg_id = [stream readLong];
	super.info = [stream readByteArray];
}
        
-(TL_msgs_state_info *)copy {
    
    TL_msgs_state_info *objc = [[TL_msgs_state_info alloc] init];
    
    objc.req_msg_id = self.req_msg_id;
    objc.info = [self.info copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            if([self.msg_ids count] > i) {
                NSNumber* obj = [self.msg_ids objectAtIndex:i];
			[stream writeLong:[obj longValue]];
            }  else
                break;
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
			[self.msg_ids addObject:@(obj)];
		}
	}
	super.info = [stream readByteArray];
}
        
-(TL_msgs_all_info *)copy {
    
    TL_msgs_all_info *objc = [[TL_msgs_all_info alloc] init];
    
    objc.msg_ids = [self.msg_ids copy];
    objc.info = [self.info copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.msg_id = [stream readLong];
	super.answer_msg_id = [stream readLong];
	super.bytes = [stream readInt];
	super.status = [stream readInt];
}
        
-(TL_msg_detailed_info *)copy {
    
    TL_msg_detailed_info *objc = [[TL_msg_detailed_info alloc] init];
    
    objc.msg_id = self.msg_id;
    objc.answer_msg_id = self.answer_msg_id;
    objc.bytes = self.bytes;
    objc.status = self.status;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
	super.answer_msg_id = [stream readLong];
	super.bytes = [stream readInt];
	super.status = [stream readInt];
}
        
-(TL_msg_new_detailed_info *)copy {
    
    TL_msg_new_detailed_info *objc = [[TL_msg_new_detailed_info alloc] init];
    
    objc.answer_msg_id = self.answer_msg_id;
    objc.bytes = self.bytes;
    objc.status = self.status;
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
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
            if([self.msg_ids count] > i) {
                NSNumber* obj = [self.msg_ids objectAtIndex:i];
			[stream writeLong:[obj longValue]];
            }  else
                break;
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
			[self.msg_ids addObject:@(obj)];
		}
	}
}
        
-(TL_msg_resend_req *)copy {
    
    TL_msg_resend_req *objc = [[TL_msg_resend_req alloc] init];
    
    objc.msg_ids = [self.msg_ids copy];
    
    return objc;
}
        

    
-(id)initWithCoder:(NSCoder *)aDecoder {

    if((self = [ClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}
        
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[ClassStore serialize:self] forKey:@"data"];
}
        

        
@end
