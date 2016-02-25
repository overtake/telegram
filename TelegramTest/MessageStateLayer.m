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
@property (nonatomic,strong) NSImageView *readOrSentView;
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
    _state = state;
    
    
    if(state == MessageTableCellSending) {
        if(!self.progressView) {
            self.progressView = [[TMClockProgressView alloc] initWithFrame:NSMakeRect(NSWidth(self.frame) - image_ClockFrame().size.width, 4, 15, 15)];
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
            self.errorView = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(self.frame) - image_ChatMessageError().size.width, 2, image_ChatMessageError().size.width , image_ChatMessageError().size.height)];
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
            
            self.readOrSentView.image = nil;
            [self.readOrSentView.layer removeFromSuperlayer];
            self.readOrSentView = nil;
            
            _viewsCountText = [[TGTextLabel alloc] init];
            
            [_viewsCountText setText:self.container.item.viewsCountAndSign maxWidth:50];
            
            [_viewsCountText setFrameSize:NSMakeSize(MIN(NSWidth(self.frame) - NSWidth(_channelImageView.frame) - 4,self.container.item.viewsCountAndSignSize.width), 17)];
            [_viewsCountText setFrameOrigin:CGPointMake(NSWidth(self.frame) - NSWidth(_viewsCountText.frame) - 2,1)];
            [self addSubview:_viewsCountText];
            
            [_channelImageView setFrameOrigin:NSMakePoint(NSMinX(_viewsCountText.frame) - NSWidth(_channelImageView.frame), 5)];
            
            [self addSubview:_channelImageView];
            
            
        } else {
            if(!self.readOrSentView) {
                self.readOrSentView = [[NSImageView alloc] initWithFrame:NSMakeRect(11, 2, 0, 0)];
                self.readOrSentView.wantsLayer = YES;
            }
            
            self.readOrSentView.image = state == MessageTableCellUnread ? image_MessageStateSent() : image_MessageStateRead();
            [self.readOrSentView setFrameSize:self.readOrSentView.image.size];
            [self.readOrSentView setFrameOrigin:NSMakePoint(NSWidth(self.frame) - NSWidth(_readOrSentView.frame), NSMinY(self.readOrSentView.frame))];
            [self.layer addSublayer:self.readOrSentView.layer];
        }
        
    } else {
        self.readOrSentView.image = nil;
        [self.readOrSentView.layer removeFromSuperlayer];
        self.readOrSentView = nil;
        
        
    }
    
    
    [self setNeedsDisplay:YES];

}

-(void)setState:(MessageTableCellState)state {
    [self setState:state animated:NO];
}


@end
