//
//  MessageTableCellAudioView.h
//  Messenger for Telegram
//
//  Created by keepcoder on 24.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTablecellAudioDocumentView.h"
#import <Quartz/Quartz.h>
#import "TMMediaController.h"
#import "TLPeer+Extensions.h"
#import "TMPreviewDocumentItem.h"
#import "TMCircularProgress.h"
#import "MessageTableItemAudio.h"

#import "TGTimer.h"
#import "NSStringCategory.h"
#import "TGAudioPlayerWindow.h"
#import "TGCTextView.h"

@interface MessageTablecellAudioDocumentView()<TGAudioPlayerWindowDelegate>
@property (nonatomic,assign) TGAudioPlayerState audioState;
@property (nonatomic,strong) BTRButton *playView;
@property (nonatomic,strong) TGCTextView *nameView;
@end

@implementation MessageTablecellAudioDocumentView


+ (void)stop {
    [globalAudioPlayer() stop];
    [globalAudioPlayer().delegate audioPlayerDidFinishPlaying:globalAudioPlayer()];
}



- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        weak();
        
        self.playView = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, blue_circle_background_image().size.width, blue_circle_background_image().size.height)];
        
        [self.playView addBlock:^(BTRControlEvents events) {
            
            if(weakSelf.item.isset) {
                [TGAudioPlayerWindow show:weakSelf.item.message.conversation];
                [TGAudioPlayerWindow setCurrentItem:(MessageTableItemAudioDocument *)weakSelf.item];

            } else {
                [weakSelf checkOperation];
            }
              
        } forControlEvents:BTRControlEventClick];
        [_playView setBackgroundImage:blue_circle_background_image() forControlState:BTRControlStateNormal];

        [self.containerView addSubview:_playView];
    
        _nameView = [[TGCTextView alloc] initWithFrame:NSZeroRect];
        
         [self.containerView addSubview:_nameView];
        
        [self.progressView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
        
        [self.progressView setFrameSize:NSMakeSize(NSWidth(_playView.frame) - 4, NSWidth(_playView.frame) - 4)];
        
        [self setProgressStyle:TMCircularProgressLightStyle];
        [self.progressView setProgressColor:[NSColor whiteColor]];
        [self setProgressToView:_playView];
        
        [TGAudioPlayerWindow addEventListener:self];
        
    }
    return self;
}

-(void)dealloc {
    [TGAudioPlayerWindow removeEventListener:self];
}

-(void)playerDidChangedState:(MessageTableItemAudioDocument *)item playerState:(TGAudioPlayerState)state {
    
    if(item.message.n_id != self.item.message.n_id)
    {
        self.audioState = TGAudioPlayerStatePaused;
    } else {
        self.audioState = state;
    }

}

-(void)setAudioState:(TGAudioPlayerState)audioState {
    _audioState = audioState;
    
    [self updateCellState:NO];
}


-(void)drawRect:(NSRect)dirtyRect {
    
}

- (void)setCellState:(CellState)cellState animated:(BOOL)animated  {
    [super setCellState:cellState animated:animated];
    
    

    
    switch (self.audioState) {
        case TGAudioPlayerStatePaused:
            [_playView setImage:play_image() forControlState:BTRControlStateNormal];
            break;
            
        case TGAudioPlayerStatePlaying:
            [_playView setImage:image_DownloadPauseIconWhite() forControlState:BTRControlStateNormal];
            break;
        case TGAudioPlayerStateForcePaused: default :
            [_playView setImage:play_image() forControlState:BTRControlStateNormal];
            break;
    }
    
    if(self.cellState == CellStateDownloading || self.cellState == CellStateNeedDownload || self.cellState == CellStateDownloading || self.item.messageSender != nil)
    {
        [_playView setImage:nil forControlState:BTRControlStateNormal];
    }
    
    [self setNeedsDisplay:YES];
    
}


- (void)updateCellState:(BOOL)animated {
    MessageTableItemAudio *item = (MessageTableItemAudio *)self.item;
    
    if(item.messageSender) {
        [self setCellState:CellStateSending animated:animated];
        return;
    }
    
    if(item.downloadItem && item.downloadItem.downloadState != DownloadStateCompleted && item.downloadItem.downloadState != DownloadStateWaitingStart) {
        [self setCellState:item.downloadItem.downloadState == DownloadStateCanceled ? CellStateCancelled : CellStateDownloading animated:YES];
    } else  if(![self.item isset]) {
        [self setCellState:CellStateNeedDownload animated:animated];
    } else {
        [self setCellState:CellStateNormal animated:animated];
    }
}


- (NSMenu *)contextMenu {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Documents menu"];
    
    weak();
    
    MessageTableItemAudioDocument *item = (MessageTableItemAudioDocument *)self.item;
    
    if([self.item isset]) {
        
        if(![self.item.message isKindOfClass:[TL_destructMessage class]]) {
            [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Message.File.ShowInFinder", nil) withBlock:^(id sender) {
                [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:item.path]]];
            }]];
        }
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.SaveAs", nil) withBlock:^(id sender) {
            [weakSelf performSelector:@selector(saveAs:) withObject:weakSelf];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.CopyToClipBoard", nil) withBlock:^(id sender) {
            [weakSelf performSelector:@selector(copy:) withObject:weakSelf];
        }]];
        
        
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
   [self.defaultMenuItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [menu addItem:item];
    }];
    
    
    return menu;
}


- (void)setItem:(MessageTableItemAudioDocument *)item {
    [super setItem:item];
    
    if([TGAudioPlayerWindow currentItem].message.n_id == item.message.n_id)
        _audioState = [TGAudioPlayerWindow playerState];
     else
        _audioState = TGAudioPlayerStatePaused;
    
    [_nameView setAttributedString:item.nameAttributedString];
    [_nameView setFrame:NSMakeRect(NSMaxX(_playView.frame) + item.defaultOffset, 0, item.nameSize.width, item.nameSize.height)];
    [_nameView setCenteredYByView:_nameView.superview];
    
    [self updateDownloadState];
    
    
    [self updateCellState:NO];
    
    
}


@end
