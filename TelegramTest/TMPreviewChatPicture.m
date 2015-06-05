
//
//  TMPreviewChatPicture.m
//  Messenger for Telegram
//
//  Created by keepcoder on 07.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMPreviewChatPicture.h"
#import "TLFileLocation+Extensions.h"
#import "DownloadQueue.h"
#import "TMMediaController.h"
#import "DownloadPhotoItem.h"

@interface TMPreviewChatPicture ()
@property (nonatomic,assign) BOOL need_download;
@property (nonatomic,strong) DownloadItem * downloadItem;
@end


@implementation TMPreviewChatPicture

@synthesize previewObject = _previewObject;
@synthesize url = _url;
@synthesize downloadListener = _downloadListener;

-(id)initWithItem:(PreviewObject *)previewObject {
    if(self = [super init]) {
        
        if([((TL_photo *)previewObject.media) isKindOfClass:[TL_photoEmpty class]])
            return nil;
        
        _previewObject = previewObject;
        
        TL_photoSize *size = [((TL_photo *)_previewObject.media).sizes lastObject];
        
      
        _url = [NSURL fileURLWithPath:locationFilePath(size.location, @"jpg")];
    }
    
    return self;
}

-(BOOL)isEqualToItem:(id<TMPreviewItem>)item {
    
     TL_photoSize *size1 = [((TL_photo *)_previewObject.media).sizes lastObject];
    
     TL_photoSize *size2 = [((TL_photo *)[item previewObject].media).sizes lastObject];
    
    return [size1.location isEqual:size2.location];
}

-(NSString *)previewItemTitle {
    return NSLocalizedString(@"Photo",nil);
}

-(NSURL *)previewItemURL {
    if(!checkFileSize(_url.path, 0)) {
        TL_photoSize *size = [((TL_photo *)_previewObject.media).sizes lastObject];
        
        if(!self.downloadItem && self.downloadItem.downloadState != DownloadStateDownloading) {
            self.downloadItem = [[DownloadPhotoItem alloc] initWithObject:size.location size:0];
            
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
