//
//  TGVideoViewerItem.m
//  Telegram
//
//  Created by keepcoder on 09/03/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGVideoViewerItem.h"
#import "DownloadVideoItem.h"
#import "DownloadQueue.h"
@interface TGVideoViewerItem ()
@property (nonatomic,strong) DownloadItem *item;
@end

@implementation TGVideoViewerItem

-(id)initWithImageObject:(TGImageObject *)imageObject previewObject:(PreviewObject *)previewObject {
    if(self = [super initWithImageObject:imageObject previewObject:previewObject]) {
        
       
        
    }
    
    return self;
}

-(NSString *)path {
    return mediaFilePath(self.previewObject.media);
}

-(TL_localMessage *)message {
    return self.previewObject.media;
}

-(BOOL)isset {
   return isPathExists(self.path) && [FileUtils checkNormalizedSize:self.path checksize:self.message.media.document.size];
}

-(DownloadItem *)downloadItem {
    
    if(_item == nil)
        _item = [DownloadQueue find:self.message.media.document.n_id];
    
    return _item;
}

-(NSSize)videoSize {
    TL_documentAttributeVideo *video = (TL_documentAttributeVideo *) [self.message.media.document attributeWithClass:[TL_documentAttributeVideo class]];
    
    return NSMakeSize(video.w, video.h);
}

-(void)startDownload {
    DownloadItem *downloadItem = self.downloadItem;
    
    if(!downloadItem) {
        downloadItem = [[DownloadVideoItem alloc] initWithObject:self.message];
    }
    
    if((downloadItem.downloadState == DownloadStateCanceled || downloadItem.downloadState == DownloadStateWaitingStart)) {
        [downloadItem start];
    }
    _item = downloadItem;
}

@end
