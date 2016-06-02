//
//  TGS_ConversationRowView.m
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGS_ConversationRowView.h"
#import "TMAttributedString.h"
#import "TGImageView.h"
#import "BTRButton.h"
@interface TGS_ConversationRowView ()
@property (nonatomic,strong) NSTextField *nameField;
@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,strong) BTRButton *selectButton;
@property (nonatomic,strong) TMView *animatedBackground;
@end



@implementation TGS_ConversationRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [DIALOG_BORDER_COLOR set];
    
    NSRectFill(NSMakeRect(60, 0, NSWidth(dirtyRect) - 70, DIALOG_BORDER_WIDTH));
    
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        _animatedBackground = [[TMView alloc] initWithFrame:self.bounds];
        [_animatedBackground setAlphaValue:0.0];
        _animatedBackground.backgroundColor = GRAY_BORDER_COLOR;
        [self addSubview:_animatedBackground];
        
        
        
        
        _nameField = [[NSTextField alloc] init];
        
        [_nameField setBordered:NO];
        [_nameField setDrawsBackground:NO];
        [_nameField setSelectable:NO];
        [_nameField setEditable:NO];
        [[_nameField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[_nameField cell] setTruncatesLastVisibleLine:YES];
        [_nameField setFrameOrigin:NSMakePoint(60, 17)];
        [_nameField setFrameSize:NSMakeSize(NSWidth(frameRect) - 100, 40)];
        
        [self addSubview:_nameField];
        
        
        _imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(10, 5, 0, 0)];
        
        [self addSubview:_imageView];
        
        
        
        _selectButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(frameRect) - image_ComposeCheckActive().size.width - 10, roundf((NSHeight(frameRect) - image_ComposeCheckActive().size.height )/ 2), image_ComposeCheckActive().size.width, image_ComposeCheckActive().size.height)];
        
        weak();
        
        _selectButton.layer.backgroundColor = [NSColor clearColor].CGColor;
        
        [_selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateNormal];
        [_selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHover];
        [_selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHighlighted];
        [_selectButton setBackgroundImage:image_ComposeCheckActive() forControlState:BTRControlStateSelected];
        
        [_selectButton addBlock:^(BTRControlEvents events) {
            
            [weakSelf mouseDown:[NSApp currentEvent]];
            
        } forControlEvents:BTRControlEventLeftClick];
        
        
        [self addSubview:_selectButton];

        
    }
    
    return self;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_animatedBackground setFrameSize:newSize];
}

-(void)mouseDown:(NSEvent *)theEvent {
    
    TGS_ConversationRowItem *item = (TGS_ConversationRowItem *) [self rowItem];
    
    item.isSelected = !item.isSelected;
    
    [self setSelected:item.isSelected animation:YES];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        [context setDuration:0.1];
        [[_animatedBackground animator] setAlphaValue:1.0];
        
    } completionHandler:^{
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            [context setDuration:0.1];
            [[_animatedBackground animator] setAlphaValue:0.0];
            
        } completionHandler:^{
            
        }];
    }];
    
}


- (void)setSelected:(BOOL)isSelected animation:(BOOL)animation {
    
    
    [self.selectButton setSelected:isSelected];
    
    if(self.selectButton.isSelected) {
        [self.selectButton setBackgroundImage:image_ComposeCheckActive() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:image_ComposeCheckActive() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:image_ComposeCheckActive() forControlState:BTRControlStateHighlighted];
    } else {
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHighlighted];
    }
    
}


-(void)redrawRow {
    
    TGS_ConversationRowItem *item = (TGS_ConversationRowItem *) [self rowItem];
    
    [_nameField setAttributedStringValue:item.name];
    
    [_imageView setFrameSize:item.imageObject.imageSize];
    
    [_nameField setCenteredYByView:self];

    _imageView.object = item.imageObject;
    
    [self setSelected:item.isSelected animation:NO];
}


@end
