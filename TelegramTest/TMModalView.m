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
@property (nonatomic,strong) NSAttributedString *attributedString;
@property (nonatomic,assign) NSSize size;
@end

@implementation TMModalView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
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
    
    
    [self.attributedString drawInRect:NSMakeRect(roundf((self.bounds.size.width - self.size.width ) / 2), roundf((self.bounds.size.height - self.size.height ) / 2), self.size.width, self.size.height)];
    
}

- (void)setHeaderTitle:(NSString *)titleString text:(NSString *)text {
    NSMutableAttributedString *sharingContactAttributedString = [[NSMutableAttributedString alloc] init];
    [sharingContactAttributedString appendString:titleString withColor:NSColorFromRGB(0x222222)];
    [sharingContactAttributedString appendString:@"\n"];
    [sharingContactAttributedString setFont:TGSystemLightFont(22) forRange:sharingContactAttributedString.range];
    
    NSRange range = [sharingContactAttributedString appendString:text withColor:NSColorFromRGB(0x9b9b9b)];
    [sharingContactAttributedString setFont:TGSystemFont(13) forRange:range];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSCenterTextAlignment];
    [sharingContactAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:sharingContactAttributedString.range];
    
    NSSize size = [sharingContactAttributedString sizeForTextFieldForWidth:280];
    
    
    self.size = size;
    
    self.attributedString = sharingContactAttributedString;
    
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if(!self.isHidden)
        [[Telegram rightViewController] hideModalView:YES animation:YES];
    else
        [super mouseDown:theEvent];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    if(self.isHidden)
        [super mouseEntered:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent {
    if(self.isHidden)
        [super mouseExited:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if(self.isHidden)
        [super mouseDragged:theEvent];
}

- (void)mouseMoved:(NSEvent *)theEvent {
//    MTLog(@"lol");
//    [[NSCursor arrowCursor] set];
}

- (void)scrollWheel:(NSEvent *)theEvent {
     if(self.isHidden)
         [super scrollWheel:theEvent];
}

- (NSView *)hitTest:(NSPoint)aPoint {
    return self;
}

@end
