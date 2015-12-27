//
//  TGWebpageGifObject.m
//  Telegram
//
//  Created by keepcoder on 20.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageGifObject.h"
#import "DownloadCacheDocumentItem.h"
#import "TGVTVideoView.h"
#import "TGBlurImageObject.h"
#import "TGThumbnailObject.h"
@interface TGWebpageGifObject ()
@property (nonatomic,strong) TL_documentAttributeVideo *imagesize;
@end

@implementation TGWebpageGifObject

@synthesize size = _size;
@synthesize imageObject = _imageObject;
@synthesize imageSize = _imageSize;
-(id)initWithWebPage:(TLWebPage *)webpage {
    if(self = [super initWithWebPage:webpage]) {
        
        
        _imagesize = (TL_documentAttributeVideo *) [webpage.document attributeWithClass:[TL_documentAttributeVideo class]];

        
        
        if(self.isset) {
            _imageObject = [[TGThumbnailObject alloc] initWithFilepath:[self path]];
            _imageObject.imageSize = NSMakeSize(self.imagesize.w, self.imagesize.h);
        } else {
            if(![webpage.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
                _imageObject = [[TGBlurImageObject alloc] initWithLocation:webpage.document.thumb.location thumbData:webpage.document.thumb.bytes size:webpage.document.thumb.size];
                _imageObject.imageSize = NSMakeSize(self.imagesize.w, self.imagesize.h);
            }
        }
        
    }
    
    return self;
}


-(TL_documentAttributeVideo *)imagesize {
    
    __block TL_documentAttributeVideo *imageSize = _imagesize;
    
    if(imageSize == nil) {
        
        dispatch_block_t thumbblock = ^{
            if(![self.webpage.document.thumb isKindOfClass:[TL_photoSizeEmpty class]])  {
                imageSize = [TL_documentAttributeVideo createWithDuration:0 w:self.webpage.document.thumb.w * 3 h:self.webpage.document.thumb.h * 3];
            } else {
                imageSize = [TL_documentAttributeVideo createWithDuration:0 w:300 h:300];
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

- (void)startDownload:(BOOL)cancel force:(BOOL)force {
    
    if(!_downloadItem) {
        _downloadItem = [[DownloadCacheDocumentItem alloc] initWithObject:self.webpage.document];
        _downloadListener = [[DownloadEventListener alloc] init];
        
        [_downloadItem addEvent:_downloadListener];

    }
    
    if((self.downloadItem.downloadState == DownloadStateCanceled || self.downloadItem.downloadState == DownloadStateWaitingStart) && force)
        [self.downloadItem start];
    
}

-(void)makeSize:(int)width {
    [super makeSize:width];
    
    _imageSize = strongsize(NSMakeSize(self.imagesize.w, self.imagesize.h), MIN(320, width - 67));
    
    _size = _imageSize;
    _size.width+=20;
    
}

- (BOOL)isset {
    return isPathExists([self path]) && [FileUtils checkNormalizedSize:[self path] checksize:self.webpage.document.size];
}

-(NSString *)path {
    return self.webpage.document.path_with_cache;
}

-(void)doAfterDownload {
    [super doAfterDownload];
    
    _imageObject = [[TGThumbnailObject alloc] initWithFilepath:[self path]];
    _imageObject.imageSize = NSMakeSize(self.imagesize.w, self.imagesize.h);
    
}


-(Class)webpageContainer {
    return NSClassFromString(@"TGWebpageGifContainer");
}

@end
