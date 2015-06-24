//
//  UserInfoPhoneView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/5/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "UserInfoParamsView.h"
#import "UserInfoContainerView.h"
#import "NS(Attributed)String+Geometrics.h"
#import "TGCTextView.h"
@interface UserInfoParamsView()
@property (nonatomic, strong) TGCTextView *textView;
@property (nonatomic,strong) NSString *header;
@end

@implementation UserInfoParamsView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizingMask:NSViewWidthSizable];
        self.textView = [[TGCTextView alloc] initWithFrame:NSZeroRect];
        [self.textView setAutoresizingMask:NSViewWidthSizable];
        [self.textView setEditable:YES];
        [self addSubview:self.textView];
        self.header = @"";
    }
    return self;
}


- (int)setString:(NSString *)string {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSLeftTextAlignment];
    
    NSAttributedString *phoneAttributedString = [[NSAttributedString alloc] initWithString:string attributes:@{NSForegroundColorAttributeName: NSColorFromRGB(0x333333), NSFontAttributeName:TGSystemLightFont(14), NSParagraphStyleAttributeName: paragraphStyle}];
    
    NSSize size = [phoneAttributedString coreTextSizeForTextFieldForWidth:NSWidth(self.frame)];
    
    [self.textView setAttributedString:phoneAttributedString];
    
    [self.textView setFrameOrigin:NSMakePoint(0, 10)];
    [self.textView setFrameSize:NSMakeSize(NSWidth(self.frame), size.height)];
    
    if(size.height > 21)
        [self setToolTip:phoneAttributedString.string];
    else
        [self setToolTip:nil];
   
    return size.height;
    
}


-(NSString *)string {
    return [self.textView attributedString].string;
}

- (void)setHeader:(NSString *)header {
    _header = header ? header : @"";
    
    [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.header attributes:[UserInfoContainerView attributsForInfoPlaceholderString]];
    
    [attributedString drawAtPoint:NSMakePoint(0, NSMaxY(self.textView.frame) + 5)];
    
    [NSColorFromRGB(0xe6e6e6) set];
    NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, 1));
}

@end
