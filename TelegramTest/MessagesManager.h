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
@property (nonatomic,assign) int unread_count;



-(void)addSupportMessages:(NSArray *)supportMessages;
-(TL_localMessage *)supportMessage:(int)n_id;

-(TL_localMessage *)findWithRandomId:(long)random_id;

-(NSArray *)findWithWebPageId:(long)webpage_id;

-(void)addMessage:(TLMessage *)message;
-(void)TGsetMessage:(TLMessage *)message;

-(NSArray *)markAllInDialog:(TLDialog*)dialog;
-(NSArray *)markAllInConversation:(TL_conversation *)conversation max_id:(int)max_id;

-(void)readMessagesContent:(NSArray *)msg_ids;

+ (void)notifyConversation:(int)peer_id title:(NSString *)title text:(NSString *)text;
+(void)addAndUpdateMessage:(TL_localMessage *)message;
+(void)addAndUpdateMessage:(TL_localMessage *)message notify:(BOOL)notify;
+(void)notifyMessage:(TL_localMessage *)message update_real_date:(BOOL)update_real_date;
@end
