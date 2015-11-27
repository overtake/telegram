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
    return self.action.isEditable ? NSLocalizedString(@"Save", nil) : NSLocalizedString(@"Profile.Edit", nil);
}

@end
