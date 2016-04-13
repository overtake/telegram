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
        
    
    [self.imageView setFrame:NSMakeRect(webpage.descSize.height > 60 ? (webpage.descSize.width + webpage.tableItem.defaultOffset) : [self textX], webpage.descSize.height > 60 ? 0 : webpage.descSize.height +  webpage.tableItem.defaultContentOffset, webpage.imageSize.width, webpage.imageSize.height)];
    
    
    if(webpage.imageObject) {
        
        
        [self.descriptionField setFrame:NSMakeRect([self textX], 0, webpage.descSize.width  , webpage.descSize.height )];
    } else {
        [self.descriptionField setFrame:NSMakeRect([self textX], 0, webpage.descSize.width , webpage.descSize.height )];
    }
    
    [self.descriptionField setAttributedString:webpage.desc];
    
    
}

-(void)showPhoto {
    open_link(self.webpage.webpage.url);
}

@end
