
//
//  MesssageInputGrowingTextView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/15/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageInputGrowingTextView.h"
#import "ImageUtils.h"
#import "MessageSender.h"
#import "ImageUtils.h"
#import "TGMentionPopup.h"
#import "TGHashtagPopup.h"
#import "NSString+FindURLs.h"
#import "NSString+Extended.h"
#import "TGBotCommandsPopup.h"

@interface TGCustomMentionRange : NSObject
@property (nonatomic,strong) NSString *original;
@property (nonatomic,assign) NSRange range;

@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) int user_id;


@end

@implementation TGCustomMentionRange


-(id)initWithOriginalText:(NSString *)text range:(NSRange)range {
    if(self = [super init]) {
        _original = text;
        _range = range;
        
        _name = [text substringWithRange:NSMakeRange(2, [text rangeOfString:@"|"].location - 2)];
        _user_id = [[text substringWithRange:NSMakeRange([text rangeOfString:@"|"].location + 1, text.length - 1 - [text rangeOfString:@"|"].location)] intValue];

    }
    
    return self;
}




@end


typedef enum {
    PasteBoardItemTypeVideo,
    PasteBoardItemTypeDocument,
    PasteBoardItemTypeImage,
    PasteBoardItemTypeGif,
    PasteBoardTypeLink
} PasteBoardItemType;


@interface MessageInputGrowingTextView ()
@property (nonatomic,strong) NSMutableDictionary *customMentions;
@end

@implementation MessageInputGrowingTextView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setPlaceholderString:NSLocalizedString(@"Messages.SendPlaceholder", nil)];
        _customMentions = [NSMutableDictionary dictionary];
    }
    return self;
}





-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    NSPasteboard *pst = [sender draggingPasteboard];
    
    if([pst.types containsObject:NSStringPboardType]) {
        NSString *text = [pst stringForType:NSStringPboardType];
        
        [self insertText:text];
        
        return YES;
        
    } else {
        
        return [MessageSender sendDraggedFiles:sender dialog:self.controller.conversation asDocument:NO messagesViewController:self.controller];
    
    }
    
    return NO;
}

-(void)insertText:(id)insertString {
    //lol. MessagesBottomView
    if(!self.superview.superview.superview.superview.superview.isHidden) {
        
        NSRange range = self.selectedRange;
        
        if(_customMentions.count > 0) {
            
//            NSString *string = self.stringValue;
//            NSString *original = self.string;
//            
//            if(range.location != self.string.length) {
//                
//            }
//            
//            [_customMentions removeAllObjects];
//            self.string = string;

        }
        
       
        
        [super insertText:insertString];
        
    }
   
}


-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
     NSPasteboard *pst = [sender draggingPasteboard];
    
    if([pst.types containsObject:NSStringPboardType])
        return NSDragOperationCopy;
    
    if([pst.types containsObject:NSTIFFPboardType] || [pst.types containsObject:NSFilenamesPboardType])
        return NSDragOperationLink;
    
    return NSDragOperationNone;
}

- (IBAction)paste:sender {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *pasteboardItems = pasteboard.pasteboardItems;
    
    __block NSMutableArray *files = [[NSMutableArray alloc] init];
    for(NSPasteboardItem *item in pasteboardItems) {
        NSString *url = [item stringForType:@"public.file-url"];
        if(url) {
            [files addObject:[[NSURL URLWithString:url] path]];
        }
    }
    
    if(files.count > 1) {
        NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"Conversation.Confirm.SendFromClipboard", nil), (int)files.count] informativeText:NSLocalizedString(@"Conversation.Confirm.SendThisPicturesDescription", nil) block:^(id result) {
            if([result intValue] == 1000) {
                
                BOOL isMultiple = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.pathExtension.lowercaseString IN (%@)",imageTypes()]].count > 1;
                [MessageSender sendFilesByPath:files dialog:self.controller.conversation isMultiple:isMultiple asDocument:NO messagesViewController:self.controller];
            }
        }];
        [alert addButtonWithTitle:NSLocalizedString(@"Message.Send", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"Profile.Cancel", nil)];
        [alert show];
        
        return;
    }
    
    
    PasteBoardItemType type = PasteBoardItemTypeDocument;
    
    __block NSImage *image = nil;
    __block NSImage *iconImage = nil;
    __block NSString *path = nil;
    
    NSString *url = [[[pasteboard pasteboardItems] objectAtIndex:0] stringForType:@"public.file-url"];
    if (url != nil) {
        path = [[NSURL URLWithString:url] path];
        
        CFStringRef fileExtension = (__bridge CFStringRef) [path pathExtension];
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
        
        if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {

            image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
            if(!image) {
                CFRelease(fileUTI);
                return;
            }
            
            type = PasteBoardItemTypeImage;
            iconImage = cropCenterWithSize(image, NSMakeSize(70, 70));
            
            
            if(UTTypeConformsTo(fileUTI, kUTTypeGIF)) {
                type = PasteBoardItemTypeGif;
            }
            
        } else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) {
            NSDictionary *dictionary = [MessageSender videoParams:path thumbSize:strongsize(NSMakeSize(640, 480), 90)];
            
            iconImage = cropCenterWithSize([dictionary objectForKey:@"image"], NSMakeSize(70, 70));
            type = PasteBoardItemTypeVideo;
        }
        
        CFRelease(fileUTI);
        
    } else {
        //Web browser copy Image;
        NSArray *objectsToPaste = [pasteboard readObjectsForClasses:[NSArray arrayWithObject:[NSImage class]] options:[NSDictionary dictionary]];
        
        
        if(objectsToPaste.count > 0 && [[[[pasteboard pasteboardItems] objectAtIndex:0] types] indexOfObject:@"com.apple.traditional-mac-plain-text"] == NSNotFound) {
            
            image = [objectsToPaste objectAtIndex:0];
            
            image = prettysize(image);
            
            if(!image || image.size.width == 0 || image.size.height == 0) {
                
                
                
                [super paste:sender];
                return;
            }
        } else {
            [super paste:sender];
            
            [self checkWebpages];
            
            return;
        }
        
        
        
        
        type = PasteBoardItemTypeImage;
        iconImage = cropCenterWithSize(image, NSMakeSize(70, 70));
    }


    
    
    NSAlert *alert = nil;
    
    switch (type) {
        case PasteBoardItemTypeImage:
        {
            if(self.controller.conversation.type == DialogTypeSecretChat) {
                alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Conversation.Confirm.SendThisPicture", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.SendThisPictureDescription", nil) block:^(id result) {
                    if([result intValue] == 1000) {
                        
                        [self.controller sendImage:image.name forConversation:self.controller.conversation file_data:[image TIFFRepresentation]];
                        
                    }
                }];
            } else {
                [self.controller sendImage:image.name forConversation:self.controller.conversation file_data:[image TIFFRepresentation]];
            }
            
            
            break;
        }
            
        case PasteBoardItemTypeDocument:
        {
            alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Conversation.Confirm.SendThisFile", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.SendThisFileDescription", nil) block:^(id result) {
                if([result intValue] == 1000) {
                    
                    [self.controller sendDocument:path forConversation:self.controller.conversation];
                    
                }
            }];
            break;
        }
            
        case PasteBoardItemTypeVideo:
        {
            alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Conversation.Confirm.SendThisVideo", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.SendThisVideoDescription", nil) block:^(id result) {
                if([result intValue] == 1000) {
                    
                    [self.controller sendVideo:path forConversation:self.controller.conversation];
                    
                }
            }];
            break;

        }
        case PasteBoardItemTypeGif:
        {
            alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Conversation.Confirm.SendThisGif", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.SendThisGifDescription", nil) block:^(id result) {
                if([result intValue] == 1000) {
                    
                    [self.controller sendDocument:path forConversation:self.controller.conversation];
                    
                }
            }];
            break;
        }
            
        default:
            break;
    }
    
    if(type == PasteBoardItemTypeImage) {
        
    }
    
    if(iconImage)
        [alert setIcon:iconImage];
    
    [alert addButtonWithTitle:NSLocalizedString(@"Message.Send", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"Profile.Cancel", nil)];
    [alert show];
}


-(void)setString:(NSString *)string {
    [_customMentions removeAllObjects];
    
    [super setString:string];
    
    [self checkAndReplaceCustomMentions];
}



-(void)checkWebpages {
    
    NSString *link = [self.string webpageLink];
    [_controller.messagesViewController clearNoWebpage];
    [_controller.messagesViewController checkWebpage:link];
    
}



-(void)didChangeSettingsMask:(SettingsMask)mask {
    [self updateFont];
}


-(void)updateFont {
    self.font = TGSystemFont([SettingsArchiver checkMaskedSetting:BigFontSetting] ? 15 : 13);
    [self textDidChange:nil];
    [self setPlaceholderString:NSLocalizedString(@"Messages.SendPlaceholder", nil)];
}

-(void)setInline_placeholder:(NSAttributedString *)inline_placeholder {
    
    if(![_inline_placeholder isEqualToAttributedString:inline_placeholder]) {
        _inline_placeholder = inline_placeholder;
        
        if(self.inline_placeholder != nil) {
//            NSMutableAttributedString *str = [self.attributedString mutableCopy];
//            
//            [str appendAttributedString:self.inline_placeholder];
//            
//            [self setString:@""];
//            [super insertText:str];
        }
        
        [self setNeedsDisplay:YES];
    }
    
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if(self.inline_placeholder) {
        
        NSSize size = [self.attributedString sizeForTextFieldForWidth:NSWidth(self.frame)];
        
        [self.inline_placeholder drawAtPoint:NSMakePoint(size.width, NSAppKitVersionNumber > NSAppKitVersionNumber10_10_Max ? 6 : 4)];
    }
}



-(void)textDidChange:(NSNotification *)notification {
    [self checkAndReplaceCustomMentions];
    [super textDidChange:notification];
}

-(NSString *)parseMentions:(NSMutableString *)copy mentions:(NSMutableArray *)customMentions {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((?<!\\w)@\\[([^\\[\\]]+(\\|))+([0-9])+\\])" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *mentions = [regex matchesInString:copy options:0 range:NSMakeRange(0, [copy length])];
    
    if(mentions.count > 0) {
        
        
        
        [mentions enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            
            TGCustomMentionRange *custom = [[TGCustomMentionRange alloc] initWithOriginalText:[copy substringWithRange:obj.range] range:obj.range];
            
            [customMentions addObject:custom];
            
            NSString *mention = [NSString stringWithFormat:@"@(%@)",custom.name];
            
            [copy replaceCharactersInRange:NSMakeRange(obj.range.location, obj.range.length) withString:mention];
            
            
            *stop = YES;
            
        }];
        
    }
    
    if(mentions.count > 0)
        return [self parseMentions:copy mentions:customMentions];
    
    return copy;

}

-(void)checkAndReplaceCustomMentions {
    
    NSString *value = self.string;
    NSMutableString *copy = [value mutableCopy];
    
    if(value.length > 0) {
        
      //  [_customMentions removeAllObjects];
        
        NSMutableArray *mentions = [NSMutableArray array];
        
        NSString *m = [self parseMentions:copy mentions:mentions];
        
        [[self textStorage] setAttributes:nil range:NSMakeRange(0, value.length)];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(@\\([^\\(\\)]+\\))" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *fakeMentions = [regex matchesInString:copy options:0 range:NSMakeRange(0, [copy length])];
        
        if(_customMentions.count > 0) {

            if(fakeMentions.count < _customMentions.count + mentions.count) {
                
                NSString *real = self.stringValue;
                
                __block id remove = nil;
                
                [_customMentions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, TGCustomMentionRange *obj, BOOL * _Nonnull stop) {
                    if([real rangeOfString:obj.original].location == NSNotFound) {
                        remove = key;
                    }
                }];
                
                [_customMentions removeObjectForKey:remove];
                
               
            }

        }
        
        
        
        NSMutableDictionary *cMentions = [_customMentions mutableCopy];
                                     
        [mentions enumerateObjectsUsingBlock:^(TGCustomMentionRange *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            cMentions[@(_customMentions.count + idx)] = obj;
            
        }];
        
        [fakeMentions enumerateObjectsUsingBlock:^(NSTextCheckingResult *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[self textStorage] addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:obj.range];

        }];
        
        if(![m isEqualToString:value]) {
             [self setString:m];
        }
        
        
        _customMentions = cMentions;
    }
}

-(NSString *)realMentions:(NSMutableString *)string mentions:(NSMutableDictionary *)mentions idx:(int)idx {
    NSString *local = string;
    
    if(mentions.count > 0) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(@\\([^\\(\\)]+\\))" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *fakeMentions = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
        
        if(fakeMentions.count > 0) {
            
            TGCustomMentionRange *obj = mentions[@(idx)];
            
            NSTextCheckingResult *fake = fakeMentions[0];
            
            NSString *nname = [local substringWithRange:NSMakeRange(fake.range.location+2, fake.range.length - 3)];
            
            [string replaceCharactersInRange:fake.range withString:[NSString stringWithFormat:@"@[%@|%d]",nname,obj.user_id]];
            
        }
        
        
        if(mentions.count > 0)
            [mentions removeObjectForKey:@(idx)];
        
        if(fakeMentions.count > 0 && mentions.count > 0)
            return [self realMentions:string mentions:mentions idx:idx+1];
    }
    
    
    return string;
}

-(NSString *)stringValue {
    
    NSString *string = [self realMentions:[super.stringValue mutableCopy] mentions:[_customMentions mutableCopy] idx:0];
    
    return string;
}


-(void)setSelectedRange:(NSRange)selectedRange {
    [super setSelectedRange:selectedRange];
   
}


-(NSPoint)textContainerOrigin {
    
    if([self numberOfLines] < 10) {
        NSRect newRect = [self.layoutManager usedRectForTextContainer:self.textContainer];
        
        int yOffset = [self.string getEmojiFromString:NO].count > 0 ? 0 : 1;
        
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

- (void)initialize {
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"enableSpelling"]) {
        [self setAutomaticSpellingCorrectionEnabled:YES];
        [self setGrammarCheckingEnabled:YES];
       // [self setContinuousSpellCheckingEnabled:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"enableSpelling"];
    }
    
    self.maxHeight = 250;
    self.minHeight = 33;
    
    [self setRichText:YES];
    
    

    [SettingsArchiver addEventListener:self];
    
    self.frame = NSMakeRect(0, 0, self.frame.size.width - 90, 200);
    [self setAllowsUndo:YES];
    self.mode = TMGrowingModeMultiLine;
    self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.autoresizesSubviews = YES;
    self.delegate = self;
    [self updateFont];
    self.insertionPointColor = NSColorFromRGB(0x0f92dd);
    
    
    //    [self setBackgroundColor:[NSColor redColor]];
    [self setDrawsBackground:YES];
    
    //TODO
    __strong MessageInputGrowingTextView *weakSelf = self;
    
    self.containerView = [[TMView alloc] initWithFrame:self.bounds];
    [self.containerView setDrawBlock:^{
        NSRect rect = NSMakeRect(1, 1, NSWidth(weakSelf.containerView.frame) - 2, NSHeight(weakSelf.containerView.frame) - 2);
        NSBezierPath *circlePath = [NSBezierPath bezierPath];
        [circlePath appendBezierPathWithRoundedRect:rect xRadius:3 yRadius:3];
        [NSColorFromRGB(0xdedede) setStroke];
        [circlePath setLineWidth:IS_RETINA ? 2 : 1];
        [circlePath stroke];
        [[NSColor whiteColor] setFill];
        [circlePath fill];
        [weakSelf.scrollView setFrameSize:NSMakeSize(NSWidth(rect) - 40, NSHeight(weakSelf.scrollView.frame))];
    }];
    
    // [self.containerView setBackgroundColor:NSColorFromRGB(0x000000)];
    
    self.containerView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    self.scrollView = [[TMScrollView alloc] initWithFrame:self.containerView.bounds];
    self.scrollView.autoresizesSubviews = YES;
    self.scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.scrollView.documentView = self;
    [self.scrollView setDrawsBackground:YES];
    [self.scrollView setFrame:NSMakeRect(9, 0, self.bounds.size.width - 43, self.bounds.size.height - 2)];
    [self.containerView addSubview:self.scrollView];
    
    
//    self.containerView.backgroundColor = NSColorFromRGB(0x000000);
//    self.backgroundColor = [NSColor redColor];
//    self.scrollView.backgroundColor = [NSColor blueColor];
    
    [self setTypingAttributes:@{NSParagraphStyleAttributeName:[self defaultParagraphStyle]}];

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


-(void)keyDown:(NSEvent *)theEvent {
    
    
    
    TGMessagesHintView *hint = self.controller.hintView;
    
    
    if(!hint.isHidden) {
        if(theEvent.keyCode == 125 || theEvent.keyCode == 126) {
            
            if(theEvent.keyCode == 125) {
                [hint selectNext];
            } else {
                [hint selectPrev];
            }
            
            return;
            
        }
        
        
        if([self isEnterEvent:theEvent] || [self isCommandEnterEvent:theEvent]) {
            
            BOOL result = [self.growingDelegate TMGrowingTextViewCommandOrControlPressed:self isCommandPressed:[self isCommandEnterEvent:theEvent]];
            
            if(result) {
                
                [hint performSelected];
                return;
            }
            
        }
        
    } else if(theEvent.keyCode == 126 && self.stringValue.length == 0) {
        [self.controller forceSetLastSentMessage];
        return;
    }
    
    //lol. MessagesBottomView
    if(!self.superview.superview.superview.superview.superview.isHidden) {
        
       
        
        [super keyDown:theEvent];
    }
    
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    BOOL superAnswer = [super validateMenuItem:menuItem];
    if(menuItem.action == @selector(paste:)) {
        
        BOOL ok = [[NSPasteboard generalPasteboard] canReadObjectForClasses:[NSArray arrayWithObject:[NSImage class]] options:@{}];
        
        return ok || superAnswer;
    }
    return superAnswer;
}


@end
