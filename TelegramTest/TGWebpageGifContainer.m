//
//  TGWebpageGifContainer.m
//  Telegram
//
//  Created by keepcoder on 20.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageGifContainer.h"
#import "TGWebpageGifObject.h"
#import "TGModernAnimatedImagePlayer.h"
#import "TGGLVideoPlayer.h"
@interface TGWebpageGifContainer ()
@property (nonatomic,strong) TGGLVideoPlayer *player;
@property (nonatomic,strong) TMView *playerContainer;
@end

@implementation TGWebpageGifContainer

@synthesize loaderView = _loaderView;


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _playerContainer = [[TMView alloc] initWithFrame:NSZeroRect];
        [_playerContainer setWantsLayer:YES];
        
        _playerContainer.layer.cornerRadius = 4;
        
        _player = [[TGGLVideoPlayer alloc] initWithFrame:NSZeroRect];
        
        [_playerContainer addSubview:_player];
        
        [self addSubview:_playerContainer];
        
    }
    
    return self;
}

-(void)setWebpage:(TGWebpageGifObject *)webpage {
    
    [super setWebpage:webpage];
    
    [webpage.imageObject.downloadItem removeEvent:webpage.imageObject.supportDownloadListener];
    
    
    [self.descriptionField setFrame:NSMakeRect([self textX], 0, webpage.descSize.width , webpage.descSize.height )];
    
    [self.descriptionField setAttributedString:webpage.desc];
    
    
    [self.imageView setFrame:NSMakeRect(0, webpage.size.height - webpage.imageSize.height, webpage.imageSize.width, webpage.imageSize.height)];
    
    [self.playerContainer setFrame:NSMakeRect(0, webpage.size.height - webpage.imageSize.height, webpage.imageSize.width, webpage.imageSize.height)];
    [self.player setFrameSize:self.playerContainer.frame.size];
    
    [self.player setPath:webpage.path];
    
    [self.imageView removeFromSuperview];
    
    [self.player addSubview:self.imageView];
    
    
    [self.imageView setHidden:NO];
    
    [self updateDownloadState];
    
    if(![webpage isset]) {
        [self startDownload:NO];
    }
    
    [self _didScrolledTableView:nil];
}


- (void)startDownload:(BOOL)cancel {
    
    TGWebpageGifObject *item = (TGWebpageGifObject *)self.webpage;
    
    [item startDownload:cancel force:YES];
    
    [self updateDownloadState];
}


-(void)updateDownloadState {
    
    weak();
    
    TGWebpageGifObject *item = (TGWebpageGifObject *)self.webpage;
    
    if(item.downloadItem) {
        
        
        [item.downloadListener setCompleteHandler:^(DownloadItem * item) {
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                
                [weakSelf downloadProgressHandler:item];
                
                dispatch_after_seconds(0.2, ^{
                    weakSelf.item.downloadItem = nil;
                    [self updateState:0];
                });
            }];
            
        }];
        
        [item.downloadListener setProgressHandler:^(DownloadItem * item) {
            
            [ASQueue dispatchOnMainQueue:^{
                [weakSelf downloadProgressHandler:item];
            }];
        }];
        
        [self updateState:TMLoaderViewStateDownloading];
        
    }
    
}

-(void)updateState:(TMLoaderViewState)state {
    
    TGWebpageGifObject *item = (TGWebpageGifObject *)self.webpage;
    
    
    if(!item.isset && item.downloadItem && item.downloadItem.downloadState != DownloadStateCompleted) {
        [self.loaderView removeFromSuperview];
        
        _loaderView = [[TMLoaderView alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
        
        [self.loaderView setStyle:TMCircularProgressDarkStyle];
        
        
        [self.imageView addSubview:self.loaderView];
        [self.loaderView setCenterByView:self.imageView];
        
        [self.loaderView setState:state];
        
        [self.loaderView setProgress:item.downloadItem.progress animated:NO];
        
        if(self.loaderView.currentProgress > 0) {
            [self.loaderView setProgress:self.loaderView.currentProgress animated:YES];
        }
        
        
        
    } else  {
        [self.loaderView removeFromSuperview];
        
        if(self.loaderView.state != 0 && state == 0) {
            
            [self.webpage doAfterDownload];
            [self _didScrolledTableView:nil];
        }
    }
    
}

-(void)downloadProgressHandler:(DownloadItem *)item {
    [self.loaderView setProgress:item.progress animated:YES];
}

-(void)_didScrolledTableView:(NSNotification *)notification {
    
    NSRange visibleRange = [self.item.table rowsInRect:self.item.table.visibleRect];
    
    if(visibleRange.location > 0) {
        visibleRange.location--;
        visibleRange.length++;
    }
    
    NSUInteger idx = [self.item.table indexOfItem:self.item];
    
    TGWebpageGifObject *webpage = (TGWebpageGifObject *)self.webpage;

    
    if(idx > visibleRange.location && idx <= visibleRange.location + visibleRange.length && ((self.window != nil && self.window.isKeyWindow) || notification == nil) && webpage.isset) {
        [_player resume];
    } else {
        [_player pause];
    }
    
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidMoveToWindow {
    if(self.window == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [_player pause];
        [_player setPath:nil];
        
    } else {
        id clipView = [[self.item.table enclosingScrollView] contentView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_didScrolledTableView:)
                                                     name:NSViewBoundsDidChangeNotification
                                                   object:clipView];        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didScrolledTableView:) name:NSWindowDidBecomeKeyNotification object:self.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didScrolledTableView:) name:NSWindowDidResignKeyNotification object:self.window];
    }
}


@end
