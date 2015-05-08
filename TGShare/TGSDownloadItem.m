//
//  TGSDownloadItem.m
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSDownloadItem.h"
#import "TGSDownloadOperation.h"
@implementation TGSDownloadItem


-(DownloadOperation *)nOperation {
    return [[TGSDownloadOperation alloc] initWithItem:self];
}

@end
