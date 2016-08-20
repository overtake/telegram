//
//  TGDownloadItem.m
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGDownloadItem.h"
#import "TGDownloadOperation.h"
#import "DownloadPhotoItem.h"

@implementation TGDownloadItem


-(TGDownloadOperation *)nOperation {
    return [[TGDownloadOperation alloc] initWithItem:self];
}

@synthesize date = _date;

-(void)setDownloadState:(DownloadState)downloadState {
    [super setDownloadState:downloadState];
    
    if(downloadState == DownloadStateDownloading) {
        _date = [[MTNetwork instance] getTime];
    }
}

-(BOOL)isNeedRequestAgain {
    return self.downloadState == DownloadStateDownloading &&  self.date + 1*60*60 < [[MTNetwork instance] getTime] && [self isKindOfClass:[DownloadPhotoItem class]];
}

@end
