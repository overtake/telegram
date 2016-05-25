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
#import "TGTextLabel.h"
#import "TGMessagesStickerImageObject.h"
@interface TGStickerPreviewModalView ()
@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,strong) TGTextLabel *textLabel;
@end


@implementation TGStickerPreviewModalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _imageView = [[TGImageView alloc] initWithFrame:NSZeroRect];
        
        _textLabel = [[TGTextLabel alloc] init];
        [self setOpaqueContent:YES];
        [self addSubview:_imageView];
        
        [self addSubview:_textLabel];
    }
    
    return self;
}

-(void)setSticker:(TLDocument *)sticker {
    
    if(_sticker == sticker)
        return;
    
    _sticker = sticker;
    
    NSImage *placeholder;
    
    NSData *bytes = sticker.thumb.bytes;
    
    if(bytes.length == 0) {
        bytes = [NSData dataWithContentsOfFile:locationFilePath(sticker.thumb.location, @"jpg") options:NSDataReadingMappedIfSafe error:nil];
    }
    
    placeholder = [[NSImage alloc] initWithData:bytes];
    
    if(!placeholder)
        placeholder = [NSImage imageWithWebpData:bytes error:nil];
    
    
    TGStickerImageObject *imageObject = [[TGStickerImageObject alloc] initWithDocument:sticker placeholder:placeholder];
    
    TL_documentAttributeImageSize *imageSize = (TL_documentAttributeImageSize *) [sticker attributeWithClass:[TL_documentAttributeImageSize class]];
    
    imageObject.imageSize = strongsize(NSMakeSize(imageSize.w, imageSize.h), 320);
    
    [self setContainerFrameSize:NSMakeSize(imageObject.imageSize.width, imageObject.imageSize.height + 60)];
    
    self.imageView.object = imageObject;
    [self.imageView setFrameSize:imageObject.imageSize];
    
    
    NSMutableAttributedString *alt = [[NSMutableAttributedString alloc] init];
    
    [alt appendString:sticker.stickerAttr.alt];
    [alt setFont:TGSystemFont(20)  forRange:alt.range];
    [_textLabel setText:alt maxWidth:INT32_MAX];
    
    
    [_textLabel setBackgroundColor:[NSColor clearColor]];
    [_textLabel setCenteredXByView:_textLabel.superview];
    [_textLabel setFrameOrigin:NSMakePoint(NSMinX(_textLabel.frame), imageObject.imageSize.height + 30)];
}



@end
