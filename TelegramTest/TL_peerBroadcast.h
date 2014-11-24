//
//  TL_peerBroadcast.h
//  Telegram
//
//  Created by keepcoder on 06.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MTProto.h"

@interface TL_peerBroadcast : TL_peerChat
+(TL_peerBroadcast *)createWithChat_id:(int)chat_id;
@end
