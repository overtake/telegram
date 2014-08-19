//
//  TGDialog+Extensions.h
//  TelegramTest
//
//  Created by keepcoder on 27.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TLRPC.h"

typedef enum {
    DialogTypeUser = 0,
    DialogTypeChat = 1,
    DialogTypeSecretChat = 2,
    DialogTypeBroadcast = 3
} DialogType;

@interface TGDialog (Extensions)
-(id)inputPeer;
-(void)setUnreadCount:(int)unread_count;
-(NSPredicate *)predicateForPeer;
-(void)addUnread;
-(void)subUnread;

- (TGChat *) chat;
- (TL_encryptedChat *) encryptedChat;
- (TGUser *) user;

- (NSUInteger)cacheHash;
- (NSString *)cacheKey;

- (DialogType) type;



@end
