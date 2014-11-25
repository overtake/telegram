//
//  MessageStateLayer.m
//  Telegram
//
//  Created by keepcoder on 19.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageStateLayer.h"
#import "TMClockProgressView.h"
@interface MessageStateLayer ()
@property (nonatomic,strong) TMClockProgressView *progressView;
@property (nonatomic,strong) NSImageView *readOrSentView;
@property (nonatomic,strong) BTRButton *errorView;

@property (nonatomic,assign) MessageTableCellState state;

@end

@implementation MessageStateLayer




-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
    
        
    }
    
    return self;
}


-(void)setState:(MessageTableCellState)state {
    _state = state;
    
    if(state == MessageTableCellSending) {
         self.progressView = [[TMClockProgressView alloc] initWithFrame:NSMakeRect(1, 4, 15, 15)];
        [self.layer addSublayer:self.progressView.layer];
        [self.progressView startAnimating];
    } else {
        [self.progressView stopAnimating];
        [self.progressView.layer removeFromSuperlayer];
        self.progressView = nil;
    }
    
    
    if(state == MessageTableCellSendingError) {
        self.errorView = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 2, image_ChatMessageError().size.width , image_ChatMessageError().size.height)];
        [self.errorView setBackgroundImage:image_ChatMessageError() forControlState:BTRControlStateNormal];
        [self addSubview:self.errorView];
        
        weak();
        
        [self.errorView addBlock:^(BTRControlEvents events) {
            [weakSelf.container alertError];
        } forControlEvents:BTRControlEventClick];
        
        
    } else {
        [self.errorView.layer removeFromSuperlayer];
        self.errorView = nil;
    }
    
    
    if(state == MessageTableCellUnread || state == MessageTableCellRead) {
       
        if(!self.readOrSentView) {
            self.readOrSentView = [[NSImageView alloc] initWithFrame:NSMakeRect(1, 5, 0, 0)];
            self.readOrSentView.wantsLayer = YES;
        }
        
        self.readOrSentView.image = state == MessageTableCellUnread ? image_MessageStateSent() : image_MessageStateRead();
        [self.readOrSentView setFrameSize:self.readOrSentView.image.size];
        [self.readOrSentView setFrameOrigin:NSMakePoint(state == MessageTableCellUnread ? 2 : 1, NSMinY(self.readOrSentView.frame))];
        [self.layer addSublayer:self.readOrSentView.layer];
    } else {
        self.readOrSentView.image = nil;
        [self.readOrSentView.layer removeFromSuperlayer];
        self.readOrSentView = nil;
    }
    
}




@end
