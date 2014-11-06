//
//  PhotoCollectionImageObject.m
//  Telegram
//
//  Created by keepcoder on 05.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PhotoCollectionImageObject.h"
#import "DownloadPhotoCollectionItem.h"
@implementation PhotoCollectionImageObject

@synthesize downloadItem = _downloadItem;
@synthesize downloadListener = _downloadListener;


static const int width = 100;

-(void)initDownloadItem {
    
    
    if(_downloadItem) {
        return;//[_downloadItem cancel];
    }
    
    _downloadItem = [[DownloadPhotoCollectionItem alloc] initWithObject:self.location size:self.size];
    
    
    
    _downloadListener = [[DownloadEventListener alloc] initWithItem:_downloadItem];
    
    [_downloadItem addEvent:_downloadListener];
    
    
    weak();
    
    [self.downloadListener setCompleteHandler:^(DownloadItem * item) {
        
        
        const NSSize size = NSMakeSize(width, width);
        
        
        NSImage *image = decompressedImage([[NSImage alloc] initWithData:item.result]);
        
        
        if(item.isRemoteLoaded) {
            
            image = cropCenterWithSize(image, size);
            
            [jpegNormalizedData(image) writeToFile:item.path atomically:YES];

        }
        
        
         weakSelf.downloadItem = nil;
        
        [[ASQueue mainQueue] dispatchOnQueue:^{
            [weakSelf.delegate didDownloadImage:image object:weakSelf];
        }];
        
    }];
    
    [_downloadItem start];

}


@end
