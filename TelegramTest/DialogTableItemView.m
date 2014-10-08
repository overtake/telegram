//
//  DialogTableItemView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/18/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "DialogTableItemView.h"
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
    
    [NSColorFromRGB(0x6ac065) setFill];
    [path fill];

    [[NSColor whiteColor] set];
    [self.unreadCount drawAtPoint:NSMakePoint(8, 4) withAttributes:attributes()];
}

@end


@interface DialogTableItemView()


@property (nonatomic, strong) TGImageView *photoImageView;
@property (nonatomic, strong) TMNameTextField *titleTextField;
@property (nonatomic, strong) TMTextField *messageTextField;
@property (nonatomic, strong) TMTextField *dateTextField;

@property (nonatomic, strong) TMAvatarImageView *avatarImageView;
@property (nonatomic, strong) DialogShortUnreadCount *shortUnreadCount;
@property (nonatomic, strong) TGTimer *timer;
//@property (atomic) int width;

@property (nonatomic, strong) DialogSwipeTableControll *controll;

- (DialogTableItem *)rowItem;

@end

@implementation DialogTableItemView

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
        
        
        int mutedWith = [self rowItem].isMuted ? image_muted().size.width + 6 : 0;
        [self.titleTextField setFrameSize:NSMakeSize(self.bounds.size.width - [self rowItem].dateSize.width - 80 - mutedWith, self.titleTextField.bounds.size.height)];
        [self.messageTextField setFrameSize:NSMakeSize(self.bounds.size.width - 110, 19)];

        
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
        
        weakify();
        
        self.controll = [[DialogSwipeTableControll alloc] initWithFrame:self.bounds itemView:self];
        [self.controll setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self.controll setDrawBlock:^{
            NSColor *color = nil;
            if(!strongSelf.isSelected) {
                color = [NSColor whiteColor]; //strongSelf.isHover ? NSColorFromRGB(0xfafafa) : [NSColor whiteColor];
                [color set];
                NSRectFill(NSMakeRect(0, 0, strongSelf.bounds.size.width - DIALOG_BORDER_WIDTH, strongSelf.bounds.size.height));
            } else {
                color = DIALOG_SELECT_COLOR;
                [color set];
                NSRectFill(NSMakeRect(0, 0, strongSelf.bounds.size.width, strongSelf.bounds.size.height));
            }
            strongSelf.controll.backgroundColor = color;
        }];
        [self.controll.containerView setDrawBlock:^{
            
           
            
            if([strongSelf rowItem].isOut) {
                
                if(![strongSelf rowItem].isRead) {
                    if([strongSelf rowItem].lastMessage.dstate == DeliveryStateNormal) {
                        
                        if([strongSelf rowItem].dialog.type != DialogTypeBroadcast) {
                            NSRect rect = NSMakeRect(strongSelf.bounds.size.width - 10 - 11, 18, 8, 8);
                            NSBezierPath* circlePath = [NSBezierPath bezierPath];
                            [circlePath appendBezierPathWithOvalInRect: rect];
                            if(strongSelf.isSelected) {
                                [NSColorFromRGB(0xc1d6e5) setFill];
                            } else {
                                [NSColorFromRGB(0x41a2f7) setFill];
                            }
                            
                            [circlePath fill];
                        } else {
                            
                            NSImage *white = [NSImage imageNamed:@"broadcastSendingWhite"];
                            NSImage *gray = [NSImage imageNamed:@"broadcastSendingGray"];
                            
                            NSImage *current = strongSelf.isSelected ? white : gray;
                            
                            
                            [current drawInRect:NSMakeRect(strongSelf.bounds.size.width - 12 - current.size.width, 14, current.size.width, current.size.height)];
                        }
                        
                        
                    } else if([strongSelf rowItem].lastMessage.dstate == DeliveryStateError) {
                        
                        NSImage *img = !strongSelf.isSelected ? image_ChatMessageError() : [NSImage imageNamed:@"DialogSelectedSendError"];
                        
                        [img drawInRect:NSMakeRect(strongSelf.bounds.size.width - 12 - img.size.width, 14, img.size.width, img.size.height)];
                    } else if([strongSelf rowItem].lastMessage.dstate == DeliveryStatePending) {
                        NSRect rect = NSMakeRect(strongSelf.bounds.size.width - 10 - 11, 18, 8, 8);
                        NSBezierPath* circlePath = [NSBezierPath bezierPath];
                        [circlePath appendBezierPathWithOvalInRect: rect];
                        if(strongSelf.isSelected) {
                            [NSColorFromRGB(0xffffff) setFill];
                        } else {
                            [NSColorFromRGB(0xcccccc) setFill];
                        }
                        
                         [circlePath fill];
                    }
                    
                    
                    
                }
                
            }
            
            if(strongSelf.style == DialogTableItemViewShortStyle) {
                [strongSelf.shortUnreadCount setUnreadCount:[strongSelf rowItem].unreadTextCount];
                return;
            }
            
            if([strongSelf rowItem].isMuted) {
                NSImage *mutedImage = strongSelf.isSelected ? image_mutedSld() : image_muted();
                [mutedImage drawAtPoint:NSMakePoint(strongSelf.bounds.size.width - strongSelf.dateTextField.bounds.size.width - 25, strongSelf.dateTextField.frame.origin.y + 1) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
            }
            
            if([strongSelf rowItem].unreadTextCount.length)
                [strongSelf drawUnreadCount];
        }];
        [self.controll setItemView:self];
        [self addSubview:self.controll];
        
        self.avatarImageView = [TMAvatarImageView standartTableAvatar];
        [self.controll addSubview:self.avatarImageView];
        
        
        self.shortUnreadCount = [[DialogShortUnreadCount alloc] init];
        [self.shortUnreadCount setHidden:YES];
        [self.controll addSubview:self.shortUnreadCount];
        
        self.titleTextField
        = [[TMNameTextField alloc] initWithFrame:NSMakeRect(68, 33, 0, 0)];
        [self.titleTextField setEditable:NO];
        [self.titleTextField setBordered:NO];
        [self.titleTextField setSelector:@selector(dialogTitle)];
        [self.titleTextField setEncryptedSelector:@selector(dialogTitleEncrypted)];
        [self.titleTextField setDrawsBackground:NO];
        [[self.titleTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.titleTextField cell] setTruncatesLastVisibleLine:YES];
        [self.titleTextField setAutoresizingMask:NSViewWidthSizable];
        [self.controll addSubview:self.titleTextField];
        
        self.messageTextField = [[TMTextField alloc] initWithFrame:NSMakeRect(68, 15, 0, 0)];
        [self.messageTextField setEditable:NO];
        [self.messageTextField setBordered:NO];
        [self.messageTextField setBackgroundColor:[NSColor clearColor]];
        [self.messageTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:12.5]];
        [[self.messageTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.messageTextField cell] setTruncatesLastVisibleLine:YES];
        [self.messageTextField setAutoresizingMask:NSViewWidthSizable];
        [self.controll addSubview:self.messageTextField];
        
        self.dateTextField = [[TMTextField alloc] initWithFrame:NSMakeRect(0, 34, 0, 0)];
        [self.dateTextField setAutoresizingMask:NSViewMinXMargin];
        [self.dateTextField setEditable:NO];
        [self.dateTextField setBordered:NO];
        [self.dateTextField setBackgroundColor:[NSColor clearColor]];
        [self.dateTextField setFont:[NSFont fontWithName:@"Helvetica-Light" size:11]];
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

//    if([NSScroller preferredScrollerStyle] == NSScrollerStyleLegacy) {
//        [self.messageTextField setFrameSize:NSMakeSize(164-15, 19)];
////        self.width = 280-15;
//    } else {
////        self.width = 280;
//    }
    
    [self.messageTextField setFrameSize:NSMakeSize(self.bounds.size.width - 110, 19)];
    
    if([self rowItem])
        [self redrawRow];
}

- (DialogTableItem *)rowItem {
    return (DialogTableItem *)[super rowItem];
}

- (void)drawRect:(NSRect)dirtyRect {
   
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    self.style = newSize.width == 70 ? DialogTableItemViewShortStyle : DialogTableItemViewFullStyle;
    
    [self.messageTextField setFrameSize:NSMakeSize(newSize.width - 110, 19)];
    
    
}

static int unreadCountRadius = 10;
static int unreadOffsetRight = 13;

- (void)drawUnreadCount {
    
    static int offsetY = 12;
    
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
        [NSColorFromRGB(0x6ac065) set];
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

- (void) changeSelected:(BOOL)isSelected {
    if(isSelected) {
//        if(self.row != 0)
//            [self setBorder:TMViewBorderTop | TMViewBorderBottom];
//        else
//            [self setBorder:TMViewBorderBottom];
    } else {
//        [self setBorder:0];
    }
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    [super rightMouseDown:theEvent];
    
    [DialogsViewController showPopupMenuForDialog:[self rowItem].dialog withEvent:theEvent forView:self];
}

- (void)setItem:(id)item selected:(BOOL)isSelected {
    [super setItem:item selected:isSelected];
}


- (void)redrawRow {
    [super redrawRow];

//    [self.shortUnreadCount draw];
    
    DialogTableItem *item = [self rowItem];
    
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

    [self.titleTextField sizeToFit];
    int mutedWith = item.isMuted ? image_muted().size.width + 6 : 0;
    [self.titleTextField setFrameSize:NSMakeSize(self.bounds.size.width - item.dateSize.width - 80 - mutedWith, self.titleTextField.bounds.size.height)];
        
    [self.dateTextField setFrameOrigin:NSMakePoint(self.bounds.size.width - item.dateSize.width - 10, self.dateTextField.frame.origin.y)];
    
    if(item.isTyping) {
        [self startTyping];
        [self.messageTextField setAttributedStringValue:item.writeAttributedString];
    } else {
        [self stopTyping];
        [self.messageTextField setAttributedStringValue:item.messageText];
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
//    [super setNeedsDisplay:flag];
    
    [self.controll setNeedsDisplay:YES];
    [self.controll.containerView setNeedsDisplay:YES];
}

- (void)startTyping {
    if(self.timer)
        return;
    
    DialogTableItem *item = [self rowItem];
    
    self.timer = [[TGTimer alloc] initWithTimeout:0.35 repeat:YES completion:^{
        NSString *string = [NSString stringWithFormat:@"%@", item.writeAttributedString.string];
        if([[string substringFromIndex:string.length - 3] isEqualToString:@"..."]) {
            [[item.writeAttributedString mutableString] setString:[string substringToIndex:string.length - 3]];
        }
        
        [item.writeAttributedString appendString:@"." withColor:self.isSelected ? NSColorFromRGB(0xffffff) : NSColorFromRGB(0x9b9b9b)];
        [item.writeAttributedString setSelected:self.isSelected];
        [self.messageTextField setAttributedStringValue:item.writeAttributedString];
        [item.writeAttributedString setAlignment:NSLeftTextAlignment range:NSMakeRange(0, item.writeAttributedString.length)];
        
        
    } queue:dispatch_get_main_queue()];
    [self.timer start];
}

- (void)stopTyping {
    [self.timer invalidate];
    self.timer = nil;
}


@end
