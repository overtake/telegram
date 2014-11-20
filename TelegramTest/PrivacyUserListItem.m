//
//  PrivacyUserListItem.m
//  Telegram
//
//  Created by keepcoder on 20.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PrivacyUserListItem.h"

@implementation PrivacyUserListItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _user = [[UsersManager sharedManager] find:[object intValue]];
    }
    
    return self;
}

-(NSUInteger)hash {
    return _user.n_id;
}

@end
