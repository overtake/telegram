//
//  MessageTableItemDocument.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/4/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"
#import "DownloadOperation.h"
#import "DownloadDocumentItem.h"
#import "TGImageObject.h"
@class MessageTableCellDocumentView;

typedef enum {
    DocumentStateWaitingDownload,
    DocumentStateDownloading,
    DocumentStateUploading,
    DocumentStateDownloaded
} DocumentState;

@interface MessageTableItemDocument : MessageTableItem

@property (nonatomic) DocumentState state;

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *fileSize;

@property (nonatomic) NSSize fileNameSize;
@property (nonatomic) NSSize fileSizeSize;

@property (nonatomic) NSSize thumbSize;


@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSImage *cachedThumb;

@property (nonatomic, weak) MessageTableCellDocumentView *cell;

@property (nonatomic,strong) TGImageObject *thumbObject;

- (BOOL)isset;
- (BOOL)isHasThumb;

- (NSString *)path;
- (int)size;
- (BOOL)canDownload;

@end