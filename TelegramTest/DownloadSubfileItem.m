//
//  DownloadSubfileItem.m
//  Telegram
//
//  Created by keepcoder on 14/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "DownloadSubfileItem.h"

@interface DownloadSubfileItem ()
@property (nonatomic,strong) TL_documentAttributeSubfile *subfile;
@end

@implementation DownloadSubfileItem


-(id)initWithObject:(TLMessage *)object {
    if(self = [super initWithObject:object]) {
        self.subfile = (TL_documentAttributeSubfile *) [object.media.document attributeWithClass:[TL_documentAttributeSubfile class]];
        self.n_id = object.media.document.n_id;
        self.path = mediaFilePathWithSubfile(object.media,self.subfile);
        self.fileType = DownloadFileDocument;
        self.dc_id = object.media.document.dc_id;
        self.size = self.subfile.size;
        
    }
    return self;
}

-(TLInputFileLocation *)input {
    TLMessage *message = self.object;

    return [TL_inputDocumentSubfileLocation createWithN_id:message.media.document.n_id access_hash:message.media.document.access_hash type:_subfile.type];
}

@end
