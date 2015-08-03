//
//  TGBotCommandsPopup.h
//  Telegram
//
//  Created by keepcoder on 28.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGHelpPopup.h"

@interface TGBotCommandsPopup : TGHelpPopup

+(void)show:(NSString *)string botInfo:(NSArray *)botInfo view:(NSView *)view  ofRect:(NSRect)rect callback:(void (^)(NSString *command))callback;

@end
