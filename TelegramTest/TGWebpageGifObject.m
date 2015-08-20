//
//  TGWebpageGifObject.m
//  Telegram
//
//  Created by keepcoder on 20.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageGifObject.h"
#import "DownloadCacheDocumentItem.h"
@interface TGWebpageGifObject ()

@end

@implementation TGWebpageGifObject

@synthesize size = _size;
@synthesize imageObject = _imageObject;
@synthesize imageSize = _imageSize;
-(id)initWithWebPage:(TLWebPage *)webpage {
    if(self = [super initWithWebPage:webpage]) {
        
        _imageObject = [[TGImageObject alloc] initWithLocation:webpage.document.thumb.location placeHolder:nil sourceId:0 size:webpage.document.thumb.size];
        _imageObject.imageSize = NSMakeSize(roundf(webpage.document.thumb.w * (320 / webpage.document.thumb.w)), roundf(webpage.document.thumb.h * (320 / webpage.document.thumb.h)));
        
        
    }
    
    return self;
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
    
    _imageSize = strongsize(_imageObject.imageSize, MIN(320, width - 67));
    
    _size = _imageSize;
    _size.width+=20;
    
}

- (BOOL)isset {
    return isPathExists([self path]) && [FileUtils checkNormalizedSize:[self path] checksize:self.webpage.document.size];
}

-(NSString *)path {
    return self.webpage.document.path_with_cache;
}


-(Class)webpageContainer {
    return NSClassFromString(@"TGWebpageGifContainer");
}

@end
