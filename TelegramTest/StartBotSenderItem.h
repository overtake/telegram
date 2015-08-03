//
//  StartBotSenderItem.h
//  Telegram
//
//  Created by keepcoder on 16.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "SenderItem.h"

@interface StartBotSenderItem : SenderItem
-(id)initWithMessage:(NSString *)message forConversation:(TL_conversation *)conversation bot:(TLUser *)bot startParam:(NSString *)startParam;
@end
