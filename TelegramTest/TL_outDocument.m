//
//  TL_outDocument.m
//  Messenger for Telegram
//
//  Created by keepcoder on 09.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_outDocument.h"

@implementation TL_outDocument
+(TL_outDocument *)createWithN_id:(long)n_id access_hash:(long)access_hash user_id:(int)user_id date:(int)date file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(int)size thumb:(TLPhotoSize *)thumb dc_id:(int)dc_id file_path:(NSString *)file_path {
    TL_outDocument *document = [[TL_outDocument alloc] init];
    document.n_id = n_id;
    document.access_hash = access_hash;
    document.user_id = user_id;
    document.date = date;
    document.file_name = file_name;
    document.mime_type = mime_type;
    document.size = size;
    document.thumb = thumb;
    document.dc_id = dc_id;
    document.file_path = file_path;
    
    return document;
}

+(TL_outDocument *)outWithDocument:(TL_document *)document file_path:(NSString *)file_path {
    return [self createWithN_id:document.n_id access_hash:document.access_hash user_id:document.user_id date:document.date file_name:document.file_name mime_type:document.mime_type size:document.size thumb:document.thumb dc_id:document.dc_id file_path:file_path];
}


- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.user_id];
	[stream writeInt:self.date];
	[stream writeString:self.file_name];
	[stream writeString:self.mime_type];
	[stream writeInt:self.size];
	[TLClassStore TLSerialize:self.thumb stream:stream];
	[stream writeInt:self.dc_id];
    [stream writeString:self.file_path];
}


- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
	self.user_id = [stream readInt];
	self.date = [stream readInt];
	self.file_name = [stream readString];
	self.mime_type = [stream readString];
	self.size = [stream readInt];
	self.thumb = [TLClassStore TLDeserialize:stream];
	self.dc_id = [stream readInt];
    self.file_path = [stream readString];
    
}


@end
