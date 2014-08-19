//
//  TMInAppLinks.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/5/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMInAppLinks.h"
#import "Telegram.h"

@implementation TMInAppLinks

+ (NSString *) userProfile:(int)user_id {
    return [NSString stringWithFormat:@"USER_PROFILE:%d", user_id];
}

+ (void) parseUrlAndDo:(NSString *)url {
    NSArray *params = [url componentsSeparatedByString:@":"];
    if(params.count) {
        NSString *action = [params objectAtIndex:0];
        if([action isEqualToString:@"USER_PROFILE"]) {
            int user_id = [[params objectAtIndex:1] intValue];
            [[Telegram sharedInstance] showUserInfoWithUserId:user_id conversation:nil sender:self];
            
        }
    }
}

@end
