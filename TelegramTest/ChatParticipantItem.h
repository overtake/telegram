//
//  ChatParticipantItem.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/21/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@interface ChatParticipantItem : TMRowItem

- (id)initWithObject:(TLChatParticipant *)object;

- (id)initWithUser:(TLUser *)user;

@property (nonatomic, strong) TLUser *user;
@property (nonatomic, strong) ChatInfoViewController *viewController;

@property (nonatomic) BOOL isBlocking;
@property (nonatomic) BOOL isCanKicked;

@property (nonatomic, strong) NSAttributedString *membersCount;
@property (nonatomic, strong) NSAttributedString *onlineCount;

@end
