//
//  TMSearchTextField.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/22/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//
#import "TMSearchTextField.h"
#import "NSString+Extended.h"
#import "NSTextFieldCategory.h"
#import "TMButton.h"
#import "TMAnimations.h"
@interface _TMSearchTextField : NSTextField
@property (nonatomic, strong) id<TMSearchTextFieldDelegate> searchDelegate;
@property (nonatomic) BOOL isInitialize;
@end

@implementation _TMSearchTextField

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
}

-(BOOL)resignFirstResponder {
    
    BOOL res = [super resignFirstResponder];
    
    [self.searchDelegate searchFieldDidResign];
                
    return res;
}

- (BOOL)becomeFirstResponder {
    
    if(!self.isInitialize) {
        self.isInitialize = YES;
        return NO;
    }
    
    BOOL result = [super becomeFirstResponder];
    if(result) {
        
        [self.searchDelegate searchFieldFocus];
        NSText *fieldEditor = [self.window fieldEditor:YES forObject:self];
        [fieldEditor setSelectedRange:NSMakeRange([[fieldEditor string] length], 0)];
        [fieldEditor scrollRangeToVisible:NSMakeRange([[fieldEditor string] length], 0)];
        [fieldEditor setNeedsDisplay:YES];
    }
    return result;
}

- (void)setStringValue:(NSString *)aString {
    aString = [[aString htmlentities] singleLine];
    
    while(aString.length > 0 && [aString characterAtIndex:0] == ' ') {
        aString = [aString substringFromIndex:1];
    }
    
    NSRange range = NSMakeRange(0, 1);
    while(range.length != 0) {
        range = [aString rangeOfString:@"  "];
        aString = [aString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    
    [super setStringValue:aString];
}

- (void)textDidEndEditing:(NSNotification *)notification {
    [self setStringValue:self.stringValue];
    [super textDidEndEditing:notification];
    
    if([[notification.userInfo objectForKey:@"NSTextMovement"] intValue] == 0) {
        [self.searchDelegate searchFieldBlur];
    }
}
-(void)keyUp:(NSEvent *)theEvent {
    [super keyUp:theEvent];
    
    if([self.searchDelegate respondsToSelector:@selector(searchFieldDidEnter)])
    {
        if([self isEnterEvent:theEvent])
            [self.searchDelegate searchFieldDidEnter];
    }
}


- (BOOL)isEnterEvent:(NSEvent *)e {// VK_RETURN
    return ((e.keyCode == 0x24 || e.keyCode ==  0x4C));
}



-(void)keyDown:(NSEvent *)theEvent {
    if(theEvent.keyCode == 53) {
        [self setStringValue:@""];
        
        return;
    }
    
    [super keyDown:theEvent];
}

- (void)textDidChange:(NSNotification *)notification {
    [self setStringValue:self.stringValue];
    [super textDidChange:notification];
}

@end


@interface TMSearchTextField()
@property (nonatomic) BOOL isHover;
@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL isResults;

@property (nonatomic, strong) _TMSearchTextField *textField;
@property (nonatomic, strong) TMButton *cancelButton;
@property (nonatomic, strong) NSImage *bgImage;

@end


@implementation TMSearchTextField

const static int textFieldXOffset = 30;


- (id) initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        self.isHover = NO;
        self.isActive = NO;
        self.isResults = NO;
        [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:NO];

        
        self.containerView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [self.containerView setAutoresizingMask:NSViewWidthSizable];
        [self addSubview:self.containerView];
        
        NSImage *image = image_searchIcon();
        NSImageView *searchIconImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(13, roundf((self.bounds.size.height - image.size.height) / 2), image.size.width, image.size.height)];
        searchIconImageView.image = image;
        [self.containerView addSubview:searchIconImageView];
        
        
        self.textField = [[_TMSearchTextField alloc] initWithFrame:NSZeroRect];
        [self.textField setDelegate:self];
        [self.textField setSearchDelegate:self];
        NSAttributedString *placeholderAttributed = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Search", nil) attributes:@{NSForegroundColorAttributeName: NSColorFromRGB(0xaeaeae), NSFontAttributeName: TGSystemLightFont(12)}];
        [[self.textField cell] setPlaceholderAttributedString:placeholderAttributed];
        
        [self.textField setBackgroundColor:[NSColor clearColor]];
        [self.textField setFont:TGSystemLightFont(12)];
        [self.textField setStringValue:NSLocalizedString(@"Search", nil)];
        [self.textField sizeToFit];
        [self.textField setStringValue:@""];
        
        [self.textField setFrame:NSMakeRect(textFieldXOffset, roundf((self.frame.size.height - self.textField.frame.size.height) / 2) - 1, self.containerView.frame.size.width - 30 - textFieldXOffset, self.textField.bounds.size.height)];
        
        
        [self.textField setBordered:NO];
        
        [self.textField setFocusRingType:NSFocusRingTypeNone];
        [[self.textField cell] setTruncatesLastVisibleLine:NO];
        [[self.textField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        
        [self.containerView addSubview:self.textField];
        
        
        
        
        
        
        self.cancelButton = [[TMButton alloc] initWithFrame:NSZeroRect];
        [self.cancelButton setAutoresizingMask:NSViewMinXMargin];
        [self.cancelButton setImage:image_clear() forState:TMButtonNormalState];
        [self.cancelButton setImage:image_clearActive() forState:TMButtonPressedState];
        
        [self.cancelButton setFrameSize:image_clear().size];
        [self.cancelButton setFrameOrigin:NSMakePoint(self.frame.size.width - self.cancelButton.frame.size.width - 10, roundf((self.bounds.size.height - self.cancelButton.bounds.size.height) / 2))];
//        [self.cancelButton setBackgroundColor:[NSColor redColor]];
        [self.cancelButton setNeedsDisplay:YES];
        [self.cancelButton setHidden:YES];
        [self.cancelButton setTarget:self selector:@selector(cancelButtonClick)];
        [self addSubview:self.cancelButton];
        [self.containerView setWantsLayer:YES];
    }
    
    return self;
}

-(BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

-(void)searchFieldDidEnter {
    [self.delegate searchFieldDidEnter];
}


- (bool)endEditing;
{
    bool success;
    id responder = [[NSApp mainWindow] firstResponder];
    
    
    if ( (responder != nil) && [responder isKindOfClass:[NSTextView class]] && [(NSTextView*)responder isFieldEditor] )
        responder = ( [[responder delegate] isKindOfClass:[NSResponder class]] ) ? [responder delegate] : nil;
    
    success = [[NSApp mainWindow] makeFirstResponder:nil];
    
    [self centerPosition:YES];
    
    return success;
}

-(BOOL)isFirstResponder {
    id responder = [self.window firstResponder];
    
    return [responder isKindOfClass:[NSTextView class]] && [[responder superview] superview] == self.textField;
}

-(void)setSelectedRange:(NSRange)range {
    [self.textField setSelectionRange:range];
}


- (void)setFrameSize:(NSSize)newSize {
    
    [super setFrameSize:newSize];
    
    
    [self.textField setFrame:NSMakeRect(textFieldXOffset, roundf((self.frame.size.height - self.textField.frame.size.height) / 2) - 2, self.containerView.frame.size.width - 30 - textFieldXOffset, self.textField.bounds.size.height)];
    
   // [self.textField setFrameOrigin:NSMakePoint(30, NSMinY(self.textField.frame))];
    
    [self.textField setFrameSize:NSMakeSize(self.containerView.frame.size.width - 30 - NSMinX(self.textField.frame), NSHeight(self.textField.frame))];
    
    if([self inLiveResize]) {
        if(self.textField.window.firstResponder != self.textField.textView) {
            [self centerPosition:NO];
        } else {
            [self leftPosition:NO];
        }
    } else {
        [self.containerView setFrameOrigin:NSMakePoint(roundf((self.bounds.size.width - [self containerWidth]) / 2), 0)];
    }
}

static float duration = 0.1;

- (void)viewDidMoveToWindow {
    [self.containerView setFrameOrigin:NSMakePoint(roundf((self.bounds.size.width - [self containerWidth]) / 2), 0)];
    [super viewDidMoveToSuperview];

   // dispatch_async(dispatch_get_main_queue(), ^{
        [self.containerView setFrameOrigin:NSMakePoint(0, 0)];
        [self centerPosition:NO];
   // });
}

- (void)leftPosition:(BOOL)animation {
    NSPoint point = NSMakePoint(0, self.containerView.frame.origin.y);
    if(NSEqualPoints(point, self.containerView.frame.origin))
        return;
    
    if(animation) {
        [self.containerView setFrameOrigin:NSMakePoint(0, 0)];
        [self.containerView setWantsLayer:YES];
        [self.containerView.layer removeAllAnimations];
        
        NSPoint oldPoint = self.containerView.layer.position;
        NSPoint point = oldPoint;
        point.x += roundf((self.bounds.size.width - [self containerWidth]) / 2);
        
        CAAnimation *animation = [TMAnimations postionWithDuration:duration fromValue:point toValue:oldPoint];
        animation.delegate = self;
        self.containerView.layer.position = oldPoint;
        [self.containerView.layer addAnimation:animation forKey:@"position"];
    } else {
        [self.containerView setFrameOrigin:point];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if(flag) {
        [self.containerView setWantsLayer:NO];
    }
}

- (void)centerPosition:(BOOL)animation {

    if(self.textField.stringValue.length > 0)
        return;
    
    NSPoint point = NSMakePoint(roundf((self.bounds.size.width - [self containerWidth]) / 2), self.containerView.frame.origin.y);
    if(NSEqualPoints(point, self.containerView.frame.origin))
        return;
    
    if(animation) {
        [self.containerView setWantsLayer:YES];
        [self.containerView.layer removeAllAnimations];
        NSPoint oldPoint = self.containerView.layer.position;
        
        self.containerView.layer.position = NSMakePoint(self.containerView.layer.position.x + point.x, self.containerView.layer.position.y);

        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self.containerView setFrameOrigin:point];
            self.containerView.wantsLayer = NO;
        }];
        [self.containerView.layer addAnimation:[TMAnimations postionWithDuration:duration fromValue:NSMakePoint(oldPoint.x, oldPoint.y) toValue:self.containerView.layer.position] forKey:@"position"];
    } else {
        [self.containerView setFrameOrigin:point];
    }
}

- (float)containerWidth {
    
    NSSize size = self.textField.frame.size;
    [self.textField sizeToFit];
    NSSize newSize = self.textField.frame.size;
    [self.textField setFrameSize:size];
    
    return self.textField.frame.origin.x + newSize.width + 10;
}

- (void)setStringValue:(NSString *)value {
    [self.textField setStringValue:value];
    [self controlTextDidChange:nil];
}

- (NSString *)stringValue {
    return _textField.stringValue;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    static const double radius = 6;
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(1, 1, self.bounds.size.width - 2, self.bounds.size.height - 2) xRadius:radius yRadius:radius];
    
    [NSColorFromRGB(0xf4f4f4) setFill];
    [path fill];
}

- (void) mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    if(!self.isActive) {
        [self.textField becomeFirstResponder];
    }
}



- (void) cancelButtonClick {
    self.textField.stringValue = @"";
    [self controlTextDidChange:nil];
    
    if(![self isTextFieldInFocus:self.textField]) {
        [self centerPosition:YES];
    }
    
    [self endEditing];
}

- (BOOL)isTextFieldInFocus:(NSTextField *)textField {
	BOOL inFocus = ([[[textField window] firstResponder] isKindOfClass:[NSTextView class]]
			   && [[textField window] fieldEditor:NO forObject:nil]!=nil
			   && [textField isEqualTo:(id)[(NSTextView *)[[textField window] firstResponder]delegate]]);
	
	return inFocus;
}

- (void) controlTextDidChange:(NSNotification *)obj {
    [self.cancelButton setHidden:!self.textField.stringValue.length];
    [self.delegate searchFieldTextChange:self.textField.stringValue];
}





//- (void) setNeedsDisplay:(BOOL)flag {
//    [super setNeedsDisplay:flag];
//
//    if(self.isActive) {
//        self.bgImage = searchFieldActive();
//    } else {
//        self.bgImage = searchFieldImage();
//    }
//}

- (void) searchFieldBlur {
    self.isActive = NO;
//    if(self.)
 //   [self centerPosition:YES];
//    [self setNeedsDisplay:YES];
    
    [self.cancelButton setHidden:self.textField.stringValue.length == 0];
    if([self.delegate respondsToSelector:@selector(searchFieldBlur)])
        [self.delegate searchFieldBlur];
}

- (void) searchFieldFocus {
    self.isActive = YES;
    [self leftPosition:YES];
//    [self setNeedsDisplay:YES];
     [self.cancelButton setHidden:NO];
    
    if([self.delegate respondsToSelector:@selector(searchFieldFocus)])
        [self.delegate searchFieldFocus];
}

- (void) searchFieldDidResign {
    [self.cancelButton setHidden:self.textField.stringValue.length == 0];
    if([self.delegate respondsToSelector:@selector(searchFieldFocus)])
        [self.delegate searchFieldFocus];
}

- (void) mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    self.isHover = YES;
//    [self setNeedsDisplay:YES];
}

- (void) mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    self.isHover = NO;
//    [self setNeedsDisplay:YES];
}

- (void) searchFieldTextChange:(NSString *)searchString {
    [NSException raise:@"Not implemented" format:@""];
}



@end
