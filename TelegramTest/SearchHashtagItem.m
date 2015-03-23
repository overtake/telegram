//
//  SearchHashtagItem.m
//  Telegram
//
//  Created by keepcoder on 23.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "SearchHashtagItem.h"

@interface SearchHashtagItem ()

@end

@implementation SearchHashtagItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _hashtag = [NSString stringWithFormat:@"#%@",object];
    }
    
    return self;
}


-(NSUInteger)hash {
    return [_hashtag hash];
}

@end
