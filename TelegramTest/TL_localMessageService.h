//
//  TL_localMessageService.h
//  Telegram
//
//  Created by keepcoder on 23.06.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_localMessage.h"

@interface TL_localMessageService : TL_localMessage

+(TL_localMessageService*)createWithFlags:(int)flags n_id:(int)n_id from_id:(int)from_id to_id:(TLPeer*)to_id date:(int)date action:(TLMessageAction*)action fakeId:(int)fakeId randomId:(long)randomId dstate:(DeliveryState)dstate;


+(TL_localMessageService *)createWithHole:(TGMessageHole *)hole;

@end
