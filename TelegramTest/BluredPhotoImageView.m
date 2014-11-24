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



static CAAnimation *ani() {
    static CAAnimation *animation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        animation = [CABasicAnimation animationWithKeyPath:@"contents"];
        animation.duration = .2;
    });
    return animation;
}

- (void)setIsAlwaysBlur:(BOOL)isAlwaysBlur {
  //  if(self->_isAlwaysBlur == isAlwaysBlur)
    //    return;
    
    self->_isAlwaysBlur = isAlwaysBlur;
    [self setImage:self.originImage];
}

- (void)setImage:(NSImage *)image {
    
    self.originImage = image;
    
    if(image == nil) {
       // [self removeAnimationForKey:@"contents"];
        [super setImage:image];
        return;
    }
    
    BOOL isBlur = NO;
    
    
    if(self.isAlwaysBlur) {
        
       [ASQueue dispatchOnStageQueue:^{
            NSImage *blured = [self blur:image];
            [[ASQueue mainQueue] dispatchOnQueue:^{
                [super setImage:blured];
            }];
            
        }];
        
        return;
    }
    
    BOOL needAnimation = self.image && (self.isAlwaysBlur != isBlur);
    
    if(needAnimation) {
       // [self addAnimation:ani() forKey:@"contents"];
    } else {
       // [self removeAnimationForKey:@"contents"];
    }
    
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
