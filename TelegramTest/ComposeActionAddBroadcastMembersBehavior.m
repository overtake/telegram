//
//  ComposeActionAddBroadcastMembersBehavior.m
//  Telegram
//
//  Created by keepcoder on 03.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeActionAddBroadcastMembersBehavior.h"
#import "SelectUserItem.h"
@implementation ComposeActionAddBroadcastMembersBehavior


-(TL_broadcast *)broadcast {
    return self.action.object;
}

-(NSUInteger)limit {
    return maxBroadcastUsers() - self.broadcast.participants.count;
}


-(NSString *)doneTitle {
    return NSLocalizedString(@"Compose.AddMembers", nil);
}

-(NSAttributedString *)centerTitle {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:NSLocalizedString(@"Compose.Contacts", nil) withColor:NSColorFromRGB(0x333333)];
    
    NSRange range = [attr appendString:[NSString stringWithFormat:@" - %lu/%lu",self.action.result.multiObjects.count,[self limit]] withColor:DARK_GRAY];
    
    [attr setFont:TGSystemFont(12) forRange:range];
    
    [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
    
    return attr;
}


-(void)composeDidDone {
    
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    
    [self.action.result.multiObjects enumerateObjectsUsingBlock:^(SelectUserItem *obj, NSUInteger idx, BOOL *stop) {
        [ids addObject:@(obj.user.n_id)];
    }];
    
    
    [self.broadcast addParticipants:ids];
    
    [Notification perform:BROADCAST_STATUS data:@{KEY_CHAT_ID:@(self.broadcast.n_id)}];
    
    [[[BroadcastManager sharedManager] broadcastMembersCheckerById:self.broadcast.n_id] reloadParticipants];
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [self.action.currentViewController.navigationViewController goBackWithAnimation:YES];
    });
    
    
   
    
}




@end
