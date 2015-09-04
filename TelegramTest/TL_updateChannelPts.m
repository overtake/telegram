//
//  TL_updateChannelPts.m
//  Telegram
//
//  Created by keepcoder on 04.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TL_updateChannelPts.h"

@implementation TL_updateChannelPts

-(id)initWithPts:(int)pts pts_count:(int)pts_count channel_id:(int)channel_id {
    if(self = [super init]) {
        _pts = pts;
        _pts_count = pts_count;
        _channel_id = channel_id;
    }
    
    return self;
}

@end
