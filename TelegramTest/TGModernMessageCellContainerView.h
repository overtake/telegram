//
//  TGModernMessageCellContainerView.h
//  Telegram
//
//  Created by keepcoder on 21/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "MessageTableCellContainerView.h"

@interface TGModernMessageCellContainerView : MessageTableCellContainerView



-(TMView *)containerView;


-(void)setSelected:(BOOL)selected animated:(BOOL)animated;
-(void)setEditable:(BOOL)editable animated:(BOOL)animated;

@end
