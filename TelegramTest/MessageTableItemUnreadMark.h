//
//  MessageTableItemUnreadMark.h
//  Messenger for Telegram
//
//  Created by keepcoder on 14.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"

@interface MessageTableItemUnreadMark : MessageTableItem
@property (nonatomic,assign,readonly) int unread_count;
@property (nonatomic,strong,readonly) NSString *text;

typedef enum {
    RemoveUnreadMarkAfterSecondsType,
    RemoveUnreadMarkNoneType
} RemoveUnreadMarkType;


@property (nonatomic,assign) RemoveUnreadMarkType removeType;

-(id)initWithCount:(int)unread_count type:(RemoveUnreadMarkType)type;
@end
