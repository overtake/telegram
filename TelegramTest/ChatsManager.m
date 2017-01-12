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
#import <MtProtoKitMac/MTEncryption.h>
#import "SecretChatAccepter.h"
#import "TGSearchSignalKit.h"



@interface ChatsManager ()
@end

@implementation ChatsManager
+(id)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] initWithQueue:[ASQueue globalQueue]];
    });
    return instance;
}

-(id)initWithQueue:(ASQueue *)queue {
    if(self = [super initWithQueue:queue]) {
    }
    
    return self;
}


- (SSignal *)add:(NSArray *)all withCustomKey:(NSString*)key autoStart:(BOOL)autoStart {
    
    SSignal *signal = [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber * subscriber) {
        
        __block BOOL dispose = NO;
        
        NSMutableArray *chatsToUpdate = [NSMutableArray array];
        
        
        for (id obj in all) {
            if([obj isKindOfClass:[TL_chatEmpty class]]) 
                continue;
            
            if([obj isKindOfClass:[TLChat class]]) {
                TLChat *newChat = (TLChat *)obj;
                
                
                TLChat *currentChat = [self->keys objectForKey:[obj valueForKey:key]];
                if(currentChat != nil) {
                    
                    BOOL isNeedUpdateTypeNotification = NO;
                    BOOL isUpdated = NO;
                    if(!newChat.isMin) {
                        
                        isUpdated = currentChat.flags != newChat.flags || currentChat.class != newChat.class;
                        
                        if([currentChat.photo.photo_small hashCacheKey] != [newChat.photo.photo_small hashCacheKey]) {
                            isUpdated = YES;
                            currentChat.photo = newChat.photo;
                            [Notification perform:CHAT_UPDATE_PHOTO data:@{KEY_CHAT: currentChat}];
                        }
                        
                        if(![currentChat.title isEqualToString:newChat.title]) {
                            isUpdated = YES;
                            currentChat.title = newChat.title;
                            
                            [Notification perform:CHAT_UPDATE_TITLE data:@{KEY_CHAT: currentChat}];
                        }
                        
                        if(![currentChat.username isEqualToString:newChat.username]) {
                            
                            
                            currentChat.username = newChat.username;
                            isUpdated = YES;
                        }
                        
                        if(currentChat.participants_count != newChat.participants_count) {
                            isUpdated = YES;
                            currentChat.participants_count = newChat.participants_count;
                        }
                        if(currentChat.date != newChat.date) {
                            currentChat.date = newChat.date;
                            isUpdated = YES;
                        }
                        
                        if(currentChat.access_hash != newChat.access_hash) {
                            isUpdated = YES;
                            currentChat.access_hash = newChat.access_hash;
                        }
                        
                        
                        if(currentChat.version != newChat.version) {
                            isUpdated = YES;
                            currentChat.version = newChat.version;
                            
                            [[ChatFullManager sharedManager] requestChatFull:currentChat.n_id force:YES];
                        }
                        
                        if(currentChat.flags != newChat.flags) {
                            if(!(currentChat.type == TLChatTypeNormal && newChat.type == TLChatTypeForbidden)) {
                                currentChat.flags = newChat.flags;
                                isNeedUpdateTypeNotification = YES;
                            }
                        }
                        
                        if((currentChat.migrated_to || newChat.migrated_to) && (![currentChat.migrated_to isKindOfClass:newChat.migrated_to.class] || currentChat.migrated_to.channel_id !=  newChat.migrated_to.channel_id)) {
                            currentChat.migrated_to = newChat.migrated_to;
                            isUpdated = YES;
                            if(currentChat.isDeactivated && currentChat.migrated_to.channel_id != 0) {
                                [Notification perform:DIALOG_DELETE data:@{KEY_DIALOG:currentChat.dialog,KEY_DATA:@(YES)}];
                            }
                        }
                        
                        
                        
                        if(currentChat.type != newChat.type) {
                            isUpdated = YES;
                            currentChat.type = newChat.type;
                            isNeedUpdateTypeNotification = YES;
                        }
                        
                    } else {
                        
                        isUpdated = isNeedUpdateTypeNotification = newChat.flags != currentChat.flags;
                        
                        if(newChat.isBroadcast)
                            currentChat.flags|= (1 << 5);
                        else
                            currentChat.flags&= ~(1 << 5);
                        
                        if(newChat.isVerified)
                            currentChat.flags|= (1 << 7);
                        else
                            currentChat.flags&= ~(1 << 7);
                        
                        if(newChat.isMegagroup)
                            currentChat.flags|= (1 << 8);
                        else
                            currentChat.flags&= ~(1 << 8);
                        
                        if(newChat.isDemocracy)
                            currentChat.flags|= (1 << 10);
                        else
                            currentChat.flags&= ~(1 << 10);
                        
                        if(![currentChat.title isEqualToString:newChat.title]) {
                            isUpdated = YES;
                            currentChat.title = newChat.title;
                        }
                        
                        
                        if(![currentChat.username isEqualToString:newChat.username]) {
                            isUpdated = YES;
                            currentChat.username = newChat.username;
                        }
                        
                        
                        if([currentChat.photo.photo_small hashCacheKey] != [newChat.photo.photo_small hashCacheKey]) {
                            isUpdated = YES;
                            currentChat.photo = newChat.photo;
                            [Notification perform:CHAT_UPDATE_PHOTO data:@{KEY_CHAT: currentChat}];
                        }
                        
                    }
                    
                    if(isUpdated) {
                        [chatsToUpdate addObject:newChat];
                    }
                    
                    if(isNeedUpdateTypeNotification) {
                        [Notification perform:CHAT_FLAGS_UPDATED data:@{KEY_CHAT:currentChat}];
                        [Notification perform:CHAT_UPDATE_TYPE data:@{KEY_CHAT:currentChat}];
                    }
                    
                    
                } else {
                    [self->list addObject:newChat];
                    [self->keys setObject:newChat forKey:[newChat valueForKey:key]];
                    
                    [chatsToUpdate addObject:newChat];
                    
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
                
                [chatsToUpdate addObject:newChat];
            }
            
            if(dispose)
                break;
        }

        if(chatsToUpdate.count)
            [subscriber putNext:chatsToUpdate];
        
        
        return [[SBlockDisposable alloc] initWithBlock:^
                {
                    dispose = YES;
                }];
    }] startOn:self.queue];
    
    
    if(autoStart)
        [signal startWithNext:^(id next) {
            
        }];
    
    
    return signal;

    
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


+(TLChat *)findChatByName:(NSString *)userName {
    if([userName hasPrefix:@"@"])
        userName = [userName substringFromIndex:1];
    
    NSArray *chats = [[[ChatsManager sharedManager] all] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.username.lowercaseString == %@",userName.lowercaseString]];
    
    if(chats.count == 1)
        return chats[0];
    
    return nil;
}

+(NSArray *)findChatsByName:(NSString *)userName {
    if([userName hasPrefix:@"@"])
        userName = [userName substringFromIndex:1];
    
    NSArray *chats = [[[ChatsManager sharedManager] all] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.username BEGINSWITH[c] %@",userName]];
    
    
    return chats;
}


-(void)updateChannelUserName:(NSString *)userName channel:(TL_channel *)channel completeHandler:(void (^)(TL_channel *))completeHandler errorHandler:(void (^)(NSString *))errorHandler  {
    
    [RPCRequest sendRequest:[TLAPI_channels_updateUsername createWithChannel:channel.inputPeer username:userName] successHandler:^(id request, id response) {
        
        if([response isKindOfClass:[TL_boolTrue class]]) {
            channel.username = userName;
            [[Storage manager] insertChat:channel];
            
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
