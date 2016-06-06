//
//  MessagesTopInfoView.m
//  Telegram
//
//  Created by keepcoder on 02.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessagesTopInfoView.h"
#import "TLPeer+Extensions.h"
#import "MessageReplyContainer.h"
#import "TGReplyObject.h"
#import "MessageTableItem.h"
@interface MessagesTopInfoView () <TMHyperlinkTextFieldDelegate>
@property (nonatomic,strong) TMHyperlinkTextField *field;
@property (nonatomic,strong) NSProgressIndicator *progress;

@property (nonatomic,assign) BOOL locked;

@property (nonatomic,strong) BTRButton *cancel;

@property (nonatomic,strong) RPCRequest *request;

@property (nonatomic,strong) MessageReplyContainer *pinnedContainer;

@end

@implementation MessagesTopInfoView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        self.field = [TMHyperlinkTextField defaultTextField];
        
        
        [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
       
        
        self.progress = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        [self.progress setAutoresizingMask:NSViewMaxXMargin | NSViewMinXMargin];
        
        [self.progress setStyle:NSProgressIndicatorSpinningStyle];
        
        
        [self addSubview:self.progress];
        
        [self addSubview:self.field];
        
        self.locked = NO;
        
        self.backgroundColor = NSColorFromRGB(0xffffff);

        
        self.action = MessagesTopInfoActionShareContact;
        
        self.field.url_delegate = self;
        
        
        _cancel = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 72, NSHeight(frame))];
        [_cancel setTitle:NSLocalizedString(@"Messages.MessagesTopInfoActionReportSpam.ButtonCancel", nil) forControlState:BTRControlStateNormal];
        [_cancel setTitleFont:TGSystemMediumFont(13) forControlState:BTRControlStateNormal];
        [_cancel setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
        
        weak();
        
        [_cancel addBlock:^(BTRControlEvents events) {
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"showreport_%d",weakSelf.conversation.user.n_id]];
            
            TL_conversation *conversation = weakSelf.conversation;
            
            [weakSelf.controller showModalProgress];
            
            [RPCRequest sendRequest:[TLAPI_messages_hideReportSpam createWithPeer:weakSelf.conversation.inputPeer] successHandler:^(id request, id response) {
                
                [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:[NSString stringWithFormat:@"alwaysHideReportSpam_%d",conversation.peer_id]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if(weakSelf.conversation == conversation)
                    [weakSelf setConversation:conversation];
                
                [weakSelf.controller hideModalProgressWithSuccess];

                
            } errorHandler:^(id request, RpcError *error) {
                [weakSelf.controller hideModalProgress];
            }];
            
            
        } forControlEvents:BTRControlEventClick];
        
        
        [_cancel setHidden:YES];
        
        [self addSubview:_cancel];
        
    }
    return self;
}

static NSMutableDictionary *cache;

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSMutableDictionary alloc] init];
        
        cache[@(MessagesTopInfoActionShareContact)] = [[NSMutableDictionary alloc] init];
        cache[@(MessagesTopInfoActionAddContact)] = [[NSMutableDictionary alloc] init];
    });
}


-(void)setLocked:(BOOL)locked {
    self->_locked = locked;
    
    [self.progress setHidden:!locked];
    [self.field setHidden:locked];
    
    if(self.progress.isHidden)
        [self.progress stopAnimation:self];
    else [self.progress startAnimation:self];
}

-(void)setFrame:(NSRect)frameRect {
    [super setFrame:NSMakeRect(0, NSMinY(frameRect), NSWidth(self.controller.table.containerView.frame), frameRect.size.height)];
    
    [self.progress setCenterByView:self];
    [self.field setCenterByView:self];
}


- (void)didChangeUserBlock:(NSNotification *)notification {
    
    return;
    
    TL_contactBlocked *contact = notification.userInfo[KEY_USER];
    
    if(_conversation.user.n_id != contact.user_id || _conversation.user.isBot)
        return;
    
    if(_conversation.user.isBlocked) {
        self.action = MessagesTopInfoActionUnblockUser;
        [self show:YES];
    } else {
        [self hide:YES];
    }
}

- (void)didChangeUserType:(NSNotification *)notification {
    TLUser *user = notification.userInfo[KEY_USER];
    
     MessagesTopInfoAction newAction = MessagesTopInfoActionNone;
    
    if(user.type == TLUserTypeRequest)
        newAction = MessagesTopInfoActionAddContact;
    
    if(user.type == TLUserTypeForeign) {
        newAction = MessagesTopInfoActionShareContact;
    }
    
    [cache[@(newAction)] removeObjectForKey:@(user.n_id)];
    
    if(newAction != MessagesTopInfoActionNone) {
        self.action = newAction;
        [self show:YES];
    } else {
        [self hide:YES];
    }
    
    
}

-(void)show:(BOOL)animated {
    if(!self.isShown) {
        [self.controller showTopInfoView:animated];
        _isShown = YES;
    }
}

-(void)hide:(BOOL)animated {
    if(self.isShown) {
        [self.controller hideTopInfoView:animated];
        _isShown = NO;
    }
    
}

-(void)dealloc {
    [Notification removeObserver:self];
}


-(void)setConversation:(TL_conversation *)conversation {
    self->_conversation = conversation;
    
    [_pinnedContainer removeFromSuperview];
    _pinnedContainer = nil;
    
    self.locked = NO;
    
    [Notification removeObserver:self];
    
    [Notification addObserver:self selector:@selector(didChangeUserBlock:) name:USER_BLOCK];
    
    [Notification addObserver:self selector:@selector(didChangeUserType:) name:[Notification notificationForUser:conversation.user action:USER_CHANGE_TYPE]];
    [Notification addObserver:self selector:@selector(didUpdatePinnedMessage:) name:UPDATE_PINNED_MESSAGE];
    
    [Notification addObserver:self selector:@selector(messageTableDeleteMessage:) name:MESSAGE_DELETE_EVENT];
    
    TLUser *user = conversation.user;
    
    MessagesTopInfoAction newAction = MessagesTopInfoActionNone;
    
    if(!user.isContact && user.phone.length > 0 && !user.isServiceUser)
        newAction = MessagesTopInfoActionAddContact;
   else if(!user.isContact && user.phone.length == 0) {
        newAction = MessagesTopInfoActionNone;;
    }

    if(user.isBot) {
        newAction = MessagesTopInfoActionNone;
    }
    

    
    
    
    if(cache[@(newAction)] && cache[@(newAction)][@(conversation.peer.peer_id)]) {
        [self hide:NO];
        return;
    }

    
    
    if(newAction == MessagesTopInfoActionNone) {
        [self hide:NO];
    } else {
        self.action = newAction;
        [self show:NO];
        
    }
    
    [_request cancelRequest];
    _request = nil;
    
    
    
    if(self.conversation.type == DialogTypeChannel && self.conversation.chat.isMegagroup) {
        
        TLChatFull *fullChat = [[ChatFullManager sharedManager] find:self.conversation.chat.n_id];
        
        if(fullChat.pinned_msg_id > 0) {
            [self loadAndShowPinnedMessage:fullChat.pinned_msg_id chat_id:fullChat.n_id animated:NO];
        } else {
            [[ChatFullManager sharedManager] requestChatFull:self.conversation.chat.n_id withCallback:^(TLChatFull *fullChat) {
                
                if(fullChat.pinned_msg_id > 0) {
                    [self loadAndShowPinnedMessage:fullChat.pinned_msg_id chat_id:fullChat.n_id animated:YES];
                }
                
            }];
        }
        
    }
    
    if(self.conversation.type != DialogTypeSecretChat) {
        [self checkReportSpam];
    }
    
}


-(void)messageTableDeleteMessage:(NSNotification *)notification {
    
    
    
    
    [ASQueue dispatchOnMainQueue:^{
        
        NSArray *updateData = [notification.userInfo objectForKey:KEY_DATA];
        
        if(updateData.count == 0)
            return;

        
        
        [updateData enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            
            
            int peer_id = [obj[KEY_PEER_ID] intValue];
            
            int message_id = [obj[KEY_MESSAGE_ID] intValue];
            
            if(self.conversation.peer_id == peer_id && _pinnedContainer.replyObject.replyMessage.n_id == message_id) {
                [self deletePinnedMessage:_pinnedContainer.replyObject.replyMessage chat_id:abs(peer_id) withRequest:NO];
                *stop = YES;
            }
            
        }];

        
    }];
}




-(void)checkReportSpam {
    
    BOOL alwaysHide = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"alwaysHideReportSpam_%d",_conversation.peer_id]];
    
    if(!alwaysHide) {
        
        TL_conversation *conversation = self.conversation;
        
        [RPCRequest sendRequest:[TLAPI_messages_getPeerSettings createWithPeer:_conversation.inputPeer] successHandler:^(id request, TL_peerSettings *response) {
            
            if(response.isReport_spam) {
                if(conversation == self.conversation) {
                    [self setAction:MessagesTopInfoActionReportSpam];
                    [self show:YES];
                }
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:[NSString stringWithFormat:@"alwaysHideReportSpam_%d",conversation.peer_id]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }

            
        } errorHandler:^(id request, RpcError *error) {
            
        }];
    }
    
}

-(void)didUpdatePinnedMessage:(NSNotification *)notification {
    int peer_id = [notification.userInfo[KEY_PEER_ID] intValue];
    int msg_id = [notification.userInfo[KEY_MESSAGE_ID] intValue];
                  
                  
    if(_conversation.peer_id == peer_id) {
        if(msg_id != 0 ) {
            [self loadAndShowPinnedMessage:msg_id chat_id:abs(peer_id) animated:YES];
        }else if(self.action == MessagesTopInfoActionPinnedMessage) {
            [self hide:YES];
        }
    }
}

-(void)loadAndShowPinnedMessage:(int)msg_id chat_id:(int)chat_id animated:(BOOL)animated {
    
    __block TL_localMessage *msg = [[Storage manager] messageById:msg_id inChannel:-chat_id];
    
    
    dispatch_block_t block = ^{
        
        if(![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"igonore_pinned_%d_%d",msg_id,chat_id]]) {
            self.action = MessagesTopInfoActionPinnedMessage;
            
            TGReplyObject *replyObject = [[TGReplyObject alloc] initWithReplyMessage:msg fromMessage:nil tableItem:nil pinnedMessage:YES];
            
            [_pinnedContainer removeFromSuperview];
            _pinnedContainer = nil;
            
            _pinnedContainer = [[MessageReplyContainer alloc] initWithFrame:NSMakeRect([MessageTableItem defaultContainerOffset], 0, NSWidth(self.frame) - [MessageTableItem defaultContainerOffset] * 2, replyObject.containerHeight)];
            
            //_pinnedContainer.autoresizingMask = NSViewWidthSizable;
            
            _pinnedContainer.pinnedMessage = YES;
            
            weak();
            
            _pinnedContainer.deleteHandler = ^{
                strongWeak();
                if(strongSelf == weakSelf) {
                    
                    dispatch_block_t block = ^{
                        strongSelf.pinnedContainer.pinnedMessage = NO;
                        [strongSelf deletePinnedMessage:msg chat_id:chat_id withRequest:YES];
                    };
                    if(strongSelf.conversation.chat.isManager)
                        confirm(appName(), NSLocalizedString(@"Channel.ConfirmUnpin", nil), block, nil);
                    else
                        block();
                    
                }
            };
            
            
            [_pinnedContainer setCenteredYByView:self];
            _pinnedContainer.replyObject = replyObject;
            
            
            
            [self addSubview:_pinnedContainer];
            
            [self show:animated];
        }
        
    };
    
    if(!msg) {
        _request = [RPCRequest sendRequest:[TLAPI_channels_getMessages createWithChannel:self.conversation.chat.inputPeer n_id:[@[@(msg_id)] mutableCopy]] successHandler:^(id request, TL_messages_messages *response) {
            
            if(response.messages.count > 0 && ![response.messages[0] isKindOfClass:[TL_messageEmpty class]]) {
                msg = [TL_localMessage convertReceivedMessage:response.messages[0]];
                if(msg.peer_id == self.conversation.peer_id) {
                    [response.messages removeAllObjects];
                    [SharedManager proccessGlobalResponse:response];
                    
                    
                    [[Storage manager] addHolesAroundMessage:msg];
                    [[Storage manager] insertMessages:@[msg]];
                    
                    
                    if(![msg isKindOfClass:[TL_messageEmpty class]]) {
                        block();
                    }
                }
                
            }
            
        } errorHandler:^(id request, RpcError *error) {
            
        }];
    } else {
        block();
    }
    
}

-(void)deletePinnedMessage:(TL_localMessage *)msg chat_id:(int)chat_id withRequest:(BOOL)withRequest {
   
     dispatch_block_t block = ^{
        TLChatFull *chat = [[ChatFullManager sharedManager] find:chat_id];
         
         if(!withRequest) {
             [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:[NSString stringWithFormat:@"igonore_pinned_%d_%d",msg.n_id,chat_id]];
         }
         
        
        chat.pinned_msg_id = 0;
        
        [[Storage manager] insertFullChat:chat completeHandler:nil];
        
        [self hide:YES];

    };
    
    if(_conversation.chat.isManager && withRequest) {
        
        [self.controller showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_channels_updatePinnedMessage createWithFlags: 0 channel:msg.conversation.inputPeer n_id:0] successHandler:^(id request, id response) {
            
            block();
            
            [self.controller hideModalProgressWithSuccess];
            
        } errorHandler:^(id request, RpcError *error) {
            [self.controller hideModalProgress];
        }];

    } else {
        block();
    }
    
    
    
}


-(void)setAction:(MessagesTopInfoAction)action {
    self->_action = action;
    
    if(action == MessagesTopInfoActionNone) {
        return;
    }
    
    [self setFrame:NSMakeRect(NSMinX(self.frame), NSMinY(self.frame), NSWidth(self.frame), action == MessagesTopInfoActionPinnedMessage ? 46 : 40)];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    
    static NSString * const localizations[] = {
        [MessagesTopInfoActionAddContact] = @"Messages.MessagesTopInfoActionAddContact",
        [MessagesTopInfoActionShareContact] = @"Messages.MessagesTopInfoActionShareContact",
        [MessagesTopInfoActionUnblockUser] = @"Messages.MessagesTopInfoActionUnblockUser",
        [MessagesTopInfoActionReportSpam] = @"",
        [MessagesTopInfoActionPinnedMessage] = @""
    };
    
    static NSString * const buttonLocalization[] = {
        [MessagesTopInfoActionAddContact] = @"Messages.MessagesTopInfoActionAddContact.Button",
        [MessagesTopInfoActionShareContact] = @"Messages.MessagesTopInfoActionShareContact.Button",
        [MessagesTopInfoActionUnblockUser] = @"Messages.MessagesTopInfoActionUnblockUser.Button",
        [MessagesTopInfoActionReportSpam] = @"Messages.MessagesTopInfoActionReportSpam.Button",
        [MessagesTopInfoActionPinnedMessage] = @""
    };
    
    [string appendString:NSLocalizedString(localizations[action], nil) withColor:NSColorFromRGB(0xa9a9a9)];
    
    [string appendString:@" "];
    
    NSRange range = [string appendString:NSLocalizedString(buttonLocalization[action], nil) withColor:BLUE_UI_COLOR];
    
    [string addAttributes:@{NSLinkAttributeName:@"first"} range:range];
    
    [string setAlignment:NSCenterTextAlignment range:string.range];
    
    [_cancel setHidden:action != MessagesTopInfoActionReportSpam];
    
    
    [self.field setAttributedStringValue:string];
    
    [self.field sizeToFit];
    
    [self.field setCenterByView:self];
    
    [self.progress setCenterByView:self];
    
}

-(void)setNeedsDisplay:(BOOL)flag {
    [super setNeedsDisplay:flag];
    
    self.action = self.action;
}

- (void)textField:(id)textField handleURLClick:(NSString *)url {
   
    if(self.locked)
        return;
    
    
    if(self.action == MessagesTopInfoActionShareContact) {
        [self.controller shareContact:[UsersManager currentUser] forConversation:self.conversation callback:nil];
        cache[@(self.action)][@(self.conversation.peer.peer_id)] = @(self.conversation.peer.peer_id);
        [self hide:YES];
    }
    
    if(self.action == MessagesTopInfoActionUnblockUser) {
        self.locked = YES;
        [[BlockedUsersManager sharedManager] unblock:self.controller.conversation.user.n_id completeHandler:^(BOOL response) {
            [self hide:YES];
            self.locked = NO;
        }];
    }
    
    if(self.action == MessagesTopInfoActionAddContact) {
        self.locked = YES;
        [[NewContactsManager sharedManager] importContact:[TL_inputPhoneContact createWithClient_id:0 phone:self.controller.conversation.user.phone first_name:self.controller.conversation.user.first_name last_name:self.controller.conversation.user.last_name] callback:^(BOOL isAdd, TL_importedContact *contact, TLUser *user) {
            cache[@(self.action)][@(self.conversation.peer.peer_id)] = @(self.conversation.peer.peer_id);
            [self hide:YES];
            self.locked = NO;
        }];
    }
    
    if(self.action == MessagesTopInfoActionReportSpam) {
        
        confirm(appName(), NSLocalizedString(@"ReportSpam.ConfirmDescription", nil), ^{
            
            self.locked = YES;
            
            weak();
            
            TL_conversation *conversation = _conversation;
            
            [RPCRequest sendRequest:[TLAPI_messages_reportSpam createWithPeer:conversation.user.inputPeer] successHandler:^(id request, id response) {
                
                 [[DialogsManager sharedManager] deleteDialog:conversation completeHandler:^{
                     
                     if(conversation.type == DialogTypeUser) {
                         [[BlockedUsersManager sharedManager] block:conversation.user.n_id completeHandler:^(BOOL response) {
                             
                             weakSelf.locked = NO;
                             weakSelf.conversation = weakSelf.conversation;
                         }];
                     } else {
                         weakSelf.locked = NO;
                         weakSelf.conversation = weakSelf.conversation;
                     }
                      
                    
                }];
                
                
            } errorHandler:^(id request, RpcError *error) {
                weakSelf.locked = NO;
                weakSelf.conversation = weakSelf.conversation;
            }];
            
        }, ^{
            
        });
        
        
        
    }
    
}


-(void)mouseUp:(NSEvent *)theEvent
{
   // [self.controller hideTopInfoView];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_field setFrameSize:NSMakeSize(NSWidth(self.frame) - 40, NSHeight(_field.frame))];
    [_field setCenteredXByView:self];
    [_pinnedContainer setFrame:NSMakeRect(NSMinX(_pinnedContainer.frame), NSMinY(_pinnedContainer.frame), newSize.width - NSMinX(_pinnedContainer.frame) * 2, NSHeight(_pinnedContainer.frame))];
    [_cancel setFrameOrigin:NSMakePoint(newSize.width - NSWidth(_cancel.frame), 2)];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [GRAY_BORDER_COLOR set];
    
    NSRectFill(NSMakeRect(0, 0, self.frame.size.width, 1));
    
    // Drawing code here.
}

@end
