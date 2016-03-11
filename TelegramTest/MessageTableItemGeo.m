//
//  MessageTableItemGeo.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemGeo.h"
#import "MessageTableCellGeoView.h"
@implementation MessageTableItemGeo

- (id) initWithObject:(TLMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        
        TLGeoPoint *geoPoint = object.media.geo;
        
        _imageObject = [[TGExternalImageObject alloc] initWithURL:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=15&size=%@&sensor=true", geoPoint.lat,  geoPoint.n_long, [self.message.media isKindOfClass:[TL_messageMediaVenue class]] ? ([NSScreen mainScreen].backingScaleFactor == 2 ? @"120x120" : @"60x60") : ([NSScreen mainScreen].backingScaleFactor == 2 ? @"500x260" : @"250x130")]];
        _imageObject.imageSize = [self.message.media isKindOfClass:[TL_messageMediaVenue class]] ? NSMakeSize(60, 60) : NSMakeSize(250, 130);
        _imageObject.placeholder = gray_resizable_placeholder();
        
       if([self.message.media isKindOfClass:[TL_messageMediaVenue class]]) {
            NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] init];
            
            [attrs appendString:[NSString stringWithFormat:@"%@\n",self.message.media.title] withColor:[NSColor blackColor]];
            
            [attrs setFont:TGSystemMediumFont(13) forRange:attrs.range];
            
            
            NSRange range = [attrs appendString:self.message.media.address withColor:GRAY_TEXT_COLOR];
            
            [attrs setFont:TGSystemFont(13) forRange:range];
            
            _venue = attrs;
           
           NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
           style.lineBreakMode = NSLineBreakByTruncatingMiddle;
           
           [attrs addAttribute:NSParagraphStyleAttributeName value:style range:attrs.range];
        }
        
    }
    return self;
}

-(BOOL)makeSizeByWidth:(int)width {
    
   NSSize size = NSMakeSize(width, [self.message.media isKindOfClass:[TL_messageMediaVenue class]] ? 60 : 130);
    
    self.blockSize = size;
    self.venueSize = [_venue coreTextSizeForTextFieldForWidth:width - 60 - self.defaultOffset];
    
    NSSize imageSize = NSMakeSize(MIN(width,[self.message.media isKindOfClass:[TL_messageMediaVenue class]] ? 60 : 250), [self.message.media isKindOfClass:[TL_messageMediaVenue class]] ? 60 : 130);
        
    _imageSize = imageSize;
    
    return [super makeSizeByWidth:width];
}

-(Class)viewClass {
    return [MessageTableCellGeoView class];
}

@end
