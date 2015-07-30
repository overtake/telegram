//
//  TGEmbedModalView.m
//  Telegram
//
//  Created by keepcoder on 30.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGEmbedModalView.h"
#import <WebKit/WebKit.h>
@interface TGEmbedModalView ()
@property (nonatomic,strong) WebView *webView;
@property (nonatomic,strong) TLWebPage *webpage;
@end

@implementation TGEmbedModalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _webView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
        
        [self addSubview:_webView];
        
        [self setContainerFrameSize:NSMakeSize(300, 300)];
    }
    
    return self;
}

-(void)setWebpage:(TLWebPage *)webpage {
    
    _webpage = webpage;
    
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:webpage.embed_url]]];
    
}


-(void)modalViewDidHide {
    _webpage = nil;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    NSSize embedSize = NSMakeSize(_webpage.embed_width, _webpage.embed_height);
    
    embedSize = strongsize(embedSize, MIN(newSize.width,newSize.height) - 10);
    
    [self setContainerFrameSize:embedSize];
    
    [_webView setFrame:NSMakeRect(3, 3, self.containerSize.width - 6, self.containerSize.height - 6)];
}

@end
