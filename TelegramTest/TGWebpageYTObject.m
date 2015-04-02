//
//  TGWebpageTWObject.m
//  Telegram
//
//  Created by keepcoder on 01.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageYTObject.h"
#import "TGWebpageYTContainer.h"
#import "YoutubeServiceDescription.h"
@implementation TGWebpageYTObject

@synthesize size = _size;



-(void)makeSize:(int)width {
    
    [super makeSize:width];
    
    _size = self.imageSize;
    
    
    _descriptionSize = [self.title sizeForTextFieldForWidth:width-60];
    
    
    _size.height+=_descriptionSize.height+8;
    
    _size.width = width - 60;
    
}

-(Class)webpageContainer {
    return [TGWebpageYTContainer class];
}

-(void)loadVideo:(void (^)(XCDYouTubeVideo *video))callback {
    
    
    if(_video)
    {
        callback(_video);
        return;
    }
    
    NSString *videoIdentifier = [YoutubeServiceDescription idWithURL:self.webpage.display_url];
    
    
    [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:videoIdentifier completionHandler:^(XCDYouTubeVideo *video, NSError *error) {
        
        if (video)
        {
            _video = video;
            callback(video);
            
        }
        else
        {
            // Handle error
        }
        
    }];
}

@end
