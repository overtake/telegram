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
#import "DownloadAudioItem.h"
#import "TMCircularProgress.h"
#import "MessageTableItemAudio.h"

#import "TGTimer.h"
#import "NSStringCategory.h"
#import "TGAudioPlayerWindow.h"
#define OFFSET 75.0f

@interface MessageTablecellAudioDocumentView()<TGAudioPlayerWindowDelegate>


@property (nonatomic,assign) TGAudioPlayerState audioState;
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
        
        self.playerButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, blueBackground().size.width, blueBackground().size.height)];
        
        [self.playerButton addBlock:^(BTRControlEvents events) {
            
            if(weakSelf.item.isset) {
                [TGAudioPlayerWindow show:weakSelf.item.message.conversation];
                [TGAudioPlayerWindow setCurrentItem:(MessageTableItemAudioDocument *)weakSelf.item];

            } else {
                [weakSelf checkOperation];
            }
              
        } forControlEvents:BTRControlEventClick];
        
        [self.containerView addSubview:self.playerButton];
        
        self.durationView = [[TMTextField alloc] initWithFrame:NSMakeRect(self.playerButton.frame.size.width + 8, NSMinY(self.playerButton.frame) + NSHeight(self.playerButton.frame) - 30, 100, 23)];
        [self.durationView setEnabled:NO];
        [self.durationView setBordered:NO];
        [self.durationView setEditable:NO];
        [self.durationView setDrawsBackground:NO];
        [self.durationView setStringValue:@"00:00 / 00:00"];
        
        [[self.durationView cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.durationView setFont:TGSystemFont(13)];
        [self.durationView sizeToFit];
        [self.durationView setTextColor:DARK_BLACK];
        [self.containerView addSubview:self.durationView];
        
        self.stateTextField = [[TMTextField alloc] initWithFrame:NSZeroRect];
        [self.stateTextField setEnabled:NO];
        [self.stateTextField setBordered:NO];
        [self.stateTextField setEditable:NO];
        [self.stateTextField setDrawsBackground:NO];
        [self.stateTextField setFont:TGSystemFont(12)];
        [self.stateTextField setTextColor:NSColorFromRGB(0xbebebe)];
        
        
        [self.containerView addSubview:self.stateTextField];
        
        
        [self.progressView setImage:image_DownloadIconGrey() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelGrayIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelGrayIcon() forState:TMLoaderViewStateUploading];
        
        [self setProgressStyle:TMCircularProgressLightStyle];
        
        [self setProgressToView:self.playerButton];
        
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
    
    [self updateCellState];
}

-(float)progressWidth {
    return MAX(150, MIN(self.item.blockSize.width, self.item.message.media.document.duration * 30));
}

- (NSRect)progressRect {
    return NSMakeRect(self.containerView.frame.origin.x + self.playerButton.frame.size.width + 10, NSMinY(self.playerButton.frame) + NSHeight(self.playerButton.frame) - 27, [self progressWidth], 3);
}

-(void)setDurationTextFieldString:(NSString *)string {
    [self.durationView setStringValue:self.item.duration];
    [self.durationView sizeToFit];
    [self.durationView setFrameSize:NSMakeSize(MIN(NSWidth(self.containerView.frame) - NSMinX(self.durationView.frame) - NSWidth(self.stateTextField.frame) - 15,NSWidth(self.durationView.frame)), NSHeight(self.durationView.frame))];
    
    [self.durationView setCenteredYByView:self.durationView.superview];
}

-(void)drawRect:(NSRect)dirtyRect {
    
}

- (void)setCellState:(CellState)cellState {
    //    if(self.cellState == cellState)
    //        return;
    [super setCellState:cellState];
    

    
    [self.progressView setState:cellState];
    
    if(self.item.state == AudioStateWaitPlaying || self.item.state == AudioStatePaused || self.item.state == AudioStatePlaying) {
        [self.playerButton setBackgroundImage:blueBackground() forControlState:BTRControlStateNormal];
    } else {
        [self.playerButton setBackgroundImage:grayBackground() forControlState:BTRControlStateNormal];
    }
    
    switch (self.audioState) {
        case TGAudioPlayerStatePaused:
            [self.playerButton setImage:playImage() forControlState:BTRControlStateNormal];
            break;
            
        case TGAudioPlayerStatePlaying:
            [self.playerButton setImage:image_DownloadPauseIconWhite() forControlState:BTRControlStateNormal];
            break;
        case TGAudioPlayerStateForcePaused: default :
            [self.playerButton setImage:playImage() forControlState:BTRControlStateNormal];
            break;
    }
    
    if(self.cellState == CellStateDownloading || self.cellState == CellStateNeedDownload || self.cellState == CellStateDownloading || self.item.messageSender != nil)
    {
        [self.playerButton setImage:nil forControlState:BTRControlStateNormal];
    }
    
    [self setNeedsDisplay:YES];
    
}


- (void)updateCellState {
    MessageTableItemAudio *item = (MessageTableItemAudio *)self.item;
    
    
    if(item.messageSender) {
        self.item.state = AudioStateUploading;
        self.cellState = CellStateSending;
        return;
    }
    
    if(item.downloadItem && item.downloadItem.downloadState != DownloadStateCompleted && item.downloadItem.downloadState != DownloadStateWaitingStart) {
        self.item.state = item.downloadItem.downloadState == DownloadStateCanceled ? AudioStateWaitDownloading : AudioStateDownloading;
        self.cellState = item.downloadItem.downloadState == DownloadStateCanceled ? CellStateCancelled : CellStateDownloading;

        
    } else  if(![self.item isset]) {
        self.item.state = AudioStateWaitDownloading;
        self.cellState = CellStateNeedDownload;
        
    } else {
        self.item.state = AudioStateWaitPlaying;
        self.cellState = CellStateNormal;
    }
    
    
}


- (NSMenu *)contextMenu {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Documents menu"];
    
    if([self.item isset]) {
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Message.File.ShowInFinder", nil) withBlock:^(id sender) {
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:self.item.path]]];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.SaveAs", nil) withBlock:^(id sender) {
            [self performSelector:@selector(saveAs:) withObject:self];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.CopyToClipBoard", nil) withBlock:^(id sender) {
            [self performSelector:@selector(copy:) withObject:self];
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
    
    item.cellView = self;
    
    if([TGAudioPlayerWindow currentItem].message.n_id == item.message.n_id)
        _audioState = [TGAudioPlayerWindow playerState];
     else
        _audioState = TGAudioPlayerStatePaused;
    
    
    self.acceptTimeChanger = NO;
    
    [self updateDownloadState];
    
    
    [self setStateTextFieldString:item.fileSize];
    
    [self setDurationTextFieldString:item.duration];
    
    [self.stateTextField setFrameOrigin:NSMakePoint(NSMaxX(self.durationView.frame) + 2, self.durationView.frame.origin.y )];
    [self.stateTextField setHidden:YES];
    if(item.state != AudioStatePlaying && item.state != AudioStatePaused)
        [self updateCellState];
    else {
        self.cellState = self.cellState;
        if(item.state != AudioStatePaused)
            [self startTimer];
    }
    
    
}


@end
