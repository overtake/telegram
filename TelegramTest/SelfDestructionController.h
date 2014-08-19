//
//  SelfDestructionController.h
//  Messenger for Telegram
//
//  Created by keepcoder on 24.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelfDestructionController : NSObject

+(int)lastTTL:(TL_encryptedChat *)chat;

+(void)addMessage:(TL_destructMessage *)message;
+(void)addMessages:(NSArray *)messages;
+(void)addDestructor:(Destructor *)destructor;
@end
