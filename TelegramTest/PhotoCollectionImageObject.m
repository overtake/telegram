//
//  PhotoCollectionImageObject.m
//  Telegram
//
//  Created by keepcoder on 05.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PhotoCollectionImageObject.h"
#import "DownloadPhotoCollectionItem.h"
#import "TGFileLocation+Extensions.h"
#import "PhotoCollectionImageView.h"
#import "TGCache.h"
@implementation PhotoCollectionImageObject


static const int width = 180;

-(id)initWithLocation:(TGFileLocation *)location placeHolder:(NSImage *)placeHolder sourceId:(int)sourceId size:(int)size {
    if(self = [super initWithLocation:location placeHolder:placeHolder sourceId:sourceId size:size]) {
    }
    
    return self;
}


-(void)_didDownloadImage:(DownloadItem *)item {
    const NSSize size = NSMakeSize(width, width);
    
    NSImage *image = [[NSImage alloc] initWithData:item.result];
    
    if(item.isRemoteLoaded) {
        
        image = cropCenterWithSize(image, size);
        
        [jpegNormalizedData(image) writeToFile:item.path atomically:YES];
        
    }
    
    image = renderedImage(image, image.size);
    
    [TGCache cacheImage:image forKey:self.location.cacheKey groups:@[PCCACHE]];
    
    [[ASQueue mainQueue] dispatchOnQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];

}

@end
