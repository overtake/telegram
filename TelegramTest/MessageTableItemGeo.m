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
        
        TLGeoPoint *geoPoint = [object.media isKindOfClass:[TL_messageMediaBotResult class]]  ? object.media.bot_result.send_message.geo : object.media.geo;
        
        NSString *title = [object.media isKindOfClass:[TL_messageMediaBotResult class]] ? object.media.bot_result.send_message.title : object.media.title;
        NSString *address = [object.media isKindOfClass:[TL_messageMediaBotResult class]] ? object.media.bot_result.send_message.address : object.media.address;
        
        
        _imageObject = [[TGExternalImageObject alloc] initWithURL:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=15&size=%@&sensor=true", geoPoint.lat,  geoPoint.n_long, self.isVenue ? ([NSScreen mainScreen].backingScaleFactor == 2 ? @"120x120" : @"60x60") : ([NSScreen mainScreen].backingScaleFactor == 2 ? @"500x260" : @"250x130")]];
        _imageObject.imageSize = self.isVenue ? NSMakeSize(60, 60) : NSMakeSize(250, 130);
        _imageObject.placeholder = gray_resizable_placeholder();
        
       if(self.isVenue) {
            NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] init];
            
            [attrs appendString:[NSString stringWithFormat:@"%@\n",title] withColor:[NSColor blackColor]];
            
            [attrs setFont:TGSystemMediumFont(13) forRange:attrs.range];
            
            
            NSRange range = [attrs appendString:address withColor:GRAY_TEXT_COLOR];
            
            [attrs setFont:TGSystemFont(13) forRange:range];
            
            _venue = attrs;
           
           NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
           style.lineBreakMode = NSLineBreakByTruncatingMiddle;
           
           [attrs addAttribute:NSParagraphStyleAttributeName value:style range:attrs.range];
        }
        
    }
    return self;
}

-(BOOL)isVenue {
    return  [self.message.media isKindOfClass:[TL_messageMediaVenue class]] || [self.message.media.bot_result.send_message isKindOfClass:[TL_botInlineMessageMediaVenue class]];
}

-(BOOL)makeSizeByWidth:(int)width {
    
   NSSize size = NSMakeSize(width, self.isVenue ? 60 : 130);
    
    self.blockSize = size;
    self.venueSize = [_venue coreTextSizeForTextFieldForWidth:width - 60 - self.defaultOffset];
    
    NSSize imageSize = NSMakeSize(MIN(width,self.isVenue ? 60 : 250), self.isVenue ? 60 : 130);
        
    self.contentSize = imageSize;
    
    return [super makeSizeByWidth:width];
}

-(Class)viewClass {
    return [MessageTableCellGeoView class];
}

@end
