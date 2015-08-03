//
//  TL_messageActionBotDescription.h
//  Telegram
//
//  Created by keepcoder on 05.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "MTProto.h"

@interface TL_messageActionBotDescription : TLMessageAction
+(TL_messageActionBotDescription*)createWithTitle:(NSString*)title;
@end
