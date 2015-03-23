//
//  MessageTableCellSocialView.m
//  Telegram
//
//  Created by keepcoder on 03.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellSocialView.h"

#import "UIImageView+AFNetworking.h"
#import "MessageCellDescriptionView.h"


@interface MessageTableCellSocialView ()
@property (nonatomic,strong) NSImageView *imageView;
@property (nonatomic,strong) TMTextField *serviceNameView;
@property (nonatomic,strong) TMTextField *urlView;
@property (nonatomic,strong) NSImageView *centerImageView;


@property (nonatomic,strong) TMView *backgroundView;
@end

@implementation MessageTableCellSocialView


-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 320, 240)];
        
        [self.imageView setWantsLayer:YES];
        
        [self.containerView setWantsLayer:YES];
        [self.containerView.layer setCornerRadius:4];
        
        self.imageView.layer.cornerRadius = 4;
        [self.imageView setImageScaling:NSImageScaleNone];
        [self.containerView addSubview:self.imageView];
        
        self.serviceNameView = [TMTextField defaultTextField];
        
        
        self.centerImageView = [[NSImageView alloc] initWithFrame:NSZeroRect];
        
        
        [self.containerView addSubview:self.centerImageView];
        
        self.urlView = [TMTextField defaultTextField];
        
        
        
        weak();
        
        [self.imageView setCallback:^{
            
            open_link([(MessageTableItemSocial *)weakSelf.item social].url);
            
        }];
        
        self.backgroundView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.containerView.frame), 40)];
        
        self.backgroundView.backgroundColor = NSColorFromRGBWithAlpha(0x000000, 0.5);
        
        
        
        
        [self.containerView addSubview:self.backgroundView];
        
        [self.containerView setAutoresizesSubviews:NO];
        [self.containerView setAutoresizingMask:0];
        
        
        [self.containerView addSubview:self.serviceNameView];
        [self.containerView addSubview:self.urlView];
        
        [self.urlView setFrameOrigin:NSMakePoint(5, 16)];
        [self.serviceNameView setFrameOrigin:NSMakePoint(5, 0)];
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


-(void)setItem:(MessageTableItemSocial *)item {
    [super setItem:item];
    
    [self.imageView setFrameSize:item.blockSize];
    
    [self.containerView setFrameSize:item.blockSize];
    
    [self.backgroundView setFrameSize:NSMakeSize(NSWidth(self.containerView.frame), NSHeight(self.backgroundView.frame))];
    
    [self.imageView setImageWithURL:[item.social imageURL]];
    
    [self.centerImageView setImage:item.social.centerImage];
    [self.centerImageView setFrameSize:item.social.centerImage.size];
    
    [self.centerImageView setCenterByView:self.containerView];
    
    [self.centerImageView setFrameOrigin:NSMakePoint(roundf((item.blockSize.width - NSWidth(self.centerImageView.frame))/2), NSMinY(self.centerImageView.frame))];
    
    
    [self.urlView setFrameSize:NSMakeSize(NSWidth(self.containerView.frame) - 5, item.social.titleSize.height)];
    [self.urlView setAttributedStringValue:item.social.title];
    
    [self.serviceNameView setHidden:item.social.serviceName == nil];
    
    [self.serviceNameView setFrameSize:NSMakeSize(NSWidth(self.containerView.frame) - 5, item.social.serviceNameSize.height)];
    [self.serviceNameView setAttributedStringValue:item.social.serviceName];
    
}

@end
