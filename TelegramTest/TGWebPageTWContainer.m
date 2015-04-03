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
        
        dispatch_block_t block = ^{
            
            PreviewObject *previewObject =[[PreviewObject alloc] initWithMsdId:self.webpage.webpage.photo.n_id media:[self.webpage.webpage.photo.sizes lastObject] peer_id:0];
            
            previewObject.reservedObject = self.imageView.image;
            
            [[TGPhotoViewer viewer] show:previewObject];
            
        };
        
        
        [self.imageView setTapBlock:block];
        
        
    }
    
    return self;
}

-(void)setWebpage:(TGWebpageTWObject *)webpage {
    
    
    
    [self.imageView setFrame:NSMakeRect(0, NSHeight(self.frame) - webpage.imageSize.height, webpage.imageSize.width, webpage.imageSize.height)];
    
    [self.imageView setObject:webpage.imageObject];
    
    [self.loaderView setCenterByView:self.imageView];
    
    [self.descriptionField setFrame:NSMakeRect(0, 20, webpage.descSize.width , webpage.descSize.height )];
    
    [self.descriptionField setAttributedString:webpage.desc];
    
    [self.author setHidden:!webpage.author];
    [self.date setHidden:!webpage.date];
    
    if(webpage.author ) {
        [self.author setAttributedStringValue:webpage.author];
        [self.author sizeToFit];
        [self.author setFrameOrigin:NSMakePoint(0, -4)];
    }
    
    if(webpage.date && webpage.author) {
        [self.date setStringValue:webpage.date];
        [self.date sizeToFit];
        [self.date setFrameOrigin:NSMakePoint(NSMaxX(self.author.frame) + 4, 0)];
    }
    
    [super setWebpage:webpage];
    
}

-(void)updateState:(TMLoaderViewState)state {
    [super updateState:state];
    
}


@end
