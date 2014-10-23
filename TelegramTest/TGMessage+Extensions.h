//
//  TGMessage+Extensions.h
//  TelegramTest
//
//  Created by keepcoder on 28.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TLRPC.h"

@interface TGMessage (Extensions)
-(int)peer_id;
-(TGPeer *)peer;


-(BOOL)n_out;
-(BOOL)unread;

@end
