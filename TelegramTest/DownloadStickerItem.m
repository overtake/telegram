//
//  DownloadStickerItem.m
//  Telegram
//
//  Created by keepcoder on 18.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DownloadStickerItem.h"

@implementation DownloadStickerItem

-(id)initWithObject:(TL_localMessage *)object {
    if(self = [super initWithObject:object]) {
        self.isEncrypted = NO;
        self.n_id = object.media.document.n_id;
        self.path = [NSString stringWithFormat:@"%@/%ld.webp",path(),object.media.document.n_id];
        self.fileType = DownloadFileDocument;
        self.dc_id = object.media.document.dc_id;
        self.size = object.media.document.size;
    }
    return self;
}

-(TLInputFileLocation *)input {
    TLMessage *message = self.object;
    if(self.isEncrypted)
        return [TL_inputEncryptedFileLocation createWithN_id:message.media.document.n_id access_hash:message.media.document.access_hash];
    
    return [TL_inputDocumentFileLocation createWithN_id:message.media.document.n_id access_hash:message.media.document.access_hash];
}

@end
