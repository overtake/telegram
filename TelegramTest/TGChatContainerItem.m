//
//  TGChatContainerItem.m
//  Telegram
//
//  Created by keepcoder on 05/08/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGChatContainerItem.h"

@implementation TGChatContainerItem

@synthesize chat = _chat;

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _chat = object;
    }
    
    return self;
}

-(Class)viewClass {
    return NSClassFromString(@"TGObjectContainerView");
}




@end
