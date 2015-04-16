//
//  DialogRedButtonView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/31/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TGConversationTableCell.h"

@class ConversationTableItemView;

@interface TGSwipeRedView : NSView

@property (nonatomic, strong) NSAttributedString *attributedString;
@property (nonatomic) NSSize size;
@property (nonatomic) BOOL disable;
@property (nonatomic, weak) TGConversationTableCell *itemView;

@end
