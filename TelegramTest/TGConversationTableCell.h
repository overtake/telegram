//
//  TGConversationTableCell.h
//  Telegram
//
//  Created by keepcoder on 14.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGConversationTableItem.h"

@class TGConversationsTableView;

@interface TGConversationTableCell : TMRowView


typedef enum {
    ConversationTableCellFullStyle,
    ConversationTableCellShortStyle
} ConversationTableCellStyle;



@property (nonatomic,assign) ConversationTableCellStyle style;

@property (nonatomic,assign,setter=setSwipePanelActive:) BOOL isSwipePanelActive;


-(TGConversationsTableView *)tableView;
-(void)updateFrames;
@end
