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
@property (nonatomic, strong) TMTextLayer *forwardMessagesTextLayer;
@property (nonatomic, strong) TMTextField *dateLayer;
@property (nonatomic, strong) BTRButton *selectButton;

@property (nonatomic, strong) MessageStateLayer *stateLayer;

@property (nonatomic, strong) MessageReplyContainer *replyContainer;


@property (nonatomic,strong) DownloadEventListener *downloadEventListener;


@property (nonatomic,strong) NSImageView *shareImageView;

@property (nonatomic,strong) TGModalForwardView *forwardModalView;

@end


@implementation MessageTableCellContainerView


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setWantsLayer:YES];
        [self.layer disableActions];
        
        assert(self.layer != nil);
        
        
        self.containerView = [[TMView alloc] initWithFrame:NSZeroRect];
        [self.containerView setWantsLayer:YES];
        [self.containerView setAutoresizingMask:NSViewWidthSizable];
        [self.containerView setFrameSize:NSMakeSize(self.bounds.size.width - 160, self.bounds.size.height)];
        [self addSubview:self.containerView];
        
        self.rightView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
        [self.rightView setLayer:[CALayer layer]];
        [self.rightView.layer disableActions];
        [self.rightView setWantsLayer:YES];
        [self.rightView setAutoresizingMask:NSViewMinXMargin];
        [self addSubview:self.rightView];
        
       
        
        self.dateLayer = [TMTextField defaultTextField];

        [self.dateLayer setFrameOrigin:CGPointMake(offserUnreadMark, 2)];
        [self.dateLayer setTextColor:GRAY_TEXT_COLOR];
        [self.dateLayer setFont:TGSystemFont(12)];
        [self.rightView addSubview:self.dateLayer];
        
        
        self.stateLayer = [[MessageStateLayer alloc] initWithFrame:NSMakeRect(0, 0, 60, NSHeight(self.rightView.frame))];
                
        
        [self.rightView addSubview:self.stateLayer];
        
        
    
        
        
        if(![self isKindOfClass:[MessageTableCellTextView class]] && ![self isKindOfClass:[MessageTableCellGeoView class]]) {
            _progressView = [[TMLoaderView alloc] initWithFrame:NSMakeRect(0, 0, 48, 48)];
            [self.progressView setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin];
            [self.progressView addTarget:self selector:@selector(checkOperation)];
        }
        
        
        
        
    }
    return self;
}

-(void)initForwardContainer {
    
    weak();
    
    
    
    if(!self.forwardMessagesTextLayer) {
        self.forwardMessagesTextLayer = [TMTextLayer layer];
        [self.forwardMessagesTextLayer disableActions];
        [self.forwardMessagesTextLayer setFrameSize:NSMakeSize(180, 20)];
        [self.forwardMessagesTextLayer setContentsScale:self.layer.contentsScale];
        [self.forwardMessagesTextLayer setTextColor:NSColorFromRGB(0x9b9b9b)];
        [self.forwardMessagesTextLayer setTextFont:TGSystemFont(13)];
        [self.forwardMessagesTextLayer setString:NSLocalizedString(@"Messages.ForwardedMessages",nil)];
        [self.layer addSublayer:self.forwardMessagesTextLayer];
    }
    
    if(!self.fwdContainer) {
        self.fwdContainer = [[TMView alloc] initWithFrame:NSMakeRect(self.item.containerOffset +1, 0, self.bounds.size.width - 130, self.bounds.size.height )];
        
        [self.fwdContainer setDrawBlock:^{
            [BLUE_SEPARATOR_COLOR set];
            
            float offset = weakSelf.item.isHeaderMessage ? weakSelf.item.isHeaderForwardedMessage ? 50 : 20 : weakSelf.item.isHeaderForwardedMessage ? 24 : 0;
            
            if(weakSelf.item.isHeaderForwardedMessage) {
                NSRectFill(NSMakeRect(0, 0, 2, weakSelf.fwdContainer.bounds.size.height - offset ));
            } else {
                NSRectFill(NSMakeRect(0, 0, 2, weakSelf.fwdContainer.bounds.size.height));
            }
        }];
        
        [self.fwdContainer setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self addSubview:self.fwdContainer];
    }
    
    if(!self.fwdName) {
        self.fwdName = [[TMHyperlinkTextField alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.fwdContainer.frame) - 100, 25)];
        [self.fwdName setBordered:NO];
        [self.fwdName setDrawsBackground:NO];
        [self.fwdName setAutoresizingMask:NSViewWidthSizable];
        [[self.fwdName cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.fwdContainer addSubview:self.fwdName];
    }
    
    
}

-(void)deallocForwardContainer {
    [self.fwdAvatar removeFromSuperview];
    self.fwdAvatar = nil;
    
    [self.forwardMessagesTextLayer removeFromSuperlayer];
    self.forwardMessagesTextLayer = nil;
    
    [self.fwdContainer removeFromSuperview];
    self.fwdContainer = nil;
    
    [self.fwdName removeFromSuperview];
    self.fwdName = nil;
    

}


-(void)initReplyContainer {
    
    if(!_replyContainer)
    {
        _replyContainer = [[MessageReplyContainer alloc] initWithFrame:NSMakeRect(80, 0, self.bounds.size.width - 170, 30)];
    
        
        [self addSubview:_replyContainer];
    }
    
}

-(void)deallocReplyContainer {
    
    [_replyContainer removeFromSuperview];
    
    [_replyContainer setReplyObject:nil];
    _replyContainer = nil;
}

-(void)initSelectButton {
    
    if(!self.selectButton) {
        self.selectButton = [[BTRButton alloc] initWithFrame:NSMakeRect(self.rightView.bounds.size.width - image_checked().size.width - 6, 0, image_checked().size.width, image_checked().size.height)];
        [self.selectButton setAutoresizingMask:NSViewMinXMargin];
        [self.selectButton setHidden:NO];
        
        [self.selectButton setBackgroundImage:selectCheckImage() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:selectCheckImage() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:selectCheckImage() forControlState:BTRControlStateHighlighted];
        [self.selectButton setBackgroundImage:selectCheckActiveImage() forControlState:BTRControlStateSelected];
        
        
        [self.selectButton setUserInteractionEnabled:NO];
        
        
        [self.rightView addSubview:self.selectButton];
    }
   
}

-(void)deallocSelectButton {
    [self.selectButton removeFromSuperview];
    self.selectButton = nil;
}

-(void)initHeader {
    
    weak();
    if(!self.avatarImageView) {
        
       
        
        self.avatarImageView = [TMAvatarImageView standartMessageTableAvatar];
        
       
        [self.avatarImageView setTapBlock:^{
            
            [appWindow().navigationController showInfoPage:weakSelf.item.user.dialog];
            
         //
        }];
        [self addSubview:self.avatarImageView];
    }
    
    if(!self.nameTextField) {
        self.nameTextField = [[TMHyperlinkTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 20)];
        [self.nameTextField setBordered:NO];
        [self.nameTextField setFont:TGSystemMediumFont(13)];
        [self.nameTextField setDrawsBackground:NO];
        
        
        [self addSubview:self.nameTextField];
    }
    
    [_avatarImageView setHidden:NO];
    [_nameTextField setHidden:NO];
}




-(void)deallocHeader {
    [self.avatarImageView removeFromSuperview];
    self.avatarImageView = nil;
    
    [self.nameTextField removeFromSuperview];
    self.nameTextField = nil;
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
        [self updateCellState];
        [self checkOperation];
    }

}

-(void)open {
    
}


NSImage *selectCheckImage() {
    return [NSImage imageNamed:@"ComposeCheck"];
}

NSImage *selectCheckActiveImage() {
    return [NSImage imageNamed:@"checked"];
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
    
    [self setRightLayerToEditablePosition:self.isEditable];
}

- (void)setSelected:(BOOL)isSelected {
    [self setSelected:isSelected animation:NO];
}

- (void)searchSelection {
    NSColor *color = NSColorFromRGB(0xffffff);
    NSColor *oldColor = NSColorFromRGB(0xf7f7f7);
    
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
    animation.duration = 2;
    animation.fromValue = (__bridge id)(oldColor.CGColor);
    animation.toValue = (__bridge id)(color.CGColor);
    [animation setCompletionBlock:^(POPAnimation *anim, BOOL finish) {
        [self.layer setBackgroundColor:(self.isSelected ? NSColorFromRGB(0xf7f7f7) : NSColorFromRGB(0xffffff)).CGColor];
    }];
    
    animation.removedOnCompletion = YES;
    
    [self _didChangeBackgroundColorWithAnimation:animation toColor:color];
    
    [self.layer pop_addAnimation:animation forKey:@"background"];
}





- (void)stopSearchSelection {
    [self.layer pop_removeAnimationForKey:@"background"];
}

- (void)setSelected:(BOOL)isSelected animation:(BOOL)animation {
    
    if(self.isSelected == isSelected)
        return;
    
    
    if([self isEditable])
        [self initSelectButton];
    else
        [self deallocSelectButton];
    
    
    
    
    
    self.item.isSelected = isSelected;
    _isSelected = isSelected;
    

    [self.selectButton setSelected:isSelected];
    
    if(self.selectButton.layer.anchorPoint.x != 0.5) {
        CGPoint point = self.selectButton.layer.position;
        
        point.x += roundf(image_checked().size.width / 2);
        point.y += roundf(image_checked().size.height / 2);
        
        self.selectButton.layer.position = point;
        self.selectButton.layer.anchorPoint = CGPointMake(0.5, 0.5);
    }
    
    if(self.selectButton.isSelected) {
        [self.selectButton setBackgroundImage:selectCheckActiveImage() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:selectCheckActiveImage() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:selectCheckActiveImage() forControlState:BTRControlStateHighlighted];
    } else {
        [self.selectButton setBackgroundImage:selectCheckImage() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:selectCheckImage() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:selectCheckImage() forControlState:BTRControlStateHighlighted];
    }
    
    NSColor *color;
    if(animation) {
        float duration = 1 / 18.f;
        float to = 0.9;
        
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.fromValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
        scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(to, to)];
        scaleAnimation.duration = duration / 2;
        [scaleAnimation setCompletionBlock:^(POPAnimation *anim, BOOL result) {
            if(result) {
                POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
                scaleAnimation.fromValue  = [NSValue valueWithCGSize:CGSizeMake(to, to)];
                scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
                scaleAnimation.duration = duration / 2;
                [self.selectButton.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
            }
        }];
        
        [self.selectButton.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
        
        color = isSelected ? NSColorFromRGB(0xf7f7f7) : NSColorFromRGB(0xffffff);
        NSColor *oldColor = !isSelected ? NSColorFromRGB(0xf7f7f7) : NSColorFromRGB(0xffffff);
        
        [self.layer pop_animationForKey:@"background"];
        
        POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
        animation.fromValue = (__bridge id)(oldColor.CGColor);
        animation.toValue = (__bridge id)(color.CGColor);
        animation.duration = 0.2;
        animation.removedOnCompletion = YES;
        [self _didChangeBackgroundColorWithAnimation:animation toColor:color];
        
        [self.layer pop_addAnimation:animation forKey:@"background"];
        
    } else {
        color = isSelected ? NSColorFromRGB(0xf7f7f7) : NSColorFromRGB(0xffffff);
        [self.layer setBackgroundColor:color.CGColor];
        [self _didChangeBackgroundColorWithAnimation:nil toColor:color];
    }
    
}


static MessageTableItem *dateEditItem;

static BOOL mouseIsDown = NO;

-(void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
    
    mouseIsDown = NO;
}


-(void)scrollWheel:(NSEvent *)theEvent {
    [super scrollWheel:theEvent];
    
    if(self.messagesViewController.state != MessagesViewControllerStateEditable)
        return;
    if([NSEvent pressedMouseButtons] == 1)
        [self acceptEvent:theEvent];
}


-(BOOL)acceptEvent:(NSEvent *)theEvent {
    
    if(!self.isEditable)
        return false;
    
    [self.messagesViewController.table checkAndScroll:[self.messagesViewController.table.scrollView convertPoint:[theEvent locationInWindow] fromView:nil]];
    
    NSPoint pos = [self.messagesViewController.table convertPoint:[theEvent locationInWindow] fromView:nil];
    
    
    NSUInteger row = [self.messagesViewController.table rowAtPoint:pos];
    
    if(row != NSUIntegerMax) {
        
        NSTableRowView *rowView = [self.messagesViewController.table rowViewAtRow:row makeIfNecessary:NO];
        
        MessageTableCellContainerView *container = [[rowView subviews] objectAtIndex:0];
        if(container && [container isKindOfClass:[MessageTableCellContainerView class]]) {
            [container setSelected:dragAction animation:YES];
            [self.messagesViewController setSelectedMessage:container.item selected:self.item.isSelected];
        }
        
    }
    
    return true;

}

static BOOL dragAction = NO;

- (void)mouseDown:(NSEvent *)theEvent {
    
    
    
    if(self.item.messageSender)
        return;
    
    NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if(NSPointInRect(pos, self.rightView.frame)) {
        if(self.messagesViewController.state == MessagesViewControllerStateNone) {
            [self.messagesViewController setCellsEditButtonShow:self.messagesViewController.state != MessagesViewControllerStateEditable animated:YES];
            [self mouseDown:theEvent];
            
            dateEditItem = self.item;
            
            
            return;
        }
    }
    
    
    
    if(!self.isEditable) {
        [super mouseDown:theEvent];
        
        return;
    }
    
    [self checkDateEditItem];
    
    
    [self.window makeFirstResponder:self];
    
    
    mouseIsDown = YES;
    
    self.item.isSelected = !self.item.isSelected;
    [self setSelected:self.item.isSelected animation:YES];
    [self.messagesViewController setSelectedMessage:self.item selected:self.item.isSelected];
    
    dragAction = self.item.isSelected;
    
}

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
        [pasteboard writeObjects:[NSArray arrayWithObject:[NSURL fileURLWithPath:mediaFilePath(self.item.message.media)]]];
    }
}


- (void)saveAs:(id)sender {
    
    if(![self.item.message.media isKindOfClass:[TL_messageMediaEmpty class]]) {
        
        NSSavePanel *panel = [NSSavePanel savePanel];
        
        NSString *path = mediaFilePath(self.item.message.media);
        
        NSString *fileName = [self.item.message.media isKindOfClass:[TL_messageMediaDocument class]] ? [self.item.message.media.document file_name] : [path lastPathComponent];
        
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

-(void)mouseDragged:(NSEvent *)theEvent {
    
    if(![self acceptEvent:theEvent]) {
        [super mouseDragged:theEvent];
    }
}

- (void)setItem:(MessageTableItem *)item {
    
    [super setItem:item];
    
    [self.progressView setCurrentProgress:0];
        
    self.stateLayer.container = self;
    
    if(item.isForwadedMessage) {
        
        [self initForwardContainer];
        
        [_fwdContainer setFrame:NSMakeRect(self.item.containerOffset, 0, self.bounds.size.width - 130, self.bounds.size.height )];
        
        float minus = 0;
        
        if(self.item.isHeaderForwardedMessage) {
            minus = FORWARMESSAGE_TITLE_HEIGHT;
            
            float minus = item.isHeaderMessage ? 30 : 5;
            [self.forwardMessagesTextLayer setFrameOrigin:CGPointMake(item.containerOffset+1, item.viewSize.height - self.forwardMessagesTextLayer.frame.size.height - minus)];
            
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [self.forwardMessagesTextLayer setHidden:NO];
            [CATransaction commit];
        } else {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [self.forwardMessagesTextLayer setHidden:YES];
            [CATransaction commit];
        }
        
        if(self.item.isHeaderMessage) {
            [self.fwdName setFrameOrigin:NSMakePoint(6, item.viewSize.height - 50 - minus)];
        } else {
            [self.fwdName setFrameOrigin:NSMakePoint(6, item.viewSize.height - 24 - minus)];
        }
        
        [self.fwdName setFrameSize:NSMakeSize(NSWidth(self.containerView.frame) , NSHeight(self.fwdName.frame))];
        [self.fwdName setAttributedStringValue:item.forwardMessageAttributedString];
        
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.forwardMessagesTextLayer setHidden:YES];
        [CATransaction commit];
        
        [self deallocForwardContainer];
        
    }

    if(item.isHeaderMessage) {
        [self initHeader];
        [self.nameTextField setAttributedStringValue:item.headerName];
        [self.nameTextField setFrameOrigin:NSMakePoint(item.containerOffset - 2, item.viewSize.height - 24)];
        if(item.message.from_id != 0)
            [self.avatarImageView setUser:item.user];
        else
            [self.avatarImageView setChat:item.message.chat];
        [self.avatarImageView setFrameOrigin:NSMakePoint(29, item.viewSize.height - 43)];
        
        
    } else {
        [self deallocHeader];
    }

    
  //  [self.containerView setBackgroundColor:[NSColor redColor]];
    
    [self.containerView setFrame:NSMakeRect(item.isForwadedMessage ? item.containerOffsetForward : item.containerOffset, item.isHeaderMessage ? item.isForwadedMessage ? 4 : 4 : item.isForwadedMessage ? 4 : roundf((item.viewSize.height - item.blockSize.height)/2), NSWidth(self.frame) - 160, item.blockSize.height)];
    
  //  [self.containerView removeAllSubviews];
    
  //  [self.layer setBackgroundColor:NSColorFromRGB(arc4random() % 16000000).CGColor];
        
    
    if([item isReplyMessage])
    {
        
        [self initReplyContainer];
        
        [_replyContainer setItem:item];
        
        [_replyContainer setReplyObject:item.replyObject];
        
        [_replyContainer setFrame:NSMakeRect(item.containerOffset + 1, NSHeight(_containerView.frame) + 10, item.blockWidth  , item.replyObject.containerHeight)];
        
        
    } else {
        [self deallocReplyContainer];
    }
    
    if(item.messageSender)  {
        
        [item.messageSender addEventListener:self];
        
        if(item.messageSender.state == MessageStateWaitSend)
            [item.messageSender send];
        else
            [self checkState:item.messageSender];
    }
    
    
    [self setSelected:item.isSelected];
    
    

    [self checkActionState:YES];
    
  //  Layers ;)
    
    [self.dateLayer setStringValue:item.dateStr];
    [self.dateLayer setFrameSize:CGSizeMake(item.dateSize.width, item.dateSize.height)];
    [self.dateLayer setFrameOrigin:CGPointMake(NSMaxX(_stateLayer.frame), NSMinY(self.dateLayer.frame))];
    [self.rightView setFrameSize:CGSizeMake(item.dateSize.width + offserUnreadMark + NSWidth(self.stateLayer.frame) + 15 , 18)];
    [self.rightView setToolTip:self.item.fullDate];
    
    [self setNeedsDisplay:YES];
    
    
    if(item.message.isChannelMessage && item.message.from_id == 0) {
        
        if(!_shareImageView) {
            _shareImageView = imageViewWithImage(image_ChannelShare());
            
            weak();
            
            [_shareImageView setCallback:^{
                
                [weakSelf.forwardModalView close:NO];
                weakSelf.forwardModalView = nil;
                
                weakSelf.forwardModalView = [[TGModalForwardView alloc] initWithFrame:weakSelf.window.contentView.bounds];
                
                [weakSelf.messagesViewController setSelectedMessage:weakSelf.item selected:YES];
                
                 weakSelf.forwardModalView.messagesViewController = weakSelf.messagesViewController;
                
                [weakSelf.forwardModalView show:weakSelf.window animated:YES];
                
                
            }];
        }
        
        
        [self addSubview:_shareImageView];
        [_shareImageView setAutoresizingMask:NSViewMinXMargin];
       // [_shareImageView setFrameOrigin:NSMakePoint(NSMinX(_rightView.frame) + NSWidth(_shareImageView.frame) + NSMaxX(_dateLayer.frame), NSMinY(_rightView.frame) - NSHeight(_shareImageView.frame))];
        
    } else {
        [_shareImageView removeFromSuperview];
        _shareImageView = nil;
    }
    

}


static int offserUnreadMark = 20;
static int offsetEditable = 30;

- (void)setRightLayerToEditablePosition:(BOOL)editable {
    //    static int offserUnreadMark = 12;
    
    CGPoint position = CGPointMake(self.bounds.size.width - self.rightView.bounds.size.width , self.item.viewSize.height - self.rightView.bounds.size.height - (self.item.isHeaderMessage ? 7 : 4));
    
    if(editable)
        position.x -= offsetEditable;
    
    
    [self.rightView.layer setFrameOrigin:position];
    [self.rightView setFrameOrigin:position];
    
    if(!editable)
        [_shareImageView setFrameOrigin:NSMakePoint(NSMinX(_rightView.frame) + NSWidth(_shareImageView.frame) + NSWidth(_dateLayer.frame) + 35, NSMinY(_rightView.frame) - NSHeight(_shareImageView.frame) - 5)];
    
    [_shareImageView setHidden:editable];
}

- (void)setEditable:(BOOL)editable animation:(BOOL)animation {
    
    if(editable)
        [self initSelectButton];
    else
        [self deallocSelectButton];
    
    
     [_shareImageView setHidden:editable];
    
    if(self.isEditable == editable && animation)
        return;
    _isEditable = editable;
    
    static float duration = 0.1f;
    
    if((!self.visibleRect.size.width && !self.visibleRect.size.height) || !animation) {
        [self setRightLayerToEditablePosition:editable];
        
        if(editable) {
            [self.selectButton.layer setOpacity:1];
            [self.selectButton setHidden:NO];
        } else {
            [self.selectButton setHidden:YES];
        }
        
        return;
    }
    
    
    
    [self setRightLayerToEditablePosition:!editable];
    
    float from = self.rightView.layer.frame.origin.x;
    float to = self.rightView.layer.frame.origin.x + (editable ? -offsetEditable : offsetEditable);
    

    
    [self.selectButton.layer setOpacity:editable ? 0 : 1];
    [self.selectButton setHidden:NO];
    
    
    POPBasicAnimation *position = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    position.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    position.fromValue = @(from);
    position.toValue = @(to);
    position.duration = duration;
    [position setCompletionBlock:^(POPAnimation *anim, BOOL result) {
        if(result) {
            [self setRightLayerToEditablePosition:editable];
        }
    }];
    [self.rightView.layer pop_addAnimation:position forKey:@"slide"];
    
    

    
    POPBasicAnimation *opacityAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    opacityAnim.fromValue = @(editable ? 0 : 1);
    opacityAnim.toValue = @(editable ? 1 : 0);
    opacityAnim.duration = duration;
    [opacityAnim setCompletionBlock:^(POPAnimation *anim, BOOL result) {
        if(result) {
            [self.selectButton setHidden:!editable];
        }
    }];
    [self.selectButton.layer pop_addAnimation:opacityAnim forKey:@"slide"];
    
    
    
    
    
}

- (void)cancelDownload {
    [self.item.downloadItem cancel];
    self.item.downloadItem = nil;
    [self.progressView setProgress:0.0 animated:NO];
    [self updateCellState];
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
    self->_cellState = cellState;
    
    [self.progressView setHidden:cellState == CellStateNormal];
    
}

- (void)updateCellState {
    
    
    MessageTableItem *item =(MessageTableItem *)self.item;
    
    if(item.downloadItem && (item.downloadItem.downloadState != DownloadStateWaitingStart && item.downloadItem.downloadState != DownloadStateCompleted)) {
        self.cellState = item.downloadItem.downloadState == DownloadStateCanceled ? CellStateCancelled : CellStateDownloading;
    } else if(item.messageSender && item.messageSender.state != MessageSendingStateSent ) {
        self.cellState = item.messageSender.state == MessageSendingStateCancelled ? CellStateCancelled : CellStateSending;
    } else if(![self.item isset]) {
        self.cellState = CellStateNeedDownload;
    } else {
        self.cellState = CellStateNormal;
    }
    
}

- (void)checkState:(SenderItem *)sender {
    if(sender.state == MessageSendingStateSent) {
        
        self.cellState = CellStateNormal;
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
    
    
    [self updateCellState];
    
    weak();
    
    if(self.item.downloadItem) {
        [self.progressView setProgress:self.item.downloadItem.progress animated:NO];
        
        [self.item.downloadItem removeEvent:_downloadEventListener];
        
        [_downloadEventListener clear];
        
        _downloadEventListener = [[DownloadEventListener alloc] init];
        
        [self.item.downloadItem addEvent:_downloadEventListener];
        
        [_downloadEventListener setCompleteHandler:^(DownloadItem * item) {
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                
                [weakSelf downloadProgressHandler:item];
                
                dispatch_after_seconds(0.2, ^{
                    [weakSelf.item doAfterDownload];
                    [weakSelf updateCellState];
                    [weakSelf doAfterDownload];
                    [weakSelf.progressView setCurrentProgress:0];
                    weakSelf.item.downloadItem = nil;
                });  
            }];
            
        }];
        
        [_downloadEventListener setProgressHandler:^(DownloadItem * item) {
            
            [ASQueue dispatchOnMainQueue:^{
                if(weakSelf.cellState != CellStateDownloading)
                    [weakSelf updateCellState];
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
        [self updateCellState];
    }
}

- (void)uploadProgressHandler:(SenderItem *)item animated:(BOOL)animation {
    [self.progressView setProgress:item.progress animated:animation];
}

- (void)doAfterDownload {
    
}

- (void)onRemovedListener:(SenderItem *)item {
    if(item.canRelease) {
        self.item.messageSender = nil;
        
       [self updateCellState];
    } 
}

- (void)onStateChanged:(SenderItem *)item {
    
    if(item == self.item.messageSender) {
        [self checkState:item];
        [self uploadProgressHandler:item animated:NO];
        [self updateCellState];
        
        if(item.state == MessageSendingStateCancelled) {
            [self deleteAndCancel];
        }
    } else
        [item removeEventListener:self];
    
}

- (void)checkActionState:(BOOL)redraw {
    
    MessageTableCellState state;
    if(self.item.messageSender) {
        
        if(self.item.messageSender.state == MessageSendingStateError) {
            state = MessageTableCellSendingError;
        } else if(self.item.messageSender.state == MessageStateSending)  {
            state = MessageTableCellSending;
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
    
    
    [self.stateLayer setHidden:!self.item.message.n_out && self.item.message.from_id != 0];
    
    if(!self.stateLayer.isHidden)
        [self.stateLayer setState:state];
}

-(void)clearSelection {
    [_replyContainer.messageField setSelectionRange:NSMakeRange(NSNotFound, 0)];
}

-(BOOL)mouseInText:(NSEvent *)theEvent {
    return [_replyContainer.superview mouse:[_replyContainer.superview convertPoint:[theEvent locationInWindow] fromView:nil] inRect:_replyContainer.frame] && [_replyContainer.messageField mouseInText:theEvent];
}

-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    
    if(!_replyContainer)
        return;
    
    if(!anim) {
        _replyContainer.messageField.backgroundColor = color;
        return;
    }
    
    POPBasicAnimation *animation = [POPBasicAnimation animation];
    
    animation.property = [POPAnimatableProperty propertyWithName:@"background" initializer:^(POPMutableAnimatableProperty *prop) {
        
        [prop setReadBlock:^(TGCTextView *textView, CGFloat values[]) {
            POPCGColorGetRGBAComponents(textView.backgroundColor.CGColor, values);
        }];
        
        [prop setWriteBlock:^(TGCTextView *textView, const CGFloat values[]) {
            CGColorRef color = POPCGColorRGBACreate(values);
            textView.backgroundColor = [NSColor colorWithCGColor:color];
        }];
        
    }];
    
    animation.toValue = anim.toValue;
    animation.fromValue = anim.fromValue;
    animation.duration = anim.duration;
    animation.removedOnCompletion = YES;
    [_replyContainer.messageField pop_addAnimation:animation forKey:@"background"];
    
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
    
 //   assert([NSThread isMainThread]);
    
    [self.item.messageSender removeEventListener:self];
}

@end
