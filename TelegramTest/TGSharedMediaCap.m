//
//  TGSharedMediaCap.m
//  Telegram
//
//  Created by keepcoder on 03.02.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSharedMediaCap.h"

@interface TGSharedMediaCap ()
@property (nonatomic,strong) NSImageView *capImageView;
@property (nonatomic,strong) TMTextField *capTextField;
@property (nonatomic,strong) NSProgressIndicator *progressIndicator;
@end

@implementation TGSharedMediaCap

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
    }
    
    return self;
}

-(instancetype)initWithFrame:(NSRect)frameRect cap:(NSImage *)cap text:(NSString *)text {
    if(self = [super initWithFrame:frameRect]) {
        
        self.progressIndicator = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
        
        [self.progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
        
        [self addSubview:self.progressIndicator];
        
        
        
        self.backgroundColor = NSColorFromRGB(0xffffff);
        
        self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        
        self.capImageView = imageViewWithImage(cap);
        
        self.capTextField = [TMTextField defaultTextField];
        
        
        [self.capTextField setAlignment:NSCenterTextAlignment];
        
        [self.capTextField setStringValue:text];
        
        [self.capTextField setFont:TGSystemFont(14)];
        [self.capTextField setTextColor:GRAY_TEXT_COLOR];
        
        [self.capTextField sizeToFit];
        
               
        [self addSubview:self.capTextField];
        [self addSubview:self.capImageView];
        
        
        [self setProgress:NO];
        
    }
    
    return self;
}

-(void)setProgress:(BOOL)progress {
    _progress = progress;
    [_progressIndicator setHidden:YES];
    
//    if(progress)
//        [_progressIndicator startAnimation:self];
//    else
//        [_progressIndicator stopAnimation:self];
    
    [_capImageView setHidden:progress];
    [_capTextField setHidden:progress];
}

-(void)updateCap:(NSImage *)cap text:(NSString *)text {
    
    [self.capImageView setImage:cap];
    
    [self.capImageView setFrameSize:cap.size];
    
    [self.capTextField setStringValue:text];
    
    [self.capTextField sizeToFit];
    
    [self setFrame:self.frame];
}

-(void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    
    [self.capTextField setCenterByView:self];
    
    [self.capImageView setCenterByView:self];
    
    [self.capImageView setFrameOrigin:NSMakePoint(NSMinX(self.capImageView.frame), NSMinY(self.capTextField.frame) + NSHeight(self.capTextField.frame) + 50)];
    
    [self.progressIndicator setCenterByView:self];
}


@end
