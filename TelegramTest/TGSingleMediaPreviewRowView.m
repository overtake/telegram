//
//  TGSingleMediaPreviewRowView.m
//  Telegram
//
//  Created by keepcoder on 21/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGSingleMediaPreviewRowView.h"
#import "TGSingleMediaPreviewRowItem.h"
#import "TGCTextView.h"
@interface TGSingleMediaPreviewRowView ()
@property (nonatomic,strong) NSImageView *imageView;
@property (nonatomic,strong) TGCTextView *textView;
@end

@implementation TGSingleMediaPreviewRowView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(30, 0, 80, 80)];
        _imageView.wantsLayer = YES;
        _imageView.layer.cornerRadius = 4;
        
        [self addSubview:_imageView];
        _textView = [[TGCTextView alloc] init];
        
        [self addSubview:_textView];
        
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    TGSingleMediaPreviewRowItem *item = (TGSingleMediaPreviewRowItem *) self.rowItem;

    if(item.thumbImage == nil) {
        [NSColorFromRGB(0x4ba3e2) setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:_imageView.frame xRadius:4 yRadius:4];
        [path fill];
    }
    // Drawing code here.
}



-(void)redrawRow {
    [super redrawRow];
    
    
    
    TGSingleMediaPreviewRowItem *item = (TGSingleMediaPreviewRowItem *) self.rowItem;
    
    [_imageView setFrameSize:item.thumbSize];
    
    if(item.text)
        [_imageView setCenteredYByView:self];
    else
        [_imageView setCenterByView:self];
    
    _imageView.image = item.thumbImage;
    
    
    if(!_imageView.image)
    {
        //[self.attachButton setBackgroundImage:item.isHasThumb ? gray_resizable_placeholder() : blue_circle_background_image() forControlState:BTRControlStateNormal];
        _imageView.image = attach_downloaded_background();
    }
    
    [_textView setAttributedString:item.text];
    [_textView setFrameSize:item.textSize];
    
    [_textView setFrameOrigin:NSMakePoint(NSMaxX(_imageView.frame) + 10, 0)];
    [_textView setCenteredYByView:self];
    
}

@end
