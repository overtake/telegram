//
//  TL_secretPeer.m
//  Telegram P-Edition
//
//  Created by keepcoder on 06.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_peerSecret.h"

@implementation TL_peerSecret

+(TL_peerSecret *)createWithChat_id:(int)chat_id {
    TL_peerSecret * obj = [[TL_peerSecret alloc] init];
	obj.chat_id = chat_id;
	return obj;

}
@end
