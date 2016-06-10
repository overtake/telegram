//
//  TGMessageEditSender.m
//  Telegram
//
//  Created by keepcoder on 18/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGMessageEditSender.h"

@implementation TGMessageEditSender


-(id)initWithTemplate:(TGInputMessageTemplate *)inputTemplate conversation:(TL_conversation *)conversation {
    if(self = [super init]) {
        _inputTemplate = inputTemplate;
        _conversation = conversation;
    }
    
    return self;
}

-(void)performEdit:(int)flags {
    
    flags |= (1 << 11);
    
    NSMutableArray *entities = [NSMutableArray array];
    
    NSString *message = [_inputTemplate.text copy];
    
    message = [MessageSender parseCustomMentions:message entities:entities];
    
    message = [MessageSender parseEntities:message entities:entities backstrips:@"```" startIndex:0];
    
    message = [MessageSender parseEntities:message entities:entities backstrips:@"`" startIndex:0];
    
    if(entities.count > 0)
        flags |= (1 << 3);
    
    
    
    [RPCRequest sendRequest:[TLAPI_messages_editMessage createWithFlags:flags peer:_conversation.inputPeer n_id:_inputTemplate.postId message:message reply_markup:nil entities:entities] successHandler:^(id request, id response) {
        
        
        
    } errorHandler:^(id request, RpcError *error) {
        if(![error.error_msg  isEqualToString:@"MESSAGE_NOT_MODIFIED"])
            alert(appName(), NSLocalizedString(@"EditMessage.EditErrorAlert", nil));
    }];
}

@end
