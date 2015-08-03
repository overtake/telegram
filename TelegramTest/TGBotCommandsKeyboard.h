//
//  TGBotCommandsKeyboard.h
//  Telegram
//
//  Created by keepcoder on 05.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGBotCommandsKeyboard : TMView

-(void)setConversation:(TL_conversation *)conversation botUser:(TLUser *)botUser;

-(BOOL)isCanShow;
-(TL_localMessage *)keyboard;

@end
