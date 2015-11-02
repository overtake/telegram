//
//  ChannelInfoHeaderView.m
//  Telegram
//
//  Created by keepcoder on 21.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ChannelInfoHeaderView.h"
#import "UserInfoParamsView.h"
#import "ComposeActionAddChannelModeratorBehavior.h"
#import "ComposeActionBehavior.h"
#import "ComposeActionBlackListBehavior.h"
#import "ComposeActionChannelMembersBehavior.h"
@interface ChannelInfoHeaderView ()<TMGrowingTextViewDelegate>
@property (nonatomic,strong) UserInfoParamsView *linkView;
@property (nonatomic,strong) UserInfoParamsView *aboutView;

@property (nonatomic,strong) UserInfoShortButtonView *linkEditButton;


@property (nonatomic,strong) UserInfoShortButtonView *openOrJoinChannelButton;


@property (nonatomic,strong) TMGrowingTextView *aboutTextView;
@property (nonatomic,strong) TMTextField *aboutDescription;


@property (nonatomic,strong) TMView *editAboutContainer;


@property (nonatomic,strong) UserInfoShortButtonView *managmentButton;
@property (nonatomic,strong) UserInfoShortButtonView *blackListButton;
@property (nonatomic,strong) UserInfoShortButtonView *membersButton;
@property (nonatomic,strong) UserInfoShortButtonView *enableCommentsButton;

@property (nonatomic,strong) ITSwitch *commentsSwitch;

@property (nonatomic,strong) ComposeAction *composeActionManagment;

@end

@implementation ChannelInfoHeaderView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)controlTextDidChange:(NSNotification *)obj {
    
    
//    [self.aboutTextView setStringValue:[self.aboutTextView.stringValue substringToIndex:MIN(160,self.aboutTextView.stringValue.length)]];
//    
//    NSSize size = [self.aboutTextView.attributedStringValue sizeForTextFieldForWidth:NSWidth(self.aboutTextView.frame)];
//    
//    [self.aboutTextView setFrameSize:NSMakeSize(NSWidth(self.aboutTextView.frame), size.height)];
//    
//    [self.editAboutContainer setFrameSize:NSMakeSize(NSWidth(_editAboutContainer.frame), size.height + 20)];
//    

    
}


- (void) TMGrowingTextViewHeightChanged:(id)textView height:(int)height cleared:(BOOL)isCleared {
    [self setFrameSize:self.frame.size];
}
- (BOOL) TMGrowingTextViewCommandOrControlPressed:(id)textView isCommandPressed:(BOOL)isCommandPressed {
    return NO;
}
- (void) TMGrowingTextViewTextDidChange:(id)textView {
     [self setFrameSize:self.frame.size];
}
- (void) TMGrowingTextViewFirstResponder:(id)textView isFirstResponder:(BOOL)isFirstResponder {
    
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        _editAboutContainer = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect) - 200, 80)];
        
        self.aboutTextView = [[TMGrowingTextView alloc] initWithFrame:NSMakeRect(0, 24, NSWidth(_editAboutContainer.frame) , 40)];
     
        self.aboutTextView.growingDelegate = self;
        
        
        [self.aboutTextView setMinHeight:20];
        [self.aboutTextView setMaxHeight:47];
        
        [self.aboutTextView setLimit:200];
        [self.aboutTextView setDisabledBorder:YES];
     //   self.aboutTextView.delegate = self;
        [self.aboutTextView setFont:TGSystemFont(13)];
        
        [self.aboutTextView setEditable:YES];
        [self.aboutTextView setFocusRingType:NSFocusRingTypeNone];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
        
        [str appendString:NSLocalizedString(@"Compose.ChannelAboutPlaceholder", nil) withColor:DARK_GRAY];
        [str setAlignment:NSLeftTextAlignment range:str.range];
        [str setFont:TGSystemFont(13) forRange:str.range];
        
        
        
        [_editAboutContainer addSubview:self.aboutTextView.containerView];
        
        
        TMView *separator = [[TMView alloc] initWithFrame:NSMakeRect(0, 15, NSWidth(_editAboutContainer.frame), 1)];
        
        separator.backgroundColor = DIALOG_BORDER_COLOR;
        
        
        [_editAboutContainer addSubview:separator];
        
        
        
        
        _aboutDescription = [TMTextField defaultTextField];
        [_aboutDescription setFont:TGSystemFont(13)];
        [_aboutDescription setTextColor:GRAY_TEXT_COLOR];
        
        
        [_aboutDescription setStringValue:NSLocalizedString(@"Compose.ChannelAboutDescription", nil)];
        
        
        
        [_aboutDescription setFrameOrigin:NSMakePoint(0, 0)];
        
        [_editAboutContainer addSubview:_aboutDescription];
        
        
        [self addSubview:_editAboutContainer];
        
        self.linkView = [[UserInfoParamsView alloc] initWithFrame:NSMakeRect(100, 50, 200, 61)];
        [self.linkView setHeader:NSLocalizedString(@"Profile.ShareLink", nil)];
        [self addSubview:self.linkView];
        
        
        self.aboutView = [[UserInfoParamsView alloc] initWithFrame:NSMakeRect(100, 50, 200, 61)];
        [self.aboutView setHeader:NSLocalizedString(@"Profile.About", nil)];
        [self addSubview:self.aboutView];

        
        self.linkEditButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.EditLink", nil) tapBlock:^{
                        
            
            ComposeAction *action = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBehavior class]];
            
            action.result = [[ComposeResult alloc] init];
            
            action.result.singleObject = self.controller.chat;
            
            ComposeCreateChannelUserNameStepViewController *viewController = [[ComposeCreateChannelUserNameStepViewController alloc] initWithFrame:self.controller.view.bounds];
            
            [viewController setAction:action];
            
            [self.controller.navigationViewController pushViewController:viewController animated:YES];
            
            
        }];
        
        weak();
        
        [self.exportChatInvite setCallback:^{
            dispatch_block_t cblock = ^ {
                
                ChatExportLinkViewController *export = [[ChatExportLinkViewController alloc] initWithFrame:weakSelf.controller.view.bounds];
                
                [export setChat:weakSelf.controller.fullChat];
                
                [weakSelf.controller.navigationViewController pushViewController:export animated:YES];
                
            };
            
            
            if([weakSelf.controller.fullChat.exported_invite isKindOfClass:[TL_chatInviteExported class]]) {
                
                cblock();
                
            } else {
                
                [weakSelf.controller showModalProgress];
                
                [RPCRequest sendRequest:[TLAPI_messages_exportChatInvite createWithChat_id:weakSelf.controller.chat.n_id] successHandler:^(RPCRequest *request, TL_chatInviteExported *response) {
                    
                    [weakSelf.controller hideModalProgressWithSuccess];
                    
                    weakSelf.controller.fullChat.exported_invite = response;
                    
                    [[Storage manager] insertFullChat:weakSelf.controller.fullChat completeHandler:nil];
                    
                    cblock();
                    
                    
                } errorHandler:^(RPCRequest *request, RpcError *error) {
                    [weakSelf.controller hideModalProgress];
                } timeout:10];
                
            }

        }];
        
        
        [self.exportChatInvite.textButton setStringValue:NSLocalizedString(@"Profile.ExportInviteLink", nil)];
        

        
        self.managmentButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.Managment", nil) tapBlock:^{
            
            
            ComposeManagmentViewController *viewController = [[ComposeManagmentViewController alloc] initWithFrame:self.controller.view.bounds];
            
            [viewController setAction:_composeActionManagment];
            
            [self.controller.navigationViewController pushViewController:viewController animated:YES];
            
        }];
        
        [self addSubview:self.managmentButton];
        
        
        self.blackListButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.ChannelBlackList", nil) tapBlock:^{
            
            
            ComposeChannelParticipantsViewController *viewController = [[ComposeChannelParticipantsViewController alloc] initWithFrame:self.controller.view.bounds];
            
            [viewController setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBlackListBehavior class] filter:@[] object:self.controller.chat reservedObjects:@[[TL_channelParticipantsKicked create]]]];
            
            [self.controller.navigationViewController pushViewController:viewController animated:YES];
            
        }];
        
        [self addSubview:self.blackListButton];
        
        
        self.membersButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.ChannelMembers", nil) tapBlock:^{
            
            
            ComposeChannelParticipantsViewController *viewController = [[ComposeChannelParticipantsViewController alloc] initWithFrame:self.controller.view.bounds];
            
            [viewController setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionChannelMembersBehavior class] filter:@[] object:self.controller.chat reservedObjects:@[[TL_channelParticipantsRecent create]]]];
            
            [self.controller.navigationViewController pushViewController:viewController animated:YES];
            
        }];
        
        [self addSubview:self.membersButton];
        
        
        self.enableCommentsButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.EnableComments", nil) tapBlock:nil];
        
        
        _commentsSwitch = [[ITSwitch alloc] initWithFrame:NSMakeRect(0, 0, 30, 20)];
        
        
        [_commentsSwitch setDidChangeHandler:^(BOOL isOn){
           
             [RPCRequest sendRequest:[TLAPI_channels_toggleComments createWithChannel:weakSelf.controller.chat.inputPeer enabled:isOn] successHandler:^(id request, id response) {
                 

                 
             } errorHandler:^(id request, RpcError *error) {
                 
             }];
            
            
        }];
        
        [self.enableCommentsButton setRightContainer:_commentsSwitch];
        
        
        [self addSubview:self.enableCommentsButton];
        
        
        [self.setGroupPhotoButton.textButton setStringValue:NSLocalizedString(@"Profile.SetChannelPhoto", nil)];
        
        [self.setGroupPhotoButton sizeToFit];
        
        [self addSubview:self.linkEditButton];
        
        self.linkEditButton.textButton.textColor = TEXT_COLOR;
        self.setGroupPhotoButton.textButton.textColor = TEXT_COLOR;
        self.addMembersButton.textButton.textColor = TEXT_COLOR;
        self.enableCommentsButton.textButton.textColor = TEXT_COLOR;
        self.managmentButton.textButton.textColor = TEXT_COLOR;
        self.membersButton.textButton.textColor = TEXT_COLOR;
        self.blackListButton.textButton.textColor = TEXT_COLOR;
        self.exportChatInvite.textButton.textColor = TEXT_COLOR;
        self.openOrJoinChannelButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.OpenChannel", nil) tapBlock:^{
            
            [self.controller.navigationViewController gotoViewController:self.controller.messagesViewController];
            
        }];
        
        
        [self addSubview:self.openOrJoinChannelButton];
        
    }
    
    return self;
}

- (void)reload {
    
    
    TLChat *chat = self.controller.chat;
    
    self.avatarImageView.sourceType = ChatAvatarSourceChannel;
    
     [self rebuildOrigins];
    
    _composeActionManagment = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBehavior class] filter:@[] object:chat];
    
    [[FullChatManager sharedManager]  performLoad:chat.n_id callback:^(TLChatFull *fullChat) {
        
        self.controller.fullChat = fullChat;
        
        [self.managmentButton setRightContainer:[self buildTitleWithString:[NSString stringWithFormat:@"%d",fullChat.admins_count]]];
        [self.blackListButton setRightContainer:[self buildTitleWithString:[NSString stringWithFormat:@"%d",fullChat.kicked_count]]];
        [self.membersButton setRightContainer:[self buildTitleWithString:[NSString stringWithFormat:@"%d",fullChat.participants_count]]];
        
        [self.aboutTextView setString:self.controller.fullChat.about];
        [self.aboutTextView controlTextDidChange:nil];
                
        [self.statusTextField setChat:chat];
        [self.statusTextField sizeToFit];
        
        if(!self.controller.fullChat) {
            MTLog(@"full chat is not loading");
            return;
        }
        
        
        if(self.controller.chat.username.length > 0) {

            NSString *str = [NSString stringWithFormat:@"/%@",[self.controller.chat.username substringToIndex:MIN(20,self.controller.chat.username.length)]];
            
            if(str.length == 21 && self.controller.chat.username.length > 20) {
                str = [str stringByAppendingString:@"..."];
            }
            
            [self.linkEditButton setRightContainer:[self buildTitleWithString:str]];
        } else {
            [self.linkEditButton setRightContainer:nil];
            
            NSUInteger idx = [self.controller.fullChat.exported_invite.link rangeOfString:@"/joinchat"].location;
            
            
            
            [self.exportChatInvite setRightContainer:[self buildTitleWithString:[self.controller.fullChat.exported_invite.link substringWithRange:NSMakeRange(idx == NSNotFound ? 0 : idx, MIN(15, self.controller.fullChat.exported_invite.link.length - idx))]]];
        }
        
        
        [_commentsSwitch setOn:!chat.isBroadcast];
        
        [self.sharedLinksButton setConversation:self.controller.chat.dialog];
        [self.filesMediaButton setConversation:self.controller.chat.dialog];
        [self.sharedMediaButton setConversation:self.controller.chat.dialog];
        
        [self buildNotificationsTitle];
        
        
        self.avatarImageView.sourceType = ChatAvatarSourceChannel;
        [self.avatarImageView setChat:chat];
        [self.avatarImageView rebuild];
        
        [self.nameTextField setChat:chat];
        
        
        int h = [self.linkView setString:self.controller.chat.usernameLink];
        
        [self.linkView setFrameSize:NSMakeSize(NSWidth(self.linkView.frame), h+50)];
        
        h = [self.aboutView setString:self.controller.fullChat.about];
        
        [self.aboutView setFrameSize:NSMakeSize(NSWidth(self.linkView.frame), h+50)];
        
        
        [self TMNameTextFieldDidChanged:self.nameTextField];
        
        
        
        [self rebuildOrigins];

    }];

}

-(TMTextField *)buildTitleWithString:(NSString *)str  {
    
    TMTextField *textField = [TMTextField defaultTextField];
    
    [[textField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    [string appendString:str withColor:NSColorFromRGB(0xa1a1a1)];
    
    [string setFont:TGSystemFont(13) forRange:NSMakeRange(0, string.length)];
    
    [textField setAttributedStringValue:string];
    
    [textField sizeToFit];
    
    return textField;
}

-(void)rebuildOrigins {
    
    [self.exportChatInvite setHidden:YES];
    [self.sharedMediaButton setHidden:self.type == ChatInfoViewControllerEdit];
    [self.filesMediaButton setHidden:self.type == ChatInfoViewControllerEdit];
    [self.sharedLinksButton setHidden:self.type == ChatInfoViewControllerEdit];
    
    [self.admins setHidden:YES];
    
    
    [self.linkView setHidden:self.type == ChatInfoViewControllerEdit || self.linkView.string.length == 0];
    [self.aboutView setHidden:self.type == ChatInfoViewControllerEdit || self.aboutView.string.length == 0];
    
    
    [self.exportChatInvite setHidden:self.type != ChatInfoViewControllerEdit || self.controller.chat.username.length > 0];
    
    [self.editAboutContainer setHidden:self.type != ChatInfoViewControllerEdit];
    
    [self.linkEditButton setHidden:self.type != ChatInfoViewControllerEdit || self.controller.chat.isMegagroup];
    [self.setGroupPhotoButton setHidden:self.type != ChatInfoViewControllerEdit];
    
    
    [self.openOrJoinChannelButton setHidden:self.controller.chat.isManager || self.controller.chat.isMegagroup];
   
    
    [self.managmentButton setHidden:!self.controller.chat.isManager];
    
    [self.membersButton setHidden:!self.controller.chat.isManager];
    [self.blackListButton setHidden:self.type != ChatInfoViewControllerEdit || !self.controller.chat.isManager || self.controller.chat.isBroadcast];
    
    
    [self.enableCommentsButton setHidden:YES];
    
    [self.addMembersButton setHidden:self.type == ChatInfoViewControllerEdit || !self.controller.chat.isAdmin || self.controller.fullChat.participants_count >= 200];
    
    
    int yOffset = 42;
    
    [self.notificationView setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
    
    yOffset+=42;
    
    if(!self.sharedLinksButton.isHidden) {
        [self.sharedLinksButton setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
        yOffset+=42;
    }
    
    if(!self.filesMediaButton.isHidden) {
        [self.filesMediaButton setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
        yOffset+=42;
    }
        
    if(!self.sharedMediaButton.isHidden) {
        [self.sharedMediaButton setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
        yOffset+=42;
    }
    
    yOffset+=42;
    
    if(!self.addMembersButton.isHidden) {
        
        [self.addMembersButton setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=42;
    }
    
    if(!self.managmentButton.isHidden) {
        [self.managmentButton setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
        yOffset+=42;
    }
        
    if(!self.membersButton.isHidden) {
        [self.membersButton setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=42;
    }
    
        
    if(!self.blackListButton.isHidden) {
        [self.blackListButton setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=42;
    }
    
    
    
    
    
    if(!self.exportChatInvite.isHidden) {
        
        yOffset+=42;
        
        [self.exportChatInvite setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, NSHeight(self.exportChatInvite.frame))];
     
        yOffset+=42;
        
    }
    
    
    if(!self.openOrJoinChannelButton.isHidden) {
        [self.openOrJoinChannelButton setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame)-200, 42)];
        
        yOffset+=NSHeight(self.openOrJoinChannelButton.frame);
    }
    
    if(!self.linkView.isHidden || !self.aboutView.isHidden || !self.openOrJoinChannelButton.isHidden) {
        yOffset+=42;
    }
    
    
    if(!self.aboutView.isHidden) {
        [self.aboutView setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, NSHeight(self.aboutView.frame))];
        
        yOffset+=NSHeight(self.aboutView.frame);
    }
    
    if(!self.linkView.isHidden) {
        [self.linkView setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, NSHeight(self.linkView.frame))];
        
        yOffset+=NSHeight(self.linkView.frame);
    }
    
    

    
    if(!self.enableCommentsButton.isHidden) {
        
        [self.enableCommentsButton setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=42;
    }
    
    
    if(!self.linkEditButton.isHidden) {
        [self.linkEditButton setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=NSHeight(self.linkEditButton.frame);
    }
    
    if(!self.setGroupPhotoButton.isHidden) {
        [self.setGroupPhotoButton setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=NSHeight(self.setGroupPhotoButton.frame) + 42;
    }
    
    
    
        
    if(!self.editAboutContainer.isHidden) {
        
        [_aboutTextView scrollToEndOfDocument:self];
        
        [_aboutTextView textDidChange:nil];
        
        [_editAboutContainer setFrame:NSMakeRect(100, yOffset-14,NSWidth(self.frame) - 200, NSHeight(_editAboutContainer.frame))];
        yOffset+=50;
    }
    
    
    
  
    
    [self.nameTextField setFrameOrigin:NSMakePoint(180, yOffset + (NSHeight(self.avatarImageView.frame)/2) + roundf(NSHeight(self.statusTextField.frame)/2 + NSHeight(self.nameTextField.frame)/2)) ];
    
    [self.statusTextField setFrameOrigin:NSMakePoint(180, yOffset + (NSHeight(self.avatarImageView.frame)/2)  )];

    
    [self.nameLiveView setFrameOrigin:NSMakePoint(182, NSMinY(self.nameTextField.frame) - 5)];
    
    
    [self.nameLiveView setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.nameLiveView.frame) - 100, NSHeight(self.nameLiveView.frame))];
    [self.nameTextField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.nameTextField.frame) - 100, NSHeight(self.nameTextField.frame))];
    
    
    yOffset+=20;
    
    [self.avatarImageView setFrameOrigin:NSMakePoint(100, yOffset)];
    
    
    yOffset+=100;
    
    [self setFrameSize:NSMakeSize(NSWidth(self.frame), yOffset)];
    
    [self.controller buildFirstItem];
    

}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_editAboutContainer setFrameSize:NSMakeSize(newSize.width - 200, NSHeight(_editAboutContainer.frame))];
    
    [_aboutTextView.containerView setFrameSize:NSMakeSize(NSWidth(_editAboutContainer.frame), NSHeight(_aboutTextView.containerView.frame))];
    [_aboutDescription setFrameSize:NSMakeSize(NSWidth(_editAboutContainer.frame)+10, 18)];
    
    [_aboutTextView.containerView setFrameOrigin:NSMakePoint(-5, 16)];
    
    [self.nameLiveView setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.nameLiveView.frame) - 100, NSHeight(self.nameLiveView.frame))];
    
    
    [self.nameTextField sizeToFit];
    
    [self.nameTextField setFrameSize:NSMakeSize(MIN(NSWidth(self.frame) - NSMinX(self.nameTextField.frame) - 100,NSWidth(self.nameTextField.frame)), NSHeight(self.nameTextField.frame))];
    
}

-(void)save {
    dispatch_block_t block = ^{
        self.controller.type = ChatInfoViewControllerNormal;
        [self reload];
        
        [self.controller hideModalProgress];
    };
    
    
    dispatch_block_t next = ^{
      
        if(![self.controller.fullChat.about isEqualToString:self.aboutTextView.stringValue]) {
            
            
            
            [RPCRequest sendRequest:[TLAPI_channels_editAbout createWithChannel:self.controller.chat.inputPeer about:self.aboutTextView.stringValue] successHandler:^(RPCRequest *request, id response) {
                
                if(self.controller.fullChat != nil) {
                    self.controller.fullChat.about = [request.object about];
                    
                    [[Storage manager] insertFullChat:self.controller.fullChat completeHandler:nil];
                } else {
                    [[FullChatManager sharedManager] loadIfNeed:self.controller.chat.n_id force:YES];
                }
                
                
                block();
            } errorHandler:^(id request, RpcError *error) {
                block();
            }];
            
        } else {
            block();
        }
        
    };
    
    [self.controller showModalProgress];
    
    if(![self.nameTextField.stringValue isEqualToString:self.controller.chat.title] && self.nameTextField.stringValue.length > 0) {
        
        [RPCRequest sendRequest:[TLAPI_channels_editTitle createWithChannel:self.controller.chat.inputPeer title:self.nameTextField.stringValue] successHandler:^(RPCRequest *request, id response) {
            next();
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            next();
        }];
    } else
        next();
}


-(void)setType:(ChatInfoViewControllerType)type {
    [super setType:type];
    
    [self reload];
}


@end
