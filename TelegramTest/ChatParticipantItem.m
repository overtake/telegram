//
//  ChatParticipantItem.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/21/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ChatParticipantItem.h"

@implementation ChatParticipantItem

- (id)initWithObject:(TLChatParticipant *)object {
    self = [super initWithObject:object];
    if(self) {
        self.user = [[UsersManager sharedManager] find:object.user_id];
    }
    return self;
}

-(id)initWithUser:(TLUser *)user {
    if(self = [super init]) {
        self.user = user;
    }
    return self;
}

- (NSObject *)itemForHash {
    return @(self.user.n_id);
}

+ (NSUInteger)hash:(NSObject *)object {
    return [object hash];
}

@end
