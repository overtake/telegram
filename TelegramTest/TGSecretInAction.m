//
//  TGSecretInputAction.m
//  Telegram
//
//  Created by keepcoder on 30.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGSecretInAction.h"

@implementation TGSecretInAction

-(id)initWithActionId:(int)actionId chat_id:(int)chat_id messageData:(NSData *)messageData fileData:(NSData *)fileData date:(int)date in_seq_no:(int)in_seq_no layer:(int)layer {
    if(self = [super init]) {
        _actionId = actionId;
        _chat_id = chat_id;
        _messageData = messageData;
        _fileData = fileData;
        _date = date;
        _in_seq_no = in_seq_no;
        _layer = layer;
    }
    
    return self;
}

@end
