//
//  TLPeer+Extensions.h
//  TelegramTest
//
//  Created by keepcoder on 28.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "MTProto.h"

@interface TLPeer (Extensions)
-(int)peer_id;
-(BOOL)isChat;
+(TLPeer *)peerForId:(int)peer_id;
-(TLPeer *)peerOut;
-(TLInputPeer *)inputPeer;
-(BOOL)isSecret;
-(BOOL)isBroadcast;
@end
