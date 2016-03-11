//
//  ComposeActionDeleteChannelMessagesBehavior.m
//  Telegram
//
//  Created by keepcoder on 17.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeActionDeleteChannelMessagesBehavior.h"

@implementation ComposeActionDeleteChannelMessagesBehavior


-(void)composeDidCancel {
    
}

-(TL_channel *)channel {
    return self.action.object;
}

-(NSMutableArray *)msgIds {
    return self.action.reservedObject1;
}

-(TLUser *)user {
    return self.action.result.singleObject;
}

-(void)composeDidDone {
    [self.delegate behaviorDidStartRequest];
    [TMViewController showModalProgress];
    id request = [TLAPI_channels_deleteMessages createWithChannel:self.channel.inputPeer n_id:self.msgIds];
    
    [RPCRequest sendRequest:request successHandler:^(id request, id response) {
        
        [[MTNetwork instance].updateService.proccessor addUpdate:[TL_updateDeleteChannelMessages createWithChannel_id:self.channel.n_id messages:self.msgIds pts:[response pts] pts_count:[response pts_count]]];
        
        
        dispatch_block_t success = ^{
            [self.delegate behaviorDidEndRequest:nil];
            [TMViewController hideModalProgressWithSuccess];
        };
        
        
        BOOL banUser = [self.action.result.multiObjects[1] boolValue];
        BOOL reportSpam = [self.action.result.multiObjects[2] boolValue];
        BOOL deleteMessages = [self.action.result.multiObjects[3] boolValue];
        
        
        dispatch_block_t report_spam_block = ^{
            [RPCRequest sendRequest:[TLAPI_channels_reportSpam createWithChannel:self.channel.inputPeer user_id:self.user.inputUser n_id:self.msgIds] successHandler:^(id request, id response1) {
                
                success();
                
            } errorHandler:^(id request, RpcError *error) {
                success();
            }];
        };
        
        dispatch_block_t ban_block = ^{
            
            [RPCRequest sendRequest:[TLAPI_channels_kickFromChannel createWithChannel:self.channel.inputPeer user_id:self.user.inputUser kicked:YES] successHandler:^(id request, id response2) {
               
                if(reportSpam)
                    report_spam_block();
                else
                    success();
                
            } errorHandler:^(id request, RpcError *error) {
                
                if(reportSpam)
                    report_spam_block();
                else
                    success();
                
            }];
            
        };
        
        dispatch_block_t delete_messages_block = ^{
            
            [RPCRequest sendRequest:[TLAPI_channels_deleteUserHistory createWithChannel:self.channel.inputPeer user_id:self.user.inputUser] successHandler:^(id request, id response) {
                
                [[Storage manager] deleteUserChannelMessages:self.channel.n_id from_id:self.user.n_id completeHandler:^(NSArray *peer_updates, NSDictionary *readCount) {
                    
                    [peer_updates enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                        
                        TL_conversation *conversation = [[DialogsManager sharedManager] find:[obj[KEY_PEER_ID] intValue]];
                        
                        [[DialogsManager sharedManager] updateLastMessageForDialog:conversation];
                        
                    }];
                    
                    [Notification perform:MESSAGE_DELETE_EVENT data:@{KEY_DATA:peer_updates}];
                    
                    
                    if(reportSpam)
                        report_spam_block();
                    else if(banUser)
                        ban_block();
                    else
                        success();
                    
                }];
                
                
                
            } errorHandler:^(id request, RpcError *error) {
                
                if(reportSpam)
                    report_spam_block();
                else if(banUser)
                    ban_block();
                else
                    success();
                
            }];
            
        };
        
      
        if(deleteMessages)
            delete_messages_block();
        else if(banUser)
            ban_block();
        else if(reportSpam)
            report_spam_block();
        else
            success();
        
        
        
    } errorHandler:^(id request, RpcError *error) {
        [self.delegate behaviorDidEndRequest:nil];
    }];
}

@end
