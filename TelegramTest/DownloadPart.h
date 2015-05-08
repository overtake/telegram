//
//  DownloadPart.h
//  Messenger for Telegram
//
//  Created by keepcoder on 27.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DownloadItem;
@interface DownloadPart : NSObject
@property (nonatomic,assign,readonly) int offset;
@property (nonatomic,assign,readonly) int partId;
@property (nonatomic,assign,readonly) int dcId;
@property (nonatomic,weak,readonly) DownloadItem *item;
@property (nonatomic,strong) NSData *resultData;
@property (nonatomic,strong) id request;

- (id)initWithId:(int)partId offset:(int)offset dcId:(int)dcId downloadItem:(DownloadItem *)downloadItem;

@end
