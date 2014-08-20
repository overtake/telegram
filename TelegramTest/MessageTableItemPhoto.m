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
        
        if(photo.sizes.count) {
            //Find cacheImage;
            for(TGPhotoSize *photoSize in photo.sizes) {
                if([photoSize isKindOfClass:[TL_photoCachedSize class]]) {
                    self.cachePhoto = [[NSImage alloc] initWithData:photoSize.bytes];
                    break;
                }
            }
            
            TGPhotoSize *photoSize = ((TGPhotoSize *)[photo.sizes lastObject]);
            
            self.photoLocation = photoSize.location;
            self.photoSize = photoSize.size;
            
            self.imageObject = [[TGImageObject alloc] initWithLocation:self.photoLocation placeHolder:self.cachePhoto sourceId:object.peer.peer_id size:self.photoSize];
            
           
            
            imageSize = strongsizeWithMinMax(NSMakeSize(photoSize.w, photoSize.h), MIN_IMG_SIZE.height, MIN_IMG_SIZE.width);
            
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
    
    self.imageObject.isLoaded = YES;
}


-(void)doAfterDownload {
    
}

-(BOOL)needUploader {
    return YES;
}

@end
