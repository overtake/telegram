//
//  DialogSwipeTableControll.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/31/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TGConversationTableCell.h"
#import "TGSwipeRedView.h"
#import "TGConversationsTableView.h"
@class ConversationTableItemView;

@interface TGSwipeTableControll : TGView
- (id)initWithFrame:(NSRect)frameRect itemView:(TGConversationTableCell *)itemView;
- (void)showButton;
- (void)hideButton;

@property (nonatomic, copy) dispatch_block_t drawBlock;
@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) TMView *containerView;
@property (nonatomic, weak) TGConversationTableCell *itemView;


@end