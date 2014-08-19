//
//  TypingController.m
//  Telegram
//
//  Created by keepcoder on 06.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TypingController.h"

@interface TypingController ()
@property (nonatomic,strong) NSImageView *imageView;
@end

@implementation TypingController
-(id)initWithImageView:(NSImageView *)imageView {
    
    if(self = [super init]) {
        self.imageView = imageView;
        [self stopAnimation];
       
      
    }
    return self;
}



-(void)startAnimation {
    [self.imageView setHidden:NO];
    [self.viewToHidden setHidden:YES];
    [self loop:1];
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self stopAnimation];
    });
}

-(void)loop:(int)img_id {
    if(self.imageView.isHidden) return;
    self.imageView.image = [NSImage imageNamed:[NSString stringWithFormat:@"typing_animated_%d",img_id]];
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self loop:(img_id % 5)+1];
    });
}

-(void)stopAnimation {
    [self.imageView setHidden:YES];
     [self.viewToHidden setHidden:NO];
     self.imageView.image = nil;
}
@end
