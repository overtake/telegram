//
//  DownloadStandartItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 13.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadItem.h"


@class DownloadOperation;

@class DownloadItem;

typedef enum {
    DownloadItemHandlerTypeError,
    DownloadItemHandlerTypeCompletion,
    DownloadItemHandlerTypeProgress
} DownloadItemHandlerType;

typedef void (^DownloadItemHandler)(DownloadItem *item);

@interface DownloadEventListener : NSObject
@property (atomic,copy) DownloadItemHandler progressHandler;
@property (atomic,copy) DownloadItemHandler completeHandler;
@property (atomic,copy) DownloadItemHandler errorHandler;


-(void)clear;

@end


@interface DownloadItem : NSObject

typedef enum {
    DownloadErrorNone = 0,
    DownloadErrorCantLoad = 1
} DownloadErrorType;

typedef enum {
    DownloadFileImage = 0,
    DownloadFileVideo = 1,
    DownloadFileDocument = 2,
    DownloadFileAudio = 3
} DownloadFileType;

typedef enum {
    DownloadStateWaitingStart = 0,
    DownloadStateDownloading = 1,
    DownloadStateCanceled = 2,
    DownloadStatePaused = 3,
    DownloadStateCompleted = 4,
} DownloadState;




@property (nonatomic,strong) id object;

@property (nonatomic,weak) id reservedObject;

@property (nonatomic,assign) long n_id;
@property (nonatomic,assign,readonly) long uniqueKey;

@property (nonatomic,assign) DownloadFileType fileType;
@property (nonatomic,strong) NSString *path;
@property (nonatomic,assign) DownloadErrorType errorType;
@property (nonatomic,strong) NSData *result;
@property (nonatomic,assign) DownloadState downloadState;
@property (nonatomic,assign) BOOL isEncrypted;

@property (nonatomic,assign) int size;
@property (nonatomic,assign) int dc_id;


@property (nonatomic,assign) BOOL isRemoteLoaded;






//@property (atomic,copy) DownloadItemHandler progressHandler;
//@property (atomic,copy) DownloadItemHandler errorHandler;
//@property (atomic,copy) DownloadItemHandler completeHandler;


-(void)addEvent:(DownloadEventListener *)event;
-(void)removeEvent:(DownloadEventListener *)event;

-(void)removeAllEvents;

-(void)notify:(DownloadItemHandlerType)type;

@property (nonatomic,assign) float progress;

-(id)initWithObject:(id)object;

-(BOOL)isEqualToItem:(DownloadItem *)item;
-(void)start;
-(void)cancel;
-(void)pause;
-(void)resetItem;
-(TLInputFileLocation *)input;


-(int)partSize;

-(id)initWithObject:(id)object size:(int)size;

-(DownloadOperation *)nOperation;

@end
