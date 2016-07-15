//
//  TGModernGrowingTextView.m
//  Telegram
//
//  Created by keepcoder on 12/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernGrowingTextView.h"
#import "TGTextLabel.h"
#import "TGAnimationBlockDelegate.h"
@interface TGGrowingTextView : NSTextView
@property (nonatomic,weak) id <TGModernGrowingDelegate> weakd;
@end

@implementation TGGrowingTextView

-(NSPoint)textContainerOrigin {
    
    if([self numberOfLines] <= 1) {
        NSRect newRect = [self.layoutManager usedRectForTextContainer:self.textContainer];
        int yOffset = 1;
        
        return NSMakePoint(0, roundf( (NSHeight(self.frame) - NSHeight(newRect)  )/ 2 -yOffset  ));
    }
    
    return [super textContainerOrigin];
    
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

- (void) keyDown:(NSEvent *)theEvent {
    
    
    if(isEnterEvent(theEvent)) {
        
        BOOL result = isEnterAccess(theEvent) && self.string.trim.length > 0 && [_weakd textViewEnterPressed:self];
        
        if(!result) {
            [self insertNewline:self];
        }
        return;
    }   else if(theEvent.keyCode == 53 && [_weakd respondsToSelector:@selector(textViewNeedClose:)]) {
        [_weakd textViewNeedClose:self];
        return;
    }
    
    
    [super keyDown:theEvent];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
}

@end


@interface TGModernGrowingTextView () <NSTextViewDelegate> {
    int _last_height;
}
@property (nonatomic,strong) TGGrowingTextView *textView;
@property (nonatomic,strong) NSScrollView *scrollView;
@property (nonatomic,strong) TMTextField *placeholder;
@end


@implementation TGModernGrowingTextView


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _min_height = 33;
        _max_height = 250;
        _animates = YES;
        

        _textView = [[TGGrowingTextView alloc] initWithFrame:self.bounds];
        
        _textView.backgroundColor = [NSColor clearColor];
        
        [_textView setAllowsUndo:YES];
        
        self.autoresizesSubviews = YES;
        _textView.delegate = self;
        
        [_textView setDrawsBackground:YES];
        
        
        self.scrollView = [[NSScrollView alloc] initWithFrame:self.bounds];
        [[self.scrollView verticalScroller] setControlSize:NSSmallControlSize];
        self.scrollView.documentView = _textView;
        [self.scrollView setDrawsBackground:NO];
        [self.scrollView setFrame:NSMakeRect(0, 0, NSWidth(self.frame), NSHeight(self.frame))];
        [self addSubview:self.scrollView];
        
        
        self.wantsLayer = _textView.wantsLayer = _scrollView.wantsLayer = YES;

        
        _placeholder = [TMTextField defaultTextField];
        _placeholder.alphaValue = 0.0f;
        [self addSubview:_placeholder];
        
        
        
        
        
//        _animates = NO;
//        [self textDidChange:[NSNotification notificationWithName:NSTextDidChangeNotification object:_textView]];
//        _animates = YES;
        
//        self.backgroundColor = [NSColor blueColor];
//        _textView.backgroundColor = [NSColor redColor];
        
        
    }
    
    return self;
}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    if(self.window.firstResponder != _textView) {
        [self.window makeFirstResponder:_textView];
    }
}

-(BOOL)becomeFirstResponder {
    return [_textView becomeFirstResponder];
}

-(int)height {
    return _last_height;
}

-(void)setDelegate:(id<TGModernGrowingDelegate>)delegate {
    _delegate = _textView.weakd = delegate;
}


-(void)update {
    [self textDidChange:[NSNotification notificationWithName:NSTextDidChangeNotification object:_textView]];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
//    NSRect rect = NSMakeRect(1, 1, NSWidth(self.frame)- 2, NSHeight(self.frame) - 2);
//    NSBezierPath *circlePath = [NSBezierPath bezierPath];
//    [circlePath appendBezierPathWithRoundedRect:rect xRadius:3 yRadius:3];
//    [DIALOG_BORDER_COLOR setStroke];
//    [circlePath setLineWidth:2];
//    [circlePath stroke];
//    [[NSColor whiteColor] setFill];
//    [circlePath fill];

}

- (void)textDidChange:(NSNotification *)notification {
    
    
    
    _textView.font = TGSystemFont(13);
    
    self.scrollView.verticalScrollElasticity = NSHeight(_scrollView.contentView.documentRect) <= NSHeight(_scrollView.frame) ? NSScrollElasticityNone : NSScrollElasticityAllowed;
    
    [_textView.layoutManager ensureLayoutForTextContainer:_textView.textContainer];
    NSRect newRect = [_textView.layoutManager usedRectForTextContainer:_textView.textContainer];
    
    NSSize size = newRect.size;
    size.width = NSWidth(self.frame);
    

    NSSize newSize = NSMakeSize(size.width, size.height);

    
    newSize.height+= 8;
    
    
    newSize.height = MIN(MAX(newSize.height,_min_height),_max_height);
    
    BOOL animated = self.animates;
    
    
    if(_last_height != newSize.height) {
        
        dispatch_block_t future = ^ {
            _last_height = newSize.height;
            [_delegate textViewHeightChanged:self height:newSize.height animated:animated];
        };
        
        [_textView.layoutManager ensureLayoutForTextContainer:_textView.textContainer];
        
        newSize.width = [_delegate textViewSize].width;
        
        NSSize layoutSize = NSMakeSize(newSize.width, newSize.height);
        
        
        if(animated) {
            
            float presentHeight = NSHeight(self.frame);
            
            CALayer *presentLayer = (CALayer *)[self.layer presentationLayer];
            
            if(presentLayer && [self.layer animationForKey:@"bounds"]) {
                presentHeight = [[presentLayer valueForKeyPath:@"bounds.size.height"] floatValue];
            }
            
            CABasicAnimation *sAnim = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
            sAnim.duration = 0.2;
            sAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            sAnim.removedOnCompletion = YES;
            
            sAnim.fromValue = @(presentHeight);
            sAnim.toValue = @(layoutSize.height);
            
            [self.layer removeAnimationForKey:@"bounds"];
            [self.layer addAnimation:sAnim forKey:@"bounds"];
            
            [self.layer setFrame:NSMakeRect(0, 0, NSWidth(self.frame), layoutSize.height)];
            
            
            
            presentHeight = NSHeight(_scrollView.frame);
            presentLayer = (CALayer *)[_scrollView.layer presentationLayer];
            
            if(presentLayer && [_scrollView.layer animationForKey:@"bounds"]) {
                presentHeight = [[presentLayer valueForKeyPath:@"bounds.size.height"] floatValue];
            }
            
            
            sAnim.fromValue = @(presentHeight);
            sAnim.toValue = @(layoutSize.height);
            
            [_scrollView.layer removeAnimationForKey:@"bounds"];
            [_scrollView.layer addAnimation:sAnim forKey:@"bounds"];
            
            
            
            [self setFrameSize:layoutSize];
            
        
            future();

            
        } else {
            [self setFrameSize:layoutSize];
            future();
        }
        
    }
    
    
 //   if(self.needShowPlaceholder) {
    
    if(_placeholderAttributedString) {
        
        if(animated && ((self.string.length == 0 && _placeholder.layer.opacity < 1.0f) || (self.string.length > 0 && _placeholder.layer.opacity > 0.0f))) {
            float presentX = self.needShowPlaceholder ? NSMinX(_placeholder.frame) + NSWidth(_placeholder.frame) : NSMinX(_scrollView.frame) + 6;
            float presentOpacity = self.needShowPlaceholder ? 0.0f : 1.0f;
            
            CALayer *presentLayer = (CALayer *)[_placeholder.layer presentationLayer];
            
            if(presentLayer && [_placeholder.layer animationForKey:@"position"]) {
                presentX = [[presentLayer valueForKeyPath:@"frame.origin.x"] floatValue];
            }
            if(presentLayer && [_placeholder.layer animationForKey:@"opacity"]) {
                presentOpacity = [[presentLayer valueForKeyPath:@"opacity"] floatValue];
            }
            
            
            
            CAAnimation *oAnim = [TMAnimations fadeWithDuration:0.2 fromValue:presentOpacity toValue:self.needShowPlaceholder ? 1.0f : 0.0f];
            
            [_placeholder.layer removeAnimationForKey:@"opacity"];
            [_placeholder.layer addAnimation:oAnim forKey:@"opacity"];
            
            CAAnimation *pAnim = [TMAnimations postionWithDuration:0.2 fromValue:NSMakePoint(presentX, NSMinY(_placeholder.frame)) toValue:self.needShowPlaceholder ? NSMakePoint(NSMinX(_scrollView.frame) + 6, roundf((newSize.height - NSHeight(_placeholder.frame))/2.0)) : NSMakePoint(NSMinX(_placeholder.frame) + NSWidth(_placeholder.frame), NSMinY(_placeholder.frame))];
            
            
            [_placeholder.layer removeAnimationForKey:@"position"];
            [_placeholder.layer addAnimation:pAnim forKey:@"position"];
            
         }
        
        [_placeholder setFrameOrigin:self.needShowPlaceholder ? NSMakePoint(NSMinX(_scrollView.frame) + 6, roundf((newSize.height - NSHeight(_placeholder.frame))/2.0)) : NSMakePoint(NSMinX(_placeholder.frame) + NSWidth(_placeholder.frame), roundf((newSize.height - NSHeight(_placeholder.frame))/2.0))];
        
        _placeholder.layer.opacity = self.needShowPlaceholder ? 1.0f : 0.0f;

    }
    
    
    [self setNeedsDisplay:YES];
    
    [_textView setSelectedRange:NSMakeRange(_textView.selectedRange.location, _textView.selectedRange.length)];
    
    [self setNeedsDisplay:YES];
    
    
    [self.delegate textViewTextDidChange:self];
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [_scrollView setFrameSize:NSMakeSize(newSize.width, newSize.height)];
    [_textView setFrameSize:NSMakeSize(NSWidth(_scrollView.frame), NSHeight(_textView.frame))];
}

-(BOOL)needShowPlaceholder {
    return _textView.string.length == 0 && _placeholderAttributedString;
}


-(void)setPlaceholderAttributedString:(NSAttributedString *)placeholderAttributedString {
    _placeholderAttributedString = placeholderAttributedString;
    [_placeholder setAttributedString:_placeholderAttributedString];
    [_placeholder sizeToFit];
    
    [_placeholder setFrameSize:NSMakeSize(MIN(NSWidth(_textView.frame) - 20,NSWidth(_placeholder.frame)), NSHeight(_placeholder.frame))];
    
    BOOL animates = _animates;
    _animates = NO;
    [self update];
    _animates = animates;

}

-(NSParagraphStyle *)defaultParagraphStyle {
    static NSMutableParagraphStyle *para;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        para = [[NSMutableParagraphStyle alloc] init]; 
    });
    
    [para setLineSpacing:0];
    [para setMaximumLineHeight:[SettingsArchiver checkMaskedSetting:BigFontSetting] ? 20 : 18];
    
    
    return para;
}





-(NSString *)string {
    return [_textView.string copy];
}
-(void)setString:(NSString *)string {
    [_textView setString:string];
    [self update];
}
-(NSRange)selectedRange {
    return _textView.selectedRange;
}


@end
