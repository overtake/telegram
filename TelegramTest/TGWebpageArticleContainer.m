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
    
    // Drawing code here.
}


-(void)setWebpage:(TGWebpageObject *)webpage {
    
    
    [super setWebpage:webpage];
    
    
    [self.author setHidden:webpage.title != nil];
        
    [self.imageView setFrame:NSMakeRect(NSWidth(self.frame) - 67, 20, webpage.imageSize.width, webpage.imageSize.height)];
    
    if(webpage.imageObject) {
        [self.descriptionField setDrawRects:@[[NSValue valueWithRect:NSMakeRect(0, webpage.size.height - 80, webpage.size.width - 77, 60)],[NSValue valueWithRect:NSMakeRect(0, 0, webpage.size.width - 7, webpage.size.height - 80)]]];
        
        [self.descriptionField setFrame:NSMakeRect([self textX], 16, webpage.size.width - 7 , webpage.size.height - 20 )];
    } else {
        [self.descriptionField setFrame:NSMakeRect([self textX], 30, webpage.descSize.width , webpage.descSize.height )];
    }
     
    
    
    [self.descriptionField setAttributedString:webpage.desc];
    
    
}

@end
