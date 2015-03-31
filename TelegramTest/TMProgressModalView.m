//
//  TMProgressModalView.m
//  Telegram
//
//  Created by keepcoder on 02.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMProgressModalView.h"
#import "ITProgressIndicator.h"

@interface TMProgressModalView ()
@property (nonatomic,strong) TMView *progressContainer;
@property (nonatomic,strong) ITProgressIndicator *progressIndicator;
@property (nonatomic,strong) NSImageView *successImageView;
@end

@implementation TMProgressModalView



- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _successImageView = imageViewWithImage(image_ProgressWindowCheck());
        
        
        [_successImageView setCenterByView:self];
        
        
        
        [self setWantsLayer:YES];
        [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
                
        self.progressContainer = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 80, 80)];
        
        self.progressContainer.wantsLayer = YES;
        
        self.progressContainer.layer.cornerRadius = 6;
        
        
        self.progressContainer.layer.backgroundColor = NSColorFromRGB(0x000000).CGColor;
        self.progressContainer.layer.opacity = 0.8;
        
        [self.progressContainer setCenterByView:self];
        
        
        [self addSubview:self.progressContainer];
        
        self.progressIndicator = [[ITProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
        
        
        self.progressIndicator.color = [NSColor whiteColor];
        
        [self.progressIndicator setIndeterminate:YES];
        
        self.progressIndicator.lengthOfLine = 8;
        self.progressIndicator.numberOfLines = 10;
        self.progressIndicator.innerMargin = 5;
        self.progressIndicator.widthOfLine = 3;

        
        [self.progressIndicator setCenterByView:self];
        
        [self addSubview:self.progressIndicator];
        
        [self addSubview:_successImageView];
        
        _successImageView.autoresizingMask = self.progressIndicator.autoresizingMask = self.progressContainer.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
        
        
        [self progressAction];

    }
    return self;
}


-(void)successAction {
    [_progressIndicator setHidden:YES];
    [_successImageView setHidden:NO];
}

-(void)progressAction {
    [_progressIndicator setHidden:NO];
    [_successImageView setHidden:YES];
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}

-(void)scrollWheel:(NSEvent *)theEvent {
    
}

-(void)mouseEntered:(NSEvent *)theEvent {
    
}

-(void)mouseExited:(NSEvent *)theEvent {
    
}

-(void)mouseMoved:(NSEvent *)theEvent {
    
}

-(void)keyDown:(NSEvent *)theEvent {
    
}

-(void)keyUp:(NSEvent *)theEvent {
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}



@end
