//
//  TL_secretPeer.h
//  Telegram P-Edition
//
//  Created by keepcoder on 06.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MTProto.h"

@interface TL_peerSecret : TL_peerChat
+(TL_peerSecret *)createWithChat_id:(int)chat_id;
@end
