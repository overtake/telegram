//
//  TL_updateChannelPts.m
//  Telegram
//
//  Created by keepcoder on 04.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGForceChannelUpdate.h"

@implementation TGForceChannelUpdate

-(id)initWithUpdate:(id)update {
    if(self = [super init]) {
        _update = update;
    }
    
    return self;
}

@end
