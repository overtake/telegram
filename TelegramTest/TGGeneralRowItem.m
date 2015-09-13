//
//  TGGeneralRowItem.m
//  Telegram
//
//  Created by keepcoder on 13.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGGeneralRowItem.h"

@interface TGGeneralRowItem ()
@property (nonatomic,assign,readonly) int rand;
@end

@implementation TGGeneralRowItem


-(id)initWithHeight:(int)height {
    if(self = [super init]) {
        _height = height;
    }
    
    return self;
}

-(NSUInteger)hash {
    if(_rand == 0)
        _rand = rand_int();
    
    return _rand;
}

-(int)xOffset {
    if(_xOffset < 1)
        return 100;
    return _xOffset;
}


-(Class)viewClass {
    return [TMView class];
}



@end
