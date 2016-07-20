//
//  TGModernMessagesBottomView.m
//  Telegram
//
//  Created by keepcoder on 11/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernMessagesBottomView.h"
#import "TGMessagesGrowingTextView.h"
#import "TGModernSendControlView.h"
#import "TGModernBottomAttachView.h"
#import "TGBottomActionsView.h"
#import "TGBottomTextAttachment.h"
#import "TGBottomKeyboardContainerView.h"
#import "TGBottomMessageActionsView.h"
#import "TGBottomBlockedView.h"
#import "TGBottomAudioRecordView.h"
#import "FullUsersManager.h"
#import "ChatFullManager.h"
@interface TGModernMessagesBottomView () <TGModernGrowingDelegate,TGBottomActionDelegate,TGModernSendControlDelegate> {
    TMView *_ts;
   
    id<SDisposable> _attachDispose;
    NSTrackingArea *_trackingArea;
}

@property (nonatomic,strong) TLUser *inlineBot;


@property (nonatomic,weak) MessagesViewController *messagesController;

@property (nonatomic,strong) TGMessagesGrowingTextView *textView;
@property (nonatomic,strong) TGModernSendControlView *sendControlView;
@property (nonatomic,strong) TGModernBottomAttachView *attachView;
@property (nonatomic,strong) TGBottomActionsView *actionsView;

@property (nonatomic,strong) TGBottomTextAttachment *attachment;
@property (nonatomic,strong) TGBottomKeyboardContainerView *botkeyboard;

@property (nonatomic,strong) TMView *attachmentsContainerView;
@property (nonatomic,strong) TMView *textContainerView;


@property (nonatomic,strong) TMView *topContainerView;

@property (nonatomic,assign) int attachmentsHeight;
@property (nonatomic,assign) int bottomHeight;


@property (nonatomic,strong) TGBottomMessageActionsView *messageActionsView;
@property (nonatomic,strong) TGBottomBlockedView *blockChatView;
@property (nonatomic,strong) TGBottomAudioRecordView *audioRecordView;
@end

@implementation TGModernMessagesBottomView


const float defYOffset = 12;

-(instancetype)initWithFrame:(NSRect)frameRect messagesController:(MessagesViewController *)messagesController {
    if(self = [super initWithFrame:frameRect]) {
        
        _attachmentsHeight = -1;
        _bottomHeight = 0;
        _actionState = -1;
        
        _animates = YES;
        self.wantsLayer = YES;
        
        self.layer.backgroundColor = [NSColor whiteColor].CGColor;
        
        self.autoresizingMask = NSViewWidthSizable;
        
        
        _topContainerView = [[TMView alloc] initWithFrame:self.bounds];
        _topContainerView.wantsLayer = YES;
      //  _topContainerView.layer.backgroundColor = [NSColor blueColor].CGColor;
        [self addSubview:_topContainerView];
        
        
        
        
        _attachmentsContainerView = [[TMView alloc] initWithFrame:NSMakeRect(0, NSHeight(frameRect), NSWidth(frameRect), 50)];
        _attachmentsContainerView.wantsLayer = YES;
        //_attachmentsContainerView.layer.backgroundColor = [NSColor redColor].CGColor;
        [_topContainerView addSubview:_attachmentsContainerView];
        
        _textContainerView = [[TMView alloc] initWithFrame:self.bounds];
        _textContainerView.wantsLayer = YES;
        [_topContainerView addSubview:_textContainerView];
        
        _messagesController = messagesController;

        
       
        
        _attachment = [[TGBottomTextAttachment alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(_textContainerView.frame), 50)];
        [_attachmentsContainerView addSubview:_attachment];
       
        
        _sendControlView = [[TGModernSendControlView alloc] initWithFrame:NSMakeRect(NSWidth(_textContainerView.frame) - 60, 0, 60, NSHeight(_textContainerView.frame))];
        _sendControlView.delegate = self;
        _sendControlView.wantsLayer = YES;
        
        
        _attachView = [[TGModernBottomAttachView alloc] initWithFrame:NSMakeRect(0, 0, 60, NSHeight(_textContainerView.frame)) messagesController:messagesController];
        _attachView.wantsLayer = YES;
        
        
        _actionsView = [[TGBottomActionsView alloc] initWithFrame:NSMakeRect(0, 0, 0, NSHeight(_textContainerView.frame)) messagesController:messagesController];
        _actionsView.delegate = self;
        _actionsView.wantsLayer = YES;
        
        
        _textView = [[TGMessagesGrowingTextView alloc] initWithFrame:NSMakeRect(NSWidth(_attachView.frame) , defYOffset, NSWidth(_textContainerView.frame)  - NSWidth(_attachView.frame) - NSWidth(_sendControlView.frame), NSHeight(_textContainerView.frame) - defYOffset*2) ];
        _textView.delegate = self;
        
        [_textContainerView addSubview:_attachView];
        [_textContainerView addSubview:_textView];
        [_textContainerView addSubview:_actionsView];
        [_textContainerView addSubview:_sendControlView];
        
        
        _botkeyboard = [[TGBottomKeyboardContainerView alloc] initWithFrame:NSZeroRect];
        _botkeyboard.wantsLayer = YES;
       // _botkeyboard.layer.backgroundColor = [NSColor redColor].CGColor;
        [self addSubview:_botkeyboard];
    
        
        
        _messageActionsView = [[TGBottomMessageActionsView alloc] initWithFrame:self.bounds messagesController:messagesController];
        _messageActionsView.wantsLayer = YES;
        
        _blockChatView = [[TGBottomBlockedView alloc] initWithFrame:self.bounds];
        _blockChatView.wantsLayer = YES;
        
        _audioRecordView = [[TGBottomAudioRecordView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.frame) - NSWidth(_sendControlView.frame), NSHeight(frameRect)) messagesController:messagesController];
        
     //   [self addTarget:self action:@selector(recordAudioMouseEntered:) forControlEvents:BTRControlEventMouseEntered];
     //   [self addTarget:self action:@selector(recordAudioMouseExited:) forControlEvents:BTRControlEventMouseExited];
     
    //    [_audioRecordView addTarget:self action:@selector(mouseUpInside:) forControlEvents:BTRControlEventMouseUpInside];
    //    [_audioRecordView addTarget:self action:@selector(mouseUpOutside:) forControlEvents:BTRControlEventMouseUpOutside];

        _ts = [[TMView alloc] initWithFrame:NSMakeRect(0, NSHeight(frameRect) - DIALOG_BORDER_WIDTH, NSWidth(frameRect), DIALOG_BORDER_WIDTH)];
        _ts.wantsLayer = YES;
        _ts.backgroundColor = DIALOG_BORDER_COLOR;
        
        [self addSubview:_ts];
        
    }
    
    return self;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_textContainerView setFrameSize:NSMakeSize(newSize.width, NSHeight(_textContainerView.frame))];
    [_attachmentsContainerView setFrameSize:NSMakeSize(newSize.width - 40, NSHeight(_attachmentsContainerView.frame))];
    [_attachment setFrameSize:NSMakeSize(NSWidth(_attachmentsContainerView.frame), NSHeight(_attachment.frame))];
    [_ts setFrameSize:NSMakeSize(newSize.width, NSHeight(_ts.frame))];
}

-(void)performSendMessage {

    [_messagesController sendMessage];

    [_sendControlView performSendAnimation];
    
}

-(void)cleanTextView {
    BOOL o = _textView.animates;
    _textView.animates = NO;
    [_textView setString:@""];
    _textView.animates = o;

}


-(void)resignalActions {
    [[_actionsView resignal:_sendControlView.type] startWithNext:^(id next) {
        
        if([next boolValue]) {
            [self updateTextViewSize];
            
            [_actionsView moveWithCAAnimation:NSMakePoint(NSMinX(_textView.frame) + self.textViewSize.width, NSMinY(_actionsView.frame)) animated:_actionsView.animates];
            
            
            if(_actionsView.animates) {
                
                _actionsView.layer.opacity = 0.0f;
                [_actionsView performCAShow:YES];
                
            }

        }
        
    }];
}

-(int)defTextViewHeight {
    int height = _textView.height % 2 == 1 ? _textView.height + 1 : _textView.height;
    
    height += NSMinY(_textView.frame) * 2;
    
    return height;
}

-(NSSize)textViewSize {
    return NSMakeSize(NSWidth(_textContainerView.frame) - NSWidth(_attachView.frame) - NSWidth(_sendControlView.frame) - NSWidth(_actionsView.frame) , NSHeight(_textView.frame));
}

-(void)updateTextViewSize {
    [_textView.animates ? [_textView animator] : _textView setFrameSize:self.textViewSize];
}


- (void) textViewHeightChanged:(id)textView height:(int)height animated:(BOOL)animated {
    
    height = self.defTextViewHeight;
    
    NSSize topSize = NSMakeSize(NSWidth(self.frame), (_actionState != TGModernMessagesBottomViewActionsState && _actionState != TGModernMessagesBottomViewBlockChat) ? _attachmentsHeight > 0 ? height + _attachmentsHeight : height : 58);
    
    NSSize bottomSize = NSMakeSize(NSWidth(self.frame), (_actionState != TGModernMessagesBottomViewActionsState && _actionState != TGModernMessagesBottomViewBlockChat) ? MAX(_bottomHeight,0) : 0);
    NSSize fullSize = NSMakeSize(NSWidth(self.frame), topSize.height + bottomSize.height);
    
    [self heightWithCAAnimation:NSMakeRect(0,0,NSWidth(self.frame), fullSize.height) animated:animated];
    [_textContainerView heightWithCAAnimation:NSMakeRect(0,0,NSWidth(self.frame), height) animated:animated];
    [_ts moveWithCAAnimation:NSMakePoint(NSMinX(_ts.frame),fullSize.height - NSHeight(_ts.frame)) animated:animated];
    [_attachmentsContainerView heightWithCAAnimation:NSMakeRect(NSMinX(_attachmentsContainerView.frame), NSMinY(_attachmentsContainerView.frame), NSWidth(_attachmentsContainerView.frame), _attachmentsHeight) animated:animated];
    [_attachmentsContainerView moveWithCAAnimation:NSMakePoint(20,topSize.height - NSHeight(_attachmentsContainerView.frame) -  defYOffset/2.0f) animated:animated];
    [_topContainerView moveWithCAAnimation:NSMakePoint(NSMinX(_topContainerView.frame),bottomSize.height) animated:animated];
    [_topContainerView heightWithCAAnimation:NSMakeRect(0, bottomSize.height, NSWidth(self.frame), topSize.height) animated:animated];
    
    
    [_botkeyboard moveWithCAAnimation:NSMakePoint(0, _bottomHeight > 0 ? 0 : -NSHeight(_botkeyboard.frame)) animated:animated];

    [_botkeyboard heightWithCAAnimation:NSMakeRect(0, 0, NSWidth(self.frame), bottomSize.height) animated:animated];
    
    if(_audioRecordView.superview) {
        [_audioRecordView moveWithCAAnimation:NSMakePoint(0, bottomSize.height) animated:animated];
    }
    
    
    [_messagesController bottomViewChangeSize:fullSize.height animated:animated];
    
    

}

- (BOOL) textViewEnterPressed:(TGModernGrowingTextView *)textView {
    
    [self performSendMessage];
    
    return YES;
}

-(void)updateTextType {
    [_sendControlView setType:_inputTemplate.type == TGInputMessageTemplateTypeEditMessage ? TGModernSendControlEditType :( _textView.string.length > 0 || _inputTemplate.forwardMessages.count > 0 ? TGModernSendControlSendType : TGModernSendControlRecordType)];
}

- (void) textViewTextDidChange:(TGModernGrowingTextView *)textView {
    
    [self updateTextType];
    
    [self saveInputText];
    
    [_messagesController recommendStickers];
    
    [self resignalActions];
    
    [self checkMentionsOrTags];
}


-(void)saveInputText {
    [[_inputTemplate updateSignalText:_textView.attributedString] startWithNext:^(NSArray *next){
        
        if(next.count == 2) {
            
            if([next[1] boolValue]) {
                [self resignalTextAttachments];
            }
            
        }
        
    }];
}

-(void)setActionState:(TGModernMessagesBottomViewState)actionState {
    [self setActionState:actionState animated:NO];
}

-(void)setActionState:(TGModernMessagesBottomViewState)state animated:(BOOL)animated {
    
    if(state == TGModernMessagesBottomViewNormalState) {
        if(_messagesController.conversation.type == DialogTypeSecretChat) {
            EncryptedParams *params = _messagesController.conversation.encryptedChat.encryptedParams;
            if(params.state != EncryptedAllowed) {
                state = TGModernMessagesBottomViewBlockChat;
            }
        }
        
        if(!_messagesController.conversation.canSendMessage || _messagesController.conversation.isInvisibleChannel)
            state = TGModernMessagesBottomViewBlockChat;
        
        [_blockChatView setBlockedText:_messagesController.conversation.blockedText];
    }

    
    TGModernMessagesBottomViewState ostate = _actionState;
    
    if(_actionState == state)
        return;
    
    _actionState = state;
    
    if(state == TGModernMessagesBottomViewActionsState) {
        [self addSubview:_messageActionsView positioned:NSWindowBelow relativeTo:_ts];
        [_messageActionsView performCAShow:animated];
    } else if(state == TGModernMessagesBottomViewBlockChat) {
        [self addSubview:_blockChatView positioned:NSWindowBelow relativeTo:_ts];
         [_blockChatView performCAShow:animated];
    } else if(state == TGModernMessagesBottomViewRecordAudio) {
        [self addSubview:_audioRecordView positioned:NSWindowBelow relativeTo:_ts];
        [_audioRecordView performCAShow:animated];
        
    }
    
    [_attachView setHidden:state == TGModernMessagesBottomViewRecordAudio];

    

    if(state != TGModernMessagesBottomViewNormalState && state != TGModernMessagesBottomViewRecordAudio)
        [_topContainerView removeFromSuperview:animated];
    else if(!_topContainerView.superview) {
        [self addSubview:_topContainerView positioned:NSWindowBelow relativeTo:_ts];
        [_topContainerView performCAShow:animated];
    }
    
    
    if(ostate == TGModernMessagesBottomViewActionsState) {
        [_messageActionsView removeFromSuperview:animated];
    }
    
    if(ostate == TGModernMessagesBottomViewBlockChat) {
        [_blockChatView removeFromSuperview:animated];
    }
    
    if(ostate == TGModernMessagesBottomViewRecordAudio) {
        [_audioRecordView removeFromSuperview:animated];
    }
    
    [self textViewHeightChanged:_textView height:_textView.height animated:animated];
}

- (void)setSectedMessagesCount:(NSUInteger)count deleteEnable:(BOOL)deleteEnable forwardEnable:(BOOL)forwardEnable {
    [_messageActionsView setSectedMessagesCount:count deleteEnable:deleteEnable forwardEnable:forwardEnable];
}


-(void)setAnimates:(BOOL)animates {
    _animates = animates;
    _textView.animates = animates;
    _actionsView.animates = animates;
    _sendControlView.animates = animates;
}

-(void)setInputTemplate:(TGInputMessageTemplate *)inputTemplate animated:(BOOL)animated {
    _inputTemplate = inputTemplate;
    
    
    BOOL oa = _animates;
    
    
    self.animates = animated;
    
    [_textView setAttributedString:inputTemplate.attributedString];

    [self resignalBotKeyboard:NO changeState:NO resignalAttachments:YES resignalKeyboard:YES];
    
    [self checkSecretChatState];
    [self refreshObservers];
    
    
    if(inputTemplate.type == TGInputMessageTemplateTypeSimpleText) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        [attr appendString:_messagesController.conversation.chat.isChannel && !_messagesController.conversation.chat.isMegagroup ? NSLocalizedString(@"Message.SendBroadcast", nil) : NSLocalizedString(@"Message.SendPlaceholder", nil) withColor:GRAY_TEXT_COLOR];
        [attr setFont:TGSystemFont([SettingsArchiver checkMaskedSetting:BigFontSetting] ? 15 : 13) forRange:attr.range];
        
        [_textView setPlaceholderAttributedString:attr];
    }
    
    self.animates = oa;
    
    [self setActionState:_actionState animated:animated];
    
    [self becomeFirstResponder];
    
}

-(void)refreshObservers {
    [Notification removeObserver:self];
    [Notification addObserver:self selector:@selector(_showOrHideBotKeyboardAction:) name:[Notification cAction:_messagesController.conversation action:@"botKeyboard"]];
    [Notification addObserver:self selector:@selector(_updateNotifySettings:) name:[Notification cAction:_messagesController.conversation action:@"notification"]];
}

-(void)checkSecretChatState {
    
    if(_messagesController.conversation.type == DialogTypeSecretChat) {
        NSUInteger dialogHash = _messagesController.conversation.cacheHash;
        EncryptedParams *params = _messagesController.conversation.encryptedChat.encryptedParams;
        stateHandler handler = ^(EncryptedState state) {
            if(dialogHash != _messagesController.conversation.cacheHash)
                return;
            
            [self setActionState:TGModernMessagesBottomViewNormalState animated:YES];
        };
        
        [params setStateHandler:handler];
    }

}


-(void)resignalTextAttachments {
    [self resignalBotKeyboard:NO changeState:NO resignalAttachments:YES resignalKeyboard:NO];
}


-(void)resignalBotKeyboard:(BOOL)forceShow changeState:(BOOL)changeState resignalAttachments:(BOOL)resignalAttachments resignalKeyboard:(BOOL)resignalKeyboard {
    
    
    [_attachDispose dispose];
    
    SSignal *attachSignal = [_attachment resignal:_messagesController.conversation animateSignal:[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        [subscriber putNext:@(self.animates)];
        
        return nil;
        
    }] template:_inputTemplate];
    
    SSignal *botSignal = [_botkeyboard resignalKeyboard:_messagesController forceShow:forceShow changeState:changeState];

    
    NSMutableArray *signals = [NSMutableArray array];
    
    if(resignalAttachments)
        [signals addObject:attachSignal];
    if(resignalKeyboard)
        [signals addObject:botSignal];
    
    
    
    
    _attachDispose = [[[SSignal combineSignals:signals] map:^id(NSArray *next) {
        
        if(resignalKeyboard && _sendControlView.type == TGModernSendControlEditType) {
            if(next.count == 1) {
                return @[@(0)];
            } else
                return @[next[0],@(0)];
        }
        
        return next;
    }] startWithNext:^(id next) {
        
        BOOL changed = NO;
        
        if(resignalAttachments) {
            if(_attachmentsHeight != [next[0] intValue]) {
                _attachmentsHeight = [next[0] intValue];
                changed = YES;
                
                if(_animates) {
                    CAAnimation *animation = [TMAnimations fadeWithDuration:0.2 fromValue:_attachmentsHeight > 0  ? 0.0f : 1.0f toValue:_attachmentsHeight > 0  ? 1.0f : 0.0f];
                    
                    [_attachmentsContainerView.layer addAnimation:animation forKey:@"opacity"];
                    
                }
                
                _attachmentsContainerView.layer.opacity = _attachmentsHeight > 0 ? 1.0f : 0.0f;
                
            }
        }
        
        
        
        if(resignalKeyboard) {
            if(_bottomHeight != [next[[next count] == 1 ? 0 : 1] intValue]) {
                
                int nextHeight = [next[[next count] == 1 ? 0 : 1] intValue];
                [_botkeyboard setFrame:NSMakeRect(0, nextHeight > 0 && _bottomHeight == 0 ? -nextHeight : nextHeight > _bottomHeight ? (_bottomHeight - nextHeight) : 0, NSWidth(self.frame), nextHeight < _bottomHeight > 0 ? _bottomHeight : nextHeight)];
                
                _bottomHeight = nextHeight;
                

                changed = YES;
                
                [_actionsView setActiveKeyboardButton:_bottomHeight > 0];
                
            }
        }
        

        if(changed)
            [self textViewHeightChanged:_textView height:NSHeight(_textView.frame) animated:_animates];

        
    }];

}


-(void)checkMentionsOrTags {
    
    
    @try {
        NSString *search = nil;
        NSString *string = _textView.string;
        NSRange selectedRange = _textView.selectedRange;
        
        TGHintViewShowType type = [TGMessagesHintView needShowHint:string selectedRange:selectedRange completeString:&string searchString:&search];
        
        
        if(_textView.string.length > 0 && [_textView.string hasPrefix:@"@"] && type != 0) {
            NSRange split = [_textView.string rangeOfString:@" "];
            if(split.location != NSNotFound && split.location != 1) {
                
                NSString *bot = [_textView.string substringWithRange:NSMakeRange(1,split.location-1)];
                
                TLUser *user = [UsersManager findUserByName:bot];
                
                if(user.isBot && user.isBotInlinePlaceholder) {
                    search = nil;
                }
            }
            
            
        }
        
        [_messagesController.hintView cancel];
        
        
        if(search != nil && ![string hasPrefix:@" "]) {
            
            
            NSString *check = [_textView.string substringWithRange:NSMakeRange(MAX((int)(selectedRange.location - 2),0),1)];
            
            
            void (^callback)(NSString *name, id object) = ^(NSString *name,id object) {
               
                NSRange range = NSMakeRange(selectedRange.location - search.length, search.length);
                if(![object isKindOfClass:[TLUser class]]) {
                    [_textView insertText:[name stringByAppendingString:@" "] replacementRange:range];
                } else {
                    TLUser *user = object;
                    [_textView replaceMention:user.username.length > 0 ? user.username : user.first_name username:user.username.length > 0 userId:user.n_id];
                }
           
            };
            
            
            if(type == TGHintViewShowMentionType) {
                [_messagesController.hintView showMentionPopupWithQuery:search conversation:_messagesController.conversation chat:_messagesController.conversation.chat allowInlineBot:[_textView.string rangeOfString:@"@"].location == 0 choiceHandler:callback];
                
            } else if(type == TGHintViewShowHashtagType && [check isEqualToString:@" "]) {
                
                [_messagesController.hintView showHashtagHintsWithQuery:search conversation:_messagesController.conversation peer_id:_messagesController.conversation.peer_id choiceHandler:callback];
                
            } else if(type == TGHintViewShowBotCommandType && [_textView.string rangeOfString:@"/"].location == 0) {
                if([_messagesController.conversation.user isBot] || _messagesController.conversation.fullChat.bot_info != nil) {
                    
                    
                    TL_conversation *conversation = _messagesController.conversation;
                    
                   __block  NSArray *info = @[];
                    
                    dispatch_block_t perform = ^{
                        if(_messagesController.conversation == conversation) {
                            [_messagesController.hintView showCommandsHintsWithQuery:search conversation:_messagesController.conversation botInfo:info choiceHandler:^(NSString *command, id object) {
                                callback(command, object);
                                [self performSendMessage];
                            }];
                        }
                    };
                    
                    if([_messagesController.conversation.user isBot]) {
                        
                        [[FullUsersManager sharedManager] requestUserFull:_messagesController.conversation.user withCallback:^(TLUserFull *userFull) {
                            if(userFull) {
                                info = @[userFull.bot_info];
                                perform();
                            }
                        }];
                    } else if(_messagesController.conversation.chat) {
                        [[ChatFullManager sharedManager] requestChatFull:_messagesController.conversation.chat.n_id withCallback:^(TLChatFull *chatFull) {
                            if(chatFull.bot_info) {
                                info = chatFull.bot_info;
                                perform();
                            }
                        }];
                    }
 
                }
            } else {
                [_messagesController.hintView hide];
            }
            
            
        } else if([_textView.string hasPrefix:@"@"] && _messagesController.conversation.type != DialogTypeSecretChat) {
            
            [_messagesController.hintView hide];
            
            NSString *value = _textView.string;
            
            NSRange split = [value rangeOfString:@" "];
            
            
            if(split.location != NSNotFound && split.location != 1) {
                NSString *bot = [value substringWithRange:NSMakeRange(1,split.location-1)];
                NSString *query = [value substringFromIndex:split.location];
                
                if([bot rangeOfString:@"\n"].location == NSNotFound) {
                    weak();
                    
                    [[_messagesController.hintView showContextPopupWithQuery:bot query:[query trim] conversation:_messagesController.conversation acceptHandler:^(TLUser *user){
                        // [weakSelf.textView setInline_placeholder:![query isEqualToString:@" "] ? nil : [weakSelf inline_placeholder:user]];
                         [weakSelf checkAndDisableSendingWithInlineBot:user animated:YES];
                    }] startWithNext:^(id next) {
                        
                        [_actionsView setInlineProgress:[next boolValue] ? 90 : 0];
                        
                    }];
                } else {
                    [self checkAndDisableSendingWithInlineBot:nil animated:YES];
                }
                
                
            } else {
                  [self checkAndDisableSendingWithInlineBot:nil animated:YES];
            }
            
            
        } else {
            [_messagesController.hintView hide];
        }
    } @catch (NSException *exception) {
        int bp = 0;
    }
   
}



-(void)checkAndDisableSendingWithInlineBot:(TLUser *)user animated:(BOOL)animated {
    
    if(user)
        [_sendControlView setType:TGModernSendControlInlineRequestType];
    else
        [self updateTextType];
    
    [self resignalActions];
}

-(void)_showOrHideBotKeyboardAction:(NSNotification *)notify {
    [self resignalBotKeyboard:NO changeState:notify == nil resignalAttachments:NO resignalKeyboard:YES];
}

-(void)_insertEmoji:(NSString *)emoji {
    [_textView insertText:emoji replacementRange:NSMakeRange(_textView.selectedRange.location, emoji.length + _textView.selectedRange.length)];
}

-(void)_updateNotifySettings:(NSNotification *)notify {
    [_actionsView setActiveSilentMode:!_messagesController.conversation.notify_settings.isSilent];
}

-(void)_changeSilentMode:(id)sender {
    int flags = _messagesController.conversation.notify_settings.flags;
    
    if(flags & PushEventMaskDisableChannelMessageNotification)
        flags &= ~PushEventMaskDisableChannelMessageNotification;
    else
        flags |= PushEventMaskDisableChannelMessageNotification;
    
    
    [_messagesController.conversation updateNotifySettings:[TL_peerNotifySettings createWithFlags:flags mute_until:_messagesController.conversation.notify_settings.mute_until sound:_messagesController.conversation.notify_settings.sound] serverSave:YES];
    
    [self _updateNotifySettings:nil];
    
}

-(void)_performSendAction {
    if(_sendControlView.type == TGModernSendControlSendType)
        [self performSendMessage];
    else if(_sendControlView.type == TGModernSendControlInlineRequestType)
        [_textView setAttributedString:[[NSAttributedString alloc] init]];
}

-(void)_startAudioRecord {
    [_audioRecordView setFrameOrigin:NSMakePoint(0, NSMinY(_topContainerView.frame))];
    [self setActionState:TGModernMessagesBottomViewRecordAudio animated:YES];
    [self.window makeFirstResponder:self];
    
    [_audioRecordView startRecord];
}
-(void)_stopAudioRecord  {
    [self setActionState:TGModernMessagesBottomViewNormalState animated:YES];
    [_audioRecordView stopRecord:NO];
    [_sendControlView setVoiceSelected:NO];
}

-(void)_sendAudioRecord {
    [self setActionState:TGModernMessagesBottomViewNormalState animated:YES];
    [_audioRecordView stopRecord:YES];
    [_sendControlView setVoiceSelected:NO];
}


-(void)mouseUp:(NSEvent *)theEvent {
    
    if(_actionState == TGModernMessagesBottomViewRecordAudio) {
        if([self mouse:[self.superview convertPoint:[theEvent locationInWindow] fromView:nil] inRect:self.frame]) {
            [self _sendAudioRecord];
        } else {
           [self _stopAudioRecord];
        }
    }
    
}
- (void)updateTrackingAreas {

    if (_trackingArea) {
        [self removeTrackingArea:_trackingArea];
        _trackingArea = nil;
    }
    
    NSUInteger options = (NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp | NSTrackingMouseMoved);
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                     options:options
                                                       owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
}



-(void)mouseDragged:(NSEvent *)theEvent {
    
     if(_actionState == TGModernMessagesBottomViewRecordAudio) {
        
        if([self mouse:[self.superview convertPoint:[theEvent locationInWindow] fromView:nil] inRect:self.frame]) {
            [_audioRecordView updateDesc:YES];
            [_sendControlView setVoiceSelected:YES];
        } else {
            [_audioRecordView updateDesc:NO];
            [_sendControlView setVoiceSelected:NO];
        }
    }
}


-(BOOL)becomeFirstResponder {
    return [_textView becomeFirstResponder];
}

-(void)dealloc {
    [Notification removeObserver:self];
}

-(void)paste:(id)sender {
    [_textView paste:sender];
}

-(void)selectInputTextByText:(NSString *)text {
    [_textView setSelectedRange:[_textView.string rangeOfString:text]];
}

-(void)setActiveEmoji:(BOOL)active {
    [_actionsView setActiveEmoji:active];
}

-(int)attachmentsCount {
    return 0;
}

-(void)addAttachment:(TGImageAttachment *)attachment {
    
}

@end
