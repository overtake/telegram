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
        
        

        
        //tests main container
        {
            _photoView = [TMAvatarImageView standartMessageTableAvatar];
            _nameView = [[TGTextLabel alloc] initWithText:nil maxWidth:0];
            
            _nameView.backgroundColor = [NSColor blackColor];
            
            [self addSubview:_photoView];
            [self addSubview:_nameView];
        }
        
        
        //container
        {
            _contentContainerView = [[TMView alloc] initWithFrame:NSZeroRect];
           // _contentContainerView.backgroundColor = [NSColor redColor];
            _contentContainerView.isFlipped = YES;
            
            _contentView = [[TMView alloc] initWithFrame:NSZeroRect];
          //  _contentView.backgroundColor = [NSColor yellowColor];
            [_contentView setIsFlipped:YES];
            [_contentContainerView addSubview:_contentView];
            [self addSubview:_contentContainerView];
        }
        
    }
    return self;
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
        
        [_contentContainerView setFrameOrigin:NSMakePoint(NSMinX(_contentContainerView.frame), NSMaxY(_replyContainer.frame) + item.defaultContentOffset)];
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
        
        [_rightView setFrame:NSMakeRect(item.cellWidth - item.defaultContainerOffset - item.rightSize.width, item.defaultContentOffset, item.rightSize.width, item.rightSize.height)];
        [_rightView setItem:item container:self];
        
    } else {
        [_rightView removeFromSuperview];
        _rightView = nil;
    }
    
}


-(void)checkAndMakeSenderItem:(MessageTableItem *)item {
    if(item.messageSender)  {
    
        [item.messageSender addEventListener:self];
    
        if(item.messageSender.state == MessageStateWaitSend)
                [item.messageSender send];
        else
            [self checkActionState:NO];
    }
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
    
    
    [self.rightView setState:state animated:animated];
}

- (void)onStateChanged:(SenderItem *)item {
    
    if(item == self.item.messageSender) {
        [self checkActionState:YES];
        [self uploadProgressHandler:item animated:YES];
        [self updateCellState];
        
        if(item.state == MessageSendingStateCancelled) {
            [self deleteAndCancel];
        }
    } else
    [item removeEventListener:self];
    
}


-(void)setItem:(MessageTableItem *)item {
    [super setItem:item];
    
    [_photoView setUser:item.user];
    
    [_nameView setText:item.headerName maxWidth:item.headerSize.width height:item.headerSize.height];
    
    [_photoView setFrameOrigin:NSMakePoint(item.defaultContainerOffset, item.defaultContentOffset)];
    [_nameView setFrameOrigin:NSMakePoint(item.startContentOffset, item.defaultContentOffset)];

  //  self.layer.backgroundColor = item.rowId % 2 == 0 ? [NSColor blueColor].CGColor : [NSColor greenColor].CGColor;
    
    [_contentContainerView setFrame:NSMakeRect(item.startContentOffset,NSMaxY(_nameView.frame) + item.defaultContentOffset, item.viewSize.width, item.viewSize.height - NSMaxY(_nameView.frame) - item.defaultContentOffset)];
    
    [_contentView setFrame:NSMakeRect(0, 0, item.blockSize.width, item.blockSize.height)];
    
    
    [self chekAndMakeForwardContainer:item];
    [self checkAndMakeReplyContainer:item];
    [self checkAndMakeRightView:item];
    [self checkAndMakeSenderItem:item];
}

-(TMView *)containerView {
    return _contentView;
}

- (void)setRightLayerToEditablePosition:(BOOL)editable {
    
}

@end
