//
//  MessageTableCellMpegView.m
//  Telegram
//
//  Created by keepcoder on 10/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "MessageTableCellMpegView.h"
#import "MessageTableItemMpeg.h"
#import "TGGLVideoPlayer.h"
#import "TGImageView.h"
@interface MessageTableCellMpegView ()
@property (nonatomic,strong) TGGLVideoPlayer *player;

@property (nonatomic,strong) TGImageView *thumbImage;

@property (nonatomic,strong) TMView *playerContainer;
@end

@implementation MessageTableCellMpegView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _playerContainer = [[TMView alloc] initWithFrame:NSZeroRect];
        
        _playerContainer.wantsLayer = YES;
        _playerContainer.layer.cornerRadius = 4;
        
        [self.containerView addSubview:_playerContainer];
        
        _player = [[TGGLVideoPlayer alloc] initWithFrame:NSMakeRect(0, 0, 500, 280)];
        
        [_playerContainer addSubview:_player];
        
                
        _thumbImage = [[TGImageView alloc] init];
        
        [_player addSubview:_thumbImage];
        
        
        [self setProgressStyle:TMCircularProgressDarkStyle];
        [self.progressView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
        
        
        [self setProgressToView:_player];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setCellState:(CellState)cellState {
    
    [_thumbImage setHidden:NO];
    
    if(self.cellState == CellStateSending && cellState == CellStateNormal) {
        [super setCellState:cellState];
        
        if(!self.item.isset) {
            [self.item checkStartDownload:0 size:0];
            if(self.item.downloadItem != nil) {
                [self updateDownloadState];
            }
        } else {
            [self.item doAfterDownload];
            [self doAfterDownload];

        }
    }
    
    [super setCellState:cellState];
    [self.progressView setState:cellState];
    
}

-(void)doAfterDownload {
    [super doAfterDownload];
    
    MessageTableItemMpeg *item = (MessageTableItemMpeg *) self.item;
    
    _thumbImage.object = item.thumbObject;
    
    [_player setPath:item.path];
    
    [self _didScrolledTableView:nil];
}



-(void)setItem:(MessageTableItemMpeg *)item {
    [super setItem:item];
    
    [_playerContainer setFrameSize:item.blockSize];
    [_player setFrameSize:item.blockSize];
    
    
    [_player setPath:item.path];
    
    [_thumbImage setObject:item.thumbObject];
    [_thumbImage setFrameSize:item.blockSize];

    [self updateDownloadState];
    
    [self _didScrolledTableView:nil];
}

-(void)_didScrolledTableView:(NSNotification *)notification {
    
    NSRange visibleRange = [self.messagesViewController.table rowsInRect:self.messagesViewController.table.visibleRect];
    
    if(visibleRange.location > 0) {
        visibleRange.location--;
        visibleRange.length++;
    }
    
    NSUInteger idx = [self.messagesViewController.table indexOfItem:self.item];
    
    if(idx > visibleRange.location && idx <= visibleRange.location + visibleRange.length && ((self.window != nil && self.window.isKeyWindow) || notification == nil) && self.item.isset) {
        [_player resume];
    } else {
        [_player pause];
    }
    
}



-(void)viewDidMoveToWindow {
    if(self.window == nil) {
        
        [self removeScrollEvent];
        [_player pause];
        [_player setPath:nil];
        
    } else {
        [self addScrollEvent];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didScrolledTableView:) name:NSWindowDidBecomeKeyNotification object:self.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didScrolledTableView:) name:NSWindowDidResignKeyNotification object:self.window];
    }
}

@end
