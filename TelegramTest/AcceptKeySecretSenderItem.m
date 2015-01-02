//
//  AcceptKeySecretSenderItem.m
//  Telegram
//
//  Created by keepcoder on 02.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "AcceptKeySecretSenderItem.h"

@implementation AcceptKeySecretSenderItem

-(id)initWithConversation:(TL_conversation *)conversation {
    if(self = [super initWithConversation:conversation]) {
        
        self.action = [[TGSecretAction alloc] initWithActionId:[MessageSender getFutureMessageId] chat_id:conversation.peer.chat_id decryptedData:[self decryptedMessageLayer]  senderClass:[AcceptKeySecretSenderItem class] layer:self.params.layer];
        
        [self.action save];
        
    }
    
    return self;
}




@end
