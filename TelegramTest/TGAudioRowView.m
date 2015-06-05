//
//  TGAudioRowView.m
//  Telegram
//
//  Created by keepcoder on 01.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGAudioRowView.h"
#import "MessageTableItemAudioDocument.h"
@interface TGAudioRowView ()
@property (nonatomic,strong) TMTextField *nameField;
@property (nonatomic,strong) NSImageView *imageView;
@end

@implementation TGAudioRowView


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _nameField = [TMTextField defaultTextField];
        
        [self addSubview:_nameField];
        
        
        _imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(22, 10, 44, 40)];
        
        _imageView.wantsLayer = YES;
        _imageView.layer.borderColor = NSColorFromRGB(0x7F7F7F).CGColor;
        _imageView.layer.borderWidth = 1;
        [self addSubview:_imageView];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    TGAudioRowItem *item = (TGAudioRowItem *) [self rowItem];
    
    if(item.isSelected) {
        [NSColorFromRGB(0xeeeeee) set];
        NSRectFill(dirtyRect);
    }
    
    // Drawing code here.
}


-(void)redrawRow {
    [super redrawRow];
    
    TGAudioRowItem *item = (TGAudioRowItem *) [self rowItem];
    
    _imageView.image = image_MiniPlayerDefaultCover();
    
    [_imageView setFrameSize:_imageView.image.size];
    
    [_imageView setCenteredYByView:self];
    
    [_imageView setFrameOrigin:NSMakePoint(roundf((90 - NSWidth(_imageView.frame))/2), NSMinY(_imageView.frame))];
    
    
    [_nameField setStringValue:[item trackName]];
    
    [_nameField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMaxX(_imageView.frame) - 22, 20)];
    
    [_nameField setFrameOrigin:NSMakePoint(NSMaxX(_imageView.frame) + 10, 0)];
    
    
    [_nameField setCenteredYByView:self];
    
    
    [self setNeedsDisplay:YES];
    
}

@end
