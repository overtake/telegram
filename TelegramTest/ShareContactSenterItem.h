//
//  ShareContactSenterItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 18.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SenderItem.h"

@interface ShareContactSenterItem : SenderItem
-(id)initWithContact:(TGUser *)contact forConversation:(TL_conversation *)conversation;
@end
