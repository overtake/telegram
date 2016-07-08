//
//  TGStickerImageObject.m
//  Telegram
//
//  Created by keepcoder on 18.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGStickerImageObject.h"
#import "DownloadStickerItem.h"
#import "webp/decode.h"
#import "DownloadQueue.h"
@interface TGStickerImageObject ()
@property (nonatomic,strong) TLDocument *document;
@end


@implementation TGStickerImageObject

@synthesize placeholder = _placeholder;
@synthesize supportDownloadListener = _supportDownloadListener;

-(id)initWithDocument:(TLDocument *)document placeholder:(NSImage *)placeholder {
    if(self = [super init]) {
        _document = document;
        _placeholder = placeholder;
    }
    
    return self;
}


-(void)initDownloadItem {
    
    
    if((self.downloadItem && (self.downloadItem.downloadState != DownloadStateCompleted && self.downloadItem.downloadState != DownloadStateCanceled && self.downloadItem.downloadState != DownloadStateWaitingStart)))
        return;//[_downloadItem cancel];
    
    
    self.downloadItem = [[DownloadStickerItem alloc] initWithObject:_document];
    
    self.downloadListener = [[DownloadEventListener alloc] init];
    
    _supportDownloadListener = [[DownloadEventListener alloc] init];
    
    [self.downloadItem addEvent:_supportDownloadListener];
    
    [self.downloadItem addEvent:self.downloadListener];
    
    
    weak();
    
    [self.downloadListener setCompleteHandler:^(DownloadItem * item) {
        
        [TGImageObject.threadPool addTask:[[SThreadPoolTask alloc] initWithBlock:^(bool (^canceled)()) {
            
            strongWeak();
            
            if(strongSelf == weakSelf) {
                weakSelf.isLoaded = YES;
                [weakSelf _didDownloadImage:item];
                weakSelf.downloadItem = nil;
                weakSelf.downloadListener = nil;
            }
            
        }]];
          
    }];
    
    
    [self.downloadListener setProgressHandler:^(DownloadItem * item) {
        if([weakSelf.delegate respondsToSelector:@selector(didUpdatedProgress:)]) {
            [weakSelf.delegate didUpdatedProgress:item.progress];
        }
    }];
    
    
    [self.downloadItem start];
}

-(void)_didDownloadImage:(DownloadItem *)item {
    
    NSError *error = nil;
    
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:item.path];
    
    if(!image)
        image = [NSImage imageWithWebP:item.path error:&error];
    
    
    image = renderedImage(image, self.imageSize);
    
    if(error == nil) {
        [TGCache cacheImage:image forKey:[self cacheKey] groups:@[IMGCACHE]];
    }
   
    
    [ASQueue dispatchOnMainQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}

-(void)dealloc {
    [self.downloadItem removeEvent:self.downloadListener];
    self.downloadItem = nil;
}

-(NSString *)cacheKey {
    return [NSString stringWithFormat:@"s:%ld",_document.n_id];
}

@end
