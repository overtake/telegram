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
#import "TGReplyObject.h"
#define FORWARMESSAGE_TITLE_HEIGHT 20

@interface MessageTableItem : NSObject<SelectTextDelegate>

@property (nonatomic,weak) MessagesTableView *table;

@property (nonatomic, strong) TL_localMessage *message;

@property (nonatomic, strong) SenderItem *messageSender;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *fullDate;
@property (nonatomic, strong) TLUser *user;
@property (nonatomic, strong) NSAttributedString *headerName;
@property (nonatomic, strong) NSMutableAttributedString *forwardMessageAttributedString;
@property (nonatomic, strong) NSString *dateStr;

@property (nonatomic, strong) TLUser *fwd_user;
@property (nonatomic, strong) TLChat *fwd_chat;

@property (nonatomic) BOOL isForwadedMessage;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isHeaderMessage;
@property (nonatomic) BOOL isHeaderForwardedMessage;

@property (nonatomic,assign,readonly) int containerOffsetForward;
@property (nonatomic,assign,readonly) int containerOffset;

@property (nonatomic,assign,readonly) int makeSize;

@property (nonatomic) NSSize blockSize;
@property (nonatomic) NSSize previewSize;
@property (nonatomic) NSSize dateSize;
@property (nonatomic, strong) DownloadItem *downloadItem;


@property (nonatomic,assign,readonly) int blockWidth;



@property (nonatomic,strong) TGReplyObject *replyObject;

@property (nonatomic,strong,readonly) NSString *viewsCount;

-(BOOL)updateViews;

- (id) initWithObject:(id)object;
+ (id) messageItemFromObject:(id)object;
+ (NSArray *)messageTableItemsFromMessages:(NSArray *)input;
- (NSSize)viewSize;
- (void)setViewSize:(NSSize)size;

- (BOOL)canDownload;
- (void)clean;
- (BOOL)makeSizeByWidth:(int)width;

- (void)rebuildDate;

- (Class)downloadClass;

- (BOOL)isset;
- (BOOL)needUploader;
- (void)doAfterDownload;
- (void)startDownload:(BOOL)cancel force:(BOOL)force;
- (void)checkStartDownload:(SettingsMask)setting size:(int)size;

+ (NSDateFormatter *)dateFormatter;

-(BOOL)canShare;

-(NSURL *)shareObject;

-(BOOL)isReplyMessage;
-(BOOL)isFwdMessage;

-(int)fontSize;


@end
