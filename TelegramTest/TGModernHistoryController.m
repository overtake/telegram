//
//  TGModernHistoryController.m
//  Telegram
//
//  Created by keepcoder on 04.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGModernHistoryController.h"

@implementation TGModernHistoryController


-(SSignal *)requestObserver:(TGConversation *)conversation startMsgId:(int)msg_id  {
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
                
        return nil;
    }];
    
}

@end
