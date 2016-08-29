//
//  MessageTableCell.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCell.h"
#import "MessageTableCellTextView.h"
#import "TGMessageViewSender.h"
#import "POPCGUtils.h"
@interface MessageTableCell()<NSMenuDelegate>

@end

@implementation MessageTableCell

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
//        self.wantsLayer = YES;
//        self.layer.backgroundColor = [NSColor whiteColor].CGColor;
//        self.layer.opaque = NO;
    }
    return self;
}

- (void)setItem:(MessageTableItem *)item {
    self->_item = item;
    
    if(item.message && ( item.message.dstate != DeliveryStateNormal && item.messageSender == nil )) {
        
        SenderItem *sender = [SenderItem senderForMessage:item.message];
        
        if(sender && sender.state != MessageSendingStateSent) {
            item.messageSender = sender;
            if(item.messageSender.state == MessageStateWaitSend) {
                [item.messageSender send];
            }
        }
        
    }
    
    if(item.message.isChannelMessage && item.message.isPost && !item.message.isViewed) {
        if(![item.message isKindOfClass:[TL_localMessageService class]]) {
            item.message.viewed = YES;
            [TGMessageViewSender addItem:item];
        }
        
    }
    
}

- (void)resizeAndRedraw {
    [self setItem:self.item];
}


-(void)addScrollEvent {
    id clipView = [[self.item.table enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didScrolledTableView:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];

}

-(void)removeScrollEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)_didScrolledTableView:(NSNotification *)notification {
    
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)rightMouseDown:(NSEvent *)theEvent {
    
    if(self.item.messageSender != nil || self.item.message.n_id > TGMINFAKEID || ![self.messagesViewController contextAbility]) {
        [super rightMouseDown:theEvent];
        return;
    }
    
    NSMenu *contextMenu = [self contextMenu];
    
    if(contextMenu && self.messagesViewController.state == MessagesViewControllerStateNone) {
        
        contextMenu.delegate = self;
        
        [NSMenu popUpContextMenu:contextMenu withEvent:theEvent forView:self];
    } else {
        [super rightMouseDown:theEvent];
    }
}


- (void)menuWillOpen:(NSMenu *)menu {
    self.layer.backgroundColor =  NSColorFromRGB(0xf7f7f7).CGColor;
    [self _didChangeBackgroundColorWithAnimation:nil toColor:NSColorFromRGB(0xf7f7f7)];
}


- (void)menuDidClose:(NSMenu *)menu {
    self.layer.backgroundColor = NSColorFromRGB(0xffffff).CGColor;
    [self _didChangeBackgroundColorWithAnimation:nil toColor:NSColorFromRGB(0xffffff)];
}


- (NSMenu *)contextMenu {
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Context"];
    
    [self.defaultMenuItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [menu addItem:item];
    }];
    
    return menu;
}

-(NSArray *)defaultMenuItems {
    
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    
    weak();
    
    
    BOOL canEdit = self.item.message.canEdit;
    
    if(canEdit) {
        [items addObject:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Edit", nil) withBlock:^(id sender) {
            
            [weakSelf.messagesViewController setEditableMessage:weakSelf.item.message];
            
            [RPCRequest sendRequest:[TLAPI_messages_getMessageEditData createWithPeer:weakSelf.item.message.conversation.inputPeer n_id:weakSelf.item.message.n_id] successHandler:^(id request, id response) {
                
                [SharedManager proccessGlobalResponse:response];
                
            } errorHandler:nil];
            
        }]];
    }
    
    
    if(self.item.message.isChannelMessage && self.item.message.chat.isMegagroup && self.item.message.chat.isManager) {
        
        TLChatFull *chat = [[ChatFullManager sharedManager] find:abs(self.item.message.peer_id)];
        
        BOOL unpin = chat.pinned_msg_id == self.item.message.n_id;
        
        
        [items addObject:[NSMenuItem menuItemWithTitle:!unpin ? NSLocalizedString(@"Context.Pin", nil) : NSLocalizedString(@"Context.Unpin", nil) withBlock:^(id sender) {
        
            BOOL unpin = chat.pinned_msg_id == weakSelf.item.message.n_id;
            __block int flags = 0;
            dispatch_block_t block = ^{
                [RPCRequest sendRequest:[TLAPI_channels_updatePinnedMessage createWithFlags:flags channel:weakSelf.item.message.chat.inputPeer n_id:unpin ? 0 : weakSelf.item.message.n_id] successHandler:^(id request, id response) {
                    
                    
                } errorHandler:nil];
            };
            
            if(!unpin) {
                
                NSAlert *alert = [NSAlert alertWithMessageText:appName() informativeText:NSLocalizedString(@"Pin.PinMessageAndNotifyDesc", nil) block:^(id result) {
                    
                    if([result intValue] != 1002) {
                        if([result intValue] != 1000)
                            flags|= (1 << 0);
                        block();
                    }
                    
                    
                }];
                [alert addButtonWithTitle:NSLocalizedString(@"Pin.Ok", nil)];
                [alert addButtonWithTitle:NSLocalizedString(@"Pin.OnlyPin", nil)];
                [alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
                [alert show];
            } else {
                block();
            }
            
            
            
        }]];
    }
    
    
    if([self.item.message.conversation canSendMessage]) {
        
        if(self.item.message.conversation.type != DialogTypeSecretChat || self.item.message.conversation.encryptedChat.encryptedParams.layer >= 45) {
            [items addObject:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Reply", nil) withBlock:^(id sender) {
                
                TGInputMessageTemplate *template = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:self.item.message.peer_id];
                [template setReplyMessage:self.item.message save:YES];
                [template performNotification];
                
            }]];
        }
    }
    

    
    if([self.item canShare]) {
        
        NSArray *shareServiceItems = [NSSharingService sharingServicesForItems:@[self.item.shareObject]];
        
        NSMenu *shareMenu = [[NSMenu alloc] initWithTitle:@"Share"];
        
        
        for (NSSharingService *currentService in shareServiceItems) {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:currentService.title action:@selector(selectedSharingServiceFromMenuItem:) keyEquivalent:@""];
            item.image = currentService.image;
            item.representedObject = currentService;
            [shareMenu addItem:item];
        }
        
        NSMenuItem *shareSubItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Share",nil) withBlock:nil];
        
        [shareSubItem setSubmenu:shareMenu];
        
        [items addObject:shareSubItem];
        
        [items addObject:[NSMenuItem separatorItem]];
        
    }
    
    
    if(self.item.message.conversation.type != DialogTypeSecretChat) {
        [items addObject:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Forward", nil) withBlock:^(id sender) {
            
            [weakSelf.messagesViewController setState:MessagesViewControllerStateNone];
            [weakSelf.messagesViewController unSelectAll:NO];
            [weakSelf.messagesViewController setSelectedMessage:weakSelf.item selected:YES];
            [weakSelf.messagesViewController showForwardMessagesModalView];
            
            
        }]];
    }
    
    if([MessagesViewController canDeleteMessages:@[self.item.message] inConversation:self.item.message.conversation]) {
        [items addObject:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Delete", nil) withBlock:^(id sender) {
            
            [weakSelf.messagesViewController setState:MessagesViewControllerStateNone];
            [weakSelf.messagesViewController unSelectAll:NO];
            [weakSelf.messagesViewController setSelectedMessage:weakSelf.item selected:YES];
            [weakSelf.messagesViewController deleteSelectedMessages];
            
        }]];
    }
    
    if(self.item.message.dstate == DeliveryStateNormal) {
        [items addObject:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Select", nil) withBlock:^(id sender) {
            
            [weakSelf.messagesViewController setCellsEditButtonShow:YES animated:YES];
            [weakSelf setSelected:YES animated:YES];
            [weakSelf.messagesViewController setSelectedMessage:weakSelf.item selected:YES];
            
        }]];
    }
    
    return items;
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    if((theEvent.clickCount == 2) && self.messagesViewController.state == MessagesViewControllerStateNone) {
        
        BOOL accept = ![self mouseInText:theEvent];;
        
        if(accept && self.item.message.n_id < TGMINFAKEID && self.item.message.n_id > 0)
        {
            TGInputMessageTemplate *template = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:self.item.message.peer_id] ;
            [template setReplyMessage:self.item.message save:YES];
            [template performNotification];
        }
    }
    
    
    [super mouseDown:theEvent];
}


-(void)clearSelection {
    
}

- (void)stopSearchSelection {
    [self.layer pop_removeAnimationForKey:@"background"];
}

- (void)searchSelection {
    NSColor *color = NSColorFromRGB(0xffffff);
    NSColor *oldColor = NSColorFromRGB(0xf7f7f7);
    
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
    animation.duration = 2;
    animation.fromValue = (__bridge id)(oldColor.CGColor);
    animation.toValue = (__bridge id)(color.CGColor);
    [animation setCompletionBlock:^(POPAnimation *anim, BOOL finish) {
        [self.layer setBackgroundColor:(self.isSelected ? NSColorFromRGB(0xf7f7f7) : NSColorFromRGB(0xffffff)).CGColor];
    }];
    
    animation.removedOnCompletion = YES;
    
    [self.layer pop_addAnimation:animation forKey:@"background"];
    
    
    POPBasicAnimation *fieldsAnimation = [POPBasicAnimation animation];
    
    fieldsAnimation.property = [POPAnimatableProperty propertyWithName:@"background" initializer:^(POPMutableAnimatableProperty *prop) {
        
        [prop setReadBlock:^(TMView *textView, CGFloat values[]) {
            POPCGColorGetRGBAComponents(textView.backgroundColor.CGColor, values);
        }];
        
        [prop setWriteBlock:^(TMView *textView, const CGFloat values[]) {
            CGColorRef color = POPCGColorRGBACreate(values);
            textView.backgroundColor = [NSColor colorWithCGColor:color];
        }];
        
    }];
    
    fieldsAnimation.toValue = animation.toValue;
    fieldsAnimation.fromValue = animation.fromValue;
    fieldsAnimation.duration = animation.duration;
    fieldsAnimation.removedOnCompletion = YES;
    
    [self _didChangeBackgroundColorWithAnimation:fieldsAnimation toColor:color];
}

-(BOOL)mouseInText:(NSEvent *)theEvent {
    return NO;
}


- (void)copy:(id)sender {
    
    if(![self.item.message.media isKindOfClass:[TL_messageMediaEmpty class]]) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        
        
        [pasteboard writeObjects:[NSArray arrayWithObject:[NSURL fileURLWithPath:mediaFilePath(self.item.message)]]];
    }
}

-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)toColor {
    
}



@end
