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
        
        weak();
        
        [TGImageObject.threadPool addTask:[[SThreadPoolTask alloc] initWithBlock:^(bool (^canceled)()) {
            
            strongWeak();
            
            if(strongSelf == weakSelf) {
                NSImage *image = previewImageForDocument(strongSelf.path);
                
                image = cropCenterWithSize(image,strongSelf.imageSize);
                
                [TGCache cacheImage:image forKey:strongSelf.cacheKey groups:@[IMGCACHE]];
                
                [ASQueue dispatchOnMainQueue:^{
                    _inited = NO;
                    [strongSelf.delegate didDownloadImage:image object:strongSelf];
                }];
            }
            
            
            
        }]];
    }
    
}

@end
