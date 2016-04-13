//
//  TL_messageFwdHeader+Extension.m
//  Telegram
//
//  Created by keepcoder on 18/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TLMessageFwdHeader+Extension.h"

@implementation TLMessageFwdHeader (Extension)


-(TLPeer *)fwdPeer {
    TL_channel *channel;
    
    if(self.channel_id != 0)
        channel = [[ChatsManager sharedManager] find:self.channel_id];
    
    if(!channel || channel.isMegagroup) {
        return [TL_peerUser createWithUser_id:self.from_id];
    } else if(self.channel_id != 0) {
        return [TL_peerChannel createWithChannel_id:self.channel_id];
    }
    
    return nil;
}

@end
