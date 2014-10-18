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
@interface MessageTableCellContainerView()
@property (nonatomic, strong) TMTextButton *nameTextField;
@property (nonatomic, strong) BTRImageView *sendImageView;
@property (nonatomic, strong) TMAvatarImageView *avatarImageView;
@property (nonatomic, strong) NSImageView *broadcastImageView;


@property (nonatomic, strong) TMView *fwdContainer;
@property (nonatomic, strong) TMHyperlinkTextField *fwdName;
@property (nonatomic, strong) TMAvatarImageView *fwdAvatar;

@property (nonatomic, strong) NSView *rightView;
@property (nonatomic, strong) TMTextLayer *forwardMessagesTextLayer;
@property (nonatomic, strong) TMTextLayer *dateLayer;
@property (nonatomic, strong) TMCircleLayer *circleLayer;
@property (nonatomic, strong) BTRButton *selectButton;
@property (nonatomic, strong) BTRButton *errorSendingButton;
@property (nonatomic,strong) ITProgressIndicator *progressIndicator;




@end


@implementation MessageTableCellContainerView

static NSImage* image_broadcast() {
    static NSImage *broadcast;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        broadcast = [NSImage imageNamed:@"broadcastSendingGray"];
    });
    
    return broadcast;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        weak();
        [self setWantsLayer:YES];
        [self.layer disableActions];
        
        assert(self.layer != nil);
        
       
        
        self.rightView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
        [self.rightView setLayer:[CALayer layer]];
        [self.rightView.layer disableActions];
        [self.rightView setWantsLayer:YES];
        [self.rightView setAutoresizingMask:NSViewMinXMargin];
        [self addSubview:self.rightView];
        
        self.forwardMessagesTextLayer = [TMTextLayer layer];
        [self.forwardMessagesTextLayer disableActions];
        [self.forwardMessagesTextLayer setContentsScale:self.layer.contentsScale];
        [self.forwardMessagesTextLayer setTextColor:NSColorFromRGB(0x9b9b9b)];
        [self.forwardMessagesTextLayer setTextFont:[NSFont fontWithName:@"HelveticaNeue" size:13]];
        [self.layer addSublayer:self.forwardMessagesTextLayer];
        
        self.dateLayer = [TMTextLayer layer];
        [self.dateLayer disableActions];
        [self.dateLayer setContentsScale:self.layer.contentsScale];
        [self.dateLayer setFrameOrigin:CGPointMake(offserUnreadMark, 0)];
        [self.dateLayer setTextColor:NSColorFromRGB(0x999999)];
        [self.dateLayer setTextFont:[NSFont fontWithName:@"HelveticaNeue" size:11]];
        [self.dateLayer setBackgroundColor:[NSColor clearColor].CGColor];
        [self.rightView.layer addSublayer:self.dateLayer];
        
        
        self.circleLayer = [TMCircleLayer layer];
        [self.circleLayer setFrame:CGRectMake(0, 4, 0, 0)];
        [self.circleLayer setContentsScale:self.layer.contentsScale];
        [self.circleLayer setRadius:8];
        [self.circleLayer setFillColor:NSColorFromRGB(0x41a2f7)];
        [self.circleLayer setNeedsDisplay];
        [self.rightView.layer addSublayer:self.circleLayer];
        
        self.selectButton = [[BTRButton alloc] initWithFrame:NSMakeRect(self.rightView.bounds.size.width - image_checked().size.width - 6, 0, image_checked().size.width, image_checked().size.height)];
        [self.selectButton setAutoresizingMask:NSViewMinXMargin];
        [self.selectButton setHidden:NO];
        
        [self.selectButton setBackgroundImage:selectCheckImage() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:selectCheckImage() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:selectCheckImage() forControlState:BTRControlStateHighlighted];
        [self.selectButton setBackgroundImage:selectCheckActiveImage() forControlState:BTRControlStateSelected];
        
        
        
        self.broadcastImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, image_broadcast().size.width, image_broadcast().size.height)];
        
        self.broadcastImageView.image = image_broadcast();
        
        [self.broadcastImageView setHidden:YES];
       
        [self addSubview:self.broadcastImageView];
    
        [self.selectButton setUserInteractionEnabled:NO];


        [self.rightView addSubview:self.selectButton];
        
        
       
        self.errorSendingButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_ChatMessageError().size.width , image_ChatMessageError().size.height)];
        [self.errorSendingButton setAutoresizingMask:NSViewMinXMargin];
        [self.errorSendingButton setHidden:NO];
        [self.errorSendingButton setBackgroundImage:image_ChatMessageError() forControlState:BTRControlStateNormal];
        
        [self.errorSendingButton addBlock:^(BTRControlEvents events) {
            
            
            [weakSelf alertError];
          
            
        } forControlEvents:BTRControlEventClick];
        
        [self addSubview:self.errorSendingButton];
        
        
        
        self.avatarImageView = [TMAvatarImageView standartMessageTableAvatar];
        [self.avatarImageView setTapBlock:^{
            [[Telegram sharedInstance] showUserInfoWithUserId:weakSelf.item.user.n_id conversation:weakSelf.item.user.dialog sender:weakSelf];
        }];
        [self addSubview:self.avatarImageView];
        
        self.nameTextField = [[TMTextButton alloc] initWithFrame:NSMakeRect(0, 0, 200, 20)];
        [self.nameTextField setBordered:NO];
        [self.nameTextField setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:13]];
        [self.nameTextField setDrawsBackground:NO];
        [self.nameTextField setTapBlock:^{
            [[Telegram sharedInstance] showUserInfoWithUserId:weakSelf.item.user.n_id conversation:weakSelf.item.user.dialog sender:weakSelf];
        }];
        [self addSubview:self.nameTextField];
        
        self.fwdContainer = [[TMView alloc] initWithFrame:NSZeroRect];
        [self.fwdContainer setDrawBlock:^{
            [GRAY_BORDER_COLOR set];
            
            float offset = weakSelf.item.isHeaderMessage ? 26 : 0;
            
            if(weakSelf.item.isHeaderForwardedMessage) {
                NSRectFill(NSMakeRect(0, 0, 2, weakSelf.fwdContainer.bounds.size.height - offset - 37));
            } else {
                NSRectFill(NSMakeRect(0, 0, 2, weakSelf.fwdContainer.bounds.size.height - offset));
            }
        }];

        [self.fwdContainer setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self.fwdContainer setFrameSize:NSMakeSize(self.bounds.size.width - 160, self.bounds.size.height)];
        [self addSubview:self.fwdContainer];
        
        
        self.fwdName = [[TMHyperlinkTextField alloc] init];
        [self.fwdName setBordered:NO];
        [self.fwdName setDrawsBackground:NO];
        [self.fwdContainer addSubview:self.fwdName];
        

        
        self.fwdAvatar = [TMAvatarImageView standartMessageTableAvatar];
        [self.fwdAvatar setTapBlock:^{
            [[Telegram sharedInstance] showUserInfoWithUserId:weakSelf.item.fwd_user.n_id conversation:weakSelf.item.fwd_user.dialog sender:weakSelf];
        }];
        [self.fwdContainer addSubview:self.fwdAvatar];
        
        
        self.containerView = [[TMView alloc] initWithFrame:NSZeroRect];
        [self.containerView setWantsLayer:YES];
        [self.containerView setAutoresizingMask:NSViewWidthSizable];
        [self.containerView setFrameSize:NSMakeSize(self.bounds.size.width - 160, self.bounds.size.height)];
        [self addSubview:self.containerView];
        
        
        
        _progressView = [[TMLoaderView alloc] initWithFrame:NSMakeRect(0, 0, 48, 48)];
        [self.progressView setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin];
        [self.progressView addTarget:self selector:@selector(checkOperation)];
        
    }
    return self;
}

-(void)checkOperation {
    if(self.item.messageSender) {
        [self deleteAndCancel];
        return;
    } else if(self.item.downloadItem.downloadState == DownloadStateDownloading) {
        [self cancelDownload];
        return;
    }
    
    if(self.progressView.state == TMLoaderViewStateNeedDownload) {
        [self startDownload:YES];
        return;
    }
    
    if([self.item isset]) {
        [self open];
        return;
    }

}

-(void)open {
    
}


NSImage *selectCheckImage() {
    return [NSImage imageNamed:@"ComposeCheck"];
}

NSImage *selectCheckActiveImage() {
    return [NSImage imageNamed:@"ComposeCheckActive"];
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
    NSColor *oldColor = NSColorFromRGB(0xf4f4f4);
    
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
    animation.duration = 2;
    animation.fromValue = (__bridge id)(oldColor.CGColor);
    animation.toValue = (__bridge id)(color.CGColor);
    [animation setCompletionBlock:^(POPAnimation *anim, BOOL finish) {
        [self.layer setBackgroundColor:(self.isSelected ? NSColorFromRGB(0xfafafa) : NSColorFromRGB(0xffffff)).CGColor];
    }];
    
    [self _didChangeBackgroundColorWithAnimation:animation];
    
    [self.layer pop_addAnimation:animation forKey:@"background"];
}



-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim {
    
}

- (void)stopSearchSelection {
    [self.layer pop_removeAnimationForKey:@"background"];
}

- (void)setSelected:(BOOL)isSelected animation:(BOOL)animation {
    if(self.isSelected == isSelected)
        return;
    
    
    self.item.isSelected = isSelected;
    _isSelected = isSelected;
    
    [self.selectButton setSelected:!self.selectButton.isSelected];
    
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
        
        color = isSelected ? NSColorFromRGB(0xfafafa) : NSColorFromRGB(0xffffff);
        NSColor *oldColor = !isSelected ? NSColorFromRGB(0xfafafa) : NSColorFromRGB(0xffffff);
        
        [self.layer pop_animationForKey:@"background"];
        
        POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
        animation.fromValue = (__bridge id)(oldColor.CGColor);
        animation.toValue = (__bridge id)(color.CGColor);
        animation.duration = 0.2;
        [self _didChangeBackgroundColorWithAnimation:animation];
        
        [self.layer pop_addAnimation:animation forKey:@"background"];
        
    } else {
        color = isSelected ? NSColorFromRGB(0xfafafa) : NSColorFromRGB(0xffffff);
        [self.layer setBackgroundColor:color.CGColor];
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
    if(mouseIsDown)
        [self acceptEvent:theEvent];
}


-(BOOL)acceptEvent:(NSEvent *)theEvent {
    
    if(!self.isEditable)
        return false;
    
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
        if(self.messagesViewController.state != MessagesViewControllerStateEditable) {
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


-(void)mouseDragged:(NSEvent *)theEvent {
    
    
   
    if(![self acceptEvent:theEvent]) {
        [super mouseDragged:theEvent];
    }
}

- (void)setItem:(MessageTableItem *)item {
    [super setItem:item];
    
    
    float offsetContainerView;
    
    
    
    
    if(item.isForwadedMessage) {
        
        float minus = 0;
        
        if(self.item.isHeaderForwardedMessage) {
            minus = FORWARMESSAGE_TITLE_HEIGHT;
            [self.forwardMessagesTextLayer setString:NSLocalizedString(@"Messages.ForwardedMessages",nil)];
            [self.forwardMessagesTextLayer sizeToFit];
            
            
            float minus = item.isHeaderMessage ? 30 : 12;
            [self.forwardMessagesTextLayer setFrameOrigin:CGPointMake(80, item.viewSize.height - self.forwardMessagesTextLayer.frame.size.height - minus)];
            
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
        
        
        [self.fwdName setHidden:NO];
        [self.fwdContainer setHidden:NO];
        [self.fwdContainer setFrameOrigin:NSMakePoint(68, 0)];
        [self.fwdAvatar setUser:item.fwd_user];
        
        if(self.item.isHeaderMessage) {
            [self.fwdAvatar setFrameOrigin:NSMakePoint(12, (item.viewSize.height - self.fwdAvatar.bounds.size.height - 8 - 26 - minus))];
            [self.fwdName setFrameOrigin:NSMakePoint(59, item.viewSize.height - 48 - minus)];
        } else {
            [self.fwdAvatar setFrameOrigin:NSMakePoint(12, (item.viewSize.height - self.fwdAvatar.bounds.size.height - 8 - minus))];
            [self.fwdName setFrameOrigin:NSMakePoint(59, item.viewSize.height - 24 - minus)];
        }
        
        
        [self.fwdName setAttributedStringValue:item.forwardMessageAttributedString];
        [self.fwdName sizeToFit];
        
        offsetContainerView = 129;
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.forwardMessagesTextLayer setHidden:YES];
        [CATransaction commit];
        
        [self.fwdName setHidden:YES];
        [self.fwdContainer setHidden:YES];
        offsetContainerView = 79;
    }

    
    if(item.isHeaderMessage) {
        [self.avatarImageView setHidden:NO];
        [self.nameTextField setHidden:NO];
        [self.nameTextField setTextColor:item.headerColor];
        [self.nameTextField setStringValue:item.headerName];
        [self.nameTextField sizeToFit];
        
        [self.nameTextField setFrameOrigin:NSMakePoint(77, item.viewSize.height - 24)];
        [self.containerView setFrameOrigin:NSMakePoint(offsetContainerView, 10)];
    } else {
        [self.avatarImageView setHidden:YES];
        [self.nameTextField setHidden:YES];
        [self.containerView setFrameOrigin:NSMakePoint(offsetContainerView, 8)];
    }
    
    [self.containerView setFrameSize:NSMakeSize(self.containerView.bounds.size.width, item.blockSize.height)];
   // [self.progressView setHidden:YES];
    
    if(item.messageSender)  {
        
        [item.messageSender addEventListener:self];
        
        if(item.messageSender.state == MessageStateWaitSend)
            [item.messageSender send];
        else
            [self checkState:item.messageSender];
    }
    
    
    [self setSelected:item.isSelected];
    
    [self.avatarImageView setUser:item.user];
    [self.avatarImageView setFrameOrigin:NSMakePoint(29, item.viewSize.height - 43)];

    [self checkActionState:YES];
    
    
    //Layers ;)
    
    [self.dateLayer setString:item.dateStr];
    [self.dateLayer setFrameSize:CGSizeMake(item.dateSize.width, item.dateSize.height)];
    [self.rightView setFrameSize:CGSizeMake(item.dateSize.width + offserUnreadMark + 32, MAX(item.dateSize.height, image_checked().size.width))];
    
    
   
    
    [self.rightView setToolTip:self.item.fullDate];
    
    
    [self setNeedsDisplay:YES];
    

}


static int offserUnreadMark = 14;
static int offsetEditable = 30;

- (void)setRightLayerToEditablePosition:(BOOL)editable {
    //    static int offserUnreadMark = 12;
    
    CGPoint position = CGPointMake(self.bounds.size.width - self.rightView.bounds.size.width - 2, self.item.viewSize.height - self.rightView.bounds.size.height - (self.item.isHeaderMessage ? 26 : 2));
    
    if(editable)
        position.x -= offsetEditable;
    
    int offset = editable ? offsetEditable : 0;
    
    
    [self.broadcastImageView setFrameOrigin:NSMakePoint(self.bounds.size.width - self.item.dateSize.width - 53 - offset, self.item.viewSize.height - self.broadcastImageView.bounds.size.height - (self.item.isHeaderMessage ? 29 : 5) )];
    
     [self.errorSendingButton setFrameOrigin:NSMakePoint(self.bounds.size.width - self.item.dateSize.width - 53 - offset, self.item.viewSize.height - self.errorSendingButton.bounds.size.height - (self.item.isHeaderMessage ? 28 : 4))];
    
   // [self.broadcastImageView setFrameOrigin:NSMakePoint(NSMinX(self.broadcastImageView.frame) - offset, NSMinY(self.broadcastImageView.frame))];
    
    [self.rightView.layer setFrameOrigin:position];
    [self.rightView setFrameOrigin:position];
}

- (void)setEditable:(BOOL)editable animation:(BOOL)animation {
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
    
    
    from = self.errorSendingButton.layer.frame.origin.x;
    to = self.errorSendingButton.layer.frame.origin.x + (editable ? -offsetEditable : offsetEditable);
    
    POPBasicAnimation *errorPos = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    errorPos.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    errorPos.fromValue = @(from);
    errorPos.toValue = @(to);
    errorPos.duration = duration;

    [self.errorSendingButton.layer pop_addAnimation:errorPos forKey:@"slide"];
    
    from = self.broadcastImageView.layer.frame.origin.x;
    to = self.broadcastImageView.layer.frame.origin.x + (editable ? -offsetEditable : offsetEditable);
    
    POPBasicAnimation *broadcastPos = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    broadcastPos.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    broadcastPos.fromValue = @(from);
    broadcastPos.toValue = @(to);
    broadcastPos.duration = duration;
    
    
    [self.broadcastImageView.layer pop_addAnimation:broadcastPos forKey:@"slide"];
    
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
    [[Storage manager] deleteMessages:@[@(item.message.n_id)] completeHandler:nil];
    [[DialogsManager sharedManager] updateLastMessageForDialog:item.message.dialog];
    [self.messagesViewController deleteItem:item];
    [Notification perform:DELETE_MESSAGE
                     data:@{KEY_MESSAGE:item.message}];
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
    if(sender.state == MessageStateSending) {
        
        if(!self.progressIndicator) {
            self.progressIndicator = [[ITProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 14, 14)];
            [self.progressIndicator setAutoresizingMask:NSViewMinYMargin | NSViewMinXMargin];
            [self addSubview:self.progressIndicator];
            
            self.progressIndicator.color = NSColorFromRGB(0x808080);
            
            [self.progressIndicator setIndeterminate:YES];
        }
        
    } else {
        [self.progressIndicator removeFromSuperview];
        self.progressIndicator = nil;
        if(sender.state == MessageSendingStateSent) {
            [self.item.messageSender removeEventListener:self];
            self.cellState = CellStateNormal;
            self.item.messageSender = nil;
        }
    }
    
    
    [self checkActionState:YES];
}


-(BOOL)canEdit {
    return self.item.messageSender == nil || self.item.messageSender.state == MessageSendingStateSent;
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
        
        
        [self.item.downloadListener setCompleteHandler:^(DownloadItem * item) {
            [weakSelf.item doAfterDownload];
            [weakSelf updateCellState];
            [weakSelf doAfterDownload];
            weakSelf.item.downloadItem = nil;
        }];
        
        [self.item.downloadListener setProgressHandler:^(DownloadItem * item) {
            if(weakSelf.cellState != CellStateDownloading)
                [weakSelf updateCellState];
            [weakSelf downloadProgressHandler:item];
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
        [self uploadProgressHandler:item animated:NO];
        [self updateCellState];
    }
}

- (void)uploadProgressHandler:(SenderItem *)item animated:(BOOL)animation {
    [self.progressView setProgress:item.progress animated:animation];
}

- (void)doAfterDownload {
    
}

- (void)onRemovedListener:(SenderItem *)item {
    
}

- (void)onStateChanged:(SenderItem *)item {
    if(item == self.item.messageSender) {
        [self checkState:item];
        [self uploadProgressHandler:item animated:NO];
        [self updateCellState];
        
        
        if(item.state == MessageSendingStateError) {
            [self checkState:item];
        }
        
        if(item.state == MessageSendingStateCancelled) {
            [self deleteAndCancel];
        }
    } else
        [self.item.messageSender removeEventListener:self];
    
}

- (void)checkActionState:(BOOL)redraw {
    MessageTableCellState state;
    if(self.item.message.n_out && self.item.message.unread) {
        if(self.item.messageSender) {
            if(self.item.messageSender.state == MessageSendingStateError) {
                state = MessageTableCellSendingError;
            } else if(self.item.message.dstate == DeliveryStatePending)  {
                state = MessageTableCellSending;
            }
        } else {
            state = MessageTableCellUnread;
        }
        
    } else {
        state = MessageTableCellRead;
    }
    
    
//    if(state != self.actionState)
    {
        MessageTableCellState oldState = self.actionState;
        
        self.actionState = state;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.circleLayer setHidden:!(self.actionState == MessageTableCellUnread) || self.item.message.dialog.type == DialogTypeBroadcast];
        [CATransaction commit];
        
    
        
        int offset = self.messagesViewController.state == MessagesViewControllerStateEditable ? offsetEditable : 0;
        
        [self.broadcastImageView setFrameOrigin:NSMakePoint(self.bounds.size.width - self.item.dateSize.width - 53 - offset, self.item.viewSize.height - self.broadcastImageView.bounds.size.height - (self.item.isHeaderMessage ? 29 : 5))];
        
        [self.broadcastImageView setHidden:state != MessageTableCellUnread || self.item.message.dialog.type != DialogTypeBroadcast];
        
        
        
        if(oldState == MessageTableCellSending && state == MessageTableCellUnread && self.item.message.dialog.type != DialogTypeBroadcast) {
            
            
            
            float fromValue = 0.5f;
            float duration = 0.1;
            
            POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
            scaleAnimation.fromValue  = [NSValue valueWithCGSize:CGSizeMake(fromValue, fromValue)];
            scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
            scaleAnimation.duration = duration;
            [self.circleLayer pop_addAnimation:scaleAnimation forKey:@"scale"];
            
            
        }
        
        
        [self.errorSendingButton setHidden:state != MessageTableCellSendingError];
        if(state == MessageTableCellSendingError) {
            [self.errorSendingButton setFrameOrigin:NSMakePoint(self.bounds.size.width - self.item.dateSize.width - 53 - offset, self.item.viewSize.height - self.errorSendingButton.bounds.size.height - (self.item.isHeaderMessage ? 28 : 4) )];
        }
        
        
        if(self.actionState == MessageTableCellSending) {
            
            [self.progressIndicator setHidden:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(self.actionState != MessageTableCellSending)
                    return;
                
                [self.progressIndicator setFrameOrigin:NSMakePoint(self.bounds.size.width - self.item.dateSize.width - 53, self.item.viewSize.height - self.progressIndicator.bounds.size.height - (self.item.isHeaderMessage ? 29 : 5))];
                [self.progressIndicator setHidden:NO];
            });
            
        } else {
            [self.progressIndicator setHidden:YES];
        }
    }
}


-(void)dealloc {
    self.containerView = nil;
    _progressView = nil;
    self.nameTextField = nil;
    self.avatarImageView = nil;
    self.fwdContainer = nil;
    self.fwdName = nil;
    self.fwdAvatar = nil;
    self.dateLayer = nil;
}




@end
