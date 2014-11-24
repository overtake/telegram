//
//  TLPeer+Extensions.m
//  TelegramTest
//
//  Created by keepcoder on 28.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TLPeer+Extensions.h"
#import "TL_peerSecret.h"
@implementation TLPeer (Extensions)

- (int)peer_id {
    return  self.chat_id != 0 ? ([self isSecret] || ([self isBroadcast]) ? self.chat_id : -self.chat_id) : self.user_id;
}

- (BOOL)isChat {
    return self.chat_id != 0;
}

- (BOOL)isSecret {
    return [self isKindOfClass:[TL_peerSecret class]];
}


- (BOOL)isBroadcast {
    return [self isKindOfClass:[TL_peerBroadcast class]];
}



-(TLPeer *)peerOut {
    if(self.chat_id == 0)
        return [TL_peerUser createWithUser_id:self.user_id];
    else
        if([self isSecret] || [self isBroadcast]) return self;
    
    return [TL_peerChat createWithChat_id:self.chat_id];
}

+(TLPeer *)peerForId:(int)peer_id {
    if(peer_id < 0)
        return [TL_peerChat createWithChat_id:-peer_id];
    return [TL_peerUser createWithUser_id:peer_id];
};
@end
