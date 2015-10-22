//
//  TGWebpageArticle.m
//  Telegram
//
//  Created by keepcoder on 05.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageArticle.h"
#import "TGArticleImageObject.h"
@implementation TGWebpageArticle

@synthesize size = _size;
@synthesize imageSize = _imageSize;
@synthesize author = _author;
@synthesize imageObject = _imageObject;
@synthesize descSize = _descSize;

-(id)initWithWebPage:(TLWebPage *)webpage {
    
    if(self = [super initWithWebPage:webpage]) {
        
        
       
        
        if([webpage.photo isKindOfClass:[TL_photo class]]) {
            
            TLPhotoSize *size = [webpage.photo.sizes lastObject];
            
            _imageObject = [[TGArticleImageObject alloc] initWithLocation:size.location placeHolder:[super imageObject].placeholder sourceId:0 size:[super imageObject].size];
            
            _imageObject.imageSize = NSMakeSize(60, 60);
        }
        
    }
    
    return self;
}

-(Class)webpageContainer {
    return NSClassFromString(@"TGWebpageArticleContainer");
}

-(void)makeSize:(int)width {
    
    [super makeSize:width];
    
    _size = [super size];

   // if(self.imageObject) {
        
        _imageSize = strongsize(self.imageObject.imageSize,60);
    
        _descSize = [self.desc coreTextSizeForTextFieldForWidth: width-67];
    
//        _size.height = [self.desc coreTextSizeForTextFieldForWidth:width - 67 withPaths:@[[NSValue valueWithRect:NSMakeRect(0, 300, _size.width - 77, 60)],[NSValue valueWithRect:NSMakeRect(0, 0, _size.width -7, 300)]]].height;
//
        _size.width = _descSize.width + _imageSize.width + 100;
        _size.height = _descSize.width > 200 ? _descSize.height : _descSize.height + _imageSize.height + 10;
    
    
        _size.height = MAX(_size.height, _imageSize.height);
 //   }
    
}

@end
