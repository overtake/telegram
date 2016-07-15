//
//  TGModernSendControlView.m
//  Telegram
//
//  Created by keepcoder on 12/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernSendControlView.h"
#import "POPLayerExtras.h"
@interface TGModernSendControlView ()
@property (nonatomic,strong) BTRButton *send;
@property (nonatomic,strong) BTRButton *voice;

@end

@implementation TGModernSendControlView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.wantsLayer = YES;
        _type = -1;
        _animates = YES;
        
        _send = [[BTRButton alloc] initWithFrame:NSZeroRect];
        _send.wantsLayer = YES;
        
        [_send setImage:image_ic_send() forControlState:BTRControlStateNormal];
        [_send setFrameSize:image_ic_send().size];
        
        [_send setCenterByView:self];
        
        [self addSubview:_send];
        
        
        _voice = [[BTRButton alloc] initWithFrame:NSZeroRect];
        _voice.wantsLayer = YES;
        _voice.layer.anchorPoint = NSMakePoint(0.5, 0.5);
        [_voice setImage:image_VoiceMic() forControlState:BTRControlStateNormal];
        [_voice setImage:image_VoiceMicHighlighted() forControlState:BTRControlStateHighlighted];
        [_voice setImage:image_VoiceMicHighlighted() forControlState:BTRControlStateSelected];
        [_voice setImage:image_VoiceMicHighlighted() forControlState:BTRControlStateSelected | BTRControlStateHover];
        [_voice setFrameSize:image_VoiceMic().size];
        [_voice setCenterByView:self];
        
        [_voice addTarget:self action:@selector(startRecord:) forControlEvents:BTRControlEventMouseDownInside];
        [_voice addTarget:self action:@selector(stopRecordInside:) forControlEvents:BTRControlEventMouseUpInside];
        [_voice addTarget:self action:@selector(stopRecordOutside:) forControlEvents:BTRControlEventMouseUpOutside];
        
        
        
        [self addSubview:_voice];
        
    }
    
    return self;
}

-(int)csx {
    return roundf((NSWidth(self.frame) - NSWidth(_send.frame))/2);
}

-(void)setType:(TGModernSendControlType)type {
    
    if(type == _type)
        return;
    _type = type;


    //dispatch_async(dispatch_get_main_queue(), ^{
        if(_animates) {
            
            [_send.layer removeAnimationForKey:@"position"];
            
            CABasicAnimation *pAnim = [CABasicAnimation animationWithKeyPath:@"position"];
            pAnim.duration = 0.2;
            pAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            pAnim.removedOnCompletion = YES;
            [pAnim setValue:@(CALayerPositionAnimation) forKey:@"type"];

            
            int presentX = self.presentSendX;

            
            pAnim.fromValue = [NSValue valueWithPoint:NSMakePoint(presentX, NSMinY(_send.frame))];
            pAnim.toValue = [NSValue valueWithPoint:NSMakePoint(self.csx , NSMinY(_send.frame))];
            
            
            
            CABasicAnimation *oAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            oAnim.duration = 0.2;
            oAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            oAnim.removedOnCompletion = YES;
            [oAnim setValue:@(CALayerOpacityAnimation) forKey:@"type"];
            
            
            oAnim.fromValue = @(type != TGModernSendControlSendType ? 1.0f : 0.0f);
            oAnim.toValue = @(type == TGModernSendControlSendType ? 1.0f : 0.0f);
            
            
            [_send.layer addAnimation:pAnim forKey:@"position"];
            [_send.layer addAnimation:oAnim forKey:@"opacity"];
            
            

            [[_voice animator] setAlphaValue:type != TGModernSendControlRecordType ? 0.0f : 1.0f];
            
            
//            if(_voice.layer.anchorPoint.x != 0.5) {
//                CGPoint point = _voice.layer.position;
//                
//                point.x += roundf(NSWidth(_voice.frame) / 2.0f);
//                point.y += roundf(NSHeight(_voice.frame) / 2.0f);
//                
//                _voice.layer.position = point;
//                _voice.layer.anchorPoint = CGPointMake(0.5, 0.5);
//                
//
//            }
            
//            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
//            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//            anim.duration = 0.125;
//            anim.repeatCount = 1;
//            anim.autoreverses = YES;
//            anim.removedOnCompletion = YES;
//            anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)];
//            [_voice.layer addAnimation:anim forKey:@"bounce"];
//            
//            _voice.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
            
         //
         //   _voice.layer.anchorPoint = NSMakePoint(0.5, 0.5);

            
            
            
//            POPSpringAnimation *sprintAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
//            sprintAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
//            sprintAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
//            
//            sprintAnimation.springBounciness = 4.0f;
//            [_voice.layer pop_addAnimation:sprintAnimation forKey:@"springAnimation"];
            
        }
    
        [_animates ? [_voice animator] : _voice setAlphaValue:type != TGModernSendControlRecordType ? 0.0f : 1.0f];
        _send.layer.opacity = type == TGModernSendControlSendType ? 1.0f : 0.0f;
        _send.layer.position = NSMakePoint(type != TGModernSendControlSendType ? -NSWidth(_send.frame) : self.csx, NSMinY(_send.frame));
        [_send setFrameOrigin:_send.layer.position];
    
}

-(float)presentSendX {
    CALayer *presentLayer = (CALayer *)[_send.layer presentationLayer];
    
    if(presentLayer && [_send.layer animationForKey:@"position"]) {
        float presentX = [[presentLayer valueForKeyPath:@"frame.origin.x"] floatValue];
        
        return presentX;
    }
    
    return _type == TGModernSendControlSendType ? -NSWidth(_send.frame) : self.csx;
}

-(void)performSendAnimation {
    if(_animates) {
        
        CABasicAnimation *pAnim = [CABasicAnimation animationWithKeyPath:@"position"];
        pAnim.duration = 0.2;
        pAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        pAnim.removedOnCompletion = YES;
        [pAnim setValue:@(CALayerPositionAnimation) forKey:@"type"];
        
        
        int presentX = self.presentSendX;
        
        pAnim.fromValue = [NSValue valueWithPoint:NSMakePoint(presentX, NSMinY(_send.frame))];
        pAnim.toValue = [NSValue valueWithPoint:NSMakePoint(NSWidth(self.frame) , NSMinY(_send.frame))];
        
        [_send.layer removeAnimationForKey:@"position"];
        
        [_send.layer addAnimation:pAnim forKey:@"position"];
        
    }
}

-(void)startRecord:(id)button {
    
}

-(void)stopRecordInside:(id)button {
    
}

-(void)stopRecordOutside:(id)button {
    
}

@end
