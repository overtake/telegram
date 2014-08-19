//
//  TGEncryptedChat+Extensions.m
//  Telegram P-Edition
//
//  Created by keepcoder on 25.12.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TGEncryptedChat+Extensions.h"

@implementation TGEncryptedChat (Extensions)
-(TGUser *)peerUser {
    int uid = uniqueElement(self.admin_id, self.participant_id, [UsersManager currentUserId]);
    return [[UsersManager sharedManager] find:uid];
}

-(TGChatPhoto *)photo {
    return [TL_chatPhoto createWithPhoto_small:[[[self peerUser] photo] photo_small] photo_big:[[[self peerUser] photo] photo_big]];
}
-(NSString *)title {
    TGUser *user = [self peerUser];
    return [user fullName];
}


-(TGInputEncryptedChat *)inputPeer {
    return [TL_inputEncryptedChat createWithChat_id:self.n_id access_hash:self.access_hash];
}

@end
