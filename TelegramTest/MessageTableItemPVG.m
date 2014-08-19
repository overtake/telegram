//
//  MessageTableItemPVG.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/3/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemPVG.h"
#import "ImageUtils.h"

@interface MessageTableItemPVG()
@end

@implementation MessageTableItemPVG

- (id) initWithObject:(TGMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        
        if([object.media isKindOfClass:[TL_messageMediaPhoto class]]) {
            [self generatePhoto:object];
        } else if([object.media isKindOfClass:[TL_messageMediaVideo class]]) {
            [self generateVideo:object];
        }
        
       
    }
    return self;
}

- (void) generateVideo:(TGMessage *)item {
    NSSize videoThumbSize = NSZeroSize;
    
    TGVideo *video = item.media.video;
    TGPhotoSize *photoSize = video.thumb;
    if([photoSize isKindOfClass:[TL_photoCachedSize class]]) {
        self.cacheImage = [[NSImage alloc] initWithData:photoSize.bytes];
    }
    
    self.fileLocation = photoSize.location;
    self.fileSize = photoSize.size;
    videoThumbSize = NSMakeSize(photoSize.w * 2, photoSize.h * 2);
    self.blockSize = videoThumbSize;
    
    self.viewSize = NSMakeSize(MAX(videoThumbSize.width, 50), MAX(videoThumbSize.height + 10, 30));
}

- (void) generatePhoto:(TGMessage *)item {
    
    NSSize imageSize = NSZeroSize;
    TGPhoto *photo = item.media.photo;
    
    if(photo.sizes.count) {
        //Find cacheImage;
        for(TGPhotoSize *photoSize in photo.sizes) {
            if([photoSize isKindOfClass:[TL_photoCachedSize class]]) {
                self.cacheImage = [[NSImage alloc] initWithData:photoSize.bytes];
                break;
            }
        }
        
        TGPhotoSize *photoSize = ((TGPhotoSize *)[photo.sizes objectAtIndex:MIN(2, photo.sizes.count) - 1]);
        self.fileLocation = photoSize.location;
        self.fileSize = photoSize.size;

        imageSize = strongsizeWithMinMax(NSMakeSize(photoSize.w, photoSize.h), 40, 250);
    }
    
    self.blockSize = imageSize;
    self.viewSize = NSMakeSize(MAX(imageSize.width, 50), MAX(imageSize.height + 10, 30));
}

@end
