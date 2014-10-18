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
#import "POPCGUtils.h"
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


-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim {
    
    
    POPBasicAnimation *animation = [POPBasicAnimation animation];
    
    animation.property = [POPAnimatableProperty propertyWithName:@"background" initializer:^(POPMutableAnimatableProperty *prop) {
        
        [prop setReadBlock:^(TGCTextView *textView, CGFloat values[]) {
            POPCGColorGetRGBAComponents(textView.backgroundColor.CGColor, values);
        }];
        
        [prop setWriteBlock:^(TGCTextView *textView, const CGFloat values[]) {
            CGColorRef color = POPCGColorRGBACreate(values);
            textView.backgroundColor = [NSColor colorWithCGColor:color];
        }];
        
    }];
    
    animation.toValue = anim.toValue;
    animation.fromValue = anim.fromValue;
    animation.duration = anim.duration;
    [self.textView pop_addAnimation:animation forKey:@"background"];
    
}

-(void)_colorAnimationEvent {
    CALayer *currentLayer = (CALayer *)[self.textView.layer presentationLayer];
    
    id value = [currentLayer valueForKeyPath:@"backgroundColor"];
    
    self.textView.layer.backgroundColor = (__bridge CGColorRef)(value);
    [self.textView setNeedsDisplay:YES];
}

-(void)setSelected:(BOOL)selected animation:(BOOL)animation {
    if(selected == self.isSelected)
        return;
    
    [super setSelected:selected animation:animation];
    
    if(!animation) {
        [self.textView setBackgroundColor:selected ? NSColorFromRGB(0xfafafa) : NSColorFromRGB(0xffffff)];
    }
}

@end
