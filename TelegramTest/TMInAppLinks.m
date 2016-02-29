//
//  TMInAppLinks.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/5/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMInAppLinks.h"
#import "Telegram.h"
#import "TLPeer+Extensions.h"
#import "TGHeadChatPanel.h"
@implementation TMInAppLinks

+ (NSString *) userProfile:(int)user_id {
    return [NSString stringWithFormat:@"chat://TL_peerUser/%d", user_id];
}

+ (NSString *)peerProfile:(TLPeer*)peer jumpId:(int)jump_id {
    if(jump_id > 0) {
        return [NSString stringWithFormat:@"chat://%@/%d/%d",peer.className,peer.peer_id,jump_id];
    } else {
        return [self peerProfile:peer];
    }
    
}

+ (NSString *)peerProfile:(TLPeer*)peer {
    return [NSString stringWithFormat:@"chat://%@/%d",peer.className,peer.peer_id];
}


@end
