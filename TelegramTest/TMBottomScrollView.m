//
//  TMBottomScrollView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 24.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMBottomScrollView.h"
#import "TGCalendarView.h"
#import "MessageTableItem.h"
#import "TGCirclularCounter.h"
@interface TMBottomScrollView ()<MLCalendarViewDelegate>
@property (nonatomic,strong) TGCirclularCounter *circularCounter;


@end

@implementation TMBottomScrollView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layerContentsPlacement = NSViewLayerContentsPlacementScaleAxesIndependently;
        self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
        
        
        _circularCounter = [[TGCirclularCounter alloc] initWithFrame:NSMakeRect(0, 0, 44, 44)];
        
        _circularCounter.textFont = TGSystemFont(13);
        _circularCounter.textColor = [NSColor whiteColor];
        _circularCounter.backgroundColor = NSColorFromRGB(0x5098d3);
        
        [_circularCounter setHidden:YES];
        
        [self addSubview:_circularCounter];
        
        [self addTarget:self action:@selector(clickHandler) forControlEvents:BTRControlEventLeftClick];
        
        
        [self dropCounter];
        

    }
    return self;
}

-(void)dropCounter {
    _circularCounter.animated = NO;
    _circularCounter.stringValue = @"1";
    _circularCounter.animated = YES;
}


-(void)setMessagesViewController:(MessagesViewController *)messagesViewController {
    _messagesViewController = messagesViewController;
}



-(void)setHidden:(BOOL)flag {
    [super setHidden:flag];
    
    if(flag) {
        [self setMessagesCount:0];
        [self dropCounter];
        [self sizeToFit];
    }
    
}


- (void)clickHandler {

    if(_callback) {
        _callback();
        [self setHidden:YES];
    }
}

- (void)handleStateChange {
    [self setNeedsDisplay:YES];
}

- (void)setMessagesCount:(int)messagesCount {
    if(messagesCount == self->_messagesCount)
        return;
    
    self->_messagesCount = messagesCount;
    
    [_circularCounter setHidden:messagesCount == 0];
    
    if(messagesCount > 0)
        _circularCounter.stringValue = [NSString stringWithFormat:@"%d",messagesCount];
    
//    if(messagesCount) {
//        self.messagesCountAttributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d",messagesCount] attributes:@{NSFontAttributeName: TGSystemFont(14), NSForegroundColorAttributeName: [NSColor whiteColor]}];
//    } else {
//        self.messagesCountAttributedString = nil;
//    }
    
    
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    CGContextRef context = [NSGraphicsContext currentContext].graphicsPort;
    [NSGraphicsContext saveGraphicsState];
    CGContextSetShouldSmoothFonts(context, TRUE);
    
    
    int width = 42;
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(1, 1, width, width) xRadius:width/2.0 yRadius:width/2.0];
    
    NSColor *fillColor = self.isHover ? NSColorFromRGB(0xffffff) : NSColorFromRGB(0xfdfdfd);
    NSColor *strokeColor = GRAY_BORDER_COLOR;
    
    [fillColor setFill];
    [strokeColor setStroke];
    
    [path setLineWidth:1];
    
    [path fill];
    [path stroke];
    

    
    
    
   // if(self.messagesCount) {
        
        
        
//        NSSize size = [self.messagesCountAttributedString size];
//        size.width = ceil(size.width) ;
//        
//        int max = MAX(size.width,size.height);
//    
//        int cmax = max + 10;
//    
//        NSBezierPath *cpath = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(roundf((NSWidth(self.frame) - cmax)/2.0), NSHeight(self.frame) - cmax, cmax, cmax) xRadius:cmax/2.0f yRadius:cmax/2.0f];
//        
//        [BLUE_UI_COLOR setFill];
//        
//         NSPoint point = NSMakePoint(roundf((NSWidth(self.frame) - size.width)/2.0), NSHeight(self.frame) - ((float)cmax - size.height/2.0));
//        
//        [cpath fill];
//        
    
        
       // [self.messagesCountAttributedString drawAtPoint:point];
  //  }
    
    
    NSPoint ipoint;
    
    ipoint.y = roundf((width - image_ScrollDownArrow().size.height) * 0.5);
    
    [image_ScrollDownArrow() drawAtPoint:ipoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    
    [NSGraphicsContext restoreGraphicsState];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_circularCounter setCenteredXByView:self];
    
    [_circularCounter setFrameOrigin:NSMakePoint(NSMinX(_circularCounter.frame), newSize.height - NSHeight(_circularCounter.frame))];
}

- (void)sizeToFit {
    
    NSSize size = NSMakeSize(0, 0);

    
    size.width =44;

    size.height = 44;
    
    if(_messagesCount > 0) {
        size.height+=20;
        if(_messagesCount > 100)
            size.height+=10;
    }
    
//    if(_messagesCountAttributedString.length > 0) {
//        NSSize tsize = [_messagesCountAttributedString size];
//        int m = MAX(tsize.width + 10,tsize.height);
//        size.height+= roundf(m/2.0f);
//    }
    
    
    [self setFrameSize:size];
    
    
    [self setNeedsDisplay:YES];
//    [self.layer setNeedsLayout];
//    [self.layer needsDisplay];
}

@end