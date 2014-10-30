//
//  UpgradeLayerSenderItem.h
//  Telegram
//
//  Created by keepcoder on 27.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SecretSenderItem.h"

@interface UpgradeLayerSenderItem : SecretSenderItem

-(id)initWithConversation:(TL_conversation *)conversation;

@end
