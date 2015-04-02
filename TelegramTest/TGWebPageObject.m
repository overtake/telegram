//
//  TGWebPageObject.m
//  Telegram
//
//  Created by keepcoder on 01.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageObject.h"

@implementation TGWebpageObject

-(id)initWithWebPage:(TLWebPage *)webpage {
    if(self = [super init]) {
        
        _webpage = webpage;
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
        
        
        [title appendString:webpage.title withColor:[NSColor blackColor]];
        [title setFont:[NSFont fontWithName:@"HelveticaNeue" size:12] forRange:title.range];
        
        _title = title;
                
    
               
        if(webpage.n_description.length > 0) {
            _toolTip = [NSString stringWithFormat:@"%@",webpage.n_description];
        }
        
        
        
        if(![webpage.photo isKindOfClass:[TL_photoEmpty class]]) {
            NSArray *photo = [webpage.photo sizes];
            
            TLPhotoSize *photoSize = [photo lastObject];
            
            __block NSImage *thumb;
            
            [photo enumerateObjectsUsingBlock:^(TLPhotoSize *obj, NSUInteger idx, BOOL *stop) {
                
                if([obj isKindOfClass:[TL_photoCachedSize class]]) {
                    thumb = [[NSImage alloc] initWithData:obj.bytes];
                    *stop = YES;
                }
                
            }];
            
            
            _imageObject = [[TGImageObject alloc] initWithLocation:photoSize.location placeHolder:thumb sourceId:0 size:photoSize.size];
            
            
            NSSize imageSize = strongsize(NSMakeSize(photoSize.w, photoSize.h), 320);
            
            
            _imageObject.imageSize = imageSize;
        }
        
        
    }
    
    return self;
}



-(void)makeSize:(int)width {
    
    _imageSize = strongsize(_imageObject.imageSize, width - 67);
    
    _size = _imageSize;
    
}

-(Class)webpageContainer {
    return NSClassFromString(@"TGWebpageContainer");
}

@end
