//
//  TGUpdateChannelContainer.h
//  Telegram
//
//  Created by keepcoder on 21.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGUpdateChannelContainer : NSObject

@property (nonatomic,assign,readonly) int pts;
@property (nonatomic,assign,readonly) int pts_count;
@property (nonatomic,assign,readonly) int channel_id;
@property (nonatomic,strong,readonly) id update;

-(id)initWithPts:(int)pts pts_count:(int)pts_count channel_id:(int)channel_id update:(id)update;

@end
