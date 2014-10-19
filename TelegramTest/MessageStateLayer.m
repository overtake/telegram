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
        
        
        self.progressView = [[TMClockProgressView alloc] initWithFrame:NSMakeRect(1, 0, 15, 15)];
        
        self.errorView = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_ChatMessageError().size.width , image_ChatMessageError().size.height)];
        [self.errorView setBackgroundImage:image_ChatMessageError() forControlState:BTRControlStateNormal];
        
        
        weak();
        
        [self.errorView addBlock:^(BTRControlEvents events) {
            [weakSelf.container alertError];
        } forControlEvents:BTRControlEventClick];
        
        
        self.readOrSentView = [[NSImageView alloc] initWithFrame:NSMakeRect(1, 3, 0, 0)];

        self.readOrSentView.wantsLayer = YES;
    }
    
    return self;
}


-(void)setState:(MessageTableCellState)state {
    _state = state;
    
    if(state == MessageTableCellSending) {
        [self.layer addSublayer:self.progressView.layer];
        [self.progressView startAnimating];
    } else {
        [self.progressView stopAnimating];
        [self.progressView.layer removeFromSuperlayer];
    }
    
    
    if(state == MessageTableCellSendingError) {
        [self addSubview:self.errorView];
    } else {
        [self.errorView.layer removeFromSuperlayer];
    }
    
    
    if(state == MessageTableCellUnread || state == MessageTableCellRead) {
        self.readOrSentView.image = state == MessageTableCellUnread ? image_MessageStateSent() : image_MessageStateRead();
        [self.readOrSentView setFrameSize:self.readOrSentView.image.size];
        [self.readOrSentView setFrameOrigin:NSMakePoint(state == MessageTableCellUnread ? 2 : 1, NSMinY(self.readOrSentView.frame))];
        [self.layer addSublayer:self.readOrSentView.layer];
    } else {
        self.readOrSentView.image = nil;
        [self.readOrSentView.layer removeFromSuperlayer];
    }
    
}




@end
