//
//  DocumentSenderItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SenderItem.h"

@interface DocumentSenderItem : SenderItem
- (id)initWithPath:(NSString *)path forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags caption:(NSString *)caption;
@end
