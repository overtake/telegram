//
//  TGWebpageGifContainer.m
//  Telegram
//
//  Created by keepcoder on 20.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageGifContainer.h"
#import "TGWebpageGifObject.h"
#import "TGVTVideoView.h"
#import "SpacemanBlocks.h"
@interface TGWebpageGifContainer () {
    BOOL _prevState;
    SMDelayedBlockHandle _handle;
}
@property (nonatomic,strong) TGVTVideoView *player;
@property (nonatomic,strong) TMView *playerContainer;
@property (nonatomic,strong) NSImageView *playImageView;
@end

@implementation TGWebpageGifContainer

@synthesize loaderView = _loaderView;


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _playImageView = imageViewWithImage(image_PlayButtonBig());
        _playerContainer = [[TMView alloc] initWithFrame:NSZeroRect];
        [_playerContainer addSubview:_playImageView];
        
        _playerContainer = [[TMView alloc] initWithFrame:NSZeroRect];
        [_playerContainer setWantsLayer:YES];
        
        _playerContainer.layer.cornerRadius = 4;
        
        _player = [[TGVTVideoView alloc] initWithFrame:NSZeroRect];
        
        [_playerContainer addSubview:_player];
        
        [self addSubview:_playerContainer];
        
    }
    
    return self;
}

-(void)setWebpage:(TGWebpageGifObject *)webpage {
    
    _prevState = NO;
    [self.imageView setHidden:YES];
    
    [self.player setPath:nil];
    
    [super setWebpage:webpage];
    
    
    
    [self.siteName setHidden:YES];
    
    [self.imageView setFrame:NSMakeRect(0, webpage.size.height - webpage.imageSize.height, webpage.imageSize.width, webpage.imageSize.height)];
    
    [self.playerContainer setFrame:NSMakeRect(0, webpage.size.height - webpage.imageSize.height, webpage.imageSize.width, webpage.imageSize.height)];
    [self.player setFrameSize:self.playerContainer.frame.size];
        
    [self.player setImageObject:webpage.imageObject];
    
    [self.imageView removeFromSuperview];
    
    [self.player addSubview:self.imageView];
    
    [self.imageView setHidden:NO];
    
    [_playImageView removeFromSuperview];
    [_playerContainer addSubview:_playImageView];
    
    [_playImageView setHidden:![SettingsArchiver checkMaskedSetting:DisableAutoplayGifSetting]];
    if(!_playImageView.isHidden)
        [_playImageView setCenterByView:_playImageView.superview];
    
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

-(void)showPhoto {
    TGWebpageGifObject *item = (TGWebpageGifObject *)self.webpage;
    
    if(item.isset && [SettingsArchiver checkMaskedSetting:DisableAutoplayGifSetting]) {
        
        [_player setPath:_playImageView.isHidden ? nil : item.path];
        [_playImageView setHidden:!_playImageView.isHidden];
    } else {
        [super showPhoto];
    }
}



-(void)updateDownloadState {
    
    weak();
    
    TGWebpageGifObject *item = (TGWebpageGifObject *)self.webpage;
    
    [self.playImageView setHidden:![SettingsArchiver checkMaskedSetting:DisableAutoplayGifSetting] || item.downloadItem != nil];
    
    if(item.downloadItem) {
        
        [item.downloadListener setCompleteHandler:^(DownloadItem * item) {
            
            __strong TGWebpageGifContainer *strongSelf = weakSelf;
            
            [ASQueue dispatchOnMainQueue:^{
                
                [strongSelf downloadProgressHandler:item];
                
                dispatch_after_seconds(0.2, ^{
                    strongSelf.item.downloadItem = nil;
                    strongSelf->_prevState = NO;
                    
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
    
     TGWebpageGifObject *webpage = (TGWebpageGifObject *)self.webpage;

    
    BOOL (^check_block)() = ^BOOL() {
        
        BOOL completelyVisible = self.visibleRect.size.width > 0 && self.visibleRect.size.height > 0 && ![TMViewController isModalActive];
        
        return  ![SettingsArchiver checkMaskedSetting:DisableAutoplayGifSetting] && completelyVisible && ((self.window != nil && self.window.isKeyWindow) || notification == nil) && webpage.isset && ![self inLiveResize];
        
    };
    
    cancel_delayed_block(_handle);
    
    dispatch_block_t block = ^{
        BOOL nextState = check_block();
        
        if(_prevState != nextState) {
            [_player setPath:nextState ? webpage.path : nil];
        }
        
        _prevState = nextState;
    };
    
    if(!check_block())
        block();
    else
        _handle = perform_block_after_delay(0.03, block);

    
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidMoveToWindow {
    if(self.window == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
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
