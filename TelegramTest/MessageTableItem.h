//
//  MessageTableItem.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SenderHeader.h"
#import "DownloadItem.h"

#define FORWARMESSAGE_TITLE_HEIGHT 28

@interface MessageTableItem : NSObject

@property (nonatomic, strong) TL_localMessage *message;
@property (nonatomic, strong) SenderItem *messageSender;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *fullDate;
@property (nonatomic, strong) TGUser *user;
@property (nonatomic, strong) NSString *headerName;
@property (nonatomic, strong) NSColor *headerColor;
@property (nonatomic, strong) NSMutableAttributedString *forwardMessageAttributedString;
@property (nonatomic, strong) NSString *dateStr;

@property (nonatomic, strong) TGUser *fwd_user;

@property (nonatomic) BOOL isForwadedMessage;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isHeaderMessage;
@property (nonatomic) BOOL isHeaderForwardedMessage;


@property (nonatomic) NSSize blockSize;
@property (nonatomic) NSSize previewSize;
@property (nonatomic) NSSize dateSize;
@property (nonatomic, strong) DownloadItem *downloadItem;
@property (nonatomic,strong) DownloadEventListener *downloadListener;

- (id) initWithObject:(id)object;
+ (id) messageItemFromObject:(id)object;

- (NSSize)viewSize;
- (void)setViewSize:(NSSize)size;

- (BOOL)canDownload;
- (void)clean;
- (BOOL)makeSizeByWidth:(int)width;

- (void)rebuildDate;

- (BOOL)isset;
- (BOOL)needUploader;
- (void)doAfterDownload;
- (void)startDownload:(BOOL)cancel downloadItemClass:(Class)itemClass force:(BOOL)force;
- (void)checkStartDownload:(SettingsMask)setting size:(int)size downloadItemClass:(Class)itemClass;

+ (NSDateFormatter *)dateFormatter;
@end
