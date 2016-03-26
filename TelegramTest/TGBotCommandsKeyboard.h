//
//  TGBotCommandsKeyboard.h
//  Telegram
//
//  Created by keepcoder on 05.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGBotCommandsKeyboard : TMView


@property (nonatomic,strong,readonly) TL_localMessage *keyboard;

-(void)setKeyboard:(TL_localMessage *)keyboard fillToSize:(BOOL)fillToSize keyboadrdCallback:(void (^)(TLKeyboardButton *command))keyboardCallback;

-(BOOL)isCanShow;

@end
