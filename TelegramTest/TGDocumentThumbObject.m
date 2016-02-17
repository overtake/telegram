//
//  TGDocumentThumbObject.m
//  Telegram
//
//  Created by keepcoder on 16/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGDocumentThumbObject.h"
#import "DownloadQueue.h"
@interface TGDocumentThumbObject ()
{
    BOOL _inited;
}
@end

@implementation TGDocumentThumbObject


-(void)initDownloadItem {
    
    if(!_inited) {
        _inited = YES;
        
        [DownloadQueue dispatchOnDownloadQueue:^{
            
            NSImage *image = previewImageForDocument(self.path);
            
            image = cropCenterWithSize(image,self.imageSize);
            
            [TGCache cacheImage:image forKey:self.cacheKey groups:@[IMGCACHE]];
            
            [ASQueue dispatchOnMainQueue:^{
                _inited = NO;
                [self.delegate didDownloadImage:image object:self];
            }];
            
        }];
    }
    
}

@end
