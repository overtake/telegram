//
//  TGThumbnailObject.m
//  Telegram
//
//  Created by keepcoder on 14/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGThumbnailObject.h"

@interface TGThumbnailObject ()
{
    BOOL _inited;
}
@end

@implementation TGThumbnailObject


-(id)initWithFilepath:(NSString *)filepath {
    if(self = [super init]) {
        _path = filepath;
    }
    
    return self;
}

-(void)initDownloadItem {
    
    
    if(!_inited) {
        _inited = YES;
        
        AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:_path] options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform=TRUE;
        CMTime thumbTime = CMTimeMakeWithSeconds(0,1);
        
        AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
            if (result != AVAssetImageGeneratorSucceeded) {
                NSLog(@"couldn't generate thumbnail, error:%@", error);
            }
            
            NSImage* thumbImg = [[NSImage alloc] initWithCGImage:im size:self.imageSize];
            
            thumbImg = renderedImage(thumbImg, self.imageSize);
            
            [TGCache cacheImage:thumbImg forKey:[self cacheKey] groups:@[IMGCACHE]];
            
            
            [ASQueue dispatchOnMainQueue:^{
                
                _inited = NO;
                
                [self.delegate didDownloadImage:thumbImg object:self];
            }];
        };
        
        
        generator.maximumSize = self.imageSize;
        [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
    }
    
}

-(NSString *)cacheKey {
    return _path;
}

@end
