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
    [super mouseEntered:theEvent];
    [_removeButton setHidden:NO];
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
    
    [DIALOG_BORDER_COLOR set];
    NSRectFill(NSMakeRect(60, 0, NSWidth(dirtyRect) - 60, 1));

    
        // Drawing code here.
}



-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_textField setFrameSize:NSMakeSize(newSize.width - 70, NSHeight(_textField.frame))];
}

-(void)redrawRow {
    
    [super redrawRow];
    
    
    TGRecentSearchRowItem *item = (TGRecentSearchRowItem *)[self rowItem];
    
    [_textField updateWithConversation:item.conversation];
    [_imageView updateWithConversation:item.conversation];
    
    [_removeButton setHidden:YES];
}

@end
