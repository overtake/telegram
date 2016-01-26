//
//  MessageTableItemGeo.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemGeo.h"

@implementation MessageTableItemGeo

- (id) initWithObject:(TLMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        
        TLGeoPoint *geoPoint = object.media.geo;
        self.geoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=15&size=%@&sensor=true", geoPoint.lat,  geoPoint.n_long, [self.message.media isKindOfClass:[TL_messageMediaVenue class]] ? ([NSScreen mainScreen].backingScaleFactor == 2 ? @"120x120" : @"60x60") : ([NSScreen mainScreen].backingScaleFactor == 2 ? @"500x260" : @"250x130")]];
        
        self.blockSize = NSMakeSize(250, [self.message.media isKindOfClass:[TL_messageMediaVenue class]] ? 60 : 130);
        
        
        _imageSize = NSMakeSize([self.message.media isKindOfClass:[TL_messageMediaVenue class]] ? 60 : 250, [self.message.media isKindOfClass:[TL_messageMediaVenue class]] ? 60 : 130);
        
        if([self.message.media isKindOfClass:[TL_messageMediaVenue class]]) {
            NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] init];
            
            [attrs appendString:[NSString stringWithFormat:@"%@\n",self.message.media.title] withColor:[NSColor blackColor]];
            
            [attrs setFont:TGSystemMediumFont(13) forRange:attrs.range];
            
            
            NSRange range = [attrs appendString:self.message.media.address withColor:GRAY_TEXT_COLOR];
            
            [attrs setFont:TGSystemFont(13) forRange:range];
            
            _venue = attrs;
        }
        
    }
    return self;
}

-(BOOL)makeSizeByWidth:(int)width {
    [super makeSizeByWidth:width];
    
    if(self.isForwadedMessage) {
        width-=50;
    }
    
    NSSize size = NSMakeSize(width - ([self.message.media isKindOfClass:[TL_messageMediaVenue class]] ? 100 : 60), [self.message.media isKindOfClass:[TL_messageMediaVenue class]] ? 60 : 130);
    
    BOOL makeNew = self.blockSize.width != size.width || self.blockSize.height != size.height;
    
    self.blockSize = size;
    
    return makeNew;
}

@end
