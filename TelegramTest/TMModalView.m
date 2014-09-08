//
//  TMBlockedView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/4/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMModalView.h"
#import "Telegram.h"

@interface TMModalView()
@end

@implementation TMModalView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAcceptsTouchEvents:YES];
        
        [self setWantsLayer:YES];
        [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self setBackgroundColor:[NSColor whiteColor]];
        
        self.textField = [TMTextField defaultTextField];
        [self.textField setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin];
        [self addSubview:self.textField];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
    
    [image_ClosePopupDialog() drawAtPoint:NSMakePoint(self.bounds.size.width - image_ClosePopupDialog().size.width - 30, self.bounds.size.height - image_ClosePopupDialog().size.height - 30) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    
}

- (void)setHeaderTitle:(NSString *)titleString text:(NSString *)text {
    NSMutableAttributedString *sharingContactAttributedString = [[NSMutableAttributedString alloc] init];
    [sharingContactAttributedString appendString:titleString withColor:NSColorFromRGB(0x222222)];
    [sharingContactAttributedString appendString:@"\n"];
    [sharingContactAttributedString setFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:22] forRange:sharingContactAttributedString.range];
    
    NSRange range = [sharingContactAttributedString appendString:text withColor:NSColorFromRGB(0x9b9b9b)];
    [sharingContactAttributedString setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:range];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSCenterTextAlignment];
    [sharingContactAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:sharingContactAttributedString.range];
    
    NSSize size = [sharingContactAttributedString sizeForTextFieldForWidth:280];
    
    [self.textField setFrameSize:size];
    [self.textField setAttributedStringValue:sharingContactAttributedString];
    [self.textField setFrameOrigin:NSMakePoint(roundf((self.bounds.size.width - self.textField.bounds.size.width ) / 2), roundf((self.bounds.size.height - self.textField.bounds.size.height ) / 2))];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [[Telegram rightViewController] hideModalView:YES animation:YES];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    
}

- (void)mouseExited:(NSEvent *)theEvent {
    
}

- (void)mouseDragged:(NSEvent *)event {

}

- (void)mouseMoved:(NSEvent *)theEvent {
//    DLog(@"lol");
//    [[NSCursor arrowCursor] set];
}

- (void)scrollWheel:(NSEvent *)theEvent {
    
}

- (NSView *)hitTest:(NSPoint)aPoint {
    return self;
}

@end
