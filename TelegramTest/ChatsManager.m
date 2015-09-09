//
//  ChatsManager.m
//  TelegramTest
//
//  Created by keepcoder on 31.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "ChatsManager.h"
#import "TLFileLocation+Extensions.h"
#import "Crypto.h"
#import <MTProtoKit/MTEncryption.h>
#import "SecretChatAccepter.h"
@implementation ChatsManager
+(id)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] initWithQueue:[ASQueue globalQueue]];
    });
    return instance;
}


- (void)add:(NSArray *)all withCustomKey:(NSString*)key {
    
    
    
    [self.queue dispatchOnQueue:^{
        
        for (id obj in all) {
            if([obj isKindOfClass:[TL_chatEmpty class]])
                continue;
            
            if([obj isKindOfClass:[TLChat class]]) {
                TLChat *newChat = (TLChat *)obj;
                
            //    [[FullChatManager sharedManager] loadIfNeed:newChat.n_id force:NO];
                
                TLChat *currentChat = [self->keys objectForKey:[obj valueForKey:key]];
                if(currentChat != nil) {
                    
                    
                    if([currentChat.photo.photo_small hashCacheKey] != [newChat.photo.photo_small hashCacheKey]) {
                        currentChat.photo = newChat.photo;
                        [Notification perform:CHAT_UPDATE_PHOTO data:@{KEY_CHAT: currentChat}];
                    }
                    
                    if(![currentChat.title isEqualToString:newChat.title]) {
                        currentChat.title = newChat.title;
                        [Notification perform:CHAT_UPDATE_TITLE data:@{KEY_CHAT: currentChat}];
                    }
                    
                    currentChat.participants_count = newChat.participants_count;
                    currentChat.date = newChat.date;
                    currentChat.version = newChat.version;
                    currentChat.access_hash = newChat.access_hash;
                    
                    BOOL isNeedUpdateTypeNotification = NO;
                    if(currentChat.left != newChat.left) {
                        currentChat.left = newChat.left;
                        isNeedUpdateTypeNotification = YES;
                    }
                    
                    if(currentChat.type != newChat.type) {
                        currentChat.type = newChat.type;
                        isNeedUpdateTypeNotification = YES;
                    }
                    
                    if(isNeedUpdateTypeNotification)
                        [Notification perform:CHAT_UPDATE_TYPE data:@{KEY_CHAT:currentChat}];
                    
                    
                } else {
                    [self->list addObject:newChat];
                    [self->keys setObject:newChat forKey:[newChat valueForKey:key]];
                }
                
            } else {
                //ECRYPTED CHAT
                
                TLEncryptedChat *newChat = (TLEncryptedChat *)obj;
                TLEncryptedChat *currentChat = [self->keys objectForKey:[obj valueForKey:key]];
                if(currentChat != nil) {
                    
                    currentChat.date = newChat.date;
                    currentChat.g_a = newChat.g_a;
                    currentChat.g_a_or_b = newChat.g_a_or_b;
                    currentChat.key_fingerprint = newChat.key_fingerprint;
                    
                } else {
                    [self->list addObject:newChat];
                    [self->keys setObject:newChat forKey:[newChat valueForKey:key]];
                }
            }
        }

    }];
}


- (NSArray *)secretChats {
    
    NSMutableArray *filtred = [[NSMutableArray alloc ] init];
    
    [self.queue dispatchOnQueue:^{
        for (id current in self->list) {
            if([current class] == [TL_encryptedChat class]) {
                [filtred addObject:current];
            }
        }
    } synchronous:YES];
  
    
    return filtred;
}



-(void)acceptEncryption:(TL_encryptedChatRequested *)request {
    
    
    [RPCRequest sendRequest:[TLAPI_messages_getDhConfig createWithVersion:1 random_length:256] successHandler:^(RPCRequest *requestR, TL_messages_dhConfig *response) {
        
        uint8_t bBytes[256] = {};
        
        for (int i = 0; i < 256 && i < (int)response.random.length; i++)
        {
            uint8_t currentByte = ((uint8_t *)response.random.bytes)[i];
            bBytes[i] ^= currentByte;
        }
        
        NSData *b = [[NSData alloc] initWithBytes:bBytes length:256];
        
        int g = [response g];
        
        if(!MTCheckIsSafeG(g)) return;
        
        NSData *p = [response p];
        
        NSData *g_b = MTExp([NSData dataWithBytes:&g length:1], b, p);
        
        if( !MTCheckIsSafeGAOrB(g_b, p)) return;
        
        
        NSData *key_hash = MTExp([request g_a], b, p);
        
        NSData *key_fingerprints = [[Crypto sha1:key_hash] subdataWithRange:NSMakeRange(12, 8)];
        long keyId;
        [key_fingerprints getBytes:&keyId];
        
        
        EncryptedParams *params = [[EncryptedParams alloc] initWithChatId:request.n_id encrypt_key:key_hash key_fingerprint:keyId a:b p:p random:[response random] g_a_or_b:g_b g:g state:EncryptedRequested access_hash:request.access_hash layer:MIN_ENCRYPTED_LAYER isAdmin:NO];
        
        [params save];
        
        
        
        [SecretChatAccepter addChatId:params.n_id];
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
    }];
    
    
}

-(void)updateChannelUserName:(NSString *)userName channel:(TL_channel *)channel completeHandler:(void (^)(TL_channel *))completeHandler errorHandler:(void (^)(NSString *))errorHandler  {
    
    [RPCRequest sendRequest:[TLAPI_messages_updateChannelUsername createWithChat_id:channel.input username:userName] successHandler:^(id request, id response) {
        
        if([response isKindOfClass:[TL_boolTrue class]]) {
            channel.username = userName;
            [[Storage manager] insertChat:channel completeHandler:nil];
            
            if(completeHandler != nil) {
                completeHandler(channel);
            }
        }
        
    } errorHandler:^(id request, RpcError *error) {
        
        if(errorHandler != nil) {
            errorHandler(error.error_msg);
        }
        
    }];
    
}


@end
