//
//  TGUserContainerRowItem.m
//  Telegram
//
//  Created by keepcoder on 16.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGUserContainerRowItem.h"

@implementation TGUserContainerRowItem


-(id)initWithUser:(TLUser *)user {
    if(self = [super init]) {
        _user = user;
    }
    return self;
}

-(Class)viewClass {
    return NSClassFromString(@"TGUserContainerView");
}

@end
