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
#import "SpacemanBlocks.h"
@interface MessageTableCellMpegView () {
    SMDelayedBlockHandle _handle;
}
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
    
    [self _didScrolledTableView:nil];
    
}

-(void)doAfterDownload {
    [super doAfterDownload];
    
    MessageTableItemMpeg *item = (MessageTableItemMpeg *) self.item;
    
    _thumbImage.object = item.thumbObject;
    
    [_player setPath:item.path];
    
    [_player pause];
    
    [self _didScrolledTableView:nil];
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
    
}

-(void)_didScrolledTableView:(NSNotification *)notification {

    
     MessageTableItemMpeg *item = (MessageTableItemMpeg *) self.item;
    
    BOOL (^check_block)() = ^BOOL() {
        
        NSRange visibleRange = [self.messagesViewController.table rowsInRect:self.messagesViewController.table.visibleRect];
        
        if(visibleRange.location > 0) {
            visibleRange.location--;
            visibleRange.length++;
        }
        
        NSUInteger idx = [self.messagesViewController.table indexOfItem:self.item];
        
        return  idx > visibleRange.location && idx <= visibleRange.location + visibleRange.length && ((self.window != nil && self.window.isKeyWindow) || notification == nil) && self.item.isset;
        
    };
    
    if(check_block() && [[NSFileManager defaultManager] fileExistsAtPath:item.path isDirectory:NO]) {
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
