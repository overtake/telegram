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


-(ChatHistoryState)prevState;
-(ChatHistoryState)nextState;

//@property (nonatomic,strong,readonly) TL_conversation *conversation;
@property (nonatomic,readonly) id<MessagesDelegate> controller;


-(BOOL)isProccessing;

@property (nonatomic,assign) BOOL need_save_to_db;


@property (nonatomic,assign) NSUInteger selectLimit; // default = 70;




-(HistoryFilter *)filterWithNext:(BOOL)next;
-(HistoryFilter *)filterWithPeerId:(int)peer_id;

-(HistoryFilter *)filter;
-(void)setFilter:(HistoryFilter *)filter;
-(void)addFilter:(HistoryFilter *)filter;
-(id)initWithController:(id<MessagesDelegate>)controller historyFilter:(Class)historyFilter;
typedef void (^selectHandler)(NSArray *result, NSRange range);

-(void)request:(BOOL)next anotherSource:(BOOL)anotherSource sync:(BOOL)sync selectHandler:(selectHandler)selectHandler;



-(void)loadAroundMessagesWithMessage:(MessageTableItem *)msg limit:(int)limit selectHandler:(selectHandler)selectHandler;
-(void)loadAroundMessagesWithSelectHandler:(selectHandler)selectHandler limit:(int)limit prevResult:(NSMutableArray *)prevResult nextResult:(NSMutableArray *)nextResult;


-(void)addItem:(MessageTableItem *)item;
-(void)addItems:(NSArray *)items conversation:(TL_conversation *)conversation;
-(void)addItems:(NSArray *)items conversation:(TL_conversation *)conversation  sentControllerCallback:(dispatch_block_t)sentControllerCallback;
-(void)addItem:(MessageTableItem *)item sentControllerCallback:(dispatch_block_t)sentControllerCallback;

-(void)addItem:(MessageTableItem *)item conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback sentControllerCallback:(dispatch_block_t)sentControllerCallback;
-(void)addItems:(NSArray *)items conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback sentControllerCallback:(dispatch_block_t)sentControllerCallback;

-(void)addItemWithoutSavingState:(MessageTableItem *)item;



-(void)drop:(BOOL)dropMemory;

-(void)startChannelPolling;
-(void)stopChannelPolling;
-(void)startChannelPollingIfAlreadyStoped;
-(TL_conversation *)conversation;

-(void)items:(NSArray *)msgIds complete:(void (^)(NSArray *list))complete;


// protected methods

-(ASQueue *)queue;

-(void)setProccessing:(BOOL)isProccessing;
-(void)performCallback:(selectHandler)selectHandler result:(NSArray *)result range:(NSRange )range;
@end

