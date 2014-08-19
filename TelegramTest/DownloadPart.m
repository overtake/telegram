//
//  DownloadPart.m
//  Messenger for Telegram
//
//  Created by keepcoder on 27.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DownloadPart.h"

@implementation DownloadPart


-(id)initWithId:(int)partId offset:(int)offset dcId:(int)dcId downloadItem:(DownloadItem *)downloadItem {
    if(self = [super init]) {
        _partId = partId;
        _offset = offset;
        _dcId = dcId;
        _item = downloadItem;
    }
    
    return self;
}

-(void)dealloc {
    self.resultData = nil;
    self.request = nil;
}

@end
