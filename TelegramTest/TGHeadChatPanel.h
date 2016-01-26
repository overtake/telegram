//
//  TGHeadChatPanel.h
//  Telegram
//
//  Created by keepcoder on 15.10.15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TGHeadChatPanel : TelegramWindow

+(void)showWithConversation:(TL_conversation *)conversation;

-(void)back;

+(void)lockAllControllers;
+(void)unlockAllControllers;

@end
