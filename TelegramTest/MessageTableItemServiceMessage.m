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

@implementation MessageTableItemServiceMessage

- (id) initWithDate:(int)date {
    self = [super initWithObject:nil];
    if(self) {
        self.type = MessageTableItemServiceMessageDate;

        self.viewSize = NSMakeSize(0, 10);
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue" size:13],
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

- (id)initWithObject:(TLMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        self.messageAttributedString = [MessagesUtils serviceAttributedMessage:object forAction:object.action];
        self.type = MessageTableItemServiceMessageAction;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSCenterTextAlignment;
        
        [((NSMutableAttributedString *)self.messageAttributedString) addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:self.messageAttributedString.range];
        
        
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
                self.photoSize = strongsizeWithMinMax(NSMakeSize(photoSize.w, photoSize.h), 40, 250);
            }
            
            self.imageObject = [[TGImageObject alloc] initWithLocation:self.photoLocation placeHolder:self.cachePhoto];
            
            self.imageObject.imageSize = self.photoSize;
        }
        
        NSSize size = [self.messageAttributedString sizeForTextFieldForWidth:400];
        
        self.blockSize = size;
        size.height += 16;
        size.height += self.photoSize.height ? self.photoSize.height + 10 : 0;
        self.viewSize = size;
    }
    return self;
}


@end
