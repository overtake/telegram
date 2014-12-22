//
//  DialogSwipeTableControll.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/31/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConversationTableItemView.h"
#import "DialogTableView.h"
#import "DialogRedButtonView.h"

@class ConversationTableItemView;

@interface DialogSwipeTableControll : NSControl
- (id)initWithFrame:(NSRect)frameRect itemView:(ConversationTableItemView *)itemView;
- (void)showButton;
- (void)hideButton;

@property (nonatomic, copy) dispatch_block_t drawBlock;
@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) TMView *containerView;
@property (nonatomic, strong) ConversationTableItemView *itemView;
@property (nonatomic, strong) DialogTableView *tableView;



@end