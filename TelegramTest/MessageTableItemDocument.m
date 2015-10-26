//
//  MessageTableItemDocument.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/4/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemDocument.h"
#import "NS(Attributed)String+Geometrics.h"
#import "TMAttributedString.h"
#import "FileUtils.h"
#import "Telegram.h"
#import "TLPeer+Extensions.h"
#import "NSAttributedString+Hyperlink.h"
#import "ImageCache.h"
#import "ImageUtils.h"

#import "MessageTableCellDocumentView.h"
#import "NSString+Extended.h"

@implementation MessageTableItemDocument

- (BOOL)isHasThumb {
    return self.message.media.document.thumb && ![self.message.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]];
}

- (id)initWithObject:(TLMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        self.fileName = self.message.media.document.file_name;
        if(!self.fileName)
            self.fileName = @"undefined.file";
        
        
        self.fileSize = [[NSString sizeToTransformedValuePretty:self.message.media.document.size] trim];
        
        NSSize size;
        
        if([self isHasThumb]) {
            
            size = strongsizeWithMinMax(NSMakeSize(self.message.media.document.thumb.w, self.message.media.document.thumb.h), 70, 70);
            
           if(self.message.media.document.thumb.bytes) {
                NSImage *thumb = [[NSImage alloc] initWithData:self.message.media.document.thumb.bytes];
                thumb = renderedImage(thumb, size);
                [TGCache cacheImage:thumb forKey:self.message.media.document.thumb.location.cacheKey groups:@[IMGCACHE]];
            }
            
            self.thumbSize = NSMakeSize(70, 70);
            
        } else {
            self.thumbSize = NSMakeSize(48, 48);
        }
        
        self.thumbObject = [[TGImageObject alloc] initWithLocation:self.message.media.document.thumb.location placeHolder:self.cachedThumb];
        
        self.thumbObject.imageSize = size;
        
        self.blockSize = NSMakeSize(200, self.thumbSize.height + 6);
        self.previewSize = self.thumbSize;
    
        if(self.isset) {
            self.state = DocumentStateDownloaded;
        } else {
            self.state = DocumentStateWaitingDownload;
        }
        
          [self checkStartDownload:[self.message.to_id isKindOfClass:[TL_peerChat class]] ? AutoGroupDocuments : AutoPrivateDocuments size:self.message.media.document.size];
        
    }
    return self;
}

-(NSString *)fileName {
    return _fileName.length > 0 ? _fileName : @"File";
}

-(BOOL)canShare {
    return [self isset];
}



- (int)size {
    return self.message.media.document.size;
}

- (Class)downloadClass {
    return [DownloadDocumentItem class];
}

- (NSString *)path {
    if([self.message.media.document isKindOfClass:[TL_outDocument class]])
        return ((TL_outDocument *)self.message.media.document).file_path;
    else
        return mediaFilePath(self.message.media);
}

- (void)doAfterDownload {
    [super doAfterDownload];
    
    self.state = DocumentStateDownloaded;
}

-(DownloadItem *)downloadItem {
    return [DownloadQueue find:self.message.media.document.n_id];
}

- (BOOL)canDownload {
    return self.message.media.document.dc_id != 0;
}

- (BOOL)isset {
    return isPathExists([self path]) && [FileUtils checkNormalizedSize:[self path] checksize:[self size]];
}

- (BOOL)needUploader {
    return YES;
}

@end