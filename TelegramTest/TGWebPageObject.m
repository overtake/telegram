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
        
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
        
        
        [title appendString:webpage.title withColor:[NSColor whiteColor]];
        [title setFont:[NSFont fontWithName:@"HelveticaNeue" size:12] forRange:title.range];
        
        _title = title;
        
        NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] init];
        
        
        NSString *d = webpage.n_description.length > 0 ? webpage.n_description : webpage.display_url;
        
        [desc appendString:d withColor:[NSColor whiteColor]];
        
        
        [desc setFont:[NSFont fontWithName:@"HelveticaNeue" size:12] forRange:desc.range];
        
        
        _toolTip = [NSString stringWithFormat:@"%@\n\n%@",webpage.title,d];
        
        
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
            
            
            NSSize imageSize = strongsize(NSMakeSize(photoSize.w, photoSize.h), 350);
            
            
            _imageObject.imageSize = imageSize;
        }
        
        
    }
    
    return self;
}



-(void)makeSize:(int)width {
    
    _size = _imageObject.imageSize;
    
}

-(Class)webpageContainer {
    return NSClassFromString(@"TGWebpageContainer");
}

@end
