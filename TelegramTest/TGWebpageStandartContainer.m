//
//  TGWebpageStandartContainer.m
//  Telegram
//
//  Created by keepcoder on 02.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageStandartContainer.h"
#import "TGWebpageStandartObject.h"
#import "TGPhotoViewer.h"
@implementation TGWebpageStandartContainer


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        
    }
    
    return self;
}

-(void)setWebpage:(TGWebpageStandartObject *)webpage {
    
    [super setWebpage:webpage];
    
    
    [self.descriptionField setFrame:NSMakeRect([self textX], 0, webpage.descSize.width , webpage.descSize.height )];
    
    [self.descriptionField setAttributedString:webpage.desc];
    
    
    [self.imageView setFrame:NSMakeRect(0, webpage.size.height - webpage.imageSize.height, webpage.imageSize.width, webpage.imageSize.height)];
    
}

-(void)updateState:(TMLoaderViewState)state {
    [super updateState:state];
    
}

@end
