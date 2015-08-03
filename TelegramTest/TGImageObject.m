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
        weakSelf.isLoaded = YES;
        
        [weakSelf _didDownloadImage:item];
        weakSelf.downloadItem = nil;
        weakSelf.downloadListener = nil;
    }];
    
    
    [self.downloadListener setProgressHandler:^(DownloadItem * item) {
        if([weakSelf.delegate respondsToSelector:@selector(didUpdatedProgress:)]) {
            [weakSelf.delegate didUpdatedProgress:item.progress];
        }
    }];
    
    
    [self.downloadItem start];
}

-(void)_didDownloadImage:(DownloadItem *)item {
    NSImage *image = [[NSImage alloc] initWithData:item.result];
    
    
    if(image != nil) {
        if(NSSizeNotZero(self.realSize) && NSSizeNotZero(self.imageSize) && self.realSize.width > MIN_IMG_SIZE.width && self.realSize.width > MIN_IMG_SIZE.height && self.imageSize.width == MIN_IMG_SIZE.width && self.imageSize.height == MIN_IMG_SIZE.height) {
            
            int difference = roundf( (self.realSize.width - self.imageSize.width) /2);
            
            image = cropImage(image,self.imageSize, NSMakePoint(difference, 0));
            
        }
        
        image = renderedImage(image, self.imageSize);
        
        [TGCache cacheImage:image forKey:[self cacheKey] groups:@[IMGCACHE]];
    }
        
    [[ASQueue mainQueue] dispatchOnQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}


@end