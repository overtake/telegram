//
//  MessageTableItemText.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"

@interface MessageTableItemText : MessageTableItem

@property (nonatomic, strong) NSMutableAttributedString *textAttributed;
@property (nonatomic,strong) NSDictionary *textAttributes;

@end
