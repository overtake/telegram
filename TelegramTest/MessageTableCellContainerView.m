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
@property (nonatomic, strong) TMHyperlinkTextField *nameTextField;
@property (nonatomic, strong) BTRImageView *sendImageView;
@property (nonatomic, strong) TMAvatarImageView *avatarImageView;


@property (nonatomic, strong) TMView *fwdContainer;
@property (nonatomic, strong) TMHyperlinkTextField *fwdName;
@property (nonatomic, strong) TMAvatarImageView *fwdAvatar;

@property (nonatomic, strong) NSView *rightView;
@property (nonatomic, strong) TGCTextView *forwardMessagesTextLayer;
@property (nonatomic, strong) TMTextField *dateLayer;
@property (nonatomic, strong) BTRButton *selectButton;

@property (nonatomic, strong) MessageStateLayer *stateLayer;

@property (nonatomic, strong) MessageReplyContainer *replyContainer;


@property (nonatomic,strong) DownloadEventListener *downloadEventListener;


@property (nonatomic,strong) BTRButton *shareButton;

@property (nonatomic,strong) TGModalForwardView *forwardModalView;


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
    
//    [self.progressView setCurrentProgress:0];
//    
//    self.stateLayer.container = self;
//    
//    
//    [self.dateLayer setStringValue:item.dateStr];
//    [self.dateLayer setFrameSize:CGSizeMake(item.dateSize.width, item.dateSize.height)];
//    
//    NSSize stateLayerSize = NSMakeSize(MIN(item.message.isPost ? item.viewsCountAndSignSize.width + 30 : 30,NSWidth(item.table.frame) - item.containerOffset - 2 - 200 - NSWidth(self.dateLayer.frame)), NSHeight(_stateLayer.frame));
//    
//    [self.stateLayer setFrameSize:stateLayerSize];
//    [self.dateLayer setFrameOrigin:CGPointMake(NSMaxX(_stateLayer.frame), NSMinY(self.dateLayer.frame))];
//    [self.rightView setFrameSize:CGSizeMake(item.dateSize.width + offserUnreadMark + NSWidth(self.stateLayer.frame) + 15 , 18)];
//    [self.rightView setToolTip:self.item.fullDate];
//    
//    [self checkActionState:YES];
//    
//    [self setSelected:item.isSelected];
//    
//    if(item.isForwadedMessage) {
//        
//        [self initForwardContainer];
//        
//        [_fwdContainer setFrame:NSMakeRect(self.item.containerOffset, 0, self.bounds.size.width - 130, self.bounds.size.height )];
//        
//        float minus = 0;
//        
//        if(self.item.isHeaderForwardedMessage) {
//            minus = FORWARMESSAGE_TITLE_HEIGHT;
//            
//            float minus = item.isHeaderMessage ? 30 : 5;
//            [self.forwardMessagesTextLayer setFrameOrigin:CGPointMake(item.containerOffset+1, item.viewSize.height - self.forwardMessagesTextLayer.frame.size.height - minus)];
//            
//            [CATransaction begin];
//            [CATransaction setDisableActions:YES];
//            [self.forwardMessagesTextLayer setHidden:NO];
//            [CATransaction commit];
//        } else {
//            [CATransaction begin];
//            [CATransaction setDisableActions:YES];
//            [self.forwardMessagesTextLayer setHidden:YES];
//            [CATransaction commit];
//        }
//        
//        if(self.item.isHeaderMessage) {
//            [self.fwdName setFrameOrigin:NSMakePoint(6, item.viewSize.height - 50 - minus)];
//        } else {
//            [self.fwdName setFrameOrigin:NSMakePoint(6, item.viewSize.height - 24 - minus)];
//        }
//        [self.fwdName setAttributedStringValue:item.forwardMessageAttributedString];
//        [self.fwdName setFrameSize:NSMakeSize(NSWidth(self.containerView.frame) -40, 25)];
//        
//        
//    } else {
//        [CATransaction begin];
//        [CATransaction setDisableActions:YES];
//        [self.forwardMessagesTextLayer setHidden:YES];
//        [CATransaction commit];
//        
//        [self deallocForwardContainer];
//        
//    }
//    
//    
//
//    if(item.isHeaderMessage) {
//        [self initHeader];
//        [self.nameTextField setAttributedStringValue:item.headerName];
//        [self.nameTextField setFrameOrigin:NSMakePoint(item.containerOffset - 2, item.viewSize.height - 24)];
//        
//        [self.nameTextField setFrameSize:NSMakeSize(MIN(NSWidth(item.table.frame) - NSWidth(self.rightView.frame) - NSMinX(self.nameTextField.frame) - 30,item.headerSize.width) , NSHeight(self.nameTextField.frame))];
//        
//        if(!item.message.isPost)
//            [self.avatarImageView setUser:item.user];
//        else
//            [self.avatarImageView setChat:item.message.chat];
//        [self.avatarImageView setFrameOrigin:NSMakePoint(29, item.viewSize.height - 43)];
//        
//        
//    } else {
//        [self deallocHeader];
//    }
//
//    [self.containerView setFrame:NSMakeRect(item.isForwadedMessage ? item.containerOffsetForward : item.containerOffset, item.isHeaderMessage ? item.isForwadedMessage ? 4 : 4 : item.isForwadedMessage ? 4 : roundf((item.viewSize.height - item.blockSize.height)/2), NSWidth(self.frame) - 160, item.blockSize.height)];
//
//    
//    if([item isReplyMessage])
//    {
//        
//        [self initReplyContainer];
//        
//        [_replyContainer setItem:item];
//        
//        [_replyContainer setReplyObject:item.replyObject];
//        
//        [_replyContainer setFrame:NSMakeRect(item.containerOffset + 1, NSHeight(_containerView.frame) + 10, item.blockWidth  , item.replyObject.containerHeight)];
//        
//        
//    } else {
//        [self deallocReplyContainer];
//    }
//    
//    if(item.messageSender)  {
//        
//        [item.messageSender addEventListener:self];
//        
//        if(item.messageSender.state == MessageStateWaitSend)
//            [item.messageSender send];
//        else
//            [self checkState:item.messageSender];
//    }
//    
//    
//    
//    
//    
//    
//    [self setNeedsDisplay:YES];
//    
//    
//    if(item.message.isChannelMessage && item.message.isPost) {
//        
//        if(!_shareButton) {
//            _shareButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_ChannelShare().size.width , image_ChannelShare().size.height )];
//            [_shareButton setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateHover];
//            [_shareButton setImage:image_ChannelShare() forControlState:BTRControlStateNormal];
//            weak();
//            
//            [_shareButton addBlock:^(BTRControlEvents events) {
//                [weakSelf.forwardModalView close:NO];
//                weakSelf.forwardModalView = nil;
//                
//                weakSelf.forwardModalView = [[TGModalForwardView alloc] initWithFrame:weakSelf.window.contentView.bounds];
//                
//                [weakSelf.messagesViewController setSelectedMessage:weakSelf.item selected:YES];
//                
//                weakSelf.forwardModalView.messagesViewController = weakSelf.messagesViewController;
//                weakSelf.forwardModalView.messageCaller = weakSelf.item.message;
//                
//                [weakSelf.forwardModalView show:weakSelf.window animated:YES];
//
//            } forControlEvents:BTRControlEventClick ];
//        }
//        
//        
//        [self addSubview:_shareButton];
//        [_shareButton setAutoresizingMask:NSViewMinXMargin];
//
//        
//    } else {
//        [_shareButton removeFromSuperview];
//        _shareButton = nil;
//    }
    
   

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



- (void)checkActionState:(BOOL)redraw {
    
    
    MessageTableCellState state;
    if(self.item.messageSender) {
        
        if(self.item.messageSender.state == MessageSendingStateError) {
            state = MessageTableCellSendingError;
        } else if(self.item.messageSender.state == MessageStateSending)  {
            state = MessageTableCellSending;
            
            [self uploadProgressHandler:self.item.messageSender animated:NO];
            [self uploadProgressHandler:self.item.messageSender animated:YES];
            
        } else {
            state = self.item.message.unread ? MessageTableCellUnread : MessageTableCellRead;
        }
    } else {
        if(self.item.message.n_out) {
            if(!self.item.message.unread)
                state = MessageTableCellRead;
            else
                state = MessageTableCellUnread;
        } else  {
            state = MessageTableCellUnread;
        }
        
    }
    
    
    [self.stateLayer setHidden:!self.item.message.n_out && !self.item.message.isPost];
    
    if(!self.stateLayer.isHidden)
        [self.stateLayer setState:state];
}

-(void)clearSelection {
    
}

-(BOOL)mouseInText:(NSEvent *)theEvent {
    return [_replyContainer.superview mouse:[_replyContainer.superview convertPoint:[theEvent locationInWindow] fromView:nil] inRect:_replyContainer.frame] ;
}



-(void)_colorAnimationEvent {
    
    if(!_replyContainer.messageField)
        return;
    
    CALayer *currentLayer = (CALayer *)[_replyContainer.messageField.layer presentationLayer];
    
    id value = [currentLayer valueForKeyPath:@"backgroundColor"];
    
    _replyContainer.messageField.layer.backgroundColor = (__bridge CGColorRef)(value);
    [_replyContainer.messageField setNeedsDisplay:YES];
}

-(void)dealloc {
    
    [self.item.messageSender removeEventListener:self];
}

@end
