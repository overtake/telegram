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
    return [self.action.currentViewController isKindOfClass:[ComposePickerViewController class]] ? @"" : NSLocalizedString(@"Compose.Next", nil);
}

-(NSUInteger)limit {
    return 0;
}

-(NSAttributedString *)centerTitle {
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:NSLocalizedString(@"Compose.Contacts", nil) withColor:NSColorFromRGB(0x333333)];
    
    [attr setAlignment:NSCenterTextAlignment range:attr.range];
    
    return attr;
}

-(TL_channel *)chat {
    return self.action.object;
}

-(TLUser *)user {
    return self.action.result.multiObjects[0];
}


-(void)composeDidChangeSelected {
    [self composeDidDone];
}

-(void)composeDidDone {
    
    if([self.action.currentViewController isKindOfClass:[ComposePickerViewController class]])  {
        
        if(!self.chat.isBroadcast && !self.chat.isMegagroup) {
            
            ComposeConfirmModeratorViewController *viewController = [[ComposeConfirmModeratorViewController alloc] initWithFrame:self.action.currentViewController.view.bounds];
            
            [viewController setAction:self.action];
            
            [self.action.currentViewController.navigationViewController pushViewController:viewController animated:YES];
        } else {
            self.action.result.singleObject = [TL_channelRoleEditor create];
            [self addAccess];
        }
        
    } else {
        
        [self addAccess];
        
    }
    
}


-(void)addAccess {
   
    
    confirm(appName(), NSLocalizedString(@"Chat.ToggleUserToAdminConfirm", nil), ^{
        [RPCRequest sendRequest:[TLAPI_channels_editAdmin createWithChannel:self.chat.inputPeer user_id:[self.user inputUser] role: self.action.result.singleObject] successHandler:^(id request, id response) {
            
             [self.delegate behaviorDidStartRequest];
            
            [RPCRequest sendRequest:[TLAPI_channels_getParticipants createWithChannel:self.chat.inputPeer filter:[TL_channelParticipantsAdmins create] offset:0 limit:100] successHandler:^(id request, TL_channels_channelParticipants *response) {
                
                [SharedManager proccessGlobalResponse:response];
                
                [[FullChatManager sharedManager] performLoad:self.chat.n_id force:YES callback:^(TLChatFull *fullChat) {
                    ComposeAction *action = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBehavior class] filter:@[] object:self.chat];
                    
                    action.result = [[ComposeResult alloc] initWithMultiObjects:response.participants];
                    
                    ComposeManagmentViewController *viewController =  [[ComposeManagmentViewController alloc] initWithFrame:self.action.currentViewController.view.bounds];
                    
                    [viewController setAction:self.action];
                    
                    [self.action.currentViewController.navigationViewController gotoViewController:viewController];
                    
                    [self.delegate behaviorDidEndRequest:response];
                }];
                
                
                
            } errorHandler:^(id request, RpcError *error) {
                [self.delegate behaviorDidEndRequest:nil];
            }];
            
            
            
        } errorHandler:^(id request, RpcError *error) {
            [self.delegate behaviorDidEndRequest:nil];
            
            if(error.error_code == 400) {
                alert(appName(), NSLocalizedString(error.error_msg, nil));
            }
            
        }];
    }, nil);
    
}


@end
