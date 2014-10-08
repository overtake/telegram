//
//  MessageTableCellTextView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellTextView.h"
#import "MessageTableItemText.h"
#import "TGTimerTarget.h"
@interface TestTextView : NSTextView
@property (nonatomic, strong) NSString *rand;
@property (nonatomic) BOOL isSelecedRange;
@property (nonatomic) BOOL linkClicked;
@end


@interface MessageTableCellTextView() <TMHyperlinkTextFieldDelegate>
@property (nonatomic,strong) NSTimer *bgTimer;
@end

@implementation MessageTableCellTextView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        _textView = [[TGMultipleSelectTextView alloc] initWithFrame:self.bounds];
        [self.containerView addSubview:self.textView];
        
        
    }
    return self;
}

- (void) textField:(id)textField handleURLClick:(NSString *)url {
    open_link(url);
}

-(void)selectSearchTextInRange:(NSRange)range {
    
    [self.textView setSelectionRange:range];
    
  //  [self.textField becomeFirstResponder];
    
}


- (void)setEditable:(BOOL)editable animation:(BOOL)animation {
    [super setEditable:editable animation:animation];
    [self.textView setEditable:!editable];
}

- (void) setItem:(MessageTableItemText *)item {
    
    [super setItem:item];
    
    [self.textView setFrameSize:NSMakeSize(item.blockSize.width , item.blockSize.height)];
    [self.textView setAttributedString:item.textAttributed];
    
    [self.textView setItem:item];
    
    [self.textView setSelectionRange:[SelectTextManager rangeForItem:item]];
    
    [self.textView addMarks:item.mark.marks];

}


-(void)_mouseDragged:(NSEvent *)theEvent {
    [self.textView _parentMouseDragged:theEvent];
}

-(void)_setStartSelectPosition:(NSPoint)position {
     self.textView->startSelectPosition = position;
    [self.textView setNeedsDisplay:YES];
}
-(void)_setCurrentSelectPosition:(NSPoint)position {
     self.textView->currentSelectPosition = position;
     [self.textView setNeedsDisplay:YES];
}

-(void)setSelected:(BOOL)selected animation:(BOOL)animation {
    
    if(self.isSelected == selected)
        return;
    
    [super setSelected:selected animation:animation];
    
//    if(animation) {
//        NSColor *color = selected ? NSColorFromRGB(0xfafafa) : NSColorFromRGB(0xffffff);
//        NSColor *oldColor = !selected ? NSColorFromRGB(0xfafafa) : NSColorFromRGB(0xffffff);
//        
//        
//        POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
//        animation.fromValue = (__bridge id)(oldColor.CGColor);
//        animation.toValue = (__bridge id)(color.CGColor);
//        
//        animation.removedOnCompletion = YES;
//        
//        animation.delegate = self;
//        
//        
//        
//        [self.bgTimer invalidate];
//        
//        self.bgTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(_colorAnimationEvent) interval:0.05 repeat:true];
//        
//        [[NSRunLoop mainRunLoop] addTimer:self.bgTimer forMode:NSRunLoopCommonModes];
//        
//        [self.textView.layer pop_addAnimation:animation forKey:@"backgroundColor"];
//        
//        
//    } else {
//        [self.textView setBackgroundColor:self.item.isSelected ? NSColorFromRGB(0xfafafa) : NSColorFromRGB(0xffffff)];
//    }
//    
//    
     [self.textView setBackgroundColor:self.item.isSelected ? NSColorFromRGB(0xfafafa) : NSColorFromRGB(0xffffff)];
}

-(void)_colorAnimationEvent {
    CALayer *currentLayer = (CALayer *)[self.textView.layer presentationLayer];
    
    id value = [currentLayer valueForKeyPath:@"backgroundColor"];
    
    self.textView.layer.backgroundColor = (__bridge CGColorRef)(value);
    [self.textView setNeedsDisplay:YES];
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished {
    if(finished) {
        [self.bgTimer invalidate];
        self.bgTimer = nil;
    }
    
    [self.textView setBackgroundColor:self.item.isSelected ? NSColorFromRGB(0xfafafa) : NSColorFromRGB(0xffffff)];
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
  //  CFAttributedStringRef attrString =
    
   
    
}

@end
