//
//  TGMultipleSelectTextView.m
//  Telegram
//
//  Created by keepcoder on 03.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGMultipleSelectTextView.h"

@implementation TGMultipleSelectTextView



-(void)_mouseDragged:(NSEvent *)theEvent {
   
}

-(void)_mouseDown:(NSEvent *)theEvent {
    
}



-(void)_parentMouseDragged:(NSEvent *)theEvent {
    currentSelectPosition = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    [self setNeedsDisplay:YES];
}

-(void)_parentMouseDown:(NSEvent *)theEvent {
    
}


-(void)copy:(id)sender {
    [[SelectTextManager instance] copy:sender];
}

-(void)_resignFirstResponder {
   
}

-(BOOL)_checkClickCount:(NSEvent *)theEvent {
    
    
    if([super _checkClickCount:theEvent]) {
         [SelectTextManager addRange:self.selectRange forItem:self.item];
        
        return YES;
    }
    
    return NO;
    
}

-(void)rightMouseDown:(NSEvent *)theEvent {
    
    if([SelectTextManager count] > 0) {
        NSTextView *view = (NSTextView *) [self.window fieldEditor:YES forObject:self];
        [view setEditable:NO];
        
        [view setString:[SelectTextManager fullString]];
        
        [view setSelectedRange:NSMakeRange(0, view.string.length)];
        
        
        [NSMenu popUpContextMenu:[view menuForEvent:theEvent] withEvent:theEvent forView:view];
    }
}


-(void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
}



@end
