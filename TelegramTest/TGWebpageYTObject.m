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
@synthesize author = _author;
-(id)initWithWebPage:(TLWebPage *)webpage {
    if(self = [super initWithWebPage:webpage]) {
        
        NSString *sizeInfo = [NSString durationTransformedValue:self.webpage.duration];
        
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:sizeInfo attributes:@{NSForegroundColorAttributeName: [NSColor whiteColor] }];

        
        _videoTimeAttributedString = attr;
        
        
       // _desc = [super title];
        
        NSSize size = [_videoTimeAttributedString size];
        size.width = ceil(size.width + 10);
        size.height = ceil(size.height + 3);
        _videoTimeSize = size;
        
     //   _author = [super title];

    }
    
    return self;
}


-(void)makeSize:(int)width {
    
    [super makeSize:width];
    
    _size = [super size];
        
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
