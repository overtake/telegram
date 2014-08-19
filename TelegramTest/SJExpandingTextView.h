
// SJExpandingTextView.h

// Seb Jachec

#import <Cocoa/Cocoa.h>

@interface SJExpandingTextView : NSTextView {
    SEL action;
    id actionSender;
}

@property BOOL clearsTextOnEnter;

@property UInt16 actionKey;

@property int minimumWidth;
@property int heightMargin;

//Action run on enter
- (void)setAction:(SEL)theAction Sender:(id)sender;

@end