//
//  TGModernHistoryController.h
//  Telegram
//
//  Created by keepcoder on 04.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>
#import "TGConversation.h"
@interface TGModernHistoryController : NSObject

-(SSignal *)requestObserver:(TGConversation *)conversation startMsgId:(int)msg_id;

@end
