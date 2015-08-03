//
//  NotificationConversationRowItem.h
//  Telegram
//
//  Created by keepcoder on 29.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@interface NotificationConversationRowItem : TMRowItem

@property (nonatomic,strong) TL_conversation *conversation;

@property (nonatomic,strong) NSAttributedString *title;

@end
