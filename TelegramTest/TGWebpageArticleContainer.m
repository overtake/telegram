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
    

    [self.author setHidden:YES];
    
    
    
    [self.imageView setBackgroundColor:[NSColor redColor]];

    [self.imageView setFrame:NSMakeRect(NSWidth(self.frame) - 67, 0, 60, 60)];
    
    [self.descriptionField setDrawRects:@[[NSValue valueWithRect:NSMakeRect(0, NSHeight(self.frame) - 60, NSWidth(self.frame) - 60, 60)],[NSValue valueWithRect:NSMakeRect(0, 0, NSWidth(self.frame) , NSHeight(self.frame) - 60)]]];
    
    
    
    
    [self.descriptionField setFrame:NSMakeRect(0, 0, NSWidth(self.frame) , NSHeight(self.frame)  )];
    
    [self.descriptionField setAttributedString:webpage.desc];
    
    [self.descriptionField setBackgroundColor:[NSColor blueColor]];
    
    
    
}

@end
