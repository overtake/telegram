//
//  ChatHistoryController.h
//  Messenger for Telegram
//
//  Created by keepcoder on 16.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagesDelegate.h"
#import "SenderListener.h"

#import "HistoryFilter.h"

@interface ChatHistoryController : NSObject<SenderListener>


typedef enum {
    ChatHistoryStateCache = 0,
    ChatHistoryStateLocal = 1,
    ChatHistoryStateRemote = 2,
    ChatHistoryStateFull = 3
} ChatHistoryState;

@property (atomic,assign) ChatHistoryState nextState;
@property (atomic,assign) ChatHistoryState prevState;

//@property (nonatomic,strong,readonly) TL_conversation *conversation;
@property (nonatomic,readonly) MessagesViewController *controller;
@property (atomic,assign,readonly) BOOL isProccessing;
@property (nonatomic,assign) BOOL need_save_to_db;

@property (nonatomic,assign) int max_id;
@property (nonatomic,assign) int min_id;

@property (nonatomic,assign) int start_min;


@property (nonatomic,assign) int server_max_id;
@property (nonatomic,assign) int server_min_id;

@property (nonatomic,assign) int server_start_min;

@property (nonatomic,assign) int minDate;
@property (nonatomic,assign) int maxDate;

@property (nonatomic,assign) NSUInteger selectLimit; // default = 70;
@property (nonatomic,strong) id <MessagesDelegate> delegate;


@property (nonatomic,strong) HistoryFilter *filter;

-(id)initWithConversation:(TL_conversation *)conversation controller:(MessagesViewController *)controller;
-(id)initWithConversation:(TL_conversation *)conversation controller:(MessagesViewController *)controller historyFilter:(Class)historyFilter;
typedef void (^selectHandler)(NSArray *result, NSRange range);

-(void)request:(BOOL)next anotherSource:(BOOL)anotherSource sync:(BOOL)sync selectHandler:(selectHandler)selectHandler;


-(void)addItem:(MessageTableItem *)item;
-(void)addItems:(NSArray *)items conversation:(TL_conversation *)conversation;
-(void)addItems:(NSArray *)items conversation:(TL_conversation *)conversation  sentControllerCallback:(dispatch_block_t)sentControllerCallback;
-(void)addItem:(MessageTableItem *)item sentControllerCallback:(dispatch_block_t)sentControllerCallback;

-(void)addItem:(MessageTableItem *)item conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback sentControllerCallback:(dispatch_block_t)sentControllerCallback;
-(void)addItems:(NSArray *)items conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback sentControllerCallback:(dispatch_block_t)sentControllerCallback;


-(void)removeAllItems;

+(void)drop;
-(void)drop:(BOOL)dropMemory;

-(TL_conversation *)conversation;
@end

