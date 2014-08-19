//
//  TGMessageCategory.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/27/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLRPC.h"

@interface TGMessage (Category)

- (TL_conversation *)dialog;
-(int)filterType;
@end
