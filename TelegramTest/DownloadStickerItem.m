//
//  DownloadStickerItem.m
//  Telegram
//
//  Created by keepcoder on 18.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DownloadStickerItem.h"

@implementation DownloadStickerItem

-(id)initWithObject:(TLDocument *)object {
    if(self = [super initWithObject:object]) {
        self.isEncrypted = NO;
        self.n_id = object.n_id;
        self.path = [NSString stringWithFormat:@"%@/%ld.webp",path(),object.n_id];
        self.fileType = DownloadFileDocument;
        self.dc_id = object.dc_id;
        self.size = object.size;
    }
    return self;
}

-(TLInputFileLocation *)input {
    TLDocument *document = self.object;
    if(self.isEncrypted)
        return [TL_inputEncryptedFileLocation createWithN_id:document.n_id access_hash:document.access_hash];
    
    return [TL_inputDocumentFileLocation createWithN_id:document.n_id access_hash:document.access_hash];
}

@end
