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
@property (nonatomic,strong) MessageCellDescriptionView *serviceNameView;
@property (nonatomic,strong) MessageCellDescriptionView *urlView;
@property (nonatomic,strong) NSImageView *centerImageView;
@end

@implementation MessageTableCellSocialView


-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 320, 240)];
        
        [self.imageView setWantsLayer:YES];
        
        self.imageView.layer.cornerRadius = 4;
        [self.imageView setImageScaling:NSImageScaleNone];
        [self.containerView addSubview:self.imageView];
        
        self.serviceNameView = [[MessageCellDescriptionView alloc] initWithFrame:NSMakeRect(20, 20, 50, 0)];
        
        [self.containerView addSubview:self.serviceNameView];
        
        self.centerImageView = [[NSImageView alloc] initWithFrame:NSZeroRect];
        
        
        [self.containerView addSubview:self.centerImageView];
        
        self.urlView = [[MessageCellDescriptionView alloc] initWithFrame:NSMakeRect(20, 60, 0, 0)];
        
        [self.containerView addSubview:self.urlView];
        
        weak();
        
        [self.imageView setCallback:^{
            
            open_link([(MessageTableItemSocial *)weakSelf.item social].url);
            
        }];
        
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
    
    [self.imageView setImageWithURL:[item.social imageURL]];
    
    [self.centerImageView setImage:item.social.centerImage];
    [self.centerImageView setFrameSize:item.social.centerImage.size];
    
    [self.centerImageView setCenterByView:self.containerView];
    
    [self.centerImageView setFrameOrigin:NSMakePoint(roundf((item.blockSize.width - NSWidth(self.centerImageView.frame))/2), NSMinY(self.centerImageView.frame))];
    
    
    [self.urlView setFrameSize:item.social.titleSize];
    [self.urlView setString:item.social.title];
    [self.urlView setFrameOrigin:NSMakePoint(10, NSHeight(self.imageView.frame) - 30)];
    
    [self.serviceNameView setFrameSize:item.social.serviceNameSize];
    [self.serviceNameView setString:item.social.serviceName];
    [self.serviceNameView setFrameOrigin:NSMakePoint(NSWidth(self.imageView.frame) - NSWidth(self.serviceNameView.frame) - 10, 10)];
}

@end
