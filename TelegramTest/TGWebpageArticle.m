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
@synthesize desc = _desc;
@synthesize imageSize = _imageSize;
@synthesize author = _author;
@synthesize imageObject = _imageObject;


-(id)initWithWebPage:(TLWebPage *)webpage {
    
    if(self = [super initWithWebPage:webpage]) {
        
        
        
        NSString *t = webpage.title.length > 0 ? webpage.title : webpage.author;
        
        if(t.length > 0) {
            
            
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
            
            [title appendString:[NSString stringWithFormat:@"%@\n",t] withColor:[NSColor blackColor]];
            [title setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:12.5] forRange:title.range];
            
            
            NSMutableAttributedString *attr = [[super desc] mutableCopy];
            
                        
            [attr insertAttributedString:title atIndex:0];
            
            _desc = attr;
        } else {
            _desc = [super desc];
        }
        
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

    if(self.imageObject) {
        
        _imageSize = strongsize(self.imageObject.imageSize,60);
        
        _size.height = [self.desc coreTextSizeForTextFieldForWidth:width - 67 withPaths:@[[NSValue valueWithRect:NSMakeRect(0, 300, _size.width - 77, 60)],[NSValue valueWithRect:NSMakeRect(0, 0, _size.width -7, 300)]]].height;
        
        
        _size.height = MAX(_size.height, 60);
    }
    
}

@end
