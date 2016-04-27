//
//  MessageTableItemSticker.m
//  Telegram
//
//  Created by keepcoder on 18.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemSticker.h"
#import "MessageTableCellStickerView.h"
@implementation MessageTableItemSticker

-(id)initWithObject:(TL_localMessage *)object {
    if(self = [super initWithObject:object]) {
        
        if(NSSizeNotZero(self.document.imageSize)) {
            self.blockSize = self.document.imageSize;
        } else {
            if ([SettingsArchiver checkMaskedSetting:SmallerStickers]) {
                self.blockSize = NSMakeSize(40, 40);
            } else {
                self.blockSize = NSMakeSize(200, 200);
            }
        }
        
        NSImage *placeholder;
        
        NSData *bytes = self.document.thumb.bytes;
            
        if(bytes.length == 0) {
            bytes = [NSData dataWithContentsOfFile:locationFilePath(self.document.thumb.location, @"jpg") options:NSDataReadingMappedIfSafe error:nil];
        }
            
        placeholder = [[NSImage alloc] initWithData:bytes];
            
        if(!placeholder)
            placeholder = [NSImage imageWithWebpData:bytes error:nil];
            

        if(!placeholder)
            placeholder = white_background_color();
        
        if ([SettingsArchiver checkMaskedSetting:SmallerStickers]) {
            self.blockSize = strongsize(self.blockSize, 40);
        } else {
            self.blockSize = strongsize(self.blockSize, 200);
        }

        self.imageObject = [[TGStickerImageObject alloc] initWithDocument:self.document placeholder:placeholder];
        
        self.imageObject.imageSize = self.blockSize;
        
    }
    
    return self;
}

-(BOOL)makeSizeByWidth:(int)width {
    
    if(NSSizeNotZero(self.document.imageSize)) {
        self.blockSize = self.document.imageSize;
    } else {
        if ([SettingsArchiver checkMaskedSetting:SmallerStickers]) {
            self.blockSize = NSMakeSize(40, 40);
        } else {
            self.blockSize = NSMakeSize(200, 200);
        }
    }
    
    if ([SettingsArchiver checkMaskedSetting:SmallerStickers]) {
        self.contentSize = self.blockSize = strongsize(self.blockSize, MIN(width, 40));
    } else {
        self.contentSize = self.blockSize = strongsize(self.blockSize, MIN(width, 200));
    }

    
    return [super makeSizeByWidth:width];
}


-(TLDocument *)document {
    if([self.message.media isKindOfClass:[TL_messageMediaBotResult class]]) {
        return self.message.media.bot_result.document;
    } else
        return self.message.media.document;
}


-(Class)viewClass {
    return [MessageTableCellStickerView class];
}


@end
