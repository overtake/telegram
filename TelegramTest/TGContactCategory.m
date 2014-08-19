//
//  TGContactCategory.m
//  Telegram
//
//  Created by Dmitry Kondratyev on 6/19/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGContactCategory.h"

@implementation TGContact (Category)

- (TGUser *)user {
    return [[UsersManager sharedManager] find:self.user_id];
}

@end
