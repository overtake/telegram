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
#import "TGPhotoViewer.h"
@implementation LineView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColorFromRGB(0xe6e6e6) set];
    NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, 1));
}

@end

@interface ChatInfoHeaderView()
@property (nonatomic, strong) TLChatFull *fullChat;




@end

@implementation ChatInfoHeaderView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        weakify();
        
        
        float offsetRight = self.bounds.size.width - 200;
        
        _avatarImageView = [ChatAvatarImageView standartUserInfoAvatar];
        
        [self.avatarImageView setFrameSize:NSMakeSize(70, 70)];
        
        [self.avatarImageView setFrameOrigin:NSMakePoint(100, self.bounds.size.height - self.avatarImageView.bounds.size.height - 30)];
        
        [self addSubview:self.avatarImageView];
        
        [self.avatarImageView setSourceType:ChatAvatarSourceGroup];
        
        
        [self.avatarImageView setTapBlock:^{
            
            if(strongSelf.avatarImageView.sourceType != ChatAvatarSourceBroadcast) {
                
                if(![strongSelf.fullChat.chat_photo isKindOfClass:[TL_photoEmpty class]]) {
                    
                    TL_photoSize *size = [strongSelf.fullChat.chat_photo.sizes lastObject];
                    
                    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:strongSelf.fullChat.chat_photo.n_id media:size peer_id:strongSelf.fullChat.n_id];
                    
                    previewObject.reservedObject = [TGCache cachedImage:strongSelf.controller.chat.photo.photo_small.cacheKey];
                    
                    [[TGPhotoViewer viewer] show:previewObject];
                }
               
//                
//                TMPreviewChatPicture *picture = [[TMPreviewChatPicture alloc] initWithItem:previewObject];
//                if(picture)
//                    [[TMMediaUserPictureController controller] show:picture];
            }
            
        }];
        
        self.nameTextField = [[TMNameTextField alloc] init];
        [self.nameTextField setNameDelegate:self];
        [self.nameTextField setSelector:@selector(titleForChatInfo)];
        [self.nameTextField setTextColor:NSColorFromRGB(0x333333)];
        [self.nameTextField setEditable:NO];
        [self.nameTextField setSelectable:YES];
        [[self.nameTextField cell] setFocusRingType:NSFocusRingTypeNone];
        [self.nameTextField setFont:[NSFont fontWithName:@"Helvetica" size:15]];
        [self.nameTextField setTarget:self];
        [self.nameTextField setAction:@selector(enter)];
        [self addSubview:self.nameTextField];
        
        _nameLiveView = [[LineView alloc] initWithFrame:NSMakeRect(185, self.bounds.size.height - 80, NSWidth(self.frame) - 310, 1)];
        [self.nameLiveView setHidden:YES];
        [self addSubview:self.nameLiveView];
        
        _statusTextField = [[TMStatusTextField alloc] init];
        
        [_statusTextField setSelector:@selector(statusForMessagesHeaderView)];
        
        
        [self.statusTextField setBordered:NO];
        [self addSubview:self.statusTextField];
        
        _setGroupPhotoButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.SetGroupPhoto", nil) tapBlock:^{
            [self.avatarImageView showUpdateChatPhotoBox];
        }];
        [self.setGroupPhotoButton setFrameSize:NSMakeSize(offsetRight, 42)];
        [self.setGroupPhotoButton setFrameOrigin:NSMakePoint(100, self.bounds.size.height - 156)];
        [self addSubview:self.setGroupPhotoButton];
        
        
        _addMembersButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Group.AddMembers", nil) tapBlock:^{
            
            NSMutableArray *filter = [[NSMutableArray alloc] init];
            
            for (TL_chatParticipant *participant in self.fullChat.participants.participants) {
                [filter addObject:@(participant.user_id)];
            }
            
            
            if(self.fullChat.participants.participants.count < maxChatUsers())
                [[Telegram rightViewController] showComposeWithAction:[[ComposeAction alloc]initWithBehaviorClass:[ComposeActionAddGroupMembersBehavior class] filter:filter object:self.fullChat]];
            
            
        }];
        
        [self.addMembersButton setFrameSize:NSMakeSize(self.setGroupPhotoButton.bounds.size.width, 42)];
        [self.addMembersButton setFrameOrigin:NSMakePoint(self.setGroupPhotoButton.frame.origin.x, self.setGroupPhotoButton.frame.origin.y - 42)];
        
       
       
        [self addSubview:self.addMembersButton];
        
        
        self.sharedMediaButton = [TMSharedMediaButton buttonWithText:NSLocalizedString(@"Profile.SharedMedia", nil) tapBlock:^{
            
            [[Telegram rightViewController] showCollectionPage:self.controller.chat.dialog];
            
            
          //  [[Telegram rightViewController].messagesViewController setHistoryFilter:[PhotoHistoryFilter class] force:NO];
            
           // [[Telegram rightViewController] showByDialog:self.controller.chat.dialog withJump:0 historyFilter:[PhotoHistoryFilter class] sender:self];
        }];
        
        [self.sharedMediaButton setFrameSize:NSMakeSize(self.addMembersButton.bounds.size.width, 42)];
        [self.sharedMediaButton setFrameOrigin:NSMakePoint(self.addMembersButton.frame.origin.x, self.addMembersButton.frame.origin.y - 72)];
        
        [self addSubview:self.sharedMediaButton];
        
        

        
        _notificationView = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Notifications", nil) tapBlock:^{
           
        }];
        
        _notificationSwitcher = [[ITSwitch alloc] initWithFrame:NSMakeRect(0, 0, 36, 20)];
        
        _notificationView.rightContainer = self.notificationSwitcher;
        
        [self.notificationSwitcher setDidChangeHandler:^(BOOL isOn) {
            
            TL_conversation *dialog = [[DialogsManager sharedManager] findByChatId:strongSelf.controller.chat.n_id];
            
            BOOL isMute =  dialog.isMute;
            if(isMute == isOn) {
                [dialog muteOrUnmute:nil];
            }

        }];
        
        [_notificationView setFrame:NSMakeRect(100,  NSMinY(self.sharedMediaButton.frame) - 42, NSWidth(self.frame) - 200, 42)];
        

        [self addSubview:self.notificationView];
        
        self.sharedMediaButton.textButton.textColor = self.notificationView.textButton.textColor = DARK_BLACK;
        
        

        
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
    [self.statusTextField prepareForAnimation];
    [self.nameLiveView prepareForAnimation];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.statusTextField setHidden:self.statusTextField.layer.opacity == 0];
        [self.nameLiveView setHidden:self.nameLiveView.layer.opacity == 0];
    }];
    switch (self->_type) {
        case ChatInfoViewControllerEdit: {
            [self.nameTextField setEditable:YES];
            if([self.nameTextField becomeFirstResponder]) {
                 [self.nameTextField setCursorToEnd];
            }
           
            [self.statusTextField setAnimation:[TMAnimations fadeWithDuration:duration fromValue:1 toValue:0] forKey:@"opacity"];
            [self.nameLiveView setAnimation:[TMAnimations fadeWithDuration:duration fromValue:0 toValue:1] forKey:@"opacity"];
        }
            break;
            
        case ChatInfoViewControllerNormal: {
            [self.nameTextField setEditable:NO];
            [self.statusTextField setAnimation:[TMAnimations fadeWithDuration:duration fromValue:0 toValue:1] forKey:@"opacity"];
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
    [self.nameTextField setFrame:NSMakeRect(185, self.bounds.size.height - 43   - self.nameTextField.bounds.size.height, self.bounds.size.width - 185 - 30, self.nameTextField.bounds.size.height)];
    
    
    [self.statusTextField sizeToFit];
    [self.statusTextField setFrame:NSMakeRect(182, self.nameTextField.frame.origin.y - self.statusTextField.bounds.size.height - 3, MIN(self.bounds.size.width - 310,NSWidth(self.statusTextField.frame)), self.nameTextField.bounds.size.height)];
}

- (void)setController:(ChatInfoViewController *)controller {
    self->_controller = controller;
    
    self.avatarImageView.controller = controller;
}

- (void)reload {
    
    TLChat *chat = self.controller.chat;
    
    [self.statusTextField setChat:chat];
    [self.statusTextField sizeToFit];
    
    self.fullChat = [[FullChatManager sharedManager] find:chat.n_id];
    if(!self.fullChat) {
        DLog(@"full chat is not loading");
        return;
    }
    
    [self.avatarImageView setChat:chat];
    [self.avatarImageView rebuild];
    
   
    
    [_mediaView setConversation:chat.dialog];
    [self.sharedMediaButton setConversation:chat.dialog];
    
    
    [self.nameTextField setChat:chat];
    
    BOOL isMute = chat.dialog.isMute;
    
    [self.notificationSwitcher setOn:!isMute animated:NO];
    [self TMNameTextFieldDidChanged:self.nameTextField];
}


- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

@end
