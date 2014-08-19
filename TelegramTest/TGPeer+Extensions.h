//
//  TGPeer+Extensions.h
//  TelegramTest
//
//  Created by keepcoder on 28.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TLRPC.h"

@interface TGPeer (Extensions)
-(int)peer_id;
-(BOOL)isChat;
+(TGPeer *)peerForId:(int)peer_id;
-(TGPeer *)peerOut;
-(BOOL)isSecret;
-(BOOL)isBroadcast;
@end
