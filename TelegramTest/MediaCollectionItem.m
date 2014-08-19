//
//  MediaCollectionItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 08.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MediaCollectionItem.h"
#import "DownloadPhotoItem.h"
#import "ImageCache.h"
#import "ImageUtils.h"
@interface MediaCollectionItem ()
@property (nonatomic,strong) DownloadPhotoItem *download;
@end

@implementation MediaCollectionItem

-(id)init {
    if(self = [super init]) {
        self.image = image_MessageMapPin();
    }
    
    return self;
}


- (id)initWithPreviewObject:(PreviewObject *)previewObject {
    
    if(self = [super init]) {
        _previewObject = previewObject;
        
        NSArray *sizes = ((TL_messageMediaPhoto *)[self.previewObject media]).photo.sizes;
        TL_photoSize *size;
        
        if(sizes.count > 0) {
           size = sizes[0];
        } else
            return nil;
        
        
        if([size isKindOfClass:[TL_photoCachedSize class]] && size.bytes.length > 0) {
            self.image = [[NSImage alloc] initWithData:size.bytes];
        } else {
            self.image = [[ImageCache sharedManager] imageFromMemory:size.location];
        }
        
        
        if(!self.image) {
//            _download = [[DownloadPhotoItem alloc] initWithObject:size.location size:size.size];
//            weakify();
//            [_download setCompleteHandler:^(DownloadItem *item) {
//                strongSelf.image = [[NSImage alloc] initWithData:item.result];
//            }];
//            
//            [_download start];
        }
    
        
        
        _size = strongsize(NSMakeSize(size.w, size.h), 60);
        
       
        
    }
    
    return self;
    
}

- (void)dealloc {
    [_download cancel];
}



@end
