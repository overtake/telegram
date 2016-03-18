//
//  TGMultipleRequestCallback.m
//  Telegram
//
//  Created by keepcoder on 18/03/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGMultipleRequestCallback.h"

@implementation TGMultipleRequestCallback

-(id)initWithRequest:(RPCRequest *)request {
    if(self = [super init]) {
        _request = request;
        _callbacks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)dealloc {
    [_request cancelRequest];
}

@end
