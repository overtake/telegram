
// SJExpandingTextView.m

// Seb Jachec

#import "SJExpandingTextView.h"

@implementation SJExpandingTextView

- (void)setAction:(SEL)theAction Sender:(id)sender {
    actionSender = sender;
    action = theAction;
}

- (void)keyUp:(NSEvent *)theEvent {
    UInt16 key = [theEvent keyCode];
    
    if ((_actionKey && key == _actionKey) || (!_actionKey && key == 36)) {
        if (actionSender && action) {
            MTLog(@"Enter");
            NSString *stringSelector = NSStringFromSelector(action);
            
            //Could be action:(id)sender for example
            if ([[stringSelector substringFromIndex:stringSelector.length-1] isEqualToString:@":"]) {
                @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [actionSender performSelector:action withObject:self];
#pragma clang diagnostic pop
                }
                @catch (NSException *exception) {
                    MTLog(@"SJExpandingTextView: Unable to performSelector: withObject:self . Selector '%@'. Object: '%@'",NSStringFromSelector(action), [actionSender description]);
                }
            } else {
                //If not, performSelector: as normal
                @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [actionSender performSelector:action];
#pragma clang diagnostic pop
                }
                @catch (NSException *exception) {
                    MTLog(@"SJExpandingTextView: Unable to performSelector: . Selector '%@'. Object: '%@'",NSStringFromSelector(action), [actionSender description]);
                }
            }
        }
        
        if (_clearsTextOnEnter) {
            self.string = @"";
            [self didChangeText];
        }
    }
    
    [super keyUp:theEvent];
}

- (void)didChangeText {
    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
    
    //Get the correct sized NSRect for the text in the our text container
    NSRect newRect = [self.layoutManager usedRectForTextContainer:self.textContainer];
    
    //If there's a height margin set, add it on to the height (of course!)
    if (_heightMargin) {
        newRect.size.height += _heightMargin;
    }
    
    //Ensure that we doesn't start shrinking the width when you fill less than a line.
    if ((_minimumWidth && newRect.size.width >= _minimumWidth) || (newRect.size.width >= self.frame.size.width)) {
        //For some reason, I'm not sure why, we need to reference [[You are here] > superview > superview] to get to the our containing NSScrollView and set it's frameSize.
        [self.superview.superview setFrameSize:newRect.size];
    }
}

@end
