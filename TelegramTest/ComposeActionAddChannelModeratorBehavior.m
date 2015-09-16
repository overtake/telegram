//
//  ComposeActionAddChannelModeratorBehavior.m
//  Telegram
//
//  Created by keepcoder on 16.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeActionAddChannelModeratorBehavior.h"
#import "SelectUserItem.h"
@implementation ComposeActionAddChannelModeratorBehavior

-(NSString *)doneTitle {
    return NSLocalizedString(@"Compose.Next", nil);
}

-(NSUInteger)limit {
    return 1;
}

-(TL_channel *)chat {
    return self.action.object;
}


-(void)composeDidDone {
    
    if([self.action.currentViewController isKindOfClass:[ComposePickerViewController class]])  {
        [[Telegram rightViewController] showComposeAddModerator:self.action];
    } else {
        [self.delegate behaviorDidStartRequest];
        
        [RPCRequest sendRequest:[TLAPI_channels_editAdmin createWithChannel:self.chat.inputPeer user_id:[[(SelectUserItem *)self.action.result.multiObjects[0] user] inputUser] role: [self.action.result.singleObject boolValue] ? [TL_channelRoleModerator create] : [TL_channelRoleEditor create]] successHandler:^(id request, id response) {
                        
            NSArray *stack = self.action.currentViewController.navigationViewController.viewControllerStack;
            
            NSUInteger idx = [stack indexOfObject:[Telegram rightViewController].channelInfoViewController];
            
            self.action.currentViewController.navigationViewController.viewControllerStack =[[stack subarrayWithRange:NSMakeRange(0, idx)] mutableCopy];
            
            
            [[Telegram rightViewController] showChannelInfoPage:self.chat];

            
            [self.delegate behaviorDidEndRequest:response];
            
        } errorHandler:^(id request, RpcError *error) {
            [self.delegate behaviorDidEndRequest:nil];
        }];
        
    }
    
 //   [self.delegate behaviorDidStartRequest];
    
  //  [self addMembersToChat:[self.action.result.multiObjects mutableCopy] toChatId:self.chat.n_id];
    
}


@end
