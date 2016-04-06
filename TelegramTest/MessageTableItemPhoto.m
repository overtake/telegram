//
//  MessageTableItemPhoto.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemPhoto.h"
#import "ImageUtils.h"
#import "NSString+Extended.h"
#import "NSAttributedString+Hyperlink.h"
#import "TGExternalImageObject.h"
#import "MessageTableCellPhotoView.h"
@implementation MessageTableItemPhoto

- (id) initWithObject:(TL_localMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        
        [self doAfterDownload];
        
    }
    return self;
}

-(TLPhoto *)photo {
    if(self.message.media.photo != nil)
        return self.message.media.photo;
    else
        return self.message.media.bot_result.photo;
}

-(void)setMessageSender:(SenderItem *)messageSender {
    [super setMessageSender:messageSender];
}

-(BOOL)canShare {
    return [TGCache cachedImage:self.imageObject.cacheKey] != nil;
}


-(BOOL)isset {
    
    TLPhotoSize *photoSize = ((TLPhotoSize *)[self.message.media.photo.sizes lastObject]);
    
    return [TGCache cachedImage:self.imageObject.cacheKey] || ((fileSize(photoSize.location.path) >= photoSize.size || (self.imageObject.size == 0 && isPathExists(photoSize.location.path))) && self.messageSender == nil && self.downloadItem == nil);
}

-(DownloadItem *)downloadItem {
    return nil;
}


-(BOOL)makeSizeByWidth:(int)width {
    self.contentSize = strongsize(self.imageObject.realSize, MIN(MIN_IMG_SIZE.width,width));
        
    self.blockSize = NSMakeSize(self.contentSize.width, self.contentSize.height);
    
    return [super makeSizeByWidth:width];
}

-(BOOL)needUploader {
    return YES;
}

-(void)doAfterDownload {
    
    NSSize imageSize = NSZeroSize;
    TLPhoto *photo = self.photo;
    
    if(photo.sizes.count) {
        
        NSImage *cachePhoto;
        for(TLPhotoSize *photoSize in photo.sizes) {
            if([photoSize isKindOfClass:[TL_photoCachedSize class]]) {
                cachePhoto = [[NSImage alloc] initWithData:photoSize.bytes];
                break;
            }
        }
        
        TLPhotoSize *photoSize = ((TLPhotoSize *)[photo.sizes lastObject]);
        
        imageSize = strongsize(NSMakeSize(photoSize.w, photoSize.h), MIN_IMG_SIZE.width);
        
        imageSize.height = MAX(MIN_IMG_SIZE.height,imageSize.height);
        
        cachePhoto.size = imageSize;
        
        if(cachePhoto && imageSize.width == MIN_IMG_SIZE.width && imageSize.height == MIN_IMG_SIZE.height && photoSize.w > MIN_IMG_SIZE.width && photoSize.h > MIN_IMG_SIZE.height) {
            
            cachePhoto = [ImageUtils imageResize:cachePhoto newSize:NSMakeSize(photoSize.w, photoSize.h)];
            
            cachePhoto = cropImage(cachePhoto, imageSize,NSMakePoint((photoSize.w - imageSize.width)/2, 0));
            
        }
        
        if(!cachePhoto) {
            cachePhoto = white_background_color();
        }
        
        self.imageObject = [[TGImageObject alloc] initWithLocation:photoSize.location placeHolder:cachePhoto sourceId:self.message.n_id size:photoSize.size];
        
        if(self.isSecretPhoto) {
            self.imageObject.imageProcessor = [ImageUtils b_processor];
        }
        
        self.imageObject.thumbProcessor = [ImageUtils b_processor];
        
        self.imageObject.realSize = NSMakeSize(photoSize.w, photoSize.h);
        
    } else {
        self.imageObject = [[TGExternalImageObject alloc] initWithURL:self.message.media.bot_result.content_url];
        self.imageObject.imageProcessor = [ImageUtils b_processor];
        self.imageObject.realSize = NSMakeSize(self.message.media.bot_result.w, self.message.media.bot_result.h);
        
        imageSize = strongsize(self.imageObject.realSize, MIN_IMG_SIZE.width);
        imageSize.height = MAX(MIN_IMG_SIZE.height,imageSize.height);
    }
    

    
    self.imageObject.imageSize = imageSize;
    
}

-(BOOL)isSecretPhoto {
    return ([self.message isKindOfClass:[TL_destructMessage class]] && ((TL_destructMessage *)self.message).ttl_seconds < 60 && ((TL_destructMessage *)self.message).ttl_seconds > 0);
}


-(Class)viewClass {
    return [MessageTableCellPhotoView class];
}

@end
