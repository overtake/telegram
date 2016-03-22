//
//  ChatFullManager.h
//  Telegram
//
//  Created by keepcoder on 22/03/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "SharedManager.h"

@interface ChatFullManager : SharedManager

-(void)requestChatFull:(int)chat_id withCallback:(void (^) (TLChatFull *chatFull))callback;
-(void)requestChatFull:(int)chat_id force:(BOOL)force withCallback:(void (^) (TLChatFull *chatFull))callback;

-(void)requestChatFull:(int)chat_id;
-(void)requestChatFull:(int)chat_id force:(BOOL)force;

- (int)getOnlineCount:(int)chat_id;

-(void)loadParticipantsWithMegagroupId:(int)chat_id;

@end
