//
//  TL_localEmptyMessage.h
//  Telegram
//
//  Created by keepcoder on 16.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TLObject.h"

@interface TL_localEmptyMessage : TL_localMessage


+(TL_localEmptyMessage *)createWithN_Id:(int)n_id to_id:(TLPeer *)peer;

@end
