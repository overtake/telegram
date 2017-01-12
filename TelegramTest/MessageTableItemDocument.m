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
#import "ImageUtils.h"
#import "MessageTableCellDocumentView.h"
#import "NSString+Extended.h"
@implementation MessageTableItemDocument

- (BOOL)isHasThumb {
    return self.document.thumb && ![self.document.thumb isKindOfClass:[TL_photoSizeEmpty class]];
}

- (id)initWithObject:(TL_localMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        
        _fileSize = [[NSString sizeToTransformedValuePretty:self.document.size] trim];
        
        [self doAfterDownload];
        
        NSSize size = NSZeroSize;
        
        if([self isHasThumb]) {
            
            if(![TGCache cachedImage:self.document.thumb.location.cacheKey]) {
                size = strongsizeWithMinMax(NSMakeSize(self.document.thumb.w, self.document.thumb.h), 70, 70);
                
                if(self.document.thumb.bytes) {
                    NSImage *thumb = [[NSImage alloc] initWithData:self.document.thumb.bytes];
                    thumb = renderedImage(thumb, size);
                    [TGCache cacheImage:thumb forKey:self.document.thumb.location.cacheKey groups:@[IMGCACHE]];
                }
            }
            
            self.thumbSize = NSMakeSize(70, 70);
            
        } else {
            self.thumbSize = NSMakeSize(40, 40);
        }
        
        self.thumbObject = [[TGImageObject alloc] initWithLocation:self.document.thumb.location placeHolder:nil];
        
        self.thumbObject.imageSize = size;
        self.thumbObject.imageProcessor = [ImageUtils c_processor];
        self.blockSize = NSMakeSize(200, self.thumbSize.height + 6);
        [self checkStartDownload:[self.message.to_id isKindOfClass:[TL_peerChat class]] ? AutoGroupDocuments : AutoPrivateDocuments size:self.document.size];
        
    }
    return self;
}

-(TLDocument *)document {
    if([self.message.media isKindOfClass:[TL_messageMediaBotResult class]]) {
        return self.message.media.bot_result.document;
    } else
        return self.message.media.document;
}

-(BOOL)makeSizeByWidth:(int)width {
    
    _fileNameSize = [_fileNameAttrubutedString coreTextSizeForTextFieldForWidth:width - self.thumbSize.width - self.defaultOffset];
    
    self.contentSize = self.blockSize = NSMakeSize(MAX(_fileNameSize.width,170) + self.thumbSize.width + self.defaultOffset, self.thumbSize.height);
    
    return [super makeSizeByWidth:width];
}


-(BOOL)canShare {
    return [self isset];
}

- (int)size {
    return self.document.size;
}

- (Class)downloadClass {
    return [DownloadDocumentItem class];
}

- (NSString *)path {
        return mediaFilePath(self.message);
}

- (void)doAfterDownload {
    [super doAfterDownload];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:self.document.file_name withColor:TEXT_COLOR];
    
    [attr setFont:TGSystemMediumFont(13) forRange:attr.range];
    
    if(attr.length > 0)
        [attr appendString:@"\n"];
    NSRange range = [attr appendString:_fileSize withColor:GRAY_TEXT_COLOR];
    
    [attr setFont:TGSystemFont(13) forRange:range];
    
    if(![self isHasThumb] && self.isset) {
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
    _fileNameSize = [_fileNameAttrubutedString coreTextSizeForTextFieldForWidth:self.makeSize - self.thumbSize.width - self.defaultOffset];
    
}

-(DownloadItem *)downloadItem {
    
    if(super.downloadItem == nil)
        [super setDownloadItem:[DownloadQueue find:self.document.n_id]];
    
    return [super downloadItem];
}

- (BOOL)canDownload {
    return self.document.dc_id != 0;
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
