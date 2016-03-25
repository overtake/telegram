//
//  TGImageObject.m
//  Telegram
//
//  Created by keepcoder on 17.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGImageObject.h"
#import "DownloadPhotoItem.h"
#import "ImageCache.h"
#import "TGImageView.h"
#import "ImageUtils.h"
#import "TLFileLocation+Extensions.h"
#import "TGCache.h"
@implementation TGImageObject

@synthesize supportDownloadListener = _supportDownloadListener;

-(void)initDownloadItem {
    
    
    if((self.downloadItem && (self.downloadItem.downloadState != DownloadStateCompleted && self.downloadItem.downloadState != DownloadStateCanceled && self.downloadItem.downloadState != DownloadStateWaitingStart)) || !self.location)
        return;//[_downloadItem cancel];
    

    self.downloadItem = [[DownloadPhotoItem alloc] initWithObject:self.location size:self.size];
    
    self.downloadListener = [[DownloadEventListener alloc] init];

    _supportDownloadListener = [[DownloadEventListener alloc] init];
    
    
    [self.downloadItem addEvent:self.supportDownloadListener];
    [self.downloadItem addEvent:self.downloadListener];
    
    
    weak();

    [self.downloadListener setCompleteHandler:^(DownloadItem * item) {
        
        strongWeak();
        
        if(strongSelf == weakSelf) {
            [TGImageObject.threadPool addTask:[[SThreadPoolTask alloc] initWithBlock:^(bool (^canceled)()) {
                strongWeak();
                
                if(strongSelf == weakSelf) {
                    strongSelf.isLoaded = YES;
                    [strongSelf _didDownloadImage:item];
                    strongSelf.downloadItem = nil;
                    strongSelf.downloadListener = nil;
                }
                
            }]];
            

        }
        
        
       
    }];
    
    
    [self.downloadListener setProgressHandler:^(DownloadItem * item) {
        if([weakSelf.delegate respondsToSelector:@selector(didUpdatedProgress:)]) {
            [weakSelf.delegate didUpdatedProgress:item.progress];
        }
    }];
    
    
    [self.downloadItem start];
}

-(NSImage *)placeholder {
    __block NSImage *placeHolder = super.placeholder;
    
    if(placeHolder && _thumbProcessor) {
        
        weak();
        
        [TGImageObject.threadPool addTask:[[SThreadPoolTask alloc] initWithBlock:^(bool (^canceled)()) {
            
            strongWeak();
            
            if(strongSelf == weakSelf && _thumbProcessor) {
                
                placeHolder = _thumbProcessor(placeHolder,self.imageSize);
                super.placeholder = placeHolder;
                _thumbProcessor = nil;
                
                [ASQueue dispatchOnMainQueue:^{
                    [self.delegate didDownloadImage:placeHolder object:self];
                }];
            }

        }]];
        
        return gray_resizable_placeholder();
    }
    
    return super.placeholder;
}

-(void)_didDownloadImage:(DownloadItem *)item {
    NSImage *image = [[NSImage alloc] initWithData:item.result];
    
    
    if(image != nil) {
        
        if(self.imageProcessor != nil) {
            image = self.imageProcessor(image,self.imageSize);
        } else {
            if(NSSizeNotZero(self.realSize) && NSSizeNotZero(self.imageSize) && self.realSize.width > MIN_IMG_SIZE.width && self.realSize.width > MIN_IMG_SIZE.height && self.imageSize.width == MIN_IMG_SIZE.width && self.imageSize.height == MIN_IMG_SIZE.height) {
                
                int difference = roundf( (self.realSize.width - self.imageSize.width) /2);
                
                image = cropImage(image,self.imageSize, NSMakePoint(difference, 0));
                
            }
            
            image = renderedImage(image, self.imageSize);
        }
        
        [TGCache cacheImage:image forKey:[self cacheKey] groups:@[IMGCACHE]];
    }
    

    [[ASQueue mainQueue] dispatchOnQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}

+(SThreadPool *)threadPool {
    static SThreadPool *pool;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pool = [[SThreadPool alloc] initWithThreadCount:3 threadPriority:0.5];
    });
    
    
    return pool;
}


-(BOOL)isset {
    
    return [TGCache cachedImage:self.cacheKey] || ((fileSize(self.location.path) >= self.size || (self.size == 0 && isPathExists(self.location.path))) && self.downloadItem == nil);
}


@end