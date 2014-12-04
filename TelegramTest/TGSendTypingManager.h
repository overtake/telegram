//
//  TGSendTypingManager.h
//  Telegram
//
//  Created by keepcoder on 03.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGSendTypingManager : NSObject
+(void)addAction:(TLSendMessageAction *)action forConversation:(TL_conversation *)conversation;
+(void)clear:(TL_conversation *)conversation;
@end
