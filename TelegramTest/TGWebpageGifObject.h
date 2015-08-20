//
//  TGWebpageGifObject.h
//  Telegram
//
//  Created by keepcoder on 20.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeViewController.h"
#import "TGWebpageObject.h"
@interface TGWebpageGifObject : TGWebpageObject


@property (nonatomic,strong,readonly) DownloadEventListener *downloadListener;
@property (nonatomic,strong,readonly) DownloadItem *downloadItem;

- (void)startDownload:(BOOL)cancel force:(BOOL)force;
-(NSString *)path;
-(BOOL)isset;
@end
