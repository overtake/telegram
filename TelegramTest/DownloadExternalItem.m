//
//  DownloadExternalItem.m
//  Telegram
//
//  Created by keepcoder on 24/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "DownloadExternalItem.h"
#import "DownloadExternalOperation.h"
@implementation DownloadExternalItem

-(id)initWithObject:(NSString *)object {
    if(self = [super initWithObject:object]) {
        self.n_id = [object hash];
        self.path = path_for_external_link(object);
        _downloadUrl = object;
    }
    
    return self;
}

-(DownloadOperation *)nOperation {
    return [[DownloadExternalOperation alloc] initWithItem:self];
}

@end
