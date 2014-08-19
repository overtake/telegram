//
//  TL_peerBroadcast.m
//  Telegram
//
//  Created by keepcoder on 06.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_peerBroadcast.h"

@implementation TL_peerBroadcast


+(TL_peerBroadcast *)createWithChat_id:(int)chat_id {
    
    TL_peerBroadcast *peer = [[TL_peerBroadcast alloc] init];
    
    peer.chat_id = chat_id;
    
    return peer;
}


@end
