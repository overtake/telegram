//
//  TGUpdateChannelContainer.m
//  Telegram
//
//  Created by keepcoder on 21.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGUpdateChannelContainer.h"

@implementation TGUpdateChannelContainer

-(id)initWithPts:(int)pts pts_count:(int)pts_count channel_id:(int)channel_id update:(id)update {
    if(self = [super init]) {
        _pts = pts;
        _pts_count = pts_count;
        _channel_id = channel_id;
        _update = update;
    }
    
    return self;
}

@end
