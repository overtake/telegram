//
//  TGVideoViewerItem.h
//  Telegram
//
//  Created by keepcoder on 09/03/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGPhotoViewerItem.h"

@interface TGVideoViewerItem : TGPhotoViewerItem

@property (nonatomic,strong) DownloadItem *downloadItem;

-(NSString *)path;

-(BOOL)isset;

-(NSSize)videoSize;

@end
