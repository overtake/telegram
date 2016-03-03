//
//  TGWebpageArticle.m
//  Telegram
//
//  Created by keepcoder on 05.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageArticle.h"
#import "TGArticleImageObject.h"
#import "TGExternalImageObject.h"
#import "MessageTableItem.h"
@implementation TGWebpageArticle

@synthesize size = _size;
@synthesize imageSize = _imageSize;
@synthesize author = _author;
@synthesize imageObject = _imageObject;
@synthesize descSize = _descSize;

-(id)initWithWebPage:(TLWebPage *)webpage tableItem:(MessageTableItem *)item {
    
    if(self = [super initWithWebPage:webpage tableItem:item]) {
        
        
       
        
        if([webpage.photo isKindOfClass:[TL_photo class]]) {
            
            TLPhotoSize *size = [webpage.photo.sizes lastObject];
            
            {
                _imageObject = [[TGArticleImageObject alloc] initWithLocation:size.location placeHolder:[super imageObject].placeholder sourceId:0 size:size.size];
                
                _imageObject.imageSize = NSMakeSize(60, 60);
            }
            
            
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
    
        _descSize = [self.desc coreTextSizeForTextFieldForWidth: width - self.tableItem.defaultOffset - _imageSize.width];
    
        _size.width = _descSize.width + _imageSize.width + self.tableItem.defaultOffset;
        _size.height = _descSize.height > 60 ? _descSize.height : _descSize.height + _imageSize.height + self.tableItem.defaultContentOffset;
    
    
        _size.height = MAX(_size.height, _imageSize.height);
 //   }
    
}

@end
