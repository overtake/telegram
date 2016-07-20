//
//  TGModernSendControlView.m
//  Telegram
//
//  Created by keepcoder on 12/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernSendControlView.h"
#import "POPLayerExtras.h"
#import "TGModernMessagesBottomView.h"



@interface TGModernSendControlView ()
@property (nonatomic,strong) BTRButton *send;
@property (nonatomic,strong) BTRButton *voice;
@property (nonatomic,strong) BTRButton *inlineDispose;



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
        [_voice setFrameSize:image_VoiceMic().size];
        [self setVoiceSelected:NO];
        [_voice setCenterByView:self];
        
        [_voice addTarget:self action:@selector(startRecord:) forControlEvents:BTRControlEventMouseDownInside];
        
        [self addTarget:self action:@selector(sendAction:) forControlEvents:BTRControlEventClick];
        [_send addTarget:self action:@selector(sendAction:) forControlEvents:BTRControlEventClick];
        
        _inlineDispose = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_LoadCancelGrayIcon().size.width, image_LoadCancelGrayIcon().size.height)];
        [_inlineDispose setImage:image_LoadCancelGrayIcon() forControlState:BTRControlStateNormal];
        
        [_inlineDispose setCenterByView:self];
        
        [_inlineDispose addTarget:self action:@selector(sendAction:) forControlEvents:BTRControlEventClick];
        
    }
    
    return self;
}

-(void)sendAction:(BTRButton *)sender {
    [_delegate _performSendAction];
}

-(void)inlineDisposeAction:(id)sender {
    
}

-(int)csx {
    return roundf((NSWidth(self.frame) - NSWidth(_send.frame))/2);
}

-(void)setType:(TGModernSendControlType)type {
    
    TGModernSendControlType otype = _type;
    
    if(type == _type || (otype == TGModernSendControlSendType && type == TGModernSendControlEditType))
        return;
    _type = type;


    if(_animates) {
        
        [_send.layer removeAnimationForKey:@"position"];
        
        CABasicAnimation *pAnim = [CABasicAnimation animationWithKeyPath:@"position"];
        pAnim.duration = 0.2;
        pAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        pAnim.removedOnCompletion = YES;
        [pAnim setValue:@(CALayerPositionAnimation) forKey:@"type"];
        
        
        int presentX = otype == TGModernSendControlInlineRequestType ? self.csx : self.presentSendX;
        
        
        pAnim.fromValue = [NSValue valueWithPoint:NSMakePoint(presentX, NSMinY(_send.frame))];
        pAnim.toValue = [NSValue valueWithPoint:NSMakePoint(self.csx , NSMinY(_send.frame))];
        
        
        
        [_send.layer addAnimation:pAnim forKey:@"position"];

        
    }
    
    if(type == TGModernSendControlSendType || type == TGModernSendControlEditType) {
        [_voice removeFromSuperview:_animates];
        [_send performCAShow:_animates];
    } else if(type == TGModernSendControlRecordType) {
        [_voice performCAShow:_animates];
        [_send performCAFade:_animates];
        [self addSubview:_voice];
    } else if(type == TGModernSendControlInlineRequestType) {
        [_voice removeFromSuperview:_animates];
        [_send performCAFade:_animates];
        [_inlineDispose performCAShow:_animates];
        [self addSubview:_inlineDispose];
    }
    
    if(otype == TGModernSendControlInlineRequestType) {
        [_inlineDispose removeFromSuperview:_animates];
    }
    
    
    _send.layer.opacity = type == TGModernSendControlSendType || type == TGModernSendControlEditType ? 1.0f : 0.0f;
    _send.layer.position = NSMakePoint(type != TGModernSendControlSendType && type != TGModernSendControlEditType ? -NSWidth(_send.frame) : self.csx, NSMinY(_send.frame));
    [_send setFrameOrigin:_send.layer.position];

}

-(float)presentSendX {
    CALayer *presentLayer = (CALayer *)[_send.layer presentationLayer];
    
    if(presentLayer && [_send.layer animationForKey:@"position"]) {
        float presentX = [[presentLayer valueForKeyPath:@"frame.origin.x"] floatValue];
        
        return presentX;
    }
    
    return _type == TGModernSendControlSendType || _type == TGModernSendControlEditType ? -NSWidth(_send.frame) : self.csx;
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
    [self setVoiceSelected:YES];
    [_delegate _startAudioRecord];
}



-(void)setVoiceSelected:(BOOL)selected {
    [_voice setSelected:selected];
    [_voice setImage:_voice.isSelected ? image_VoiceMicHighlighted() : image_VoiceMic() forControlState:BTRControlStateNormal];

}

@end
