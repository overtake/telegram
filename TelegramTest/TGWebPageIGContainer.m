//
//  TGWebPageYTContainer.m
//  Telegram
//
//  Created by keepcoder on 01.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebPageIGContainer.h"
#import "TGImageView.h"
#import "TMLoaderView.h"
#import "TGPhotoViewer.h"
#import "TGWebpageIGObject.h"
@interface TGWebpageIGContainer ()

@property (nonatomic,strong) NSImageView *playVideo;
@end

@implementation TGWebpageIGContainer



-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
    }
    
    return self;
}

-(void)setWebpage:(TGWebpageIGObject *)webpage {
    
     [super setWebpage:webpage];
    
    [_playVideo removeFromSuperview];
    _playVideo = nil;
    
    [self.imageView setFrame:NSMakeRect(0, NSHeight(self.frame) - webpage.imageSize.height, webpage.imageSize.width, webpage.imageSize.height)];
    
   
    
    if([webpage.webpage.type isEqualToString:@"video"]) {
        
        _playVideo = imageViewWithImage(image_WebpageInstagramVideoPlay());
        
        [self.imageView addSubview:_playVideo];
        
        [_playVideo setCenterByView:self.imageView];
    }
    
    [self.descriptionField setFrame:NSMakeRect([self textX], 20, webpage.descSize.width , webpage.descSize.height + 20 > NSHeight(self.frame) ? NSHeight(self.frame) - 20 : webpage.descSize.height )];
    
    [self.descriptionField setAttributedString:webpage.desc];
    
    
}

-(void)updateState:(TMLoaderViewState)state {
    [super updateState:state];
    
}


@end
