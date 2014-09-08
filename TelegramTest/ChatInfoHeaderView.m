//
//  ChatInfoHeaderView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/9/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ChatInfoHeaderView.h"
#import "TMAvatarImageView.h"
#import "UserInfoShortButtonView.h"
#import "ChatInfoNotificationView.h"
#import "ChatAvatarImageView.h"
#import "SelectUserItem.h"
#import "PreviewObject.h"
#import "TMPreviewChatPicture.h"
#import "TMMediaUserPictureController.h"
#import "PhotoHistoryFilter.h"
#import "TMSharedMediaButton.h"
#import "ComposeActionAddGroupMembersBehavior.h"

@implementation LineView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColorFromRGB(0xe6e6e6) set];
    NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, 1));
}

@end

@interface ChatInfoHeaderView()
@property (nonatomic, strong) TGChatFull *fullChat;




@end

@implementation ChatInfoHeaderView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        weakify();
        
        
        float offsetRight = self.bounds.size.width - 286;
        
        _avatarImageView = [ChatAvatarImageView standartUserInfoAvatar];
        [self.avatarImageView setFrameOrigin:NSMakePoint(30, self.bounds.size.height - self.avatarImageView.bounds.size.height - 30)];
        [self addSubview:self.avatarImageView];
        
        [self.avatarImageView setSourceType:ChatAvatarSourceGroup];
        
        
        [self.avatarImageView setTapBlock:^{
            
            if(strongSelf.avatarImageView.sourceType != ChatAvatarSourceBroadcast) {
                PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:0 media:strongSelf.fullChat.chat_photo peer_id:strongSelf.fullChat.n_id];
                
                previewObject.reservedObject = strongSelf.avatarImageView;
                
                
                TMPreviewChatPicture *picture = [[TMPreviewChatPicture alloc] initWithItem:previewObject];
                if(picture)
                    [[TMMediaUserPictureController controller] show:picture];
            } 
            
        }];
        
        self.nameTextField = [[TMNameTextField alloc] init];
        [self.nameTextField setNameDelegate:self];
        [self.nameTextField setSelector:@selector(titleForChatInfo)];
        [self.nameTextField setTextColor:NSColorFromRGB(0x333333)];
        [self.nameTextField setEditable:NO];
        [self.nameTextField setSelectable:YES];
        [[self.nameTextField cell] setFocusRingType:NSFocusRingTypeNone];
        [self.nameTextField setFont:[NSFont fontWithName:@"Helvetica" size:22]];
        [self.nameTextField setTarget:self];
        [self.nameTextField setAction:@selector(enter)];
        [self addSubview:self.nameTextField];
        
        _nameLiveView = [[LineView alloc] initWithFrame:NSMakeRect(170, self.bounds.size.height - 80, offsetRight, 1)];
        [self.nameLiveView setHidden:YES];
        [self addSubview:self.nameLiveView];
        
        _createdByTextField = [[TMHyperlinkTextField alloc] init];
        [self.createdByTextField setBordered:NO];
        [self addSubview:self.createdByTextField];
        
        _setGroupPhotoButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.SetGroupPhoto", nil) tapBlock:^{
            [self.avatarImageView showUpdateChatPhotoBox];
        }];
        [self.setGroupPhotoButton setFrameSize:NSMakeSize(offsetRight, 0)];
        [self.setGroupPhotoButton setFrameOrigin:NSMakePoint(170, self.bounds.size.height - 146)];
        [self addSubview:self.setGroupPhotoButton];
        
        
        _addMembersButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Group.AddMembers", nil) tapBlock:^{
            
            NSMutableArray *filter = [[NSMutableArray alloc] init];
            
            for (TL_chatParticipant *participant in self.fullChat.participants.participants) {
                [filter addObject:@(participant.user_id)];
            }
            
            
            if(self.fullChat.participants.participants.count < MAX_CHAT_USERS)
                [[Telegram rightViewController] showComposeWithAction:[[ComposeAction alloc]initWithBehaviorClass:[ComposeActionAddGroupMembersBehavior class] filter:filter object:self.fullChat]];
            
            
        }];
        
        [self.addMembersButton setFrameSize:NSMakeSize(self.setGroupPhotoButton.bounds.size.width, 0)];
        [self.addMembersButton setFrameOrigin:NSMakePoint(self.setGroupPhotoButton.frame.origin.x, self.setGroupPhotoButton.frame.origin.y - 42)];
        
       
       
        [self addSubview:self.addMembersButton];
        
        
        self.sharedMediaButton = [TMSharedMediaButton buttonWithText:NSLocalizedString(@"Profile.SharedMedia", nil) tapBlock:^{
            
            [[Telegram rightViewController].messagesViewController setHistoryFilter:[PhotoHistoryFilter class] force:NO];
            
            [[Telegram rightViewController] showByDialog:self.controller.chat.dialog
                                                withJump:0 historyFilter:[PhotoHistoryFilter class] sender:self];
        }];
        
        [self.sharedMediaButton setFrameSize:NSMakeSize(self.addMembersButton.bounds.size.width, 0)];
        [self.sharedMediaButton setFrameOrigin:NSMakePoint(self.addMembersButton.frame.origin.x, self.addMembersButton.frame.origin.y - 72)];
        
        [self addSubview:self.sharedMediaButton];

        
       _notificationView = [[ChatInfoNotificationView alloc] initWithFrame:NSMakeRect(30, self.sharedMediaButton.frame.origin.y - 40 - 20, self.bounds.size.width - 60, 40)];
        
        [self.notificationView.switchControl setDidChangeHandler:^(BOOL change) {
            
            
            TL_conversation *dialog = [[DialogsManager sharedManager] findByChatId:strongSelf.controller.chat.n_id];
            
            BOOL isMute =  dialog.isMute;
            if(isMute == change) {
                [dialog muteOrUnmute:nil];
            }
            
        }];
        [self addSubview:self.notificationView];
        
        

        
    }
    return self;
}

- (void)rebuild {
    
}

- (void)enter {
    [self.controller save];
}



- (void)setType:(ChatInfoViewControllerType)type {
    self->_type = type;
    
    float duration = 0.08;
    [self.createdByTextField prepareForAnimation];
    [self.nameLiveView prepareForAnimation];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.createdByTextField setHidden:self.createdByTextField.layer.opacity == 0];
        [self.nameLiveView setHidden:self.nameLiveView.layer.opacity == 0];
    }];
    switch (self->_type) {
        case ChatInfoViewControllerEdit: {
            [self.nameTextField setEditable:YES];
            if([self.nameTextField becomeFirstResponder]) {
                 [self.nameTextField setCursorToEnd];
            }
           
            [self.createdByTextField setAnimation:[TMAnimations fadeWithDuration:duration fromValue:1 toValue:0] forKey:@"opacity"];
            [self.nameLiveView setAnimation:[TMAnimations fadeWithDuration:duration fromValue:0 toValue:1] forKey:@"opacity"];
        }
            break;
            
        case ChatInfoViewControllerNormal: {
            [self.nameTextField setEditable:NO];
            [self.createdByTextField setAnimation:[TMAnimations fadeWithDuration:duration fromValue:0 toValue:1] forKey:@"opacity"];
            [self.nameLiveView setAnimation:[TMAnimations fadeWithDuration:duration fromValue:1 toValue:0] forKey:@"opacity"];

        }
            break;
            
        default:
            break;
    }
    [CATransaction commit];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if(self.window.firstResponder != self.nameTextField) {
        if([self.nameTextField becomeFirstResponder])
            [self.nameTextField setCursorToEnd];
    }
}

- (NSString *)title {
    return self.nameTextField.stringValue;
}

- (void) TMNameTextFieldDidChanged:(TMNameTextField *)textField {
    [self.nameTextField sizeToFit];
    [self.nameTextField setFrame:NSMakeRect(178, self.bounds.size.height - 44   - self.nameTextField.bounds.size.height, self.bounds.size.width - 178 - 30, self.nameTextField.bounds.size.height)];
}

- (void)setController:(ChatInfoViewController *)controller {
    self->_controller = controller;
    
    self.avatarImageView.controller = controller;
}

- (void)reload {
    
    TGChat *chat = self.controller.chat;
    
    self.fullChat = [[FullChatManager sharedManager] find:chat.n_id];
    if(!self.fullChat) {
        NSLog(@"full chat is not loading");
        return;
    }
    
    [[TMMediaUserPictureController controller] removeAllObjects];
    
    [self.avatarImageView setChat:chat];
    [self.avatarImageView rebuild];
    
    [self.nameTextField setChat:chat];
    
    [_mediaView setConversation:chat.dialog];
    [self.sharedMediaButton setConversation:chat.dialog];
    
    NSMutableAttributedString *createdByAttributedString = [[NSMutableAttributedString alloc] init];
    [createdByAttributedString appendString:NSLocalizedString(@"Profile.CreatedBy", nil) withColor:NSColorFromRGB(0xa1a1a1)];
    TGUser *user = [[UsersManager sharedManager] find:self.fullChat.participants.admin_id];
    NSRange range = [createdByAttributedString appendString:user.fullName withColor:NSColorFromRGB(0xa1a1a1)];
    [createdByAttributedString setLink:[TMInAppLinks userProfile:user.n_id] forRange:range];
    [createdByAttributedString setFont:[NSFont fontWithName:@"Helvetica-Light" size:13] forRange:createdByAttributedString.range];
    [self.createdByTextField setAttributedStringValue:createdByAttributedString];
    [self.createdByTextField sizeToFit];
    [self.createdByTextField setFrameOrigin:NSMakePoint(self.nameTextField.frame.origin.x, self.nameTextField.frame.origin.y - self.createdByTextField.bounds.size.height - 3)];
    
    BOOL isMute = chat.dialog.isMute;
    [self.notificationView.switchControl setOn:!isMute animated:YES];
}


- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

@end
