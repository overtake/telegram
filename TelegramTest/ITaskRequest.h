//
//  ITimeoutRequest.h
//  Messenger for Telegram
//
//  Created by keepcoder on 28.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskObserver.h"
@protocol ITaskRequest <NSObject>

@property (nonatomic,strong) id<TaskObserver> delegate;
@property (nonatomic,strong,readonly) NSDictionary *params;
@property (nonatomic,assign,readonly) NSUInteger taskId;
@required
-(id)initWithParams:(NSDictionary *)params;
-(id)initWithParams:(NSDictionary *)params taskId:(NSUInteger)taskId;
-(void)execute;
-(void)deleteTask;

@end
