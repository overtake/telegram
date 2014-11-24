//
//  TLEncryptedChat+Extensions.m
//  Telegram P-Edition
//
//  Created by keepcoder on 25.12.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TLEncryptedChat+Extensions.h"

@implementation TLEncryptedChat (Extensions)
-(TLUser *)peerUser {
    int uid = uniqueElement(self.admin_id, self.participant_id, [UsersManager currentUserId]);
    return [[UsersManager sharedManager] find:uid];
}

-(TLChatPhoto *)photo {
    return [TL_chatPhoto createWithPhoto_small:[[[self peerUser] photo] photo_small] photo_big:[[[self peerUser] photo] photo_big]];
}
-(NSString *)title {
    TLUser *user = [self peerUser];
    return [user fullName];
}


-(TLInputEncryptedChat *)inputPeer {
    return [TL_inputEncryptedChat createWithChat_id:self.n_id access_hash:self.access_hash];
}

@end
