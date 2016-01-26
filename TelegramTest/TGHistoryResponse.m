//
//  HistoryResponse.m
//  Telegram
//
//  Created by keepcoder on 27.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGHistoryResponse.h"

@implementation TGHistoryResponse

-(id)initWithResult:(NSArray *)result hole:(TGMessageHole *)hole groupHoles:(NSArray *)groupHoles {
    if(self = [super init]) {
        _result = result;
        _hole = hole;
        _groupHoles = groupHoles;
    }
    
    return self;
}

@end
