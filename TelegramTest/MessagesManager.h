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



-(void)addSupportMessages:(NSArray *)supportMessages;
-(TL_localMessage *)supportMessage:(int)n_id;

-(TL_localMessage *)findWithRandomId:(long)random_id;

-(NSArray *)findWithWebPageId:(long)webpage_id;

-(void)addMessage:(TLMessage *)message;
-(void)TGsetMessage:(TLMessage *)message;

-(void)markAllInDialog:(TLDialog*)dialog callback:(void (^)(NSArray *ids))callback;
-(void)markAllInConversation:(TL_conversation *)conversation max_id:(int)max_id out:(BOOL)n_out callback:(void (^)(NSArray *ids))callback;

-(void)readMessagesContent:(NSArray *)msg_ids;

+ (void)notifyConversation:(int)peer_id title:(NSString *)title text:(NSString *)text;
+(void)addAndUpdateMessage:(TL_localMessage *)message;
+(void)addAndUpdateMessage:(TL_localMessage *)message notify:(BOOL)notify;
+(void)notifyMessage:(TL_localMessage *)message update_real_date:(BOOL)update_real_date;

+(void)updateUnreadBadge;

+(int)unreadBadgeCount;

@end
