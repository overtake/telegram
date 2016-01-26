//
//  ComposeActionStickersBehavior.m
//  Telegram
//
//  Created by keepcoder on 26/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "ComposeActionStickersBehavior.h"

@implementation ComposeActionStickersBehavior

-(NSString *)doneTitle {
    return self.action.isEditable ? NSLocalizedString(@"Profile.Done", nil) : NSLocalizedString(@"Profile.Edit", nil);
}

-(NSAttributedString *)centerTitle {
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:NSLocalizedString(@"Settings.Stickers", nil) withColor:NSColorFromRGB(0x333333)];
    
    [attr setAlignment:NSCenterTextAlignment range:attr.range];
    
    return attr;
}

@end
