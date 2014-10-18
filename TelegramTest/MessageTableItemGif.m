//
//  MessageTableItemGif.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/3/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemGif.h"
#import "ImageUtils.h"

@implementation MessageTableItemGif

- (id)initWithObject:(TGMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        self.document = self.message.media.document;
        
        TGPhotoSize *thumb = self.document.thumb;
        
        self.previewLocation = thumb.location;
        
        NSSize size;
        float maxSize = 250;
        if(thumb.w > thumb.h) {
            size.width = maxSize;
            float k = size.width / thumb.w;
            size.height = ceil(thumb.h * k);
        } else {
            size.height = maxSize;
            float k = size.height / thumb.h;
            size.width = ceil(thumb.w * k);
        }
        
        size.width = MAX(36, size.width);
        size.height = MAX(36, size.height);
        
        
        self.blockSize = size;
        
        if(thumb.bytes.length > 0) {
            self.cachedThumb = [ImageUtils blurImage:[[NSImage alloc] initWithData:thumb.bytes] blurRadius:60 frameSize:self.blockSize];
            
            self.cachedThumb = [ImageUtils roundCorners:self.cachedThumb size:NSMakeSize(3, 3)];
        } else {
            self.imageObject = [[TGImageObject alloc] initWithLocation:self.previewLocation placeHolder:self.cachedThumb sourceId:object.peer.peer_id size:thumb.size];
        }
        
        self.imageObject.imageSize = size;
        
        [self checkStartDownload:[self.message.to_id isKindOfClass:[TL_peerChat class]] ? AutoGroupDocuments : AutoPrivateDocuments size:self.message.media.document.size];
        
        

    }
    return self;
}

-(Class)downloadClass {
    return [DownloadDocumentItem class];
}

-(void)doAfterDownload {
    
}

@end
