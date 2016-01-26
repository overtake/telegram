//
//  TGWebpageArticleContainer.m
//  Telegram
//
//  Created by keepcoder on 05.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageArticleContainer.h"

@implementation TGWebpageArticleContainer

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}


-(void)setWebpage:(TGWebpageObject *)webpage {
    
    [super setWebpage:webpage];
        
    
    [self.imageView setFrame:NSMakeRect(webpage.descSize.width > 200 ? (webpage.descSize.width + 5) : [self textX], webpage.descSize.width > 200 ? 0 : webpage.descSize.height + 5, webpage.imageSize.width, webpage.imageSize.height)];
    
    if(webpage.imageObject) {
        
        
        //[self.descriptionField setDrawRects:@[[NSValue valueWithRect:NSMakeRect(0, webpage.size.height - 60, webpage.size.width - 77, 60)],[NSValue valueWithRect:NSMakeRect(0, 0, webpage.size.width - 7, webpage.size.height - 60)]]];
        
        [self.descriptionField setFrame:NSMakeRect([self textX], 0, webpage.descSize.width  , webpage.size.height )];
    } else {
        [self.descriptionField setFrame:NSMakeRect([self textX], 0, webpage.descSize.width , webpage.descSize.height )];
    }
    
    [self.descriptionField setAttributedString:webpage.desc];
    
    
}

-(void)showPhoto {
    open_link(self.webpage.webpage.url);
}

@end
