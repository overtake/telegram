//
//  TGConversationTableItem.h
//  Telegram
//
//  Created by keepcoder on 14.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMRowItem.h"

@interface TGConversationTableItem : TMRowItem

@property (nonatomic,strong,readonly) TL_conversation *conversation;

-(TL_localMessage *)message;


@property (nonatomic,strong,readonly) NSMutableAttributedString *messageText;
@property (nonatomic,strong,readonly) NSMutableAttributedString *dateText;


@property (nonatomic,assign) NSSize nameTextSize;

@property (nonatomic,strong,readonly) NSString *selectText;

@property (nonatomic, strong,readonly) NSString *unreadText;
@property (nonatomic,assign,readonly) NSSize unreadTextSize;

@property (nonatomic,assign,readonly) NSSize dateSize;

@property (nonatomic,strong) NSString *typing;

-(id)initWithConversation:(TL_conversation *)conversation;

-(BOOL)itemIsUpdated;

-(void)needUpdateMessage:(NSNotification *)notification;

-(void)performReload;
@end
