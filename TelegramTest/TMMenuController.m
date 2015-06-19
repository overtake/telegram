//
//  TMMenuController.m
//  Telegram
//
//  Created by Dmitry Kondratyev on 6/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMMenuController.h"


#import "NSMenuItemCategory.h"

@class TMMenuController;

@interface TMMenuItemView : BTRControl

@property (nonatomic, strong) NSMenuItem *item;

@property (nonatomic, strong, readonly) BTRImageView *backgroundImageView;
@property (nonatomic, strong) TMTextLayer *textLayer;
@property (nonatomic, strong) TMTextLayer *subTextLayer;
@property (nonatomic, strong) NSImageView *imageView;
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

        
        
        [item addObserver:self
                  forKeyPath:@"image"
                     options:0
                     context:NULL];
        
        
        self.textLayer = [TMTextLayer layer];
        [self.textLayer disableActions];
        [self.textLayer setTextFont:TGSystemFont(14)];
        [self.textLayer setTextColor:[NSColor blackColor]];
        [self.textLayer setString:item.title];
        [self.textLayer sizeToFit];
        [self.textLayer setFrameOrigin:CGPointMake(48, roundf((self.bounds.size.height - self.textLayer.size.height) / 2.0) - 1)];
        [self.textLayer setContentsScale:self.layer.contentsScale];
        [self.layer addSublayer:self.textLayer];
        
        
        if(item.subtitle) {
            self.subTextLayer = [TMTextLayer layer];
            [self.subTextLayer disableActions];
            [self.subTextLayer setTextFont:TGSystemFont(12)];
            [self.subTextLayer setTextColor:GRAY_TEXT_COLOR];
            [self.subTextLayer setString:item.subtitle];
            [self.subTextLayer sizeToFit];
            [self.subTextLayer setFrameOrigin:CGPointMake(48, roundf((self.bounds.size.height - self.subTextLayer.size.height) / 2.0) - 10)];
            [self.subTextLayer setContentsScale:self.layer.contentsScale];
            [self.layer addSublayer:self.subTextLayer];
        }
        
        
        self.subTextLayer.truncationMode = @"end";
        self.textLayer.truncationMode = @"end";
        
        
        self.imageView = [[NSImageView alloc] init];
        [self.imageView setFrameSize:item.image.size];
        [self.imageView setFrameOrigin:CGPointMake(roundf((46 - item.image.size.width) / 2.f), roundf((self.bounds.size.height - item.image.size.height) / 2.f))];
        [self addSubview:self.imageView];
        
        [self handleStateChange];
        
        [self addTarget:self action:@selector(click) forControlEvents:BTRControlEventLeftClick];
    }
    return self;
}

-(NSString *)title {
    return self.item.title;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    
    [self handleStateChange];

    
    
}

-(void)dealloc {
    [_item removeObserver:self forKeyPath:@"image"];
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
    
    if((self.isHover  && self.controller.popover.isAutoHighlight) || (self.controller.selectedItem == self) ) {
        
        NSImage *img = self.item.highlightedImage;
        
        if(!img)
            img = self.item.image;
    
        
        [self.gradientLayer setColors:@[(id)BLUE_COLOR_SELECT.CGColor, (id)BLUE_COLOR_SELECT.CGColor]];
        [self.textLayer setTextColor:[NSColor whiteColor]];
        [self.subTextLayer setTextColor:[NSColor whiteColor]];
        [self.imageView setFrameSize:img.size];
        [self.imageView setFrameOrigin:CGPointMake(roundf((46 - img.size.width) / 2.f), roundf((self.bounds.size.height - img.size.height) / 2.f))];
        
        self.imageView.image = img;
        
    } else {
        [self.gradientLayer setColors:@[]];
        [self.textLayer setTextColor:NSColorFromRGB(0x000000)];
        [self.subTextLayer setTextColor:GRAY_TEXT_COLOR];
        
        [self.imageView setFrameSize:self.item.image.size];
        [self.imageView setFrameOrigin:CGPointMake(roundf((46 - self.item.image.size.width) / 2.f), roundf((self.bounds.size.height - self.item.image.size.height) / 2.f))];
        
        self.imageView.image = self.item.image;
        
        
        
    }
    
    [self.subTextLayer setFrameSize:NSMakeSize(NSWidth(self.frame) - (self.imageView.image ? 60 : 10), NSHeight(self.subTextLayer.frame))];
    [self.textLayer setFrameSize:NSMakeSize(NSWidth(self.frame) - (self.imageView.image ? 60 : 10), NSHeight(self.textLayer.frame))];
    
    if(self.imageView.image == nil) {
        
        [self.textLayer setFrameOrigin:NSMakePoint(round((NSWidth(self.frame) - NSWidth(self.textLayer.frame))/2), round((NSHeight(self.frame) - NSHeight(self.textLayer.frame))/2 + (self.subTextLayer == nil ? 0 : 8)))];
        [self.subTextLayer setFrameOrigin:CGPointMake(round((NSWidth(self.frame) - NSWidth(self.subTextLayer.frame))/2), roundf((self.bounds.size.height - self.subTextLayer.size.height) / 2.0) - 10)];
        
    } else {
        [self.textLayer setFrameOrigin:CGPointMake(48, roundf((self.bounds.size.height - self.textLayer.size.height) / 2.0 + (self.subTextLayer == nil ? 0 : 8)) - 1)];
        [self.subTextLayer setFrameOrigin:CGPointMake(48, roundf((self.bounds.size.height - self.subTextLayer.size.height) / 2.0) - 10)];
    }
}

@end


@interface TMMenuController ()
@property (nonatomic,assign) int selectedIndex;
@end



@implementation TMMenuController

- (id)initWithMenu:(NSMenu *)menu {
    self = [super initWithFrame:NSMakeRect(0, 0, 200, menu.itemArray.count * 36 + 12)];
    if(self) {
        self.menuController = menu;
        _selectedIndex = -1;
    }
    return self;
}

- (void)close {
    [self.popover setAnimates:NO];
    [self.popover close];
}

- (void)loadView {
    [super loadView];
    
    int count = (int)self.menuController.itemArray.count - 1;
    for(NSMenuItem *item in self.menuController.itemArray) {
        TMMenuItemView *itemView = [[TMMenuItemView alloc] initWithMenuItem:item];
        itemView.controller = self;
        [itemView setFrameOrigin:NSMakePoint(0, count * 36 + 6)];
        [self.view addSubview:itemView];
        count--;
    }
}

-(void)selectNext {
    
    _selectedIndex++;
    
    if(_selectedIndex >= self.view.subviews.count) {
        _selectedIndex = 0;
    }
    
    TMMenuItemView *lastItem = _selectedItem;
    
     _selectedItem = self.view.subviews[_selectedIndex];
    
    [lastItem handleStateChange];
    
    [(TMMenuItemView *)_selectedItem handleStateChange];
    
}

-(void)selectPrev {
    _selectedIndex--;
    
    if(_selectedIndex < 0) {
        _selectedIndex = (int)self.view.subviews.count - 1;
    }
    
    TMMenuItemView *lastItem = _selectedItem;
    
    [(TMMenuItemView *)_selectedItem handleStateChange];
    
    _selectedItem = self.view.subviews[_selectedIndex];
    
     [lastItem handleStateChange];
    
    [(TMMenuItemView *)_selectedItem handleStateChange];
}

-(void)performSelected {
    TMMenuItemView *item = (TMMenuItemView *)_selectedItem;
    
    item.item.blockAction(item.item);
}

@end
