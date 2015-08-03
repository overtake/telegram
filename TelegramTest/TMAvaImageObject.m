//
//  TMAvaImageObject.m
//  Telegram
//
//  Created by keepcoder on 19.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMAvaImageObject.h"
#import "TMImageUtils.h"

@implementation TMAvaImageObject


-(void)_didDownloadImage:(DownloadItem *)item {
    __block NSImage *imageOrigin = [[NSImage alloc] initWithData:item.result];

    NSImage *image = renderedImage(imageOrigin, imageOrigin.size.width == 0 || imageOrigin.size.height ? self.imageSize : imageOrigin.size);
    
    [TGCache cacheImage:image forKey:self.location.cacheKey groups:@[AVACACHE]];
    
    image = [TMImageUtils roundedImageNew:image size:self.imageSize];
    
    [TGCache cacheImage:image forKey:[self cacheKey] groups:@[AVACACHE]];
    
    [ASQueue dispatchOnMainQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}

-(NSString *)cacheKey {
    return [NSString stringWithFormat:@"%lu:%@",self.location.hashCacheKey,NSStringFromSize(self.imageSize)];
}

@end
