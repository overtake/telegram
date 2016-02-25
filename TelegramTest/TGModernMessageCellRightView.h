//
//  TGModernMessageCellRightView.h
//  Telegram
//
//  Created by keepcoder on 24/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGModernMessageCellContainerView.h"
@interface TGModernMessageCellRightView : TMView

@property (nonatomic,weak,readonly) MessageTableItem *item;
@property (nonatomic,weak,readonly) TGModernMessageCellContainerView *container;

-(void)setItem:(MessageTableItem *)item container:(TGModernMessageCellContainerView *)container;

-(void)setEditable:(BOOL)editable animated:(BOOL)animated;
-(void)setState:(MessageTableCellState)actionState animated:(BOOL)animated;

@end
