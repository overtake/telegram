//
//  MessageTableItemPhoto.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemPhoto.h"
#import "ImageUtils.h"

@implementation MessageTableItemPhoto

- (id) initWithObject:(TL_localMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        NSSize imageSize = NSZeroSize;
        TLPhoto *photo = object.media.photo;
        
        NSImage *cachePhoto;
        
        if(photo.sizes.count) {
            //Find cacheImage;
            for(TLPhotoSize *photoSize in photo.sizes) {
                if([photoSize isKindOfClass:[TL_photoCachedSize class]]) {
                    cachePhoto = [[NSImage alloc] initWithData:photoSize.bytes];
                    break;
                }
            }
            
            TLPhotoSize *photoSize = ((TLPhotoSize *)[photo.sizes lastObject]);
            
            self.photoLocation = photoSize.location;
            self.photoSize = photoSize.size;
            
            
            imageSize = strongsize(NSMakeSize(photoSize.w, photoSize.h), MIN_IMG_SIZE.width);
            
          //  imageSize.width = MAX(MIN_IMG_SIZE.width,imageSize.width);
            imageSize.height = MAX(MIN_IMG_SIZE.height,imageSize.height);
            
            cachePhoto.size = imageSize;
            
            
            if(cachePhoto && imageSize.width == MIN_IMG_SIZE.width && imageSize.height == MIN_IMG_SIZE.height && photoSize.w > MIN_IMG_SIZE.width && photoSize.h > MIN_IMG_SIZE.height) {
                
                cachePhoto = [ImageUtils imageResize:cachePhoto newSize:NSMakeSize(photoSize.w, photoSize.h)];
                
                cachePhoto = cropImage(cachePhoto, imageSize,NSMakePoint((photoSize.w - imageSize.width)/2, 0));
                
            }
            
            cachePhoto = [ImageUtils blurImage:renderedImage(cachePhoto, cachePhoto.size) blurRadius:80 frameSize:cachePhoto.size] ;
            
            
            self.imageObject = [[TGImageObject alloc] initWithLocation:self.photoLocation placeHolder:cachePhoto sourceId:self.message.n_id size:self.photoSize];
            
            self.imageObject.imageSize = imageSize;
            
            self.imageObject.realSize = NSMakeSize(photoSize.w, photoSize.h);
            
        }
                
       
        self.imageObject.imageSize = imageSize;
        self.blockSize = NSMakeSize(imageSize.width, MAX(imageSize.height, 60));
        self.previewSize = imageSize;
    }
    return self;
}

-(void)setMessageSender:(SenderItem *)messageSender {
    [super setMessageSender:messageSender];
}

-(BOOL)canShare {
    return [TGCache cachedImage:self.imageObject.cacheKey] != nil;
}


-(BOOL)isset {
    return isPathExists(((TLPhotoSize *)[self.message.media.photo.sizes lastObject]).location.path) && self.downloadItem == nil && self.messageSender == nil;
}

-(void)doAfterDownload {
    
}

-(BOOL)needUploader {
    return YES;
}

@end
