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
@interface MessageReplyContainer ()
@property (nonatomic,strong) TMHyperlinkTextField *nameTextField;

@property (nonatomic,strong) TMTextField *dateField;
@property (nonatomic,strong) TGImageView *thumbImageView;
@property (nonatomic,strong) NSImageView *locationImageView;

@property (nonatomic,strong) NSImageView *deleteImageView;


@end

@implementation MessageReplyContainer



-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.nameTextField = [[TMHyperlinkTextField alloc] initWithFrame:NSMakeRect(15, NSHeight(frameRect) - 13, 200, 20)];
        [self.nameTextField setBordered:NO];
        [self.nameTextField setFont:TGSystemMediumFont(13)];
        [self.nameTextField setDrawsBackground:NO];
        //[self.nameTextField setBackgroundColor:[NSColor redColor]];
        
        [self addSubview:self.nameTextField];
        
        self.dateField = [TMTextField defaultTextField];
        
        [self.dateField setTextColor:GRAY_TEXT_COLOR];
        [self.dateField setFont:TGSystemFont(12)];
        
       // [self addSubview:self.dateField];
        
        _messageField = [[TGCTextView alloc] initWithFrame:NSZeroRect];
        
        [_messageField setEditable:NO];
        
        [self.messageField setBackgroundColor:[NSColor whiteColor]];

        [self.messageField setFrameOrigin:NSMakePoint(15, 0)];
        
        [self addSubview:self.messageField];
        
        self.thumbImageView = [[TGImageView alloc] initWithFrame:NSMakeRect(5, 1, NSHeight(self.frame) - 2, NSHeight(self.frame) - 2)];
        
        self.thumbImageView.cornerRadius = 3;
        
        self.locationImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(5, 1, NSHeight(self.frame) - 2, NSHeight(self.frame) - 2)];
        
        [self.thumbImageView setContentMode:BTRViewContentModeCenter];
        
        self.locationImageView.layer.cornerRadius = 3;
        
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



-(void)update {
    
   
    int xOffset = _replyObject.replyThumb || _replyObject.geoURL ? 40 : 6;
    
    
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
  
    [self.nameTextField setAttributedStringValue:[_replyObject replyHeader]];
    [self.nameTextField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.messageField.frame),_replyObject.replyHeaderHeight)];
    
    
    [self.nameTextField setFrameOrigin:NSMakePoint(xOffset, NSHeight(self.frame))];
    
    
    [self.messageField setAttributedString:_replyObject.replyText];
    
    [self.messageField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.messageField.frame), self.replyObject.replyHeight)];
    [self.messageField setFrameOrigin:NSMakePoint(xOffset + 2, 0)];
    
  //  [_messageField setEditable:_deleteHandler == nil];
    
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
    
    [self.nameTextField setFrameOrigin:NSMakePoint(NSMinX(self.nameTextField.frame), NSHeight(self.frame) - _replyObject.replyHeaderHeight + 6)];
}

-(void)setBackgroundColor:(NSColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    [self.messageField setBackgroundColor:backgroundColor];
}

-(void)mouseUp:(NSEvent *)theEvent {
    
    if(!_deleteHandler) {
        if(_item.table.viewController.state == MessagesViewControllerStateNone)
            [_item.table.viewController showMessage:_replyObject.replyMessage fromMsg:_item.message flags:ShowMessageTypeReply];
    }
    
}

-(void)mouseDragged:(NSEvent *)theEvent {
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[self color] setFill];
    
    NSRectFill(NSMakeRect(0, 0, 2, NSHeight(self.frame)));
    
    if(_replyObject.replyThumb) {
        [NSColorFromRGB(0xf3f3f3) set];
        
        NSRectFill(NSMakeRect(NSMinX(self.thumbImageView.frame) - 1, 0, NSWidth(self.thumbImageView.frame) + 2, NSHeight(self.thumbImageView.frame) + 2));
    }

   
}

@end
