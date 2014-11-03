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
        
        
        self.urlView = [[MessageCellDescriptionView alloc] initWithFrame:NSMakeRect(20, 60, 0, 0)];
        
        [self.containerView addSubview:self.urlView];
        
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
    
    
    [self.urlView setFrameSize:item.social.titleSize];
    [self.urlView setString:item.social.title];
    
    [self.serviceNameView setFrameSize:item.social.serviceNameSize];
    [self.serviceNameView setString:item.social.serviceName];
}

@end
