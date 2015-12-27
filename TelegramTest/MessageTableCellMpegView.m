//
//  MessageTableCellMpegView.m
//  Telegram
//
//  Created by keepcoder on 10/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "MessageTableCellMpegView.h"
#import "MessageTableItemMpeg.h"
#import "TGVTVideoView.h"
#import "TGVTVideoView.h"
#import "TGImageView.h"
#import "SpacemanBlocks.h"
@interface MessageTableCellMpegView () {
    SMDelayedBlockHandle _handle;
    BOOL _prevState;
}
@property (nonatomic,strong) TGVTVideoView *player;

@property (nonatomic,strong) TMView *playerContainer;

@end

@implementation MessageTableCellMpegView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _playerContainer = [[TMView alloc] initWithFrame:NSZeroRect];
        
        _playerContainer.wantsLayer = YES;
        _playerContainer.layer.cornerRadius = 4;
        
        [self.containerView addSubview:_playerContainer];
        
        _player = [[TGVTVideoView alloc] initWithFrame:NSMakeRect(0, 0, 500, 280)];
        
        [_playerContainer addSubview:_player];
        
        
        
        [self setProgressStyle:TMCircularProgressDarkStyle];
        [self.progressView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
        
        
        [self setProgressToView:_playerContainer];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setCellState:(CellState)cellState {
    
    if(self.cellState == CellStateSending && cellState == CellStateNormal) {
        [super setCellState:cellState];
        
        if(!self.item.isset) {
            [self.item checkStartDownload:0 size:0];
            if(self.item.downloadItem != nil) {
                [self updateDownloadState];
            }
        }
    } else if(self.cellState == CellStateDownloading && cellState == CellStateNormal) {
        if(self.item.isset) {
            [self.item doAfterDownload];
            [self doAfterDownload];
        }
    }
    
    [super setCellState:cellState];
    [self.progressView setState:cellState];
    
    [self _didScrolledTableView:nil];
    
}

-(void)doAfterDownload {
    [super doAfterDownload];
    
    MessageTableItemMpeg *item = (MessageTableItemMpeg *) self.item;
        
    _prevState = NO;
    
    _player.imageObject = item.thumbObject;
    
    [self _didScrolledTableView:nil];
}



-(void)setItem:(MessageTableItemMpeg *)item {
    [super setItem:item];
    
    _prevState = NO;
    
    [_playerContainer setFrameSize:item.blockSize];
    [_player setFrameSize:item.blockSize];
    
    [self.progressView setCenterByView:self.progressView.superview];
    
    
    [_player setImageObject:item.thumbObject];

    [self updateDownloadState];
    
}

-(void)_didScrolledTableView:(NSNotification *)notification {

    
     MessageTableItemMpeg *item = (MessageTableItemMpeg *) self.item;
    
    BOOL (^check_block)() = ^BOOL() {
        
        BOOL completelyVisible = self.visibleRect.size.width > 0 && self.visibleRect.size.height > 0 && ![TMViewController isModalActive];
        
        return  completelyVisible && ((self.window != nil && self.window.isKeyWindow) || notification == nil) && item.isset;
        
    };
    
    cancel_delayed_block(_handle);
    
    dispatch_block_t block = ^{
        BOOL nextState = check_block();
        
        if(_prevState != nextState) {
            [_player setPath:nextState ? item.path : nil];
        }
        
        _prevState = nextState;
    };
    
    
    
    if(check_block()) {
        _handle = perform_block_after_delay(0.05, block);
    } else {
        block();
    }

    
}



-(void)viewDidMoveToWindow {
    if(self.window == nil) {
        
        [self removeScrollEvent];
        [_player setPath:nil];
        
    } else {
        [self addScrollEvent];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didScrolledTableView:) name:NSWindowDidBecomeKeyNotification object:self.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didScrolledTableView:) name:NSWindowDidResignKeyNotification object:self.window];
    }
}

@end
