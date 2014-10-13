//
//  BlockedUserRowItem.m
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "BlockedUserRowItem.h"

@implementation BlockedUserRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _contact = object;
        _user = [[UsersManager sharedManager] find:_contact.user_id];
    }
    
    return self;
}

-(NSUInteger)hash {
    return _contact.user_id;
}

@end
