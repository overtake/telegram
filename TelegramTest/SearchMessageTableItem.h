//
//  SearchMessageTableItem.h
//  Telegram
//
//  Created by keepcoder on 21.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGConversationTableItem.h"

@interface SearchMessageTableItem : TGConversationTableItem




-(id)initWithMessage:(TL_localMessage *)message selectedText:(NSString *)selectedText;

@end
