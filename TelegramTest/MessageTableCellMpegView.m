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
@property (nonatomic,strong) NSImageView *playImageView;

@end

@implementation MessageTableCellMpegView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _playImageView = imageViewWithImage(image_PlayButtonBig());
        _playerContainer = [[TMView alloc] initWithFrame:NSZeroRect];
        
        
        _playerContainer.wantsLayer = YES;
        _playerContainer.layer.cornerRadius = 4;
        
        [self.containerView addSubview:_playerContainer];
        
        _player = [[TGVTVideoView alloc] initWithFrame:NSMakeRect(0, 0, 500, 280)];
        
        [_playerContainer addSubview:_player];
        [_playerContainer addSubview:_playImageView];
        
        
        [self setProgressStyle:TMCircularProgressDarkStyle];
        [self.progressView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
        
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setCellState:(CellState)cellState animated:(BOOL)animated {
    
    if(self.cellState == CellStateSending && cellState == CellStateNormal) {
        [super setCellState:cellState animated:animated];
        
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
    
    [super setCellState:cellState animated:animated];
    
    [_playImageView setHidden:![SettingsArchiver checkMaskedSetting:DisableAutoplayGifSetting] || cellState != CellStateNormal];
    
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
    [_player setPath:nil];
    
    [_playerContainer setFrameSize:item.imageSize];
    [_player setFrameSize:item.imageSize];
    
    [_player setImageObject:item.thumbObject];
    
    [self setProgressToView:_playerContainer];
    
    [_playImageView removeFromSuperview];
    [self.playerContainer addSubview:_playImageView];
    
    
    [_playImageView setCenterByView:_playImageView.superview];

    [self updateDownloadState];
    
}

-(NSMenu *)contextMenu {
    
     MessageTableItemMpeg *item = (MessageTableItemMpeg *) self.item;
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Gifs"];
    
    
    if(item.isset) {
        
        __block NSMutableArray *items;
        
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
            items = [transaction objectForKey:@"gifs" inCollection:RECENT_GIFS];
        }];
        
        TLDocument *document = self.item.message.media.document;
        
        TLDocument *item = [[items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",document.n_id]] firstObject];
        
        
        [menu addItem:[NSMenuItem menuItemWithTitle:item == nil ? NSLocalizedString(@"Context.AddGif", nil) : NSLocalizedString(@"Context.RemoveGif", nil) withBlock:^(id sender) {
            
            [TMViewController showModalProgress];
            
            [RPCRequest sendRequest:[TLAPI_messages_saveGif createWithN_id:[TL_inputDocument createWithN_id:self.item.message.media.document.n_id access_hash:self.item.message.media.document.access_hash] unsave:item != nil] successHandler:^(id request, id response) {
                
                if([response isKindOfClass:[TL_boolTrue class]]) {
                    [[Storage yap] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
                        
                        NSMutableArray *items = [transaction objectForKey:@"gifs" inCollection:RECENT_GIFS];
                        
                        TLDocument *d = [[items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",document.n_id]] firstObject];
                        
                        if(d != nil)
                            [items removeObject:d];
                        
                        if(item == nil) {
                            [items insertObject:document atIndex:0];
                        }
                        
                        
                        [transaction setObject:items forKey:@"gifs" inCollection:RECENT_GIFS];
                    }];
                }
                
                
                
                [TMViewController hideModalProgressWithSuccess];
                
            } errorHandler:^(id request, RpcError *error) {
                [TMViewController hideModalProgress];
            }];
            
        }]];
        
        [menu addItem:[NSMenuItem separatorItem]];
    }
    

    [self.defaultMenuItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [menu addItem:item];
    }];
    
    return menu;
    
}

-(void)_didScrolledTableView:(NSNotification *)notification {

    MessageTableItemMpeg *item = (MessageTableItemMpeg *) self.item;
    
    BOOL (^check_block)() = ^BOOL() {
        
        BOOL completelyVisible = self.containerView.visibleRect.size.width > 0 && self.containerView.visibleRect.size.height > 0 && ![TMViewController isModalActive];
        
        return ![SettingsArchiver checkMaskedSetting:DisableAutoplayGifSetting] && completelyVisible && ((self.containerView.window != nil && self.containerView.window.isKeyWindow) || notification == nil) && item.isset && ![self.containerView inLiveResize];
        
    };
        
    cancel_delayed_block(_handle);
    
    dispatch_block_t block = ^{
        BOOL nextState = check_block();
        
        if(_prevState != nextState || [SettingsArchiver checkMaskedSetting:DisableAutoplayGifSetting]) {
            [_player setPath:nextState ? item.path : nil];
            
            [_playImageView removeFromSuperview];
            [self.playerContainer addSubview:_playImageView];
            [_playImageView setHidden:nextState || ![SettingsArchiver checkMaskedSetting:DisableAutoplayGifSetting]];
        }
        
        _prevState = nextState;
    };
    
    if(!check_block())
        block();
    else
        _handle = perform_block_after_delay(0.03, block);

}


-(void)mouseUp:(NSEvent *)theEvent {
    MessageTableItemMpeg *item = (MessageTableItemMpeg *) self.item;
    
    if(item.isset && [SettingsArchiver checkMaskedSetting:DisableAutoplayGifSetting]) {
        
        [_player setPath:_playImageView.isHidden ? nil : item.path];
        
        [_playImageView removeFromSuperview];
        [self.playerContainer addSubview:_playImageView];
        [_playImageView setHidden:!_playImageView.isHidden];
    } else {
        [super mouseUp:theEvent];
    }
}


-(void)viewDidMoveToWindow {
    if(self.containerView.window == nil) {
        
        [self removeScrollEvent];
        [_player setPath:nil];
        
    } else {
        [self addScrollEvent];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didScrolledTableView:) name:NSWindowDidBecomeKeyNotification object:self.containerView.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didScrolledTableView:) name:NSWindowDidResignKeyNotification object:self.containerView.window];
        
        [self _didScrolledTableView:nil];
    }
}

@end
