//
//  TGDownloadItem.m
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGDownloadItem.h"
#import "TGDownloadOperation.h"
@implementation TGDownloadItem


-(TGDownloadOperation *)nOperation {
    return [[TGDownloadOperation alloc] initWithItem:self];
}

@end
