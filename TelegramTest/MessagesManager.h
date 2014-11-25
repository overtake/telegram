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


-(TL_destructMessage *)findWithRandomId:(long)random_id;

-(void)addMessage:(TLMessage *)message;
-(void)TGsetMessage:(TLMessage *)message;

-(NSArray *)markAllInDialog:(TLDialog*)dialog;
+ (void)notifyConversation:(int)peer_id title:(NSString *)title text:(NSString *)text;
+(void)statedMessage:(TL_messages_statedMessage*)response;
+(void)addAndUpdateMessage:(TLMessage *)message;
+(void)notifyMessage:(TLMessage *)message update_real_date:(BOOL)update_real_date;
@end
