//
//  MessageStateLayer.m
//  Telegram
//
//  Created by keepcoder on 19.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageStateLayer.h"
#import "TMClockProgressView.h"
#import "NSNumber+NumberFormatter.h"
#import "TGTextLabel.h"
@interface MessageStateLayer ()
@property (nonatomic,strong) TMClockProgressView *progressView;
@property (nonatomic,strong) NSImageView *checkMark1;
@property (nonatomic,strong) NSImageView *checkMark2;


@property (nonatomic,strong) BTRButton *errorView;

@property (nonatomic,assign) MessageTableCellState state;

@property (nonatomic,strong) TGTextLabel *viewsCountText;

@property (nonatomic,strong) NSImageView *channelImageView;

@end

@implementation MessageStateLayer




-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.wantsLayer = YES;
    }
    
    return self;
}

-(void)setState:(MessageTableCellState)state animated:(BOOL)animated {
    
    if(state == MessageTableCellSending) {
        if(!self.progressView) {
            self.progressView = [[TMClockProgressView alloc] initWithFrame:NSMakeRect(NSWidth(self.frame) - image_ClockFrame().size.width, 1, 15, 15)];
            [self.layer addSublayer:self.progressView.layer];
        }
        [self.progressView startAnimating];
    } else {
        [self.progressView stopAnimating];
        [self.progressView.layer removeFromSuperlayer];
        self.progressView = nil;
    }
    
    
    if(state == MessageTableCellSendingError) {
        
        if(!self.errorView) {
            self.errorView = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(self.frame) - image_ChatMessageError().size.width, 1, image_ChatMessageError().size.width , image_ChatMessageError().size.height)];
            [self.errorView setBackgroundImage:image_ChatMessageError() forControlState:BTRControlStateNormal];
            [self addSubview:self.errorView];
        }
        
        weak();
        
        [self.errorView addBlock:^(BTRControlEvents events) {
            [weakSelf.container alertError];
        } forControlEvents:BTRControlEventClick];
        
        
    } else {
        [self.errorView removeFromSuperview];
        self.errorView = nil;
    }
    
    [_viewsCountText removeFromSuperview];
    _viewsCountText = nil;
    [_channelImageView removeFromSuperview];
    
    if((state == MessageTableCellUnread || state == MessageTableCellRead)) {
        
        if(self.container.item.message.isPost) {
            
            _channelImageView = imageViewWithImage(image_ChannelViews());
            
            [self.checkMark1 removeFromSuperview];
            [self.checkMark2 removeFromSuperview];
            self.checkMark1 = nil;
            self.checkMark2 = nil;
            
            _viewsCountText = [[TGTextLabel alloc] init];
            
            [_viewsCountText setText:self.container.item.viewsCountAndSign maxWidth:self.container.item.viewsCountAndSignSize.width];
            
            [_viewsCountText setFrameSize:NSMakeSize(MIN(NSWidth(self.frame) - NSWidth(_channelImageView.frame) - 4,self.container.item.viewsCountAndSignSize.width), NSHeight(_viewsCountText.frame))];
            [_viewsCountText setFrameOrigin:CGPointMake(NSWidth(self.frame) - NSWidth(_viewsCountText.frame) - 2,0)];
            [self addSubview:_viewsCountText];
            
            [_channelImageView setFrameOrigin:NSMakePoint(NSMinX(_viewsCountText.frame) - NSWidth(_channelImageView.frame) - 2, 3)];
            
            [self addSubview:_channelImageView];

        } else {
            
            if(!_checkMark1) {
                _checkMark1 = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 1, 0, 0)];
                _checkMark1.wantsLayer = YES;
                _checkMark1.image = image_ModernMessageCheckmark1();
                [_checkMark1 setFrameSize:image_ModernMessageCheckmark1().size];
                
            }
            
            [self.layer addSublayer:_checkMark1.layer];
            
            if(state == MessageTableCellRead) {
                if(!_checkMark2) {
                    _checkMark2 = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 1, 0, 0)];
                    _checkMark2.wantsLayer = YES;
                    _checkMark2.image = image_ModernMessageCheckmark2();
                    [_checkMark2 setFrameSize:image_ModernMessageCheckmark2().size];
                }
                
                [self addSubview:_checkMark2];

            } else {
                [_checkMark2 removeFromSuperview];
                _checkMark2= nil;
            }
            
            [self.checkMark1 setFrameOrigin:NSMakePoint(NSWidth(self.frame) - 15, NSMinY(self.checkMark1.frame))];
            [self.checkMark2 setFrameOrigin:NSMakePoint(NSWidth(self.frame) - (15 - 4), NSMinY(self.checkMark2.frame))];
            
            
            if(_state == MessageTableCellSending && state == MessageTableCellUnread) {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                animation.fromValue = @(1.2f);
                animation.toValue = @(1.0f);
                animation.duration = 0.14;
                animation.removedOnCompletion = true;
                [_checkMark1.layer addAnimation:animation forKey:@"transform.scale"];
            }
            
            if(_state == MessageTableCellUnread && state == MessageTableCellRead) {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                animation.fromValue = @(1.2f);
                animation.toValue = @(1.0f);
                animation.duration = 0.14;
                animation.removedOnCompletion = true;
                [_checkMark2.layer addAnimation:animation forKey:@"transform.scale"];
            }
            
        }
        
    } else {
        [self.checkMark1 removeFromSuperview];
        [self.checkMark2 removeFromSuperview];
        self.checkMark1 = nil;
        self.checkMark2 = nil;
    }
    
    _state = state;
    
    [self setNeedsDisplay:YES];

}

-(void)setState:(MessageTableCellState)state {
    [self setState:state animated:NO];
}


@end
