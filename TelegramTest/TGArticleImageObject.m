//
//  TGArticleImageObject.m
//  Telegram
//
//  Created by keepcoder on 07.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGArticleImageObject.h"

@implementation TGArticleImageObject

-(void)_didDownloadImage:(DownloadItem *)item {
    __block NSImage *imageOrigin = [[NSImage alloc] initWithData:item.result];
    
    
     NSImage *image = cropCenterWithSize(imageOrigin, self.imageSize);
    
    [TGCache cacheImage:image forKey:[self cacheKey] groups:@[IMGCACHE]];
        
    [ASQueue dispatchOnMainQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}

@end
