//
//  TMPreviewUserPicture.m
//  Messenger for Telegram
//
//  Created by keepcoder on 12.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMPreviewUserPicture.h"
#import "TLFileLocation+Extensions.h"
#import "FileUtils.h"
#import "DownloadQueue.h"
#import "TMMediaController.h"
#import "DownloadPhotoItem.h"
@interface TMPreviewUserPicture ()
@property (nonatomic,assign) BOOL need_download;
@property (nonatomic,strong) DownloadItem * downloadItem;
@end

@implementation TMPreviewUserPicture

@synthesize previewObject = _previewObject;
@synthesize url = _url;
@synthesize downloadListener = _downloadListener;

-(id)initWithItem:(PreviewObject *)previewObject {
    if(self = [super init]) {
        
        _previewObject = previewObject;
        
        
        if([previewObject.media isKindOfClass:[TL_fileLocation class]]) {
           
            _url = [NSURL fileURLWithPath:locationFilePath(previewObject.media, @"jpg")];
        
        } else {
         
            return nil;
        
        }
        
       
    }

    return self;
}

-(BOOL)isEqualToItem:(id<TMPreviewItem>)item {
    
    TL_fileLocation *location1 = _previewObject.media;
    
    
     TL_fileLocation *location2 = item.previewObject.media;
    
    
    return [location1 isEqual:location2];
}

-(NSString *)previewItemTitle {
    return NSLocalizedString(@"Photo",nil);
}

-(NSURL *)previewItemURL {
    if(!checkFileSize(_url.path, 0)) {
        
         TL_fileLocation *location = _previewObject.media;
        
        if(!self.downloadItem && self.downloadItem.downloadState != DownloadStateDownloading) {
            self.downloadItem = [[DownloadPhotoItem alloc] initWithObject:location size:0];
            
            [self.downloadItem removeEvent:self.downloadListener];
            
            self.downloadListener = [[DownloadEventListener alloc] init];
            
            [self.downloadItem addEvent:self.downloadListener];
            
            weakify();
            
            [self.downloadListener setCompleteHandler:^(DownloadItem * item) {
                
                [[ASQueue mainQueue] dispatchOnQueue:^{
                    if([[TMMediaController getCurrentController] currentItem] == strongSelf)
                        [[TMMediaController getCurrentController] refreshCurrentPreviewItem];
                    strongSelf.downloadItem = nil;
                }];
                
            }];
            
            [self.downloadItem start];
        }
        
        
        
        return nil;
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
