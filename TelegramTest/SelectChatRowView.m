//
//  SelectUserRowView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 21.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SelectChatRowView.h"
#import "SelectChatItem.h"
#import "TMAvatarImageView.h"
#import "TMCheckBox.h"
#import "SelectUsersTableView.h"


@interface SelectChatRowView ()
@property (nonatomic, strong) TMAvatarImageView *avatarImageView;

@property (nonatomic, strong) TMNameTextField *titleTextField;
@property (nonatomic, strong) TMStatusTextField *statusTextField;

-(SelectChatItem *)rowItem;


@end

@implementation SelectChatRowView


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setSelectedBackgroundColor: NSColorFromRGB(0xfafafa)];
        [self setNormalBackgroundColor:NSColorFromRGB(0xffffff)];
        _avatarImageView = [TMAvatarImageView standartNewConversationTableAvatar];
        [self addSubview:_avatarImageView];
        [_avatarImageView setFont:TGSystemLightFont(15)];
        [_avatarImageView setFrameSize:NSMakeSize(36, 36)];
        
        
        _titleTextField = [[TMNameTextField alloc] init];
        [_titleTextField setEditable:NO];
        [_titleTextField setBordered:NO];
        [_titleTextField setBackgroundColor:[NSColor clearColor]];
        [_titleTextField setFont:TGSystemMediumFont(12)];
        [[_titleTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[_titleTextField cell] setTruncatesLastVisibleLine:YES];
        
        [_titleTextField setSelector:@selector(dialogTitle)];
        [self addSubview:_titleTextField];
        
        
        
        _statusTextField = [[TMStatusTextField alloc] init];
        [_statusTextField setEditable:NO];
        [_statusTextField setBordered:NO];
        [_statusTextField setBackgroundColor:[NSColor clearColor]];
        [_statusTextField setFont:TGSystemFont(12)];
        [[_statusTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[_statusTextField cell] setTruncatesLastVisibleLine:YES];
        [_statusTextField setSelector:@selector(statusForSearchTableView)];
        
        [self addSubview:_statusTextField];
        
        
    }
    return self;
}

- (void) redrawRow {
    
    [super redrawRow];
    
    [_titleTextField setChat:[self rowItem].chat];
    
    
    [_statusTextField setChat:[self rowItem].chat];
    
    [self setSelected:NO];
    
    [_titleTextField sizeToFit];
    
    [_statusTextField sizeToFit];
    

    [_titleTextField setFrameOrigin:NSMakePoint(77, 25)];
    [_statusTextField setFrameOrigin:NSMakePoint(77, 8)];
    
    [_avatarImageView setFrameOrigin:NSMakePoint(30, (50 - 36) / 2)];
    
    
    [_avatarImageView setChat:[self rowItem].chat];
    [self setNeedsDisplay:YES];
    
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_titleTextField setFrameSize:NSMakeSize(newSize.width - _titleTextField.frame.origin.x - 14, _titleTextField.frame.size.height)];
    
    [_statusTextField setFrameSize:NSMakeSize(newSize.width - _statusTextField.frame.origin.x - 14, _statusTextField.frame.size.height)];
}


- (void)mouseDown:(NSEvent *)theEvent {
    
    [((SelectUsersTableView *)[self rowItem].table).selectDelegate selectTableDidChangedItem:[self rowItem]];

}


- (BOOL)isEditable {
    return NO;
}

- (void)setEditable:(BOOL)editable animation:(BOOL)animation {
    
    
}

- (void)needUpdateSelectType {
    [self setEditable:[self isEditable] animation:NO];
}

- (void)setSelected:(BOOL)isSelected {
    [self setSelected:isSelected animation:NO];
}

-(void)checkSelected:(BOOL)isSelected {
    //   [self.lastSeenTextField setSelected:isSelected];
    //  [_titleTextField setSelected:isSelected];
}


- (void)setSelected:(BOOL)isSelected animation:(BOOL)animation {
    
}

-(SelectChatItem *)rowItem {
    return (SelectChatItem *) [super rowItem];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    
    [LIGHT_GRAY_BORDER_COLOR setFill];
    
    NSRectFill(NSMakeRect(30, 0, NSWidth(self.frame) - 60 , 1));

}



@end
