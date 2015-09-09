//
//  ImageAttachSenderItem.h
//  Telegram
//
//  Created by keepcoder on 21.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "SenderItem.h"
#import "TGAttachObject.h"
@interface ImageAttachSenderItem : SenderItem

-(id)initWithConversation:(TL_conversation *)conversation attachObject:(TGAttachObject *)attach additionFlags:(int)additionFlags;

@end
