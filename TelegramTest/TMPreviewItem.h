//
//  TMPreviewItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 12.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import "DownloadItem.h"

#import "PreviewObject.h"

@protocol TMPreviewItem <NSObject, QLPreviewItem>
@property (nonatomic, strong, readonly) PreviewObject *previewObject;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSImage *previewImage;
@property (nonatomic,strong) DownloadEventListener *downloadListener;
@required

- (id)initWithItem:(PreviewObject *)previewObject;
- (BOOL)isEqualToItem:(id<TMPreviewItem>)item;

- (NSImage *)previewImage;
- (NSString *)fileName;

@optional
-(id)initWithPath:(NSString *)path;

@end
