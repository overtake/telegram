//
//  DialogsHistoryController.m
//  Telegram P-Edition
//
//  Created by keepcoder on 12.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DialogsHistoryController.h"
#import "TLPeer+Extensions.h"

@interface DialogsHistoryController ()
@property (nonatomic,strong) ASQueue *queue;
@end

@implementation DialogsHistoryController


-(id)init {
    if(self = [super init]) {
        self.state = DialogsHistoryStateNeedLocal;
        self.queue = [(DialogsManager *)[DialogsManager sharedManager] queue];
    }
    return self;
}

+(DialogsHistoryController *)sharedController {
    static DialogsHistoryController *controller;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[DialogsHistoryController alloc] init];
    });
    return controller;
}

-(void)initialize {
    
}


-(void)next:(int)offset limit:(int)limit callback:(void (^)(NSArray *))callback usersCallback:(void (^)(NSArray *))usersCallback  {
    
    [self.queue dispatchOnQueue:^{
        self.isLoading = YES;
        if(self.state == DialogsHistoryStateNeedLocal) {
            [self loadlocal:offset limit:limit callback:callback];
        } else {
            [self loadremote:offset limit:limit callback:callback];
        }
    }];
}

-(void)loadlocal:(int)offset limit:(int)limit callback:(void (^)(NSArray *))callback  {
        
    [[Storage manager] dialogsWithOffset:offset limit:limit completeHandler:^(NSArray *d, NSArray *m) {
        
        [ASQueue dispatchOnStageQueue:^{
            
            NSMutableArray *converted = [[NSMutableArray alloc] init];
            
            [d enumerateObjectsUsingBlock:^(TL_conversation *obj, NSUInteger idx, BOOL *stop) {
                
                if(![[DialogsManager sharedManager] find:obj.peer_id])
                {
                    [converted addObject:obj];
                }
            }];
            
            [[DialogsManager sharedManager] add:converted];
            [[MessagesManager sharedManager] add:m];
                        
            if(d.count < limit) {
                self.state = DialogsHistoryStateNeedRemote;
                
            }
            
            self.isLoading = NO;
            [[ASQueue mainQueue] dispatchOnQueue:^{
                if(callback)
                    callback(converted);
            }];
        }];
       
    }];
}

-(void)loadremote:(int)offset limit:(int)limit callback:(void (^)(NSArray *))callback  {
    
    [RPCRequest sendRequest:[TLAPI_messages_getDialogs createWithOffset:offset limit:limit]successHandler:^(RPCRequest *request, id response) {
        
        TL_messages_dialogs *dialogs = response;
        
        
        [SharedManager proccessGlobalResponse:response];
        
        
        NSMutableArray *converted = [[NSMutableArray alloc] init];
        for (TL_dialog *dialog in [dialogs dialogs]) {
            
            TLMessage *msg = [[MessagesManager sharedManager] find:dialog.top_message];
            
            if(![[DialogsManager sharedManager] find:dialog.peer.peer_id])
                [converted addObject:[TL_conversation createWithPeer:dialog.peer top_message:dialog.top_message unread_count:dialog.unread_count last_message_date:msg.date notify_settings:dialog.notify_settings last_marked_message:dialog.top_message top_message_fake:dialog.top_message last_marked_date:msg.date sync_message_id:msg.n_id]];
    
            
            
            
        }
        
        [[DialogsManager sharedManager] add:converted];
        [[Storage manager] insertDialogs:converted completeHandler:nil];
        
        [MessagesManager updateUnreadBadge];
        
        
        if(converted.count < limit) {
            self.state = DialogsHistoryStateEnd;
        } 
        
         self.isLoading = NO;
        
        
        
        [[ASQueue mainQueue] dispatchOnQueue:^{
            if(callback)
                callback(converted);
        }];
        
        
       
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        self.isLoading = NO;
        
        if(error.error_code == 502) {
            [self loadremote:offset limit:limit callback:callback];
            return;
        }
        
    } timeout:10 queue:self.queue.nativeQueue];

}

-(void)drop {
    self.state = DialogsHistoryStateNeedLocal;
}



@end
