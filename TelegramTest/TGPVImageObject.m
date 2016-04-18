//
//  TGPVImageObject.m
//  Telegram
//
//  Created by keepcoder on 18.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGPVImageObject.h"
#import "DownloadPhotoItem.h"
@implementation TGPVImageObject

-(void)initDownloadItem {
    [super initDownloadItem];
    
    [self.downloadItem setDeliveryQueue:[ASQueue mainQueue]];
    
    weak();
    
    [self.downloadListener setCompleteHandler:^(DownloadItem * item) {
        
        strongWeak();
        
        if(strongSelf == weakSelf) {
            
            strongSelf.isLoaded = YES;
            [strongSelf _didDownloadImage:item];
            strongSelf.downloadItem = nil;
            strongSelf.downloadListener = nil;

        }
        
        
        
    }];
    
}

-(void)_didDownloadImage:(DownloadItem *)item {
    
    NSImage *image = [[NSImage alloc] initWithData:item.result];
    
    [TGCache cacheImage:image forKey:self.location.cacheKey groups:@[PVCACHE]];

    
    [self.delegate didDownloadImage:image object:self];
}



@end
