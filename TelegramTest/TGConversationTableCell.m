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

@interface ShortUnread : NSView
@property (nonatomic, strong) NSString *unreadCount;
@property (nonatomic) NSSize undreadSize;
@end

@implementation ShortUnread


static NSDictionary *attributes() {
    static NSDictionary *dictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = @{NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-Bold" size:11], NSForegroundColorAttributeName:NSColorFromRGB(0xfafafa)};
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
    
    [NSColorFromRGB(0x4ba3e2) setFill];
    [path fill];
    
    [[NSColor whiteColor] set];
    [self.unreadCount drawAtPoint:NSMakePoint(8, 4) withAttributes:attributes()];
}

@end


@interface TGConversationTableCell ()
@property (nonatomic,weak) TGConversationTableItem *item;


// views

@property (nonatomic,strong) TMTextField *dateField;
@property (nonatomic,strong) TMTextField *messageField;
@property (nonatomic,strong) TMNameTextField *nameField;
@property (nonatomic,strong) TMAvatarImageView *photoImageView;

@property (nonatomic,strong) NSImageView *stateImageView;
@property (nonatomic,strong) ShortUnread *shortUnread;

@property (nonatomic,strong) TGTimer *timer;
@property (nonatomic,strong) NSString *dots;

@end





@implementation TGConversationTableCell

- (void)drawRect:(NSRect)dirtyRect {
    
    
    NSColor *color = nil;
    if(!self.isSelected) {
        color = [NSColor whiteColor];
        [color set];
        NSRectFill(NSMakeRect(0, 0, self.bounds.size.width - DIALOG_BORDER_WIDTH, self.bounds.size.height));
        
        
        [DIALOG_BORDER_COLOR setFill];
        NSRectFill(NSMakeRect(NSMinX(_nameField.frame) +2, 0, NSWidth(self.frame) - NSMinX(_nameField.frame), 1));
        
    } else {
        color = BLUE_COLOR_SELECT;
        [color set];
        NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height));
    }
    
    
    if(self.item.unreadText.length && self.style != ConversationTableCellShortStyle)
        [self drawUnreadCount];
    
    
}


static int unreadCountRadius = 10;
static int unreadOffsetRight = 13;

- (void)drawUnreadCount {
    
    static int offsetY = 9;
    
    int sizeWidth = MAX(_item.unreadTextSize.width + 12, unreadCountRadius * 2);
    
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
        [NSColorFromRGB(0x4ba3e2) set];
    }
    [path fill];
    [path closePath];
    
    int offsetX = (sizeWidth - _item.unreadTextSize.width)/2;
    [_item.unreadText drawAtPoint:CGPointMake(offset1 - unreadCountRadius + offsetX, offsetY + 3) withAttributes:@{NSForegroundColorAttributeName: self.isSelected ? NSColorFromRGB(0x6896ba)  : [NSColor whiteColor], NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-Bold" size:11]}];
}

-(BOOL)isSelected {
    return self.item.table.selectedItem == self.item;
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.wantsLayer = YES;
        
        self.layer.backgroundColor = DIALOG_BORDER_COLOR.CGColor;
        
        _photoImageView = [TMAvatarImageView standartTableAvatar];
        _photoImageView.wantsLayer = YES;
        
        
        _nameField = [[TMNameTextField alloc] initWithFrame:NSMakeRect(68, 40, 0, 18)];
         _nameField.wantsLayer = YES;
        
        [_nameField setSelector:@selector(dialogTitle)];
        [_nameField setEncryptedSelector:@selector(dialogTitleEncrypted)];
        [[_nameField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        
        [_nameField setDrawsBackground:NO];
      //  [_nameField setBackgroundColor:[NSColor redColor]];
        
       
        
        _messageField = [TMTextField defaultTextField];
        
        [_messageField setFrameOrigin:NSMakePoint(68, 3)];
        
        _messageField.wantsLayer = YES;
        
        [_messageField setDrawsBackground:NO];
     //   [_messageField setBackgroundColor:[NSColor blueColor]];
        [[_messageField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[_messageField cell] setTruncatesLastVisibleLine:YES];
        
        
        _dateField = [TMTextField defaultTextField];
        [_dateField setFrameOrigin:NSMakePoint(0, 46)];
        
        _dateField.wantsLayer = YES;
        
        [_dateField setAutoresizingMask:NSViewMinXMargin];
        [_dateField setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
        
        [self addSubview:_nameField];
        
        
    
        
        
        [self.layer addSublayer:_dateField.layer];
        [self.layer addSublayer:_photoImageView.layer];
        
        [self.layer addSublayer:_messageField.layer];
        
        
        
    }
    
    return self;
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    
    
    [self updateFrames];
}

-(void)updateFrames {
    
    self.style = NSWidth(self.frame) == 70 ? ConversationTableCellShortStyle : ConversationTableCellFullStyle;
    
    [_nameField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(_nameField.frame) - NSWidth(_dateField.frame) - 10 - (_item.message.n_out ? 18 : 0), 23)];
    [_messageField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(_nameField.frame) -40, 36)];
    [_dateField setFrameOrigin:NSMakePoint(self.bounds.size.width - _item.dateSize.width - 10, _dateField.frame.origin.y)];
    
    NSValue *point = [self stateImage][@"point"];
    
    if(point) {
        [_stateImageView setFrame:NSMakeRect([point pointValue].x, [point pointValue].y, NSWidth(_stateImageView.frame), NSHeight(_stateImageView.frame))];
    }
    
    
    if(self.style == ConversationTableCellShortStyle && _item.unreadText != nil)
    {
        if(!_shortUnread) {
            _shortUnread = [[ShortUnread alloc] init];
            _shortUnread.wantsLayer = YES;
            [self.layer addSublayer:_shortUnread.layer];
        }
        
        [_shortUnread setUnreadCount:_item.unreadText];
        
    } else {
        [_shortUnread.layer removeFromSuperlayer];
        _shortUnread = nil;
    }
    
}


-(void)didChangeTyping:(NSNotification *)notify {
    
    NSArray *actions;
    
    if(!notify) {
        actions = [[TGModernTypingManager typingForConversation:_item.conversation] currentActions];
    } else {
        actions = notify.userInfo[@"users"];
    }

    if(actions.count > 0) {
        
        NSString *string;
        
        if(actions.count == 1) {
            
            TGActionTyping *action = actions[0];
            
           // if(_item.conversation.type == DialogTypeChat) {
                TLUser *user = [[UsersManager sharedManager] find:action.user_id];
                if(user)
                    string =[NSString stringWithFormat:NSLocalizedString(NSStringFromClass(action.action.class), nil),user.first_name];
         //   } else {
          //      string = NSLocalizedString(@"Typing.Typing", nil);
         //   }
            
        } else {
            
            string = [NSString stringWithFormat:NSLocalizedString(@"Typing.PeopleTyping", nil), (int)actions.count];
            
        }
        
        [self startAnimationWithMainString:string];
        
    } else {
        [_messageField setAttributedStringValue:_item.messageText];
        [_timer invalidate];
        _timer = nil;
        _dots = @"";
    }
    
}


-(void)startAnimationWithMainString:(NSString *)string {
    
    [_timer invalidate];
    _timer = nil;
    
    _timer = [[TGTimer alloc] initWithTimeout:0.25 repeat:YES completion:^{
        
        _dots = [NSString stringWithFormat:@"%@.",[_dots substringWithRange:NSMakeRange(0, _dots.length >=3 ? 0 : _dots.length)]];
        
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:[NSString stringWithFormat:@"%@%@",string,_dots] withColor:NSColorFromRGB(0x999999)];
        [attr setSelectionColor:[NSColor whiteColor] forColor:NSColorFromRGB(0x999999)];
        [attr setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:attr.range];
        [attr setSelected:self.isSelected];
        
        [_messageField setAttributedStringValue:attr];
        
    } queue:[ASQueue mainQueue].nativeQueue];
    
    [_timer start];
    [_timer fire];
}

-(void)setItem:(TGConversationTableItem *)item {
    _item = item;
    
    [Notification removeObserver:self];
    
    [Notification addObserver:self selector:@selector(didChangeTyping:) name:[Notification notificationNameByDialog:item.conversation action:@"typing"]];
    
    [_photoImageView updateWithConversation:item.conversation];
    
    _nameField.attach = nil;
    _nameField.selectedAttach = nil;
    
    
    [_nameField clear];
    [_nameField setSelected:self.isSelected];
    
    
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
        
        _nameField.attach = attach;
        _nameField.selectedAttach = selectedAttach;
    }
    
    
    
    [_nameField updateWithConversation:item.conversation];
    
    
    [self didChangeTyping:nil];
    
    
    [self.dateField setAttributedStringValue:item.dateText];
    
    [self.dateField setFrameSize:item.dateSize];
    
    
    NSDictionary *stateImage = [self stateImage];
    
    
    if(stateImage) {
        if(!_stateImageView) {
            _stateImageView = imageViewWithImage(stateImage[@"image"]);
            
            [self addSubview:_stateImageView];
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
    if(_item.message.n_out) {
        
        NSImage *stateImage;
        
        NSPoint point;
        
        if(self.style != ConversationTableCellShortStyle) {
            if(self.item.message.dstate == DeliveryStateNormal) {
                
                if(!self.item.message.unread) {
                    stateImage = self.isSelected ? image_MessageStateReadWhite() : image_MessageStateRead();
                } else {
                    stateImage = self.isSelected ? image_MessageStateSentWhite() : image_MessageStateSent();
                }
                
                point = NSMakePoint(NSMinX(self.dateField.frame) - stateImage.size.width , NSHeight(self.frame) - stateImage.size.height - 10);
                
            } else if(self.item.message.dstate == DeliveryStateError) {
                
                stateImage = self.isSelected ? image_DialogSelectedSendError() : image_ChatMessageError() ;
                
                point = NSMakePoint(NSWidth(self.frame) - stateImage.size.width - 13, 6);
                
            } else if(self.item.message.dstate == DeliveryStatePending) {
                
                stateImage = self.isSelected ? image_SendingClockWhite() : image_SendingClockGray();
                
                point = NSMakePoint(NSMinX(self.dateField.frame) - stateImage.size.width -2, NSHeight(self.frame) - stateImage.size.height - 9);
                
            }
            
            return @{@"image":stateImage,@"point":[NSValue valueWithPoint:point]};
            
        }
    }
    
    return nil;
}

-(void)setStyle:(ConversationTableCellStyle)style {
    
    if(_style == style)
        return;
    
    _style = style;
    
    [self.nameField setHidden:style == ConversationTableCellShortStyle];
    [self.messageField setHidden:style == ConversationTableCellShortStyle];
    [self.dateField setHidden:style == ConversationTableCellShortStyle];
    [self.stateImageView setHidden:style == ConversationTableCellShortStyle];
}


- (void) checkSelected:(BOOL)isSelected {
    
}

-(void)rightMouseDown:(NSEvent *)theEvent {
    [super rightMouseDown:theEvent];
    
    [TGConversationsViewController showPopupMenuForDialog:_item.conversation withEvent:theEvent forView:self];

}

-(void)dealloc {
    [Notification removeObserver:self];
}

@end
