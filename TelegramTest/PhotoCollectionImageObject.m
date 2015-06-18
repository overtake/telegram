//
//  PhotoCollectionImageObject.m
//  Telegram
//
//  Created by keepcoder on 05.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PhotoCollectionImageObject.h"
#import "DownloadPhotoCollectionItem.h"
#import "TLFileLocation+Extensions.h"
#import "PhotoCollectionImageView.h"
#import "TGCache.h"
@implementation PhotoCollectionImageObject

@synthesize supportDownloadListener = _supportDownloadListener;

static const int width = 180;


-(id)initWithLocation:(TLFileLocation *)location placeHolder:(NSImage *)placeHolder sourceId:(int)sourceId size:(int)size {
    if(self = [super initWithLocation:location placeHolder:placeHolder sourceId:sourceId size:size]) {
    }
    
    return self;
}

-(void)initDownloadItem {
    
    
    if((self.downloadItem && (self.downloadItem.downloadState != DownloadStateCompleted && self.downloadItem.downloadState != DownloadStateCanceled && self.downloadItem.downloadState != DownloadStateWaitingStart)) || !self.location)
        return;//[_downloadItem cancel];
    
    
    self.downloadItem = [[DownloadPhotoCollectionItem alloc] initWithObject:self.location size:self.size];
    
    self.downloadListener = [[DownloadEventListener alloc] init];
    
    
    _supportDownloadListener = [[DownloadEventListener alloc] init];
    
    [self.downloadItem addEvent:_supportDownloadListener];
    
    [self.downloadItem addEvent:self.downloadListener];
    
    
    weak();
    
    [self.downloadListener setCompleteHandler:^(DownloadItem * item) {
        
        [ASQueue dispatchOnStageQueue:^{
            
            weakSelf.isLoaded = YES;
            
            [weakSelf _didDownloadImage:item];
            weakSelf.downloadItem = nil;
            weakSelf.downloadListener = nil;
            
        }];
       
    }];
    
    
    [self.downloadListener setProgressHandler:^(DownloadItem * item) {
        if([weakSelf.delegate respondsToSelector:@selector(didUpdatedProgress:)]) {
            [weakSelf.delegate didUpdatedProgress:item.progress];
        }
    }];
    
    
    [self.downloadItem start];
}

-(NSImage *)placeholder {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSRect rect = NSMakeRect(0, 0, 120, 120);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        
        [GRAY_BORDER_COLOR setFill];
        NSRectFill(rect);
        [image unlockFocus];
        
    });
    return image;
}


-(void)_didDownloadImage:(DownloadItem *)item {
    const NSSize size = NSMakeSize(width, width);
    
    NSImage *image = [[NSImage alloc] initWithData:item.result];
    
    if(item.isRemoteLoaded) {
        
        [[NSFileManager defaultManager] moveItemAtPath:item.path toPath:locationFilePath(self.location, @"jpg") error:nil];
        
        image = cropCenterWithSize(image, size);
        
        [jpegNormalizedData(image) writeToFile:item.path atomically:YES];
        
    }
    
    image = decompressedImage(image);
    
    [TGCache cacheImage:image forKey:self.location.cacheKey groups:@[PCCACHE]];
    
    
    
    [[ASQueue mainQueue] dispatchOnQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];

}

@end
