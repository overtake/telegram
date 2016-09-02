//
//  TGMessagesGrowingTextView.m
//  Telegram
//
//  Created by keepcoder on 20/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGMessagesGrowingTextView.h"
#import "TGSingleMediaSenderModalView.h"
@interface TGMessagesTextView : TGGrowingTextView
@end

@implementation TGMessagesTextView

-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    NSPasteboard *pst = [sender draggingPasteboard];
    
    if([pst.types containsObject:NSStringPboardType]) {
        NSString *text = [pst stringForType:NSStringPboardType];
        
        [self insertText:text];
        
        return YES;
        
    } else {
        
        return [MessageSender sendDraggedFiles:sender dialog:self.weakd.messagesController.conversation asDocument:NO messagesViewController:self.weakd.messagesController];
        
    }
    
    return NO;
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
                [MessageSender sendFilesByPath:files dialog:self.weakd.messagesController.conversation isMultiple:isMultiple asDocument:NO messagesViewController:self.weakd.messagesController];
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
    NSString *caption = [[[pasteboard pasteboardItems] objectAtIndex:0] stringForType:@"public.utf8-plain-text"];
    if (url != nil) {
        path = [[NSURL URLWithString:url] path];
        
        CFStringRef fileExtension = (__bridge CFStringRef) [[path pathExtension] lowercaseString];
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
        
        if (UTTypeConformsTo(fileUTI, kUTTypeImage) && [document_preview_mime_types() indexOfObject:mimetypefromExtension((__bridge NSString *)fileExtension)] != NSNotFound) {
            
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
            
            return;
        }
        
        
        if(image.size.width / 10 < image.size.height) {
            type = PasteBoardItemTypeImage;
            iconImage = cropCenterWithSize(image, NSMakeSize(70, 70));
        } else {
            type = PasteBoardItemTypeDocument;
            if(!path) {
                path = exportPath(rand_long(), @"jpg");
                [jpegNormalizedData(image) writeToFile:path atomically:YES];
            }
            
        }
        
        
    }
    
    dispatch_block_t modal_caption_block = ^{
        TGSingleMediaSenderModalView *modalView = [[TGSingleMediaSenderModalView alloc] initWithFrame:NSZeroRect];
        
        [modalView show:self.window animated:YES file:path ? path : image.name filedata:jpegNormalizedData(image) ptype:type caption:nil conversation:self.weakd.messagesController.conversation messagesViewController:self.weakd.messagesController];
    };
    
    
    NSAlert *alert = nil;
    
    switch (type) {
        case PasteBoardItemTypeImage:
        {
            if(self.weakd.messagesController.conversation.type == DialogTypeSecretChat) {
                alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Conversation.Confirm.SendThisPicture", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.SendThisPictureDescription", nil) block:^(id result) {
                    if([result intValue] == 1000) {
                        
                        [self.weakd.messagesController sendImage:image.name forConversation:self.weakd.messagesController.conversation file_data:[image TIFFRepresentation]];
                        
                    }
                }];
            } else {
                if(self.weakd.messagesController.attachmentsCount == 0 && self.string.length == 0)
                    modal_caption_block();
                else
                    [self.weakd.messagesController sendImage:@"image" forConversation:self.weakd.messagesController.conversation file_data:[image TIFFRepresentation]];
            }
            
            
            break;
        }
            
        case PasteBoardItemTypeDocument:
        {
            
            if(self.weakd.messagesController.conversation.type != DialogTypeSecretChat) {
                modal_caption_block();
                
                break;
            } else {
                alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Conversation.Confirm.SendThisFile", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.SendThisFileDescription", nil) block:^(id result) {
                    if([result intValue] == 1000) {
                        
                        [self.weakd.messagesController sendDocument:path forConversation:self.weakd.messagesController.conversation];
                        
                    }
                }];
                break;
            }
            
            
            
            
        }
            
        case PasteBoardItemTypeVideo:
        {
            if(self.weakd.messagesController.conversation.type != DialogTypeSecretChat) {
                
                modal_caption_block();
                break;
            } else {
                alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Conversation.Confirm.SendThisVideo", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.SendThisVideoDescription", nil) block:^(id result) {
                    if([result intValue] == 1000) {
                        
                        [self.weakd.messagesController sendVideo:path forConversation:self.weakd.messagesController.conversation];
                        
                    }
                }];
                break;
            }
            
            
        }
        case PasteBoardItemTypeGif:
        {
            alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Conversation.Confirm.SendThisGif", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.SendThisGifDescription", nil) block:^(id result) {
                if([result intValue] == 1000) {
                    
                    [self.weakd.messagesController sendDocument:path forConversation:self.weakd.messagesController.conversation];
                    
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

-(BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if(menuItem.action == @selector(changeLayoutOrientation:)) {
        return NO;
    }
    
    if(menuItem.action == @selector(paste:))
        return YES;
    
    
    return [super validateMenuItem:menuItem];
}

-(void)keyDown:(NSEvent *)theEvent {
    
    
    
    TGMessagesHintView *hint = self.weakd.messagesController.hintView;
    
    
    if(!hint.isHidden) {
        if(theEvent.keyCode == 125 || theEvent.keyCode == 126) {
            
            if(theEvent.keyCode == 125) {
                [hint selectNext];
            } else {
                [hint selectPrev];
            }
            
            return;
            
        }
        
        
        if(isEnterAccess(theEvent)) {
            
            [hint performSelected];
            return;
            
        }
        
    } else if(theEvent.keyCode == 126 && (self.string.length == 0)) {
        [self.weakd.messagesController forceSetEditSentMessage:NO];
        return;
    } else if(theEvent.keyCode == 124) {
        if([self.weakd.messagesController selectNextStickerIfNeeded])
            return;
    } else if(theEvent.keyCode == 123) {
        if([self.weakd.messagesController selectPrevStickerIfNeeded])
            return;
    }
    
    //MessagesBottomView
   // if(!self.superview.superview.superview.superview.superview.isHidden) {
        
        [super keyDown:theEvent];
   // }
    
}

-(BOOL)becomeFirstResponder {
    
    return [super becomeFirstResponder];
}

@end

@implementation TGMessagesGrowingTextView



- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(Class)_textViewClass {
    return [TGMessagesTextView class];
}

-(void)setInline:(BOOL)isInline placeHolder:(NSAttributedString *)placeholder {
    _isInline = isInline;
    [self setPlaceholderAttributedString:placeholder update:NO];
}

-(int)_startXPlaceholder {
    return _isInline ? [self.attributedString sizeForTextFieldForWidth:NSWidth(self.frame)].width - 2  : [super _startXPlaceholder];
}

-(NSFont *)font {
    return [SettingsArchiver font];
}

-(BOOL)_needShowPlaceholder {
    return _isInline || [super _needShowPlaceholder];
}


@end
