//
//  TimeoutObserver.h
//  Messenger for Telegram
//
//  Created by keepcoder on 28.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TaskObserver <NSObject>

-(void)didCompleteTaskRequest:(id)task;
-(void)didStartTaskRequest:(id)task;
-(void)didCancelledTask:(id)task;


@end
