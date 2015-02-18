//
//  TL_localMessage.h
//  Telegram P-Edition
//
//  Created by keepcoder on 10.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MTProto.h"
#import "TL_conversation.h"
@interface TL_localMessage : TL_message

typedef enum {
    MessageOutStateSend = 0,
    MessageOutStateSent = 1,
    MessageOutStateError = 2
} MessageOutState;

+(TL_localMessage *)createWithN_id:(int)n_id flags:(int)flags from_id:(int)from_id to_id:(TLPeer *)to_id date:(int)date message:(NSString *)message media:(TLMessageMedia *)media fakeId:(int)fakeId randomId:(long)randomId state:(DeliveryState)state;
@property (nonatomic,assign) int fakeId;
@property (nonatomic,assign) long randomId;
@property (nonatomic,assign) DeliveryState dstate;
@property (nonatomic,copy) dispatch_block_t didChangedDeliveryState;

@property (nonatomic,strong) NSUserNotification *userNotification;

-(void)save:(BOOL)updateConversation;

+(TL_localMessage *)convertReceivedMessage:(TLMessage *)msg;
+(void)convertReceivedMessages:(NSMutableArray *)messages;


-(int)peer_id;
-(TLPeer *)peer;


-(BOOL)n_out;
-(BOOL)unread;

- (TL_conversation *)conversation;
-(int)filterType;
@end
