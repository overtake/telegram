//
//  ComposeActionBlockUsersBehavior.m
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeActionBlockUsersBehavior.h"
#import "SelectUserItem.h"
@implementation ComposeActionBlockUsersBehavior


-(TL_chatFull *)chat {
    return self.action.object;
}

-(NSUInteger)limit {
    return INT32_MAX;
}


-(NSString *)doneTitle {
    return NSLocalizedString(@"Compose.BlockUsers", nil);
}

-(NSAttributedString *)centerTitle {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:NSLocalizedString(@"Block Users", nil) withColor:NSColorFromRGB(0x333333)];
    
  //  NSRange range = [attr appendString:[NSString stringWithFormat:@" - %lu/%lu",self.action.result.multiObjects.count,[self limit]] withColor:DARK_GRAY];
    
  //  [attr setFont:TGSystemFont(12) forRange:range];
    
    [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
    
    return attr;
}

-(void)composeDidDone {
    
    [self.delegate behaviorDidStartRequest];
    
    [self blockUsers:[self.action.result.multiObjects mutableCopy]];
    
}

-(void)blockUsers:(NSMutableArray *)members {
    
    TLUser *user = members[0];
    
    [members removeObjectAtIndex:0];
    
    [[BlockedUsersManager sharedManager] block:user.n_id completeHandler:^(BOOL response) {
        
        if(members.count == 0) {
            [self.delegate behaviorDidEndRequest:nil];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.action.currentViewController.navigationViewController goBackWithAnimation:YES];
            });
        } else {
            [self blockUsers:members];
        }
        
    }];
}



@end
