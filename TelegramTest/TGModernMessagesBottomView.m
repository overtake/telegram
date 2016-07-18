//
//  TGModernMessagesBottomView.m
//  Telegram
//
//  Created by keepcoder on 11/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernMessagesBottomView.h"
#import "TGModernGrowingTextView.h"
#import "TGModernSendControlView.h"
#import "TGModernBottomAttachView.h"
#import "TGBottomActionsView.h"
#import "TGBottomTextAttachment.h"
#import "TGBottomKeyboardContainerView.h"

@interface TGModernMessagesBottomView () <TGModernGrowingDelegate> {
    TMView *_ts;
   
    id<SDisposable> _attachDispose;
}

@property (nonatomic,strong) TLUser *inlineBot;


@property (nonatomic,weak) MessagesViewController *messagesController;

@property (nonatomic,strong) TGModernGrowingTextView *textView;
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


@end

@implementation TGModernMessagesBottomView

- (void)drawRect:(NSRect)dirtyRect {
}
const float defYOffset = 12;

-(instancetype)initWithFrame:(NSRect)frameRect messagesController:(MessagesViewController *)messagesController {
    if(self = [super initWithFrame:frameRect]) {
        
        _attachmentsHeight = -1;
        _bottomHeight = 0;
        
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

        
        _ts = [[TMView alloc] initWithFrame:NSMakeRect(0, NSHeight(frameRect) - DIALOG_BORDER_WIDTH, NSWidth(frameRect), DIALOG_BORDER_WIDTH)];
        _ts.wantsLayer = YES;
        _ts.backgroundColor = DIALOG_BORDER_COLOR;
        
        [self addSubview:_ts];
        
        _attachment = [[TGBottomTextAttachment alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(_textContainerView.frame), 50)];
        [_attachmentsContainerView addSubview:_attachment];
       
        
        _sendControlView = [[TGModernSendControlView alloc] initWithFrame:NSMakeRect(NSWidth(_textContainerView.frame) - 60, 0, 60, NSHeight(_textContainerView.frame))];
        _sendControlView.wantsLayer = YES;
        
        
        _attachView = [[TGModernBottomAttachView alloc] initWithFrame:NSMakeRect(0, 0, 60, NSHeight(_textContainerView.frame)) messagesController:messagesController];
        _attachView.wantsLayer = YES;
        
        
        _actionsView = [[TGBottomActionsView alloc] initWithFrame:NSMakeRect(0, 0, 0, NSHeight(_textContainerView.frame)) messagesController:messagesController bottomController:self];
        _actionsView.wantsLayer = YES;
        
        
        _textView = [[TGModernGrowingTextView alloc] initWithFrame:NSMakeRect(NSWidth(_attachView.frame) , defYOffset, NSWidth(_textContainerView.frame)  - NSWidth(_attachView.frame) - NSWidth(_sendControlView.frame), NSHeight(_textContainerView.frame) - defYOffset*2)];
        _textView.delegate = self;
        
        [_textContainerView addSubview:_attachView];
        [_textContainerView addSubview:_textView];
        [_textContainerView addSubview:_actionsView];
        [_textContainerView addSubview:_sendControlView];
        
        
        _botkeyboard = [[TGBottomKeyboardContainerView alloc] initWithFrame:NSZeroRect];
        _botkeyboard.wantsLayer = YES;
       // _botkeyboard.layer.backgroundColor = [NSColor redColor].CGColor;
        [self addSubview:_botkeyboard];
    
        
    }
    
    return self;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_textContainerView setFrameSize:NSMakeSize(newSize.width, NSHeight(_textContainerView.frame))];
    [_attachmentsContainerView setFrameSize:NSMakeSize(newSize.width - NSMaxX(_attachView.frame) - 20, NSHeight(_attachmentsContainerView.frame))];
    [_attachment setFrameSize:NSMakeSize(NSWidth(_attachmentsContainerView.frame), NSHeight(_attachment.frame))];
    [_ts setFrameSize:NSMakeSize(newSize.width, NSHeight(_ts.frame))];
}

-(void)performSendMessage {
    
    [_messagesController sendMessage:_textView.string];

    [_sendControlView performSendAnimation];
    
}


-(void)resignalActions {
    [[_actionsView resignal:_sendControlView.type] startWithNext:^(id next) {
        
        if([next boolValue]) {
            [self updateTextViewSize];
            
            
            if(_actionsView.animates) {
                
                
                CABasicAnimation *pAnim = [CABasicAnimation animationWithKeyPath:@"position"];
                pAnim.duration = 0.2;
                pAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                pAnim.removedOnCompletion = YES;
                [pAnim setValue:@(CALayerPositionAnimation) forKey:@"type"];
                
                
                float presentX = NSMaxX(self.textView.frame);
                
                CALayer *presentLayer = (CALayer *)[_actionsView.layer presentationLayer];
                
                if(presentLayer && [_actionsView.layer animationForKey:@"position"]) {
                    presentX = [[presentLayer valueForKeyPath:@"frame.origin.x"] floatValue];
                }
                
                pAnim.fromValue = [NSValue valueWithPoint:NSMakePoint(presentX, NSMinY(_actionsView.frame))];
                pAnim.toValue = [NSValue valueWithPoint:NSMakePoint(NSMinX(_textView.frame) + self.textViewSize.width , NSMinY(_actionsView.frame))];
                
                
                CABasicAnimation *oAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
                oAnim.duration = 0.2;
                oAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                oAnim.removedOnCompletion = YES;
                [oAnim setValue:@(CALayerOpacityAnimation) forKey:@"type"];
                
                
                oAnim.fromValue = @(0.0f);
                oAnim.toValue = @(1.0f);
                
                [_actionsView.layer removeAnimationForKey:@"position"];
                
                [_actionsView.layer addAnimation:pAnim forKey:@"position"];
                [_actionsView.layer addAnimation:oAnim forKey:@"opacity"];
                
                [_actionsView.layer setOpacity:1.0f];
                [_actionsView.layer setPosition:NSMakePoint(NSMinX(_textView.frame) + self.textViewSize.width, self.defTextViewHeight - NSHeight(_actionsView.frame))];
                
                [_actionsView.animator setFrameOrigin:NSMakePoint(NSMinX(_textView.frame) + self.textViewSize.width, NSMinY(_actionsView.frame))];
                
                
            }
            [_actionsView setFrameOrigin:NSMakePoint(NSMinX(_textView.frame) + self.textViewSize.width, NSMinY(_actionsView.frame))];

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
    
    
    
    NSSize topSize = NSMakeSize(NSWidth(self.frame), _attachmentsHeight > 0 ? height + _attachmentsHeight : height);
    
    NSSize bottomSize = NSMakeSize(NSWidth(self.frame), MAX(_bottomHeight,0));
    NSSize fullSize = NSMakeSize(NSWidth(self.frame), topSize.height + bottomSize.height);
    
    [self heightWithCAAnimation:NSMakeRect(0,0,NSWidth(self.frame), fullSize.height) animated:animated];
    [_textContainerView heightWithCAAnimation:NSMakeRect(0,0,NSWidth(self.frame), height) animated:animated];
    [_ts moveWithCAAnimation:NSMakePoint(NSMinX(_ts.frame),fullSize.height - NSHeight(_ts.frame)) animated:animated];
    [_attachmentsContainerView moveWithCAAnimation:NSMakePoint(NSMaxX(_attachView.frame),topSize.height - NSHeight(_attachmentsContainerView.frame) -  defYOffset/2.0f) animated:animated];
    [_topContainerView moveWithCAAnimation:NSMakePoint(NSMinX(_topContainerView.frame),bottomSize.height) animated:animated];
    [_topContainerView heightWithCAAnimation:NSMakeRect(0, bottomSize.height, NSWidth(self.frame), topSize.height) animated:animated];
    [_botkeyboard heightWithCAAnimation:NSMakeRect(0, 0, NSWidth(self.frame), bottomSize.height) animated:animated];
    
    
    [_messagesController bottomViewChangeSize:fullSize.height animated:animated];
    

}

- (BOOL) textViewEnterPressed:(TGModernGrowingTextView *)textView {
    
    [self performSendMessage];
    
    return YES;
}

- (void) textViewTextDidChange:(TGModernGrowingTextView *)textView {
    [_sendControlView setType:textView.string.length > 0 ? TGModernSendControlSendType : TGModernSendControlRecordType];
    
    [self saveInputText];
    
    [_messagesController recommendStickers];
    
    [self resignalActions];
    
    [self checkMentionsOrTags];
}


-(void)saveInputText {
    [[_inputTemplate updateSignalText:_textView.string] startWithNext:^(NSArray *next){
        
        if(next.count == 2) {
            
            if([next[1] boolValue]) {
                [self resignalTextAttachments];
            }
            
        }
        
    }];
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
    
    
    [self resignalBotKeyboard:NO changeState:NO resignalAttachments:YES resignalKeyboard:YES];
    
    [Notification removeObserver:self];
    [Notification addObserver:self selector:@selector(_showOrHideBotKeyboardAction:) name:[Notification cAction:_messagesController.conversation action:@"botKeyboard"]];
    
    [_textView setString:inputTemplate.text];
    
    if(inputTemplate.type == TGInputMessageTemplateTypeSimpleText) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        [attr appendString:_messagesController.conversation.chat.isChannel && !_messagesController.conversation.chat.isMegagroup ? NSLocalizedString(@"Message.SendBroadcast", nil) : NSLocalizedString(@"Message.SendPlaceholder", nil) withColor:GRAY_TEXT_COLOR];
        [attr setFont:TGSystemFont([SettingsArchiver checkMaskedSetting:BigFontSetting] ? 15 : 13) forRange:attr.range];
        
        [_textView setPlaceholderAttributedString:attr];
    }
    
    self.animates = oa;
    
}


-(void)resignalTextAttachments {
    [self resignalBotKeyboard:NO changeState:NO resignalAttachments:YES resignalKeyboard:NO];
}


-(void)resignalBotKeyboard:(BOOL)forceShow changeState:(BOOL)changeState resignalAttachments:(BOOL)resignalAttachments resignalKeyboard:(BOOL)resignalKeyboard {
    
    
    [_attachDispose dispose];
    
    SSignal *attachSignal = [_attachment resignal:_messagesController.conversation animateSignal:[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        [subscriber putNext:@(self.animates)];
        
        return nil;
        
    }]];
    
    SSignal *botSignal = [_botkeyboard resignalKeyboard:_messagesController forceShow:forceShow changeState:changeState];

    
    NSMutableArray *signals = [NSMutableArray array];
    
    if(resignalAttachments)
        [signals addObject:attachSignal];
    if(resignalKeyboard)
        [signals addObject:botSignal];
    
    
    _attachDispose = [[SSignal combineSignals:signals] startWithNext:^(id next) {
        
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
                _bottomHeight = [next[[next count] == 1 ? 0 : 1] intValue];
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
        
        _inlineBot = nil;
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
                    
                    // [_messagesController.hintView showCommandsHintsWithQuery:search conversation:_messagesController.conversation botInfo:_userFull ? @[_userFull.bot_info] : _messagesController.conversation.fullChat.bot_info choiceHandler:^(NSString *command) {
                    //     callback(command);
                    //      [self sendButtonAction];
                    //   }];
                    
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
                    
                    [_messagesController.hintView showContextPopupWithQuery:bot query:[query trim] conversation:_messagesController.conversation acceptHandler:^(TLUser *user){
                        // [weakSelf.textView setInline_placeholder:![query isEqualToString:@" "] ? nil : [weakSelf inline_placeholder:user]];
                        // weakSelf.inlineBot = user;
                        // [weakSelf checkAndDisableSendingWithInlineBot:user animated:YES];
                    }];
                } else {
                    //[self checkAndDisableSendingWithInlineBot:nil animated:YES];
                }
                
                
            } else {
                //  [self checkAndDisableSendingWithInlineBot:nil animated:YES];
            }
            
            
        } else {
            [_messagesController.hintView hide];
            // [self setProgress:NO];
        }
    } @catch (NSException *exception) {
        int bp = 0;
    }
   
}

-(void)_showOrHideBotKeyboardAction:(NSNotification *)notify {
    [self resignalBotKeyboard:NO changeState:notify == nil resignalAttachments:NO resignalKeyboard:YES];
}


-(void)dealloc {
    [Notification removeObserver:self];
}

@end
