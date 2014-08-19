//
//  TMWindowTitleView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 27.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMWindowTitleView.h"
#import "NSString+Size.h"
#import "NSStringCategory.h"
@implementation TMWindowTitleView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (NSView *)hitTest:(NSPoint)aPoint {
    return nil;
}

- (void)drawString:(NSString *)string inRect:(NSRect)rect {
    static NSDictionary *att = nil;
    if (!att) {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];
        [style setAlignment:NSCenterTextAlignment];
        
        NSShadow* redShadow = [[NSShadow alloc] init];
        redShadow.shadowOffset = NSMakeSize(0.0f, -0.5f) ;
        redShadow.shadowColor = NSColorFromRGBWithAlpha(0xffffff, 0.5);
        
        att = [[NSDictionary alloc] initWithObjectsAndKeys: style, NSParagraphStyleAttributeName,NSColorFromRGB(0x7d7d7d), NSForegroundColorAttributeName,[NSFont fontWithName:@"Lucida Grande" size:13], NSFontAttributeName,redShadow,NSShadowAttributeName, nil];
        
    }
    
    if(!string || string.length == 0)
        string = @"";
    else {
        string = [@"— " stringByAppendingString:string];
        
        int symb = 25;
        while (string.length < symb) {
            string = [string stringByAppendingString:@"\u00a0"]; // хахахах, ну лол конечно))0
        }
    }
    
    
    NSRect titlebarRect = NSMakeRect(150, rect.origin.y-2, rect.size.width, rect.size.height);
    
    
    
       [string drawInRect:titlebarRect withAttributes:att];
}


- (void)drawRect:(NSRect)dirtyRect
{
    NSRect windowFrame = [NSWindow  frameRectForContentRect:[[[self window] contentView] bounds] styleMask:[[self window] styleMask]];
    NSRect contentBounds = [[[self window] contentView] bounds];
    
    NSRect titlebarRect = NSMakeRect(0, 0, self.bounds.size.width, windowFrame.size.height - contentBounds.size.height);
    titlebarRect.origin.y = self.bounds.size.height - titlebarRect.size.height;
    
    
    [self drawString:self.title inRect:titlebarRect];
    
    
}

-(void)setTitle:(NSString *)title {
    self->_title = title;
    [self setNeedsDisplay:YES];
}

@end
