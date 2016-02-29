//
//  TGModernMessageCellContainerView.m
//  Telegram
//
//  Created by keepcoder on 21/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernMessageCellContainerView.h"
#import "TGModernForwardCellContainer.h"
#import "TGTextLabel.h"
#import "MessageReplyContainer.h"
#import "TGModernMessageCellRightView.h"
@interface TGModernMessageCellContainerView ()

@property (nonatomic,strong) TMAvatarImageView *photoView;
@property (nonatomic,strong) TGTextLabel *nameView;


@property (nonatomic,strong) TMView *contentView;
@property (nonatomic,strong) TGModernMessageCellRightView *rightView;


//containers
@property (nonatomic,strong) TMView *contentContainerView;
@property (nonatomic,strong) TGModernForwardCellContainer *forwardContainerView;
@property (nonatomic,strong) MessageReplyContainer *replyContainer;


@end

@implementation TGModernMessageCellContainerView

@synthesize progressView = _progressView;
@synthesize isEditable = _isEditable;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(BOOL)isFlipped {
    return YES;
}



-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        self.wantsLayer = YES;
        
        
        //container
        {
            _contentContainerView = [[TMView alloc] initWithFrame:NSZeroRect];
          //  _contentContainerView.backgroundColor = [NSColor redColor];
            _contentContainerView.isFlipped = YES;
            
            _contentView = [[TMView alloc] initWithFrame:NSZeroRect];
          //  _contentView.backgroundColor = [NSColor yellowColor];
            [_contentView setIsFlipped:YES];
            [_contentContainerView addSubview:_contentView];
            [self addSubview:_contentContainerView];
        }
        
        if(![self isKindOfClass:NSClassFromString(@"MessageTableCellTextView")] && ![self isKindOfClass:NSClassFromString(@"MessageTableCellGeoView")]) {
            _progressView = [[TMLoaderView alloc] initWithFrame:NSMakeRect(0, 0, 48, 48)];
            [_progressView setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin];
            [_progressView addTarget:self selector:@selector(checkOperation)];
            _progressView.wantsLayer = YES;
            [_progressView setHidden:YES animated:NO];
           // [_progressView.layer setac]
            
        }
        
    }
    return self;
}


-(void)checkAndMakeHeaderContainer:(MessageTableItem *)item {

    if(item.isHeaderMessage)
    {
        if(!_photoView) {
            _photoView = [TMAvatarImageView standartMessageTableAvatar];
            [self addSubview:_photoView];
        }
        
        if(!_nameView) {
            _nameView = [[TGTextLabel alloc] initWithText:nil maxWidth:0];
            [self addSubview:_nameView];
        }
        
        [_photoView setUser:item.user];
        
        [_nameView setText:item.headerName maxWidth:item.headerSize.width height:item.headerSize.height];
        
        [_photoView setFrameOrigin:NSMakePoint(item.defaultContainerOffset, item.defaultContentOffset)];
        [_nameView setFrameOrigin:NSMakePoint(item.startContentOffset, item.defaultContentOffset)];
        
    } else {
        [_photoView removeFromSuperview];
        _photoView = nil;
        [_nameView removeFromSuperview];
        _nameView = nil;
        
    }
}

-(void)chekAndMakeForwardContainer:(MessageTableItem *)item {
    
    if(item.isForwadedMessage) {
        
        if(!_forwardContainerView) {
            _forwardContainerView = [[TGModernForwardCellContainer alloc] initWithFrame:NSZeroRect];
            _forwardContainerView.backgroundColor = [NSColor whiteColor];
            [_contentContainerView addSubview:_forwardContainerView];
            [_contentView removeFromSuperview];
            [_forwardContainerView addSubview:_contentView];
        }
        
        [_forwardContainerView setFrameSize:_contentContainerView.frame.size];
        [_forwardContainerView setTableItem:item contentView:_contentView containerView:self];
        
        
    } else {
        if(_forwardContainerView) {
            [_forwardContainerView removeFromSuperview];
            [_contentView removeFromSuperview];
            [_contentContainerView addSubview:_contentView];
            _forwardContainerView = nil;
        }
    }
    
}

-(void)checkAndMakeReplyContainer:(MessageTableItem *)item {
    if(item.isReplyMessage) {
        
        if(!_replyContainer) {
            _replyContainer = [[MessageReplyContainer alloc] initWithFrame:NSMakeRect(NSMinX(_nameView.frame), NSMaxY(_nameView.frame) + item.defaultContentOffset, 0, 0)];
            [self addSubview:_replyContainer];
        }
        
        [_replyContainer setFrameSize:NSMakeSize(item.blockSize.width, item.replyObject.containerHeight)];
        [_replyContainer setItem:item];
        [_replyContainer setReplyObject:item.replyObject];
        
        [_contentContainerView setFrameOrigin:NSMakePoint(NSMinX(_contentContainerView.frame), NSMaxY(_replyContainer.frame) + item.contentHeaderOffset)];
    } else {
        if(_replyContainer) {
            [_replyContainer removeFromSuperview];
            _replyContainer = nil;
        }
    }
}

-(void)checkAndMakeRightView:(MessageTableItem *)item {
    
    if(item.hasRightView) {
        if(!_rightView) {
            _rightView = [[TGModernMessageCellRightView alloc] initWithFrame:NSZeroRect];
            [self addSubview:_rightView];
        }
        
        [_rightView setFrame:NSMakeRect(item.cellWidth - item.defaultContainerOffset - item.rightSize.width, item.defaultContentOffset, item.rightSize.width, image_checked().size.height)];
        [_rightView setItem:item container:self];
        
    } else {
        [_rightView removeFromSuperview];
        _rightView = nil;
    }
    
    [self setEditable:self.messagesViewController.state == MessagesViewControllerStateEditable animated:NO];
    [self setSelected:self.item.isSelected animated:NO];
}


-(void)checkAndMakeSenderItem:(MessageTableItem *)item {
    if(item.messageSender)  {
    
        [item.messageSender addEventListener:self];
        if(item.messageSender.state == MessageStateWaitSend)
                [item.messageSender send];
    }
    
    [self checkActionState:NO];
    
}


- (void)checkActionState:(BOOL)animated {
    
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
    self.actionState = state;
    
    [self.rightView setState:state animated:animated];
}

- (void)onStateChanged:(SenderItem *)item {
    
    if(item == self.item.messageSender) {
        
        [self uploadProgressHandler:item animated:YES];
        
        if(item.state == MessageSendingStateSent) {
            self.item.messageSender = nil;
        }
        
        [self checkActionState:YES];
        [self updateCellState];
        
        if(item.state == MessageSendingStateCancelled) {
            [self deleteAndCancel];
        }
 
    } else
        [item removeEventListener:self];
    
}



-(void)setItem:(MessageTableItem *)item {
    [super setItem:item];
    
  //  self.layer.backgroundColor = item.rowId % 2 == 0 ? [NSColor blueColor].CGColor : [NSColor greenColor].CGColor;
    
    int yStartContentOffset = item.isHeaderMessage ? item.headerSize.height + item.contentHeaderOffset + item.defaultContentOffset : item.defaultContentOffset;
    
    [_contentContainerView setFrame:NSMakeRect(item.startContentOffset,yStartContentOffset, item.viewSize.width, item.viewSize.height - yStartContentOffset)];
    
    [_contentView setFrame:NSMakeRect(0, 0, item.blockSize.width, item.blockSize.height)];
    
    [self checkAndMakeHeaderContainer:item];
    [self chekAndMakeForwardContainer:item];
    [self checkAndMakeReplyContainer:item];
    [self checkAndMakeSenderItem:item];
    [self checkAndMakeRightView:item];
}

-(TMView *)containerView {
    return _contentView;
}

- (void)setRightLayerToEditablePosition:(BOOL)editable {
    
}


static MessageTableItem *dateEditItem;
static BOOL mouseIsDown = NO;
static bool dragAction = NO;


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
    
    NSPoint pos = [self.messagesViewController.table convertPoint:[theEvent locationInWindow] fromView:nil];
    
    
    NSUInteger row = [self.messagesViewController.table rowAtPoint:pos];
    
    if(row != NSUIntegerMax) {
        
        NSTableRowView *rowView = [self.messagesViewController.table rowViewAtRow:row makeIfNecessary:NO];
        
        TGModernMessageCellContainerView *container = [[rowView subviews] objectAtIndex:0];
        if(container && [container isKindOfClass:[TGModernMessageCellContainerView class]]) {
            
            if(container.item.isSelected != dragAction) {
                [container setSelected:dragAction animated:YES];
                [self.messagesViewController setSelectedMessage:container.item selected:self.item.isSelected];
            }
            
        }
        
    }
    
    return true;
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    
    
    if(self.item.messageSender)
        return;
    
    if(self.messagesViewController.state == MessagesViewControllerStateNone && theEvent == nil) {
        [self.messagesViewController setCellsEditButtonShow:self.messagesViewController.state != MessagesViewControllerStateEditable animated:YES];
        [self mouseDown:nil];
        
        dateEditItem = self.item;
        
        return;
    }
   
    if(!self.isEditable) {
        [super mouseDown:[NSApp currentEvent]];
        
        return;
    }
    
    [self checkDateEditItem];
    
    mouseIsDown = YES;
    
    [self setSelected:!self.item.isSelected animated:theEvent != nil];
    [self.messagesViewController setSelectedMessage:self.item selected:self.item.isSelected];
    
    dragAction = self.item.isSelected;

}

-(void)mouseDragged:(NSEvent *)theEvent {
    
    if(![self acceptEvent:theEvent]) {
        [super mouseDragged:theEvent];
    }
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    animated = animated && self.item.isSelected != selected;
    
    [self.rightView setSelected:selected animated:animated];
    
    if(animated && NSHeight(self.visibleRect) > 0) {
        
        NSColor *color = selected ? NSColorFromRGB(0xf7f7f7) : NSColorFromRGB(0xffffff);
        NSColor *oldColor = !selected ? NSColorFromRGB(0xf7f7f7) : NSColorFromRGB(0xffffff);
        
        POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
        animation.fromValue = (__bridge id)(oldColor.CGColor);
        animation.toValue = (__bridge id)(color.CGColor);
        animation.duration = 0.2;
        animation.removedOnCompletion = YES;
        [self _didChangeBackgroundColorWithAnimation:animation toColor:color];
        
        [self.layer pop_addAnimation:animation forKey:@"background"];
        
    } else {
        NSColor *color = selected ? NSColorFromRGB(0xf7f7f7) : NSColorFromRGB(0xffffff);
        [self.layer setBackgroundColor:color.CGColor];
        [self _didChangeBackgroundColorWithAnimation:nil toColor:color];
    }
    
    
}

-(void)checkDateEditItem {
    if(dateEditItem == self.item && self.messagesViewController.selectedMessages.count == 1) {
        [self.messagesViewController setCellsEditButtonShow:NO animated:YES];
        dateEditItem = nil;
    }
}

-(void)setEditable:(BOOL)editable animated:(BOOL)animated {
    
    _isEditable = editable;
    
    [_rightView setEditable:editable animated:animated];
}


@end
