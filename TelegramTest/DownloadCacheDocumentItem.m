//
//  DownloadCacheDocumentItem.m
//  Telegram
//
//  Created by keepcoder on 20.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "DownloadCacheDocumentItem.h"

@implementation DownloadCacheDocumentItem


-(id)initWithObject:(TLDocument *)document {
    if(self = [super initWithObject:document]) {
        self.n_id = document.n_id;
        self.path = document.path_with_cache;
        self.fileType = DownloadFileDocument;
        self.dc_id = document.dc_id;
        self.size = document.size;
    }
    
    return self;
}

-(TLInputFileLocation *)input {
    TLDocument *document = self.object;

    return [TL_inputDocumentFileLocation createWithN_id:document.n_id access_hash:document.access_hash];
}

@end
