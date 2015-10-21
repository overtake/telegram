//
//  MessagesTopInfoView.h
//  Telegram
//
//  Created by keepcoder on 02.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface MessagesTopInfoView : TMView

typedef enum {
    MessagesTopInfoActionAddContact,
    MessagesTopInfoActionUnblockUser,
    MessagesTopInfoActionShareContact,
    MessagesTopInfoActionReportSpam,
    MessagesTopInfoActionNone
} MessagesTopInfoAction;


@property (nonatomic,assign) MessagesTopInfoAction action;

@property (nonatomic,weak) MessagesViewController *controller;
@property (nonatomic,strong) TL_conversation *conversation;

@property (nonatomic,assign,readonly) BOOL isShown;

@end
