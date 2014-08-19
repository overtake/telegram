//
//  TGDialog+Extensions.m
//  TelegramTest
//
//  Created by keepcoder on 27.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TGDialog+Extensions.h"
#import "TGPeer+Extensions.h"
#import "TGEncryptedChat+Extensions.h"

@implementation TGDialog (Extensions)

-(id)inputPeer {
    id input;
    if(self.peer.chat_id != 0) {
       // if([self.peer isKindOfClass:[TL_peerSecret class]]) {
          //  TGEncryptedChat *chat = [[ChatsManager sharedManager] find:self.peer.chat_id];
        //}
        input = [TL_inputPeerChat createWithChat_id:self.peer.chat_id];
    } else {
        TGUser *user = [[UsersManager sharedManager] find:self.peer.user_id];
        input = [user inputPeer];
    }
    if(!input)
        return [TL_inputPeerEmpty create];
    return input;
}

-(void)setUnreadCount:(int)unread_count {
    self.unread_count = unread_count  < 0 ? 0 : unread_count;
    
}

-(void)addUnread {
    self.unread_count++;
}


-(void)subUnread {
    self.unread_count = self.unread_count-1 < 0 ? 0 : self.unread_count-1;
}

-(NSPredicate *)predicateForPeer {
//    int peer_id = ;
//    NSLog(@"")
//    int a = 1;
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"peer.peer_id == %d",self.peer.peer_id];
    return pred;
}






static void *kType;

- (DialogType) type {
    NSNumber *typeNumber = objc_getAssociatedObject(self, &kType);
    if(typeNumber) {
        return [typeNumber intValue];
    } else {
        DialogType type = DialogTypeUser;
        if(self.peer.chat_id) {
            if(self.peer.class == [TL_peerChat class])
                type = DialogTypeChat;
            else if(self.peer.class == [TL_peerSecret class])
                type = DialogTypeSecretChat;
            else
                type = DialogTypeBroadcast;
            

        }
        
        objc_setAssociatedObject(self, kType, [NSNumber numberWithInt:type], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return type;
    }
}



- (NSUInteger) cacheHash {
    return [[self cacheKey] hash];
}

- (NSString *)cacheKey {
    return [NSString stringWithFormat:@"%d_%d_%d", self.type, self.peer.chat_id, self.peer.user_id];
}

- (TGChat *) chat {
    if(self.peer.chat_id) {
        return [[ChatsManager sharedManager] find:self.peer.chat_id];
    }
    return nil;
}


- (TL_encryptedChat *) encryptedChat {
    return (TL_encryptedChat *)[self chat];
}

- (TGUser *) user {
    if(self.peer.user_id) {
        return  [[UsersManager sharedManager] find:self.peer.user_id];
    }
    return nil;
}
@end
