
//
//  ImageLoader.m
//  TelegramTest
//
//  Created by keepcoder on 19.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "DownloadQueue.h"
#import "DownloadOperation.h"
#import "CMath.h"
#import "FileUtils.h"
#import "Telegram.h"

#include <set>
#include <map>
@interface DownloadQueue ()
@property (nonatomic,strong) NSMutableArray *fileQueue;
@property (nonatomic) std::map< long, DownloadItem *> *loading;

@end


@implementation DownloadQueue
@synthesize fileQueue = _fileQueue;
@synthesize loading = _loading;


-(id)init {
    if(self = [super init]) {
        _fileQueue = [[NSMutableArray alloc] init];
        _loading = new std::map< long, DownloadItem *> ();
    }
    return self;
}


+ (void)dispatchOnStageQueue:(dispatch_block_t)block {
    [[DownloadQueue dispatcher] dispatchOnQueue:block];
}

+ (void)dispatchOnStageQueue:(dispatch_block_t)block synchronous:(BOOL)synchronous {
    [[DownloadQueue dispatcher] dispatchOnQueue:block synchronous:synchronous];
}

+(ASQueue *)dispatcher {
    static ASQueue *queue;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[ASQueue alloc] initWithName:"DowloadQueue"];
    });
    
    return queue;
}

+(DownloadQueue *)sharedManager {
    static DownloadQueue *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DownloadQueue alloc] init];
    });
    return instance;
}




+(DownloadItem *)find:(long)key {
    return [[DownloadQueue sharedManager] find:key];
}

-(DownloadItem *)find:(long)key {
    
    __block DownloadItem *item;
    
    [DownloadQueue dispatchOnStageQueue:^{
        std::map< long, DownloadItem * >::iterator it = _loading->find(key);
        if(it != _loading->end())
            item = it->second;
    }];
    
    
    return item;
}


-(void)dequeue {
    [DownloadQueue dispatchOnStageQueue:^{
       [_fileQueue enumerateObjectsUsingBlock:^(DownloadOperation *operation, NSUInteger idx, BOOL *stop) {
           DownloadItem * item = [self find:operation.item.n_id];
           if(!item) {
               [operation start:self selector:@selector(operationComplete:)];
               _loading->insert(std::pair< long, DownloadItem * >(operation.item.n_id,operation.item));
           }
       }];

    }];
}


-(void)operationComplete:(DownloadOperation *)operation {
    
    
    [DownloadQueue dispatchOnStageQueue:^{
        [self erase:operation.item];
        
        __block NSMutableArray *removeArray = [[NSMutableArray alloc] init];
        
        [self.fileQueue enumerateObjectsUsingBlock:^(DownloadOperation *current, NSUInteger idx, BOOL *stop) {
            
            if([current.item isEqualToItem:operation.item]) {
                
                current.item.result = operation.item.result;
//                
//                if(current.item.downloadState == DownloadStateDownloading)
//                    current.item.downloadState = DownloadStateCompleted;
                
                if(current.item.errorType == DownloadErrorNone)
                    [current.item notify:DownloadItemHandlerTypeCompletion];
                 else
                    [current.item notify:DownloadItemHandlerTypeError];
            
                
                [removeArray addObject:current];
            }
        }];
        
        for(DownloadOperation *_operation in removeArray) {
            [_fileQueue removeObject:_operation];
        }
        
        [self dequeue];
    }];
}


+(void)setProgress:(float)progress toOperation:(DownloadOperation *)operation {
    [[DownloadQueue sharedManager] setProgress:progress toOperation:operation];
}

-(void)setProgress:(float)progress toOperation:(DownloadOperation *)operation {
    [DownloadQueue dispatchOnStageQueue:^{
        [self.fileQueue enumerateObjectsUsingBlock:^(DownloadOperation *current, NSUInteger idx, BOOL *stop) {
            
            if([current.item isEqualToItem:operation.item]) {
                
                current.item.progress = progress;
            }
        }];
    }];
}

+(void)addAndStartItem:(DownloadItem *)item {
    DownloadQueue *manager = [DownloadQueue sharedManager];
   
    
    [DownloadQueue dispatchOnStageQueue:^{
        DownloadOperation *operation = [[DownloadOperation alloc] initWithItem:item];
        [manager.fileQueue addObject:operation];
        [manager dequeue];
    }];
    
}

+(void)removeItem:(DownloadItem *)item {
    DownloadQueue *manager = [DownloadQueue sharedManager];
    [DownloadQueue dispatchOnStageQueue:^{
      
        __block int once = 0;
        __block NSMutableArray *removeArray = [[NSMutableArray alloc] init];
        
       [manager.fileQueue enumerateObjectsUsingBlock:^(DownloadOperation *obj, NSUInteger idx, BOOL *stop) {
           
           if([obj.item isEqualToItem:item])
               once++;
           
           if(obj.item == item) {
               [obj cancel];
               [removeArray addObject:obj];
           }
           
       }];
        
        [manager.fileQueue removeObjectsInArray:removeArray];
        
        if(once == 1)
            [manager erase:item];
        
    }];
}

-(void)erase:(DownloadItem *)item {
    std::map<long, DownloadItem *>::iterator it = _loading->find(item.n_id);
    if(it != _loading->end()) {
        _loading->erase(it);
    }
}

+(void)pauseItem:(DownloadItem *)item {
    
}

+(void)resetItem:(DownloadItem *)item {
    
}


@end
