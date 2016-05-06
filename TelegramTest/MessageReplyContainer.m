//
//  MessageReplyContainer.m
//  Telegram
//
//  Created by keepcoder on 10.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "MessageReplyContainer.h"
#import "MessageTableItem.h"
#import "MessageTableElements.h"
#import "UIImageView+AFNetworking.h"
#import "TGTextLabel.h"
#import "TGTimer.h"
@interface MessageReplyContainer ()
@property (nonatomic,strong) TGTextLabel *nameView;

@property (nonatomic,strong) TGImageView *thumbImageView;
@property (nonatomic,strong) NSImageView *locationImageView;

@property (nonatomic,strong) NSImageView *deleteImageView;
@property (nonatomic,strong) TGTextLabel *loadingTextField;


@property (nonatomic,strong) TGTimer *editTimer;
@property (nonatomic,strong) TGTextLabel *editTimerLabel;


@end

@implementation MessageReplyContainer



-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _loadingTextField = [[TGTextLabel alloc] init];
        
        static NSMutableAttributedString *loadingAttr;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            loadingAttr = [[NSMutableAttributedString alloc] init];
            [loadingAttr appendString:NSLocalizedString(@"Reply.Loading", nil) withColor:TEXT_COLOR];
            [loadingAttr setFont:TGSystemFont(13) forRange:loadingAttr.range];
        });
        
        [_loadingTextField setText:loadingAttr maxWidth:INT32_MAX];
        [_loadingTextField setFrameOrigin:NSMakePoint(6, 0)];
        
        self.nameView = [[TGTextLabel alloc] initWithFrame:NSMakeRect(15, NSHeight(frameRect) - 13, 200, 20)];
        
        [self addSubview:self.nameView];
        
        _messageField = [[TGTextLabel alloc] initWithFrame:NSZeroRect];
        
        
        [self.messageField setBackgroundColor:[NSColor whiteColor]];

        [self.messageField setFrameOrigin:NSMakePoint(15, 0)];
        
        [self addSubview:self.messageField];
        
        self.thumbImageView = [[TGImageView alloc] initWithFrame:NSMakeRect(5, 1, NSHeight(self.frame) - 2, NSHeight(self.frame) - 2)];
        
        self.thumbImageView.cornerRadius = 4;
        
        self.locationImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(5, 1, NSHeight(self.frame) - 2, NSHeight(self.frame) - 2)];
        
        [self.thumbImageView setContentMode:BTRViewContentModeCenter];
        
        self.locationImageView.layer.cornerRadius = 4;
        
        [self update];
        
        [Notification addObserver:self selector:@selector(messagTableEditedMessageUpdate:) name:UPDATE_EDITED_MESSAGE];
        
    }
    
    
    return self;
}



-(void)messagTableEditedMessageUpdate:(NSNotification *)notification {
    TL_localMessage *message = notification.userInfo[KEY_MESSAGE];
    
    if( self.replyObject.replyMessage.channelMsgId == message.channelMsgId ) {
        
        TGReplyObject* nReply = [[TGReplyObject alloc] initWithReplyMessage:message fromMessage:self.replyObject.fromMessage tableItem:self.replyObject.item pinnedMessage:self.replyObject.pinnedMessage];
        
        self.replyObject = nReply;
    }
}



-(void)dealloc {
    [Notification removeObserver:self];
}

-(void)setDeleteHandler:(dispatch_block_t)deleteHandler {
    _deleteHandler = deleteHandler;
    
    [self update];
}

-(void)setReplyObject:(TGReplyObject *)replyObject {
    _replyObject = replyObject;
    _doublePinScrolled = NO;
    [self update];
}


-(NSColor *)color {
    
    NSRange range = NSMakeRange(0, 1);
    
   // if(_replyObject.replyHeader.string.length == 0)
   // {
        return BLUE_SEPARATOR_COLOR;
   // }
    
   // return [_replyObject.replyHeader attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:&range];
}


-(int)xOffset {
    return _replyObject.replyThumb || _replyObject.geoURL ? _replyObject.replyThumb.imageSize.width + ([MessageTableItem defaultOffset] - 1) *2 : [MessageTableItem defaultOffset]-1;
}

-(void)update {
    
    
    
    if(_replyObject.replyMessage == nil) {
        [self addSubview:_loadingTextField];
    } else {
        [_loadingTextField removeFromSuperview];
    }
   
    
    if(_replyObject.replyThumb) {
        [self addSubview:self.thumbImageView];
        [self.thumbImageView setObject:_replyObject.replyThumb];
        [self.thumbImageView setFrameSize:_replyObject.replyThumb.imageSize];
    } else {
        [self.thumbImageView removeFromSuperview];
    }
    
    
    if(_replyObject.geoURL) {
        [self addSubview:self.locationImageView];
        [self.locationImageView setImageWithURL:_replyObject.geoURL];
        
    } else {
        [self.locationImageView removeFromSuperview];
    }
    
    [_thumbImageView setFrameOrigin:NSMakePoint([MessageTableItem defaultOffset]-1, 1)];
    [_locationImageView setFrameOrigin:NSMakePoint([MessageTableItem defaultOffset]-1, 1)];
    
    [self.nameView setText:[_replyObject replyHeader] maxWidth:NSWidth(self.frame) - self.xOffset height:_replyObject.replyHeaderHeight];
    
    
    
    
    [self.messageField setFrameOrigin:NSMakePoint(self.xOffset, 0)];

    
   
    
    
    if(_deleteHandler != nil)
    {
        _deleteImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(NSWidth(self.frame) - image_CancelReply().size.width, NSHeight(self.frame) - image_CancelReply().size.height, image_CancelReply().size.width , image_CancelReply().size.height )];
        
        _deleteImageView.image = image_CancelReply();
        
        [_deleteImageView setCallback:_deleteHandler];
        
        [_deleteImageView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
        
        if(self.isPinnedMessage) {
            [_deleteImageView setCenteredYByView:self];
        }
        
        [self addSubview:_deleteImageView];
    } else {
        [_deleteImageView removeFromSuperview];
        _deleteImageView = nil;
    }
    
    [self setNeedsDisplay:YES];
    
    [self setFrame:self.frame];
    
    
    if(self.replyObject.isEditMessage) {
        _editTimerLabel = [[TGTextLabel alloc] init];
        [self addSubview:_editTimerLabel];
        [_editTimerLabel setBackgroundColor:self.backgroundColor];
        
        weak();
        
        _editTimer = [[TGTimer alloc] initWithTimeout:1.0 repeat:YES completion:^{
            
            
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
            
            int time = MAX( self.replyObject.replyMessage.date + edit_time_limit() - [[MTNetwork instance] getTime],0);
            
            [attr appendString:[NSString durationTransformedValue:time] withColor:GRAY_TEXT_COLOR];
            
            [attr setFont:TGSystemFont(13) forRange:attr.range];
            
            [_editTimerLabel setText:attr maxWidth:NSWidth(weakSelf.frame) - self.xOffset- 30 - NSWidth(weakSelf.nameView.frame)];
            
            [_editTimerLabel setFrameOrigin:NSMakePoint(NSMaxX(weakSelf.nameView.frame) + 8, NSMinY(weakSelf.nameView.frame))];
            
            [_editTimerLabel setHidden:time <= 10*60];
            
            if(time <= 0) {
                [weakSelf.editTimer invalidate];
                weakSelf.editTimer = nil;
                if(weakSelf.deleteHandler)
                weakSelf.deleteHandler();
            }
            
            
        } queue:dispatch_get_current_queue()];
        
        [_editTimer start];
        [_editTimer fire];
        
    } else {
        
        [_editTimer invalidate];
        _editTimer =nil;
        
        [_editTimerLabel removeFromSuperview];
        _editTimerLabel = nil;
    }
    
}

-(void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    
    [self.messageField setText:_replyObject.replyText maxWidth:NSWidth(self.frame) - self.xOffset- (_deleteHandler ?  NSWidth(_deleteImageView.frame) +10 : 0) height:_replyObject.replyHeight];
    [self.nameView setFrameOrigin:NSMakePoint(self.xOffset, NSHeight(self.frame) - NSHeight(_nameView.frame))];
    
    [_loadingTextField setCenteredYByView:self];
}

-(void)setBackgroundColor:(NSColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    [self.messageField setBackgroundColor:backgroundColor];
    [self.nameView setBackgroundColor:backgroundColor];
    [self.editTimerLabel setBackgroundColor:backgroundColor];
}

-(void)mouseUp:(NSEvent *)theEvent {
    
    if([self.superview mouse:[self.superview convertPoint:theEvent.locationInWindow fromView:nil] inRect:self.frame]) {
        if(!_deleteHandler) {
            if(_item.table.viewController.state == MessagesViewControllerStateNone)
                [_item.table.viewController showMessage:_replyObject.replyMessage fromMsg:_item.message flags:ShowMessageTypeReply];
        } else if(self.isPinnedMessage) {
            if(![self mouse:[self convertPoint:theEvent.locationInWindow fromView:nil] inRect:_deleteImageView.frame])
                [appWindow().navigationController.messagesViewController showMessage:_replyObject.replyMessage fromMsg:nil flags:ShowMessageTypeReply];
        }
    }
    
}

-(void)_didScrolledTableView:(NSNotification *)notification {
    _doublePinScrolled = NO;
    [self removeScrollEvent];
}


-(void)addScrollEvent {
    id clipView = [[_item.table.viewController.table enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didScrolledTableView:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
    
}

-(void)removeScrollEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    if(!anim) {
        _messageField.backgroundColor = color;
        _nameView.backgroundColor = color;
    } else {
        [_messageField pop_addAnimation:anim forKey:@"background"];
        [_nameView pop_addAnimation:anim forKey:@"background"];
    }
    
}

-(void)mouseDragged:(NSEvent *)theEvent {
    
}

-(void)mouseDown:(NSEvent *)theEvent{
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[self color] setFill];
    
    NSRectFill(NSMakeRect(0, 0, 2, NSHeight(self.frame)));
    
    if(_replyObject.replyThumb) {
        //[NSColorFromRGB(0xf3f3f3) set];
        
       // NSRectFill(NSMakeRect(NSMinX(self.thumbImageView.frame) - 1, 0, NSWidth(self.thumbImageView.frame) + 2, NSHeight(self.thumbImageView.frame) + 2));
    }

   
}

@end
