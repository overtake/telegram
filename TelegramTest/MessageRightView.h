//
//  MessageRightView.h
//  Telegram
//
//  Created by keepcoder on 19/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "MessageTableCellContainerView.h"
@protocol MessageRightViewDelegate <NSObject>

-(void)rightViewDidChangeSize:(NSSize)size animated:(BOOL)animated;

@end

@interface MessageRightView : TMView

@property (nonatomic,weak) id <MessageRightViewDelegate> delegate;

@property (nonatomic,weak) MessageTableCellContainerView *container;

-(void)setState:(MessageTableCellState)state;

@property (nonatomic,assign) BOOL editable;

@end
