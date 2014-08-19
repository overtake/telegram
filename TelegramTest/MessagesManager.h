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

-(void)addMessage:(TGMessage *)message;
-(void)TGsetMessage:(TGMessage *)message;

-(NSArray *)markAllInDialog:(TGDialog*)dialog;
+ (void)notifyConversation:(int)peer_id title:(NSString *)title text:(NSString *)text;
-(TGMessageMedia *)mediaFromEncryptedMessage:(TGDecryptedMessageMedia *)media file:(TGEncryptedFile *)file;
+(void)statedMessage:(TL_messages_statedMessage*)response;
+(TGMessage *)defaultMessage:(TL_encryptedMessage *)message;
+(void)addAndUpdateMessage:(TGMessage *)message;
+(void)notifyMessage:(TGMessage *)message update_real_date:(BOOL)update_real_date;
@end
