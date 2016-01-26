//
//  TGConversationTableCell.m
//  Telegram
//
//  Created by keepcoder on 14.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGConversationTableCell.h"
#import "TGCTextView.h"
#import "TGTimer.h"
#import "TGSwipeTableControll.h"

@interface ShortUnread : NSView
@property (nonatomic, strong) NSString *unreadCount;
@property (nonatomic) NSSize undreadSize;
@property (nonatomic,strong) NSColor *color;
@end

@implementation ShortUnread


static NSDictionary *attributes() {
    static NSDictionary *dictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = @{NSFontAttributeName: TGSystemBoldFont(11), NSForegroundColorAttributeName:NSColorFromRGB(0xfafafa)};
    });
    return dictionary;
}

- (void)setUnreadCount:(NSString *)unreadCount {
    self->_unreadCount = unreadCount;
    NSSize size = [unreadCount sizeWithAttributes:attributes()];
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
    self.undreadSize = size;
    [self draw];
}

- (void)draw {
    NSSize size = self.undreadSize;
    
    float width = MAX(22, size.width + 14);
    [self setFrame:NSMakeRect(62 - width, 6, width, 22)];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(!self.unreadCount.length) {
        return;
    }
    
    float center = roundf(self.bounds.size.width / 2.0);
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(1, 11)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(1, 21) toPoint:NSMakePoint(center, 21) radius:10];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(self.bounds.size.width - 1, 21) toPoint:NSMakePoint(self.bounds.size.width - 1, 11) radius:10];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(self.bounds.size.width - 1, 1) toPoint:NSMakePoint(center, 1) radius:10];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(1, 1) toPoint:NSMakePoint(1, 11) radius:10];
    [path setLineWidth:2];
    
    [[NSColor whiteColor] setStroke];
    [path stroke];
    
    
    [_color setFill];
    [path fill];
    
    [[NSColor whiteColor] set];
    [self.unreadCount drawAtPoint:NSMakePoint(8, 4) withAttributes:attributes()];
}

@end


@interface TGConversationTableCell ()


// views

@property (nonatomic,strong) TMTextField *dateField;
@property (nonatomic,strong) TMTextField *messageField;
@property (nonatomic,strong) TMNameTextField *nameTextField;
@property (nonatomic,strong) TMAvatarImageView *photoImageView;

@property (nonatomic,strong) NSImageView *stateImageView;
@property (nonatomic,strong) ShortUnread *shortUnread;

@property (nonatomic,strong) TGTimer *timer;
@property (nonatomic,strong) NSString *dots;
@property (nonatomic,strong) TGSwipeTableControll *swipe;

@property (nonatomic,strong) TMView *containerView;

@property (nonatomic,assign) BOOL isActiveDragging;

@end





@implementation TGConversationTableCell


-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    
    TL_conversation *conversation = [(TGConversationTableItem *)self.rowItem conversation];
    
    if(!conversation.canSendMessage)
        return NSDragOperationNone;
    
    self.isActiveDragging = YES;
    
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( ![pboard.name isEqualToString:TGImagePType] ) {
        if (sourceDragMask) {
            return NSDragOperationLink;
        }
    }
    
    return NSDragOperationNone;
}


-(void)draggingExited:(id<NSDraggingInfo>)sender {
    
    self.isActiveDragging = NO;
}

-(void)draggingEnded:(id<NSDraggingInfo>)sender {

    self.isActiveDragging = NO;
    
}


-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    TL_conversation *conversation = [(TGConversationTableItem *)self.rowItem conversation];
    
    [appWindow().navigationController showMessagesViewController:conversation];
    
    [MessageSender sendDraggedFiles:sender dialog:conversation asDocument:NO];
    
    return YES;
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,NSStringPboardType,NSTIFFPboardType, nil]];
        
       // self.wantsLayer = YES;
        
        _swipe = [[TGSwipeTableControll alloc] initWithFrame:frameRect itemView:self];
        
        [self setSwipePanelActive:YES];
        
        
        _photoImageView = [TMAvatarImageView standartTableAvatar];
        _photoImageView.wantsLayer = YES;
        
        
        _nameTextField = [[TMNameTextField alloc] init];
        
        
        [_nameTextField setFrameOrigin:NSMakePoint(68, 36)];
        
        [[_nameTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[_nameTextField cell] setTruncatesLastVisibleLine:YES];
        
        _nameTextField.wantsLayer = YES;

        
//        [_nameTextField setBackgroundColor:[NSColor redColor]];
//        [_nameTextField setDrawsBackground:YES];
        
        _messageField = [TMTextField defaultTextField];
        
        [_messageField setFrameOrigin:NSMakePoint(68, 3)];
        
        _messageField.wantsLayer = YES;
        
        [_messageField setDrawsBackground:NO];
     //   [_messageField setBackgroundColor:[NSColor blueColor]];
        [[_messageField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[_messageField cell] setTruncatesLastVisibleLine:YES];
        
        
        _dateField = [TMTextField defaultTextField];
        [_dateField setFrameOrigin:NSMakePoint(0, 40)];
        
        _dateField.wantsLayer = YES;
        [_dateField setFont:TGSystemFont(12)];
        
      
        
        [_swipe addSubview:_dateField];
        [_swipe addSubview:_photoImageView];
        
        [_swipe addSubview:_messageField];
        
        [_swipe addSubview:_nameTextField];
        
        [self addSubview:_swipe];
        
        
        dispatch_block_t block = ^{
            NSColor *color = nil;
            if(!self.isSelected) {
                
                 _swipe.layer.backgroundColor = [NSColor clearColor].CGColor;
                
                color = [NSColor whiteColor];
                [color set];
                NSRectFill(NSMakeRect(0, 0, self.bounds.size.width - DIALOG_BORDER_WIDTH, self.bounds.size.height));
                
                
                [DIALOG_BORDER_COLOR setFill];
                NSRectFill(NSMakeRect(NSMinX(_nameTextField.frame) +2, 0, NSWidth(self.frame) - NSMinX(_nameTextField.frame), 1));
                
            } else {
                color = BLUE_COLOR_SELECT;
                [color set];
                NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height));
                 _swipe.layer.backgroundColor = color.CGColor;
            }
            
            if(self.isActiveDragging)
            {
                [GRAY_BORDER_COLOR set];
                NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height));
            }
            
            
            if(self.item.conversation.isVerified) {
                [self.isSelected ? image_VerifyWhite() : image_Verify() drawInRect:NSMakeRect(NSMaxX(self.nameTextField.frame),NSMinY(self.nameTextField.frame) + 6, image_Verify().size.width, image_Verify().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
            }
            
         //
            
            if(self.item.unreadText.length && self.style != ConversationTableCellShortStyle && self.item.conversation.unread_count > 0)
                [self drawUnreadCount]; 
        };
        
        
        
        
        [_swipe.containerView setDrawBlock:block];
        
    }
    
    return self;
}

-(void)setIsActiveDragging:(BOOL)isActiveDragging {
    _isActiveDragging = isActiveDragging;
    
    [_swipe.containerView setNeedsDisplay:YES];
}

-(void)setFrameSize:(NSSize)newSize {
    
    [super setFrameSize:newSize];
    
    [self updateFrames];
}


-(void)updateFrames {
    
    NSValue *point = [self stateImage][@"point"];
    
     [_swipe setFrameSize:self.frame.size];
    
    self.style = NSWidth(self.frame) == 70 ? ConversationTableCellShortStyle : ConversationTableCellFullStyle;
    
    
    [_nameTextField setFrameSize:NSMakeSize(MIN(NSWidth(self.frame) - NSMinX(_nameTextField.frame) - NSWidth(_dateField.frame) - 10 - (self.item.message.n_out ? 18 : 0), self.item.nameTextSize.width), 23)];
    [_messageField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(_messageField.frame) -40, 36)];
    [_dateField setFrameOrigin:NSMakePoint(self.bounds.size.width - self.item.dateSize.width - 10, _dateField.frame.origin.y)];

    
    point = [self stateImage][@"point"];
    
    if(point) {
        [_stateImageView setFrame:NSMakeRect([point pointValue].x, [point pointValue].y, NSWidth(_stateImageView.frame), NSHeight(_stateImageView.frame))];
    }
    
    
    if(self.style == ConversationTableCellShortStyle && self.item.unreadText != nil && self.item.conversation.unread_count > 0 && self.item.conversation.lastMessage.from_id != [UsersManager currentUserId])
    {
        if(!_shortUnread) {
            _shortUnread = [[ShortUnread alloc] init];
            _shortUnread.wantsLayer = YES;
            [self.layer addSublayer:_shortUnread.layer];
        }
        
        _shortUnread.color = self.item.conversation.isMute && ![SettingsArchiver checkMaskedSetting:IncludeMutedUnreadCount] ? NSColorFromRGB(0xd7d7d7) : NSColorFromRGB(0x4ba3e2);
        [_shortUnread setUnreadCount:self.item.unreadText];
        
    } else {
        [_shortUnread.layer removeFromSuperlayer];
        _shortUnread = nil;
    }
    
    [_swipe.containerView setNeedsDisplay:YES];
}


-(void)checkMessageState {
    
    if(self.item.typing.length > 0) {
        [self startAnimation];
    } else {
        [_messageField setAttributedStringValue:self.item.messageText];
        [_timer invalidate];
        _timer = nil;
        _dots = @"";
    }
    
}


-(void)startAnimation {
    
    [_timer invalidate];
    _timer = nil;
    
    _timer = [[TGTimer alloc] initWithTimeout:0.25 repeat:YES completion:^{
        
        _dots = [NSString stringWithFormat:@"%@.",[_dots substringWithRange:NSMakeRange(0, _dots.length >=3 ? 0 : _dots.length)]];
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:[NSString stringWithFormat:@"%@%@",self.item.typing,_dots] withColor:GRAY_TEXT_COLOR];
        [attr setSelectionColor:[NSColor whiteColor] forColor:GRAY_TEXT_COLOR];
        [attr setFont:TGSystemFont(13) forRange:attr.range];
        [attr setSelected:self.isSelected];
        
        
        
        [_messageField setAttributedStringValue:attr];
        
        if(self.item.typing.length == 0) {
            [_timer invalidate];
            _timer = nil;
            [self checkMessageState];
        }
        
    } queue:[ASQueue mainQueue].nativeQueue];
    
    [_timer start];
    [_timer fire];
}


-(void)redrawRow {
    [self setItem:[self item]];
}

-(TGConversationTableItem *)item {
    return (TGConversationTableItem *)  [self rowItem];
}

-(void)setItem:(TGConversationTableItem *)item {
    
    [_photoImageView updateWithConversation:item.conversation];
    
    _nameTextField.attach = nil;
    _nameTextField.selectedAttach = nil;
    
    
    [_nameTextField clear];
    [_nameTextField setSelected:self.isSelected];
    
    
    [item.messageText setSelected:self.isSelected];
    [item.dateText setSelected:self.isSelected];
    
    if(item.conversation.isMute)
    {
        static NSTextAttachment *attach;
        static NSTextAttachment *selectedAttach;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            attach = [NSMutableAttributedString textAttachmentByImage:[image_muted() imageWithInsets:NSEdgeInsetsMake(0, 4, 0, 0)]];
            selectedAttach = [NSMutableAttributedString textAttachmentByImage:[image_mutedSld() imageWithInsets:NSEdgeInsetsMake(0, 4, 0, 0)]];
        });
        
        _nameTextField.attach = attach;
        _nameTextField.selectedAttach = selectedAttach;
    }
    
    
    
    [_nameTextField updateWithConversation:item.conversation];
    
    
    [self checkMessageState];
    
    
    [self.dateField setAttributedStringValue:item.dateText];
    
    [self.dateField setFrameSize:NSMakeSize(item.dateSize.width, 18)];
    
    
    NSDictionary *stateImage = [self stateImage];
    
    
    if(stateImage) {
        if(!_stateImageView) {
            _stateImageView = imageViewWithImage(stateImage[@"image"]);
            
            [_swipe addSubview:_stateImageView];
        } else {
            _stateImageView.image = stateImage[@"image"];
            [_stateImageView setFrameSize:_stateImageView.image.size];
        }
    } else {
        [_stateImageView removeFromSuperview];
        _stateImageView = nil;
    }
    

    
    [self updateFrames];
    
    

}


-(NSDictionary *)stateImage {
    if(self.item.message.n_out) {
        
        NSImage *stateImage;
        
        NSPoint point;
        
            if(self.item.message.dstate == DeliveryStateNormal) {
                
                if(!self.item.message.unread) {
                    stateImage = self.isSelected ? image_MessageStateReadWhite() : image_MessageStateRead();
                } else {
                    stateImage = self.isSelected ? image_MessageStateSentWhite() : image_MessageStateSent();
                }
                
                point = NSMakePoint(NSMinX(self.dateField.frame) - stateImage.size.width , NSHeight(self.frame) - stateImage.size.height - 12);
                
            } else if(self.item.message.dstate == DeliveryStateError) {
                
                stateImage = self.isSelected ? image_DialogSelectedSendError() : image_ChatMessageError() ;
                
                point = NSMakePoint(NSWidth(self.frame) - stateImage.size.width - 13, 10);
                
            } else if(self.item.message.dstate == DeliveryStatePending) {
                
                stateImage = self.isSelected ? image_SendingClockWhite() : image_SendingClockGray();
                
                point = NSMakePoint(NSMinX(self.dateField.frame) - stateImage.size.width -2, NSHeight(self.frame) - stateImage.size.height - 11);
                
            }
            
            return @{@"image":stateImage,@"point":[NSValue valueWithPoint:point]};
            
    }
    
    return nil;
}

-(void)setStyle:(ConversationTableCellStyle)style {
    
    _style = style;
    
    [_nameTextField setHidden:style == ConversationTableCellShortStyle];
    [_messageField setHidden:style == ConversationTableCellShortStyle];
    [_dateField setHidden:style == ConversationTableCellShortStyle];
    [_stateImageView setHidden:style == ConversationTableCellShortStyle];
}


- (void)drawRect:(NSRect)dirtyRect {
    
    
}


static int unreadCountRadius = 10;
static int unreadOffsetRight = 13;

- (void)drawUnreadCount {
    
    static int offsetY = 9;
    
    int sizeWidth = MAX(self.item.unreadTextSize.width + 12, unreadCountRadius * 2);
    
    int offset2 = self.bounds.size.width - unreadOffsetRight - unreadCountRadius;
    int offset1 = offset2 - (sizeWidth - unreadCountRadius * 2);
    
    NSBezierPath * path = [NSBezierPath bezierPath];
    NSPoint center1 = {
        offset1,
        offsetY + unreadCountRadius
    };
    [path moveToPoint: center1];
    [path appendBezierPathWithArcWithCenter: center1 radius: unreadCountRadius startAngle: 90 endAngle: -90];
    
    NSPoint center2 = {
        offset2,
        offsetY + unreadCountRadius
    };
    [path moveToPoint: center2];
    [path appendBezierPathWithArcWithCenter: center2 radius: unreadCountRadius startAngle: -90 endAngle: 90];
    
    [path appendBezierPathWithRect:NSMakeRect(center1.x, center1.y-unreadCountRadius, center2.x-center1.x, unreadCountRadius*2)];
    if(self.isSelected) {
        [NSColorFromRGB(0xffffff) set];
        
    } else {
        if(!self.item.conversation.isMute || [SettingsArchiver checkMaskedSetting:IncludeMutedUnreadCount])
            [NSColorFromRGB(0x4ba3e2) set];
        else
            [NSColorFromRGB(0xd7d7d7) set];
    }
    [path fill];
    [path closePath];
    
    int offsetX = (sizeWidth - self.item.unreadTextSize.width)/2;
    [self.item.unreadText drawAtPoint:CGPointMake(offset1 - unreadCountRadius + offsetX, offsetY + 3) withAttributes:@{NSForegroundColorAttributeName: self.isSelected ? NSColorFromRGB(0x6896ba)  : [NSColor whiteColor], NSFontAttributeName: TGSystemBoldFont(11)}];
}

-(BOOL)isSelected {
    return self.item.table.selectedItem == self.item;
}

-(void)rightMouseDown:(NSEvent *)theEvent {
    [super rightMouseDown:theEvent];
    
    [TGConversationsViewController showPopupMenuForDialog:self.item.conversation withEvent:theEvent forView:self];

}

-(void)dealloc {
    [Notification removeObserver:self];
}

-(TGConversationsTableView *)tableView {
    return (TGConversationsTableView *) self.item.table;
}

@end
