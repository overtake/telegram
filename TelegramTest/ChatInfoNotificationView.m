//
//  CHatInfoNotificationView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/21/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ChatInfoNotificationView.h"
#import "UserInfoContainerView.h"

@interface ChatInfoNotificationView()

@end

@implementation ChatInfoNotificationView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizingMask:NSViewWidthSizable];
        self.switchControl = [[ITSwitch alloc] initWithFrame:CGRectMake(150, 17, 36, 20)];
        [self addSubview:self.switchControl];
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"notifications", nil) attributes:[UserInfoContainerView attributsForInfoPlaceholderString]];
        
        [attributedString drawAtPoint:NSMakePoint(130 - attributedString.size.width, 20)];
    
    if(!self.noBorder) {
        [NSColorFromRGB(0xe6e6e6) set];
        NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, 1));
    }
}

@end
