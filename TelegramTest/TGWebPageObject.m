//
//  TGWebPageObject.m
//  Telegram
//
//  Created by keepcoder on 01.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageObject.h"
#import "TGDateUtils.h"
#import "TGWebpageIGObject.h"
#import "TGWebpageYTObject.h"
#import "TGWebpageTWObject.h"
#import "TGWebpageStandartObject.h"
#import "NSAttributedString+Hyperlink.h"
@implementation TGWebpageObject

-(id)initWithWebPage:(TLWebPage *)webpage {
    if(self = [super init]) {
        
        _webpage = webpage;
        
        
        _author = webpage.author;
        _date = webpage.date == 0 ? nil : [TGDateUtils stringForMessageListDate:webpage.date];
        
        if(webpage.title) {
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
            
            
            [title appendString:webpage.title withColor:[NSColor blackColor]];
            [title setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:title.range];
            
            _title = title;
        }
        
        if(webpage.n_description) {
            NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] init];
            
            [desc appendString:webpage.n_description withColor:[NSColor blackColor]];
            [desc setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:desc.range];
            
            _desc = desc;
            
            [desc detectExternalLinks];
        }
        
       
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
    
    _titleSize = [self.title coreTextSizeForTextFieldForWidth:_imageSize.width ? : width-67];
    _descSize = [self.desc coreTextSizeForTextFieldForWidth:_imageSize.width ? : width-67];
    
    _size = _imageSize;
    
    _size.height+=self.titleSize.height + self.descSize.height + (!self.author ?:17) + (((_title || _desc) && _imageObject) ? 8 : 0);
    
    
    
    _size.width = width - 60;
    
}

-(Class)webpageContainer {
    return NSClassFromString(@"TGWebpageContainer");
}

+(id)objectForWebpage:(TLWebPage *)webpage {
    if([webpage.site_name isEqualToString:@"YouTube"])
    {
        return [[TGWebpageYTObject alloc] initWithWebPage:webpage];
    }
    
    if([webpage.site_name isEqualToString:@"Instagram"])
    {
        return [[TGWebpageIGObject alloc] initWithWebPage:webpage];
    }
    
    if([webpage.site_name isEqualToString:@"Twitter"])
    {
        return [[TGWebpageTWObject alloc] initWithWebPage:webpage];
    }
    
    if([webpage.type isEqualToString:@"photo"] || [webpage.type isEqualToString:@"article"] || ([webpage.type isEqualToString:@"video"] && [webpage.embed_type isEqualToString:@"video/mp4"]))
    {
        return [[TGWebpageStandartObject alloc] initWithWebPage:webpage];
    }
    
    return nil;
}

@end
