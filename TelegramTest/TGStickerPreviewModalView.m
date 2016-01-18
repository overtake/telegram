//
//  TGStickerPreviewModalView.m
//  Telegram
//
//  Created by keepcoder on 15/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGStickerPreviewModalView.h"
#import "TGImageView.h"
#import "TGStickerImageObject.h"
#import "TGMessagesStickerImageObject.h"
@interface TGStickerPreviewModalView ()
@property (nonatomic,strong) TGImageView *imageView;
@end


@implementation TGStickerPreviewModalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _imageView = [[TGImageView alloc] initWithFrame:NSZeroRect];
        [self setOpaqueContent:YES];
        [self addSubview:_imageView];
    }
    
    return self;
}

-(void)setSticker:(TLDocument *)sticker {
    _sticker = sticker;
    
    NSImage *placeholder;
    
    NSData *bytes = sticker.thumb.bytes;
    
    if(bytes.length == 0) {
        bytes = [NSData dataWithContentsOfFile:locationFilePath(sticker.thumb.location, @"jpg") options:NSDataReadingMappedIfSafe error:nil];
    }
    
    placeholder = [[NSImage alloc] initWithData:bytes];
    
    if(!placeholder)
        placeholder = [NSImage imageWithWebpData:bytes error:nil];
    
    
    TL_localMessage *message = [[TL_localMessage alloc] init];
    
    message.media = [TL_messageMediaDocument createWithDocument:sticker caption:@""];
    
    
    TGStickerImageObject *imageObject = [[TGStickerImageObject alloc] initWithMessage:message placeholder:placeholder];
    
    TL_documentAttributeImageSize *imageSize = (TL_documentAttributeImageSize *) [sticker attributeWithClass:[TL_documentAttributeImageSize class]];
    
    imageObject.imageSize = strongsize(NSMakeSize(imageSize.w, imageSize.h), 320);
    
    
    [self setContainerFrameSize:imageObject.imageSize];
    
    self.imageView.object = imageObject;
    [self.imageView setFrameSize:imageObject.imageSize];
}

@end
