//
//  ChatInfoViewController.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/9/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "UserInfoShortButtonView.h"
#import "ChatAvatarImageView.h"
@interface ChatHeaderItem : TMRowItem
@end

@interface ChatBottomItem : TMRowItem
@end


@interface ChatBottomView : TMRowView
@property (nonatomic,strong) UserInfoShortButtonView *button;
@property (nonatomic,strong) TL_conversation *conversation;

@end

@class ChatParticipantItem;
@class ChatInfoHeaderView;
typedef enum {
    ChatInfoViewControllerNormal,
    ChatInfoViewControllerEdit,
} ChatInfoViewControllerType;

@interface ChatInfoViewController : TMViewController<TMTableViewDelegate>


@property (nonatomic,weak) MessagesViewController *messagesViewController;

@property (nonatomic, strong) TLChat *chat;
@property (nonatomic) ChatInfoViewControllerType type;

@property (nonatomic,strong,readonly) ChatBottomView *bottomView;
@property (nonatomic, strong,readonly) TMTableView *tableView;
@property (nonatomic, strong) ChatInfoHeaderView *headerView;

@property (nonatomic, strong,readonly) ChatHeaderItem *headerItem;
@property (nonatomic, strong,readonly) ChatBottomItem *bottomItem;

@property (nonatomic, strong) TLChatFull *fullChat;

@property (nonatomic) BOOL notNeedToUpdate;

- (void)kickParticipantByItem:(ChatParticipantItem *)item;
- (void)save;

- (void)buildFirstItem;
- (void)buildRightView;

@end
