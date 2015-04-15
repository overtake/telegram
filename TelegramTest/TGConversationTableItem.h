//
//  TGConversationTableItem.h
//  Telegram
//
//  Created by keepcoder on 14.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TGConversationTableItem : NSObject

@property (nonatomic,weak) TMTableView *table;

@property (nonatomic,weak,readonly) TL_conversation *conversation;

-(TL_localMessage *)message;

@property (nonatomic,strong,readonly) NSMutableAttributedString *messageText;
@property (nonatomic,strong,readonly) NSMutableAttributedString *dateText;

@property (nonatomic, strong,readonly) NSString *unreadText;
@property (nonatomic,assign,readonly) NSSize unreadTextSize;

@property (nonatomic,assign,readonly) NSSize dateSize;

-(id)initWithConversation:(TL_conversation *)conversation;


-(void)update;

@end
