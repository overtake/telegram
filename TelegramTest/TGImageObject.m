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

-(id)initWithLocation:(TLFileLocation *)location {
    if(self = [self initWithLocation:location placeHolder:nil sourceId:0 size:0]) {
        
    }
    return self;
}

-(id)initWithLocation:(TLFileLocation *)location placeHolder:(NSImage *)placeHolder {
    if(self = [self initWithLocation:location placeHolder:placeHolder sourceId:0 size:0]) {
        
    }
    return self;
}


-(id)initWithLocation:(TLFileLocation *)location placeHolder:(NSImage *)placeHolder sourceId:(int)sourceId {
    if(self = [self initWithLocation:location placeHolder:placeHolder sourceId:sourceId size:0]) {
        
    }
    return self;
}

-(id)initWithLocation:(TLFileLocation *)location placeHolder:(NSImage *)placeHolder sourceId:(int)sourceId size:(int)size {
    if(self = [super init]) {
        _location = location;
        _placeholder = placeHolder;
        _sourceId = sourceId;
        _size = size;
    }
    return self;
}



-(void)initDownloadItem {
    
    
    if(_downloadItem )
        return;//[_downloadItem cancel];
    

    _downloadItem = [[DownloadPhotoItem alloc] initWithObject:_location size:_size];
    
    _downloadListener = [[DownloadEventListener alloc] initWithItem:_downloadItem];

    _supportDownloadListener = [[DownloadEventListener alloc] initWithItem:_downloadItem];
    
    
    [_downloadItem addEvent:_supportDownloadListener];
    [_downloadItem addEvent:_downloadListener];
    
    
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
    
    
    [_downloadItem start];
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

-(void)dealloc {
    [self.downloadItem removeEvent:self.downloadListener];
    _downloadItem = nil;
}

-(NSString *)cacheKey {
    return self.location.cacheKey;
}


@end