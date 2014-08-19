//
//  SecretChatAccepter.h
//  Telegram
//
//  Created by keepcoder on 11.06.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecretChatAccepter : NSObject

+(void)addChatId:(int)chat_id;

+(void)removeChatId:(int)chat_id;
+(instancetype)instance;
@end
