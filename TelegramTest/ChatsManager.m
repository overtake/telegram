//
//  ChatsManager.m
//  TelegramTest
//
//  Created by keepcoder on 31.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "ChatsManager.h"
#import "TGFileLocation+Extensions.h"
#import "Crypto.h"
#import <MTProtoKit/MTEncryption.h>
#import "SecretChatAccepter.h"
@implementation ChatsManager
+(id)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}


- (void)add:(NSArray *)all withCustomKey:(NSString*)key {
    
    
    [ASQueue dispatchOnStageQueue:^{
        for (id obj in all) {
            if([obj isKindOfClass:[TL_chatEmpty class]])
                continue;
            
            if([obj isKindOfClass:[TGChat class]]) {
                TGChat *newChat = (TGChat *)obj;
                
                [[FullChatManager sharedManager] loadIfNeed:newChat.n_id];
                
                TGChat *currentChat = [self->keys objectForKey:[obj valueForKey:key]];
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
                
                TGEncryptedChat *newChat = (TGEncryptedChat *)obj;
                TGEncryptedChat *currentChat = [self->keys objectForKey:[obj valueForKey:key]];
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
    
    [ASQueue dispatchOnStageQueue:^{
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
        
        NSData *dhPrime = [response p];
        
        NSMutableData *g_b = [[Crypto exp:[NSData dataWithBytes:&g length:1] b:b dhPrime:dhPrime] mutableCopy];
        
        if( !MTCheckIsSafeGAOrB(g_b, dhPrime)) return;
        
        
        NSData *key_hash = [Crypto exp:[request g_a] b:b dhPrime:dhPrime];
        
        
        NSData *key_fingerprints = [[Crypto sha1:key_hash] subdataWithRange:NSMakeRange(12, 8)];
        long keyId;
        [key_fingerprints getBytes:&keyId];
        
        
        EncryptedParams *params = [[EncryptedParams alloc] initWithChatId:request.n_id encrypt_key:key_hash key_fingerprings:keyId a:b g_a:g_b dh_prime:dhPrime state:EncryptedRequested access_hash:request.access_hash];
        
        [params save];
        
        
        
        [SecretChatAccepter addChatId:params.n_id];
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
    }];
    
    
}


@end
