//
//  TGWebpageContainer.m
//  Telegram
//
//  Created by keepcoder on 01.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageContainer.h"
#import "TGCTextView.h"
@interface TGWebpageContainer ()
@property (nonatomic,strong,readonly) TMView *containerView;
@end

@implementation TGWebpageContainer

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
    [LINK_COLOR setFill];
    
    NSRectFill(NSMakeRect(0, 0, 2, NSHeight(self.frame)));
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}



-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _containerView = [[TMView alloc] initWithFrame:self.bounds];
        [_containerView setIsFlipped:YES];
        
        _containerView.wantsLayer = YES;
        
        [super addSubview:_containerView];
        
        
        _imageView = [[TGImageView alloc] initWithFrame:NSZeroRect];
        
        _imageView.cornerRadius = 4;
        
        [self addSubview:_imageView];
        
        _loaderView = [[TMLoaderView alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
        
        [_loaderView setStyle:TMCircularProgressDarkStyle];
        
        
        [_imageView addSubview:_loaderView];
        
        
        _descriptionField = [[TGCTextView alloc] initWithFrame:NSZeroRect];
        
        
        [self addSubview:_descriptionField];
        
        [_descriptionField setEditable:YES];
        
        
        self.author = [TMTextField defaultTextField];
        self.date = [TMTextField defaultTextField];
        
        [self.author setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:12]];
        
        
        [self addSubview:self.author];
        [self addSubview:self.date];
    }
    
    return self;
}


-(void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    [_containerView setFrame:NSMakeRect(7,0,NSWidth(frame) - 7,NSHeight(frame))];
}

-(void)addSubview:(NSView *)aView {
    [_containerView addSubview:aView];
}

-(void)setWebpage:(TGWebpageObject *)webpage {
    _webpage = webpage;
    
    [webpage.imageObject.supportDownloadListener setProgressHandler:^(DownloadItem *item) {
        
        [ASQueue dispatchOnMainQueue:^{
            
             [self.loaderView setProgress:item.progress animated:YES];
            
        }];
        
    }];
    
    [webpage.imageObject.supportDownloadListener setCompleteHandler:^(DownloadItem *item) {
        
        [ASQueue dispatchOnMainQueue:^{
            
            [self updateState:0];
            
        }];
        
    }];
    
}

-(BOOL)isFlipped {
    return YES;
}

-(void)updateState:(TMLoaderViewState)state {
    
    [self.loaderView setHidden:self.item.isset];
    
    [self.loaderView setState:state];
    
    [self.loaderView setProgress:self.webpage.imageObject.downloadItem.progress animated:NO];
    
    [self.loaderView setProgress:self.loaderView.currentProgress animated:YES];
    
    [self.loaderView setCenterByView:_imageView];

}

-(NSSize)containerSize {
    return _containerView.frame.size;
}

@end


/*
 -(void)initWebPageContainerView {
 
 
 if(_webPageContainerView == nil) {
 
 MessageTableItemText *item = (MessageTableItemText *)[self item];
 
 _webPageContainerView = [[TMView alloc] initWithFrame:NSMakeRect(0, item.textSize.height + 5, item.webpage.size.width, item.webpage.size.height)];
 
 _webPageContainerView.wantsLayer = YES;
 
 _webPageContainerView.layer.cornerRadius = 4;
 
 
 {
 _webPageImageView = [[TGImageView alloc] initWithFrame:NSZeroRect];
 
 
 [_webPageContainerView addSubview:_webPageImageView];
 
 
 
 _webPageTitleView = [TMTextField defaultTextField];
 _webPageDescView = [TMTextField defaultTextField];
 
 
 _webPageMarkView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(_webPageContainerView.frame), 40)];
 
 _webPageMarkView.backgroundColor = NSColorFromRGBWithAlpha(0x000000, 0.6);
 
 
 
 [_webPageContainerView addSubview:_webPageMarkView];
 
 [_webPageContainerView addSubview:_webPageTitleView];
 [_webPageContainerView addSubview:_webPageDescView];
 
 [_webPageTitleView setFrameOrigin:NSMakePoint(5, 20)];
 [_webPageDescView setFrameOrigin:NSMakePoint(5, 0)];
 
 
 [self setProgressToView:_webPageContainerView];
 
 [self.progressView setStyle:TMCircularProgressDarkStyle];
 
 }
 
 
 [_webPageContainerView setBackgroundColor:[NSColor grayColor]];
 
 
 [self.containerView addSubview:_webPageContainerView];
 
 }
 
 }
*/