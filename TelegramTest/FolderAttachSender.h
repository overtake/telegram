//
//  FolderAttachSender.h
//  Telegram
//
//  Created by keepcoder on 02/09/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "SenderItem.h"

@interface FolderAttachSender : SenderItem
-(id)initWithConversation:(TL_conversation *)conversation attachObject:(TGAttachObject *)attach additionFlags:(int)additionFlags;

@end
