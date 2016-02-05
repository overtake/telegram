//
//  TMBottomScrollView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 24.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMBottomScrollView.h"
#import "MLCalendarView.h"
#import "MessageTableItem.h"
@interface TMBottomScrollView ()<MLCalendarViewDelegate>
@property (nonatomic, strong) NSAttributedString *messagesCountAttributedString;

@property (strong) NSPopover* calendarPopover;
@property (strong) MLCalendarView*calendarView;
@property (weak) IBOutlet NSDateFormatter *dateFormatter;

@property (nonatomic,strong) BTRButton *calendarButton;
@end

@implementation TMBottomScrollView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layerContentsPlacement = NSViewLayerContentsPlacementScaleAxesIndependently;
        self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
        
        [self addTarget:self action:@selector(clickHandler) forControlEvents:BTRControlEventLeftClick];
        
      //  [self setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateNormal];
        
        [self setMessagesCount:32];
        
        _calendarButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(frame) - 25, 0, 20, 20)];
        
        [_calendarButton setCenteredYByView:self];
        
        [_calendarButton setImage:image_CalendarIcon() forControlState:BTRControlStateNormal];
        
//        _calendarButton.wantsLayer = YES;
//        _calendarButton.layer.cornerRadius = 4;
//        _calendarButton.layer.borderColor = DIALOG_BORDER_COLOR.CGColor;
//        _calendarButton.layer.borderWidth = 2;
        
        [_calendarButton setHidden:!ACCEPT_FEATURE];
        
        weak();
        
        [_calendarButton addBlock:^(BTRControlEvents events) {
            [weakSelf showCalendar];
        } forControlEvents:BTRControlEventClick];
        
        [self addSubview:_calendarButton];
    }
    return self;
}

-(void)addScrollEvent {
    id clipView = [[self.messagesViewController.table enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didScrolledTableView:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
    
}

-(void)setMessagesViewController:(MessagesViewController *)messagesViewController {
    _messagesViewController = messagesViewController;
    [self addScrollEvent];
}

-(void)dealloc {
    [Notification removeObserver:self];
}

-(void)removeScrollEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)_didScrolledTableView:(NSNotification *)notification {
    
    if(self.calendarPopover.isShown) {
        NSRange range = [_messagesViewController.table rowsInRect:[_messagesViewController.table visibleRect]];
        
        __block MessageTableItem *item;
        
        [_messagesViewController.messageList enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:NSEnumerationReverse usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(obj.message != nil) {
                item = obj;
                *stop = YES;
            }
            
        }];
        
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:item.message.date];
        self.calendarView.date = date;
        self.calendarView.selectedDate = date;

    }
}

-(void)setHidden:(BOOL)flag {
    [super setHidden:flag];
    
    if(self.isHidden) {
        [self.calendarPopover close];
    }
    
    if(flag) {
        [self setMessagesCount:0];
        [self sizeToFit];
    }
    
    
}

- (void) createCalendarPopover {
    NSPopover* myPopover = self.calendarPopover;
    if(!myPopover) {
        myPopover = [[NSPopover alloc] init];
        self.calendarView = [[MLCalendarView alloc] init];
        self.calendarView.delegate = self;
        myPopover.contentViewController = self.calendarView;
     //   myPopover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
     //   myPopover.animates = YES;
        myPopover.behavior = NSPopoverBehaviorTransient;
    }
    self.calendarPopover = myPopover;
}

- (void)showCalendar {
    [self createCalendarPopover];
    
   NSRect cellRect = [_calendarButton bounds];
    [self.calendarPopover showRelativeToRect:cellRect ofView:_calendarButton preferredEdge:NSMaxYEdge];
    
    [self _didScrolledTableView:nil];
}

- (void) didSelectDate:(NSDate *)selectedDate {
    [self.calendarPopover close];
    
    assert(_messagesViewController != nil);
    
    [self.messagesViewController showModalProgress];
    
    
    NSDate *jumpDate = selectedDate;
    
    selectedDate = [NSDate dateWithTimeIntervalSince1970:selectedDate.timeIntervalSince1970 + 60*60*24];
    
    id request;
    
   
    
    if(_messagesViewController.conversation.type == DialogTypeChannel) {
        request = [TLAPI_channels_getImportantHistory createWithChannel:_messagesViewController.conversation.chat.inputPeer offset_id:0 offset_date:selectedDate.timeIntervalSince1970 add_offset:0 limit:100 max_id:INT32_MAX min_id:0];
    } else {
        request = [TLAPI_messages_getHistory createWithPeer:_messagesViewController.conversation.inputPeer offset_id:0 offset_date:selectedDate.timeIntervalSince1970 add_offset:0 limit:100 max_id:INT32_MAX min_id:0];
    }
    
    
    
    NSLog(@"selected date: %@",selectedDate);
    
    [RPCRequest sendRequest:request successHandler:^(id request, TL_messages_messages *response) {
        
        [TL_localMessage convertReceivedMessages:response.messages];
        
        if(response.messages.count > 0) {
            [[Storage manager] addHolesAroundMessage:[response.messages firstObject]];
            [[Storage manager] addHolesAroundMessage:[response.messages lastObject]];
            [[Storage manager] insertMessages:response.messages];
            
            
            NSLog(@"first date: %@",[NSDate dateWithTimeIntervalSince1970:[(TL_localMessage *)[response.messages firstObject] date]]);
            NSLog(@"last date: %@",[NSDate dateWithTimeIntervalSince1970:[(TL_localMessage *)[response.messages lastObject] date]]);
            
            __block TL_localMessage *jumpMessage = [response.messages firstObject];
            
            [response.messages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(obj.date >= jumpDate.timeIntervalSince1970) {
                    jumpMessage = obj;
                    NSLog(@"jump date: %@",[NSDate dateWithTimeIntervalSince1970:[obj date]]);
                    *stop = YES;
                }
                
            }];
            
            [self.messagesViewController showMessage:jumpMessage fromMsg:nil flags:ShowMessageTypeDateJump];
            [self.messagesViewController hideModalProgressWithSuccess];

        } else {
            [self.messagesViewController hideModalProgress];
        }
        
       
        
    } errorHandler:^(id request, RpcError *error) {
        [self.messagesViewController hideModalProgress];
    } timeout:10];
    
}

- (void)clickHandler {
    

    
    if(_callback) {
        [self setHidden:YES];
        _callback();
    }
}

- (void)handleStateChange {
    [self setNeedsDisplay:YES];
}

- (void)setMessagesCount:(int)messagesCount {
    if(messagesCount == self->_messagesCount)
        return;
    
    self->_messagesCount = messagesCount;
    if(messagesCount) {
        self.messagesCountAttributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(messagesCount == 1 ? @"Messages.scrollToBottomNewMessage" : @"Messages.scrollToBottomNewMessages", nil), messagesCount] attributes:@{NSFontAttributeName: TGSystemFont(14), NSForegroundColorAttributeName: BLUE_UI_COLOR}];
    } else {
        self.messagesCountAttributedString = nil;
    }
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    CGContextRef context = [NSGraphicsContext currentContext].graphicsPort;
    [NSGraphicsContext saveGraphicsState];
    CGContextSetShouldSmoothFonts(context, TRUE);

    
    
    //ROMANOV BUGFIX
    NSRect rect = NSMakeRect(1, 1, self.bounds.size.width - 2, self.bounds.size.height - 2);
    int radius = 3;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();

    CGPathMoveToPoint(pathRef, NULL, rect.origin.x, rect.origin.y + radius);
    CGPathAddLineToPoint(pathRef, NULL, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGPathAddArc(pathRef, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI / 2, 1); //STS fixed
    CGPathAddLineToPoint(pathRef, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
    CGPathAddArc(pathRef, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGPathAddLineToPoint(pathRef, NULL, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGPathAddArc(pathRef, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
    CGPathAddLineToPoint(pathRef, NULL, rect.origin.x + radius, rect.origin.y);
    CGPathAddArc(pathRef, NULL, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
    
    CGPathCloseSubpath(pathRef);
    CGContextAddPath(context, pathRef);
    
    NSColor *fillColor = self.isHover ? NSColorFromRGB(0xffffff) : NSColorFromRGB(0xfdfdfd);
    NSColor *strokeColor = GRAY_BORDER_COLOR;
    
    CGContextSetRGBFillColor(context, fillColor.redComponent, fillColor.greenComponent, fillColor.blueComponent, self.isHover ?  1.f : 0.96f);
    CGContextAddPath(context, pathRef);
    CGContextFillPath(context);
    
    CGContextSetRGBStrokeColor(context, strokeColor.redComponent, strokeColor.greenComponent, strokeColor.blueComponent, 1);
    CGContextAddPath(context, pathRef);
    CGContextSetLineWidth(context, 1);
    CGContextStrokePath(context);
    
    CGPathRelease(pathRef);

    
    NSPoint point;
    if(ACCEPT_FEATURE)
        point.x = -5;
    point.y = roundf((NSHeight(dirtyRect) - image_ScrollDownArrow().size.height) * 0.5);

    [image_ScrollDownArrow() drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    
    if(self.messagesCount) {
        NSSize size = [self.messagesCountAttributedString size];
        size.width = ceil(size.width);
        NSPoint point = NSMakePoint(roundf((self.bounds.size.width - 28 - size.width) / 2.f), roundf( (self.bounds.size.height - size.height) / 2.f ) + 2);
        [self.messagesCountAttributedString drawAtPoint:point];
    }
    
    [NSGraphicsContext restoreGraphicsState];
}



- (void)sizeToFit {
    
    NSSize size = NSMakeSize(0, 0);
    if(self.messagesCount) {
        size = [self.messagesCountAttributedString size];
        size.width = ceil(size.width);
        size.width += 16;
    }
    
    if(ACCEPT_FEATURE) {
         size.width += 60;
    } else {
        size.width+=40;
    }
    
   
    size.height = 44;
    
    
    [self setFrameSize:size];
  //  [self setNeedsDisplay:YES];
//    [self.layer setNeedsLayout];
//    [self.layer needsDisplay];
}

@end