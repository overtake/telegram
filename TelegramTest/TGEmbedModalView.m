//
//  TGEmbedModalView.m
//  Telegram
//
//  Created by keepcoder on 30.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGEmbedModalView.h"
#import <WebKit/WebKit.h>
@interface TGEmbedModalView () <WebFrameLoadDelegate>
@property (nonatomic,strong) WebView *webView;
@property (nonatomic,strong) TLWebPage *webpage;
@property (nonatomic,strong) NSProgressIndicator *progress;
@end

@implementation TGEmbedModalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _progress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
        
        [_progress setStyle:NSProgressIndicatorSpinningStyle];
        
        [self addSubview:_progress];
        
        
        
        _webView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
        
        _webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        
        [self addSubview:_webView];
        
        _webView.frameLoadDelegate = self;
        
        [self setContainerFrameSize:NSMakeSize(300, 300)];
    }
    
    return self;
}

-(void)setWebpage:(TLWebPage *)webpage {
    
    _webpage = webpage;
    
    [_progress setHidden:NO];
    [_progress startAnimation:self];
    [_webView setHidden:YES];
    
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:webpage.embed_url]]];
    
}

-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    [_progress setHidden:YES];
    [_progress stopAnimation:self];
    [_webView setHidden:NO];
}

-(void)dealloc {
    _webView.frameLoadDelegate = nil;
}


-(void)modalViewDidHide {
    _webpage = nil;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    NSSize embedSize = NSMakeSize(_webpage.embed_width, _webpage.embed_height);
    
    embedSize = strongsize(embedSize, MIN(newSize.width,newSize.height) - 10);
    
    [self setContainerFrameSize:embedSize];
    
}

-(void)setContainerFrameSize:(NSSize)size {
    [super setContainerFrameSize:size];
    
    [_webView setFrame:NSMakeRect(3, 3, self.containerSize.width - 6, self.containerSize.height - 6)];
    
    [_progress setCenterByView:_progress.superview];

    
}

@end
