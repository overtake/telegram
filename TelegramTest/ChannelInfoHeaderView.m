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
@interface ChannelInfoHeaderView ()
@property (nonatomic,strong) UserInfoParamsView *linkView;
@property (nonatomic,strong) UserInfoParamsView *aboutView;

@property (nonatomic,strong) UserInfoShortButtonView *linkEditButton;


@property (nonatomic,strong) UserInfoShortButtonView *openOrJoinChannelButton;



@property (nonatomic,strong) TMTextField *aboutTextView;
@property (nonatomic,strong) TMTextField *aboutDescription;


@property (nonatomic,strong) TMView *editAboutContainer;

@property (nonatomic,strong) TMTextField *linkTextField;


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

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        _editAboutContainer = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect) - 200, 62)];
        
        self.aboutTextView = [[TMTextField alloc] initWithFrame:NSMakeRect(0, 24, NSWidth(_editAboutContainer.frame) , 23)];
        
        
        [self.aboutTextView setFont:[NSFont fontWithName:@"HelveticaNeue" size:15]];
        
        [self.aboutTextView setEditable:YES];
        [self.aboutTextView setBordered:NO];
        [self.aboutTextView setFocusRingType:NSFocusRingTypeNone];
        [self.aboutTextView setTextOffset:NSMakeSize(0, 5)];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
        
        [str appendString:NSLocalizedString(@"Compose.ChannelAboutPlaceholder", nil) withColor:DARK_GRAY];
        [str setAlignment:NSLeftTextAlignment range:str.range];
        [str setFont:[NSFont fontWithName:@"HelveticaNeue" size:15] forRange:str.range];
        
        [self.aboutTextView.cell setPlaceholderAttributedString:str];
        [self.aboutTextView setPlaceholderPoint:NSMakePoint(2, 0)];
        
        
        [_editAboutContainer addSubview:self.aboutTextView];
        
        
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
            
            [[Telegram rightViewController] showComposeChangeUserName:action];
            
            
        }];
        
        self.managmentButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.Managment", nil) tapBlock:^{
            
            
             [[Telegram rightViewController] showComposeManagment:_composeActionManagment];
            
            
        }];
        
        [self addSubview:self.managmentButton];
        
        
        self.blackListButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.ChannelBlackList", nil) tapBlock:^{
            
            
            [[Telegram rightViewController] showComposeChannelBlackList:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBlackListBehavior class] filter:@[] object:self.controller.chat]];
            
        }];
        
        [self addSubview:self.blackListButton];
        
        
        self.membersButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.ChannelMembers", nil) tapBlock:^{
            
            
            [[Telegram rightViewController] showComposeChannelMembers:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBehavior class] filter:@[] object:self.controller.chat]];
            
        }];
        
        [self addSubview:self.membersButton];
        
        
        self.enableCommentsButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.EnableComments", nil) tapBlock:nil];
        
        
        _commentsSwitch = [[ITSwitch alloc] initWithFrame:NSMakeRect(0, 0, 30, 20)];
        
        weak();
        
        [_commentsSwitch setDidChangeHandler:^(BOOL isOn){
           
            [TMViewController showModalProgress];
            
            
             [RPCRequest sendRequest:[TLAPI_channels_toggleComments createWithChannel:weakSelf.controller.chat.inputPeer enabled:isOn] successHandler:^(id request, id response) {
                 

                 
             } errorHandler:^(id request, RpcError *error) {
                 
             }];
            
            [TMViewController hideModalProgress];
            
        }];
        
        [self.enableCommentsButton setRightContainer:_commentsSwitch];
        
        
        [self addSubview:self.enableCommentsButton];
        
        self.linkTextField = [TMTextField defaultTextField];
        
        [self.linkTextField setFont:TGSystemFont(13)];
        [self.linkTextField setTextColor:GRAY_TEXT_COLOR];
        
        
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
        
        self.openOrJoinChannelButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.OpenChannel", nil) tapBlock:^{
            
            [[Telegram rightViewController] showByDialog:self.controller.chat.dialog sender:self];
            
        }];
        
        
        [self addSubview:self.openOrJoinChannelButton];
        
    }
    
    return self;
}

- (void)reload {
    
    
    TLChat *chat = self.controller.chat;
    
    _composeActionManagment = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBehavior class] filter:@[] object:chat];
    
    
    if(chat.isAdmin || chat.isModerator || chat.isPublisher) {
        [RPCRequest sendRequest:[TLAPI_channels_getParticipants createWithChannel:self.controller.chat.inputPeer filter:[TL_channelParticipantsAdmins create] offset:0 limit:100] successHandler:^(id request, TL_channels_channelParticipants *response) {
            
            [SharedManager proccessGlobalResponse:response];
            
            _composeActionManagment.result = [[ComposeResult alloc] initWithMultiObjects:response.participants];
            
            
        } errorHandler:^(id request, RpcError *error) {
            
        }];
    }
    
    
    
    [[FullChatManager sharedManager]  performLoad:chat.n_id callback:^(TLChatFull *fullChat) {
        
        self.controller.fullChat = fullChat;
        
        
        [self.aboutTextView setStringValue:self.controller.fullChat.about];
        
        [self.statusTextField setChat:chat];
        [self.statusTextField sizeToFit];
        
        if(!self.controller.fullChat) {
            MTLog(@"full chat is not loading");
            return;
        }
        
        
        if(self.controller.chat.username.length > 0) {
            [self.linkTextField setStringValue:[NSString stringWithFormat:@"/%@",self.controller.chat.username]];
            [self.linkTextField sizeToFit];
            [self.linkEditButton setRightContainer:self.linkTextField];
        } else {
            [self.linkEditButton setRightContainer:nil];
        }
        
        [_commentsSwitch setOn:!chat.isBroadcast];
        
        [self.sharedLinksButton setConversation:self.controller.chat.dialog];
        [self.filesMediaButton setConversation:self.controller.chat.dialog];
        [self.sharedMediaButton setConversation:self.controller.chat.dialog];
        
        
        
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

-(void)rebuildOrigins {
    
    [self.exportChatInvite setHidden:YES];
    [self.sharedMediaButton setHidden:self.type == ChatInfoViewControllerEdit];
    [self.filesMediaButton setHidden:self.type == ChatInfoViewControllerEdit];
    [self.sharedLinksButton setHidden:self.type == ChatInfoViewControllerEdit];
    
    
    [self.linkView setHidden:self.type == ChatInfoViewControllerEdit || self.linkView.string.length == 0];
    [self.aboutView setHidden:self.type == ChatInfoViewControllerEdit || self.aboutView.string.length == 0];
    
    
    
    [self.editAboutContainer setHidden:self.type != ChatInfoViewControllerEdit];
    
    [self.linkEditButton setHidden:self.type != ChatInfoViewControllerEdit];
    [self.setGroupPhotoButton setHidden:self.type != ChatInfoViewControllerEdit];
    [self.openOrJoinChannelButton setHidden:self.type == ChatInfoViewControllerEdit];
   
    
    [self.managmentButton setHidden:self.type != ChatInfoViewControllerEdit];
    [self.membersButton setHidden:self.type != ChatInfoViewControllerEdit];
    [self.blackListButton setHidden:self.type != ChatInfoViewControllerEdit];
    [self.enableCommentsButton setHidden:self.type != ChatInfoViewControllerEdit];
    
    [self.addMembersButton setHidden:self.type != ChatInfoViewControllerEdit];
    
    
     int yOffset = 42;
    
    [self.notificationView setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
    
    if(self.type != ChatInfoViewControllerEdit) {
       
        
        yOffset+=42;
        
        [self.sharedLinksButton setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=42;
        
        [self.filesMediaButton setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=42;
        
        [self.sharedMediaButton setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=42;
    } else {
        
        yOffset+=42;
        
        [self.managmentButton setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=42;
        
        [self.membersButton setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=42;
       
        [self.blackListButton setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=42;
    }
    
    
    if(!self.addMembersButton.isHidden) {
        yOffset+=42;
        
        [self.addMembersButton setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, 42)];
    }
    
    
    
    if(self.type == ChatInfoViewControllerNormal) {
        
        if(!self.openOrJoinChannelButton.isHidden) {
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
        
    } else {
        
        yOffset+=42;
        
        
        
        [self.enableCommentsButton setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=42;
        
        [self.linkEditButton setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=NSHeight(self.linkEditButton.frame);
        
        
        [self.setGroupPhotoButton setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=NSHeight(self.setGroupPhotoButton.frame) + 42;
        
        
        [_editAboutContainer setFrameSize:NSMakeSize(NSWidth(self.frame) - 200, NSHeight(_editAboutContainer.frame))];
        
        [self.editAboutContainer setFrameOrigin:NSMakePoint(100, yOffset)];
        
        yOffset+=NSHeight(self.editAboutContainer.frame);
        
    }
    
    [self.nameTextField setFrameOrigin:NSMakePoint(180, yOffset + (NSHeight(self.avatarImageView.frame)/2) + roundf(NSHeight(self.statusTextField.frame)/2 + NSHeight(self.nameTextField.frame)/2)) ];
    
    [self.statusTextField setFrameOrigin:NSMakePoint(178, yOffset + (NSHeight(self.avatarImageView.frame)/2)  )];

    
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
    
    
    [_aboutTextView setFrameSize:NSMakeSize(NSWidth(_editAboutContainer.frame), NSHeight(_aboutTextView.frame))];
    [_aboutDescription setFrameSize:NSMakeSize(NSWidth(_editAboutContainer.frame), 18)];
    
    [self.nameLiveView setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.nameLiveView.frame) - 100, NSHeight(self.nameLiveView.frame))];
    [self.nameTextField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.nameTextField.frame) - 100, NSHeight(self.nameTextField.frame))];
    
}

-(void)save {
    dispatch_block_t block = ^{
        self.controller.type = ChatInfoViewControllerNormal;
        [self reload];
        
        [TMViewController hideModalProgress];
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
    
    [TMViewController showModalProgress];
    
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
