//
//  ImageSengerItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageSenderItem.h"

@interface ImageSenderItem : SenderItem

- (id)initWithImage:(NSImage *)image forConversation:(TL_conversation *)conversation;

@end
