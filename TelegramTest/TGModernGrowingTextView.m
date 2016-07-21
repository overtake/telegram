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
#import "NSAttributedStringCategory.h"

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
        
        BOOL result = isEnterAccess(theEvent) && [_weakd textViewEnterPressed:self];
        
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



-(BOOL)resignFirstResponder {
   return [super resignFirstResponder];
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
        _max_height = 200;
        _animates = YES;
        

        _textView = [[[self _textViewClass] alloc] initWithFrame:self.bounds];
        
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
   // if(self.window.firstResponder != _textView) {
        [self.window makeFirstResponder:_textView];
   // }
    

    
    return YES;
}

-(BOOL)resignFirstResponder {
    return [_textView resignFirstResponder];
}

-(int)height {
    return _last_height;
}

-(void)setDelegate:(id<TGModernGrowingDelegate>)delegate {
    _delegate = _textView.weakd = delegate;
}


-(void)update:(BOOL)notify {
    [self textDidChange:[NSNotification notificationWithName:NSTextDidChangeNotification object:notify ? _textView : nil]];
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
    
    if([SettingsArchiver checkMaskedSetting:EmojiReplaces]) {
        NSString *replace = [self.string replaceSmilesToEmoji];

        if(![self.string isEqualToString:replace]) {
            [self setString:replace];
            return;
        }
    }
    
    
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
            
            [CATransaction begin];
            
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
            [_scrollView setFrameSize:layoutSize];
        
            future();
            
            [CATransaction commit];

            
        } else {
            [self setFrameSize:layoutSize];
            future();
        }
        
    }
    
    
 //   if(self._needShowPlaceholder) {
    
    if(_placeholderAttributedString) {
        
        if(animated && ((self.string.length == 0 && _placeholder.layer.opacity < 1.0f) || (self.string.length > 0 && _placeholder.layer.opacity > 0.0f))) {
            float presentX = self._needShowPlaceholder ? self._endXPlaceholder : self._startXPlaceholder;
            float presentOpacity = self._needShowPlaceholder ? 0.0f : 1.0f;
            
            CALayer *presentLayer = (CALayer *)[_placeholder.layer presentationLayer];
            
            if(presentLayer && [_placeholder.layer animationForKey:@"position"]) {
                presentX = [[presentLayer valueForKeyPath:@"frame.origin.x"] floatValue];
            }
            if(presentLayer && [_placeholder.layer animationForKey:@"opacity"]) {
                presentOpacity = [[presentLayer valueForKeyPath:@"opacity"] floatValue];
            }
            [_placeholder setHidden:NO];
            
            CAAnimation *oAnim = [TMAnimations fadeWithDuration:0.2 fromValue:presentOpacity toValue:self._needShowPlaceholder ? 1.0f : 0.0f];
            
            TGAnimationBlockDelegate *delegate = [[TGAnimationBlockDelegate alloc] initWithLayer:_placeholder.layer];
            
            [delegate setCompletion:^(BOOL completed) {
                if(completed)
                    [_placeholder setHidden:!self._needShowPlaceholder];
            }];
            
            oAnim.delegate = delegate;
            
            [_placeholder.layer removeAnimationForKey:@"opacity"];
            [_placeholder.layer addAnimation:oAnim forKey:@"opacity"];
            
            CAAnimation *pAnim = [TMAnimations postionWithDuration:0.2 fromValue:NSMakePoint(presentX, NSMinY(_placeholder.frame)) toValue:self._needShowPlaceholder ? NSMakePoint(self._startXPlaceholder, roundf((newSize.height - NSHeight(_placeholder.frame))/2.0)) : NSMakePoint(self._endXPlaceholder, NSMinY(_placeholder.frame))];
            
            
            [_placeholder.layer removeAnimationForKey:@"position"];
            [_placeholder.layer addAnimation:pAnim forKey:@"position"];
            
            
            
        } else {
            [_placeholder setHidden:!self._needShowPlaceholder];
        }
        
        [_placeholder setFrameOrigin:self._needShowPlaceholder ? NSMakePoint(self._startXPlaceholder, roundf((newSize.height - NSHeight(_placeholder.frame))/2.0)) : NSMakePoint(NSMinX(_placeholder.frame) + 30, roundf((newSize.height - NSHeight(_placeholder.frame))/2.0))];
        
        _placeholder.layer.opacity = self._needShowPlaceholder ? 1.0f : 0.0f;

    }
    
    
    [self setNeedsDisplay:YES];
    
    [_textView setSelectedRange:NSMakeRange(_textView.selectedRange.location, _textView.selectedRange.length)];
    
    [self setNeedsDisplay:YES];
    
    if(notification.object)
        [self.delegate textViewTextDidChange:self];
    
    [self refreshAttributes];
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [_scrollView setFrameSize:NSMakeSize(newSize.width, newSize.height)];
    [_textView setFrameSize:NSMakeSize(NSWidth(_scrollView.frame), NSHeight(_textView.frame))];
}

-(BOOL)_needShowPlaceholder {
    return _textView.string.length == 0 && _placeholderAttributedString;
}

-(void)setPlaceholderAttributedString:(NSAttributedString *)placeholderAttributedString update:(BOOL)update {
    
    if([_placeholderAttributedString isEqualToAttributedString:placeholderAttributedString])
        return;
    
    _placeholderAttributedString = placeholderAttributedString;
    [_placeholder setAttributedString:_placeholderAttributedString];
    
    [_placeholder sizeToFit];
    
    [_placeholder setFrameSize:NSMakeSize(MIN(NSWidth(_textView.frame) - self._startXPlaceholder - 10,NSWidth(_placeholder.frame)), NSHeight(_placeholder.frame))];
    
    BOOL animates = _animates;
    _animates = NO;
    [self update:NO];
    _animates = animates;

}

-(void)setPlaceholderAttributedString:(NSAttributedString *)placeholderAttributedString {
    [self setPlaceholderAttributedString:placeholderAttributedString update:YES];
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


- (void)refreshAttributes {
    
    @try {
        NSAttributedString *string = _textView.attributedString;
        if (string.length == 0) {
            return;
        }
        
        
        //NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
        //[mutableString removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, string.length)];
        [_textView.textStorage addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR range:NSMakeRange(0, string.length)];
        
        
        
        __block NSMutableArray<TGInputTextTagAndRange *> *inputTextTags = [[NSMutableArray alloc] init];
        [string enumerateAttribute:TGMentionUidAttributeName inRange:NSMakeRange(0, string.length) options:0 usingBlock:^(__unused id value, NSRange range, __unused BOOL *stop) {
            if ([value isKindOfClass:[TGInputTextTag class]]) {
                [inputTextTags addObject:[[TGInputTextTagAndRange alloc] initWithTag:value range:range]];
            }
        }];
        
        if (inputTextTags != nil) {
            /*if (mutableString == nil) {
             mutableString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
             }*/
            
            static NSCharacterSet *alphanumericSet = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                alphanumericSet = [NSCharacterSet alphanumericCharacterSet];
            });
            
            NSMutableSet<NSNumber *> *removeTags = [[NSMutableSet alloc] init];
            for (NSInteger i = 0; i < ((NSInteger)inputTextTags.count); i++) {
                TGInputTextTagAndRange *tagAndRange = inputTextTags[i];
                if ([removeTags containsObject:@(tagAndRange.tag.uniqueId)]) {
                    [inputTextTags removeObjectAtIndex:i];
                    //[mutableString removeAttribute:TGMentionUidAttributeName range:tagAndRange.range];
                    [_textView.textStorage removeAttribute:TGMentionUidAttributeName range:tagAndRange.range];
                    
                    i--;
                } else {
                    NSInteger j = tagAndRange.range.location;
                    while (j < (NSInteger)(tagAndRange.range.location + tagAndRange.range.length)) {
                        unichar c = [string.string characterAtIndex:j];
                        if (c != ' ') {
                            break;
                        }
                        j++;
                    }
                    
                    if (j != (NSInteger)tagAndRange.range.location) {
                        NSRange updatedRange = NSMakeRange(j, tagAndRange.range.location + tagAndRange.range.length - j);
                        //[mutableString removeAttribute:TGMentionUidAttributeName range:tagAndRange.range];
                        [_textView.textStorage removeAttribute:TGMentionUidAttributeName range:tagAndRange.range];
                        
                        //[mutableString addAttribute:TGMentionUidAttributeName value:tagAndRange.tag range:updatedRange];
                        [_textView.textStorage addAttribute:TGMentionUidAttributeName value:tagAndRange.tag range:updatedRange];
                        
                        inputTextTags[i] = [[TGInputTextTagAndRange alloc] initWithTag:tagAndRange.tag range:updatedRange];
                        
                        i--;
                    } else {
                        NSInteger j = tagAndRange.range.location;
                        while (j >= 0) {
                            
                            unichar c = [string.string characterAtIndex:j];
                            if (![alphanumericSet characterIsMember:c]) {
                                break;
                            }
                            j--;
                        }
                        j++;
                        
                        if (j < ((NSInteger)tagAndRange.range.location)) {
                            NSRange updatedRange = NSMakeRange(j, tagAndRange.range.location + tagAndRange.range.length - j);
                            //[mutableString removeAttribute:TGMentionUidAttributeName range:tagAndRange.range];
                            [_textView.textStorage removeAttribute:TGMentionUidAttributeName range:tagAndRange.range];
                            
                            //[mutableString addAttribute:TGMentionUidAttributeName value:tagAndRange.tag range:updatedRange];
                            [_textView.textStorage addAttribute:TGMentionUidAttributeName value:tagAndRange.tag range:updatedRange];
                            
                            inputTextTags[i] = [[TGInputTextTagAndRange alloc] initWithTag:tagAndRange.tag range:updatedRange];
                            
                            i--;
                        } else {
                            TGInputTextTagAndRange *nextTagAndRange = nil;
                            if (i != ((NSInteger)inputTextTags.count) - 1) {
                                nextTagAndRange = inputTextTags[i + 1];
                            }
                            
                            if (nextTagAndRange == nil || nextTagAndRange.tag.uniqueId != tagAndRange.tag.uniqueId) {
                                NSInteger candidateStart = tagAndRange.range.location + tagAndRange.range.length;
                                NSInteger candidateEnd = nextTagAndRange == nil ? string.length : nextTagAndRange.range.location;
                                NSInteger j = candidateStart;
                                while (j < candidateEnd) {
                                    unichar c = [string.string characterAtIndex:j];
                                    static NSCharacterSet *alphanumericSet = nil;
                                    static dispatch_once_t onceToken;
                                    dispatch_once(&onceToken, ^{
                                        alphanumericSet = [NSCharacterSet alphanumericCharacterSet];
                                    });
                                    if (![alphanumericSet characterIsMember:c]) {
                                        break;
                                    }
                                    j++;
                                }
                                
                                if (j == candidateStart) {
                                    [removeTags addObject:@(tagAndRange.tag.uniqueId)];
                                    //[mutableString addAttribute:NSForegroundColorAttributeName value:TGAccentColor() range:tagAndRange.range];
                                    [_textView.textStorage addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:tagAndRange.range];
                                } else {
                                    //[mutableString removeAttribute:TGMentionUidAttributeName range:tagAndRange.range];
                                    [_textView.textStorage removeAttribute:TGMentionUidAttributeName range:tagAndRange.range];
                                    
                                    NSRange updatedRange = NSMakeRange(tagAndRange.range.location, j - tagAndRange.range.location);
                                    //[mutableString addAttribute:TGMentionUidAttributeName value:tagAndRange.tag range:updatedRange];
                                    [_textView.textStorage addAttribute:TGMentionUidAttributeName value:tagAndRange.tag range:updatedRange];
                                    inputTextTags[i] = [[TGInputTextTagAndRange alloc] initWithTag:tagAndRange.tag range:updatedRange];
                                    
                                    i--;
                                }
                            } else {
                                
                                
                                NSInteger candidateStart = tagAndRange.range.location + tagAndRange.range.length;
                                NSInteger candidateEnd = nextTagAndRange.range.location;
                                NSInteger j = candidateStart;
                                while (j < candidateEnd) {
                                    unichar c = [string.string characterAtIndex:j];
                                    if (![alphanumericSet characterIsMember:c] && c != ' ') {
                                        break;
                                    }
                                    j++;
                                }
                                
                                if (j == candidateEnd) {
                                    //[mutableString removeAttribute:TGMentionUidAttributeName range:tagAndRange.range];
                                    [_textView.textStorage removeAttribute:TGMentionUidAttributeName range:tagAndRange.range];
                                    
                                    //[mutableString removeAttribute:TGMentionUidAttributeName range:nextTagAndRange.range];
                                    [_textView.textStorage removeAttribute:TGMentionUidAttributeName range:nextTagAndRange.range];
                                    
                                    NSRange updatedRange = NSMakeRange(tagAndRange.range.location, nextTagAndRange.range.location + nextTagAndRange.range.length - tagAndRange.range.location);
                                    
                                    //[mutableString addAttribute:TGMentionUidAttributeName value:tagAndRange.tag range:updatedRange];
                                    [_textView.textStorage addAttribute:TGMentionUidAttributeName value:tagAndRange.tag range:updatedRange];
                                    
                                    inputTextTags[i] = [[TGInputTextTagAndRange alloc] initWithTag:tagAndRange.tag range:updatedRange];
                                    [inputTextTags removeObjectAtIndex:i + 1];
                                    
                                    i--;
                                } else if (j != candidateStart) {
                                    //[mutableString removeAttribute:TGMentionUidAttributeName range:tagAndRange.range];
                                    [_textView.textStorage removeAttribute:TGMentionUidAttributeName range:tagAndRange.range];
                                    
                                    NSRange updatedRange = NSMakeRange(tagAndRange.range.location, j - tagAndRange.range.location);
                                    //[mutableString addAttribute:TGMentionUidAttributeName value:tagAndRange.tag range:updatedRange];
                                    [_textView.textStorage addAttribute:TGMentionUidAttributeName value:tagAndRange.tag range:updatedRange];
                                    
                                    inputTextTags[i] = [[TGInputTextTagAndRange alloc] initWithTag:tagAndRange.tag range:updatedRange];
                                    
                                    i--;
                                } else {
                                    [removeTags addObject:@(tagAndRange.tag.uniqueId)];
                                    //[mutableString addAttribute:NSForegroundColorAttributeName value:TGAccentColor() range:tagAndRange.range];
                                    [_textView.textStorage addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:tagAndRange.range];
                                }
                            }
                        }
                    }
                }
            }
        }

    } @catch (NSException *exception) {
        int bp = 0;
    }
    
    

}



-(NSString *)string {
    return [_textView.string copy];
}

-(NSAttributedString *)attributedString {
    return _textView.attributedString;
}

-(void)setAttributedString:(NSAttributedString *)attributedString {
    [_textView.textStorage setAttributedString:attributedString];
    [self update:YES];
}

-(void)setString:(NSString *)string {
    [_textView setString:string];
    [self update:YES];
}
-(NSRange)selectedRange {
    return _textView.selectedRange;
}

-(void)insertText:(id)aString replacementRange:(NSRange)replacementRange {
    [_textView insertText:aString replacementRange:replacementRange];
}

-(void)addInputTextTag:(TGInputTextTag *)tag range:(NSRange)range {
    [_textView.textStorage addAttribute:TGMentionUidAttributeName value:tag range:range];
}


- (void)replaceMention:(NSString *)mention username:(bool)username userId:(int32_t)userId
{
    NSString *replacementText = [mention stringByAppendingString:@" "];
    
    NSMutableAttributedString *text = _textView.attributedString == nil ? [[NSMutableAttributedString alloc] init] : [[NSMutableAttributedString alloc] initWithAttributedString:_textView.attributedString];
    
    NSRange selRange = _textView.selectedRange;
    NSUInteger selStartPos = selRange.location;
    
    NSInteger idx = selStartPos;
    idx--;
    
    NSRange candidateMentionRange = NSMakeRange(NSNotFound, 0);
    
    if (idx >= 0 && idx < (int)text.length)
    {
        for (NSInteger i = idx; i >= 0; i--)
        {
            unichar c = [text.string characterAtIndex:i];
            if (c == '@')
            {
                if (i == idx)
                    candidateMentionRange = NSMakeRange(i + 1, 0);
                else
                    candidateMentionRange = NSMakeRange(i + 1, idx - i);
                break;
            }
            
            if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'))
                break;
        }
    }
    
    if (candidateMentionRange.location != NSNotFound)
    {
        if (!username) {
            candidateMentionRange.location -= 1;
            candidateMentionRange.length += 1;
            
            [text replaceCharactersInRange:candidateMentionRange withString:replacementText];
            
            static int64_t nextId = 0;
            nextId++;
            [text addAttributes:@{TGMentionUidAttributeName: [[TGInputTextTag alloc] initWithUniqueId:nextId left:true attachment:@(userId)]} range:NSMakeRange(candidateMentionRange.location, replacementText.length - 1)];
        } else {
            [text replaceCharactersInRange:candidateMentionRange withString:replacementText];
        }
        
        [_textView.textStorage setAttributedString:text];
    }
    
    [self update:YES];
}

-(void)paste:(id)sender {
    [_textView paste:sender];
}

-(void)setSelectedRange:(NSRange)range {
    if(range.location != NSNotFound)
        [_textView setSelectedRange:range];
}

-(Class)_textViewClass {
    return [TGGrowingTextView class];
}

-(int)_startXPlaceholder {
    return NSMinX(_scrollView.frame) + 6;
}

-(int)_endXPlaceholder {
    return self._startXPlaceholder + 30;
}

@end
