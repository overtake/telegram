//
//  NotificationConversationRowView.m
//  Telegram
//
//  Created by keepcoder on 29.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "NotificationConversationRowView.h"
#import "ITSwitch.h"
@interface NotificationConversationRowView ()
@property (nonatomic,strong) TMAvatarImageView *avatarImageView;
@property (nonatomic,strong) TMNameTextField *nameTextField;
@property (nonatomic,strong) ITSwitch *notificationSwitch;




@end

@implementation NotificationConversationRowView



-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _avatarImageView = [[TMAvatarImageView alloc] initWithFrame:NSMakeRect(30, 5, 30, 30)];
        
        [self addSubview:_avatarImageView];
        
        _nameTextField = [[TMNameTextField alloc] initWithFrame:NSMakeRect(70, 13, NSWidth(frameRect) - 100, 20)];
        [_nameTextField setSelector:@selector(dialogTitle)];
        
        [self addSubview:_nameTextField];
        
        _notificationSwitch = [[ITSwitch alloc] initWithFrame:NSMakeRect(0, 0, 36, 20)];
        
        weak();
        
        [_notificationSwitch setDidChangeHandler:^(BOOL isOn) {
            
            NotificationConversationRowItem *item = (NotificationConversationRowItem *) [weakSelf rowItem];
            
            TL_conversation *original = [[DialogsManager sharedManager] find:item.conversation.peer_id];
            
            if(isOn)
            {
                [original unmute:nil];
                [item.conversation unmute:nil];
            } else {
                [original mute:nil];
                [item.conversation mute:nil];
            }
           
            
         }];
        
        [self addSubview:_notificationSwitch];
        
        
        
        
    }
    
    return self;
}



- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [DIALOG_BORDER_COLOR set];
    
    NSRectFill(NSMakeRect(30, 0, NSWidth(dirtyRect) - 60, 1));
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_nameTextField setFrameSize:NSMakeSize(newSize.width - 110 - NSWidth(_notificationSwitch.frame), 20)];
    [_notificationSwitch setFrameOrigin:NSMakePoint(newSize.width - 30 - NSWidth(_notificationSwitch.frame), 7)];
}


-(void)redrawRow {
    [super redrawRow];
    
    
    [_notificationSwitch setEnabled:[SettingsArchiver checkMaskedSetting:PushNotifications]];
    
    NotificationConversationRowItem *item = (NotificationConversationRowItem *) [self rowItem];
    
    [_avatarImageView updateWithConversation:item.conversation];
    [_nameTextField updateWithConversation:item.conversation];
 
    [_notificationSwitch setOn:!item.conversation.isMute animated:NO];
    
    
    
}

@end
