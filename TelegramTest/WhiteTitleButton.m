//
//  WhiteTitleButton.m
//  Telegram
//
//  Created by keepcoder on 06.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "WhiteTitleButton.h"

@implementation WhiteTitleButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSCenterTextAlignment];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSColor whiteColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
        NSAttributedString *attrString = [[NSAttributedString alloc]
                                          initWithString:self.title attributes:attrsDictionary];
        [self setAttributedTitle:attrString];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
  
}

@end
