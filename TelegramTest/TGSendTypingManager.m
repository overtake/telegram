//
//  TGSendTypingManager.m
//  Telegram
//
//  Created by keepcoder on 03.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGSendTypingManager.h"

@implementation TGSendTypingManager


+(void)addAction:(TLSendMessageAction *)action forConversation:(TL_conversation *)conversation
{
    
}



+(TGSendTypingManager *)manager {
    static TGSendTypingManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TGSendTypingManager alloc] init];
    });
    
    return instance;
}

@end
