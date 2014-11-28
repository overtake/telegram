//
//  TMBackButton.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/8/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMBackButton.h"
#import "Telegram.h"


@interface TMBackButton ()
@property (nonatomic,weak) id target;
@property (nonatomic,assign) SEL selector;
@end

@implementation TMBackButton

- (id)initWithFrame:(NSRect)frame string:(NSString *)string {
    self = [super init];
    if (self) {
        
        [self setEditable:NO];
        [self setDrawsBackground:NO];
        [self setSelectable:NO];
        [self setBezeled:NO];
        [self setBordered:NO];
        
        NSImage *backImage = image_boxBack();
        self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 5, backImage.size.width, backImage.size.height)];
        self.imageView.image = backImage;
        
        [self addSubview:self.imageView];
        
        [self setStringValue:string];

        [self setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];

        [self setFrameOrigin:NSMakePoint(0, 0)];
        
        [self setTextColor:BLUE_UI_COLOR];
        
    
           
        [self setTarget:self selector:@selector(click)];
    }
    return self;
}

-(void)setTarget:(id)target selector:(SEL)selector {
    self.target = target;
    self.selector = selector;
}

-(void)mouseDown:(NSEvent *)theEvent {
    if(self.target && self.selector) {
        [self.target performSelector:self.selector];
    } else {
        [super mouseDown:theEvent];
    }
}

-(void)updateBackButton {
    if(self.controller.navigationViewController.viewControllerStack.count > 2) {
        [self setStringValue:[NSString stringWithFormat:@"   %@", NSLocalizedString(@"Compose.Back",nil)]];
    } else {
        [self setStringValue:NSLocalizedString(@"Close", nil)];
    }
    
    [self.imageView setHidden:self.controller.navigationViewController.viewControllerStack.count <= 2];
    
    [self sizeToFit];
}


- (void)click {
    [[Telegram rightViewController] navigationGoBack];
}





@end
