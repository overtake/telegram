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
@property (nonatomic,strong) TMAvatarImageView *avatarImageView;
@property (nonatomic,strong) TMStatusTextField *statusTextField;
@property (nonatomic,strong) TMNameTextField *nameTextField;

@property (nonatomic,strong) ITSwitch *switchView;
@property (nonatomic,strong) NSImageView *selectImageView;

@end

@implementation TGUserContainerView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.avatarImageView = [TMAvatarImageView standartMessageTableAvatar];
        
        [self.avatarImageView setFrameOrigin:NSMakePoint(30, NSMinY(self.avatarImageView.frame))];
        
        [self addSubview:self.avatarImageView];
        
        self.nameTextField = [[TMNameTextField alloc] init];
        [self.nameTextField setSelector:@selector(chatInfoTitle)];
        [self.nameTextField setFrameOrigin:NSMakePoint(NSMaxX(self.avatarImageView.frame) + 10, 32)];
        [self addSubview:self.nameTextField];
        
        self.statusTextField = [[TMStatusTextField alloc] init];
        [self.statusTextField setSelector:@selector(statusForGroupInfo)];
        [self.statusTextField setFrameOrigin:NSMakePoint(NSMaxX(self.avatarImageView.frame) + 10, 13)];
        [self addSubview:self.statusTextField];
        
        [_statusTextField setFont:TGSystemFont(12)];
        [_statusTextField setTextColor:GRAY_TEXT_COLOR];
        
        
        _selectImageView = imageViewWithImage(image_UsernameCheck());
        _switchView = [[ITSwitch alloc] initWithFrame:NSMakeRect(0, 0, 36, 20)];
        
        
        [self addSubview:_selectImageView];
        [self addSubview:_switchView];
        
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColorFromRGB(0xe0e0e0) setFill];
    
    NSRectFill(NSMakeRect(NSMaxX(_avatarImageView.frame) + 10, 0, NSWidth(self.frame) - (NSMaxX(_avatarImageView.frame) + 40), 1));
    
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


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    TGUserContainerRowItem *item = (TGUserContainerRowItem *)[self rowItem];
    
    [self.nameTextField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMaxX(self.avatarImageView.frame) - 20, NSHeight(self.nameTextField.frame))];
    [self.statusTextField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMaxX(self.avatarImageView.frame) - 20, NSHeight(self.statusTextField.frame))];
    
    
    [self.statusTextField setFrameOrigin:NSMakePoint(NSMinX(self.statusTextField.frame), NSHeight(self.frame)/2 - NSHeight(self.statusTextField.frame))];
    [self.nameTextField setFrameOrigin:NSMakePoint(NSMinX(self.nameTextField.frame), NSHeight(self.frame)/2 )];
    
    
    [_selectImageView setFrameOrigin:NSMakePoint(newSize.width - item.xOffset * 2, NSMinY(_selectImageView.frame))];
    [_switchView setFrameOrigin:NSMakePoint(newSize.width - item.xOffset * 2, NSMinY(_selectImageView.frame))];
    
    [_avatarImageView setCenteredYByView:_avatarImageView.superview];
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
