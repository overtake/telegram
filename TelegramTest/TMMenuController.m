//
//  TMMenuController.m
//  Telegram
//
//  Created by Dmitry Kondratyev on 6/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMMenuController.h"

@class TMMenuController;

@interface TMMenuItemView : BTRControl

@property (nonatomic, strong) NSMenuItem *item;

@property (nonatomic, strong, readonly) BTRImageView *backgroundImageView;
@property (nonatomic, strong) TMTextLayer *textLayer;
@property (nonatomic, strong) CALayer *imageLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, unsafe_unretained) TMMenuController *controller;

@end

@implementation TMMenuItemView

- (id)initWithMenuItem:(NSMenuItem *)item {
    self = [super initWithFrame:NSMakeRect(0, 0, 200, 36)];
    if(self) {
        
        self.item = item;
        
        self.gradientLayer = [CAGradientLayer layer];
        self.wantsLayer = YES;
        self.gradientLayer.contentsScale = self.layer.contentsScale;
        [self setLayer:self.gradientLayer];

        
        
        
        self.textLayer = [TMTextLayer layer];
        [self.textLayer disableActions];
        [self.textLayer setTextFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
        [self.textLayer setTextColor:[NSColor blackColor]];
        [self.textLayer setString:item.title];
        [self.textLayer sizeToFit];
        [self.textLayer setFrameOrigin:CGPointMake(48, roundf((self.bounds.size.height - self.textLayer.size.height) / 2.0) - 1)];
        [self.textLayer setContentsScale:self.layer.contentsScale];
        [self.layer addSublayer:self.textLayer];
        
        self.imageLayer = [CALayer layer];
        [self.imageLayer disableActions];
        [self.imageLayer setFrameSize:item.image.size];
        [self.imageLayer setFrameOrigin:CGPointMake(roundf((46 - item.image.size.width) / 2.f), roundf((self.bounds.size.height - item.image.size.height) / 2.f))];
        [self.layer addSublayer:self.imageLayer];
        
        [self handleStateChange];
        
        [self addTarget:self action:@selector(click) forControlEvents:BTRControlEventLeftClick];
    }
    return self;
}

- (void)click {
  
    [self.controller close];
    [self setHighlighted:NO];
    [self setSelected:NO];
    [self setHovered:NO];
    
   // dispatch_async(dispatch_get_main_queue(), ^{
        if(self.item.target && self.item.action) {
            [self.item.target performSelector:self.item.action withObject:self];
        }
    //});
}


- (void)handleStateChange {
    
    [[NSCursor arrowCursor] set];
    
    if(self.isHover) {
        [self.gradientLayer setColors:@[(id)BLUE_COLOR_SELECT.CGColor, (id)BLUE_COLOR_SELECT.CGColor]];
        [self.textLayer setTextColor:[NSColor whiteColor]];
        self.imageLayer.contents = self.item.highlightedImage;
        
    } else {
        [self.gradientLayer setColors:@[]];
        [self.textLayer setTextColor:[NSColor blackColor]];
        self.imageLayer.contents = self.item.image;
    }
    
    if(self.imageLayer.contents == nil) {
        [self.textLayer setFrameOrigin:NSMakePoint(round((NSWidth(self.frame) - NSWidth(self.textLayer.frame))/2), round((NSHeight(self.frame) - NSHeight(self.textLayer.frame))/2))];
    }
}

@end


@interface TMMenuController ()
@end

@implementation TMMenuController

- (id)initWithMenu:(NSMenu *)menu {
    self = [super initWithFrame:NSMakeRect(0, 0, 200, menu.itemArray.count * 36 + 12)];
    if(self) {
        self.menu = menu;
    }
    return self;
}

- (void)close {
    [self.popover setAnimates:NO];
    [self.popover close];
}

- (void)loadView {
    [super loadView];
    
    int count = (int)self.menu.itemArray.count - 1;
    for(NSMenuItem *item in self.menu.itemArray) {
        TMMenuItemView *itemView = [[TMMenuItemView alloc] initWithMenuItem:item];
        itemView.controller = self;
        [itemView setFrameOrigin:NSMakePoint(0, count * 36 + 6)];
        [self.view addSubview:itemView];
        count--;
    }
}

@end
