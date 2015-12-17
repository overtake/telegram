
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
@interface MessageTableItemMpeg () {
    NSString *_path;
}
@property (nonatomic,strong) TL_documentAttributeVideo *imagesize;
@end

@implementation MessageTableItemMpeg


-(id)initWithObject:(TL_localMessage *)object {
    if(self = [super initWithObject:object]) {
        _imagesize = (TL_documentAttributeVideo *) [object.media.document attributeWithClass:[TL_documentAttributeVideo class]];
        
        if(!_imagesize && ![object.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
            _imagesize = [TL_documentAttributeVideo createWithDuration:0 w:object.media.document.thumb.w h:object.media.document.thumb.h];
        }
        
        if(self.isset) {
            _thumbObject = [[TGThumbnailObject alloc] initWithFilepath:[self path]];
            _thumbObject.imageSize = NSMakeSize(_imagesize.w, _imagesize.h);
        } else {
            if(![object.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
                _thumbObject = [[TGBlurImageObject alloc] initWithLocation:object.media.document.thumb.location thumbData:object.media.document.thumb.bytes size:object.media.document.thumb.size];
                _thumbObject.imageSize = NSMakeSize(_imagesize.w, _imagesize.h);
            }
        }
        
        
        
        [self checkStartDownload:0 size:[self size]];
        
    }
    
    return self;
}

-(void)doAfterDownload {
    [super doAfterDownload];
    
    _thumbObject = [[TGThumbnailObject alloc] initWithFilepath:[self path]];
    _thumbObject.imageSize = NSMakeSize(_imagesize.w, _imagesize.h);

}

-(Class)downloadClass {
    return [DownloadDocumentItem class];
}

-(DownloadItem *)downloadItem {
    
    if(super.downloadItem == nil) {
        [super setDownloadItem:[DownloadQueue find:self.message.media.document.n_id]];
    }
    
    return [super downloadItem];
}

-(int)size {
    return self.message.media.document.size;
}

-(BOOL)makeSizeByWidth:(int)width {
    [super makeSizeByWidth:width];
    
    self.blockSize = strongsize(NSMakeSize(_imagesize.w, _imagesize.h), width - 60);
    
    return YES;
}


- (void)checkStartDownload:(SettingsMask)setting size:(int)size {
    
    if((size <= 10*1024*1024 && !self.downloadItem && !self.isset) || (self.downloadItem && self.downloadItem.downloadState != DownloadStateCanceled)) {
        [self startDownload:NO force:YES];
    }
    
}

- (BOOL)isset {
    return isPathExists([self path]) && [FileUtils checkNormalizedSize:[self path] checksize:[self size]];
}

-(NSString *)path {
    return mediaFilePath(self.message);
}

@end
