//
//  TGSharedLinkRowItem.m
//  Telegram
//
//  Created by keepcoder on 24.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSharedLinkRowItem.h"

@implementation TGSharedLinkRowItem
-(id)initWithObject:(MessageTableItem *)item {
    if(self = [super init]) {
        _item = item;
    }
    
    return self;
}
@end
