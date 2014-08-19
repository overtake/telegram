//
//  Destructor.h
//  Messenger for Telegram
//
//  Created by keepcoder on 24.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Destructor : NSObject
@property (nonatomic,assign) int max_id;
@property (nonatomic,assign) int ttl;
@property (nonatomic,assign) int chat_id;
-(id)initWithTLL:(int)ttl max_id:(int)max_id chat_id:(int)chat_id;
@end
