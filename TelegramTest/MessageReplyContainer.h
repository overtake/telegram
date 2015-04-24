//
//  MessageReplyContainer.h
//  Telegram
//
//  Created by keepcoder on 10.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGReplyObject.h"
@interface MessageReplyContainer : TMView

@property (nonatomic,strong,readonly) TGCTextView *messageField;

@property (nonatomic,copy) dispatch_block_t deleteHandler;

@property (nonatomic,strong) TGReplyObject *replyObject;

@property (nonatomic,weak) MessageTableItem *item;

@end
