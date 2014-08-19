//
//  MTProtoConnect.m
//  TelegramTest
//
//  Created by keepcoder on 07.09.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TGInitializer.h"
#import "AppDelegate.h"
#import "NSString+NSStringHexToBytes.h"
#import <zlib.h>
#import <CoreFoundation/CoreFoundation.h>
#import "NSMutableData+Extension.h"
#import "NSData+Extensions.h"
#import "Crypto.h"
#import "CMath.h"
#import "RPCRequest.h"
#import "TLRPCApi.h"
#import "DialogsHistoryController.h"
@implementation TGInitializer

-(id)init {
    if(self = [super init]) {
        if([[MTNetwork instance] isAuth]) {
            [self localInitialize];
        } else {
            [self showAuthWindow];
        }
    }
    return self;
}


-(void)showAuthWindow {
//    [[Telegram sharedInstance] showLoginViewController:YES];
}


- (void) onAuthSuccess {
    
    [[DialogsHistoryController sharedController] setState:DialogsHistoryStateNeedRemote];
    [[DialogsHistoryController sharedController] next:0 limit:20 callback:^(NSArray *result) {
        [Notification perform:APP_RUN object:nil];
        [Notification perform:DIALOGS_NEED_FULL_RESORT data:@{KEY_DIALOGS:result}];
        [Notification perform:PROTOCOL_UPDATED data:nil];
        [[NewContactsManager sharedManager] fullReload];
//        [PushNotificationsManager sharedManager];
    } usersCallback:nil];
    
//    [[Telegram sharedInstance] showLoginViewController:NO];
}

-(void)localInitialize {
    
    

    [[Storage manager] users:^(NSArray *result) {

        [[UsersManager sharedManager] addFromDB:result];
        [[Storage manager] loadChats:^(NSArray *chats) {
            [[ChatsManager sharedManager] add:chats];
            [[DialogsHistoryController sharedController] next:0 limit:20 callback:^(NSArray *result) {
            
                [[NewContactsManager sharedManager] fullReload];
                [[FullChatManager sharedManager] loadStored];
            
                [Notification perform:DIALOGS_NEED_FULL_RESORT data:@{KEY_DIALOGS:result}];
                [Notification perform:APP_RUN object:nil];
//                [PushNotificationsManager sharedManager];
            
            } usersCallback:nil];
         }];
    
        [[Storage manager] unreadCount:^(int count) {
            [[MessagesManager sharedManager] setUnreadCount:count];
        }];
    }];
    
}




@end
