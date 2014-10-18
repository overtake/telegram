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
#import "TGPeer+Extensions.h"
#import "NSAttributedString+Hyperlink.h"
#import "ImageCache.h"
#import "ImageUtils.h"

#import "MessageTableCellDocumentView.h"
#import "NSString+Extended.h"

@implementation MessageTableItemDocument

- (BOOL)isHasThumb {
    return self.message.media.document.thumb && ![self.message.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]];
}

- (id)initWithObject:(TGMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        self.fileName = self.message.media.document.file_name;
        if(!self.fileName)
            self.fileName = @"undefined.file";
        
        
        self.fileSize = [[NSString sizeToTransformedValuePretty:self.message.media.document.size] trim];
        
        if([self isHasThumb]) {
            
            self.thumbSize = NSMakeSize(100, 100);
            if(self.message.media.document.thumb.bytes) {
                self.cachedThumb = [[NSImage alloc] initWithData:self.message.media.document.thumb.bytes];
              //  if([self isset])
                  //  [self doAfterDownload];
            }
            
            
            
            
        } else {
            self.thumbSize = NSMakeSize(48, 48);
        }
        
        self.thumbObject = [[TGImageObject alloc] initWithLocation:self.message.media.document.thumb.location placeHolder:self.cachedThumb];
        
        self.thumbObject.imageSize = self.thumbSize;
        
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
    
    
//    __block NSString *filePath = locationFilePath(self.message.media.document.thumb.location, @"tiff");
//
//    if(self.message.media.document.thumb && ![self.message.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
//        
//        [ASQueue dispatchOnStageQueue:^{
//            
//            NSImage *image = previewImageForDocument([self path]);
//            if(image) {
//                NSData *data = [image TIFFRepresentation];
//                [data writeToURL:[NSURL fileURLWithPath:filePath] atomically:NO];
//                
//                [[ASQueue mainQueue] dispatchOnQueue:^{
//                    self.cachedThumb = nil;
//                    [[ImageCache sharedManager] setImage:image forLocation:self.message.media.document.thumb.location];
//                    
//                    if(self.cell.item == self) {
//                        [self.cell redrawThumb:image];
//                    }
//                }];
//            }
//        
//        }];
//    }
    
   
   
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