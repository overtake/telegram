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

@property (nonatomic,strong) NSString *n_description;

@property (nonatomic,strong) TMTextField *textField;


@end

@implementation TMProgressModalView

-(void)setDescription:(NSString *)description {
    _n_description = description;
    
    [self update];
}

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
        
        
        self.textField = [TMTextField defaultTextField];
        
        [self addSubview:self.textField];
        [_textField setHidden:YES];
        
        [self progressAction];
        
        

    }
    return self;
}

-(void)update {
    
    [_textField setHidden:_n_description.length == 0];
    
    if(_n_description.length > 0) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:_n_description withColor:[NSColor whiteColor]];
        [attr setFont:TGSystemFont(13) forRange:attr.range];
        [attr setAlignment:NSCenterTextAlignment range:attr.range];
        
        NSSize size = [attr sizeForTextFieldForWidth:300];
        
        [_textField setAttributedStringValue:attr];
        
        [_textField setFrameSize:size];
        
        [_progressContainer setFrameSize:NSMakeSize(MAX(size.width + 20,80), MAX(size.height + 60,80))];
        
        
        
        [_progressContainer setCenterByView:_progressContainer.superview];
        
        
        [_progressIndicator setCenteredXByView:_progressIndicator.superview];
        
        
        
        
        [_textField setCenteredXByView:_textField.superview];
        [_textField setFrameOrigin:NSMakePoint(NSMinX(_textField.frame), NSMinY(_progressContainer.frame) + 10)];
        
        
        [_progressIndicator setFrameOrigin:NSMakePoint(NSMinX(_progressIndicator.frame), NSMaxY(_textField.frame) + 10)];
        
        [_successImageView setFrameOrigin:NSMakePoint(NSMinX(_successImageView.frame), NSMaxY(_textField.frame) + 5)];

    } else {
        [_progressContainer setFrameSize:NSMakeSize(80, 80)];
        [_progressIndicator setCenterByView:_progressIndicator.superview];
    }
    
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
