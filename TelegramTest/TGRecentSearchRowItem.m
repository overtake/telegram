//
//  TGRecentTableItem.m
//  Telegram
//
//  Created by keepcoder on 14.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGRecentSearchRowItem.h"
#import "TGRecentSearchRowView.h"

@interface TGRecentSearchRowItem ()
@property (nonatomic,assign) long randKey;
@end

@implementation TGRecentSearchRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _conversation = [object copy];
        _conversation.fake = YES;
        _randKey = rand_long();
    }
    
    return self;
}

-(NSUInteger)hash {
    return _randKey;
}

-(Class)viewClass {
    return [TGRecentSearchRowView class];
}

-(int)height {
    return 50;
}

@end
