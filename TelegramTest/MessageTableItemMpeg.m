
//
//  MessageTableItemMpeg.m
//  Telegram
//
//  Created by keepcoder on 10/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "MessageTableItemMpeg.h"
#import "TGBlurImageObject.h"
#import "DownloadQueue.h"
#import "TGThumbnailObject.h"
#import "DownloadDocumentItem.h"
#import "DownloadExternalItem.h"
#import "TGExternalImageObject.h"
@interface MessageTableItemMpeg () {
    NSString *_path;
}
@property (nonatomic,strong) TL_documentAttributeVideo *imagesize;
@end

@implementation MessageTableItemMpeg


-(id)initWithObject:(TL_localMessage *)object {
    if(self = [super initWithObject:object]) {
        
        _imagesize = (TL_documentAttributeVideo *) [self.document attributeWithClass:[TL_documentAttributeVideo class]];
        
        [self doAfterDownload];
        
        
        [self checkStartDownload:0 size:[self size]];
        
    }
    
    return self;
}

-(TLDocument *)document {
    if([self.message.media isKindOfClass:[TL_messageMediaBotResult class]]) {
        return self.message.media.bot_result.document;
    } else
        return self.message.media.document;
}

-(TL_documentAttributeVideo *)imagesize {
    
    __block TL_documentAttributeVideo *imageSize = _imagesize;
    
    if(imageSize == nil) {
        
        dispatch_block_t thumbblock = ^{
            if(self.document && ![self.document.thumb isKindOfClass:[TL_photoSizeEmpty class]])  {
                imageSize = [TL_documentAttributeVideo createWithDuration:0 w:self.document.thumb.w * 3 h:self.document.thumb.h * 3];
            } else {
                if(self.message.media.bot_result != nil)
                    imageSize = [TL_documentAttributeVideo createWithDuration:0 w:self.message.media.bot_result.w h:self.message.media.bot_result.h];
                else
                    imageSize = [TL_documentAttributeVideo createWithDuration:0 w:480 h:320];
            }
        };
        
        if(self.isset) {
            
            AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.path]];
            
            if(asset.naturalSize.width > 0 && asset.naturalSize.height > 0) {
                 _imagesize = imageSize = [TL_documentAttributeVideo createWithDuration:CMTimeGetSeconds([asset duration]) w:[asset naturalSize].width h:[asset naturalSize].height];
            } else {
                thumbblock();
            }
            
            
        } else {
            thumbblock();
        }
    }
    
    return imageSize;
}

-(void)doAfterDownload {
    [super doAfterDownload];
    
    if(self.document && ![self.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
        _thumbObject = [[TGBlurImageObject alloc] initWithLocation:self.document.thumb.location thumbData:self.document.thumb.bytes size:self.document.thumb.size];
        _thumbObject.imageSize = NSMakeSize(self.imagesize.w, self.imagesize.h);
    } else {
        if(self.message.media.bot_result.thumb_url.length > 0) {
            _thumbObject = [[TGExternalImageObject alloc] initWithURL:self.message.media.bot_result.thumb_url];
            _thumbObject.imageSize = NSMakeSize(self.imagesize.w, self.imagesize.h);
        }
    }
    
}

-(Class)downloadClass {
    return self.document != nil ? [DownloadDocumentItem class] : [DownloadExternalItem class];
}



- (void)startDownload:(BOOL)cancel force:(BOOL)force {
    
    
    DownloadItem *downloadItem = self.downloadItem;
    
    if(!downloadItem) {
        if(self.document != nil)
            downloadItem = [[DownloadDocumentItem alloc] initWithObject:self.message];
         else
             downloadItem = [[DownloadExternalItem alloc] initWithObject:self.message.media.bot_result.content_url];
            
        
    }
    
    if((downloadItem.downloadState == DownloadStateCanceled || downloadItem.downloadState == DownloadStateWaitingStart) && (force)) {
        [downloadItem start];
    }
    
    
}

-(DownloadItem *)downloadItem {
    
    if(super.downloadItem == nil) {
        [super setDownloadItem:[DownloadQueue find:self.document.n_id]];
    }
    
    return [super downloadItem];
}



-(int)size {
    return self.document.size;
}

-(BOOL)makeSizeByWidth:(int)width {
    [super makeSizeByWidth:width];
    
    self.blockSize = strongsize(NSMakeSize(self.imagesize.w, self.imagesize.h), MIN(380,width - 60));
    
    return YES;
}


- (void)checkStartDownload:(SettingsMask)setting size:(int)size {
    
    if((self.size <= 10*1024*1024 && !self.downloadItem && !self.isset) || (self.downloadItem && self.downloadItem.downloadState != DownloadStateCanceled)) {
        [self startDownload:NO force:YES];
    }
    
}

- (BOOL)isset {
    BOOL isset = isPathExists([self path]) && (fileSize([self path]) >= self.size);
    
    return isset;
}

-(NSString *)path {
    return  mediaFilePath(self.message);
}

@end
