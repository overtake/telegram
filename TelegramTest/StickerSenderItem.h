//
//  StickerSenderItem.h
//  Telegram
//
//  Created by keepcoder on 19.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SenderItem.h"

@interface StickerSenderItem : SenderItem


-(id)initWithDocument:(TLDocument *)document forConversation:(TL_conversation*)conversation additionFlags:(int)additionFlags;

@end
