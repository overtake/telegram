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
#import "TGHistoryResponse.h"
@interface ChatHistoryController : NSObject<SenderListener>




@property (atomic,assign) ChatHistoryState nextState;
@property (atomic,assign) ChatHistoryState prevState;

//@property (nonatomic,strong,readonly) TL_conversation *conversation;
@property (nonatomic,readonly) id<MessagesDelegate> controller;


-(BOOL)isProccessing;
-(BOOL)checkState:(ChatHistoryState)state next:(BOOL)next;

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




-(HistoryFilter *)filter;
-(void)setFilter:(HistoryFilter *)filter;

-(id)initWithController:(id<MessagesDelegate>)controller historyFilter:(Class)historyFilter;
typedef void (^selectHandler)(NSArray *result, NSRange range);

-(void)request:(BOOL)next anotherSource:(BOOL)anotherSource sync:(BOOL)sync selectHandler:(selectHandler)selectHandler;



-(void)loadAroundMessagesWithMessage:(MessageTableItem *)msg limit:(int)limit selectHandler:(selectHandler)selectHandler;

-(void)addItem:(MessageTableItem *)item;
-(void)addItems:(NSArray *)items conversation:(TL_conversation *)conversation;
-(void)addItems:(NSArray *)items conversation:(TL_conversation *)conversation  sentControllerCallback:(dispatch_block_t)sentControllerCallback;
-(void)addItem:(MessageTableItem *)item sentControllerCallback:(dispatch_block_t)sentControllerCallback;

-(void)addItem:(MessageTableItem *)item conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback sentControllerCallback:(dispatch_block_t)sentControllerCallback;
-(void)addItems:(NSArray *)items conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback sentControllerCallback:(dispatch_block_t)sentControllerCallback;

-(void)addItemWithoutSavingState:(MessageTableItem *)item;


-(void)removeAllItems;
-(void)removeAllItemsWithPeerId:(int)peer_id;
+(void)drop;
-(void)drop:(BOOL)dropMemory;

-(void)startChannelPolling;
-(void)stopChannelPolling;
-(void)startChannelPollingIfAlreadyStoped;
-(TL_conversation *)conversation;

-(int)posAtMessage:(TLMessage *)message;

// protected methods
-(NSArray *)selectAllItems;
-(ASQueue *)queue;
-(NSArray *)filterAndAdd:(NSArray *)items isLates:(BOOL)isLatest;
-(NSArray *)sortItems:(NSArray *)sort;
-(void)setProccessing:(BOOL)isProccessing;
-(void)setState:(ChatHistoryState)state next:(BOOL)next;
-(void)performCallback:(selectHandler)selectHandler result:(NSArray *)result range:(NSRange )range;
@end

