//
//  TGHeadChatPanel.h
//  Telegram
//
//  Created by keepcoder on 15.10.15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TGHeadChatPanel : NSWindow

+(void)showWithConversation:(TL_conversation *)conversation;

@end
