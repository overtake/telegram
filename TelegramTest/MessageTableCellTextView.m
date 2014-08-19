//
//  MessageTableCellTextView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellTextView.h"
#import "MessageTableItemText.h"

@interface TestTextView : NSTextView
@property (nonatomic, strong) NSString *rand;
@property (nonatomic) BOOL isSelecedRange;
@property (nonatomic) BOOL linkClicked;
@end

@implementation TestTextView


- (void) clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    
    open_link(link);
  //  [super clickedOnLink:link atIndex:charIndex];
    self.linkClicked = YES;
}

- (void) mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
//    NSLog(@"theEvent %@", theEvent);
    
    if(!self.selectedRange.length) {
        if(self.isSelecedRange) {
            self.isSelecedRange = NO;
        } else {
            if(!self.linkClicked)
                [self.superview mouseDown:theEvent];
            self.linkClicked = NO;
        }
    } else {
        self.isSelecedRange = YES;
    }
    
    //    NSLog(@"mouseDown");
}

//- (void) setFrameOrigin:(NSPoint)newOrigin {
//    NSString *be = NSStringFromRect(self.frame);
//    [super setFrameOrigin:newOrigin];
//    DLog(@"[%@] be %@ stelo %@, text %@", self.rand, be, NSStringFromRect(self.frame), self.string);
//}
////
//- (void) setFrame:(NSRect)frameRect {
//    [self setFrameOrigin:frameRect.origin];
//    [self setFrameSize:frameRect.size];
//    //    NSString *be = NSStringFromRect(self.frame);
////    [super setFrame:frameRect];
//////    DLog(@"")
////    DLog(@"[%@] be %@ stelo %@", self.rand, be, NSStringFromRect(self.frame));
//
//}

@end

@interface MessageTableCellTextView() <TMHyperlinkTextFieldDelegate>
@property (nonatomic, strong) TestTextView *textView;
@property (nonatomic, strong) TMHyperlinkTextField *textField;
@end

@implementation MessageTableCellTextView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.textField = [TMHyperlinkTextField defaultTextField];
        
        [self.textField setFont:[NSFont fontWithName:@"HelveticaNeue" size:13]];
        
        [self.textField setFrameOrigin:NSMakePoint(-2, 0)];
        
       [self.textField setAllowsEditingTextAttributes: YES];
       // [self.textField setImportsGraphics:YES];
        
//        [self.textField setDrawsBackground:YES];
//        
//        [self.textField setBackgroundColor:NSColorFromRGB(0xcccccc)];
        
        
        [self.containerView addSubview:self.textField];
        
        self.textField.url_delegate = self;
        
//        self.textView = [[TestTextView alloc] initWithFrame:NSMakeRect(-5, 2, 0, 0)];
//        [self.textView setEditable:NO];
//        [self.textView setLinkTextAttributes:@{NSForegroundColorAttributeName: LINK_COLOR}];
//        [self.textView setBackgroundColor:[NSColor clearColor]];
//        self.textView.rand = [NSString randStringWithLength:10];
//        [self.textView setTextContainerInset:NSMakeSize(0, 0)];
        //[self.containerView addSubview:self.textView];
    }
    return self;
}

- (void) textField:(id)textField handleURLClick:(NSString *)url {
    open_link(url);
}

- (void)setEditable:(BOOL)editable animation:(BOOL)animation {
    [super setEditable:editable animation:animation];
    
    [self.textField setSelectable:!editable];
    
//    [self.textView setSelectedRange:NSMakeRange(0, 0)];
//    [self.textView setSelectable:!editable];
}

- (void) setItem:(MessageTableItemText *)item {
    [super setItem:item];
    
    
   
    
    self.textField.attributedStringValue = item.textAttributed;
    [self.textField setFrameSize:NSMakeSize(item.blockSize.width, item.blockSize.height+2)];
    
    
     [self.textField.textView setSelectedTextAttributes:item.textAttributes];
  
    //self.textField.selectedTextAttributes = item.textAttributes;
    
//    NSTextStorage *textStorage = [self.textView textStorage];
//    [textStorage setAttributedString:item.textAttributed];
//    
//    [self.textView setFrameSize:item.blockSize];
//    [self.textView setNeedsDisplay:YES];
}



-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

@end
