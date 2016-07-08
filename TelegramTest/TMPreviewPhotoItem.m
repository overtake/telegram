//
//  TMPreviewItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 11.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMPreviewPhotoItem.h"
#import "FileUtils.h"
#import "TLFileLocation+Extensions.h"
#import "DownloadQueue.h"
#import "TMMediaController.h"
#import "DownloadPhotoItem.h"
#import "ImageUtils.h"
@interface TMPreviewPhotoItem ()


@property (nonatomic,strong) DownloadPhotoItem *downloadItem;
@end

@implementation TMPreviewPhotoItem

@synthesize url = _url;
@synthesize previewObject = _previewObject;
@synthesize previewImage = _previewImage;
@synthesize downloadListener = _downloadListener;

-(id)initWithPath:(NSString *)path {
    if(self = [super init]) {
        _url = path ? [NSURL fileURLWithPath:path] : nil;
    }
    return self;
}


-(id)initWithItem:(PreviewObject *)previewObject {
    if(self = [super init]) {
         _previewObject = previewObject;
        
        
         TL_photoSize *size = [((TL_messageMediaPhoto *)[(TL_localMessage *)_previewObject.media media]).photo.sizes lastObject];
        
        if(size.location.dc_id == 0 || size.location.secret == 0)
            return nil;
        _url = [[NSURL alloc] initFileURLWithPath:locationFilePath(size.location, @"jpg")];
        
    }
    
    return self;
}



-(BOOL)isEqualToItem:(id<TMPreviewItem>)item {
    return _previewObject.msg_id == item.previewObject.msg_id;
}


-(NSString *)previewItemTitle {
    return NSLocalizedString(@"Photo",nil);
}

-(NSImage *)previewImage {
    
    TL_photoSize *size = [((TL_messageMediaPhoto *)[(TL_localMessage *)_previewObject.media media]).photo.sizes lastObject];
    
    if(!_previewImage) {
        _previewImage = _previewImage = [TGCache cachedImage:size.location.cacheKey];
       
    }
    
    return _previewImage;
}


-(NSURL *)previewItemURL {
    NSArray *sizes = ((TL_messageMediaPhoto *)[(TL_localMessage *)_previewObject.media media]).photo.sizes;
    
    TL_photoSize *size = [sizes lastObject];
    
    
    if(!checkFileSize(_url.path, size.size)) {
        if(!self.downloadItem && self.downloadItem.downloadState != DownloadStateDownloading) {
            self.downloadItem = [[DownloadPhotoItem alloc] initWithObject:size.location size:0];
            
            [self.downloadItem removeEvent:self.downloadListener];
            
            self.downloadListener = [[DownloadEventListener alloc] init];
            
            [self.downloadItem addEvent:self.downloadListener];
            
            weak();
            
            [self.downloadListener setCompleteHandler:^(DownloadItem * item) {
                
                [ASQueue dispatchOnMainQueue:^{
                    if([[TMMediaController getCurrentController] currentItem] == weakSelf)
                        [[TMMediaController getCurrentController] refreshCurrentPreviewItem];
                    weakSelf.downloadItem = nil;
                }];
            }];
            
            [self.downloadItem start];
        }
        return nil;
        
    }  else if(sizes.count > 1) {
        size = sizes[0];
        NSString *path = locationFilePath(size.location, @"jpg");
        if(checkFileSize(path, size.size)) {
            return [NSURL fileURLWithPath:path];
        }
    }
    return _url;
}

- (NSString *)fileName {
    NSString *filename = [self.url lastPathComponent];
    filename = [filename stringByReplacingOccurrencesOfString:@".tiff" withString:@".jpg"];
    
    if(!filename)
        filename = @"file";
    return filename;
}

@end
