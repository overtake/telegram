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
@property (nonatomic,strong) TMTextField *messageField;
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
        [self.nameTextField setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:13]];
        [self.nameTextField setDrawsBackground:NO];
        
        [self addSubview:self.nameTextField];
        
        self.dateField = [TMTextField defaultTextField];
        
        [self.dateField setTextColor:NSColorFromRGB(0x999999)];
        [self.dateField setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
        
       // [self addSubview:self.dateField];
        
        self.messageField = [TMTextField defaultTextField];
        
        [self.messageField setFont:[NSFont fontWithName:@"HelveticaNeue" size:13]];
        [self.messageField setTextColor:NSColorFromRGB(0x060606)];
        
        [self.messageField setFrameOrigin:NSMakePoint(15, 0)];
        
        [[self.messageField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.messageField cell] setTruncatesLastVisibleLine:YES];
        
        [self addSubview:self.messageField];
        
        
        
        self.thumbImageView = [[TGImageView alloc] initWithFrame:NSMakeRect(15, 1, NSHeight(self.frame) - 2, NSHeight(self.frame) - 2)];
        
        self.thumbImageView.cornerRadius = 3;
        
        self.locationImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(15, 1, NSHeight(self.frame) - 2, NSHeight(self.frame) - 2)];
        
        
        
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
        return LINK_COLOR;
    }
    
    return [_replyObject.replyHeader attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:&range];
}



-(void)update {
    
   
    int xOffset = _replyObject.replyThumb || _replyObject.geoURL ? 50 : 10;
    
    
    
    if(_replyObject.replyThumb) {
        [self addSubview:self.thumbImageView];
        [self.thumbImageView setObject:_replyObject.replyThumb];
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
    [self.nameTextField sizeToFit];
    
    [self.nameTextField setFrameOrigin:NSMakePoint(xOffset, NSMinY(self.nameTextField.frame))];
    
    [self.messageField setAutoresizingMask:NSViewWidthSizable];
    
    [self.messageField setAttributedStringValue:_replyObject.replyText];
    
    [self.messageField sizeToFit];
    
    [self.messageField setFrameOrigin:NSMakePoint(xOffset, NSMinY(self.messageField.frame))];
    
    [self.messageField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.messageField.frame), NSHeight(self.messageField.frame))];
    
    
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
    
}

-(void)mouseUp:(NSEvent *)theEvent {
    
    if(!_deleteHandler) {
        
        // go to message
        
        [[Telegram rightViewController].messagesViewController showMessage:_replyObject.replyMessage.n_id];
        
    }
    
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
