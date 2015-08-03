//
//  TLUserStatusCategory.m
//  Telegram
//
//  Created by Dmitry Kondratyev on 6/19/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLUserStatusCategory.h"

@implementation TLUserStatus (Category)

- (int)lastSeenTime {
    if([self isKindOfClass:[TL_userStatusEmpty class]])
        return -1;
    
    return self.expires ? self.expires : self.was_online;
}

-(id)photo_small {
    
    
    return nil;
}

@end
