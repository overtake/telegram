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


-(NSURL *)url {
    return [self.previewObject.reservedObject isKindOfClass:[NSDictionary class]] ? self.previewObject.reservedObject[@"url"] : [NSURL fileURLWithPath:mediaFilePath(self.previewObject.media)];
}

-(NSString *)path {
    return [self.previewObject.reservedObject isKindOfClass:[NSDictionary class]] ? nil : mediaFilePath(self.previewObject.media);
}

-(TL_localMessage *)message {
    return self.previewObject.media;
}

-(BOOL)isset {
   return [self.previewObject.reservedObject isKindOfClass:[NSDictionary class]] || ( isPathExists(self.path) && [FileUtils checkNormalizedSize:self.path checksize:self.message.media.document.size]);
}

-(DownloadItem *)downloadItem {
    
    if(_item == nil && ![self.previewObject.reservedObject isKindOfClass:[NSDictionary class]])
        _item = [DownloadQueue find:self.message.media.document.n_id];
    
    return _item;
}

-(NSSize)videoSize {
    
    if([self.previewObject.reservedObject isKindOfClass:[NSDictionary class]]) {
        return [self.previewObject.reservedObject[@"size"] sizeValue];
    } else {
        TL_documentAttributeVideo *video = (TL_documentAttributeVideo *) [self.message.media.document attributeWithClass:[TL_documentAttributeVideo class]];
        
        return NSMakeSize(video.w, video.h);
    }
    
    
}

-(void)startDownload {
    DownloadItem *downloadItem = self.downloadItem;
    
    if(!downloadItem) {
        downloadItem = [[DownloadVideoItem alloc] initWithObject:self.message];
    }
    
    if((downloadItem.downloadState == DownloadStateCanceled || downloadItem.downloadState == DownloadStateWaitingStart)) {
        [downloadItem start];
    }
    
    [Notification perform:UPDATE_MESSAGE_ITEM data:@{KEY_MESSAGE_ID:@(self.message.n_id),KEY_PEER_ID:@(self.message.peer_id)}];
    
    _item = downloadItem;
}

@end
