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
@interface MessageReplyContainer ()
@property (nonatomic,strong) TGTextLabel *nameView;

@property (nonatomic,strong) TGImageView *thumbImageView;
@property (nonatomic,strong) NSImageView *locationImageView;

@property (nonatomic,strong) NSImageView *deleteImageView;
@property (nonatomic,strong) TMTextField *loadingTextField;


@end

@implementation MessageReplyContainer



-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _loadingTextField = [TMTextField defaultTextField];
        [_loadingTextField setFont:TGSystemFont(13)];
        [_loadingTextField setStringValue:NSLocalizedString(@"Reply.Loading", nil)];
        [_loadingTextField sizeToFit];
        [_loadingTextField setFrameOrigin:NSMakePoint(6, 0)];
        
        self.nameView = [[TGTextLabel alloc] initWithFrame:NSMakeRect(15, NSHeight(frameRect) - 13, 200, 20)];
        
        [self addSubview:self.nameView];
        
        
       // [self addSubview:self.dateField];
        
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
        
    }
    
    
    return self;
}

-(void)setDeleteHandler:(dispatch_block_t)deleteHandler {
    _deleteHandler = deleteHandler;
    
    [self update];
}

-(void)setReplyObject:(TGReplyObject *)replyObject {
    _replyObject = replyObject;
    
    [self update];
}


-(NSColor *)color {
    
    NSRange range = NSMakeRange(0, 1);
    
    if(_replyObject.replyHeader.string.length == 0)
    {
        return BLUE_SEPARATOR_COLOR;
    }
    
    return [_replyObject.replyHeader attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:&range];
}


-(int)xOffset {
    return _replyObject.replyThumb || _replyObject.geoURL ? _replyObject.replyThumb.imageSize.width + [MessageTableItem defaultOffset] *2 : [MessageTableItem defaultOffset];
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
    
    [_thumbImageView setFrameOrigin:NSMakePoint([MessageTableItem defaultOffset], 1)];
    [_locationImageView setFrameOrigin:NSMakePoint([MessageTableItem defaultOffset], 1)];
    
    [self.nameView setText:[_replyObject replyHeader] maxWidth:NSWidth(self.frame) - self.xOffset height:_replyObject.replyHeaderHeight];
    
    
    [self.messageField setText:_replyObject.replyText maxWidth:NSWidth(self.frame) - self.xOffset height:_replyObject.replyHeight];
    
    [self.messageField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.messageField.frame), self.replyObject.replyHeight)];
    [self.messageField setFrameOrigin:NSMakePoint(self.xOffset, 0)];

    
    if(_deleteHandler != nil)
    {
        _deleteImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(NSWidth(self.frame) - image_CancelReply().size.width, NSHeight(self.frame) - image_CancelReply().size.height, image_CancelReply().size.width, image_CancelReply().size.height)];
        
        _deleteImageView.image = image_CancelReply();
        
        weak();
        
        [_deleteImageView setCallback:^{
            
            weakSelf.deleteHandler();
            
        }];
        
        [_deleteImageView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
        
        [self addSubview:_deleteImageView];
    } else {
        [_deleteImageView removeFromSuperview];
        _deleteImageView = nil;
    }
    
    [self setNeedsDisplay:YES];
    
    [self setFrame:self.frame];
    
}

-(void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    
    [self.messageField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.messageField.frame), self.replyObject.replyHeight)];
    
    [self.nameView setFrameOrigin:NSMakePoint(self.xOffset, NSHeight(self.frame) - NSHeight(_nameView.frame))];
    
    [_loadingTextField setCenteredYByView:self];
}

-(void)setBackgroundColor:(NSColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    [self.messageField setBackgroundColor:backgroundColor];
    [self.nameView setBackgroundColor:backgroundColor];
}

-(void)mouseUp:(NSEvent *)theEvent {
    
    if(!_deleteHandler) {
        if(_item.table.viewController.state == MessagesViewControllerStateNone)
            [_item.table.viewController showMessage:_replyObject.replyMessage fromMsg:_item.message flags:ShowMessageTypeReply];
    }
    
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
