//
//  ChatsManager.h
//  TelegramTest
//
//  Created by keepcoder on 31.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "SharedManager.h"

@interface ChatsManager : SharedManager
- (NSArray *)secretChats;
-(void)acceptEncryption:(TL_encryptedChatRequested *)request;


+(TLChat *)findChatByName:(NSString *)userName;
+(NSArray *)findChatsByName:(NSString *)userName;
-(void)updateChannelUserName:(NSString *)userName channel:(TL_channel *)channel completeHandler:(void (^)(TL_channel *))completeHandler errorHandler:(void (^)(NSString *))errorHandler;


@end
