//
//  MessageTableCellWebPageView.m
//  Telegram
//
//  Created by keepcoder on 26.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "MessageTableCellWebPageView.h"

#import "TGImageView.h"
#import "UIImageView+AFNetworking.h"
#import "MessageCellDescriptionView.h"


@interface MessageTableCellWebPageView ()

@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,strong) TMTextField *serviceNameView;
@property (nonatomic,strong) TMTextField *urlView;
@property (nonatomic,strong) NSImageView *centerImageView;


@property (nonatomic,strong) TMView *backgroundView;


@end

@implementation MessageTableCellWebPageView


-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        self.imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(0, 0, 320, 240)];
        
        
        [self.containerView setWantsLayer:YES];
        [self.containerView.layer setCornerRadius:4];
        
        self.imageView.layer.cornerRadius = 4;
        [self.containerView addSubview:self.imageView];
        
        self.serviceNameView = [TMTextField defaultTextField];
        
        
        self.centerImageView = [[NSImageView alloc] initWithFrame:NSZeroRect];
        
        
        [self.containerView addSubview:self.centerImageView];
        
        self.urlView = [TMTextField defaultTextField];

        
        self.backgroundView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.containerView.frame), 40)];
        
        self.backgroundView.backgroundColor = NSColorFromRGBWithAlpha(0x000000, 0.5);
        
        
        
        
        [self.containerView addSubview:self.backgroundView];
        
        [self.containerView setAutoresizesSubviews:NO];
        [self.containerView setAutoresizingMask:0];
        
        
        [self.containerView addSubview:self.serviceNameView];
        [self.containerView addSubview:self.urlView];
        
        [self.urlView setFrameOrigin:NSMakePoint(5, 16)];
        [self.serviceNameView setFrameOrigin:NSMakePoint(5, 0)];
        
        
        [self setProgressToView:self.containerView];
        
        [self.progressView setStyle:TMCircularProgressDarkStyle];

    }
    
    return self;
}


-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    const int borderOffset = 1;
    const int borderSize = borderOffset*2;
    
    NSRect rect = NSMakeRect(self.containerView.frame.origin.x-borderOffset, self.containerView.frame.origin.y-borderOffset, NSWidth(self.imageView.frame)+borderSize, NSHeight(self.containerView.frame)+borderSize);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:4 yRadius:4];
    [path addClip];
    
    
    [NSColorFromRGB(0xf3f3f3) set];
    NSRectFill(rect);
}



-(void)updateCellState {
    
    
    
    
}


-(void)setItem:(MessageTableItemWebPage *)item {
    [super setItem:item];
    
    [self.imageView setFrameSize:item.blockSize];
    
    [self.containerView setFrameSize:item.blockSize];
    
    [self.backgroundView setFrameSize:NSMakeSize(NSWidth(self.containerView.frame), NSHeight(self.backgroundView.frame))];
    
    [self.progressView setHidden:NO];
    
    [self setProgressToView:self.containerView];
    
    [self.progressView setProgress:50 animated:NO];
    
    [self.progressView setProgress:50 animated:YES];
    
    
    
    [self.imageView setObject:item.imageObject];
    
    
    [self.urlView setFrameSize:NSMakeSize(NSWidth(self.containerView.frame) - 5, 20)];
    [self.urlView setStringValue:item.title];
    
    [self.serviceNameView setHidden:item.description == nil];
    
    [self.serviceNameView setFrameSize:NSMakeSize(NSWidth(self.containerView.frame) - 5, 20)];
    [self.serviceNameView setStringValue:item.desc];
    
}


@end
