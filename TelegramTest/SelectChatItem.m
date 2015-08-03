//
//  SelectChatItem.m
//  Telegram
//
//  Created by keepcoder on 05.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "SelectChatItem.h"

@implementation SelectChatItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _chat = object;
    }
    
    return self;
}


-(NSUInteger)hash {
    return _chat.n_id;
}

@end
