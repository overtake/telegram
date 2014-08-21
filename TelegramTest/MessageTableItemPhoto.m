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

- (id) initWithObject:(TGMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        NSSize imageSize = NSZeroSize;
        TGPhoto *photo = object.media.photo;
        
        NSImage *cachePhoto;
        
        if(photo.sizes.count) {
            //Find cacheImage;
            for(TGPhotoSize *photoSize in photo.sizes) {
                if([photoSize isKindOfClass:[TL_photoCachedSize class]]) {
                    cachePhoto = [[NSImage alloc] initWithData:photoSize.bytes];
                    break;
                }
            }
            
            TGPhotoSize *photoSize = ((TGPhotoSize *)[photo.sizes lastObject]);
            
            self.photoLocation = photoSize.location;
            self.photoSize = photoSize.size;
            
            imageSize = strongsizeWithMinMax(NSMakeSize(photoSize.w, photoSize.h), MIN_IMG_SIZE.height, MIN_IMG_SIZE.width);
            
            
            if(cachePhoto && imageSize.width == MIN_IMG_SIZE.width && imageSize.height == MIN_IMG_SIZE.height && photoSize.w > MIN_IMG_SIZE.width && photoSize.h > MIN_IMG_SIZE.height) {
                
                cachePhoto = [ImageUtils imageResize:cachePhoto newSize:NSMakeSize(photoSize.w, photoSize.h)];
                
                cachePhoto = cropImage(cachePhoto, imageSize,NSMakePoint((photoSize.w - imageSize.width)/2, 0));
                
            }
            
            self.imageObject = [[TGImageObject alloc] initWithLocation:self.photoLocation placeHolder:cachePhoto sourceId:object.peer.peer_id size:self.photoSize];
            
            
            
            self.imageObject.realSize = NSMakeSize(photoSize.w, photoSize.h);
            
           
            
            
        }
        
       
        self.imageObject.imageSize = imageSize;
        self.blockSize = imageSize;
        self.previewSize = imageSize;
    }
    return self;
}

-(void)setMessageSender:(SenderItem *)messageSender {
    [super setMessageSender:messageSender];
}


-(void)doAfterDownload {
    
}

-(BOOL)needUploader {
    return YES;
}

@end
