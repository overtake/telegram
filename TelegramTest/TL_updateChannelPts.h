//
//  TL_updateChannelPts.h
//  Telegram
//
//  Created by keepcoder on 04.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TL_updateChannelPts : NSObject

@property (nonatomic,assign,readonly) int pts;
@property (nonatomic,assign,readonly) int pts_count;
@property (nonatomic,assign,readonly) int channel_id;

-(id)initWithPts:(int)pts pts_count:(int)pts_count channel_id:(int)channel_id;

@end
