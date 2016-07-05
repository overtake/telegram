//
//  TGSessionRowitem.m
//  Telegram
//
//  Created by keepcoder on 26.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSessionRowitem.h"

@implementation TGSessionRowitem


-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _authorization = object;
    }
    
    return self;
}

-(int)height {
    return 60;
}

-(Class)viewClass {
    return NSClassFromString(@"TGSessionRowView");
}

-(NSUInteger)hash {
    return _authorization.n_hash;
}

@end
