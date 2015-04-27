//
//  BluredPhotoImageView.m
//  Telegram
//
//  Created by keepcoder on 01.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "BluredPhotoImageView.h"

@interface BluredPhotoImageView ()
@property (nonatomic, strong) NSImage *originImage;
@end

@implementation BluredPhotoImageView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
       // self.isNotNeedHackMouseUp = NO;
    }
    return self;
}





- (void)setIsAlwaysBlur:(BOOL)isAlwaysBlur {
  //  if(self->_isAlwaysBlur == isAlwaysBlur && self.image == self.originImage)
    //    return;
    
    self->_isAlwaysBlur = isAlwaysBlur;
    
    [self setImage:self.originImage];
}

- (void)setImage:(NSImage *)image {
    
    self.originImage = image;
    
    if(image == nil) {
        [self removeAnimationForKey:@"contents"];
        [super setImage:image];
        return;
    }
    
    if(self.isAlwaysBlur) {
        
        NSString *key = [NSString stringWithFormat:@"%d:blured",self.object.sourceId];
        
        __block NSImage *blured = [TGCache cachedImage:key];
        
        
        if(!blured) {
            
            
            [ASQueue dispatchOnStageQueue:^{
                
                blured = [self blur:image];
                
                [TGCache cacheImage:blured forKey:key groups:@[IMGCACHE]];
                
                [[ASQueue mainQueue] dispatchOnQueue:^{
                    [super setImage:blured];
                }];
                
            }];
            
        } else {
            [super setImage:blured];
        }
        
       
        return;
    }
    
//    BOOL needAnimation = self.image && (_isAlwaysBlur != _isBlurred);
//    
//    if(needAnimation) {
//        [self addAnimation:ani() forKey:@"contents"];
//    } else {
//        [self removeAnimationForKey:@"contents"];
//    }
    
   // test_start_group(@"image_time");
    
    [super setImage:image];
    
    
   // test_step_group(@"image_time");
    
   // test_release_group(@"image_time");
}

- (NSImage *)blur:(NSImage *)image {
    NSSize size = self.frame.size;
    CGFloat displayScale = [[NSScreen mainScreen] backingScaleFactor];
    
    size.width *= displayScale;
    size.height *= displayScale;
    
    image = [ImageUtils blurImage:image blurRadius:self.frame.size.width / 2 frameSize:size];
    return image;
}
@end
