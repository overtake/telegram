//
//  DialogTableItem.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/18/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMElements.h"

@interface ConversationTableItem : TMRowItem
@property (nonatomic, strong) TL_conversation *conversation;
@property (nonatomic, strong) TL_localMessage *lastMessage;

@property (nonatomic, strong) TLUser *user;
@property (nonatomic, strong) TLChat *chat;
@property (nonatomic, strong) TL_broadcast *broadcast;

@property (nonatomic) DialogType type;
@property (nonatomic) BOOL isRead;
@property (nonatomic) BOOL isOut;
@property (nonatomic) BOOL isMuted;


@property (nonatomic, strong) NSMutableAttributedString *date;
@property (nonatomic) NSSize dateSize;

@property (nonatomic, strong) NSMutableAttributedString *messageText;

@property (nonatomic, strong) NSString *unreadTextCount;
@property (nonatomic) NSSize unreadTextSize;

@property (nonatomic, strong) NSMutableAttributedString *writeAttributedString;
@property (nonatomic) BOOL isTyping;

@property (nonatomic,strong) NSString *selectString;

- (id)initWithConversationItem:(TL_conversation *)conversation;
- (id)initWithConversationItem:(TL_conversation *)conversation selectString:(NSString *)selectString;
@end
