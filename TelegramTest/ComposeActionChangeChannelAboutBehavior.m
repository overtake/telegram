//
//  ComposeActionChangeChannelAboutBehavior.m
//  Telegram
//
//  Created by keepcoder on 05/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "ComposeActionChangeChannelAboutBehavior.h"

@implementation ComposeActionChangeChannelAboutBehavior


-(NSAttributedString *)centerTitle {
    return [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Compose.ChannelAboutPlaceholder", nil) attributes:@{NSFontAttributeName:TGSystemFont(15)}];
}


-(void)composeDidDone {
    [self.action.currentViewController showModalProgress];
    
    TLChat *chat = self.action.object;
    
    [RPCRequest sendRequest:[TLAPI_channels_editAbout createWithChannel:chat.inputPeer about:self.action.result.singleObject] successHandler:^(RPCRequest *request, id response) {
        
        if(chat.chatFull != nil) {
            chat.chatFull.about =  self.action.result.singleObject;
            
            [[Storage manager] insertFullChat:chat.chatFull completeHandler:nil];
        } else {
            [[FullChatManager sharedManager] loadIfNeed:chat.n_id force:YES];
        }
        
        [self.action.currentViewController hideModalProgressWithSuccess];
        
        [self.action.currentViewController.navigationViewController goBackWithAnimation:YES];
        
    } errorHandler:^(id request, RpcError *error) {
        
        [self.action.currentViewController hideModalProgress];
        
    }];
}

@end
