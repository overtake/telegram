//
//  TGRecentTableItem.m
//  Telegram
//
//  Created by keepcoder on 14.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGRecentSearchRowItem.h"
#import "TGRecentSearchRowView.h"


@implementation TGRecentSearchRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _conversation = object;
        _conversation.fake = YES;
    }
    
    return self;
}

-(NSUInteger)hash {
    return _conversation.peer_id;
}

-(Class)viewClass {
    return [TGRecentSearchRowView class];
}

-(int)height {
    return 50;
}

@end
