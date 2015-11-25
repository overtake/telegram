//
//  MesssageInputGrowingTextView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/15/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageInputGrowingTextView.h"
#import "TMImageUtils.h"
#import "MessageSender.h"
#import "ImageUtils.h"
#import "TGMentionPopup.h"
#import "TGHashtagPopup.h"
#import "NSString+FindURLs.h"
#import "NSString+Extended.h"
#import "TGBotCommandsPopup.h"
typedef enum {
    PasteBoardItemTypeVideo,
    PasteBoardItemTypeDocument,
    PasteBoardItemTypeImage,
    PasteBoardItemTypeGif,
    PasteBoardTypeLink
} PasteBoardItemType;

@implementation MessageInputGrowingTextView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setPlaceholderString:NSLocalizedString(@"Messages.SendPlaceholder", nil)];
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    NSPasteboard *pst = [sender draggingPasteboard];
    
    if([pst.types containsObject:NSStringPboardType]) {
        NSString *text = [pst stringForType:NSStringPboardType];
        
        [self insertText:text];
        
        return YES;
        
    } else {
        
        return [MessageSender sendDraggedFiles:sender dialog:[Telegram rightViewController].messagesViewController.conversation asDocument:NO];
    
    }
    
    return NO;
}

-(void)insertText:(id)insertString {
    //lol. MessagesBottomView
    if(!self.superview.superview.superview.superview.superview.isHidden) {
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
                [MessageSender sendFilesByPath:files dialog:[Telegram rightViewController].messagesViewController.conversation isMultiple:isMultiple asDocument:NO];
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
            
            if([[Telegram rightViewController] messagesViewController].conversation.type == DialogTypeSecretChat) {
                alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Conversation.Confirm.SendThisPicture", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.SendThisPictureDescription", nil) block:^(id result) {
                    if([result intValue] == 1000) {
                        
                        [[[Telegram rightViewController] messagesViewController] sendImage:image.name forConversation:[[Telegram rightViewController] messagesViewController].conversation file_data:[image TIFFRepresentation]];
                        
                    }
                }];
            } else {
                 [[[Telegram rightViewController] messagesViewController] sendImage:image.name forConversation:[[Telegram rightViewController] messagesViewController].conversation file_data:[image TIFFRepresentation]];
            }
            
           
            break;
            
        case PasteBoardItemTypeDocument:
            alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Conversation.Confirm.SendThisFile", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.SendThisFileDescription", nil) block:^(id result) {
                if([result intValue] == 1000) {
                    
                    [[[Telegram rightViewController] messagesViewController] sendDocument:path forConversation:[[Telegram rightViewController] messagesViewController].conversation];
                    
                }
            }];
            break;
            
        case PasteBoardItemTypeVideo:
            alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Conversation.Confirm.SendThisVideo", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.SendThisVideoDescription", nil) block:^(id result) {
                if([result intValue] == 1000) {
                    
                    [[[Telegram rightViewController] messagesViewController] sendVideo:path forConversation:[[Telegram rightViewController] messagesViewController].conversation];
                    
                }
            }];
            break;
            
        case PasteBoardItemTypeGif:
            alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Conversation.Confirm.SendThisGif", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.SendThisGifDescription", nil) block:^(id result) {
                if([result intValue] == 1000) {
                    
                    [[[Telegram rightViewController] messagesViewController] sendDocument:path forConversation:[[Telegram rightViewController] messagesViewController].conversation];
                    
                }
            }];
            break;
            

            
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
    [super setString:string];
    
}



-(void)checkWebpages {
    
    NSString *link = [self.string webpageLink];
    
    [[Telegram rightViewController].messagesViewController checkWebpage:link];
    
}



-(void)didChangeSettingsMask:(SettingsMask)mask {
    [self updateFont];
}


-(void)updateFont {
    self.font = TGSystemFont([SettingsArchiver checkMaskedSetting:BigFontSetting] ? 15 : 13);
    [self textDidChange:nil];
    [self setPlaceholderString:NSLocalizedString(@"Messages.SendPlaceholder", nil)];
}

-(void)textDidChange:(NSNotification *)notification {
    
    [super textDidChange:notification];
    
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
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"enableSpelling"];
    }
    
    self.maxHeight = 250;
    self.minHeight = 33;
    
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
        [strongSelf.scrollView setFrameSize:NSMakeSize(NSWidth(rect) - 40, NSHeight(strongSelf.scrollView.frame))];
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
