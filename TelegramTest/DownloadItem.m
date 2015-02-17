//
//  DownloadStandartItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 13.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DownloadItem.h"
#import "DownloadQueue.h"

#import "DownloadQueue.h"




@interface DownloadItem ()
@property (nonatomic,strong) NSMutableArray *events;
@end

@implementation DownloadEventListener

-(id)initWithItem:(DownloadItem *)item {
    if(self = [super init]) {
        _item = item;
    }
    
    return self;
}

-(void)clear {
    _item = nil;
    _completeHandler = nil;
    _errorHandler = nil;
    _progressHandler = nil;
}

-(void)dealloc {
    [self clear];
}

@end


@implementation DownloadItem



static int futureUniqueKey = 0;

-(id)initWithObject:(id)object {
    if(self = [super init]) {
        self.object = object;
        _uniqueKey = ++futureUniqueKey;
        _downloadState = DownloadStateWaitingStart;
        self.events = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id)initWithObject:(id)object size:(int)size {
    if(self = [super init]) {
        self.object = object;
        self.size = size;
        _uniqueKey = futureUniqueKey++;
        _downloadState = DownloadStateWaitingStart;
        self.events = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)setDownloadState:(DownloadState)downloadState {
    self->_downloadState = downloadState;
    
}

-(void)dealloc {
    [self removeAllEvents];
}


-(void)start {
    self.downloadState = DownloadStateDownloading;
    [DownloadQueue addAndStartItem:self];
}

-(void)cancel {
     self.downloadState = DownloadStateCanceled;
     [DownloadQueue removeItem:self];
    [self removeAllEvents];
   
}

-(void)pause {
    self.downloadState = DownloadStatePaused;
    [DownloadQueue pauseItem:self];
}


-(void)resetItem {
     self.downloadState = DownloadStateDownloading;
    [DownloadQueue resetItem:self];
}

-(TLInputFileLocation *)input {
    return nil;
}

-(BOOL)isEqualToItem:(DownloadItem *)item {
    return self.n_id == item.n_id;
}


-(void)setProgress:(float)progress {
    self->_progress = progress;
    [self notify:DownloadItemHandlerTypeProgress];
}


-(void)notify:(DownloadItemHandlerType)type {
    [DownloadQueue dispatchOnStageQueue:^{
        
        [self.events enumerateObjectsUsingBlock:^(DownloadEventListener *obj, NSUInteger idx, BOOL *stop) {
            
            switch (type) {
                case DownloadItemHandlerTypeCompletion:
                    if(obj.completeHandler) obj.completeHandler(obj.item);
                    break;
                case DownloadItemHandlerTypeError:
                    if(obj.errorHandler) obj.errorHandler(obj.item);
                    break;
                case DownloadItemHandlerTypeProgress:
                    if(obj.progressHandler) obj.progressHandler(obj.item);
                    break;
                default:
                    break;
                }
        }];
        
        if(type == DownloadItemHandlerTypeCompletion)
            [self clear];
        
    }];
}


-(void)addEvent:(DownloadEventListener *)event {
    [DownloadQueue dispatchOnStageQueue:^{
        if([self.events indexOfObject:event] == NSNotFound)
            [self.events addObject:event];
    }];
   
}
-(void)removeEvent:(DownloadEventListener *)event {
    [DownloadQueue dispatchOnStageQueue:^{
        [self.events removeObject:event];
    }];
    
}

-(void)clear {
    [self removeAllEvents];
}

-(int)partSize {
    return self.size == 0 ? 0 : 1024*128;
}


-(void)removeAllEvents {
    [DownloadQueue dispatchOnStageQueue:^{   
        [self.events removeAllObjects];
    } synchronous:YES];
    
}


@end
