//
//  TGWebgameViewController.h
//  Telegram
//
//  Created by keepcoder on 23/08/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMViewController.h"

@interface TGWebgameViewController : TMViewController




-(void)startWithUrl:(NSString *)urlString bot:(TLUser *)bot keyboard:(TLKeyboardButton *)keyboard message:(TL_localMessage *)message;

@end
