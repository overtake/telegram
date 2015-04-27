//
//  TL_outDocument.m
//  Messenger for Telegram
//
//  Created by keepcoder on 09.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_outDocument.h"

@implementation TL_outDocument
+(TL_outDocument *)createWithN_id:(long)n_id access_hash:(long)access_hash date:(int)date mime_type:(NSString *)mime_type size:(int)size thumb:(TLPhotoSize *)thumb dc_id:(int)dc_id file_path:(NSString *)file_path attributes:(NSMutableArray *)attributes {
    TL_outDocument *document = [[TL_outDocument alloc] init];
    document.n_id = n_id;
    document.access_hash = access_hash;
    document.date = date;
    document.mime_type = mime_type;
    document.size = size;
    document.thumb = thumb;
    document.dc_id = dc_id;
    document.file_path = file_path;
    document.attributes = attributes;
    return document;
}


+(TL_outDocument *)outWithDocument:(TL_document *)document file_path:(NSString *)file_path {
    return [self createWithN_id:document.n_id access_hash:document.access_hash date:document.date mime_type:document.mime_type size:document.size thumb:document.thumb dc_id:document.dc_id file_path:file_path attributes:document.attributes];
}


- (void)serialize:(SerializedData *)stream {
	[stream writeLong:self.n_id];
	[stream writeLong:self.access_hash];
	[stream writeInt:self.date];
	[stream writeString:self.mime_type];
	[stream writeInt:self.size];
	[TLClassStore TLSerialize:self.thumb stream:stream];
	[stream writeInt:self.dc_id];
    [stream writeString:self.file_path];
    
    
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


- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readLong];
	self.access_hash = [stream readLong];
	self.date = [stream readInt];
	self.mime_type = [stream readString];
	self.size = [stream readInt];
	self.thumb = [TLClassStore TLDeserialize:stream];
	self.dc_id = [stream readInt];
    self.file_path = [stream readString];
    
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
