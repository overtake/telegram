//
//  ComposeActionBehaviorUserProfile.m
//  Telegram
//
//  Created by keepcoder on 03/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "ComposeActionInfoProfileBehavior.h"

@implementation ComposeActionInfoProfileBehavior



-(NSString *)doneTitle {
    return self.action.isEditable ? NSLocalizedString(@"Profile.Done", nil) : NSLocalizedString(@"Profile.Edit", nil);
}

-(NSAttributedString *)centerTitle {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:NSLocalizedString(@"Profile.Info", nil) withColor:NSColorFromRGB(0x222222)];
    [attr setFont:TGSystemFont(15) forRange:attr.range];
    
    [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
    
    return attr;
}

@end
