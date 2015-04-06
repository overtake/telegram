//
//  TGWebPageYTContainer.m
//  Telegram
//
//  Created by keepcoder on 01.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebPageTWContainer.h"
#import "TGImageView.h"
#import "TMLoaderView.h"
#import "TGCTextView.h"
#import "TGPhotoViewer.h"
#import "TGWebpageTWObject.h"
@interface TGWebpageTWContainer ()




@end

@implementation TGWebpageTWContainer



-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        
    }
    
    return self;
}

-(void)setWebpage:(TGWebpageTWObject *)webpage {
    
    [super setWebpage:webpage];
    
    [self.descriptionField setFrame:NSMakeRect([self textX], 0, webpage.descSize.width , webpage.descSize.height )];
    
    
    [self.imageView setFrame:NSMakeRect(0, webpage.size.height - webpage.imageSize.height, webpage.imageSize.width, webpage.imageSize.height)];
    

    
    [self.descriptionField setAttributedString:webpage.desc];
    
}

-(void)updateState:(TMLoaderViewState)state {
    [super updateState:state];
}


@end
