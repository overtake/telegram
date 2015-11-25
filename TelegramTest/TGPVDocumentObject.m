//
//  TGPVDocumentObject.m
//  Telegram
//
//  Created by keepcoder on 06.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGPVDocumentObject.h"
#import "DownloadDocumentItem.h"
#import "DownloadDocumentItem.h"
@interface TGPVDocumentObject ()
@property (nonatomic,strong) TL_localMessage *message;
@end

@implementation TGPVDocumentObject

@synthesize supportDownloadListener = _supportDownloadListener;


-(id)initWithMessage:(TL_localMessage *)message placeholder:(NSImage *)placeholder {
    if(self = [super initWithLocation:nil placeHolder:placeholder]) {
        _message = message;
        
       
        
    }
    
    return self;
}

-(void)initDownloadItem {
    
    
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:mediaFilePath(self.message.media)];
    
    if(image.size.width > 0 && image.size.height > 0) {
        
         self.imageSize = image.size;
        
        [TGCache cacheImage:image forKey:[self cacheKey] groups:@[PVCACHE]];
        
        [self.delegate didDownloadImage:image object:self];
        return;
    }
    
    
    
    if((self.downloadItem && (self.downloadItem.downloadState != DownloadStateCompleted && self.downloadItem.downloadState != DownloadStateCanceled && self.downloadItem.downloadState != DownloadStateWaitingStart)) || !self.message)
        return;//[_downloadItem cancel];
    
    
    self.downloadItem = [[DownloadDocumentItem alloc] initWithObject:self.message];
    
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
        
        image = renderedImage(image, image.size.width > 0 && image.size.height > 0 ? image.size : self.imageSize);
        
        [TGCache cacheImage:image forKey:[self cacheKey] groups:@[PVCACHE]];
    }
        
    [[ASQueue mainQueue] dispatchOnQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}


-(NSString *)cacheKey {
    return [NSString stringWithFormat:@"doc:%lu",_message.media.document.n_id];
}


@end
