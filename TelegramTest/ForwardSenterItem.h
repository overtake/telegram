//
//  ForwardSenterItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 18.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SenderItem.h"

@interface ForwardSenterItem : SenderItem

@property (nonatomic,strong) NSArray *tableItems;
@property (nonatomic,strong) NSArray *fakes;
@property (nonatomic,strong) NSArray *msg_ids;
-(id)initWithMessages:(NSArray *)msgs forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags;
@end
