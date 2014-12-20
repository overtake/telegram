//
//  MessageTableItemSticker.m
//  Telegram
//
//  Created by keepcoder on 18.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemSticker.h"

@implementation MessageTableItemSticker

-(id)initWithObject:(TL_localMessage *)object {
    if(self = [super initWithObject:object]) {
        
        if(NSSizeNotZero(object.media.document.imageSize)) {
            self.blockSize = object.media.document.imageSize;
        } else {
            self.blockSize = NSMakeSize(200, 200);
        }
        
        NSImage *placeholder;
        
        if([object.media.document.thumb isKindOfClass:[TL_photoCachedSize class]]) {
            
            placeholder = [[NSImage alloc] initWithData:object.media.document.thumb.bytes];
            
            if(!placeholder)
                placeholder = [NSImage imageWithWebpData:object.media.document.thumb.bytes error:nil];
            
        }
        
        self.blockSize = strongsize(self.blockSize, 200);
        
        self.imageObject = [[TGStickerImageObject alloc] initWithMessage:object placeholder:placeholder];
        
    }
    
    return self;
}

@end
