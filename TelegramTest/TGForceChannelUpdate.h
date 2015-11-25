//
//  TL_updateChannelPts.h
//  Telegram
//
//  Created by keepcoder on 04.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGForceChannelUpdate : NSObject

@property (nonatomic,strong,readonly) id update;

-(id)initWithUpdate:(id)update;

@end
