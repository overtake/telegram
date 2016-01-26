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
#import "ComposeActionAddBroadcastMembersBehavior.h"
#import "ComposeAction.h"
@implementation BroadcastInfoHeaderView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        
        
        weakify();
        
        [self.sharedMediaButton.textButton setTapBlock:^ {
            
            
            
        }];
        
        [self.addMembersButton.textButton setTapBlock:^ {
            NSMutableArray *filter = [[NSMutableArray alloc] init];
            
            for (NSNumber *participant in strongSelf.controller.broadcast.participants) {
                [filter addObject:participant];
            }
            
            if(strongSelf.controller.broadcast.participants.count < maxBroadcastUsers()) {
                [[Telegram rightViewController] showComposeWithAction:[[ComposeAction alloc]initWithBehaviorClass:[ComposeActionAddBroadcastMembersBehavior class] filter:filter object:strongSelf.controller.broadcast]];
            }
        }];
        
        
        [self.setGroupPhotoButton setHidden:YES];
        
        [self.addMembersButton setHidden:NO];
        
        [self.sharedMediaButton setHidden:NO];
        
        
        
        
        
        [self.addMembersButton setFrameOrigin:NSMakePoint(100, self.bounds.size.height - 156)];
        
        
        [self.sharedMediaButton setFrameOrigin:NSMakePoint(self.addMembersButton.frame.origin.x, self.addMembersButton.frame.origin.y - 72)];
        
        [self.notificationView setHidden:YES];
        

    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


- (void)reload {
    
    TL_broadcast *broadcast = self.controller.broadcast;
        
    [self.statusTextField setBroadcast:broadcast];
    
    [self.avatarImageView setBroadcast:self.controller.broadcast];
    
    [self.avatarImageView setSourceType:ChatAvatarSourceBroadcast];
   
    [self.avatarImageView rebuild];
    
    [self.nameTextField setBroadcast:broadcast];
    
    [self.sharedMediaButton setConversation:broadcast.conversation];
    
    
    BOOL isMute = broadcast.conversation.isMute;

    [self.notificationSwitcher setOn:!isMute animated:YES];
}

@end
