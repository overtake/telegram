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
#import "MessagesUtils.h"
#import "ChatAdminsViewController.h"
@implementation LineView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColorFromRGB(0xe6e6e6) set];
    NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, 1));
}

@end

@interface ChatInfoHeaderView()
@property (nonatomic, strong) TLChatFull *fullChat;
@property (nonatomic,strong) TMTextField *muteUntilTitle;



@end

@implementation ChatInfoHeaderView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        weakify();
        
        
        float offsetRight = self.bounds.size.width - 200;
        
        _avatarImageView = [ChatAvatarImageView standartUserInfoAvatar];
        
        [self.avatarImageView setFrameSize:NSMakeSize(70, 70)];
        
        
        
        [self addSubview:self.avatarImageView];
        
        [self.avatarImageView setSourceType:ChatAvatarSourceGroup];
        
        
        [self.avatarImageView setTapBlock:^{
            
            if(strongSelf.avatarImageView.sourceType != ChatAvatarSourceBroadcast) {
                
                if(![strongSelf.fullChat.chat_photo isKindOfClass:[TL_photoEmpty class]] && strongSelf.fullChat.chat_photo) {
                    
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
        
        self.muteUntilTitle = [TMTextField defaultTextField];
        
        self.nameTextField = [[TMNameTextField alloc] init];
        [self.nameTextField setNameDelegate:self];
        [self.nameTextField setSelector:@selector(titleForChatInfo)];
        [self.nameTextField setTextColor:NSColorFromRGB(0x333333)];
        [self.nameTextField setEditable:NO];
        [self.nameTextField setSelectable:YES];
        [[self.nameTextField cell] setFocusRingType:NSFocusRingTypeNone];
        [self.nameTextField setFont:TGSystemFont(15)];
        [self.nameTextField setTarget:self];
        [self.nameTextField setAction:@selector(enter)];
        [self addSubview:self.nameTextField];
        
        [[self.nameTextField cell] setTruncatesLastVisibleLine:YES];
        
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
            
            
            if(self.fullChat.participants.participants.count < maxChatUsers()) {
                
                ComposePickerViewController *viewController = [[ComposePickerViewController alloc] initWithFrame:self.controller.view.bounds];
                
                [viewController setAction:[[ComposeAction alloc]initWithBehaviorClass:[ComposeActionAddGroupMembersBehavior class] filter:filter object:self.controller.fullChat reservedObjects:@[self.controller.chat]]];
                
                [self.controller.navigationViewController pushViewController:viewController animated:YES];
                
            }
            
            
            
        }];
        
        [self.addMembersButton setFrameSize:NSMakeSize(self.setGroupPhotoButton.bounds.size.width, 42)];
        [self.addMembersButton setFrameOrigin:NSMakePoint(self.setGroupPhotoButton.frame.origin.x, self.setGroupPhotoButton.frame.origin.y - 42)];
        
       
        [self addSubview:self.addMembersButton];
        
        
        _exportChatInvite = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Group.CopyExportChatInvite", nil) tapBlock:^{
            
            
            
            
            dispatch_block_t cblock = ^ {
                
                ChatExportLinkViewController *viewController = [[ChatExportLinkViewController alloc] initWithFrame:self.controller.view.frame];
                
                [viewController setChat:_fullChat];
                
                [self.controller.navigationViewController pushViewController:viewController animated:YES];

            };
            
            
            if([_fullChat.exported_invite isKindOfClass:[TL_chatInviteExported class]]) {
                
                cblock();
                
            } else {
                
                [self.controller showModalProgress];
                
                [RPCRequest sendRequest:[TLAPI_messages_exportChatInvite createWithChat_id:self.controller.chat.n_id] successHandler:^(RPCRequest *request, TL_chatInviteExported *response) {
                    
                    [self.controller hideModalProgressWithSuccess];
                    
                    _fullChat.exported_invite = response;
                    
                    [[Storage manager] insertFullChat:_fullChat completeHandler:nil];
                    
                    cblock();
                    
                    
                } errorHandler:^(RPCRequest *request, RpcError *error) {
                    [self.controller hideModalProgress];
                } timeout:10];
                
            }
            
            
            
            
        }];
        
        [_exportChatInvite setFrameSize:NSMakeSize(self.addMembersButton.bounds.size.width, 42)];
        [_exportChatInvite setFrameOrigin:NSMakePoint(self.addMembersButton.frame.origin.x, self.addMembersButton.frame.origin.y - 42)];
        
        
        
        [self addSubview:_exportChatInvite];
        
        
        
        
        self.sharedMediaButton = [TMSharedMediaButton buttonWithText:NSLocalizedString(@"Profile.SharedMedia", nil) tapBlock:^{
            
            TMCollectionPageController *viewController = [[TMCollectionPageController alloc] initWithFrame:self.controller.view.bounds];
            
            [viewController loadViewIfNeeded];
            
            [viewController setConversation:self.controller.chat.dialog];
            
            [self.controller.navigationViewController pushViewController:viewController animated:YES];
            
            [viewController showAllMedia];
        }];
        
        [self.sharedMediaButton setFrameSize:NSMakeSize(self.exportChatInvite.bounds.size.width, 42)];
        [self.sharedMediaButton setFrameOrigin:NSMakePoint(self.exportChatInvite.frame.origin.x, self.exportChatInvite.frame.origin.y - 72)];
        
        [self addSubview:self.sharedMediaButton];
        
        self.filesMediaButton = [TMSharedMediaButton buttonWithText:NSLocalizedString(@"Profile.SharedMediaFiles", nil) tapBlock:^{
            
            TMCollectionPageController *viewController = [[TMCollectionPageController alloc] initWithFrame:self.controller.view.bounds];
            
            [viewController loadViewIfNeeded];
            
            [viewController setConversation:self.controller.chat.dialog];
            
            [self.controller.navigationViewController pushViewController:viewController animated:YES];
            
            [viewController showFiles];
        }];
        
        
        
        [self.filesMediaButton setFrameSize:NSMakeSize(self.addMembersButton.bounds.size.width, 42)];
        
        [self.filesMediaButton setFrameOrigin:NSMakePoint(self.sharedMediaButton.frame.origin.x, self.sharedMediaButton.frame.origin.y -42)];
        
        [self addSubview:self.filesMediaButton];
        
        
        
        self.sharedLinksButton = [TMSharedMediaButton buttonWithText:NSLocalizedString(@"Conversation.Filter.SharedLinks", nil) tapBlock:^{
            
            TMCollectionPageController *viewController = [[TMCollectionPageController alloc] initWithFrame:self.controller.view.bounds];
            
            [viewController loadViewIfNeeded];
            
            [viewController setConversation:self.controller.chat.dialog];
            
            [self.controller.navigationViewController pushViewController:viewController animated:YES];
            
            [viewController showSharedLinks];

        }];
        
        
        
        [self.sharedLinksButton setFrameSize:NSMakeSize(self.filesMediaButton.bounds.size.width, 42)];
        
        [self.sharedLinksButton setFrameOrigin:NSMakePoint(self.sharedLinksButton.frame.origin.x, self.sharedLinksButton.frame.origin.y -42)];
        
        [self addSubview:self.sharedLinksButton];
        
        self.sharedMediaButton.type = TMSharedMediaPhotoVideoType;
        self.filesMediaButton.type = TMSharedMediaDocumentsType;
        self.sharedLinksButton.type = TMSharedMediaSharedLinksType;
                
        _notificationView = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Notifications", nil) tapBlock:^{
            
            
            NSMenu *menu = [MessagesViewController notifications:^{
                
                [self buildNotificationsTitle];
                
            } conversation:self.controller.chat.dialog click:^{
                
                
            }];;
            
            TMMenuPopover *menuPopover = [[TMMenuPopover alloc] initWithMenu:menu];
            
            [menuPopover showRelativeToRect:strongSelf.muteUntilTitle.bounds ofView:strongSelf.muteUntilTitle preferredEdge:CGRectMinYEdge];
            
        }];
        
        [_notificationView setFrame:NSMakeRect(100,  NSMinY(self.sharedLinksButton.frame) - 42, NSWidth(self.frame) - 200, 42)];
        

        [self addSubview:self.notificationView];
        
        
        
        _admins = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Chat.Administrators", nil) tapBlock:^{
            
            ChatAdminsViewController *viewController = [[ChatAdminsViewController alloc] initWithFrame:self.controller.view.bounds];
            
            viewController.chat = self.controller.chat;
            
            [self.controller.navigationViewController pushViewController:viewController animated:YES];
            
        }];
        
        [_admins setFrameSize:NSMakeSize(self.addMembersButton.bounds.size.width, 42)];
        
        [self addSubview:_admins];
        
        
        self.sharedLinksButton.textButton.textColor = self.filesMediaButton.textButton.textColor = self.sharedMediaButton.textButton.textColor = self.notificationView.textButton.textColor = DARK_BLACK;
        
        

        
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
    
    [self.statusTextField sizeToFit];
    
    [self setFrameSize:self.frame.size];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.nameTextField setFrame:NSMakeRect(185, self.bounds.size.height - 43   - self.nameTextField.bounds.size.height, MIN(self.bounds.size.width - 185 - 100, NSWidth(self.nameTextField.frame)), self.nameTextField.bounds.size.height)];
    
    [self.statusTextField setFrame:NSMakeRect(182, self.nameTextField.frame.origin.y - self.statusTextField.bounds.size.height - 3, MIN(self.bounds.size.width - 310,NSWidth(self.statusTextField.frame)), self.nameTextField.bounds.size.height)];
    
    [self.avatarImageView setFrameOrigin:NSMakePoint(100, self.bounds.size.height - self.avatarImageView.bounds.size.height - 30)];
}

- (void)setController:(ChatInfoViewController *)controller {
    self->_controller = controller;
    
    self.avatarImageView.controller = controller;
}

- (void)reload {
    
    TLChat *chat = self.controller.chat;
    
    [[FullChatManager sharedManager]  performLoad:chat.n_id callback:^(TLChatFull *fullChat) {
    
         self.fullChat = fullChat;
        
        BOOL cantEditGroup = !self.controller.chat.isCreator && ( self.controller.chat.isAdmins_enabled && !self.controller.chat.isAdmin );

        
        [self setFrameSize:NSMakeSize(NSWidth(self.frame), self.controller.chat.isCreator ? 500 : cantEditGroup ?  324 : 408)];
        
        [self.statusTextField setChat:chat];
        [self.statusTextField sizeToFit];
        
        if(!self.fullChat) {
            MTLog(@"full chat is not loading");
            return;
        }
        
        [self.avatarImageView setChat:chat];
        [self.avatarImageView rebuild];
        
        [_mediaView setConversation:chat.dialog];
        [self.sharedMediaButton setConversation:chat.dialog];
        [self.filesMediaButton setConversation:chat.dialog];
        [self.sharedLinksButton setConversation:chat.dialog];
        
        [self.nameTextField setChat:chat];
        
        
        [self buildNotificationsTitle];
        
        [self TMNameTextFieldDidChanged:self.nameTextField];
        
        
        [self.setGroupPhotoButton setFrameOrigin:NSMakePoint(100, self.bounds.size.height - 156)];
        [self.addMembersButton setFrameOrigin:NSMakePoint(self.setGroupPhotoButton.frame.origin.x, self.setGroupPhotoButton.frame.origin.y - 42)];
        
        [_addMembersButton setHidden:cantEditGroup];
        [_setGroupPhotoButton setHidden:cantEditGroup];
        
        [_exportChatInvite setFrameOrigin:NSMakePoint(self.sharedMediaButton.frame.origin.x,self.addMembersButton.isHidden ? _setGroupPhotoButton.frame.origin.y -42 : _addMembersButton.frame.origin.y-42)];
        
        [_exportChatInvite setHidden:!self.controller.chat.isCreator];
        
        
        [_admins setFrameOrigin:NSMakePoint(self.exportChatInvite.frame.origin.x,self.exportChatInvite.isHidden ? (self.addMembersButton.isHidden ? _setGroupPhotoButton.frame.origin.y -42 : _addMembersButton.frame.origin.y-42) : _exportChatInvite.frame.origin.y-42)];
        
        [_admins setHidden:!self.controller.chat.isCreator || !ACCEPT_FEATURE];
        
        
        [self.sharedMediaButton setFrameOrigin:NSMakePoint(NSMinX(_admins.isHidden ? self.addMembersButton.frame : self.admins.frame), (cantEditGroup ? NSHeight(self.frame) - 100 : NSMinY(_admins.isHidden ? self.addMembersButton.frame : self.admins.frame)) - 72)];
        
        
        [self.filesMediaButton setFrameOrigin:NSMakePoint(self.sharedMediaButton.frame.origin.x, self.sharedMediaButton.frame.origin.y -42)];
        
        [self.sharedLinksButton setFrameOrigin:NSMakePoint(self.filesMediaButton.frame.origin.x, self.filesMediaButton.frame.origin.y -42)];
        
        [_notificationView setFrame:NSMakeRect(100,  NSMinY(self.sharedLinksButton.frame) - 42, NSWidth(self.frame) - 200, 42)];
        

       
        
        [self.controller buildFirstItem];

    }];
    
   
    
}

-(void)buildNotificationsTitle  {
    
    static NSTextAttachment *attach;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attach = [NSMutableAttributedString textAttachmentByImage:[image_selectPopup() imageWithInsets:NSEdgeInsetsMake(0, 10, 0, 0)]];
    });
    
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    NSString *str = [MessagesUtils muteUntil:self.controller.chat.dialog.notify_settings.mute_until];
    
    [string appendString:str withColor:NSColorFromRGB(0xa1a1a1)];
    
    [string setFont:TGSystemLightFont(15) forRange:NSMakeRange(0, string.length)];
    
    [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
    [self.muteUntilTitle setAttributedStringValue:string];
    
    [self.muteUntilTitle sizeToFit];
    
    self.notificationView.rightContainer = self.muteUntilTitle;
    
}

-(void)save {
    
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
    if(self.controller.chat.dialog.type == DialogTypeChannel && self.controller.chat.dialog.chat.isVerified) {
        [image_Verify() drawInRect:NSMakeRect(NSMaxX(self.nameTextField.frame),NSMinY(self.nameTextField.frame) +1 , image_Verify().size.width, image_Verify().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
    }
}

@end
