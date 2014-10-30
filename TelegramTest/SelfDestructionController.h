//
//  SelfDestructionController.h
//  Messenger for Telegram
//
//  Created by keepcoder on 24.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelfDestructionController : NSObject



+(void)addMessage:(TL_destructMessage *)message force:(BOOL)force;


+(void)addMessages:(NSArray *)messages;


@end
