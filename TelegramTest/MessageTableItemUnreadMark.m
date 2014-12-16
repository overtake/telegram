//
//  MessageTableItemUnreadMark.m
//  Messenger for Telegram
//
//  Created by keepcoder on 14.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemUnreadMark.h"

@implementation MessageTableItemUnreadMark


-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        self.viewSize = NSMakeSize(0, 26);
    }
    return self;
}

-(id)initWithCount:(int)unread_count type:(RemoveUnreadMarkType)type {
    if(self = [super init]) {
        _removeType = type;
        self.viewSize = NSMakeSize(0, 26);
        _unread_count = unread_count;
        _text = NSLocalizedString(@"Messages.UnreadMessages", nil);
    }
    return self;
}

@end
