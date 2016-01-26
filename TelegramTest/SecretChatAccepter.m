//
//  SecretChatAccepter.m
//  Telegram
//
//  Created by keepcoder on 11.06.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SecretChatAccepter.h"
#import "UpgradeLayerSenderItem.h"
@interface SecretChatAccepter ()
@property (nonatomic,strong) NSMutableArray *ids;
@end

@implementation SecretChatAccepter


static NSString *kChatIdsForAccept = @"kChatIdsForAccept";

-(id)init {
    if(self = [super init]) {
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kChatIdsForAccept];
        
        _ids = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if(!_ids)
            _ids = [[NSMutableArray alloc] init];
        
        
        [Notification addObserver:self selector:@selector(proccess:) name:USER_ONLINE_CHANGED];
        
        [self proccess:nil];
    }
    
    return self;
}


-(void)save {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_ids];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kChatIdsForAccept];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(void)proccess:(NSNotification *)notify {
    if([[UsersManager currentUser] isOnline]) {
        
        [_ids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            int chat_id = [obj intValue];
            
            // accept chat;
            
            EncryptedParams *params = [EncryptedParams findAndCreate:chat_id];
            
            [RPCRequest sendRequest:[TLAPI_messages_acceptEncryption createWithPeer:[TL_inputEncryptedChat createWithChat_id:chat_id access_hash:params.access_hash] g_b:params.g_a_or_b key_fingerprint:params.key_fingerprint] successHandler:^(RPCRequest *request3, TL_encryptedChat * acceptResponse) {
                
                TL_conversation *dialog = [TL_conversation createWithPeer:[TL_peerSecret createWithChat_id:acceptResponse.n_id] top_message:-1 unread_count:0 last_message_date:[[MTNetwork instance] getTime] notify_settings:[TL_peerNotifySettingsEmpty create] last_marked_message:0 top_message_fake:-1 last_marked_date:[[MTNetwork instance] getTime] sync_message_id:0 read_inbox_max_id:0 unread_important_count:0 lastMessage:nil];
                
                [[ChatsManager sharedManager] add:@[acceptResponse]];
                [[DialogsManager sharedManager] insertDialog:dialog];
                
                [[Storage manager] insertEncryptedChat:acceptResponse];
                
                
                [params setState:EncryptedAllowed];
                
                [params save];
                
                [Notification perform:DIALOG_TO_TOP data:@{KEY_DIALOG:dialog}];
                
                [SecretChatAccepter removeChatId:chat_id];
                
                UpgradeLayerSenderItem *upgradeLayer = [[UpgradeLayerSenderItem alloc] initWithConversation:dialog];
                
                [upgradeLayer send];
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                [SecretChatAccepter removeChatId:chat_id];
            }];

        }];
        
    }
}

-(void)addChatId:(int)chat_id {
    [_ids addObject:@(chat_id)];
    [self save];
    [self proccess:nil];
}

-(void)removeChatId:(int)chat_id {
    [_ids removeObject:@(chat_id)];
    
    [self save];
}

+(void)addChatId:(int)chat_id {
    [ASQueue dispatchOnStageQueue:^{
        [[SecretChatAccepter instance] addChatId:chat_id];
    }];
}

+(void)removeChatId:(int)chat_id {
    [ASQueue dispatchOnStageQueue:^{
        [[SecretChatAccepter instance] removeChatId:chat_id];
    }];
}

-(void)dealloc {
    [Notification removeObserver:self];
}

+(instancetype)instance {
    static SecretChatAccepter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SecretChatAccepter alloc] init];
    });
    
    return instance;
}


@end
