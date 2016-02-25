//
//  TGUserContainerView.m
//  Telegram
//
//  Created by keepcoder on 16.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGUserContainerView.h"
#import "TGUserContainerRowItem.h"
#import "ITSwitch.h"
@interface TGUserContainerView ()

@property (nonatomic,strong) TMView *avatarContainerView;

@property (nonatomic,strong) TMAvatarImageView *avatarImageView;
@property (nonatomic,strong) TMStatusTextField *statusTextField;
@property (nonatomic,strong) TMNameTextField *nameTextField;

@property (nonatomic,strong) ITSwitch *switchView;
@property (nonatomic,strong) NSImageView *selectImageView;

@property (nonatomic,strong) TMView *separator;

@property (nonatomic,strong) NSImageView *deleteMenuImageView;

@end

@implementation TGUserContainerView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.avatarImageView = [TMAvatarImageView standartMessageTableAvatar];
        
        
        _avatarContainerView = [[TMView alloc] initWithFrame:NSMakeRect(30, 0, NSWidth(_avatarImageView.frame), NSHeight(_avatarImageView.frame))];
        
        [_avatarContainerView addSubview:_avatarImageView];
        
        [self addSubview:_avatarContainerView];
        
        self.nameTextField = [[TMNameTextField alloc] init];
        [self.nameTextField setSelector:@selector(chatInfoTitle)];
        
        
        self.statusTextField = [[TMStatusTextField alloc] init];
        [self.statusTextField setSelector:@selector(statusForGroupInfo)];
        [self addSubview:self.statusTextField];
        [self addSubview:self.nameTextField];
        [_statusTextField setFont:TGSystemFont(12)];
        [_statusTextField setTextColor:GRAY_TEXT_COLOR];
        
        
        _selectImageView = imageViewWithImage(image_UsernameCheck());
        _switchView = [[ITSwitch alloc] initWithFrame:NSMakeRect(0, 0, 36, 20)];
        
        
        [self addSubview:_selectImageView];
        [self addSubview:_switchView];
        
        _separator = [[TMView alloc] initWithFrame:NSZeroRect];
        _separator.backgroundColor = DIALOG_BORDER_COLOR;
        [self addSubview:_separator];
        
        _deleteMenuImageView = imageViewWithImage(image_ModernMenuDeleteIcon());
        
        [self addSubview:_deleteMenuImageView];
    }
    return self;
}

-(int)xOffset {
    return [self rowItem].isEditable ? 40 + NSWidth(_deleteMenuImageView.frame) : 30;
}

-(void)setEditable:(BOOL)editable animated:(BOOL)animated {
    
    [self updateFramesWithAnimation:animated];
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

-(TGUserContainerRowItem *)item {
    return (TGUserContainerRowItem *)[self rowItem];
}

-(void)redrawRow {
    TGUserContainerRowItem *item = (TGUserContainerRowItem *)[self rowItem];
    
    [_switchView setHidden:item.type != SettingsRowItemTypeSwitch];
    [_selectImageView setHidden:item.type != SettingsRowItemTypeSelected];
    
    
    if(item.stateback) {
        [_switchView setOn:[item.stateback(item) boolValue]];
        
        [_switchView setHidden:item.type != SettingsRowItemTypeSwitch];
        
        [_selectImageView setHidden:item.type != SettingsRowItemTypeSelected || ![item.stateback(item) boolValue]];
    }
    
    
    [_switchView setCenteredYByView:self];
    [_selectImageView setCenteredYByView:self];
    
    [self setUser:item.user];
}

-(void)mouseDown:(NSEvent *)theEvent {
     TGUserContainerRowItem *item = (TGUserContainerRowItem *)[self rowItem];
    
    if(item.stateCallback != nil) {
        item.stateCallback();
    } else {
        [super mouseDown:theEvent];
    }

}


-(void)updateFramesWithAnimation:(BOOL)animated {
    
    
    
    id statusF = animated ? [_statusTextField animator] : _statusTextField;
    id nameF = animated ? [_nameTextField animator] : _nameTextField;
    
    id avatarF = animated ? [_avatarContainerView animator] : _avatarContainerView;
    id separatorF = animated ? [_separator animator] : _separator;
    
    id deleteF = animated ? [_deleteMenuImageView animator] : _deleteMenuImageView;
    
    [statusF setFrameOrigin:NSMakePoint(self.xOffset + NSWidth(_avatarContainerView.frame) + 10, NSHeight(self.frame)/2 - NSHeight(self.statusTextField.frame) )];
    [nameF setFrameOrigin:NSMakePoint(self.xOffset + NSWidth(_avatarContainerView.frame) + 10, NSHeight(self.frame)/2 )];
    
    
    [avatarF setFrameOrigin:NSMakePoint(self.xOffset, NSMinY(_avatarContainerView.frame))];
    
    [_selectImageView setFrameOrigin:NSMakePoint(NSWidth(self.frame) - self.xOffset - 30, NSMinY(_selectImageView.frame))];
    [_switchView setFrameOrigin:NSMakePoint(NSWidth(self.frame) - self.xOffset - 30, NSMinY(_selectImageView.frame))];
    
   [separatorF setFrame:NSMakeRect(self.xOffset + 10 + NSWidth(_avatarContainerView.frame), 0, NSWidth(self.frame) - self.xOffset - 30 - 10 - NSWidth(_avatarContainerView.frame), DIALOG_BORDER_WIDTH)];
    
    [deleteF setFrameOrigin:NSMakePoint(self.item.isEditable ? 30 : - NSWidth(_deleteMenuImageView.frame), roundf((NSHeight(self.frame) - NSHeight(_deleteMenuImageView.frame))/2))];
    
    [(NSView *)deleteF setAlphaValue:self.item.isEditable ? 1 : 0];
    
    [_deleteMenuImageView setHidden:self.item.stateback == nil || ![self.item.stateback(self.item) boolValue]];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.nameTextField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMaxX(self.avatarImageView.frame) - 20, NSHeight(self.nameTextField.frame))];
    [self.statusTextField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMaxX(self.avatarImageView.frame) - 20, NSHeight(self.statusTextField.frame))];
    
    [self.avatarContainerView setCenteredYByView:self];
    
    [self updateFramesWithAnimation:NO];
    
}


-(void)setUser:(TLUser *)user {    
    [self.statusTextField setUser:user];
    [self.nameTextField setUser:user];
    [self.avatarImageView setUser:user];
    
    TGUserContainerRowItem *item = (TGUserContainerRowItem *)[self rowItem];
    
    if(item.status.length > 0) {
        [_statusTextField setUser:nil];
        [_statusTextField setStringValue:item.status];
    }
    
    [self.statusTextField sizeToFit];
    [self.nameTextField sizeToFit];
    
}


@end
