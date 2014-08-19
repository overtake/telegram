//
//  BroadcastInfoHeaderView.m
//  Telegram
//
//  Created by keepcoder on 11.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "BroadcastInfoHeaderView.h"
#import "PhotoHistoryFilter.h"
#import "SelectUserItem.h"
@implementation BroadcastInfoHeaderView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        
        
        float offsetRight = self.bounds.size.width - 286;
        
        weakify();
        
        [self.sharedMediaButton.textButton setTapBlock:^ {
            
            [[Telegram rightViewController].messagesViewController setHistoryFilter:[PhotoHistoryFilter class] force:NO];
            
            
            [[Telegram rightViewController] showByDialog:strongSelf.controller.broadcast.conversation
                                                withJump:0 historyFilter:[PhotoHistoryFilter class] sender:strongSelf];
        }];
        
        [self.addMembersButton.textButton setTapBlock:^ {
            NSMutableArray *filter = [[NSMutableArray alloc] init];
            
            for (NSNumber *participant in strongSelf.controller.broadcast.participants) {
                [filter addObject:participant];
            }
            
            [[Telegram leftViewController] showNewConversationPopover:NewConversationActionChoosePeople filter:filter target:strongSelf selector:@selector(didChoosedUsers:) toButton:strongSelf.addMembersButton title:NSLocalizedString(@"Group.AddMembers", nil)];
        }];
        
        
        [self.createdByTextField setHidden:YES];
        
        [self.setGroupPhotoButton setHidden:YES];
        
        
        [self.addMembersButton setFrameSize:NSMakeSize(offsetRight, 0)];
        [self.addMembersButton setFrameOrigin:NSMakePoint(170, self.bounds.size.height - 146)];
        
        
        [self.sharedMediaButton setFrameSize:NSMakeSize(self.addMembersButton.bounds.size.width, 0)];
        [self.sharedMediaButton setFrameOrigin:NSMakePoint(self.addMembersButton.frame.origin.x, self.addMembersButton.frame.origin.y - 72)];
        
        [self.notificationView setHidden:YES];

    }
    return self;
}

-(void)didChoosedUsers:(NSArray *)users {
    
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    
    [users enumerateObjectsUsingBlock:^(SelectUserItem *obj, NSUInteger idx, BOOL *stop) {
        [ids addObject:@(obj.contact.user_id)];
    }];
    
    if((self.controller.broadcast.participants.count + ids.count) > MAX_BROADCAST_USERS) {
        ids = [[ids subarrayWithRange:NSMakeRange(0, MAX_BROADCAST_USERS - self.controller.broadcast.participants.count )] mutableCopy];
    }
    
   
    
    [self.controller.broadcast addParticipants:ids];
    
    [Notification perform:BROADCAST_STATUS data:@{KEY_CHAT_ID:@(self.controller.broadcast.n_id)}];
    
    [[[BroadcastManager sharedManager] broadcastMembersCheckerById:self.controller.broadcast.n_id] reloadParticipants];
    
    [self.controller reloadParticipants];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


- (void)reload {
    
    TL_broadcast *broadcast = self.controller.broadcast;
    
    [self.avatarImageView setBroadcast:self.controller.broadcast];
    
    [self.avatarImageView setSourceType:ChatAvatarSourceBroadcast];
   
    [self.avatarImageView rebuild];
    
    [self.nameTextField setBroadcast:broadcast];
    
    [self.sharedMediaButton setConversation:broadcast.conversation];
    
    
    
    BOOL isMute = broadcast.conversation.isMute;
    [self.notificationView.switchControl setOn:!isMute animated:YES];
}

@end
