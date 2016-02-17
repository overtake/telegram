//
//  DownloadExternalItem.h
//  Telegram
//
//  Created by keepcoder on 24/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "DownloadItem.h"

@interface DownloadExternalItem : DownloadItem

@property (nonatomic,strong,readonly) NSString *downloadUrl;

@end
