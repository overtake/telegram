//
//  TGGeneralInputTextRowView.m
//  Telegram
//
//  Created by keepcoder on 05/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGGeneralInputTextRowView.h"
#import "TGGeneralInputRowItem.h"
#import "TGPopoverHint.h"
#import "NSTextView+EmojiExtension.h"
@interface TGInputTextField : NSTextView
@property (nonatomic,strong) NSAttributedString *placeholder;
@end

@implementation TGInputTextField


-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(self.string.length == 0 && self.placeholder.length > 0)
    {
        if(self.placeholder) {
            
            [self.placeholder drawAtPoint:NSMakePoint(6, 0)];
        }
    }
}

-(void)keyDown:(NSEvent *)theEvent {
    if([TGPopoverHint isShown] && (theEvent.keyCode == 125 || theEvent.keyCode == 126 || theEvent.keyCode == 121 || theEvent.keyCode == 116)) {
        if(theEvent.keyCode == 125 || theEvent.keyCode == 121) {
            [[TGPopoverHint hintView] selectNext];
        } else {
            [[TGPopoverHint hintView] selectPrev];
        }
    } else if(!isEnterAccess(theEvent)) {
        if(isEnterEvent(theEvent)) {
            [self insertNewline:nil];
        } else
            [super keyDown:theEvent];
    }
}

-(void)setSelectedRange:(NSRange)selectedRange {
    [super setSelectedRange:selectedRange];
}

@end

@interface TGGeneralInputTextRowView () <NSTextViewDelegate>
@property (nonatomic,strong) TGInputTextField *textField;
@property (nonatomic,strong) TMView *separator;

@end

@implementation TGGeneralInputTextRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _textField = [[TGInputTextField alloc] init];
        [_textField setFont:TGSystemFont(13)];
        [_textField setEditable:YES];
      //  [_textField setBordered:NO];
        [_textField setDrawsBackground:NO];
        [_textField setFocusRingType:NSFocusRingTypeNone];
        
        
        [_textField setFrameSize:NSMakeSize(NSWidth(self.frame) - 60, 20)];
        
      //  _textField.fieldDelegate = self;
        _textField.delegate = self;
        
        [self addSubview:_textField];
        
        _separator = [[TMView alloc] initWithFrame:NSZeroRect];
        
        _separator.backgroundColor = DIALOG_BORDER_COLOR;
        
        [self addSubview:_separator];
    }
    
    return self;
}



-(void)textFieldDidChange:(id)field {
   
}

-(BOOL)becomeFirstResponder {
    
    [self.window makeFirstResponder:_textField];
    
    return [_textField becomeFirstResponder];
}

-(void)textFieldDidBecomeFirstResponder:(id)field {
    if( self.item.callback != nil) {
        self.item.callback(self.item);
    }
}



- (void)textDidChange:(NSNotification *)notification {
    
    NSRange range = _textField.selectedRange;
    
    int limit = self.item.limit > 0 ? self.item.limit : 200;
    
    [_textField setString:[_textField.string substringToIndex:MIN(limit,_textField.string.length)]];
    
    _textField.selectedRange = NSMakeRange(MIN(range.location,limit), 0);
    
    self.item.result = [[_textField textStorage] attributedSubstringFromRange:NSMakeRange(0, _textField.string.length)];
    
    
    
    
    NSSize size = [self.item.result sizeForTextFieldForWidth:NSWidth(self.frame) - (self.item.xOffset * 2)];
    
    size.height = MAX(17,size.height);
    
    self.item.height = size.height + 5;
    
    NSSize oldSize = _textField.frame.size;
    
    if(oldSize.height != size.height) {
        
        
        [[NSAnimationContext currentContext] setDuration:0];
        [self.rowItem.table noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:self.row]];
        
        
        [_textField setFrameSize:NSMakeSize(NSWidth(self.frame) - self.item.xOffset * 2, size.height)];
        
        
      //  [[_separator animator] setFrame:NSMakeRect(self.item.xOffset, 0, NSWidth(self.frame) - (self.item.xOffset * 2), DIALOG_BORDER_WIDTH)];
       // if(rand_limit(5) > 3) {
        
       // [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
          //  [context setDuration:0.5];
        [_textField setFrameOrigin:NSMakePoint(self.item.xOffset - 4, 5)];
      //  } completionHandler:^{
            
    //    }];
        
     //   }
        
        
        
        
    }
    
    if( self.item.callback != nil) {
        self.item.callback(self.item);
    }
    
    
 //
    
    if(self.item.hintAbility) {
        [self.textField tryShowHintView:self.item.conversation];
    }
    
    
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_textField setFrameOrigin:NSMakePoint(self.item.xOffset - 4, 5)];
    [_textField setFrameSize:NSMakeSize(newSize.width - self.item.xOffset * 2, self.item.height - 5)];
    [_separator setFrame:NSMakeRect(self.item.xOffset, 0, NSWidth(self.frame) - (self.item.xOffset * 2), DIALOG_BORDER_WIDTH)];
}


-(void)redrawRow {
    [super redrawRow];
    
    if(self.item.result.length > 0)
        [[_textField textStorage] setAttributedString:self.item.result];
    
    if(self.item.placeholder.length > 0) {
        
        NSMutableAttributedString *placeHolder = [[NSMutableAttributedString alloc] init];
        [placeHolder appendString:self.item.placeholder withColor:GRAY_TEXT_COLOR];
        [placeHolder setFont:_textField.font forRange:placeHolder.range];
        [_textField setPlaceholder:placeHolder];
    }
    
    [self.window makeFirstResponder:_textField];
    
}

-(TGGeneralInputRowItem *)item {
    return (TGGeneralInputRowItem *)[self rowItem];
}

@end
