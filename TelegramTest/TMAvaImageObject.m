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
    
    NSImage *image = [TMImageUtils roundedImageNew:imageOrigin size:self.imageSize];
    
    image = renderedImage(image, image.size);
    
    [TGCache cacheImage:image forKey:[NSString stringWithFormat:@"%lu:%@",self.location.hashCacheKey,NSStringFromSize(self.imageSize)] groups:@[AVACACHE]];
    
    [ASQueue dispatchOnMainQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}

@end
