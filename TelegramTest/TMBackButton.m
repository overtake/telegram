//
//  TMBackButton.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/8/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMBackButton.h"
#import "Telegram.h"

@implementation TMBackButton

- (id)initWithFrame:(NSRect)frame string:(NSString *)string {
    self = [super initWithFrame:frame];
    if (self) {
        NSImage *backImage = image_boxBack();
        self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 2, backImage.size.width, backImage.size.height)];
        self.imageView.image = backImage;
        
        [self addSubview:self.imageView];
        [self setTarget:self selector:@selector(click)];
        [self setAutoresizesSubviews:YES];
        [self setTextFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:14]];
        
        [self setWantsLayer:YES];
        [self setFrameOrigin:NSMakePoint(0, 1)];
        
        [self setTextColor:BLUE_UI_COLOR forState:TMButtonNormalState];
      //  [self setTextColor:BLUE_COLOR_SELECT forState:TMButtonNormalHoverState];
       // [self setTextColor:NSColorFromRGB(0x2e618c) forState:TMButtonPressedState];
        [self setStringValue:string];
        
        self.acceptCursor = NO;
    }
    return self;
}

-(void)updateBackButton {
    if(self.controller.navigationViewController.viewControllerStack.count > 2) {
        [self setText:[NSString stringWithFormat:@"  %@", NSLocalizedString(@"Compose.Back",nil)]];
    } else {
        [self setText:NSLocalizedString(@"Close", nil)];
    }
    
    [self.imageView setHidden:self.controller.navigationViewController.viewControllerStack.count <= 2];
    
    [self sizeToFit];
}

- (void)setStringValue:(NSString *)stringValue {
    
}

- (void)sizeToFit {
    NSSize size = [self sizeOfText];
    size.width += 10;
    [self setFrameSize:size];
}

- (void)click {
    [[Telegram rightViewController] navigationGoBack];
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
}

@end
