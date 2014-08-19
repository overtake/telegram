//
//  ChatInfoViewController.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/9/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"

@interface ChatHeaderItem : TMRowItem
@end

@interface ChatBottomItem : TMRowItem
@end

@class ChatParticipantItem;
@class ChatInfoHeaderView;
typedef enum {
    ChatInfoViewControllerNormal,
    ChatInfoViewControllerEdit,
} ChatInfoViewControllerType;

@interface ChatInfoViewController : TMViewController<TMTableViewDelegate>

@property (nonatomic, strong) TGChat *chat;
@property (nonatomic) ChatInfoViewControllerType type;

@property (nonatomic, strong,readonly) TMTableView *tableView;
@property (nonatomic, strong) ChatInfoHeaderView *headerView;

@property (nonatomic, strong,readonly) ChatHeaderItem *headerItem;
@property (nonatomic, strong,readonly) ChatBottomItem *bottomItem;

@property (nonatomic, strong) TGChatFull *fullChat;

@property (nonatomic) BOOL notNeedToUpdate;

- (void)kickParticipantByItem:(ChatParticipantItem *)item;
- (void)save;

- (void)buildFirstItem;
- (void)buildRightView;

@end
