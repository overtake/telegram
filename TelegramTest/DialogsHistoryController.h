//
//  DialogsHistoryController.h
//  Telegram P-Edition
//
//  Created by keepcoder on 12.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DialogsHistoryController : NSObject

typedef enum {
    DialogsHistoryStateNeedLocal = 0,
    DialogsHistoryStateNeedRemote = 1,
    DialogsHistoryStateNeedUsers = 3,
    DialogsHistoryStateEnd = 2,
} DialogHistoryState;

@property (nonatomic,assign) DialogHistoryState state;
@property (nonatomic,assign) BOOL isLoading;
-(void)next:(int)offset limit:(int)limit callback:(void (^)(NSArray *))callback usersCallback:(void (^)(NSArray *))usersCallback;
+(DialogsHistoryController *)sharedController;
-(void)initialize;
-(void)drop;
@end
