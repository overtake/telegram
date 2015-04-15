//
//  TGConversationTableCell.h
//  Telegram
//
//  Created by keepcoder on 14.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGConversationTableItem.h"
@interface TGConversationTableCell : TMView


typedef enum {
    ConversationTableCellFullStyle,
    ConversationTableCellShortStyle
} ConversationTableCellStyle;


@property (nonatomic,assign) ConversationTableCellStyle style;


-(void)setItem:(TGConversationTableItem *)item;


@end
