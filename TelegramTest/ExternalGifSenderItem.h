//
//  ExternalGifSenderItem.h
//  Telegram
//
//  Created by keepcoder on 03/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "SenderItem.h"

@interface ExternalGifSenderItem : SenderItem

-(id)initWithMedia:(TLMessageMedia *)media additionFlags:(int)additionFlags forConversation:(TL_conversation *)conversation;


@end
