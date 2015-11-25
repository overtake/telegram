//
//  TLContactCategory.m
//  Telegram
//
//  Created by Dmitry Kondratyev on 6/19/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLContactCategory.h"

@implementation TLContact (Category)

DYNAMIC_PROPERTY(dUser);

- (TLUser *)user {
    
    TLUser *u = [self getdUser];
    
    if(!u)
    {
        u = [[UsersManager sharedManager] find:self.user_id];
        [self setdUser:u];
    }
    
    return u;
}

@end
