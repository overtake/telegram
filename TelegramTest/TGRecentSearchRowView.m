//
//  TGRecentSearchRowView.m
//  Telegram
//
//  Created by keepcoder on 14.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGRecentSearchRowView.h"

@interface TGRecentSearchRowView ()
@property (nonatomic,strong) TMNameTextField *textField;
@property (nonatomic,strong) TMAvatarImageView *imageView;
@property (nonatomic,strong) BTRButton *removeButton;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@end

@implementation TGRecentSearchRowView


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _textField = [[TMNameTextField alloc] initWithFrame:NSMakeRect(60, 0, frameRect.size.width - 70, 22)];
        
        [[_textField cell] setTruncatesLastVisibleLine:YES];
        
        _imageView = [TMAvatarImageView standartMessageTableAvatar];
        
        
        [self addSubview:_textField];
        
        [self addSubview:_imageView];
        
        [_imageView setCenteredYByView:self];
        
        [_imageView setFrameOrigin:NSMakePoint(12, NSMinY(_imageView.frame))];
        
        [_textField setCenteredYByView:self];
        
        _removeButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_RemoveSticker().size.width, image_RemoveSticker().size.height)];
        
        [_removeButton setImage:image_RemoveSticker() forControlState:BTRControlStateNormal];
        
        [_removeButton addTarget:self action:@selector(removeRecentItem:) forControlEvents:BTRControlEventClick];
        
        
        [_removeButton setFrameOrigin:NSMakePoint(12, NSHeight(frameRect)/2 + 7)];
        

        [self addSubview:_removeButton];
    }
    
    return self;
}

- (void) updateTrackingAreas {
    [self removeTrackingArea:self.trackingArea];
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                     options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow)
                                                       owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

-(void)mouseEntered:(NSEvent *)theEvent {
    
    TGRecentSearchRowItem *item = (TGRecentSearchRowItem *)[self rowItem];

    [super mouseEntered:theEvent];
    [_removeButton setHidden:item.disableRemoveButton];
}

-(void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    
    [_removeButton setHidden:YES];
}

-(void)removeRecentItem:(BTRButton *)sender {
    [(TMTableView *)self.rowItem.table removeItem:self.rowItem];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    TGRecentSearchRowItem *item = (TGRecentSearchRowItem *)[self rowItem];

    if(!item.disableBottomSeparator) {
        [DIALOG_BORDER_COLOR set];
        NSRectFill(NSMakeRect(60, 0, NSWidth(dirtyRect) - 60, 1));
    }
    if (item.unreadText.length > 0) {
        [self drawUnreadCount];
    }

}



-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    TGRecentSearchRowItem *item = (TGRecentSearchRowItem *)[self rowItem];
    CGFloat addition = 0;
    if ( item.unreadTextSize.width > 0) {
        addition += item.unreadTextSize.width + 20;
    }
    [_textField setFrameSize:NSMakeSize(newSize.width - 70 - addition, NSHeight(_textField.frame))];
}

-(void)redrawRow {
    
    [super redrawRow];
    
    
    TGRecentSearchRowItem *item = (TGRecentSearchRowItem *)[self rowItem];
    
    [_textField updateWithConversation:item.conversation];
    [_imageView updateWithConversation:item.conversation];
    
    [_removeButton setHidden:YES];
}

static int unreadCountRadius = 10;
static int unreadOffsetRight = 13;




- (void)drawUnreadCount {
    
    TGRecentSearchRowItem *item = (TGRecentSearchRowItem *)[self rowItem];

    
    static int offsetY = 15;
    
    int sizeWidth = MAX(item.unreadTextSize.width + 12, unreadCountRadius * 2);
    
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
        if(!item.conversation.isMute || [SettingsArchiver checkMaskedSetting:IncludeMutedUnreadCount])
            [BLUE_COLOR set];
        else
            [NSColorFromRGB(0xd7d7d7) set];
    }
    [path fill];
    [path closePath];
    
    int offsetX = (sizeWidth - item.unreadTextSize.width)/2;
    [item.unreadText drawAtPoint:CGPointMake(offset1 - unreadCountRadius + offsetX, offsetY + 3) withAttributes:@{NSForegroundColorAttributeName: self.isSelected ? NSColorFromRGB(0x6896ba)  : [NSColor whiteColor], NSFontAttributeName: TGSystemBoldFont(11)}];
}


@end
