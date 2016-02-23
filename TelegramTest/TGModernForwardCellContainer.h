//
//  TGModernForwardCellContainer.h
//  Telegram
//
//  Created by keepcoder on 22/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "MessageTableItem.h"

#import "TGModernMessageCellContainerView.h"

@interface TGModernForwardCellContainer : TMView
@property (nonatomic,weak,readonly) MessageTableItem *tableItem;
@property (nonatomic,weak,readonly) TMView *contentView;
@property (nonatomic,weak,readonly) TGModernMessageCellContainerView *containerView;


-(void)setTableItem:(MessageTableItem *)tableItem contentView:(TMView *)contentView containerView:(TGModernMessageCellContainerView *)containerView;

@end
