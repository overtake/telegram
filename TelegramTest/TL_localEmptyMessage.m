//
//  TL_localEmptyMessage.m
//  Telegram
//
//  Created by keepcoder on 16.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TL_localEmptyMessage.h"

@implementation TL_localEmptyMessage

+(TL_localEmptyMessage *)createWithN_Id:(int)n_id to_id:(TLPeer *)peer {
    TL_localEmptyMessage *empty = [[TL_localEmptyMessage alloc] init];
    empty.n_id = n_id;
    empty.to_id = peer;
    return empty;
}


-(void)serialize:(SerializedData *)stream {
    [stream writeInt:self.n_id];
    [TLClassStore TLSerialize:self.to_id stream:stream];
}

-(void)unserialize:(SerializedData *)stream {
    self.n_id = [stream readInt];
    self.to_id = [TLClassStore TLDeserialize:stream];
}

@end
