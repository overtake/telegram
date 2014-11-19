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


-(void)_didDownloadImage:(DownloadItem *)item {
    NSImage *image = [[NSImage alloc] initWithData:item.result];
    
    image = renderedImage(image,self.imageSize);
    
    [TGCache cacheImage:image forKey:self.location.cacheKey groups:@[PVCACHE]];
    
    [[ASQueue mainQueue] dispatchOnQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}

@end
