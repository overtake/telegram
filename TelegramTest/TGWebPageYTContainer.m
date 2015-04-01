//
//  TGWebPageYTContainer.m
//  Telegram
//
//  Created by keepcoder on 01.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageYTContainer.h"

@implementation TGWebpageYTContainer





-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
//        if(_webPageContainerView == nil) {
//            
//            MessageTableItemText *item = (MessageTableItemText *)[self item];
//            
//            _webPageContainerView = [[TMView alloc] initWithFrame:NSMakeRect(0, item.textSize.height + 5, item.webpage.size.width, item.webpage.size.height)];
//            
//            _webPageContainerView.wantsLayer = YES;
//            
//            _webPageContainerView.layer.cornerRadius = 4;
//            
//            
//            {
//                _webPageImageView = [[TGImageView alloc] initWithFrame:NSZeroRect];
//                
//                
//                [_webPageContainerView addSubview:_webPageImageView];
//                
//                
//                
//                _webPageTitleView = [TMTextField defaultTextField];
//                _webPageDescView = [TMTextField defaultTextField];
//                
//                
//                _webPageMarkView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(_webPageContainerView.frame), 40)];
//                
//                _webPageMarkView.backgroundColor = NSColorFromRGBWithAlpha(0x000000, 0.6);
//                
//                
//                
//                [_webPageContainerView addSubview:_webPageMarkView];
//                
//                [_webPageContainerView addSubview:_webPageTitleView];
//                [_webPageContainerView addSubview:_webPageDescView];
//                
//                [_webPageTitleView setFrameOrigin:NSMakePoint(5, 20)];
//                [_webPageDescView setFrameOrigin:NSMakePoint(5, 0)];
//                
//                
//                [self setProgressToView:_webPageContainerView];
//                
//                [self.progressView setStyle:TMCircularProgressDarkStyle];
//                
//            }
//            
//            
//            [_webPageContainerView setBackgroundColor:[NSColor grayColor]];
//            
//            
//            [self.containerView addSubview:_webPageContainerView];
//            
//        }
    }
    
    return self;
}



- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

@end
