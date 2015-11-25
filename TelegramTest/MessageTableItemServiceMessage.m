//
//  MessageTableItemServiceMessage.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/1/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemServiceMessage.h"
#import "MessagesUtils.h"
#import "NS(Attributed)String+Geometrics.h"
#import "ImageUtils.h"
#import "TGDateUtils.h"
#import "NSAttributedString+Hyperlink.h"
#import "TGImageObject.h"
#import "TMImageUtils.h"


@interface TGImageGroupPhotoObject : TGImageObject

@end

@implementation TGImageGroupPhotoObject


-(void)_didDownloadImage:(DownloadItem *)item {
    __block NSImage *imageOrigin = [[NSImage alloc] initWithData:item.result];
    
    NSImage *image = renderedImage(imageOrigin, imageOrigin.size.width == 0 || imageOrigin.size.height ? self.imageSize : imageOrigin.size);
    
    [TGCache cacheImage:image forKey:self.location.cacheKey groups:@[IMGCACHE]];
    
    image = [TMImageUtils roundedImageNew:image size:self.imageSize];
    
    [TGCache cacheImage:image forKey:[self cacheKey] groups:@[IMGCACHE]];
    
    [ASQueue dispatchOnMainQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}

-(NSString *)cacheKey {
    return [NSString stringWithFormat:@"group:%lu:%@",self.location.hashCacheKey,NSStringFromSize(self.imageSize)];
}

@end


@implementation MessageTableItemServiceMessage

- (id) initWithDate:(int)date {
    self = [super initWithObject:nil];
    if(self) {
        self.type = MessageTableItemServiceMessageDate;

        self.viewSize = NSMakeSize(0, 10);
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName: TGSystemFont(13),
                                     NSForegroundColorAttributeName: NSColorFromRGB(0xbbbbbb)
                                     };
        
        
        
        self.messageAttributedString = [[NSMutableAttributedString alloc] initWithString:[TGDateUtils stringForDayOfMonthFull:date dayOfMonth:NULL] attributes:attributes];
        
        NSSize size = [self.messageAttributedString sizeForTextFieldForWidth:400];
        size.width += 10;
        
        self.blockSize = size;
        size.height += 16;
        self.viewSize = size;
    }
    return self;
}

- (id)initWithObject:(TL_localMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        self.messageAttributedString = [[MessagesUtils serviceAttributedMessage:object forAction:object.action] mutableCopy];
        
        
        self.type = MessageTableItemServiceMessageAction;
        
        if([object.action isKindOfClass:[TL_messageActionBotDescription class]]) {
            self.type = MessagetableitemServiceMessageDescription;
        } else {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            paragraphStyle.alignment = NSCenterTextAlignment;
            
            [((NSMutableAttributedString *)self.messageAttributedString) addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:self.messageAttributedString.range];
        }
        
      
        
        
        if(object.action.photo) {
            self.photo = object.action.photo;
            self.photoSize = NSMakeSize(100, 100);
            
            if(self.photo.sizes.count) {
                //Find cacheImage;
                for(TLPhotoSize *photoSize in self.photo.sizes) {
                    if([photoSize isKindOfClass:[TL_photoCachedSize class]]) {
                        self.cachePhoto = [[NSImage alloc] initWithData:photoSize.bytes];
                        break;
                    }
                }
                
                TLPhotoSize *photoSize = ((TLPhotoSize *)[self.photo.sizes objectAtIndex:MIN(2, self.photo.sizes.count) - 1]);
                self.photoLocation = photoSize.location;
            }
            
            self.imageObject = [[TGImageGroupPhotoObject alloc] initWithLocation:self.photoLocation placeHolder:self.cachePhoto];
            
            self.imageObject.imageSize = self.photoSize;
        }
        if([self.message.action isKindOfClass:[TL_messageActionBotDescription class]])
            [self.messageAttributedString detectAndAddLinks:URLFindTypeAll];
    }
    return self;
}

-(BOOL)makeSizeByWidth:(int)width {
    [super makeSizeByWidth:width];
    
    
    NSSize size = [self.messageAttributedString coreTextSizeForTextFieldForWidth:width];
    
    _textSize = size;
    
    size.width = width;
    size.height += 10;
    size.height += self.photoSize.height ? self.photoSize.height  : 0;
    self.blockSize = size;
    
    return YES;
}


@end
