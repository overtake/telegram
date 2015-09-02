//
//  HistoryFilter.h
//  Messenger for Telegram
//
//  Created by keepcoder on 14.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

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
    HistoryFilterImportantChannelMessage = 1 << 12
} HistoryFilterType;

typedef enum {
    ChatHistoryStateCache = 0,
    ChatHistoryStateLocal = 1,
    ChatHistoryStateRemote = 2,
    ChatHistoryStateFull = 3
} ChatHistoryState;

@property (nonatomic,weak) ChatHistoryController *controller;
@property (nonatomic,strong) TGMessageHole *topHole;
@property (nonatomic,strong) TGMessageHole *botHole;


-(id)initWithController:(ChatHistoryController *)controller;

- (NSMutableDictionary *)messageKeys:(int)peer_id;
- (NSMutableArray *)messageItems:(int)peer_id;

+ (NSMutableDictionary *)messageKeys:(int)peer_id;
+ (NSMutableArray *)messageItems:(int)peer_id;

+(NSArray *)removeItems:(NSArray *)messageIds;

+(void)removeAllItems:(int)peerId;

+(NSArray *)items:(NSArray *)messageIds;

-(int)type;
+(int)type;

+(void)drop;


-(NSArray *)storageRequest:(BOOL)next;
-(void)remoteRequest:(BOOL)next peer_id:(int)peer_id callback:(void (^)(id response))callback;




-(void)remoteRequest:(BOOL)next hole:(TGMessageHole *)hole callback:(void (^)(id response,ChatHistoryState state))callback;
-(void)remoteRequest:(BOOL)next max_id:(int)max_id hole:(TGMessageHole *)hole callback:(void (^)(id response,ChatHistoryState state))callback;
-(void)request:(BOOL)next callback:(void (^)(NSArray *response, ChatHistoryState state))callback;

@end
