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

-(TLUser *)user {
    return self.action.result.multiObjects[0];
}


-(void)composeDidDone {
    
    if([self.action.currentViewController isKindOfClass:[ComposePickerViewController class]])  {
        
        [self.delegate behaviorDidStartRequest];
        
        [RPCRequest sendRequest:[TLAPI_channels_getParticipant createWithChannel:self.chat.inputPeer user_id:[self.user inputUser]] successHandler:^(id request, TLChatParticipant *response) {
            
            [self.delegate behaviorDidEndRequest:response];
            
            [[Telegram rightViewController] showComposeAddModerator:self.action];
            
        } errorHandler:^(id request, RpcError *error) {
            [self.delegate behaviorDidEndRequest:nil];
            
            if(error.error_code == 400) {
                
                if([error.error_msg isEqualToString:@"USER_NOT_PARTICIPANT"]) {
                    confirm(appName(), [NSString stringWithFormat:NSLocalizedString(error.error_msg, nil),self.user.first_name], ^{
                        
                        [self.delegate behaviorDidStartRequest];
                        
                        [RPCRequest sendRequest:[TLAPI_channels_inviteToChannel createWithChannel:self.chat.inputPeer users:[@[self.user.inputUser] mutableCopy]] successHandler:^(id request, id response) {
                            
                            [self.delegate behaviorDidEndRequest:response];
                            [[Telegram rightViewController] showComposeAddModerator:self.action];
                            
                        } errorHandler:^(id request, RpcError *error) {
                            
                            if(error.error_code == 400) {
                                alert(appName(), NSLocalizedString(error.error_msg, nil));
                            }
                            
                            [self.delegate behaviorDidEndRequest:nil];
                        }];
                        
                    }, nil);
                } else {
                    alert(appName(), NSLocalizedString(error.error_msg, nil));
                }
                
                
            }
            
            
        }];
        
        
    } else {
        [self.delegate behaviorDidStartRequest];
        
        [RPCRequest sendRequest:[TLAPI_channels_editAdmin createWithChannel:self.chat.inputPeer user_id:[self.user inputUser] role: self.action.result.singleObject] successHandler:^(id request, id response) {
            
            
            [RPCRequest sendRequest:[TLAPI_channels_getParticipants createWithChannel:self.chat.inputPeer filter:[TL_channelParticipantsAdmins create] offset:0 limit:100] successHandler:^(id request, TL_channels_channelParticipants *response) {
                
                [SharedManager proccessGlobalResponse:response];
                
                ComposeAction *action = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBehavior class] filter:@[] object:self.chat];
                
                action.result = [[ComposeResult alloc] initWithMultiObjects:response.participants];
                
                
                NSArray *stack = self.action.currentViewController.navigationViewController.viewControllerStack;
                
                NSUInteger idx = [stack indexOfObject:[Telegram rightViewController].composeManagmentViewController];
                
                self.action.currentViewController.navigationViewController.viewControllerStack =[[stack subarrayWithRange:NSMakeRange(0, idx)] mutableCopy];
                
                
                [[Telegram rightViewController] showComposeManagment:action];
                
                [self.delegate behaviorDidEndRequest:response];
                
            } errorHandler:^(id request, RpcError *error) {
                [self.delegate behaviorDidEndRequest:nil];
            }];
            
            

            
            [self.delegate behaviorDidEndRequest:response];
            
        } errorHandler:^(id request, RpcError *error) {
            [self.delegate behaviorDidEndRequest:nil];
        }];
        
    }
    
}


@end
