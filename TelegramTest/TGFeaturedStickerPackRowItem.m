//
//  TGFeaturedStickerPackRowItem.m
//  Telegram
//
//  Created by keepcoder on 24/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGFeaturedStickerPackRowItem.h"

@implementation TGFeaturedStickerPackRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _isUnread = [object[@"unread"] boolValue];
        _isAdded = [object[@"added"] boolValue];
    }
    
    return self;
}

-(Class)viewClass {
    return NSClassFromString(@"TGFeaturedStickerPackRowView");
}

@end
