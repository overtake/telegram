//
//  ComposeActionMultiObserver.m
//  Telegram
//
//  Created by keepcoder on 28.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeActionGroupBehavior.h"
#import "ComposeChatCreateViewController.h"
#import "ComposePickerViewController.h"
#import "SelectUserItem.h"
@interface ComposeActionGroupBehavior ()
@property (nonatomic,strong) RPCRequest *request;
@end

@implementation ComposeActionGroupBehavior

-(NSUInteger)limit {
    return maxChatUsers()-1;
}

-(NSString *)doneTitle {
    return [self.action.currentViewController isKindOfClass:[ComposePickerViewController class]] ? NSLocalizedString(@"Compose.Next", nil) : NSLocalizedString(@"Compose.Create", nil);
}

-(NSAttributedString *)centerTitle {
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    if([self.action.currentViewController isKindOfClass:[ComposePickerViewController class]]) {
        
        [attr appendString:NSLocalizedString(@"Compose.GroupTitle", nil) withColor:NSColorFromRGB(0x333333)];
        
        NSRange range = [attr appendString:[NSString stringWithFormat:@" - %lu/%lu",self.action.result.multiObjects.count,[self limit]] withColor:DARK_GRAY];
        
        [attr setFont:TGSystemFont(12) forRange:range];
        

        
    } else {
        [attr appendString:NSLocalizedString(@"Compose.GroupTitle", nil) withColor:NSColorFromRGB(0x333333)];
    }
    
    [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
    
    return attr;
}


-(void)composeDidDone {
    if([self.action.currentViewController isKindOfClass:[ComposePickerViewController class]]) {
        
        ComposeChatCreateViewController *viewController = [[ComposeChatCreateViewController alloc] initWithFrame:NSZeroRect];
        
        [viewController setAction:self.action];
        
        [self.action.currentViewController.navigationViewController pushViewController:viewController animated:YES];
                
    } else {
        
        [self.delegate behaviorDidStartRequest];
        
        [self createGroupChat];
        
    }
}


-(void)createGroupChat {
    NSArray *selected = self.action.result.multiObjects;
    

    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(TLUser* item in selected) {
        if(item.type != TLUserTypeSelf) {
            [array addObject:[item inputUser]];
        }
        
    }
    
    self.request = [RPCRequest sendRequest:[TLAPI_messages_createChat createWithUsers:array title:self.action.result.singleObject] successHandler:^(RPCRequest *request, TLUpdates * response) {
        
        if(response.updates.count > 1) {
            TL_localMessage *msg = [TL_localMessage convertReceivedMessage:(TLMessage *) ( [response.updates[2] message])];
            
            [[FullChatManager sharedManager] performLoad:msg.conversation.chat.n_id callback:^(TLChatFull *fullChat) {
                [self.delegate behaviorDidEndRequest:response];
                
                [self.action.currentViewController.navigationViewController showMessagesViewController:msg.conversation];
            }];
        }
        
        
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        [self.delegate behaviorDidEndRequest:nil];
    } timeout:10 queue:[ASQueue globalQueue].nativeQueue];
    
    
}



-(void)composeDidCancel {
    
    
    [self.request cancelRequest];
    
    [self.delegate behaviorDidEndRequest:nil];
}



@end
