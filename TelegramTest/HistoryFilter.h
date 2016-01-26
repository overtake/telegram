//
//  HistoryFilter.h
//  Messenger for Telegram
//
//  Created by keepcoder on 14.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLPeer+Extensions.h"


@class ChatHistoryController;

@interface HistoryFilter : NSObject

@property (nonatomic,weak) RPCRequest *request;
typedef enum {
    HistoryFilterNone = 1 << 1,
    HistoryFilterAllMedia = 1 << 2,
    HistoryFilterPhoto = 1 << 3,
    HistoryFilterVideo = 1 << 4,
    HistoryFilterAudio = 1 << 5,
    HistoryFilterDocuments = 1 << 6,
    HistoryFilterText = 1 << 7,
    HistoryFilterContact = 1 << 8,
    HistoryFilterSearch = 1 << 9,
    HistoryFilterAudioDocument = 1 << 10,
    HistoryFilterSharedLink = 1 << 11,
    HistoryFilterChannelMessage = 1 << 12,
    HistoryFilterImportantChannelMessage = 1 << 13
} HistoryFilterType;

typedef enum {
    ChatHistoryStateCache = 0,
    ChatHistoryStateLocal = 1,
    ChatHistoryStateRemote = 2,
    ChatHistoryStateFull = 3
} ChatHistoryState;



@property (nonatomic,assign) ChatHistoryState prevState;
@property (nonatomic,assign) ChatHistoryState nextState;

@property (nonatomic,weak) ChatHistoryController *controller;
@property (nonatomic,strong,readonly) TLPeer *peer;

-(id)initWithController:(ChatHistoryController *)controller peer:(TLPeer *)peer;

-(int)max_id;
-(int)min_id;
-(int)server_max_id;
-(int)server_min_id;
-(int)minDate;
-(int)maxDate;


-(int)selectLimit;

-(NSArray *)filterAndAdd:(NSArray *)items latest:(BOOL)latest;
-(NSArray *)proccessResponse:(NSArray *)result state:(ChatHistoryState)state next:(BOOL)next;

-(TGMessageHole *)holeWithNext:(BOOL)next;
-(void)setHole:(TGMessageHole *)hole withNext:(BOOL)next;


-(NSMutableArray *)messageItems;
-(NSMutableDictionary *)messageKeys;

-(NSArray *)selectAllItems;
-(NSArray *)sortItems:(NSArray *)sort;
-(int)posAtMessage:(TL_localMessage *)message;

-(int)type;
+(int)type;

-(BOOL)checkState:(ChatHistoryState)state next:(BOOL)next;
-(ChatHistoryState)stateWithNext:(BOOL)next;
-(void)setState:(ChatHistoryState)state next:(BOOL)next;
-(int)additionSenderFlags;

-(int)peer_id;

-(TGMessageHole *)proccessAndGetHoleWithHole:(TGMessageHole *)hole next:(BOOL)next messages:(NSArray *)messages;

-(BOOL)confirmHoleWithNext:(BOOL)next;


-(NSArray *)storageRequest:(BOOL)next state:(ChatHistoryState *)state;

-(void)remoteRequest:(BOOL)next hole:(TGMessageHole *)hole callback:(void (^)(id response,ChatHistoryState state))callback;
-(void)remoteRequest:(BOOL)next max_id:(int)max_id hole:(TGMessageHole *)hole callback:(void (^)(id response,ChatHistoryState state))callback;
-(void)request:(BOOL)next callback:(void (^)(NSArray *response, ChatHistoryState state))callback;


-(void)fillGroupHoles:(NSArray *)messages bottom:(BOOL)bottom;

-(TLMessagesFilter *)messagesFilter;
-(BOOL)checkAcceptResult:(NSArray *)result;

-(void)clear;

@end
