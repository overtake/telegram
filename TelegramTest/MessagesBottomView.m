//
//  MessagesBottomView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessagesBottomView.h"
#import "MessagesViewController.h"
#import "NSString+Extended.h"
#import "FileUtils.h"
#import "Telegram.h"
#import "MessageInputGrowingTextView.h"
#import <Quartz/Quartz.h>
#import "Rebel/Rebel.h"
#import "MapPanel.h"
#import "TGTimer.h"

#import "POPLayerExtras.h"

#import "TMAudioRecorder.h"
#import "TGSendTypingManager.h"

#import "NSString+FindURLs.h"
#import "TGAttachImageElement.h"
#import "TGMentionPopup.h"
#import "MessageReplyContainer.h"
#import "TGForwardContainer.h"
#import "TGHashtagPopup.h"
#import "TGWebpageAttach.h"
#import "TGImageAttachmentsController.h"
#import "FullUsersManager.h"
#import "TGBotCommandsPopup.h"
#import "TGBotCommandsKeyboard.h"
#import "BlockedUsersManager.h"
#import "TGModalGifSearch.h"
#import "TGRecordedAudioPreview.h"
#import "TGModernESGViewController.h"
#import "TGMenuItemPhoto.h"
@interface MessagesBottomView()<TGImageAttachmentsControllerDelegate>

@property (nonatomic, strong) TMView *actionsView;
@property (nonatomic, strong) TMView *normalView;
@property (nonatomic, strong) TMView *secretInfoView;



@property (nonatomic, strong) BTRButton *attachButton;
@property (nonatomic, strong) BTRButton *smileButton;
@property (nonatomic, strong) BTRButton *botKeyboardButton;
@property (nonatomic, strong) BTRButton *botCommandButton;
@property (nonatomic, strong) BTRButton *channelAdminButton;
@property (nonatomic, strong) BTRButton *secretTimerButton;
@property (nonatomic, strong) BTRButton *silentModeButton;


@property (nonatomic, strong) NSProgressIndicator *progressView;
@property (nonatomic,assign,setter=setProgress:) BOOL isProgress;

@property (nonatomic, strong) TMButton *sendButton;


@property (nonatomic, strong) TGTimer *recordTimer;
@property (nonatomic) int recordTime;
@property (nonatomic, strong) BTRButton *recordAudioButton;
@property (nonatomic, strong) TMCircleLayer *recordCircleLayer;
@property (nonatomic, strong) TMTextLayer *recordDurationLayer;
@property (nonatomic, strong) TMTextLayer *recordHelpLayer;

@property (nonatomic, strong) TMTextButton *deleteButton;
@property (nonatomic, strong) TMTextButton *messagesSelectedCount;
@property (nonatomic, strong) TMTextButton *forwardButton;

@property (nonatomic, strong) TMTextField *encryptedStateTextField;

@property (nonatomic,strong) NSMenu *attachMenu;
@property (nonatomic, strong) TMMenuPopover *menuPopover;

@property (nonatomic,strong) NSMutableArray *attachments;

@property (nonatomic,strong) NSMutableArray *attachmentsIgnore;

@property (nonatomic,strong) MessageReplyContainer *replyContainer;


@property (nonatomic,strong) TGForwardContainer *fwdContainer;

@property (nonatomic,strong) TGWebpageAttach *webpageAttach;

@property (nonatomic,strong) TGBotCommandsKeyboard *botKeyboard;

@property (nonatomic,strong,readonly) TGImageAttachmentsController *imageAttachmentsController;


@property (nonatomic,strong) TLUserFull *userFull;
@property (nonatomic,strong) TLChatFull *chatFull;


@property (nonatomic,strong) TGRecordedAudioPreview *recordedAudioPreview;

@property (nonatomic,strong) BTRButton *removeAudioRecordButton;

@property (nonatomic,strong) TGInputMessageTemplate *template;

@property (nonatomic,strong) TLUser *inlineBot;

@property (nonatomic,strong) MessageReplyContainer *editMessageContainer;

@end

@implementation MessagesBottomView

- (id)initWithFrame:(NSRect)frameRect {
    
    self = [super initWithFrame:frameRect];
    if(self) {
        [self setWantsLayer:YES];
        
        self.layer.backgroundColor = NSColorFromRGB(0xfafafa).CGColor;
        
        self.attachments = [[NSMutableArray alloc] init];
        
        self.attachmentsIgnore = [[NSMutableArray alloc] init];

        [self setState:MessagesBottomViewNormalState animated:NO];
        
        [self normalView];
    }
    return self;
}

- (void)addSubview:(NSView *)aView {
    [super addSubview:aView];
    [aView setHidden:YES];
}

- (void)didChangeBlockedUser:(NSNotification *)notification {
    
    TL_contactBlocked *contact = notification.userInfo[KEY_USER];
    
    if(self.dialog.user.n_id != contact.user_id || self.dialog.user.isBot)
        return;

    
    if(self.dialog && self.dialog.type == DialogTypeUser) {
        [self setState:MessagesBottomViewNormalState animated:YES];
    }
}

-(void)didChannelUpdatedFlags:(NSNotification *)notification {
    TLChat *chat = notification.userInfo[KEY_CHAT];
    
    if(chat.n_id == self.dialog.chat.n_id) {
        
        [self setState:self.stateBottom animated:NO];
        
    }
}

-(void)setProgress:(BOOL)progress {
    _isProgress = progress;
    
    [self.progressView setHidden:!progress];
    
    if(progress) {
        [self.progressView startAnimation:self];
    } else {
        [self.progressView stopAnimation:self];
    }
    
    [self updateBotButtons];
    
}

-(void)didChangeAttachmentsCount:(int)futureCount {
    
    if(futureCount == 0 && _imageAttachmentsController.isShown) {
        [_imageAttachmentsController hide:YES deleteItems:NO];
        [self updateBottomHeight:YES];
    } else if(futureCount > 0 && !_imageAttachmentsController.isShown) {
        [_imageAttachmentsController show:_dialog animated:YES];
        [self updateBottomHeight:YES];
    }
    
    [self  TMGrowingTextViewTextDidChange:nil];
}

-(void)addAttachment:(TGImageAttachment *)attachment {
    
    [_imageAttachmentsController addItems:@[attachment] animated:YES];
    
    
    [self updateBottomHeight:YES];
    
}


-(NSUInteger)attachmentsCount {
    return _imageAttachmentsController.attachments.count;
}

-(void)closeAttachments {
    [_imageAttachmentsController hide:YES deleteItems:YES];
    
    [self updateBottomHeight:YES];
}

- (void)dealloc {
    [Notification removeObserver:self];
}

-(void)hideBotKeyboard:(NSNotification *)notification {
    [self botKeyboardButtonAction:_botKeyboardButton];
}

-(void)botKeyboardNotification:(NSNotification *)notification
{
    [self checkBotKeyboard:YES animated:YES forceShow:YES];
}

- (void)setDialog:(TL_conversation *)dialog {
    self->_dialog = dialog;
    
    _template = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:_dialog.peer_id];
    
    _inlineBot = nil;
    
    self.botStartParam = nil;
    
    [self setOnClickToLockedView:nil];
    
    [Notification removeObserver:self];
    
    [Notification addObserver:self selector:@selector(botKeyboardNotification:) name:[Notification notificationNameByDialog:dialog action:@"botKeyboard"]];
    
    [Notification addObserver:self selector:@selector(hideBotKeyboard:) name:[Notification notificationNameByDialog:dialog action:@"hideBotKeyboard"]];
    [Notification addObserver:self selector:@selector(updateReplyMessage:) name:[Notification notificationNameByDialog:dialog action:@"reply"]];
    [Notification addObserver:self selector:@selector(updateNotifySettings:) name:[Notification notificationNameByDialog:dialog action:@"notification"]];
    [Notification addObserver:self selector:@selector(didChangeBlockedUser:) name:USER_BLOCK];
    [Notification addObserver:self selector:@selector(didChannelUpdatedFlags:) name:CHAT_FLAGS_UPDATED];
    //botKeyboard
    
    
    if(self.dialog.type == DialogTypeSecretChat) {
        weak();
        ;
        
        __block NSUInteger dialogHash = self.dialog.cacheHash;
        __block EncryptedParams *params = self.dialog.encryptedChat.encryptedParams;
        __block stateHandler handler = ^(EncryptedState state) {
            if(dialogHash != weakSelf.dialog.cacheHash)
                return;
            
            [self setState:MessagesBottomViewNormalState animated:NO];
        };
        
        [params setStateHandler:handler];
        handler(params.state);
        
        [self setForwardEnabled:NO];
    } else if(self.dialog.type == DialogTypeBroadcast) {
        [self setForwardEnabled:NO];
    } else {
         [self setForwardEnabled:YES];
    }
    
    _userFull = nil;
    _chatFull = nil;
    
    [_channelAdminButton setSelected:NO];
    [self channelAdminButtonAction:_channelAdminButton];
    
    [self updateBotButtons];
    
   
    
    [self checkReplayMessage:YES animated:NO];
    
    [self checkFwdMessages:YES animated:NO];
    
    
    [self updateStopRecordControls];
    
    [self silentModeButtonActtion:nil];
    
    if(self.dialog.type == DialogTypeUser && self.dialog.user.isBot) {
        
        
        [[FullUsersManager sharedManager] requestUserFull:self.dialog.user withCallback:^(TLUserFull *userFull) {
            
            _userFull = userFull;
            
            [self updateBotButtons];
            
        }];
        
        
    } else if(self.dialog.type == DialogTypeChat || self.dialog.type == DialogTypeChannel) {
        [[ChatFullManager sharedManager] requestChatFull:self.dialog.chat.n_id force:(self.dialog.fullChat.class == [TL_chatFull_old29 class] && !self.dialog.fullChat.isLastLayerUpdated) || dialog.type == DialogTypeChannel withCallback:^(TLChatFull * chatFull) {
            
            _chatFull = chatFull;

            [self updateBotButtons];
            
        }];
    }
    
    [_imageAttachmentsController show:_dialog animated:NO];
    
    [self TMGrowingTextViewHeightChanged:self.inputMessageTextField height:NSHeight(self.inputMessageTextField.containerView.frame) cleared:NO];

    
    
    [self setHiddenRecoderControllers];
    
    
}

-(void)setMessagesViewController:(MessagesViewController *)controller {
    _messagesViewController = controller;
    _inputMessageTextField.controller = controller;
}

-(void)updateBotButtons {
    
    
    
    if(self.dialog.type == DialogTypeUser) {
        [self.botCommandButton setHidden:!self.dialog.user.isBot];
    } else if(self.dialog.type == DialogTypeChat || (self.dialog.type == DialogTypeChannel && self.dialog.chat.isMegagroup)) {
        [self.botCommandButton setHidden:_chatFull.bot_info.count == 0];
    } else
        [self.botCommandButton setHidden:YES];
    
    [_silentModeButton setHidden:self.dialog.type != DialogTypeChannel || self.dialog.chat.isMegagroup || self.inputMessageString.length > 0];
    
    
    if(!_botCommandButton.isHidden)
    {
        [_botCommandButton setHidden:self.inputMessageString.length != 0];
        
        [_botCommandButton setFrameOrigin:NSMakePoint(self.inputMessageTextField.containerView.frame.size.width - (_botKeyboardButton.isHidden ? 60 : 90), NSMinY(_botKeyboardButton.frame))];
        
    }
    
    [_channelAdminButton setHidden:!self.dialog.canSendChannelMessageAsAdmin || (!self.dialog.canSendChannelMessageAsUser && self.dialog.canSendChannelMessageAsAdmin)];
    
    
    if(!_channelAdminButton.isHidden) {
        [_channelAdminButton setFrameOrigin:NSMakePoint(self.inputMessageTextField.containerView.frame.size.width - (_botCommandButton.isHidden ? 60 : 90), NSMinY(_channelAdminButton.frame))];

    }
    
    if(!_silentModeButton.isHidden) {
        
        int defadd = _channelAdminButton.isHidden ? 0 : 30;
        
        [_silentModeButton setFrameOrigin:NSMakePoint(self.inputMessageTextField.containerView.frame.size.width - (_botCommandButton.isHidden ? 60+defadd : 90+defadd), NSMinY(_silentModeButton.frame))];
    }
    
    
    [_secretTimerButton setHidden:self.dialog.type != DialogTypeSecretChat];
    
    
    [_botCommandButton setHidden:_botCommandButton.isHidden || self.isProgress];
    [_channelAdminButton setHidden:_channelAdminButton.isHidden || self.isProgress];
    [_secretTimerButton setHidden:_secretTimerButton.isHidden || self.isProgress];
    [_smileButton setHidden:self.isProgress];
}

- (TMView *)actionsView {
    if(self->_actionsView)
        return self->_actionsView;
    
    weak();
    
    self->_actionsView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height - 1)];
    [self.actionsView setWantsLayer:YES];
    [self.actionsView setAutoresizesSubviews:YES];
    [self.actionsView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    
    self.actionsView.backgroundColor = [NSColor whiteColor];
    
    self.deleteButton = [TMTextButton standartButtonWithTitle:NSLocalizedString(@"Messages.Selected.Delete", nil) standartImage:image_MessageActionDeleteActive() disabledImage:image_MessageActionDelete()];
    
    [self.deleteButton setAutoresizingMask:NSViewMaxXMargin ];
    [self.deleteButton setTapBlock:^{
        [weakSelf.messagesViewController deleteSelectedMessages];
    }];
    self.deleteButton.disableColor = NSColorFromRGB(0xa1a1a1);
    [self.actionsView addSubview:self.deleteButton];
    
    
    self.messagesSelectedCount = [TMTextButton standartUserProfileNavigationButtonWithTitle:@""];
    self.messagesSelectedCount.textColor = DARK_BLACK;
    self.messagesSelectedCount.font = TGSystemFont(14);
    [self.messagesSelectedCount setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
    [self.actionsView addSubview:self.messagesSelectedCount];
    
    self.forwardButton = [TMTextButton standartButtonWithTitle:NSLocalizedString(@"Messages.Selected.Forward", nil) standartImage:image_MessageActionForwardActive() disabledImage:image_MessageActionForward()];
    
    [self.forwardButton setAutoresizingMask:NSViewMinXMargin];
    self.forwardButton.disableColor = NSColorFromRGB(0xa1a1a1);
    

    [self.forwardButton setTapBlock:^{
        [weakSelf.messagesViewController showForwardMessagesModalView];
    }];
     
     [self.actionsView setDrawBlock:^{
        [weakSelf.forwardButton setFrameOrigin:NSMakePoint(weakSelf.bounds.size.width - weakSelf.forwardButton.bounds.size.width - 22, roundf((weakSelf.bounds.size.height - weakSelf.deleteButton.bounds.size.height) / 2))];
        [weakSelf.deleteButton setFrameOrigin:NSMakePoint(30, roundf((weakSelf.bounds.size.height - weakSelf.deleteButton.bounds.size.height) / 2) )];
        [weakSelf.messagesSelectedCount setCenterByView:weakSelf.actionsView];
    }];
     

    
    [self.actionsView addSubview:self.forwardButton];
    
    return self.actionsView;
}

- (void)setForwardEnabled:(BOOL)forwardEnabled {
    self->_forwardEnabled = forwardEnabled;
    [self.forwardButton setDisable:!forwardEnabled];
}

-(void)updateReplyMessage:(NSNotification *)notification {
    [self updateReplayMessage:YES animated:YES];
}

-(void)updateReplayMessage:(BOOL)updateHeight animated:(BOOL)animated {
    [self checkReplayMessage:updateHeight animated:animated];
}

-(void)updateFwdMessage:(BOOL)updateHeight animated:(BOOL)animated {
    [self checkFwdMessages:updateHeight animated:animated];
}

- (void)setSectedMessagesCount:(NSUInteger)count enable:(BOOL)enable {
    if(count == 0) {
        [self.messagesSelectedCount setHidden:YES];
        [self.forwardButton setDisable:YES];
        [self.deleteButton setDisable:YES];
        return;
    } else {
        if(self.forwardEnabled)
            [self.forwardButton setDisable:NO];
        
        
        
        [self.deleteButton setDisable:!enable];
    }
    
    [self.messagesSelectedCount setHidden:NO];
    
    [self.messagesSelectedCount setStringValue:[NSString stringWithFormat:NSLocalizedString(count == 1 ? @"Edit.selectMessage" : @"Edit.selectMessages", nil), count]];
    [self.messagesSelectedCount sizeToFit];
    [self.messagesSelectedCount setFrameOrigin:NSMakePoint(roundf((self.bounds.size.width - self.messagesSelectedCount.bounds.size.width) /2), roundf((self.bounds.size.height - self.messagesSelectedCount.bounds.size.height)/2))];
}

- (TMView *)blockSecretView {
    TMView *bottomView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height - 1)];
    [bottomView setAutoresizingMask:NSViewWidthSizable];
//    [bottomView setBackgroundColor:NSColorFromRGB(0xfafafa)];
    
    TMTextField *secretBlockTextField = [[TMTextField alloc] initWithFrame:NSMakeRect(0, -15, bottomView.frame.size.width, bottomView.frame.size.height)];
    
    [secretBlockTextField setStringValue:@"...."];
    [secretBlockTextField setBackgroundColor:NSColorFromRGB(0xfafafa)];
    [secretBlockTextField setTextColor:NSColorFromRGB(0x010101)];
    [bottomView addSubview:secretBlockTextField];
    [secretBlockTextField setEditable:NO];
    [secretBlockTextField setEnabled:NO];
    [secretBlockTextField setSelectable:NO];
    [secretBlockTextField setBordered:NO];
    [secretBlockTextField setAlignment:NSCenterTextAlignment];
    [secretBlockTextField setAutoresizingMask:NSViewWidthSizable];
    //[bottomView setBackgroundColor:NSColorFromRGB(0xfafafa)];
    return bottomView;
}

- (TMView *)normalView {
    if(self->_normalView)
        return self->_normalView;
    
    self->_normalView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height - 1)];
    [self.normalView setWantsLayer:YES];
    
    
  //  [self.normalView setBackgroundColor:NSColorFromRGB(0xfafafa)];
    [self.normalView setAutoresizesSubviews:YES];
    [self.normalView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
//    [self.normalView setBorder:TMViewBorderTop];
//    [self.normalView setBorderColor:GRAY_BORDER_COLOR];
    
    
    self.inputMessageTextField = [[MessageInputGrowingTextView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
    [self.inputMessageTextField setEditable:YES];
    [self.inputMessageTextField setRichText:NO];
    _inputMessageTextField.controller = _messagesViewController;
 //   [self.inputMessageTextField.scrollView setFrameSize:NSMakeSize(100-30,100-10)];

    
    self.attachButton = [[BTRButton alloc] initWithFrame:NSMakeRect(16, 11, image_BottomAttach().size.width, image_BottomAttach().size.height)];
    
    [self.attachButton setFrameOrigin:NSMakePoint(21, roundf((self.bounds.size.height - self.attachButton.bounds.size.height) / 2) - 3)];
    
    [self.attachButton setBackgroundImage:image_BottomAttach() forControlState:BTRControlStateNormal];
    [self.attachButton setBackgroundImage:image_AttachHighlighted() forControlState:BTRControlStateSelected];
    [self.attachButton setBackgroundImage:image_AttachHighlighted() forControlState:BTRControlStateSelected | BTRControlStateHover];
    [self.attachButton setBackgroundImage:image_AttachHighlighted() forControlState:BTRControlStateHighlighted];
    [self.attachButton addTarget:self action:@selector(attachButtonPressed) forControlEvents:BTRControlEventMouseEntered];
    [self.attachButton addTarget:self action:@selector(showMediaAttachPanel) forControlEvents:BTRControlEventMouseDownInside];
    
    [self.normalView addSubview:self.attachButton];
    
    self.sendButton = [[TMButton alloc] initWithFrame:NSZeroRect];
    [self.sendButton setAutoresizesSubviews:YES];
    [self.sendButton setAutoresizingMask:NSViewMinXMargin];
    [self.sendButton setTarget:self selector:@selector(sendButtonAction)];
    [self.sendButton setText:NSLocalizedString(@"Message.Send", nil)];
    [self.sendButton setTextFont:TGSystemMediumFont(14)];
    NSSize size = [self.sendButton sizeOfText];
    [self.sendButton setFrameSize:size];
    [self.sendButton setFrameOrigin:NSMakePoint(self.bounds.size.width - size.width - 17, 19)];
    [self.normalView addSubview:self.sendButton];
    
    self.recordAudioButton = [[BTRButton alloc] initWithFrame:NSZeroRect];
    [self.recordAudioButton setAutoresizingMask:NSViewMinXMargin];
    [self.recordAudioButton setBackgroundImage:image_VoiceMic() forControlState:BTRControlStateNormal];
    [self.recordAudioButton setBackgroundImage:image_VoiceMicHighlighted2() forControlState:BTRControlStateHover];
    [self.recordAudioButton setBackgroundImage:image_VoiceMicHighlighted() forControlState:BTRControlStateHighlighted];
    [self.recordAudioButton setBackgroundImage:image_VoiceMicHighlighted() forControlState:BTRControlStateSelected];
    [self.recordAudioButton setBackgroundImage:image_VoiceMicHighlighted() forControlState:BTRControlStateSelected | BTRControlStateHover];
    [self.recordAudioButton setFrameSize:image_VoiceMicHighlighted().size];
    [self.recordAudioButton setFrameOrigin:NSMakePoint(self.bounds.size.width - self.recordAudioButton.bounds.size.width - 26, roundf((self.bounds.size.height - self.recordAudioButton.bounds.size.height) / 2.f) - 2)];
    [self.recordAudioButton addTarget:self action:@selector(startRecord:) forControlEvents:BTRControlEventMouseDownInside];
    [self.recordAudioButton addTarget:self action:@selector(stopRecordInside:) forControlEvents:BTRControlEventMouseUpInside];
    [self.recordAudioButton addTarget:self action:@selector(stopRecordOutside:) forControlEvents:BTRControlEventMouseUpOutside];
    
    [self addTarget:self action:@selector(recordAudioMouseEntered:) forControlEvents:BTRControlEventMouseEntered];
    [self addTarget:self action:@selector(recordAudioMouseExited:) forControlEvents:BTRControlEventMouseExited];
    
    

    [self.normalView addSubview:self.recordAudioButton];
    
    self.recordCircleLayer = [TMCircleLayer layer];
    self.recordCircleLayer.contentsScale = self.normalView.layer.contentsScale;
    [self.recordCircleLayer setFillColor:NSColorFromRGB(0xf36f75)];
    [self.recordCircleLayer setRadius:17];
    [self.recordCircleLayer setFrameOrigin:CGPointMake(18, roundf((self.bounds.size.height - self.recordCircleLayer.bounds.size.height) / 2))];
    [self.recordCircleLayer setNeedsDisplay];
    [self.normalView.layer addSublayer:self.recordCircleLayer];
    
    self.recordDurationLayer = [TMTextLayer layer];
    [self.recordDurationLayer disableActions];
    self.recordDurationLayer.contentsScale = self.normalView.layer.contentsScale;
    [self.recordDurationLayer setTextColor:[NSColor blackColor]];
    [self.recordDurationLayer setTextFont:TGSystemFont(14)];
    [self.recordDurationLayer setString:@"00:34,45"];
    [self.recordDurationLayer sizeToFit];
    [self.recordDurationLayer setFrameOrigin:CGPointMake(42, roundf( (self.bounds.size.height - self.recordDurationLayer.bounds.size.height) / 2.f) - 1)];
    [self.normalView.layer addSublayer:self.recordDurationLayer];
    
    self.recordHelpLayer = [TMTextLayer layer];
    [self.recordHelpLayer disableActions];
    self.recordHelpLayer.wrapped = YES;
    self.recordHelpLayer.contentsScale = self.normalView.layer.contentsScale;
    [self.recordHelpLayer setTextFont:TGSystemFont(14)];
    [self.normalView.layer addSublayer:self.recordHelpLayer];

    int offsetX = self.textFieldXOffset;
    
    self.inputMessageTextField.containerView.autoresizesSubviews = YES;
    self.inputMessageTextField.containerView.autoresizingMask = NSViewWidthSizable;
    
    self.inputMessageTextField.containerView.frame = NSMakeRect(offsetX, 11, self.bounds.size.width - offsetX - self.sendButton.frame.size.width - 33, 30);
    self.inputMessageTextField.growingDelegate = self;
    [self.inputMessageTextField textDidChange:nil];
    
    [self.normalView addSubview:self.inputMessageTextField.containerView];
    
    self.smileButton = [[BTRButton alloc] initWithFrame:NSMakeRect(self.inputMessageTextField.containerView.frame.size.width - 30, 7, image_smile().size.width, image_smile().size.height)];
    [self.smileButton setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
    [self.smileButton.layer disableActions];
    [self.smileButton setBackgroundImage:image_smile() forControlState:BTRControlStateNormal];
    [self.smileButton setBackgroundImage:image_smileHover() forControlState:BTRControlStateHover];
    [self.smileButton setBackgroundImage:image_smileActive() forControlState:BTRControlStateHighlighted];
    [self.smileButton setBackgroundImage:image_smileActive() forControlState:BTRControlStateSelected | BTRControlStateHover];
    [self.smileButton setBackgroundImage:image_smileActive() forControlState:BTRControlStateSelected];
    
    
    
    self.botKeyboardButton = [[BTRButton alloc] initWithFrame:NSMakeRect(self.inputMessageTextField.containerView.frame.size.width - 60, 7, image_botKeyboard().size.width, image_botKeyboard().size.height)];
    [self.botKeyboardButton setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
    [self.botKeyboardButton.layer disableActions];
    
    [self.botKeyboardButton addTarget:self action:@selector(botKeyboardButtonAction:) forControlEvents:BTRControlEventMouseDownInside];
    

    [self.inputMessageTextField.containerView addSubview:self.botKeyboardButton];
    
    self.botCommandButton = [[BTRButton alloc] initWithFrame:NSMakeRect(self.inputMessageTextField.containerView.frame.size.width - 90, 7, image_botCommand().size.width, image_botCommand().size.height)];
    [self.botCommandButton setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
    [self.botCommandButton.layer disableActions];
    
    [self.botCommandButton addTarget:self action:@selector(botCommandButtonAction:) forControlEvents:BTRControlEventMouseDownInside];
    [self.botCommandButton setBackgroundImage: image_botCommand() forControlState:BTRControlStateNormal];

    
    [self.inputMessageTextField.containerView addSubview:self.botCommandButton];
    
    self.channelAdminButton = [[BTRButton alloc] initWithFrame:NSMakeRect(self.inputMessageTextField.containerView.frame.size.width - 90, 7, image_ChannelMessageAsAdmin().size.width, image_ChannelMessageAsAdmin().size.height)];
    [self.channelAdminButton setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
    [self.channelAdminButton.layer disableActions];
    
    [self.channelAdminButton addTarget:self action:@selector(channelAdminButtonAction:) forControlEvents:BTRControlEventMouseDownInside];
    [self.channelAdminButton setBackgroundImage: image_ChannelMessageAsAdmin() forControlState:BTRControlStateNormal];
    
    
    [self.inputMessageTextField.containerView addSubview:self.channelAdminButton];
    
    
    self.silentModeButton = [[BTRButton alloc] initWithFrame:NSMakeRect(self.inputMessageTextField.containerView.frame.size.width - 90, 3, image_ConversationInputFieldBroadcastIconInactive().size.width, image_ConversationInputFieldBroadcastIconInactive().size.height)];
    [self.silentModeButton setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
    [self.silentModeButton.layer disableActions];
    
    [self.silentModeButton addTarget:self action:@selector(silentModeButtonActtion:) forControlEvents:BTRControlEventMouseDownInside];
    [self.silentModeButton setBackgroundImage:image_ConversationInputFieldBroadcastIconInactive() forControlState:BTRControlStateNormal];
    
    [self.silentModeButton setCursor:[NSCursor arrowCursor] forControlState:BTRControlStateHover];
    
    
    
    
    [self.inputMessageTextField.containerView addSubview:self.silentModeButton];
    
    
    self.secretTimerButton = [[BTRButton alloc] initWithFrame:NSMakeRect(self.inputMessageTextField.containerView.frame.size.width - 60, 2, 30, 30)];
    [self.secretTimerButton setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
    [self.secretTimerButton.layer disableActions];
    
    [self.secretTimerButton addTarget:self action:@selector(secretTimerAction:) forControlEvents:BTRControlEventMouseDownInside];
    [self.secretTimerButton setImage: image_ModernConversationSecretAccessoryTimer() forControlState:BTRControlStateNormal];
    
    
    [self.inputMessageTextField.containerView addSubview:self.secretTimerButton];
    
    
    self.removeAudioRecordButton = [[BTRButton alloc] initWithFrame:NSMakeRect(18, roundf((58-image_MessageActionDeleteActive().size.height)/2), image_MessageActionDeleteActive().size.width, image_MessageActionDeleteActive().size.height)];
    
    [self.removeAudioRecordButton addTarget:self action:@selector(removeAudioRecordAction:) forControlEvents:BTRControlEventMouseDownInside];
    [self.removeAudioRecordButton setImage: image_MessageActionDeleteActive() forControlState:BTRControlStateNormal];
    
    
    [self.normalView addSubview:self.removeAudioRecordButton];
    
    
    
    self.progressView = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(self.inputMessageTextField.containerView.frame.size.width - 30, 8,16,16)];
    [self.progressView setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
    [self.progressView setControlSize:NSSmallControlSize];
    [self.progressView setStyle:NSProgressIndicatorSpinningStyle];
    [self.inputMessageTextField.containerView addSubview:self.progressView];
    
    
    [self.smileButton addTarget:self action:@selector(smileButtonEntered:) forControlEvents:BTRControlEventMouseEntered];
    [self.smileButton addTarget:self action:@selector(smileButtonClick:) forControlEvents:BTRControlEventClick];
    [self.inputMessageTextField.containerView addSubview:self.smileButton];
    
    //self.normalView.backgroundColor = NSColorFromRGB(0x000000)
    
    _imageAttachmentsController = [[TGImageAttachmentsController alloc] initWithFrame:NSMakeRect(self.attachButton.frame.origin.x + self.attachButton.frame.size.width + 11, NSHeight(self.inputMessageTextField.containerView.frame) + NSMinX(self.inputMessageTextField.frame) + 20, NSWidth(self.inputMessageTextField.containerView.frame), 70)];
        
    _imageAttachmentsController.delegate = self;
        
    [self.normalView addSubview:_imageAttachmentsController];

    
    return self.normalView;
}

-(BOOL)sendMessageAsAdmin {
    return _channelAdminButton.isSelected && [self.dialog canSendChannelMessageAsAdmin];
}

-(void)botKeyboardButtonAction:(BTRButton *)button {
    [self.botKeyboard setHidden:!self.botKeyboard.isHidden];
    
    [_botKeyboardButton setSelected:!self.botKeyboard.isHidden];
    
    [self.botKeyboardButton setBackgroundImage:!_botKeyboardButton.isSelected ? image_botKeyboard() : image_botKeyboardActive() forControlState:BTRControlStateNormal];
    
    
    [self updateBottomHeight:YES];
}

static RBLPopover *popover;

-(void)secretTimerAction:(BTRButton *)button {
    
    NSMenu *menu = [MessagesViewController destructMenu:^ {
        //  [self.setTTLButton setLocked:NO];
        
    } click:^{
        [popover close];
        popover = nil;
    }];
    
    
    [popover close];
    popover = nil;
    
    TMMenuController *controller = [[TMMenuController alloc] initWithMenu:menu];
    
    popover = [[RBLPopover alloc] initWithContentViewController:controller];
    
    [popover showRelativeToRect:button.bounds ofView:button preferredEdge:CGRectMinYEdge];

}

-(void)removeAudioRecordAction:(BTRButton *)button {
    [self updateStopRecordControls];
}

-(void)botCommandButtonAction:(BTRButton *)button {
    [self.inputMessageTextField setString:@"/"];
    [self.inputMessageTextField textDidChange:nil];
}


-(void)channelAdminButtonAction:(BTRButton *)button {
    [_channelAdminButton setSelected:!_channelAdminButton.isSelected];
    
    [_channelAdminButton setBackgroundImage:!_channelAdminButton.isSelected ? image_ChannelMessageAsAdmin() : image_ChannelMessageAsAdminHighlighted() forControlState:BTRControlStateNormal];
}

-(void)updateNotifySettings:(NSNotification *)notification {
    
    NSImage *image = self.dialog.notify_settings.isSilent ? image_ConversationInputFieldBroadcastIconInactive() : image_ConversationInputFieldBroadcastIconActive();
    [self.silentModeButton setBackgroundImage:image forControlState:BTRControlStateNormal];
    [self.silentModeButton setFrameSize:image.size];
    
    [self.silentModeButton setToolTip:self.dialog.notify_settings.isSilent ? NSLocalizedString(@"Channel.SilentModeOn",nil) : NSLocalizedString(@"Channel.SilentModeOff",nil)];
}

-(void)silentModeButtonActtion:(BTRButton *)button {
    
    if(button) {
        int flags = self.dialog.notify_settings.flags;
        
        if(flags & PushEventMaskDisableChannelMessageNotification)
        flags &= ~PushEventMaskDisableChannelMessageNotification;
        else
        flags |= PushEventMaskDisableChannelMessageNotification;
        
        
        [self.dialog updateNotifySettings:[TL_peerNotifySettings createWithFlags:flags mute_until:self.dialog.notify_settings.mute_until sound:self.dialog.notify_settings.sound] serverSave:YES];

    }
    
    [self updateNotifySettings:nil];

}

-(void)showMediaAttachPanel {
    
    self.menuPopover.animates = NO;
    
    [self.menuPopover setDidCloseBlock:^(TMMenuPopover *popover) {}];
    [self.menuPopover close];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [FileUtils showPanelWithTypes:mediaTypes() completionHandler:^(NSArray *paths) {
            
            self.menuPopover = nil;
            [self.attachButton setSelected:NO];
            
            BOOL isMultiple = [paths filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.pathExtension.lowercaseString IN (%@)",imageTypes()]].count > 1;
            
            [paths enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                
                NSString *extenstion = [[obj pathExtension] lowercaseString];
                
                if([imageTypes() indexOfObject:extenstion] != NSNotFound) {
                    [self.messagesViewController sendImage:obj forConversation:self.dialog file_data:nil isMultiple:isMultiple addCompletionHandler:nil];
                } else {
                    [self.messagesViewController sendVideo:obj forConversation:self.dialog];
                }
                
            }];
        }];
    });
    
    
}

-(NSMenu *)attachMenu {
    NSMenu *theMenu = [[NSMenu alloc] init];
    
    NSMenuItem *attachPhotoOrVideoItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Attach.PictureOrVideo", nil) withBlock:^(id sender) {
        [self showMediaAttachPanel];
    }];
    [attachPhotoOrVideoItem setImage:image_AttachPhotoVideo()];
    [attachPhotoOrVideoItem setHighlightedImage:image_AttachPhotoVideoHighlighted()];
    [theMenu addItem:attachPhotoOrVideoItem];
    
    
    NSMenuItem *attachTakePhotoItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Attach.TakePhoto", nil) withBlock:^(id sender) {
        
        IKPictureTaker *pictureTaker = [IKPictureTaker pictureTaker];
        [pictureTaker setValue:[NSNumber numberWithBool:YES] forKey:IKPictureTakerShowEffectsKey];
        [pictureTaker setValue:[NSValue valueWithSize:NSMakeSize(640, 640)] forKey:IKPictureTakerOutputImageMaxSizeKey];
        [pictureTaker beginPictureTakerSheetForWindow:self.window withDelegate:self didEndSelector:@selector(pictureTakerValidated:code:contextInfo:) contextInfo:nil];
    }];
    [attachTakePhotoItem setImage:image_AttachTakePhoto()];
    [attachTakePhotoItem setHighlightedImage:image_AttachTakePhotoHighlighted()];
    [theMenu addItem:attachTakePhotoItem];
    
    weak();
    
    NSMenuItem *attachLocationItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Attach.Location", nil) withBlock:^(id sender) {
        
        MapPanel *panel = [MapPanel sharedPanel];
        panel.messagesViewController = weakSelf.messagesViewController;
        [panel update];
        
        [self.window beginSheet:panel completionHandler:^(NSModalResponse returnCode) {
            
        }];
        
    }];
    
    
    
    [attachLocationItem setImage:image_AttachLocation()];
    [attachLocationItem setHighlightedImage:image_AttachLocationHighlighted()];
    
    
    if(ACCEPT_FEATURE && self.dialog.type != DialogTypeSecretChat && floor(NSAppKitVersionNumber) >= NSAppKitVersionNumber10_9) {
        [theMenu addItem:attachLocationItem];
    }
    
    NSMenuItem *attachFileItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Attach.File", nil) withBlock:^(id sender) {
        [FileUtils showPanelWithTypes:nil completionHandler:^(NSArray *paths) {
            
            [paths enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                [self.messagesViewController sendDocument:obj forConversation:self.dialog];
            }];
            
        }];
    }];
    [attachFileItem setImage:image_AttachFile()];
    [attachFileItem setHighlightedImage:image_AttachFileHighlighted()];
    
    
    [theMenu addItem:attachFileItem];
    
    if(self.dialog.type != DialogTypeSecretChat) {
        __block NSMutableArray *top;
        
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            
            top = [[transaction objectForKey:@"categories" inCollection:TOP_PEERS] mutableCopy];
            
        }];
        
        
        [top enumerateObjectsUsingBlock:^(TL_topPeerCategoryPeers *obj, NSUInteger cidx, BOOL * _Nonnull stop) {
            
            if([obj.category isKindOfClass:[TL_topPeerCategoryBotsInline class]]) {
                
                [obj.peers enumerateObjectsUsingBlock:^(TL_topPeer *peer, NSUInteger idx, BOOL *stop) {
                    
                    TLUser *user = [[UsersManager sharedManager] find:peer.peer.user_id];
                    
                    NSMenuItem *botMenuItem = [NSMenuItem menuItemWithTitle:[NSString stringWithFormat:@"@%@",user.username] withBlock:^(id sender) {
                        
                        open_link_with_controller([NSString stringWithFormat:@"chat://viabot/?username=@%@",user.username],weakSelf.messagesViewController.navigationViewController);
                        
                    }];
                    
                    [[TGMenuItemPhoto alloc] initWithUser:user menuItem:botMenuItem];
                    
                    
                    [theMenu addItem:botMenuItem];
                    
                }];
                
                *stop = YES;
            }
            
        }];
    }
    
   
    
    return theMenu;
}

- (void)recordAudioMouseEntered:(BTRButton *)button {
    if(!self.recordCircleLayer.isHidden) {
        [self.recordAudioButton setSelected:YES];
        [self.recordHelpLayer setTextColor:NSColorFromRGB(0x9b9b9b)];
    }
}

- (void)recordAudioMouseExited:(BTRButton *)button {
    if(!self.recordCircleLayer.isHidden) {
        [self.recordAudioButton setSelected:NO];
        [self.recordHelpLayer setTextColor:NSColorFromRGB(0xee6363)];
    }
}

- (void)setRecordHelperStringValue:(NSString *)string {
    self.recordHelpLayer.string = string;
   
    int minX = NSMaxX(self.recordDurationLayer.frame);
    int maxX = NSMinX(self.recordAudioButton.frame);
    
    NSSize size = self.recordHelpLayer.size;
    
    int dif = maxX - minX;
    
    [self.recordHelpLayer setFrameSize:NSMakeSize(dif - 20,size.width > dif-20 ? size.height + 18 : size.height)];
    [self.recordHelpLayer setFrameOrigin:CGPointMake( minX + 10 , roundf((60-self.recordHelpLayer.bounds.size.height)/2))];
}

- (void)startRecord:(BTRButton *)button {
    weak();
    
    if(!self.dialog.canSendMessage || [[TMAudioRecorder sharedInstance] isRecording])
        return;
    
    [_recordedAudioPreview removeFromSuperview];
    _recordedAudioPreview = nil;
    [_removeAudioRecordButton setHidden:YES];
    
    [self.recordDurationLayer setFrameOrigin:CGPointMake(42, roundf( (58 - self.recordDurationLayer.bounds.size.height) / 2.f) - 1)];


    [self.recordDurationLayer setString:@"00:00"];
    [self.recordDurationLayer setHidden:NO];
    [self.inputMessageTextField.containerView removeFromSuperview];

    [self.smileButton setHidden:YES];
    [self.attachButton setHidden:YES];
    
    [self.recordCircleLayer setHidden:NO];
    
    [self setRecordHelperStringValue:NSLocalizedString(@"Audio.ReleaseOut", nil)];
    [self.recordHelpLayer setHidden:NO];
    self.recordHelpLayer.alignmentMode = @"center";
    [self recordAudioMouseEntered:button];
    
    [self.recordTimer invalidate];
    
    
    self.recordTimer = [[TGTimer alloc] initWithTimeout:0.01 repeat:YES completion:^{
        
        
        [TGSendTypingManager addAction:[TL_sendMessageRecordAudioAction create] forConversation:self.dialog];
        
        NSTimeInterval time = [[TMAudioRecorder sharedInstance] timeRecorded];
        
        float ms = time - ((int)time);
        
        [weakSelf.recordDurationLayer setString:[NSString stringWithFormat:@"%@,%d",[NSString durationTransformedValue:time],(int)(ms*100)]];
    } queue:dispatch_get_main_queue()];
    [self.recordTimer start];
    

    TMAudioRecorder *recorder = [TMAudioRecorder sharedInstance];
    [recorder setPowerHandler:^(float power) {
        power = mappingRange(power, 0, 1, 0.5, 1);
        POPLayerSetScaleXY(weakSelf.recordCircleLayer, CGPointMake(power, power));
    }];
    
    [recorder startRecordWithController:self.messagesViewController];
}


-(void)startOrStopQuickRecord {
    if(![[TMAudioRecorder sharedInstance] isRecording]) {
        [self startRecord:self.recordAudioButton];
        [self setRecordHelperStringValue:NSLocalizedString(@"Audio.QuickRecordRelease", nil)];
    } else {
        BOOL res = [[TMAudioRecorder sharedInstance] stopRecord:YES askConfirm:YES];
        
        if(!res) {
            [self updateStopRecordControls];
        }
    }
    
}

-(BOOL)removeQuickRecord {
    if(_recordedAudioPreview != nil) {
        [self updateStopRecordControls];
        return YES;
    }
    
    return NO;
}


-(void)showQuickRecordedPreview:(NSString *)file audioAttr:(TL_documentAttributeAudio *)audioAttr {
    
    if(!_recordedAudioPreview)
    {
        _recordedAudioPreview = [[TGRecordedAudioPreview alloc] initWithFrame:NSMakeRect(NSMinX(self.inputMessageTextField.containerView.frame), roundf ((58 - 30)/2), NSWidth(self.inputMessageTextField.containerView.frame), 30)];
        
        _recordedAudioPreview.autoresizingMask = NSViewWidthSizable;
        [self.normalView addSubview:_recordedAudioPreview];
    }
    
    [_removeAudioRecordButton setHidden:NO];
    
    [self.recordCircleLayer setHidden:YES];
    [self.recordDurationLayer setHidden:YES];
    [self.recordHelpLayer setHidden:YES];
    
    [self TMGrowingTextViewTextDidChange:nil];
    
    [_recordedAudioPreview setAudio_file:file audioAttr:audioAttr];
}


-(void)keyUp:(NSEvent *)theEvent {
    [super keyUp:theEvent];
}

- (void)stopRecord:(BTRButton *)button {
    
    
    NSPoint pos = [self convertPoint:[[NSApp currentEvent] locationInWindow] fromView:nil];
    
    BOOL isInside = NSPointInRect(pos, self.bounds);
    [[TMAudioRecorder sharedInstance] stopRecord:isInside];

    [self updateStopRecordControls];
}

-(void)updateStopRecordControls {
    [self.recordAudioButton setSelected:NO];
    [self.recordTimer invalidate];
    
    [_removeAudioRecordButton setHidden:YES];
    
    [_recordedAudioPreview removeFromSuperview];
    _recordedAudioPreview = nil;
    
    [self.inputMessageTextField.containerView removeFromSuperview];
    NSMutableArray *subviews = [[self.normalView subviews] mutableCopy];
    [subviews insertObject:self.inputMessageTextField.containerView atIndex:subviews.count - 1];
    [self.normalView setSubviews:subviews];
    [self.inputMessageTextField.window makeFirstResponder:self.inputMessageTextField];
    
    [self setHiddenRecoderControllers];
    
    [self TMGrowingTextViewTextDidChange:nil];
}

-(void)setHiddenRecoderControllers {
    [self.smileButton setHidden:NO];
    [self.attachButton setHidden:NO];
    
    [self.recordCircleLayer setHidden:YES];
    [self.recordDurationLayer setHidden:YES];
    [self.recordHelpLayer setHidden:YES];
}

- (void)stopRecordInside:(BTRButton *)button {
    [self stopRecord:button];
}

- (void)stopRecordOutside:(BTRButton *)button {
    [self stopRecord:button];
}

- (void)insertEmoji:(NSString *)emoji {
    if(self.dialog.canSendMessage)
        [self.inputMessageTextField insertText:emoji];
}

-(void)closeEmoji {
    [self.smilePopover close];
}

- (void)smileButtonEntered:(BTRButton *)button {
    
    if(!([SettingsArchiver checkMaskedSetting:ESGLayoutSettings] && [self.messagesViewController canShownESGController])) {
       [self smileButtonClick:button]; 
    }
    
    //if(![SettingsArchiver isDefaultEnabledESGLayout] || ![self.messagesViewController canShownESGController] || NSWidth(self.messagesViewController.view.frame) < 800) {
        //[
   // }
}

- (void)smileButtonClick:(BTRButton *)button {
    
    if([SettingsArchiver checkMaskedSetting:ESGLayoutSettings] && [self.messagesViewController canShownESGController])
    {
        [self.messagesViewController showOrHideESGController:NO toggle:YES];
        return;
    }

    
    TGModernESGViewController *egsViewController = [TGModernESGViewController controller];
    
 //
    weak();
    if(!self.smilePopover) {
            
        self.smilePopover = [[RBLPopover alloc] initWithContentViewController:(NSViewController *)egsViewController];
        [self.smilePopover setHoverView:self.smileButton];
        self.smilePopover.animates = NO;
        [self.smilePopover setDidCloseBlock:^(RBLPopover *popover){
            [weakSelf.smileButton setSelected:NO];
            [egsViewController close];
        }];
        
    }
    
    egsViewController.messagesViewController = self.messagesViewController;
    egsViewController.epopover = self.smilePopover;
    
    [egsViewController.emojiViewController setInsertEmoji:^(NSString *emoji) {
        [weakSelf insertEmoji:emoji];
    }];
    
    [self.smileButton setSelected:YES];
    
    NSRect frame = self.smileButton.bounds;
    frame.origin.y += 4;
    
    if(!self.smilePopover.isShown) {
        [self.smilePopover showRelativeToRect:frame ofView:self.smileButton preferredEdge:CGRectMaxYEdge];
        [egsViewController show];
    }
    
   
}

- (TMView *)secretInfoView {
    if(self->_secretInfoView)
        return self->_secretInfoView;
    
    self->_secretInfoView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height - 1)];
    [self.secretInfoView setAutoresizesSubviews:YES];
    [self.secretInfoView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    
    self.encryptedStateTextField = [TMTextField defaultTextField];
    [self.encryptedStateTextField setFont:TGSystemFont(15)];
    [self.encryptedStateTextField setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin];
    [self.encryptedStateTextField setTextColor:NSColorFromRGB(0xa1a1a1)];
    [self.secretInfoView addSubview:self.encryptedStateTextField];
    
    weak();
    
    [_secretInfoView setCallback:^{
       
        if(weakSelf.dialog.isInvisibleChannel) {
            
            [weakSelf.messagesViewController showModalProgress];
            
            [RPCRequest sendRequest:[TLAPI_channels_joinChannel createWithChannel:weakSelf.dialog.chat.inputPeer] successHandler:^(RPCRequest *request, TLUpdates *response) {
                
                if(response.updates.count == 0) {
                    TL_localMessage *msg = [TL_localMessageService createWithFlags:TGMENTIONMESSAGE | (1 << 14) n_id:[MessageSender getFakeMessageId] from_id:[UsersManager currentUserId] to_id:weakSelf.dialog.peer reply_to_msg_id:0 date:[[MTNetwork instance] getTime] action:([TL_messageActionChatAddUser createWithUsers:[@[@([UsersManager currentUserId])] mutableCopy]]) fakeId:[MessageSender getFakeMessageId] randomId:rand_long() dstate:DeliveryStateNormal];
                    
                    [MessagesManager addAndUpdateMessage:msg];
                }
                
                
                weakSelf.dialog.invisibleChannel = NO;
                
                [weakSelf.dialog save];
                                
                [[DialogsManager sharedManager] updateLastMessageForDialog:weakSelf.dialog];
                
                
                [ASQueue dispatchOnMainQueue:^{
                    [weakSelf.messagesViewController setState:MessagesViewControllerStateNone];
                    [weakSelf.messagesViewController tryRead];
                    [weakSelf.messagesViewController hideModalProgressWithSuccess];
                }];
                
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                
                [ASQueue dispatchOnMainQueue:^{
                    [weakSelf.messagesViewController hideModalProgress];
                }];
                
                
            } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
            
            
        } else if(weakSelf.dialog.chat.isBroadcast  && !(weakSelf.dialog.chat.isLeft || weakSelf.dialog.chat.isKicked)) {
            
            
            [weakSelf.dialog muteOrUnmute:^{
                
                [weakSelf setState:weakSelf.stateBottom animated:YES];
                
            } until:weakSelf.dialog.isMute ? 0 : 365*24*60*60];
            
            
        } else if(weakSelf.dialog.type == DialogTypeChannel && (weakSelf.dialog.chat.isLeft || weakSelf.dialog.chat.isKicked || weakSelf.dialog.chat.type == TLChatTypeForbidden)) {
            [[DialogsManager sharedManager] deleteDialog:weakSelf.dialog completeHandler:nil];
            
        } else if(!weakSelf.dialog.canSendMessage && weakSelf.dialog.user.isBot && _onClickToLockedView == nil) {
            
            [weakSelf.messagesViewController showModalProgress];
            
            [[BlockedUsersManager sharedManager] unblock:weakSelf.dialog.user.n_id completeHandler:^(BOOL response){
                
                [TMViewController hideModalProgress];
                
                [weakSelf.messagesViewController sendMessage:@"/start" forConversation:weakSelf.dialog];
                
                [weakSelf setState:MessagesBottomViewNormalState animated:YES];
            }];
            
            
            
            return;
        } else if(weakSelf.dialog.type == DialogTypeUser && weakSelf.dialog.user.isBlocked) {
            [[BlockedUsersManager sharedManager] unblock:weakSelf.dialog.user.n_id completeHandler:^(BOOL response){
                [weakSelf setState:MessagesBottomViewNormalState animated:YES];
            }];
        }
        if(_onClickToLockedView != nil)
        {
            weakSelf.onClickToLockedView();
        }
        
    }];
    
    return self.secretInfoView;
}

- (void)setState:(MessagesBottomViewState)state animated:(BOOL)animated {
    
    if(state == MessagesBottomViewNormalState) {
        if(self.dialog.type == DialogTypeSecretChat) {
            EncryptedParams *params = self.dialog.encryptedChat.encryptedParams;
            if(params.state != EncryptedAllowed) {
                state = MessagesBottomViewBlockSecretState;
            }
        }
        
        if(!self.dialog.canSendMessage || self.dialog.isInvisibleChannel)
            state = MessagesBottomViewBlockChat;
        
    }
    
    
    self->_stateBottom = state;
    
    TMView *oldView, *newView;
    for(TMView *view in self.subviews) {
        if(!view.isHidden) {
            oldView = view;
            break;
        }
    }
    
    switch (state) {
        case MessagesBottomViewActionsState: {
            newView = self.actionsView;
            
            [self.messagesSelectedCount setHidden:YES];
            
            
            
            [self.forwardButton setDisable:YES];
            [self.deleteButton setDisable:YES];
            
            break;
        }
            
        case MessagesBottomViewNormalState: {
            newView = self.normalView;
            break;
        }
            
        default:
            newView = self.secretInfoView;
            break;
    }
    if(state == MessagesBottomViewBlockChat || state == MessagesBottomViewBlockSecretState) {
      //  if((self.dialog && !self.dialog.canSendMessage) || self.dialog.user.isBot) {
            animated = NO;
 
         [self.encryptedStateTextField setStringValue:[self.dialog blockedText]];
        
        [self.encryptedStateTextField setTextColor:[self.encryptedStateTextField.stringValue isEqualToString:[self.dialog blockedText]] ? LINK_COLOR : GRAY_TEXT_COLOR];
        
       
        
        [self.encryptedStateTextField sizeToFit];
        [self.encryptedStateTextField setCenterByView:self.encryptedStateTextField.superview];
     //   }
    }
   
    
    if(oldView == newView) {
        [self becomeFirstResponder];
        return;
    }
    
    if(newView) {
        
        [newView setFrameSize:NSMakeSize(NSWidth(self.frame),NSHeight(self.frame) - 1)];
    
        NSMutableArray *subviews = [[self subviews] mutableCopy];
        [subviews removeObject:newView];
        [subviews addObject:newView];
        [self setSubviews:subviews];
    }

    
    
    static float duration = 0.2;
    
    if(!animated) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [oldView setHidden:YES];
        [newView setHidden:NO];
        [CATransaction commit];
    } else {
        [oldView setHidden:YES];
        
        [newView.layer setOpacity:0];
        [newView setHidden:NO];
        
        POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anim.fromValue = @(0.);
        anim.toValue = @(1.);
        anim.duration = duration;
        [anim setCompletionBlock:^(POPAnimation *anim, BOOL result) {
           // [oldView setHidden:YES];
        }];
        [newView.layer pop_addAnimation:anim forKey:@"fade"];
        
    }
    
    
    
    [self becomeFirstResponder];
    
    [self TMGrowingTextViewHeightChanged:self.inputMessageTextField height:NSHeight(self.inputMessageTextField.containerView.frame) cleared:animated];

}

- (void)setSelectedSmileButton:(BOOL)selected {
    [self.smileButton setSelected:selected];
}

- (void)sendButtonAction {
    
    if(_inlineBot)
        return;
        
    if(self.template.type == TGInputMessageTemplateTypeEditMessage) {
        [self.messagesViewController sendMessage];
        return;
    }
    
    if(_recordedAudioPreview == nil)
        [self.messagesViewController sendMessage];
    else {
        [self.messagesViewController sendAudio:_recordedAudioPreview.audio_file forConversation:self.dialog waveforms:_recordedAudioPreview.audioAttr.waveform];
        [self updateStopRecordControls];
    }
    
    
    
    [self.messagesViewController sendAttachments:[_imageAttachmentsController attachments] forConversation:self.dialog addCompletionHandler:nil];
    
    if(_imageAttachmentsController.isShown) {
        [_imageAttachmentsController hide:YES deleteItems:YES];
        [self updateBottomHeight:YES];
        [self TMGrowingTextViewTextDidChange:nil];
    }
    
    
    
    
    [self.messagesViewController performForward:self.dialog];
    
}

- (BOOL) TMGrowingTextViewCommandOrControlPressed:(id)textView isCommandPressed:(BOOL)isCommandPressed {
    BOOL isNeedSend = ([SettingsArchiver checkMaskedSetting:SendEnter] && !isCommandPressed) || ([SettingsArchiver checkMaskedSetting:SendCmdEnter] && isCommandPressed);
    
    
    
    if(isNeedSend && self.messagesViewController.hintView.isHidden) {
         [self sendButtonAction];
    }
    return isNeedSend || (!self.messagesViewController.hintView.isHidden);
}

- (void) TMGrowingTextViewFirstResponder:(id)textView isFirstResponder:(BOOL)isFirstResponder {
    static BOOL oldValue;
    if(oldValue != isFirstResponder) {
        oldValue = isFirstResponder;
//        [self.inputMessageTextField setBackgroundImage:isFirstResponder ? msg_input_active() : msg_input()];
    }
}

- (void)TMGrowingTextViewTextDidChange:(id)textView {
    
    if(textView)
        [self.messagesViewController saveInputText];
    
    
    if( (([self.inputMessageTextField.stringValue trim].length > 0 || self.template.type == TGInputMessageTemplateTypeEditMessage) || self.fwdContainer || _imageAttachmentsController.isShown || _recordedAudioPreview != nil)) {
        
        
        if([self.inputMessageTextField.stringValue trim].length > 0 && textView)
            [TGSendTypingManager addAction:[TL_sendMessageTypingAction create] forConversation:self.dialog];
       // [self.messagesViewController sendTypingWithAction:[TL_sendMessageTypingAction create]];
        
        
        [self.sendButton setTextColor:LINK_COLOR forState:TMButtonNormalState];
        [self.sendButton setTextColor:NSColorFromRGB(0x467fb0) forState:TMButtonNormalHoverState];
        [self.sendButton setTextColor:NSColorFromRGB(0x2e618c) forState:TMButtonPressedState];
        [self.sendButton setDisabled:NO];
    } else {
        [self.sendButton setTextColor:NSColorFromRGB(0xaeaeae) forState:TMButtonNormalState];
        [self.sendButton setDisabled:YES];
    }
    
    if(self.template.type == TGInputMessageTemplateTypeEditMessage || self.inputMessageTextField.stringValue.length > 0 || self.fwdContainer || _imageAttachmentsController.isShown || _recordedAudioPreview != nil) {
        [self.sendButton setHidden:NO];
        [self.recordAudioButton setHidden:YES];
    } else {
        [self.sendButton setHidden:YES];
        [self.recordAudioButton setHidden:NO];
    }

    
    // && textView != self
    [self updateWebpage:textView != nil];
   
    
    [self updateBotButtons];
    
    [self checkMentionsOrTags];
    
    [self updateTextFieldContainer:NO];

    

}

-(void)checkMentionsOrTags {
    

    
    NSString *search = nil;
    NSString *string = self.inputMessageTextField.string;
    NSRange selectedRange = self.inputMessageTextField.selectedRange;
    TGHintViewShowType type = [TGMessagesHintView needShowHint:string selectedRange:selectedRange completeString:&string searchString:&search];
    
    
   [self.inputMessageTextField setInline_placeholder:nil];
    
    if(self.inputMessageTextField.stringValue.length > 0 && [self.inputMessageTextField.stringValue hasPrefix:@"@"] && type != 0) {
        NSRange split = [self.inputMessageTextField.stringValue rangeOfString:@" "];
        if(split.location != NSNotFound && split.location != 1) {
            
            NSString *bot = [self.inputMessageTextField.stringValue substringWithRange:NSMakeRange(1,split.location-1)];
            
            TLUser *user = [UsersManager findUserByName:bot];
            
            if(user.isBot && user.isBotInlinePlaceholder) {
                search = nil;
            }
        }
        
        
    }
    
    self.inlineBot = nil;
    [self.messagesViewController.hintView cancel];
    [self setProgress:NO];
    
    if(search != nil && ![string hasPrefix:@" "]) {
        
        
        
        void (^callback)(NSString *fullUserName) = ^(NSString *fullUserName) {
            NSMutableString *insert = [[self.inputMessageTextField string] mutableCopy];
            
            [insert insertString:fullUserName atIndex:selectedRange.location - search.length];
            [self.inputMessageTextField insertText:[fullUserName stringByAppendingString:@" "] replacementRange:NSMakeRange(selectedRange.location - search.length, search.length)];
            
            
        };
        
        if(type == TGHintViewShowMentionType) {
            [self.messagesViewController.hintView showMentionPopupWithQuery:search conversation:self.dialog chat:self.dialog.chat allowInlineBot:[self.inputMessageTextField.string rangeOfString:@"@"].location == 0 choiceHandler:callback];
            
        } else if(type == TGHintViewShowHashtagType) {
            
            [self.messagesViewController.hintView showHashtagHintsWithQuery:search conversation:self.dialog peer_id:self.dialog.peer_id choiceHandler:callback];
            
        } else if(type == TGHintViewShowBotCommandType && [self.inputMessageTextField.string rangeOfString:@"/"].location == 0) {
            if([_dialog.user isBot] || _dialog.fullChat.bot_info != nil) {
                
                [self.messagesViewController.hintView showCommandsHintsWithQuery:search conversation:self.dialog botInfo:_userFull ? @[_userFull.bot_info] : _dialog.fullChat.bot_info choiceHandler:^(NSString *command) {
                    callback(command);
                    [self sendButtonAction];
                }];
                
            }
        }
        
    } else if([self.inputMessageTextField.stringValue hasPrefix:@"@"] && self.dialog.type != DialogTypeSecretChat) {
        
        [self.messagesViewController.hintView hide];
        
        
        

         NSString *value = self.inputMessageTextField.stringValue;
        
        NSRange split = [value rangeOfString:@" "];
        
        
        if(split.location != NSNotFound && split.location != 1) {
            NSString *bot = [value substringWithRange:NSMakeRange(1,split.location-1)];
            NSString *query = [value substringFromIndex:split.location];
            
            if([bot rangeOfString:@"\n"].location == NSNotFound) {
                weak();
                
                [self.messagesViewController.hintView showContextPopupWithQuery:bot query:[query trim] conversation:self.dialog acceptHandler:^(TLUser *user){
                    [weakSelf.inputMessageTextField setInline_placeholder:![query isEqualToString:@" "] ? nil : [weakSelf inline_placeholder:user]];
                    weakSelf.inlineBot = user;
                    [weakSelf checkAndDisableSendingWithInlineBot:user animated:YES];
                }];
            } else {
                 [self checkAndDisableSendingWithInlineBot:nil animated:YES];
            }
            
            
        } else {
            [self checkAndDisableSendingWithInlineBot:nil animated:YES];
        }
        
        
    } else {
        [self.messagesViewController.hintView hide];
        [self setProgress:NO];
    }
}

-(void)paste:(id)sender {
    [_inputMessageTextField paste:sender];
}

-(void)setInlineBot:(TLUser *)inlineBot {
    _inlineBot = inlineBot;
    [self.sendButton setHidden:self.sendButton.isHidden || inlineBot != nil];
    [self.recordAudioButton setHidden:self.recordAudioButton.isHidden || inlineBot != nil];
}

-(void)checkAndDisableSendingWithInlineBot:(TLUser *)user animated:(BOOL)animated {
    [self updateTextFieldContainer:NO];
}

-(NSAttributedString *)inline_placeholder:(TLUser *)bot {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:bot.bot_inline_placeholder withColor:GRAY_TEXT_COLOR];
    
    [attr setFont:TGSystemFont(13) forRange:attr.range];
    
    return attr;
    
    
}


-(void)checkBotKeyboard:(BOOL)updateHeight animated:(BOOL)animated forceShow:(BOOL)forceShow  {
    
    
    __block TL_localMessage *keyboard;
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * __nonnull transaction) {
        
        keyboard = [transaction objectForKey:self.dialog.cacheKey inCollection:BOT_COMMANDS];
        
    }];
    
    
    if(!_botKeyboard && keyboard) {
        
        _botKeyboard = [[TGBotCommandsKeyboard alloc] initWithFrame:NSMakeRect(self.attachButton.frame.origin.x + self.attachButton.frame.size.width + 21, NSHeight(self.inputMessageTextField.containerView.frame) + NSMinX(self.inputMessageTextField.frame) + 20 + (self.replyContainer ? 45 : 0), NSWidth(self.inputMessageTextField.containerView.frame), 30)];
        [_botKeyboard setBackgroundColor:NSColorFromRGB(0xfafafa)];
        
        [self.normalView addSubview:_botKeyboard];
    } else {
        if(!keyboard) {
            [_botKeyboard removeFromSuperview];
            _botKeyboard = nil;
        }
        
    }
    
   

   
    weak();
    
    [_botKeyboard setKeyboard:keyboard fillToSize:NO keyboadrdCallback:^(TLKeyboardButton *botCommand) {
        
        strongWeak();
        
        if(strongSelf == weakSelf) {
            
            [MessageSender proccessInlineKeyboardButton:botCommand messagesViewController:strongSelf.messagesViewController conversation:keyboard.conversation messageId:0  handler:^(TGInlineKeyboardProccessType type) {
                
                [strongSelf.botKeyboard setProccessing:type == TGInlineKeyboardProccessingType forKeyboardButton:botCommand];
                
                if(type == TGInlineKeyboardSuccessType) {
                    if(keyboard.reply_markup.isSingle_use ) {
                        
                        
                        //ФЛАГ SINGLE_USE (1 << 5) ЗАНЯТ. Предупредить.
                        keyboard.reply_markup.flags|= (1 << 5);
                        
                        [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
                            [transaction setObject:keyboard forKey:keyboard.conversation.cacheKey inCollection:BOT_COMMANDS];
                        }];
                        
                        [Notification perform:[Notification notificationNameByDialog:keyboard.conversation action:@"hideBotKeyboard"] data:@{KEY_DIALOG:keyboard.conversation}];
                    }
                }
                
                
            }];
            
            
            
        }
        
    }];
    
    if(!forceShow) {
        
        if((_botKeyboard.keyboard.reply_markup.flags & (1 << 1)) == 0) {
            forceShow = YES;
        } else {
            forceShow = (_botKeyboard.keyboard.reply_markup.flags & (1 << 5)) == 0;
        }
    }

//    if(self.replyContainer != nil) {
//        forceShow = NO;
//    }
    
    [_botKeyboardButton setSelected:forceShow];
    [_botKeyboardButton setHidden:!_botKeyboard.isCanShow || self.replyContainer != nil || _template.type == TGInputMessageTemplateTypeEditMessage];
    
    [self updateBotButtons];
    
    [self updateTextFieldContainer:NO];
    
    [self.botKeyboardButton setBackgroundImage:!_botKeyboardButton.isSelected ? image_botKeyboard() : image_botKeyboardActive() forControlState:BTRControlStateNormal];
    
    [_botKeyboard setHidden:!forceShow];
    
    
    if(updateHeight) {
        [self updateBottomHeight:animated];
    }
    
    [self TMGrowingTextViewTextDidChange:nil];
    
}


-(void)checkFwdMessages:(BOOL)updateHeight animated:(BOOL)animated {
    
    
    [_fwdContainer removeFromSuperview];
    
    _fwdContainer = nil;

    
    
    NSArray *fwdMessages = [self.messagesViewController fwdMessages:self.dialog];
    
    
    if(fwdMessages.count > 0 && _template.type != TGInputMessageTemplateTypeEditMessage) {
        
        _fwdContainer = [[TGForwardContainer alloc] initWithFrame:NSMakeRect(self.attachButton.frame.origin.x + self.attachButton.frame.size.width + 21, NSHeight(self.inputMessageTextField.containerView.frame) + NSMinX(self.inputMessageTextField.frame) + 20 , NSWidth(self.inputMessageTextField.containerView.frame), 30)];
        
        
        TGForwardObject *fwdObj = [[TGForwardObject alloc] initWithMessages:fwdMessages];
        
        [_fwdContainer setFwdObject:fwdObj];
        
        weak();
        
        [_fwdContainer setDeleteHandler:^{
           
            [weakSelf.messagesViewController clearFwdMessages:weakSelf.dialog];
            
        }];
        
        _fwdContainer.autoresizingMask = NSViewWidthSizable;
        
        
        
        [self.normalView addSubview:_fwdContainer];
        
        if(updateHeight) {
            [self updateBottomHeight:animated];
        }
        
        
    } else {
        
        if(updateHeight) {
            [self updateBottomHeight:animated];
        }
        
    }
   
    
    [self TMGrowingTextViewTextDidChange:nil];
    
}

-(void)updateBottomHeight:(BOOL)animated
{
    dispatch_block_t block = ^ {
        
        [self TMGrowingTextViewHeightChanged:self.inputMessageTextField height:NSHeight(self.inputMessageTextField.containerView.frame) cleared:animated];
    };
    
    dispatch_block_t animationBlock = ^ {
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            
            [context setDuration:0.1];
            [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            
            block();
            
        } completionHandler:^{
            [self setFrame:self.frame];
        }];
        
    };
    
    if(animated)
        animationBlock();
    else {
        [self setFrame:self.frame];
        block();
    }
    
}


-(void)checkReplayMessage:(BOOL)updateHeight animated:(BOOL)animated {
    
    [self.replyContainer removeFromSuperview];
    
    self.replyContainer = nil;
    
    
    
    
    __block TL_localMessage *replyMessage = _template.replyMessage;
    
   
    if(replyMessage && _template.type != TGInputMessageTemplateTypeEditMessage) {
        int startX = self.attachButton.frame.origin.x + self.attachButton.frame.size.width + 21;
        
        TGReplyObject *replyObject = [[TGReplyObject alloc] initWithReplyMessage:replyMessage fromMessage:nil tableItem:nil];
        
        
        _replyContainer = [[MessageReplyContainer alloc] initWithFrame:NSMakeRect(startX, NSHeight(self.inputMessageTextField.containerView.frame) + NSMinX(self.inputMessageTextField.frame) + 20 , NSWidth(self.inputMessageTextField.containerView.frame), replyObject.containerHeight)];
        
        [_replyContainer setReplyObject:replyObject];
        
        [_replyContainer setBackgroundColor:NSColorFromRGB(0xfafafa)];
        
        _replyContainer.autoresizingMask = NSViewWidthSizable;
        
        weak();
        
        [_replyContainer setDeleteHandler:^{
           
            TGInputMessageTemplate *template = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:weakSelf.dialog.peer_id];
            [template setReplyMessage:nil save:YES];
            [template performNotification];
            
        }];
        
        
        if(_botKeyboard)
            [self.normalView addSubview:_replyContainer positioned:NSWindowBelow relativeTo:_botKeyboard];
        else
            [self.normalView addSubview:_replyContainer];
        
        if(updateHeight) {
            [self updateBottomHeight:animated];
        }
        
        
    } else {
        
        if(updateHeight) {
            [self updateBottomHeight:animated];
        }
        
    }
    
    [self checkBotKeyboard:updateHeight animated:animated forceShow:NO];
}

-(void)updateWebpage:(BOOL)animated {
    
#ifdef TGDEBUG
    
  //  if(!ACCEPT_FEATURE)
    //    return;
    
#endif
    
    
    if([self.webpageAttach.link isEqualToString:[self.inputMessageString webpageLink]] && !_template.noWebpage) {
     
        if(_webpageAttach && [_webpageAttach.webpage isKindOfClass:[TL_webPageEmpty class]]) {
            [_webpageAttach removeFromSuperview];
            _webpageAttach = nil;
            
            [self updateBottomHeight:YES];
        }
        
        return;
    }
    
    if(self.dialog.type == DialogTypeSecretChat && self.dialog.encryptedChat.encryptedParams.layer < 45)
        return;
    
    TLWebPage *webpage = !_template.noWebpage ? [Storage findWebpage:display_url([self.inputMessageString webpageLink])] : nil;
    
    if(!webpage && !self.webpageAttach)
        return;
    
    
    BOOL isset = _webpageAttach != nil;
   
    if([webpage isKindOfClass:[TL_webPage class]] || [webpage isKindOfClass:[TL_webPagePending class]]) {
        
        [_webpageAttach removeFromSuperview];
        _webpageAttach = nil;
        
        int startX = self.attachButton.frame.origin.x + self.attachButton.frame.size.width + 21;
        
        _webpageAttach = [[TGWebpageAttach alloc] initWithFrame:NSMakeRect(startX, NSHeight(self.inputMessageTextField.containerView.frame) + NSMinX(self.inputMessageTextField.frame) + 20 , NSWidth(self.inputMessageTextField.containerView.frame), 30) webpage:webpage link:[self.inputMessageString webpageLink] inputTemplate:_template];
        _webpageAttach.backgroundColor = self.backgroundColor;
        _webpageAttach.autoresizingMask = NSViewWidthSizable;
        
        [self.normalView addSubview:_webpageAttach];
        
    } else {
        [_webpageAttach removeFromSuperview];
        _webpageAttach = nil;
    }
    
    if(isset != (_webpageAttach != nil))
        [self updateBottomHeight:animated];
    
}





- (void) TMGrowingTextViewHeightChanged:(id)textView height:(int)height cleared:(BOOL)isCleared {
    height += 24;

    
//    MTLog(@"height %d", height);
    height = height % 2 == 1 ? height + 1 : height;
//    MTLog(@"height %d", height);
    
    

    
    if(self.stateBottom == MessagesBottomViewNormalState) {
        
        BOOL showkb = YES;
        
        if(_imageAttachmentsController.isShown ) {
            height += 75;
            showkb = NO;
        }
        
        
        
        if(self.replyContainer != nil || self.fwdContainer != nil || (self.webpageAttach != nil && self.inputMessageString.length > 0) || (_editMessageContainer != nil && !_editMessageContainer.isHidden)) {
            height+= MAX(MAX(MAX(NSHeight(self.replyContainer.frame),NSHeight(self.webpageAttach.frame)),NSHeight(self.fwdContainer.frame)),NSHeight(_editMessageContainer.frame)) + 5;
             showkb = NO;
        }
        
        [_webpageAttach setHidden:_fwdContainer != nil];
        [_replyContainer setHidden:self.fwdContainer != nil || (self.webpageAttach != nil && self.inputMessageString.length > 0)];
        
        
        if(_botKeyboard != nil && (showkb || _replyContainer != nil)) {
            height+= (!_botKeyboard.isHidden ? NSHeight(_botKeyboard.frame) + 5 : 0);
        }


    } else {
        height = 58;
    }
    
     NSSize layoutSize = NSMakeSize(self.bounds.size.width, height);
    
    if(self.stateBottom == MessagesBottomViewNormalState) {
        [self.layer setNeedsDisplay];
        
       
        
        if(isCleared) {
            
            
           // [[self.smileButton animator] setFrameOrigin:NSMakePoint(NSMinX(self.smileButton.frame), NSMinY(self.inputMessageTextField.containerView.frame) + NSHeight(self.inputMessageTextField.containerView.frame)- NSHeight(self.smileButton.frame) - 6)];
            
            [self.animator setFrameSize:layoutSize];
            [[self.normalView animator] setFrameSize:NSMakeSize(NSWidth(self.normalView.frame), layoutSize.height + 23)];
            [self.messagesViewController bottomViewChangeSize:height animated:isCleared];
            
            int offset = _imageAttachmentsController.isShown ? 95 : 20;
            
            
            [[_botKeyboard animator] setFrameOrigin:NSMakePoint(NSMinX(_botKeyboard.frame), NSHeight(self.inputMessageTextField.containerView.frame) + 20 )];
            
            offset+=((_botKeyboard && !_botKeyboard.isHidden) ? NSHeight(_botKeyboard.frame) + 5 : 0);

            
            [[_imageAttachmentsController animator] setFrameOrigin:NSMakePoint(NSMinX(_imageAttachmentsController.frame), NSHeight(self.inputMessageTextField.containerView.frame) + 20 )];
            
            [[_replyContainer animator] setFrameOrigin:NSMakePoint(NSMinX(_replyContainer.frame), NSHeight(self.inputMessageTextField.containerView.frame) + offset )];
            
            [[_fwdContainer animator] setFrameOrigin:NSMakePoint(NSMinX(_fwdContainer.frame), NSHeight(self.inputMessageTextField.containerView.frame) + offset )];
            
            [[_webpageAttach animator] setFrameOrigin:NSMakePoint(NSMinX(_webpageAttach.frame), NSHeight(self.inputMessageTextField.containerView.frame) + offset )];
            
            [[_editMessageContainer animator] setFrameOrigin:NSMakePoint(NSMinX(_editMessageContainer.frame), NSHeight(self.inputMessageTextField.containerView.frame) + offset)];
        } else {
            
             [self setFrameSize:layoutSize];
             [self.normalView setFrameSize:NSMakeSize(NSWidth(self.normalView.frame), layoutSize.height + 23)];
            
             [self.messagesViewController bottomViewChangeSize:height animated:isCleared];
            
            int offset = _imageAttachmentsController.isShown ? 95 : 20;
            
            
            [_botKeyboard setFrameOrigin:NSMakePoint(NSMinX(_botKeyboard.frame), NSHeight(self.inputMessageTextField.containerView.frame) + 20 )];
            
            offset+=((_botKeyboard && !_botKeyboard.isHidden) ? NSHeight(_botKeyboard.frame) + 5 : 0);
            
            [_imageAttachmentsController setFrameOrigin:NSMakePoint(NSMinX(_imageAttachmentsController.frame), NSHeight(self.inputMessageTextField.containerView.frame) + 20 )];
            
            [_replyContainer setFrameOrigin:NSMakePoint(NSMinX(_replyContainer.frame), NSHeight(self.inputMessageTextField.containerView.frame) + offset)];
            
            [_editMessageContainer setFrameOrigin:NSMakePoint(NSMinX(_editMessageContainer.frame), NSHeight(self.inputMessageTextField.containerView.frame) + offset)];

            [_fwdContainer setFrameOrigin:NSMakePoint(NSMinX(_fwdContainer.frame), NSHeight(self.inputMessageTextField.containerView.frame) + offset)];
            
            [_webpageAttach setFrameOrigin:NSMakePoint(NSMinX(_webpageAttach.frame), NSHeight(self.inputMessageTextField.containerView.frame) + offset)];
        }
        
        
        
        
        
       // [self.layer setNeedsDisplay];
    } else {
        [self setFrameSize:layoutSize];
        [self.messagesViewController bottomViewChangeSize:height animated:isCleared];
    }
}


-(void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    
    
    [self updateTextFieldContainer:NO];
    
//    [self.inputMessageTextField textDidChange:nil];
    
    [_botKeyboard setFrameSize:NSMakeSize(NSWidth(self.inputMessageTextField.containerView.frame), NSHeight(_botKeyboard.frame))];
}

-(void)selectInputTextByText:(NSString *)text {
    [self.inputMessageTextField setSelectedRange:[self.inputMessageTextField.string rangeOfString:text]];
    
    [self updateWebpage:NO];
}

-(int)textFieldXOffset {
    return NSMaxX(self.attachButton.frame) + 21;;
}

-(void)updateTextFieldContainer:(BOOL)animated {
    
    int offsetX = self.textFieldXOffset;
    
    TMView *view = animated  ? [self.inputMessageTextField.containerView animator] : self.inputMessageTextField.containerView;
    
    
    
    view.frame = NSMakeRect(offsetX, 11, self.bounds.size.width - offsetX - (self.inlineBot != nil ? 20 : (self.sendButton.frame.size.width + 33)), NSHeight(self.inputMessageTextField.containerView.frame));
    
        
    [self.inputMessageTextField setFrameSize:NSMakeSize(NSWidth(self.inputMessageTextField.containerView.frame) - 40 - (_botKeyboardButton.isHidden ? 0 : 30) - (_botCommandButton.isHidden ? 0 : 30) - (_channelAdminButton.isHidden ? 0 : 30) - (_secretTimerButton.isHidden ? 0 : 30) - (_progressView.isHidden ? 0 : 30) - (_silentModeButton.isHidden ? 0 : 30),NSHeight(self.inputMessageTextField.frame))];
    
    NSSize size = [self.sendButton sizeOfText];
    [self.sendButton setFrameSize:size];
    [self.sendButton setFrameOrigin:NSMakePoint(self.bounds.size.width - size.width - 17, 19)];
    
    self.inputMessageTextField.containerView.frame = NSMakeRect(offsetX, NSMinY(self.inputMessageTextField.containerView.frame), self.bounds.size.width - offsetX - (self.inlineBot != nil ? 0 : self.sendButton.frame.size.width ) - 33, NSHeight(self.inputMessageTextField.containerView.frame));


}




- (void) attachButtonPressed {
    [self.attachButton setSelected:YES];

    if(!self.menuPopover) {
        self.menuPopover = [[TMMenuPopover alloc] initWithMenu:self.attachMenu];
        [self.menuPopover setHoverView:self.attachButton];
    
    
        if(!self.menuPopover.isShown) {
            NSRect rect = self.attachButton.bounds;
            rect.origin.x += 80;
            rect.origin.y += 10;
            weak();
            [self.menuPopover setDidCloseBlock:^(TMMenuPopover *popover) {
                [weakSelf.attachButton setSelected:NO];
                weakSelf.menuPopover = nil;
            }];
            [self.menuPopover showRelativeToRect:rect ofView:self.attachButton preferredEdge:CGRectMaxYEdge];
        }
        
        }
    
//    [self.attachMenu popUpForView:self.attachButton];
}

- (void)setStateBottom:(MessagesBottomViewState)stateBottom {
    [self setState:stateBottom animated:NO];
}


- (void) pictureTakerValidated:(IKPictureTaker*) pictureTaker code:(int) returnCode contextInfo:(void*) ctxInf {
    if(returnCode == NSOKButton){
        NSImage *outputImage = [pictureTaker outputImage];
        [self.messagesViewController sendImage:nil forConversation:self.dialog file_data:[outputImage TIFFRepresentation]];

    }
}

- (void)setContextBotString:(NSString *)bot {
    [self.inputMessageTextField insertText:bot replacementRange:NSMakeRange(0,self.inputMessageTextField.stringValue.length)];
    [self.window makeFirstResponder:self.inputMessageTextField];
    [self.inputMessageTextField setSelectedRange:NSMakeRange(bot.length,0)];
}

-(void)setTemplate:(TGInputMessageTemplate *)inputTemplate checkElements:(BOOL)checkElements {
    _template = inputTemplate;
    _inputMessageTextField.inputTemplate = inputTemplate;
    
    [self.sendButton setText:_template.type == TGInputMessageTemplateTypeSimpleText ? NSLocalizedString(@"Message.Send", nil) : NSLocalizedString(@"Message.Save",nil)];
    
    
    if(checkElements) {
        [self removeQuickRecord];
        
        [self setInputMessageString:_template.text ? _template.text : @"" disableAnimations:NO];
        
        if(_template.type == TGInputMessageTemplateTypeSimpleText) {
            [_imageAttachmentsController show:_dialog animated:YES];
        } else {
            [_imageAttachmentsController hide:YES deleteItems:NO];
        }
        
        [self checkReplayMessage:YES animated:YES];
        
        [self checkFwdMessages:YES animated:YES];
        
        
        
    } else {
        [self setInputMessageString:_template.text ? _template.text : @"" disableAnimations:YES];
    }
    
    
    
    if(_template.type == TGInputMessageTemplateTypeEditMessage) {
        
        int startX = self.attachButton.frame.origin.x + self.attachButton.frame.size.width + 21;
        
        TGReplyObject *replyObject = [[TGReplyObject alloc] initWithReplyMessage:inputTemplate.editMessage fromMessage:nil tableItem:nil editMessage:YES];
        
        [_editMessageContainer removeFromSuperview];
        
        _editMessageContainer = [[MessageReplyContainer alloc] initWithFrame:NSMakeRect(startX, NSHeight(self.inputMessageTextField.containerView.frame) + NSMinX(self.inputMessageTextField.frame) + 20 , NSWidth(self.inputMessageTextField.containerView.frame), replyObject.containerHeight)];
        [_editMessageContainer setBackgroundColor:NSColorFromRGB(0xfafafa)];

        
        weak();
        
        [_editMessageContainer setDeleteHandler:^{
            [weakSelf.messagesViewController setEditableMessage:nil];
        }];
        
        [_editMessageContainer setReplyObject:replyObject];
        
        if(_webpageAttach == nil)
            [self.normalView addSubview:_editMessageContainer];
        else
            [self.normalView addSubview:_editMessageContainer positioned:NSWindowBelow relativeTo:_webpageAttach];
        
        [self updateBottomHeight:YES];
        [self TMGrowingTextViewTextDidChange:self.inputMessageTextField];
        
    } else {
        
        BOOL update = _editMessageContainer.superview != nil;
        
        [_editMessageContainer removeFromSuperview];
        _editMessageContainer = nil;
        
        if(update) {
            [self updateBottomHeight:YES];
            [self TMGrowingTextViewTextDidChange:self.inputMessageTextField];
        } else {
            [self TMGrowingTextViewTextDidChange:self.inputMessageTextField];
        }
        
    }
    

    
}

-(void)setTemplate:(TGInputMessageTemplate *)inputTemplate {
    [self setTemplate:inputTemplate checkElements:NO];
}

-(void)updateText {
    [self.inputMessageTextField textDidChange:nil];
}


- (void)setInputMessageString:(NSString *)message disableAnimations:(BOOL)disableAnimations {
    
    
    [self.inputMessageTextField.undoManager removeAllActions];

    
    [self.inputMessageTextField setString:message];
    
    
    
    self.inputMessageTextField.disableAnimation = disableAnimations;
    
    [self.inputMessageTextField textDidChange:self]; // webpage disable animation after switch

    self.inputMessageTextField.disableAnimation = YES;
    
    [self updateBotButtons];
    
    [self updateTextFieldContainer:NO];
    
}

- (NSString *)inputMessageString {
    return [self.inputMessageTextField stringValue];
}

- (BOOL)becomeFirstResponder {
    if(self.stateBottom == MessagesBottomViewNormalState) {
        [[self window] makeFirstResponder:self.inputMessageTextField];
    } else {
        if(self.window.firstResponder == self.inputMessageTextField) {
            [[self window] makeFirstResponder:nil];
        }
    }
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
    [GRAY_BORDER_COLOR set];
    NSRectFill(NSMakeRect(0, self.bounds.size.height - 1, self.bounds.size.width, 1));
}

@end


/*
 if(self.dialog.type == DialogTypeSecretChat)
 return;
 
 NSArray *links = [self.inputMessageTextField.stringValue locationsOfLinks];
 
 NSArray *acceptExtensions = @[@"jpg",@"png",@"tiff"];
 
 
 BOOL needUpdate = self.attachments.count > 0;
 
 [self.attachments enumerateObjectsUsingBlock:^(TGAttachImageElement *obj, NSUInteger idx, BOOL *stop) {
 
 [obj removeFromSuperview];
 
 }];
 
 [self.attachments removeAllObjects];
 
 
 __block int startX = self.attachButton.frame.origin.x + self.attachButton.frame.size.width + 16;
 
 __block int k = 0;
 
 [links enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
 
 NSRange range = [obj range];
 
 NSString *link = [self.inputMessageTextField.stringValue substringWithRange:range];
 
 __block BOOL checkIgnore = YES;
 
 
 [self.attachmentsIgnore enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
 
 NSString *l = obj[@"link"];
 NSRange r = [obj[@"range"] rangeValue];
 
 if((range.location == r.location && range.length == r.length) && [link isEqualToString:l])
 {
 *stop = YES;
 checkIgnore = NO;
 }
 
 }];
 
 if([acceptExtensions indexOfObject:[link pathExtension]] != NSNotFound && checkIgnore) {
 
 
 TGAttachImageElement *attach = [[TGAttachImageElement alloc] initWithFrame:NSMakeRect(startX, NSHeight(self.inputMessageTextField.containerView.frame) + NSMinX(self.inputMessageTextField.frame) + 20, 70, 70)];
 
 startX +=80;
 
 [attach setDeleteCallback:^{
 
 [self.attachmentsIgnore addObject:@{@"link":link,@"range":[NSValue valueWithRange:range]}];
 
 // [self checkAttachImages];
 
 }];
 
 [attach setLink:link range:range];
 
 
 
 [self.attachments addObject:attach];
 
 [self.normalView addSubview:attach];
 
 
 k++;
 
 }
 
 if(k == 4)
 *stop = YES;
 
 }];
 
 needUpdate = (self.attachments.count == 0 && needUpdate) || (self.attachments.count > 0 && !needUpdate);
 
 if(self.inputMessageString.length > 0 || needUpdate)

*/