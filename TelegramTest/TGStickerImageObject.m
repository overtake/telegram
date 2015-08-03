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
@interface TGStickerImageObject ()
@property (nonatomic,strong) TL_localMessage *message;
@end


@implementation TGStickerImageObject

@synthesize placeholder = _placeholder;
@synthesize supportDownloadListener = _supportDownloadListener;

-(id)initWithMessage:(TL_localMessage *)message placeholder:(NSImage *)placeholder {
    if(self = [super init]) {
        self.message = message;
        _placeholder = placeholder;
    }
    
    return self;
}


-(void)initDownloadItem {
    
    
    if((self.downloadItem && (self.downloadItem.downloadState != DownloadStateCompleted && self.downloadItem.downloadState != DownloadStateCanceled && self.downloadItem.downloadState != DownloadStateWaitingStart)))
        return;//[_downloadItem cancel];
    
    
    self.downloadItem = [[DownloadStickerItem alloc] initWithObject:self.message];
    
    self.downloadListener = [[DownloadEventListener alloc] init];
    
    _supportDownloadListener = [[DownloadEventListener alloc] init];
    
    [self.downloadItem addEvent:_supportDownloadListener];
    
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
    
    NSError *error = nil;
    
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:item.path];
    
    if(!image)
        image = [NSImage imageWithWebP:item.path error:&error];
    
    
    image = renderedImage(image, self.imageSize);
    
    if(error == nil) {
        [TGCache cacheImage:image forKey:[self cacheKey] groups:@[IMGCACHE]];
    }
   
    
    [[ASQueue mainQueue] dispatchOnQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}

-(void)dealloc {
    [self.downloadItem removeEvent:self.downloadListener];
    self.downloadItem = nil;
}

-(NSString *)cacheKey {
    return [NSString stringWithFormat:@"s:%ld",self.message.media.document.n_id];
}

@end
