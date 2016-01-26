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
            
            if(cachePhoto) {
                cachePhoto = [ImageUtils blurImage:renderedImage(cachePhoto, cachePhoto.size) blurRadius:80 frameSize:cachePhoto.size] ;
            }
            
            
            self.imageObject = [[TGImageObject alloc] initWithLocation:self.photoLocation placeHolder:cachePhoto sourceId:self.message.n_id size:self.photoSize];
            
            self.imageObject.imageSize = imageSize;
            
            self.imageObject.realSize = NSMakeSize(photoSize.w, photoSize.h);
            
            if(self.message.media.caption.length > 0) {
                NSMutableAttributedString *c = [[NSMutableAttributedString alloc] init];
                
                [c appendString:[[self.message.media.caption trim] fixEmoji] withColor:TEXT_COLOR];
                
                [c setFont:TGSystemFont(13) forRange:c.range];
                
                [c detectAndAddLinks:URLFindTypeHashtags | URLFindTypeLinks | URLFindTypeMentions | (self.user.isBot || self.message.peer.isChat ? URLFindTypeBotCommands : 0)];
                
                _caption = c;
            }
            
        }
                
        self.imageObject.imageSize = imageSize;
        
        self.previewSize = imageSize;
        
        [self makeSizeByWidth:310];
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
    
    TLPhotoSize *photoSize = ((TLPhotoSize *)[self.message.media.photo.sizes lastObject]);
    
    return (fileSize(photoSize.location.path) >= photoSize.size || (self.imageObject.size == 0 && isPathExists(photoSize.location.path))) && self.messageSender == nil && self.downloadItem == nil;
}

-(void)doAfterDownload {
    
}

-(BOOL)makeSizeByWidth:(int)width {
    [super makeSizeByWidth:width];
    
    
    TLPhotoSize *photoSize = ((TLPhotoSize *)[self.message.media.photo.sizes lastObject]);
    
    _imageSize = strongsize(NSMakeSize(photoSize.w, photoSize.h), MIN(MIN_IMG_SIZE.width,width - 40));
        
    if(_caption) {
        _captionSize = [_caption coreTextSizeForTextFieldForWidth:_imageSize.width ];
        _captionSize.width = _imageSize.width ;
    }
    
    int captionHeight = _captionSize.height ? _captionSize.height + 5 : 0;
    
    self.blockSize = NSMakeSize(_imageSize.width, MAX(_imageSize.height + captionHeight,30 + captionHeight));
    
    return YES;
}

-(BOOL)needUploader {
    return YES;
}




@end
