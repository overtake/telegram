//
//  ExternalDocumentSecretSenderItem.h
//  Telegram
//
//  Created by keepcoder on 09.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "SecretSenderItem.h"
#import "MessageSenderSecretItem.h"
@interface ExternalDocumentSecretSenderItem : MessageSenderSecretItem

-(id)initWithConversation:(TL_conversation *)conversation document:(TLDocument *)document;

@end
