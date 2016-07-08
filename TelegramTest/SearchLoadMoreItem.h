//
//  SearchLoadMoreItem.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@interface SearchLoadMoreItem : TMRowItem

@property (nonatomic, strong,readonly) void (^callback)(id item);
@property (nonatomic,strong,readonly) NSArray *items;

-(id)initWithObject:(id)object callback:(void (^)(id item))callback;

@end
