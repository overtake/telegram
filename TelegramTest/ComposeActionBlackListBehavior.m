//
//  ComposeActionBlackListBehavior.m
//  Telegram
//
//  Created by keepcoder on 17.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeActionBlackListBehavior.h"

@implementation ComposeActionBlackListBehavior

-(NSAttributedString *)centerTitle {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:NSLocalizedString(@"Compose.ChannelBlackList", nil) withColor:NSColorFromRGB(0x333333)];
    
    [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
    
    return attr;
}

@end
