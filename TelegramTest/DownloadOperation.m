//
//  DownloadOperation.m
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "DownloadOperation.h"

@implementation DownloadOperation

-(id)initWithItem:(DownloadItem *)item {
    if(self = [super init]) {
        _item = item;
    }
    
    return self;
}

-(void)start:(id)target selector:(SEL)selector {
    
}

-(void)cancel {
    
}

@end
