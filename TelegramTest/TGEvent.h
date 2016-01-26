//
//  TGEvent.h
//  Telegram
//
//  Created by keepcoder on 25.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGEvent : NSObject


@property (nonatomic,assign,readonly) long uniqueId;
@property (nonatomic,strong,readonly) id resultObject;
@property (nonatomic,strong,readonly) NSString *eventName;


-(id)initWithEventName:(NSString *)eventName resultObject:(id)resultObject;

+(id)eventWithName:(NSString *)eventName resultObject:(id)resultObject;

-(void)dispatch;
-(void)dispatchOnQueue:(ASQueue *)queue sync:(bool)sync;

@end
