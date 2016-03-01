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
@interface MessageTableItemDocument : MessageTableItem

@property (nonatomic, strong) NSAttributedString *fileNameAttrubutedString;
@property (nonatomic, strong) NSString *fileSize;

@property (nonatomic) NSSize fileNameSize;
@property (nonatomic) NSSize fileSizeSize;

@property (nonatomic) NSSize thumbSize;

@property (nonatomic,strong) TGImageObject *thumbObject;

- (BOOL)isset;
- (BOOL)isHasThumb;

- (NSString *)path;
- (int)size;
- (BOOL)canDownload;

@end