//
//  MessageTableItemUnreadMark.m
//  Messenger for Telegram
//
//  Created by keepcoder on 14.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemUnreadMark.h"

@implementation MessageTableItemUnreadMark

@synthesize unread_count = _unread_count;
@synthesize text = _text;

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        self.viewSize = NSMakeSize(0, 26);
    }
    return self;
}

-(id)initWithCount:(int)unread_count {
    if(self = [super init]) {
        self.viewSize = NSMakeSize(0, 26);
        _unread_count = unread_count;
        _text = NSLocalizedString(@"Messages.UnreadMessages", nil);
    }
    return self;
}

@end
