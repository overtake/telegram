//
//  ChannelInfoHeaderView.m
//  Telegram
//
//  Created by keepcoder on 21.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ChannelInfoHeaderView.h"
#import "UserInfoParamsView.h"

@interface ChannelInfoHeaderView ()
@property (nonatomic,strong) UserInfoParamsView *linkView;
@property (nonatomic,strong) UserInfoParamsView *aboutView;

@property (nonatomic,strong) UserInfoShortButtonView *linkEditButton;
@property (nonatomic,strong) UserInfoShortButtonView *aboutEditButton;

@end

@implementation ChannelInfoHeaderView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.linkView = [[UserInfoParamsView alloc] initWithFrame:NSMakeRect(100, 50, 200, 61)];
        [self.linkView setHeader:NSLocalizedString(@"Profile.Link", nil)];
        [self addSubview:self.linkView];
        
        
        self.aboutView = [[UserInfoParamsView alloc] initWithFrame:NSMakeRect(100, 50, 200, 61)];
        [self.aboutView setHeader:NSLocalizedString(@"Profile.About", nil)];
        [self addSubview:self.aboutView];
        
        
        
        self.linkEditButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.Link", nil) tapBlock:^{
            
            [self setType:ChatInfoViewControllerNormal];
            
            [[Telegram rightViewController] showUserNameControllerWithChannel:(TL_channel *)self.controller.chat completionHandler:^{
                [self reload];
                [self.controller.navigationViewController goBackWithAnimation:YES];
            }];
            
        }];
        
        
        self.aboutEditButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.About", nil) tapBlock:^{
            
            
            
        }];
        
        [self addSubview:self.linkEditButton];
        [self addSubview:self.aboutEditButton];
        
    }
    
    return self;
}

- (void)reload {
    
    
    TLChat *chat = self.controller.chat;
    
    [[FullChatManager sharedManager]  performLoad:chat.n_id isChannel:[chat isKindOfClass:[TL_channel class]] callback:^(TLChatFull *fullChat) {
        
        self.controller.fullChat = fullChat;
        
        [self.statusTextField setChat:chat];
        [self.statusTextField sizeToFit];
        
        if(!self.controller.fullChat) {
            MTLog(@"full chat is not loading");
            return;
        }
        
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
    [self.sharedMediaButton setHidden:YES];
    [self.filesMediaButton setHidden:YES];
    [self.sharedLinksButton setHidden:YES];
    
    
    [self.linkView setHidden:self.type == ChatInfoViewControllerEdit || self.linkView.string.length == 0];
    [self.aboutView setHidden:self.type == ChatInfoViewControllerEdit || self.aboutView.string.length == 0];
    
    
    [self.linkEditButton setHidden:self.type != ChatInfoViewControllerEdit];
    [self.aboutEditButton setHidden:self.type != ChatInfoViewControllerEdit];
    [self.setGroupPhotoButton setHidden:self.type != ChatInfoViewControllerEdit];
    
    
    [self.addMembersButton setHidden:!self.controller.chat.isAdmin];
    
    int yOffset = 0;
    
    [self.notificationView setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
    
    
    if(!self.addMembersButton.isHidden) {
        yOffset+=NSHeight(self.notificationView.frame);
        
        [self.addMembersButton setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, 42)];
    }
     
    
    yOffset+=42;
    
    
    
    if(self.type == ChatInfoViewControllerNormal) {
        
        if(!self.linkView.isHidden || !self.aboutView.isHidden) {
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
        
        [self.aboutEditButton setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=NSHeight(self.aboutEditButton.frame);
        
        [self.linkEditButton setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=NSHeight(self.linkEditButton.frame);
        
        [self.setGroupPhotoButton setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=NSHeight(self.setGroupPhotoButton.frame);
        
    }
    
    [self.nameTextField setFrameOrigin:NSMakePoint(180, yOffset + (NSHeight(self.avatarImageView.frame)/2) + roundf(NSHeight(self.statusTextField.frame)/2 + NSHeight(self.nameTextField.frame)/2)) ];
    
    [self.statusTextField setFrameOrigin:NSMakePoint(178, yOffset + (NSHeight(self.avatarImageView.frame)/2)  )];

    [self.nameLiveView setFrameOrigin:NSMakePoint(178, NSMinY(self.nameTextField.frame) - 5)];
    
    
    yOffset+=20;
    
    [self.avatarImageView setFrameOrigin:NSMakePoint(100, yOffset)];
    
    
    yOffset+=100;
    
    [self setFrameSize:NSMakeSize(NSWidth(self.frame), yOffset)];
    
    [self.controller buildFirstItem];

}


-(void)setType:(ChatInfoViewControllerType)type {
    [super setType:type];
    
    [self rebuildOrigins];
}


@end
