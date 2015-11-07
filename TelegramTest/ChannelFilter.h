//
//  ChannelFilter.h
//  Telegram
//
//  Created by keepcoder on 25.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "HistoryFilter.h"
#import "ChannelCommonFilter.h"
@interface ChannelFilter : ChannelCommonFilter
-(void)fillGroupHoles:(NSArray *)messages bottom:(BOOL)bottom;
@end
