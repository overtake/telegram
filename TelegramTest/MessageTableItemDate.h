//
//  MessageTableItemDate.h
//  Telegram
//
//  Created by keepcoder on 28/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"

@interface MessageTableItemDate : MessageTableItem
@property (nonatomic,strong,readonly) NSAttributedString *text;
@property (nonatomic,assign,readonly) NSSize textSize;

@end
