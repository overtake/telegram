//
//  ConservationHistoryController.h
//  Telegram P-Edition
//
//  Created by keepcoder on 10.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagesDelegate.h"
@interface ConversationHistoryController : NSObject

typedef enum {
    HistoryStateNeedLocal = 0,
    HistoryStateNeedRemote = 1,
    HistoryStateEnd = 2
} HistoryState;


-(id)initWithController:(MessagesViewController *)controller;

@property (nonatomic,assign) HistoryState state;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,strong) id<MessagesDelegate> delegate;
-(void)next:(int)max_id count:(int)count callback:(void (^)(NSArray *))callback;
-(void)prev:(int)max_id count:(int)count mark:(BOOL)mark callback:(void (^)(NSArray *))callback;
-(void)clear:(TL_conversation *)dialog;
-(void)setDialog:(TL_conversation *)dialog;
-(void)remoteCancel;
-(void)drop;

-(void)addItem:(MessageTableItem *)item;
-(void)addItems:(NSArray *)items peer_id:(int)peer_id;
@end
