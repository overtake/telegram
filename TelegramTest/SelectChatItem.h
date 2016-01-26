//
//  SelectChatItem.h
//  Telegram
//
//  Created by keepcoder on 05.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@interface SelectChatItem : TMRowItem
@property (nonatomic,strong,readonly) TLChat *chat;

@property (nonatomic) BOOL isSelected;

@end
