//
//  MessageTableCellNewView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellContainerView.h"
#import "MessageTableElements.h"
#import "ITProgressIndicator.h"
#import "ImageUtils.h"
#import "TMClockProgressView.h"
#import "MessageStateLayer.h"
#import "NSMenuItemCategory.h"
#import "MessageReplyContainer.h"
#import "POPCGUtils.h"
#import "MessagesBottomView.h"
#import "TGHeadChatPanel.h"
#import "TGModalForwardView.h"



@interface MessageTableCellContainerView() <TMHyperlinkTextFieldDelegate>


@property (nonatomic,strong) DownloadEventListener *downloadEventListener;

@end


@implementation MessageTableCellContainerView


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        
    }
    return self;
}



-(void)checkOperation {
    
    if(self.isEditable)
    {
        [self mouseDown:[NSApp currentEvent]];
        return;
    }
    
    if(self.item.messageSender) {
        [self deleteAndCancel];
        return;
    } else if(self.item.downloadItem.downloadState == DownloadStateDownloading) {
        [self cancelDownload];
        return;
    }
    
    if(self.cellState == CellStateNeedDownload  && ![self.item isset]) {
        [self startDownload:YES];
        return;
    }
    
    if([self.item isset]) {
        [self open];
        return;
    } else {
        [self updateCellState:YES];
        [self checkOperation];
    }

}

-(void)open {
    
}



- (void)alertError {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setMessageText:NSLocalizedString(@"Alert.MessagesSendError.Desc",nil)];
    [alert setInformativeText:NSLocalizedString(@"Alert.MessagesSendError.Text",nil)];
    
    [alert addButtonWithTitle:NSLocalizedString(@"Alert.Button.TryAgain", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"Alert.Button.Delete", nil)];
    
    [alert addButtonWithTitle:NSLocalizedString(@"Alert.Button.Ignore", nil)];
    [alert beginSheetModalForWindow:[[NSApp delegate] mainWindow] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void *)(self.item)];
    

}


- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {

    MessageTableItem *item = (__bridge MessageTableItem *)(contextInfo);
    
    
    if(returnCode == 1000) {
        [self.messagesViewController resendItem:item];
    } else if(returnCode == 1001) {
        [self deleteAndCancel:item];
    }
    
}



- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
    return (id)[NSNull null];
}

- (void)resizeAndRedraw {
    [super resizeAndRedraw];
}









- (void)stopSearchSelection {
    [self.layer pop_removeAnimationForKey:@"background"];
}

-(BOOL)isSelected {
    return self.item.isSelected;
}



static MessageTableItem *dateEditItem;
static BOOL mouseIsDown = NO;





-(void)checkDateEditItem {
    //dateEditItem == self.item
    if(dateEditItem == self.item && self.messagesViewController.selectedMessages.count == 1) {
        [self.messagesViewController setCellsEditButtonShow:NO animated:YES];
        dateEditItem = nil;
    }
}



- (void)selectedSharingServiceFromMenuItem:(NSMenuItem *)menuItem
{
    NSURL *fileURL = self.item.shareObject;
    if (!fileURL) return;
    
    NSSharingService *service = menuItem.representedObject;
    if (![service isKindOfClass:[NSSharingService class]]) return; // just to make sure…
    
    [service performWithItems:@[fileURL]];
}



- (void)copy:(id)sender {
    
    if(![self.item.message.media isKindOfClass:[TL_messageMediaEmpty class]]) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        [pasteboard writeObjects:[NSArray arrayWithObject:[NSURL fileURLWithPath:mediaFilePath(self.item.message)]]];
    }
}


- (void)saveAs:(id)sender {
    
    if(![self.item.message.media isKindOfClass:[TL_messageMediaEmpty class]]) {
        
        NSSavePanel *panel = [NSSavePanel savePanel];
        
        NSString *path = mediaFilePath(self.item.message);
        
        NSString *fileName = [self.item.message.media isKindOfClass:[TL_messageMediaDocument class]]  || [self.item.message.media isKindOfClass:[TL_messageMediaDocument_old44 class]] ? [self.item.message.media.document file_name] : [path lastPathComponent];
        
        [panel setNameFieldStringValue:fileName];
        
        
        [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
            if (result == NSFileHandlingPanelOKButton) {
                
                NSURL *file = [panel URL];
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:path] ) {

                    [[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:path] toURL:file error:nil];
                }
            } else if(result == NSFileHandlingPanelCancelButton) {
                
            }
        }];
    }
    
}



- (void)setItem:(MessageTableItem *)item {
    
    [super setItem:item];

}




- (void)cancelDownload {
    [self.item.downloadItem cancel];
    self.item.downloadItem = nil;
    [self.progressView setProgress:0.0 animated:NO];
    [self updateCellState:YES];
}

- (void)deleteAndCancel:(MessageTableItem *)item {
    if(item.messageSender.state != MessageSendingStateError && item.messageSender.state != MessageSendingStateCancelled)
        [item.messageSender cancel];
    
    item.messageSender = nil;
    
    [[DialogsManager sharedManager] deleteMessagesWithRandomMessageIds:@[@(item.message.randomId)] isChannelMessages:self.item.message.isChannelMessage];
    
    [self.messagesViewController deleteItem:item];
}



- (void)deleteAndCancel {
    [self deleteAndCancel:self.item];
}

- (void)setCellState:(CellState)cellState {
    [self setCellState:cellState animated:NO];
    
}

-(void)setCellState:(CellState)cellState animated:(BOOL)animated {
    self->_cellState = cellState;
    
    [self.progressView setState:cellState];
    [self.progressView setHidden:cellState == CellStateNormal];
}

- (void)updateCellState:(BOOL)animated {
    
    MessageTableItem *item =(MessageTableItem *)self.item;
    
    if(item.downloadItem && (item.downloadItem.downloadState != DownloadStateWaitingStart && item.downloadItem.downloadState != DownloadStateCompleted)) {
        [self setCellState:item.downloadItem.downloadState == DownloadStateCanceled ? CellStateCancelled : CellStateDownloading animated:animated];
    } else if(item.messageSender && item.messageSender.state != MessageSendingStateSent ) {
        [self setCellState:item.messageSender.state == MessageSendingStateCancelled ? CellStateCancelled : CellStateSending animated:animated];
    } else if(![self.item isset]) {
        [self setCellState:CellStateNeedDownload animated:animated];
    } else {
        [self setCellState:CellStateNormal animated:animated];
    }
    
}

- (void)checkState:(SenderItem *)sender {
    if(sender.state == MessageSendingStateSent) {
        
        [self setCellState:CellStateNormal animated:NO];
    }
    
    [self checkActionState:YES];
}


-(BOOL)canEdit {
    return (self.item.messageSender == nil || self.item.messageSender.state == MessageSendingStateSent) && self.item.message.n_id < TGMINFAKEID;
}

- (void)setProgressStyle:(TMCircularProgressStyle)style {
    
    [self.progressView setStyle:style];

}


- (void)setProgressToView:(NSView *)view {
    [self.progressView setCenterByView:view];
    [view addSubview:self.progressView];
}

- (void)setProgressFrameSize:(NSSize)newsize {
    [self.progressView setFrameSize:newsize];
    [self.progressView setCenterByView:self.progressView.superview];
}


- (void)downloadProgressHandler:(DownloadItem *)item {
    [self.progressView setProgress:item.progress animated:YES];
}

- (void)startDownload:(BOOL)cancel {
   
    
    [self.item startDownload:cancel force:YES];
    
    [self updateDownloadState];
}


-(void)updateDownloadState {
    
    
    [self updateCellState:NO];
    
    weak();
    
    if(self.item.downloadItem) {
        [self.progressView setProgress:self.item.downloadItem.progress animated:NO];
        
        [self.item.downloadItem removeEvent:_downloadEventListener];
        
        [_downloadEventListener clear];
        
        _downloadEventListener = [[DownloadEventListener alloc] init];
        
        [self.item.downloadItem addEvent:_downloadEventListener];
        
        [_downloadEventListener setCompleteHandler:^(DownloadItem * item) {
            
            strongWeak();
            
            [strongSelf.item doAfterDownload];
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                
                if(strongSelf == weakSelf) {
                    [weakSelf downloadProgressHandler:item];
                    [weakSelf updateCellState:YES];
                    [weakSelf doAfterDownload];
                    dispatch_after_seconds(0.3, ^{
                         weakSelf.item.downloadItem = nil;
                         [weakSelf downloadProgressHandler:nil];
                    });
                }
                
                
            }];
            
        }];
        
        [_downloadEventListener setProgressHandler:^(DownloadItem * item) {
            
            [ASQueue dispatchOnMainQueue:^{
                if(weakSelf.cellState != CellStateDownloading)
                    [weakSelf updateCellState:YES];
                [weakSelf downloadProgressHandler:item];
            }];
        }];

    } 
   
}

- (void)onProgressChanged:(SenderItem *)item {
    
    if(item == self.item.messageSender) {
        [self uploadProgressHandler:item animated:YES];
    }
    
}

- (void)onAddedListener:(SenderItem *)item {
    
    if(item == self.item.messageSender) {
        [self uploadProgressHandler:item animated:YES];
        [self updateCellState:YES];
    }
}

- (void)onStateChanged:(SenderItem *)item {
    
    if(item == self.item.messageSender) {
        [self checkState:item];
        [self uploadProgressHandler:item animated:YES];
        [self updateCellState:YES];
        
        if(item.state == MessageSendingStateCancelled) {
            [self deleteAndCancel];
        }
    } else
    [item removeEventListener:self];
    
}

- (void)uploadProgressHandler:(SenderItem *)item animated:(BOOL)animation {
    [self.progressView setProgress:item.progress animated:animation];
}

- (void)doAfterDownload {
    
}

- (void)onRemovedListener:(SenderItem *)item {
    if(item.canRelease) {
        self.item.messageSender = nil;
        
        [self updateCellState:YES];
    } 
}


-(void)dealloc {
    
    [self.item.messageSender removeEventListener:self];
}

@end
