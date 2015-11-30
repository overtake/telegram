//
//  ChannelHistoryController.m
//  Telegram
//
//  Created by keepcoder on 08.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ChannelHistoryController.h"
#import "MessageTableItem.h"
#import "TGChannelsPolling.h"

#import "ChannelImportantFilter.h"
#import "ChannelFilter.h"
#import "MegagroupChatFilter.h"
@interface ChannelHistoryController () <TGChannelPollingDelegate>
@property (nonatomic,assign) BOOL pollingIsStarted;
@end

@implementation ChannelHistoryController


static TGChannelsPolling *channelPolling;

-(id)initWithController:(id<MessagesDelegate>)controller historyFilter:(Class)historyFilter {
    if(self = [super initWithController:controller historyFilter:historyFilter]) {
        
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            channelPolling = [[TGChannelsPolling alloc] initWithDelegate:self withUpdatesLimit:50];
            
        });
        
        [channelPolling setDelegate:self];
        [channelPolling setCurrentConversation:controller.conversation];
        
        _pollingIsStarted = NO;
        
    }
    
    return self;
}


-(void)request:(BOOL)next anotherSource:(BOOL)anotherSource sync:(BOOL)sync selectHandler:(selectHandler)selectHandler {
    
    [self.queue dispatchOnQueue:^{
        
        
         HistoryFilter *filter = [self filterWithNext:next];
        
        if([filter checkState:ChatHistoryStateFull next:next] || self.isProccessing) {
            [self performCallback:selectHandler result:@[] range:NSMakeRange(0, 0) controller:self];
            return;
        }
        
        self.proccessing = YES;
        
       
        [filter request:next callback:^(NSArray *result, ChatHistoryState state) {
            
            if([filter checkState:ChatHistoryStateLocal next:next] && result.count == 0) {
                
                [filter proccessResponse:result state:state next:next];
                
                self.proccessing = NO;
                
                [self request:next anotherSource:anotherSource sync:sync selectHandler:selectHandler];
                
                return;
            }
            
            NSArray *converted = [self.controller messageTableItemsFromMessages:[filter proccessResponse:result state:state next:next]];
            
            [self performCallback:selectHandler result:converted range:NSMakeRange(0, converted.count) controller:self];
            
            [channelPolling checkInvalidatedMessages:result important:[self.filter isKindOfClass:[ChannelImportantFilter class]]];
            
            
            
            
        }];
        
    } synchronous:sync];
    
}



-(void)pollingDidSaidTooLongWithHole:(TGMessageHole *)hole {
    
    if(hole != nil) {
        
        HistoryFilter *filter = [self filterWithPeerId:self.conversation.peer_id];
        
        [filter setState:ChatHistoryStateRemote next:NO];
        
        [filter setHole:hole withNext:NO];
        
        
        
        [filter request:NO callback:^(id response, ChatHistoryState state) {
            
            NSArray *converted = [self.controller messageTableItemsFromMessages:[filter proccessResponse:response state:state next:NO]];
            
            [ASQueue dispatchOnMainQueue:^{
                
                if([self.controller respondsToSelector:@selector(forceAddUnreadMark)]) {
                    [self.controller forceAddUnreadMark];
                }
                
                [self.controller receivedMessageList:converted inRange:NSMakeRange(0, converted.count) itsSelf:NO];
                
            }];
            
        }];
        
    }
    
    
    
}



-(void)loadAroundMessagesWithMessage:(TL_localMessage *)message prevLimit:(int)prevLimit nextLimit:(int)nextLimit selectHandler:(selectHandler)selectHandler {
    
    
    [self.queue dispatchOnQueue:^{
        
        [self addMessageWithoutSavingState:message];
    
        [[Storage manager] addHolesAroundMessage:message];
        
        if(self.filter.class == [ChannelFilter class]) {
            [(ChannelFilter *)self.filter fillGroupHoles:@[message] bottom:NO];
        }
        
        [[Storage manager] insertMessages:@[message]];
        
        NSMutableArray *prevResult = [NSMutableArray array];
        NSMutableArray *nextResult = [NSMutableArray array];
        
        self.proccessing = YES;
        [self loadAroundMessagesWithSelectHandler:selectHandler prevLimit:(int)prevLimit nextLimit:(int)nextLimit prevResult:prevResult nextResult:nextResult];
        
      
    } synchronous:YES];
    
    
}

-(void)loadAroundMessagesWithSelectHandler:(selectHandler)selectHandler  prevLimit:(int)prevLimit nextLimit:(int)nextLimit prevResult:(NSMutableArray *)prevResult nextResult:(NSMutableArray *)nextResult {
    
    
    BOOL nextLoaded = nextResult.count >= nextLimit || self.nextState == ChatHistoryStateFull;
    BOOL prevLoaded = prevResult.count >= prevLimit || self.prevState == ChatHistoryStateFull;
    
    
    if((nextLoaded && prevLoaded) || (prevLoaded && self.nextState == ChatHistoryStateRemote && nextLimit == 1)) {
        
        NSArray *result = [self.filter selectAllItems];
        
        if(self.isNeedSwapFilters) {
            result = [[self filterAtIndex:1] selectAllItems];
        }
        
        NSArray *converted = [self.controller messageTableItemsFromMessages:result];
        
        [self performCallback:selectHandler result:converted range:NSMakeRange(0, converted.count) controller:self];

        [channelPolling checkInvalidatedMessages:result important:[self.filter isKindOfClass:[ChannelImportantFilter class]]];
        
        self.proccessing = NO;
        return;
    }
    
    BOOL nextRequest = prevLoaded;
    
    
    [self.filter request:nextRequest callback:^(NSArray *result, ChatHistoryState state) {
        
        NSArray *converted = [self.filter proccessResponse:result state:state next:nextRequest];
        
        if(nextRequest) {
            [nextResult addObjectsFromArray:converted];
        } else {
            [prevResult addObjectsFromArray:converted];
        }
        
        [self loadAroundMessagesWithSelectHandler:selectHandler prevLimit:(int)prevLimit nextLimit:(int)nextLimit prevResult:prevResult nextResult:nextResult];
        
    }];
    
}



-(void)pollingReceivedUpdates:(id)updates endPts:(int)pts {
    
}



-(void)startChannelPolling {
    
    if(!channelPolling.isActive) {
        [channelPolling start];
        _pollingIsStarted = YES;
    }
}

-(void)startChannelPollingIfAlreadyStoped {
    if(!channelPolling.isActive && _pollingIsStarted) {
        [channelPolling start];
    }
}

-(void)stopChannelPolling {
    [channelPolling stop];
}




-(void)drop:(BOOL)dropMemory {
    
    [super drop:YES];
}

-(void)dealloc {
    [channelPolling stop];
}

/*
 //            __block MessageTableItem *service;
 //
 //
 //            if([filter checkState:ChatHistoryStateFull next:next]) {
 //                [[filter selectAllItems] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
 //                    if(obj.message.action && [obj.message.action isKindOfClass:[TL_messageActionChannelMigrateFrom class]]) {
 //                        service = obj;
 //                        *stop = YES;
 //                    }
 //                }];
 //
 //
 //                if( service ) {
 //
 //                    TLChat *chat = [[ChatsManager sharedManager] find:service.message.action.chat_id];
 //
 //                    HistoryFilter *filter = [[MegagroupChatFilter alloc] initWithController:self peer:chat.dialog.peer];
 //
 //                    [filter setState:ChatHistoryStateFull next:NO];
 //
 //                    [self addFilter:filter];
 //
 //                }
 //            }

 */


@end
