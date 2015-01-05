//
//  TGEncryptedAction.m
//  Telegram
//
//  Created by keepcoder on 28.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGSecretAction.h"
#import "SecretSenderItem.h"

@interface TGSecretAction ()
@property (nonatomic,strong) SecretSenderItem *senderItem;
@end


@implementation TGSecretAction


-(id)initWithActionId:(int)actionId chat_id:(int)chat_id decryptedData:(NSData *)decryptedData senderClass:(Class)senderClass layer:(int)layer{
    if(self = [self initWithActionId:actionId chat_id:chat_id decryptedData:decryptedData layer:layer]) {
        _senderClass = senderClass;
    }
    
    return self;
}


-(id)initWithActionId:(int)actionId chat_id:(int)chat_id decryptedData:(NSData *)decryptedData layer:(int)layer {
    if(self = [super init]) {
        _actionId = actionId;
        _chat_id = chat_id;
        _decryptedData = decryptedData;
        _params = [EncryptedParams findAndCreate:_chat_id];
        _layer = layer;
        [actions addObject:self];

    }
    
    return self;
}


-(void)onStateChanged:(SecretSenderItem *)item {
    
    if(item.state == MessageSendingStateSent) {
        
        [self remove];
    }
    
}

-(void)dealloc {
    
}


static NSMutableArray *actions;

+(id)requestActionWithMessageId:(int)messageId {
    
    __block TGSecretAction *secretAction;
    
    [ASQueue dispatchOnStageQueue:^{
        
        [actions enumerateObjectsUsingBlock:^(TGSecretAction * action, NSUInteger idx, BOOL *stop) {
            
            if(action.actionId == messageId) {
                secretAction = action;
                
                *stop = YES;
            }
            
        }];
        
    } synchronous:YES];
    
    return secretAction;
    
    
}

+(void)dequeAllStorageActions {
    
     [[Storage manager] selectAllActions:^(NSArray *list) {
            
        [ASQueue dispatchOnStageQueue:^{
            actions = [list mutableCopy];
            [self _resendActions];
        }];
            
    }];

}

+(void)_resendActions {
    
    [ASQueue dispatchOnStageQueue:^{
        [actions enumerateObjectsUsingBlock:^(TGSecretAction *action, NSUInteger idx, BOOL *stop) {
            action.senderItem = [[action.senderClass alloc] initWithSecretAction:action];
            [action.senderItem send];
        }];
    }];
   
}

-(void)save {
    [[Storage manager] insertSecretAction:self];
}

-(void)remove {
    [actions removeObject:self];
    _senderItem = nil;
    [[Storage manager] removeSecretAction:self];
}

@end
