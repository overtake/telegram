//
//  DialogTableItemView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/18/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "ConversationTableItemView.h"
#import "NS(Attributed)String+Geometrics.h"
#import "TMElements.h"
#import "TMAttributedString.h"
#import "ITSwitch.h"
#import "TMAvatarImageView.h"
#import "TGTimer.h"
#import "TMNameTextField.h"
#import "DialogTableView.h"
#import "ImageUtils.h"
#import "TGImageView.h"
@interface DialogShortUnreadCount : NSView
@property (nonatomic, strong) NSString *unreadCount;
@property (nonatomic) NSSize undreadSize;
@end

@implementation DialogShortUnreadCount


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


@interface ConversationTableItemView()

@property (nonatomic, strong) TMNameTextField *titleTextField;
@property (nonatomic, strong) TMTextField *messageTextField;
@property (nonatomic, strong) TMTextField *dateTextField;

@property (nonatomic, strong) TMAvatarImageView *avatarImageView;
@property (nonatomic, strong) DialogShortUnreadCount *shortUnreadCount;
@property (nonatomic, strong) TGTimer *timer;

@property (nonatomic, strong) DialogSwipeTableControll *controll;

- (ConversationTableItem *)rowItem;

@end

@implementation ConversationTableItemView

- (BOOL)isSwipePanelActive {
    return self.swipePanelActive;
}

- (void)setStyle:(DialogTableItemViewStyle)style {
    if(self->_style == style)
        return;
    
    self->_style = style;
    
    TMTableView *tableView = (TMTableView *)self.superview.superview;
    
    
    if(style != DialogTableItemViewFullStyle) {
        [self.titleTextField setHidden:YES];
        [self.messageTextField setHidden:YES];
        [self.dateTextField setHidden:YES];
        [self.shortUnreadCount setHidden:NO];
        
        if(tableView) {
            tableView.scrollView.isHideVerticalScroller = YES;
        }
        
    } else {
        [self.titleTextField setHidden:NO];
        [self.messageTextField setHidden:NO];
        [self.dateTextField setHidden:NO];
        [self.shortUnreadCount setHidden:YES];
    
        
        tableView.scrollView.isHideVerticalScroller = NO;
    }
    [self setNeedsDisplay:YES];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setLayer:[CALayer layer]];
        [self setWantsLayer:YES];
        
        self.swipePanelActive = YES;
        
        weak();
        
        self.controll = [[DialogSwipeTableControll alloc] initWithFrame:self.bounds itemView:self];
        [self.controll setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self.controll setDrawBlock:^{
            
            NSColor *color = nil;
            if(!weakSelf.isSelected) {
                color = [NSColor whiteColor];
                [color set];
                NSRectFill(NSMakeRect(0, 0, weakSelf.bounds.size.width - DIALOG_BORDER_WIDTH, weakSelf.bounds.size.height));
                
                
                [DIALOG_BORDER_COLOR setFill];
                NSRectFill(NSMakeRect(NSMinX(weakSelf.titleTextField.frame) +2, 0, NSWidth(weakSelf.frame) - NSMinX(weakSelf.titleTextField.frame), 1));
                
            } else {
                color = BLUE_COLOR_SELECT;
                [color set];
                NSRectFill(NSMakeRect(0, 0, weakSelf.bounds.size.width, weakSelf.bounds.size.height));
            }
            
            weakSelf.controll.backgroundColor = color;
        }];
        [self.controll.containerView setDrawBlock:^{
            
           if([weakSelf rowItem].isOut) {
               
               NSImage *stateImage;
               
               if(weakSelf.style != DialogTableItemViewShortStyle) {
                   if([weakSelf rowItem].lastMessage.dstate == DeliveryStateNormal) {
                       
                       if([weakSelf rowItem].isRead) {
                           stateImage = weakSelf.isSelected ? image_MessageStateReadWhite() : image_MessageStateRead();
                       } else {
                           stateImage = weakSelf.isSelected ? image_MessageStateSentWhite() : image_MessageStateSent();
                       }
                       
                       [stateImage drawAtPoint:NSMakePoint(NSMinX(weakSelf.dateTextField.frame) - stateImage.size.width , NSHeight(weakSelf.frame) - stateImage.size.height - 14) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
                       
                   } else if([weakSelf rowItem].lastMessage.dstate == DeliveryStateError) {
                       
                       stateImage = weakSelf.isSelected ? image_DialogSelectedSendError() : image_ChatMessageError() ;
                       
                       [stateImage drawAtPoint:NSMakePoint(NSWidth(weakSelf.frame) - stateImage.size.width - 13, 6) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
                       
                   } else if([weakSelf rowItem].lastMessage.dstate == DeliveryStatePending) {
                       
                       stateImage = weakSelf.isSelected ? image_SendingClockWhite() : image_SendingClockGray();
                       
                       [stateImage drawAtPoint:NSMakePoint(NSMinX(weakSelf.dateTextField.frame) - stateImage.size.width -2, NSHeight(weakSelf.frame) - stateImage.size.height - 13) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
                       
                   }
               }
           }
            
            if(weakSelf.style == DialogTableItemViewShortStyle) {
                [weakSelf.shortUnreadCount setUnreadCount:[weakSelf rowItem].unreadTextCount];
                return;
            }
            
            if([weakSelf rowItem].isMuted) {
                NSImage *mutedImage = weakSelf.isSelected ? image_mutedSld() : image_muted();
                [mutedImage drawAtPoint:NSMakePoint(NSMinX(weakSelf.titleTextField.frame) + NSWidth(weakSelf.titleTextField.frame) + 3, weakSelf.dateTextField.frame.origin.y + 3) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
            }
            
            if([weakSelf rowItem].unreadTextCount.length)
                [weakSelf drawUnreadCount];
        }];
        [self.controll setItemView:self];
        [self addSubview:self.controll];
        
        self.avatarImageView = [TMAvatarImageView standartTableAvatar];
        [self.controll addSubview:self.avatarImageView];
        
        
        self.shortUnreadCount = [[DialogShortUnreadCount alloc] init];
        [self.shortUnreadCount setHidden:YES];
        [self.controll addSubview:self.shortUnreadCount];
        
        self.titleTextField = [[TMNameTextField alloc] initWithFrame:NSMakeRect(68, 40, 0, 0)];
        [self.titleTextField setEditable:NO];
        [self.titleTextField setBordered:NO];
        [self.titleTextField setSelector:@selector(dialogTitle)];
        [self.titleTextField setEncryptedSelector:@selector(dialogTitleEncrypted)];
        [self.titleTextField setDrawsBackground:NO];
        [[self.titleTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.titleTextField cell] setTruncatesLastVisibleLine:YES];
        [self.titleTextField setAutoresizingMask:NSViewWidthSizable];
        [self.controll addSubview:self.titleTextField];
        
        self.messageTextField = [[TMTextField alloc] initWithFrame:NSMakeRect(68, 3, 0, 0)];
        [self.messageTextField setEditable:NO];
        [self.messageTextField setBordered:NO];
        [self.messageTextField setBackgroundColor:[NSColor clearColor]];
        [self.messageTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:12.5]];
        [[self.messageTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.messageTextField cell] setTruncatesLastVisibleLine:YES];
        [self.messageTextField setAutoresizingMask:NSViewWidthSizable];
        [self.controll addSubview:self.messageTextField];
        
        self.dateTextField = [[TMTextField alloc] initWithFrame:NSMakeRect(0, 40, 0, 0)];
        [self.dateTextField setAutoresizingMask:NSViewMinXMargin];
        [self.dateTextField setEditable:NO];
        [self.dateTextField setBordered:NO];
        [self.dateTextField setBackgroundColor:[NSColor clearColor]];
        [self.dateTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
        [self.controll addSubview:self.dateTextField];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(tableViewScrollerStyleChangeNotification:)
         name:NSPreferredScrollerStyleDidChangeNotification
         object:nil];
        
        [self tableViewScrollerStyleChangeNotification:nil];
        
    }
    return self;
}

- (void)setTableView:(DialogTableView *)tableView {
    self->_tableView = tableView;
    self.controll.tableView = tableView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) tableViewScrollerStyleChangeNotification:(NSNotification *)notify {
    
    if([self rowItem])
        [self redrawRow];
}

- (ConversationTableItem *)rowItem {
    return (ConversationTableItem *)[super rowItem];
}

- (void)drawRect:(NSRect)dirtyRect {
   
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    self.style = newSize.width == 70 ? DialogTableItemViewShortStyle : DialogTableItemViewFullStyle;
    
    [self.messageTextField setFrameSize:NSMakeSize(newSize.width - 110, 36)];
    
    [self.titleTextField sizeToFit];
    
    [self.titleTextField setFrameSize:NSMakeSize(MIN(NSWidth(self.titleTextField.frame),NSWidth(self.frame) - [self rowItem].dateSize.width - 95 - ([self rowItem].isMuted ? image_muted().size.width + 6 : 0) ), NSHeight(self.titleTextField.frame))];
    
}

static int unreadCountRadius = 10;
static int unreadOffsetRight = 13;

- (void)drawUnreadCount {
    
    static int offsetY = 9;
    
    int sizeWidth = MAX([self rowItem].unreadTextSize.width + 12, unreadCountRadius * 2);
    
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
    
    int offsetX = (sizeWidth - [self rowItem].unreadTextSize.width)/2;
    [[self rowItem].unreadTextCount drawAtPoint:CGPointMake(offset1 - unreadCountRadius + offsetX, offsetY + 3) withAttributes:@{NSForegroundColorAttributeName: self.isSelected ? NSColorFromRGB(0x6896ba)  : [NSColor whiteColor], NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-Bold" size:11]}];
}

- (void) checkSelected:(BOOL)isSelected {
    
    [self.titleTextField setSelected:isSelected];
    
    [[self rowItem].messageText setSelected:isSelected];
    [[self rowItem].date setSelected:isSelected];
    [[self rowItem].writeAttributedString setSelected:isSelected];
}


- (void)rightMouseDown:(NSEvent *)theEvent {
    [super rightMouseDown:theEvent];
    
    [TGConversationListViewController showPopupMenuForDialog:[self rowItem].conversation withEvent:theEvent forView:self];
}

- (void)setItem:(id)item selected:(BOOL)isSelected {
    [super setItem:item selected:isSelected];
}


- (void)redrawRow {
    [super redrawRow];
    
    ConversationTableItem *item = [self rowItem];
    
    self.dateTextField.attributedStringValue = item.date;
    if(item.dateSize.width == 0) {
        [self.dateTextField sizeToFit];
        item.dateSize = self.dateTextField.frame.size;
    }
    
    [self.dateTextField setFrameSize:item.dateSize];
    
    if(item.type == DialogTypeUser)
        [self.titleTextField setUser:item.user isEncrypted:NO];
    else if(item.type == DialogTypeChat)
        [self.titleTextField setChat:item.chat];
    else if(item.type == DialogTypeBroadcast)
        [self.titleTextField setBroadcast:item.broadcast];
    else
        [self.titleTextField setUser:item.user isEncrypted:YES];

    [self.dateTextField setFrameOrigin:NSMakePoint(self.bounds.size.width - item.dateSize.width - 10, self.dateTextField.frame.origin.y)];
    
    if(item.isTyping) {
        [self startTimer:item];
       
    } else {
        [self stopTimer];
    }
    
    
    if(item.type == DialogTypeChat) {
        [self.avatarImageView setChat:item.chat];
    } else if(item.type == DialogTypeUser || item.type == DialogTypeSecretChat) {
        [self.avatarImageView setUser:item.user];
    } else  {
         [self.avatarImageView setBroadcast:item.broadcast];
    }
    
    
    [self.titleTextField setSelectText:item.selectString];
    
    [self setNeedsDisplay:YES];
    
}

- (void)setNeedsDisplay:(BOOL)flag {
    [self.controll setNeedsDisplay:YES];
    [self.controll.containerView setNeedsDisplay:YES];
}

- (void)startTimer:(ConversationTableItem *)item {
    if(self.timer)
        return;
    
    [self.messageTextField setAttributedStringValue:item.writeAttributedString];
    
    self.timer = [[TGTimer alloc] initWithTimeout:0.35 repeat:YES completion:^{
        
        if(item == [self rowItem]) {
            
            NSString *string = [NSString stringWithFormat:@"%@", item.writeAttributedString.string];
            if([[string substringFromIndex:string.length - 3] isEqualToString:@"..."]) {
                [[item.writeAttributedString mutableString] setString:[string substringToIndex:string.length - 3]];
            }
            
            [item.writeAttributedString appendString:@"." withColor:self.isSelected ? NSColorFromRGB(0xffffff) : NSColorFromRGB(0x808080)];
            [item.writeAttributedString setSelected:self.isSelected];
            [self.messageTextField setAttributedStringValue:item.writeAttributedString];
            [self.messageTextField sizeToFit];
            [self setFrameSize:self.frame.size];
        } else {
            [self stopTimer];
        }
        
     } queue:dispatch_get_main_queue()];
    
    [self.timer start];
}



- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
    [self.messageTextField setAttributedStringValue:[self rowItem].messageText];
}


@end
