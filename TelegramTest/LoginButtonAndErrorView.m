//
//  LoginButtonAndErrorView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "LoginButtonAndErrorView.h"

@interface LoginButtonAndErrorView()
@property (nonatomic,strong) NSImageView *nextImageView;
@property (nonatomic,assign) BOOL hasImage;
@end

@implementation LoginButtonAndErrorView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.errorTextField = [TMTextField defaultTextField];
        [self.errorTextField setEditable:NO];
        [self.errorTextField setWantsLayer:IS_RETINA];
        [self.errorTextField setFrameOrigin:NSMakePoint(0, 0)];
        [self.errorTextField setFont:TGSystemFont(13)];
        [self.errorTextField setTextColor:[NSColor redColor]];
        self.errorTextField.layer.opacity = 0;
        [self addSubview:self.errorTextField];
        
        self.textButton = [[TMTextButton alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
        [self.textButton setFont:TGSystemFont(15)];
        [self.textButton setDisableColor:NSColorFromRGB(0xaeaeae)];
        [self.textButton setTextColor:BLUE_UI_COLOR];
        [self.textButton setWantsLayer:IS_RETINA];
        [self.textButton sizeToFit];
        [self addSubview: self.textButton];
        
        
        NSImage *image = [NSImage imageNamed:@"login_next"];
        
        self.nextImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, image.size.width, image.size.height)];
        self.nextImageView.image = image;
        [self addSubview:self.nextImageView];
        self.nextImageView.wantsLayer = YES;
        [self.nextImageView setHidden:YES];
        
      //  self.backgroundColor = [NSColor orangeColor];
    }
    return self;
}

-(void)setHasImage:(BOOL)hasImage {
    self->_hasImage = hasImage;
    [self.nextImageView setHidden:!hasImage];
}

- (void)setButtonText:(NSString *)string {
    self.textButton.stringValue = string;
    [self.textButton sizeToFit];
    
    float errorOffset = 0;
    if(self.errorTextField.layer.opacity != 0)
        errorOffset = self.errorTextField.bounds.size.height + 5;
    
    [self.textButton setFrameOrigin:NSMakePoint(self.textButton.frame.origin.x, self.bounds.size.height - self.textButton.bounds.size.height - errorOffset)];
    
    [self.nextImageView setFrameOrigin:NSMakePoint(self.textButton.frame.origin.x + NSWidth(self.textButton.frame) + 7, self.bounds.size.height - self.textButton.bounds.size.height - errorOffset +2)];
}

- (void)prepareForLoading {
    [self.textButton setDisable:YES];
    [self.nextImageView setHidden:YES];
}

- (void)loadingSuccess {
    [self.textButton setDisable:NO];
    [self.textButton setTextColor:BLUE_UI_COLOR];
    [self setHasImage:self.hasImage];
}

- (void)showErrorWithText:(NSString *)text {
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.errorTextField setHidden:self.errorTextField.layer.opacity == 0];
        [self.textButton setHidden:self.textButton.layer.opacity == 0];

        if(!IS_RETINA) {
            [self setWantsLayer:NO];
            [self.errorTextField setWantsLayer:NO];
            [self.textButton setWantsLayer:NO];
        }
    }];
    
    float duration = 0.1;
    float offsetError = 5;
    
    BOOL fromOpacity, toOpacity;

    NSPoint fromPoint, toPoint, fromPointImage,toPointImage;
  
    [self prepareForAnimation];
    [self.errorTextField prepareForAnimation];
    [self.textButton prepareForAnimation];
    
    self.errorTextField.layer.opacity = self.errorTextField.isHidden ? 0 : 1;
    [self.errorTextField setHidden:NO];
    
    self.textButton.layer.opacity = self.textButton.isHidden ? 0 : 1;
    [self.textButton setHidden:NO];
    
    if(text) {
        [self.errorTextField setStringValue:text];
        [self.errorTextField sizeToFit];
        [self.errorTextField setFrameOrigin:NSMakePoint(self.errorTextField.frame.origin.x, self.bounds.size.height - self.errorTextField.bounds.size.height)];
        
        fromOpacity = 0;
        toOpacity = 1;
        
        toPoint = NSMakePoint(self.textButton.frame.origin.x, self.bounds.size.height - self.textButton.bounds.size.height - self.errorTextField.bounds.size.height - offsetError);
        fromPoint = NSMakePoint(self.textButton.frame.origin.x, self.bounds.size.height - self.textButton.bounds.size.height);
        
        
        
        toPointImage = NSMakePoint(self.textButton.frame.origin.x + NSWidth(self.textButton.frame) + 7, self.bounds.size.height - self.errorTextField.bounds.size.height - offsetError - 18);
        fromPointImage = self.nextImageView.frame.origin;
        
        
    } else {
        fromOpacity = 1;
        toOpacity = 0;
        
        fromPoint = NSMakePoint(self.textButton.frame.origin.x, self.bounds.size.height - self.textButton.bounds.size.height - self.errorTextField.bounds.size.height - offsetError);
        toPoint = NSMakePoint(self.textButton.frame.origin.x, self.bounds.size.height - self.textButton.bounds.size.height);
        
        toPointImage = NSMakePoint(self.textButton.frame.origin.x + NSWidth(self.textButton.frame) + 7, self.bounds.size.height - self.errorTextField.bounds.size.height - offsetError - 13);
        fromPointImage = self.nextImageView.frame.origin;
    }
    
    
    if(toOpacity != self.errorTextField.layer.opacity)
        [self.errorTextField setAnimation:[TMAnimations fadeWithDuration:duration fromValue:fromOpacity toValue:toOpacity] forKey:@"alpha"];
    
    if(!NSEqualPoints(toPoint, self.textButton.frame.origin))
        [self.textButton setAnimation:[TMAnimations postionWithDuration:duration fromValue:fromPoint toValue:toPoint] forKey:@"position"];
    
    [self.nextImageView setAnimation:[TMAnimations postionWithDuration:duration fromValue:fromPointImage toValue:toPointImage] forKey:@"position"];

    [CATransaction commit];
}

- (void)performTextToBottomWithDuration:(float)duration {

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.textButton.layer.opacity = 0;
        [self.errorTextField setHidden:self.errorTextField.layer.opacity == 0];
        [self.textButton setHidden:self.textButton.layer.opacity == 0];

        if(!IS_RETINA) {
            [self setWantsLayer:NO];
            [self.errorTextField setWantsLayer:NO];
            [self.textButton setWantsLayer:NO];
        }
    }];
    
    [self prepareForAnimation];
    [self.errorTextField prepareForAnimation];
    [self.textButton prepareForAnimation];
    
    self.errorTextField.layer.opacity = self.errorTextField.isHidden ? 0 : 1;
    [self.errorTextField setHidden:NO];
    
    self.textButton.layer.opacity = self.textButton.isHidden ? 0 : 1;
    [self.textButton setHidden:NO];
    
    //Fade errorTextField if that need
    if(self.errorTextField.layer.opacity) {
        [self.errorTextField setAnimation:[TMAnimations fadeWithDuration:duration * 0.5 fromValue:self.errorTextField.layer.opacity toValue:0] forKey:@"alpha"];
    }
    
    NSPoint toPoint = NSMakePoint(0, 0);
    NSPoint fromPoint = self.textButton.frame.origin;
    
    CAAnimation *positionAnimation = [TMAnimations postionWithDuration:duration * (7 / 13.0) fromValue:fromPoint toValue:toPoint];
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.textButton setAnimation:positionAnimation forKey:@"position2"];
    
    
    CAAnimation *positionAnimation2 = [TMAnimations postionWithDuration:duration * (3 / 13.0) fromValue:NSMakePoint(0, 0) toValue:NSMakePoint(0, -self.textButton.bounds.size.height)];
    positionAnimation2.beginTime = CACurrentMediaTime() + positionAnimation.duration;
    positionAnimation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self.textButton setAnimation:positionAnimation2 forKey:@"position"];
    
    
    CABasicAnimation *opacityAnimation = (CABasicAnimation *)[TMAnimations fadeWithDuration:duration * (6 / 13.0) fromValue:1 toValue:0.2];
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.textButton setAnimation:opacityAnimation forKey:@"opacity"];
    
    CAAnimation *opacityAnimation2 = [TMAnimations fadeWithDuration:duration * (3 / 13.0) fromValue:0.1 toValue:0];
    opacityAnimation2.beginTime = CACurrentMediaTime() + opacityAnimation.duration;
    opacityAnimation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.textButton setAnimation:opacityAnimation2 forKey:@"opacity2"];
    [CATransaction begin];
}


@end
