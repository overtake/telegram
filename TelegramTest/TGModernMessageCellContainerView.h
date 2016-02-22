//
//  TGModernMessageCellContainerView.h
//  Telegram
//
//  Created by keepcoder on 21/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "MessageTableCellContainerView.h"

@interface TGModernMessageCellContainerView : MessageTableCellContainerView


//start view layout methods
-(int)defaultContentOffset;
-(int)defaultOffset;


-(TMView *)containerView;

@end
