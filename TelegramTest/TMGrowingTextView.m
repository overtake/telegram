//
//  TMGrowingTextView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/24/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMGrowingTextView.h"
#import "TMNineImage.h"
#import "NSString+Extended.h"
#import "TGAnimationBlockDelegate.h"
#import "NSTextView+AutomaticLinkDetection.h"
@interface TMGrowingTextCell : NSTextFieldCell

@end

@interface TMGrowingTextView()
//@property (nonatomic) NSUInteger lastNumbersCount;
@property (nonatomic, strong) NSAttributedString *placeholderTextAttributedString;
@end

@implementation TMGrowingTextView


- (id) init {
    self = [super init];
    if(self) {
        [self initialize];
    }
    return self;
}


- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id) initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id) initWithFrame:(NSRect)frameRect textContainer:(NSTextContainer *)container {
    self = [super initWithFrame:frameRect textContainer:container];
    if(self) {
        [self initialize];
    }
    return self;
}

-(void)setMode:(TMGrowingMode)mode {
    self->_mode = mode;
    [[self textContainer] setHeightTracksTextView:mode == TMGrowingModeSingleLine];
}

- (BOOL) becomeFirstResponder {
    BOOL result = [super becomeFirstResponder];
    [self.growingDelegate TMGrowingTextViewFirstResponder:self isFirstResponder:result];
    return result;
}

- (BOOL) resignFirstResponder {
    BOOL result = [super resignFirstResponder];
    [self.growingDelegate TMGrowingTextViewFirstResponder:self isFirstResponder:!result];
    return result;
}

- (void)controlTextDidChange:(NSNotification *)obj {
}


- (void)textDidChange:(NSNotification *)notification {
    
    [self detectAndAddLinks];
    
    self.font = [NSFont fontWithName:@"HelveticaNeue" size:[SettingsArchiver checkMaskedSetting:BigFontSetting] ? 15 : 13];
    
    
//    NSUInteger numberOfLines, index, numberOfGlyphs = [self.layoutManager numberOfGlyphs];
//    NSRange lineRange;
//    
//    
////    NSUInteger endVisibleLine = 0;
//    for (numberOfLines = 0, index = 0; index < numberOfGlyphs; numberOfLines++) {
//        (void) [self.layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
//        index = NSMaxRange(lineRange);
////        if(numberOfLines == self.maxLines-1) {
////            endVisibleLine = index;
////        }
//    }
//    self.lastNumbersCount = numberOfLines;
    
    [self.scrollView setIsHideVerticalScroller:YES];
    [self.scrollView setDisableScrolling:self.string.length == 0];
    [self.scrollView setHasVerticalScroller:self.string.length != 0];
    [[self.scrollView verticalScroller] setControlSize: NSSmallControlSize];
    
    
    
    
    self.scrollView.verticalScrollElasticity = self.scrollView.documentSize.height <= self.scrollView.frame.size.height ? NSScrollElasticityNone : NSScrollElasticityAllowed;
    
    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
    NSRect newRect = [self.layoutManager usedRectForTextContainer:self.textContainer];
    
    NSSize size = newRect.size;
    size.width = self.containerView.bounds.size.width;
    
    
   // NSArray *
   
    
    NSSize newSize = NSMakeSize(size.width, size.height);
//
//    int height = (int)newSize.height % 14;
//    
//    if(height == 0 && [self.string getEmojiFromString].count > 0)
//        height = 6;
//    
//    NSArray *lines = [self.string componentsSeparatedByString:@"\n"];
//    
//    
    
    
//    
//    if(height != 0)
//        height = 4;
//
    
//    newSize.height-=height;
    
    newSize.height+= 8;
    
  //  NSLog(@"%@, height:%d",NSStringFromSize(newSize), height);
    
    if(newSize.height < 33)
        newSize.height = 33;
    
    
    int maxHeight = 250;
    
    if(newSize.height > maxHeight)
        newSize.height = maxHeight;
    
    
    
    BOOL isCleared = self.string.length == 0 && self.lastHeight > newSize.height && !self.disableAnimation;
    
    
    NSSize layoutSize = NSMakeSize(newSize.width, newSize.height);
    
    dispatch_block_t future = ^ {
        [self.scrollView setFrameSize:NSMakeSize(self.scrollView.bounds.size.width, newSize.height-2)];
        [self.scrollView setFrameOrigin:NSMakePoint(self.scrollView.frame.origin.x, 1)];
        
        if(size.height != self.lastHeight) {
            
            [self.growingDelegate TMGrowingTextViewHeightChanged:self height:newSize.height cleared:isCleared];
            self.lastHeight = size.height;
        }
        
    };
    
    if(isCleared) {
      //  CAAnimation *anim = [TMAnimations resizeLayer:self.containerView.layer to:layoutSize];
        
       [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
           
           [context setDuration:0.2];
           [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
           [[self.containerView animator] setFrameSize:layoutSize];
           
           future();
       
       } completionHandler:^{
           [self setString:@""];
           [self textDidChange:nil];
           [self setSelectedRange:NSMakeRange(0, 0)];
       }];
        
    } else {
        [self.containerView setFrameSize:layoutSize];
        future();
    }
    
    
    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
    [self.growingDelegate TMGrowingTextViewTextDidChange:self];
    
    
    
    [self setNeedsDisplay:YES];
    
    [self setSelectedRange:NSMakeRange(self.selectedRange.location, self.selectedRange.length)];
    
    [self setNeedsDisplay:YES];
    
   
}

- (void)initialize {

    
    self.disableAnimation = YES;
    self.frame = NSMakeRect(0, 0, self.frame.size.width - 90, 200);
    [self setAllowsUndo:YES];
    self.mode = TMGrowingModeMultiLine;
    self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.autoresizesSubviews = YES;
    self.delegate = self;
    self.font = [NSFont fontWithName:@"HelveticaNeue" size:15];
    self.insertionPointColor = NSColorFromRGB(0x0f92dd);
    
    
    
  
//    [self setBackgroundColor:[NSColor redColor]];
    [self setDrawsBackground:YES];
    
    weakify();
    self.containerView = [[TMView alloc] initWithFrame:self.bounds];
    [self.containerView setDrawBlock:^{
        NSRect rect = NSMakeRect(1, 1, strongSelf.containerView.bounds.size.width - 2, strongSelf.containerView.bounds.size.height - 2);
        NSBezierPath *circlePath = [NSBezierPath bezierPath];
        [circlePath appendBezierPathWithRoundedRect:rect xRadius:3 yRadius:3];
        [NSColorFromRGB(0xdedede) setStroke];
        [circlePath setLineWidth:IS_RETINA ? 2 : 1];
        [circlePath stroke];
        [[NSColor whiteColor] setFill];
        [circlePath fill];
        
        [strongSelf.scrollView setFrame:NSMakeRect(2, 2, strongSelf.containerView.bounds.size.width - 4, strongSelf.containerView.bounds.size.height - 4)];
        
    }];
    
   // [self.containerView setBackgroundColor:NSColorFromRGB(0x000000)];
    
    self.containerView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    self.scrollView = [[TMScrollView alloc] initWithFrame:self.containerView.bounds];
    self.scrollView.autoresizesSubviews = YES;
    self.scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.scrollView.documentView = self;
    [self.scrollView setDrawsBackground:YES];
//    [self.scrollView setBackgroundColor:[NSColor redColor]];
    [self.scrollView setFrame:NSMakeRect(9, 0, self.bounds.size.width - 9, self.bounds.size.height - 2)];
    [self.containerView addSubview:self.scrollView];
    
}

- (void)setContinuousSpellCheckingEnabled:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool: flag forKey:[NSString stringWithFormat:@"ContinuousSpellCheckingEnabled%@",NSStringFromClass([self class])]];
    [super setContinuousSpellCheckingEnabled: flag];
}

-(BOOL)isContinuousSpellCheckingEnabled {
    return  [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"ContinuousSpellCheckingEnabled%@",NSStringFromClass([self class])]];
}


-(void)setGrammarCheckingEnabled:(BOOL)flag {
    
    [[NSUserDefaults standardUserDefaults] setBool: flag forKey:[NSString stringWithFormat:@"GrammarCheckingEnabled%@",NSStringFromClass([self class])]];
    [super setContinuousSpellCheckingEnabled: flag];
}

-(BOOL)isGrammarCheckingEnabled {
    return  [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"GrammarCheckingEnabled%@",NSStringFromClass([self class])]];
}


-(void)setAutomaticSpellingCorrectionEnabled:(BOOL)flag {
    [[NSUserDefaults standardUserDefaults] setBool: flag forKey:[NSString stringWithFormat:@"AutomaticSpellingCorrectionEnabled%@",NSStringFromClass([self class])]];
    [super setAutomaticSpellingCorrectionEnabled: flag];
}

-(BOOL)isAutomaticSpellingCorrectionEnabled {
    return  [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"AutomaticSpellingCorrectionEnabled%@",NSStringFromClass([self class])]];
}



-(void)setAutomaticQuoteSubstitutionEnabled:(BOOL)flag {
    [[NSUserDefaults standardUserDefaults] setBool: flag forKey:[NSString stringWithFormat:@"AutomaticQuoteSubstitutionEnabled%@",NSStringFromClass([self class])]];
    [super setAutomaticSpellingCorrectionEnabled: flag];
}

-(BOOL)isAutomaticQuoteSubstitutionEnabled {
    return  [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"AutomaticQuoteSubstitutionEnabled%@",NSStringFromClass([self class])]];
}


-(void)setAutomaticLinkDetectionEnabled:(BOOL)flag {
    [[NSUserDefaults standardUserDefaults] setBool: flag forKey:[NSString stringWithFormat:@"AutomaticLinkDetectionEnabled%@",NSStringFromClass([self class])]];
    [super setAutomaticSpellingCorrectionEnabled: flag];
}

-(BOOL)isAutomaticLinkDetectionEnabled {
    return  [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"AutomaticLinkDetectionEnabled%@",NSStringFromClass([self class])]];
}


-(void)setAutomaticDataDetectionEnabled:(BOOL)flag {
    [[NSUserDefaults standardUserDefaults] setBool: flag forKey:[NSString stringWithFormat:@"AutomaticDataDetectionEnabled%@",NSStringFromClass([self class])]];
    [super setAutomaticSpellingCorrectionEnabled: flag];
}

-(BOOL)isAutomaticDataDetectionEnabled {
    return  [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"AutomaticDataDetectionEnabled%@",NSStringFromClass([self class])]];
}



-(void)setAutomaticDashSubstitutionEnabled:(BOOL)flag {
    [[NSUserDefaults standardUserDefaults] setBool: flag forKey:[NSString stringWithFormat:@"AutomaticDashSubstitutionEnabled%@",NSStringFromClass([self class])]];
    [super setAutomaticSpellingCorrectionEnabled: flag];
}

-(BOOL)isAutomaticDashSubstitutionEnabled {
    return  [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"AutomaticDashSubstitutionEnabled%@",NSStringFromClass([self class])]];
}

- (void)setFrameOrigin:(NSPoint)newOriginN {
}

- (void)setPlaceholderString:(NSString *)placeHodlder {
    self.placeholderTextAttributedString = [[NSAttributedString alloc] initWithString:placeHodlder attributes:@{NSForegroundColorAttributeName: NSColorFromRGB(0xc8c8c8), NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue" size:[SettingsArchiver checkMaskedSetting:BigFontSetting] ? 15 : 13]}];
}

-(NSPoint)textContainerOrigin {
    
    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
    NSRect newRect = [self.layoutManager usedRectForTextContainer:self.textContainer];
    
    int yOffset = [self.string getEmojiFromString].count > 0 ? 0 : 1;
    
    return NSMakePoint(0, roundf( (NSHeight(self.frame) - NSHeight(newRect)  )/ 2 -yOffset  ));
    
    
}

-(NSUInteger)numberOfLines {
    NSString *s = [self string];
    
    NSUInteger numberOfLines, index, stringLength = [s length];
    
    for (index = 0, numberOfLines = 0; index < stringLength;
         numberOfLines++) {
        index = NSMaxRange([s lineRangeForRange:NSMakeRange(index, 0)]);
    }
    return numberOfLines;
}



- (void) drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    
    if ([[self string] isEqualToString:@""] ) {
        if(self.placeholderTextAttributedString) {
            
           [self.placeholderTextAttributedString drawAtPoint:NSMakePoint(6, 4)];
        }
    }
}

-(void)setString:(NSString *)string {
    [super setString:string];
}




- (BOOL)isCommandEnterEvent:(NSEvent *)e {
    NSUInteger flags = (e.modifierFlags & NSDeviceIndependentModifierFlagsMask);
    BOOL isCommand = (flags & NSCommandKeyMask) == NSCommandKeyMask;
    BOOL isEnter = (e.keyCode == 0x24 || e.keyCode ==  0x4C); // VK_RETURN
    return (isCommand && isEnter);
}

- (BOOL)isControlEnterEvent:(NSEvent *)e {
    NSUInteger flags = (e.modifierFlags & NSDeviceIndependentModifierFlagsMask);
    BOOL isControl = (flags & NSControlKeyMask) == NSControlKeyMask;
    BOOL isEnter = (e.keyCode == 0x24 || e.keyCode ==  0x4C); // VK_RETURN
    return (isControl && isEnter);
}

- (BOOL)isEnterEvent:(NSEvent *)e {
    NSUInteger flags = (e.modifierFlags & NSDeviceIndependentModifierFlagsMask);
    //    DLog(@"log %lu", (unsigned long)flags);
    //numpad enter (0x4C) fix
    BOOL isEnter = (e.keyCode == 0x24 || e.keyCode ==  0x4C); // VK_RETURN
    // Fix some IME if marked text (select characters) do not send Enter. ex. Chinese, Japenese.
    if ([self hasMarkedText]) // AppKit NSTextInputClient
        return NO;
    return (flags == 0 || flags == 65536) && isEnter;
}

- (void) keyDown:(NSEvent *)theEvent {
    
    
    if([self isEnterEvent:theEvent] || [self isCommandEnterEvent:theEvent]) {
        
        BOOL result = [self.growingDelegate TMGrowingTextViewCommandOrControlPressed:self isCommandPressed:[self isCommandEnterEvent:theEvent]];
        
        if(!result) {
            [self insertNewline:self];
        }
        return;
    }
    
    
    [super keyDown:theEvent];
}

-(void)insertNewline:(id)sender {
    if(self.mode == TMGrowingModeMultiLine) {
        [super insertNewline:sender];
    }
}


-(BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    return [super validateMenuItem:menuItem];
}



- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    return NO;
}

- (NSString *)stringValue {
    return [NSString stringWithFormat:@"%@", self.string];
}
@end
