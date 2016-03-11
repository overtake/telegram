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

- (id)initWithObject:(TL_localMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        
        _fileSize = [[NSString sizeToTransformedValuePretty:self.message.media.document.size] trim];
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:self.message.media.document.file_name withColor:TEXT_COLOR];
        
        [attr setFont:TGSystemMediumFont(13) forRange:attr.range];
        
        [attr appendString:@"\n"];
        NSRange range = [attr appendString:_fileSize withColor:GRAY_TEXT_COLOR];
        
        [attr setFont:TGSystemFont(13) forRange:range];
        
        if(![self isHasThumb]) {
            range = [attr appendString:@" - " withColor:GRAY_TEXT_COLOR];
            [attr setFont:TGSystemFont(13) forRange:range];
            range = [attr appendString:NSLocalizedString(@"Message.File.ShowInFinder", nil) withColor:LINK_COLOR];
            [attr setFont:TGSystemFont(13) forRange:range];
            [attr setLink:@"chat://finder" forRange:range];
        }
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByTruncatingMiddle;
        style.lineSpacing = 2;
        
        [attr addAttribute:NSParagraphStyleAttributeName value:style range:attr.range];
        
        _fileNameAttrubutedString = attr;
        
        _fileNameSize = [attr coreTextSizeForTextFieldForWidth:INT32_MAX];
        
        NSSize size;
        
        if([self isHasThumb]) {
            
            if(![TGCache cachedImage:self.message.media.document.thumb.location.cacheKey]) {
                size = strongsizeWithMinMax(NSMakeSize(self.message.media.document.thumb.w, self.message.media.document.thumb.h), 70, 70);
                
                if(self.message.media.document.thumb.bytes) {
                    NSImage *thumb = [[NSImage alloc] initWithData:self.message.media.document.thumb.bytes];
                    thumb = renderedImage(thumb, size);
                    [TGCache cacheImage:thumb forKey:self.message.media.document.thumb.location.cacheKey groups:@[IMGCACHE]];
                }
            }
            
            self.thumbSize = NSMakeSize(70, 70);
            
        } else {
            self.thumbSize = NSMakeSize(40, 40);
        }
        
        self.thumbObject = [[TGImageObject alloc] initWithLocation:self.message.media.document.thumb.location placeHolder:nil];
        
        self.thumbObject.imageSize = size;
        
        self.blockSize = NSMakeSize(200, self.thumbSize.height + 6);
        [self checkStartDownload:[self.message.to_id isKindOfClass:[TL_peerChat class]] ? AutoGroupDocuments : AutoPrivateDocuments size:self.message.media.document.size];
        
    }
    return self;
}

-(BOOL)makeSizeByWidth:(int)width {
    [super makeSizeByWidth:width];
    
    self.blockSize = NSMakeSize(width, self.thumbSize.height);
    
    return YES;
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
        return mediaFilePath(self.message);
}

- (void)doAfterDownload {
    [super doAfterDownload];
    
}

-(DownloadItem *)downloadItem {
    
    if(super.downloadItem == nil)
        [super setDownloadItem:[DownloadQueue find:self.message.media.document.n_id]];
    
    return [super downloadItem];
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

-(Class)viewClass {
    return [MessageTableCellDocumentView class];
}

@end