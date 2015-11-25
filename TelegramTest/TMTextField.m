//
//  TMTextField.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTextField.h"
#import "EmojiViewController.h"
#import "RBLPopover.h"

@interface TMTextField ()
@property (nonatomic,assign) BOOL isf;
@end

@implementation PlaceholderTextView

- (id)init {
    self = [super init];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self setAutoresizesSubviews:YES];
    [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self.placeholderAttributedString drawAtPoint:self.placeholderPoint];
}

@end

@interface TMTextField()
@property (nonatomic) BOOL isInitialize;
@property (nonatomic,strong) PlaceholderTextView *reservedPlaceholder;
@end

@implementation TMTextField

+ (id)defaultTextField {
    TMTextField *textField = [[self alloc] init];
    [textField setBordered:NO];
    [textField setDrawsBackground:NO];
    [textField setSelectable:NO];
    [textField setEditable:NO];
    [[textField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    return textField;
}

+ (id)loginPlaceholderTextField {
    TMTextField *textField = [[self alloc] init];
    [textField setTextColor:NSColorFromRGB(0xaeaeae)];
    [textField setWantsLayer:YES];
    [textField setEditable:NO];
    [textField setFont:TGSystemFont(13)];
    [textField setBordered:NO];
    
    return textField;
}


- (void) keyUp:(NSEvent *)theEvent {
    [super keyUp:theEvent];
}


- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
    BOOL retval = NO;
    if (commandSelector == @selector(insertNewline:)) {
        retval = YES; // Handled
        
        // Do stuff that needs to be done when newLine is pressed
    }
    return retval;
}

- (PlaceholderTextView *)placeholderView {
    return [self placeholderView:nil];
}

-(void)setPlaceholderAttributedString:(NSAttributedString *)placeholderAttributedString {
    _placeholder = placeholderAttributedString;
    self.placeholderView.placeholderAttributedString = placeholderAttributedString;
}

-(void)setPlaceholderPoint:(NSPoint)placeholderPoint {
    self->_placeholderPoint = placeholderPoint;
    
    self.placeholderView.placeholderPoint = placeholderPoint;
}

- (PlaceholderTextView *)placeholderView:(id)sender {
    if(sender) {
        self.reservedPlaceholder = sender;
    }
    return self.reservedPlaceholder;
}


- (BOOL)becomeFirstResponder {
    BOOL result = [super becomeFirstResponder];
    
    if(self.placeHolderOnSelf)
        return result;
    
    
    if((!self.placeholderView || self.placeholderView.superview != self.textView)) {
        NSTextView *textView = self.textView;
        if(textView) {
            [self placeholderView:[[PlaceholderTextView alloc] initWithFrame:self.bounds]];
            self.placeholderView.placeholderAttributedString = self.placeholder;
            [textView addSubview:self.placeholderView];
        }
    }
    
    
    self.placeholderView.placeholderAttributedString = self.placeholder;
    self.placeholderView.placeholderPoint = self.placeholderPoint;
    
    [self.placeholderView setHidden:!self.placeholder || self.stringValue.length != 0];
    
    if([self.fieldDelegate respondsToSelector:@selector(textFieldDidBecomeFirstResponder:)]) {
        [self.fieldDelegate textFieldDidBecomeFirstResponder:self];
    }
    
    return result;
}



- (void)setStringValue:(NSString *)aString {
    [super setStringValue:aString ? aString : @""];
    
    if(self.textView.superview.superview == self) {
        [self.placeholderView setHidden:!self.placeholder || self.stringValue.length != 0];
    }
    
    if(self.fieldDelegate) {
        [self.fieldDelegate textFieldDidChange:self];
    }
}

-(void)setAttributedStringValue:(NSAttributedString *)obj {
    [super setAttributedStringValue:obj];
    
    if(self.fieldDelegate) {
        [self.fieldDelegate textFieldDidChange:self];
    }
}

-(void)mouseDown:(NSEvent *)theEvent {
    if(self.clickBlock) {
        self.clickBlock();
    } else {
        [super mouseDown:theEvent];
    }
}

-(void)insertEmoji:(NSString *)emoji {
    [self setStringValue:emoji];
}

-(void)showEmoji {
     EmojiViewController *emojiViewController = [EmojiViewController instance];
        
        weak();
        
        [emojiViewController setInsertEmoji:^(NSString *emoji) {
            [weakSelf insertEmoji:emoji];
        }];
        
        RBLPopover *smilePopover = [[RBLPopover alloc] initWithContentViewController:emojiViewController];
        [smilePopover setDidCloseBlock:^(RBLPopover *popover){

        }];

    if(!smilePopover.isShown) {
        [smilePopover showRelativeToRect:self.frame ofView:self preferredEdge:CGRectMaxYEdge];
        [[EmojiViewController instance] showPopovers];
    }

}



-(void)keyDown:(NSEvent *)theEvent {
    if(theEvent.keyCode != 53) {
        [super keyDown:theEvent];
    } else {
        [self.superview keyDown:theEvent];
    }
    
}



//- (void) drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
//}

@end
