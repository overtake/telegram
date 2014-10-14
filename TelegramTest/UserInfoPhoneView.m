//
//  UserInfoPhoneView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/5/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "UserInfoPhoneView.h"
#import "UserInfoContainerView.h"
#import "NS(Attributed)String+Geometrics.h"

@interface UserInfoPhoneView()
@property (nonatomic, strong) NSTextView *textView;
@end

@implementation UserInfoPhoneView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizingMask:NSViewWidthSizable];
        self.textView = [[NSTextView alloc] initWithFrame:NSZeroRect];
        [self.textView setAutoresizingMask:NSViewWidthSizable];
        [self.textView setEditable:NO];
        [self.textView setSelectable:YES];
        [self addSubview:self.textView];
    }
    return self;
}

- (void)setPhoneNumber:(NSString *)string {
    
    string = string ? string : NSLocalizedString(@"User.Hidden", nil);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode: NSLineBreakByTruncatingTail];
    
    [paragraphStyle setAlignment:NSLeftTextAlignment];
        
    NSAttributedString *phoneAttributedString = [[NSAttributedString alloc] initWithString:string attributes:@{NSForegroundColorAttributeName: NSColorFromRGB(0x333333), NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-Light" size:15], NSParagraphStyleAttributeName: paragraphStyle}];
    
    NSSize size = [phoneAttributedString sizeForWidth:FLT_MAX height:FLT_MAX];
    
    [[self.textView textStorage] setAttributedString:phoneAttributedString];
    [self.textView setTextContainerInset:NSMakeSize(-3, 0)];
    [self.textView setFrameSize:NSMakeSize(self.bounds.size.width, size.height)];
    [self.textView setFrameOrigin:NSMakePoint(0, 12)];
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Profile.MobilePhone", nil) attributes:[UserInfoContainerView attributsForInfoPlaceholderString]];
    
    [attributedString drawAtPoint:NSMakePoint(0, 35)];
    
    [NSColorFromRGB(0xe6e6e6) set];
    NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, 1));
}

@end
