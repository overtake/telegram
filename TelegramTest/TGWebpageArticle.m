//
//  TGWebpageArticle.m
//  Telegram
//
//  Created by keepcoder on 05.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageArticle.h"

@implementation TGWebpageArticle

@synthesize size = _size;
@synthesize desc = _desc;

-(id)initWithWebPage:(TLWebPage *)webpage {
    
    if(self = [super initWithWebPage:webpage]) {
        
        
      //  webpage.title = @"Super article mega test";
        
        if(webpage.title.length > 0) {
            
            
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
            
            [title appendString:[NSString stringWithFormat:@"%@\n",webpage.author] withColor:[NSColor blackColor]];
            [title setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:12.5] forRange:title.range];
            
            
            NSMutableAttributedString *attr = [[super desc] mutableCopy];
            
                        
             [attr insertAttributedString:title atIndex:0];
            
            _desc = attr;
        } else {
            _desc = [super desc];
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
        _size.height = [self.desc coreTextSizeForTextFieldForWidth:self.imageSize.width ? : width-67 withPaths:@[[NSValue valueWithRect:NSMakeRect(0, 300, _size.width - 70, 60)],[NSValue valueWithRect:NSMakeRect(0, 0, _size.width -7, 300)]]].height;
        
        _size.height += 20;
        
        _size.height = MAX(_size.height, 80);
    }
    
}

@end
