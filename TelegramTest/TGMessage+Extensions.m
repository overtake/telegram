//
//  TGMessage+Extensions.m
//  TelegramTest
//
//  Created by keepcoder on 28.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TGMessage+Extensions.h"

@implementation TGMessage (Extensions)

-(int)peer_id {
    int peer_id;
    if([self.to_id chat_id] != 0) {
        if(self.to_id.class == [TL_peerSecret class] || self.to_id.class == [TL_peerBroadcast class])
            peer_id = self.to_id.chat_id;
        else
            peer_id = -self.to_id.chat_id;
    }
    else
        if([self n_out])
            peer_id = self.to_id.user_id;
        else
            peer_id = self.from_id;
    return peer_id;
}

-(TGPeer *)peer {
    
    if([self.to_id chat_id] != 0)
        return self.to_id;
    else {
        if([self n_out])
            return [TL_peerUser createWithUser_id:self.to_id.user_id];
        else
            return [TL_peerUser createWithUser_id:self.from_id];
        
    }
}



-(BOOL)n_out {
    return (self.flags & TGOUTMESSAGE) == TGOUTMESSAGE;
}


-(BOOL)unread {
   return (self.flags & TGUNREADMESSAGE) == TGUNREADMESSAGE;
}


@end
