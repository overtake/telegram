//
//  TGModernTypingManager.h
//  Telegram
//
//  Created by keepcoder on 03.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TMTypingObject.h"
@interface TGModernTypingManager : NSObject

+ (TMTypingObject *) typingForConversation:(TL_conversation *)conversation;
+ (void) drop;

@end
