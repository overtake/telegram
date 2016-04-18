//
//  MessagesManager.h
//  TelegramTest
//
//  Created by keepcoder on 26.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "SharedManager.h"
#import "TL_destructMessage.h"
@interface MessagesManager : SharedManager


+(void)clearNotifies:(TL_conversation *)conversation max_id:(int)max_id;

-(TL_localMessage *)findWithRandomId:(long)random_id;

-(NSArray *)findWithWebPageId:(long)webpage_id;

-(void)readMessagesContent:(NSArray *)msg_ids;

+(void)notifyConversation:(int)peer_id title:(NSString *)title text:(NSString *)text;
+(void)addAndUpdateMessage:(TL_localMessage *)message;
+(void)addAndUpdateMessage:(TL_localMessage *)message notify:(BOOL)notify;
+(void)notifyMessage:(TL_localMessage *)message update_real_date:(BOOL)update_real_date;

+(void)updateUnreadBadge;

+(int)unreadBadgeCount;

@property (nonatomic,strong,readonly) ASQueue *supportMessagesQueue;

@end
