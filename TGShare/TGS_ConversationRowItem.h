//
//  TGS_ConversationTableItem.h
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMRowItem.h"
#import "TGSImageObject.h"
@interface TGS_ConversationRowItem : TMRowItem

@property (nonatomic,strong,readonly) TLDialog *conversation;
@property (nonatomic,strong,readonly) TLUser *user;
@property (nonatomic,strong,readonly) TLChat *chat;

@property (nonatomic,assign) int date;

@property (nonatomic,strong,readonly) NSAttributedString *name;

@property (nonatomic,assign,readonly) NSSize nameSize;

@property (nonatomic,strong,readonly) TGSImageObject *imageObject;

-(id)initWithConversation:(TLDialog *)conversation user:(TLUser *)user;

-(id)initWithConversation:(TLDialog *)conversation chat:(TLChat *)chat;


@property (nonatomic,assign) BOOL isSelected;

@end
