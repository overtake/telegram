//
//  ComposeActionSecretChatBehavior.m
//  Telegram
//
//  Created by keepcoder on 29.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeActionSecretChatBehavior.h"
#import "SelectUserItem.h"


@implementation ComposeActionSecretChatBehavior


-(NSUInteger)limit {
    return 0;
}

-(NSAttributedString *)centerTitle {
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:NSLocalizedString(@"Compose.SecretChat", nil) withColor:NSColorFromRGB(0x333333)];
    
    [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
    
    return attr;
}

-(NSString *)doneTitle {
    return nil;
}

-(void)composeDidChangeSelected {
      
    
    if(self.action.result.multiObjects.count == 1) {
        
        [self.delegate behaviorDidStartRequest];
        
        TLUser *user = self.action.result.multiObjects[0];
        
        [MessageSender startEncryptedChat:user callback:^{
            [self.delegate behaviorDidEndRequest:nil];
            
            
            
        }];
    }
    
}


-(void)composeDidCancel {
    [self.delegate behaviorDidEndRequest:nil];
}


@end
