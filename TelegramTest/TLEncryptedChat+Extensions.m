//
//  TLEncryptedChat+Extensions.m
//  Telegram P-Edition
//
//  Created by keepcoder on 25.12.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TLEncryptedChat+Extensions.h"
#import "TLEncryptedChatCategory.h"
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

- (NSAttributedString *)statusForSearchTableView {
    NSMutableAttributedString *str;
    if(!str) {
        str = [[NSMutableAttributedString alloc] init];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
        [str setSelectionColor:NSColorFromRGB(0xfffffe) forColor:DARK_BLACK];
        [str setSelectionColor:NSColorFromRGB(0xffffff) forColor:GRAY_TEXT_COLOR];
        
        EncryptedParams *params = self.encryptedParams;
        
        TL_conversation *conversation = self.dialog;
        
        if(params.state == EncryptedDiscarted) {
            
            [str appendString:NSLocalizedString(@"MessageAction.Secret.CancelledSecretChat",nil) withColor:GRAY_TEXT_COLOR];
            
            [str endEditing];
            return str;
        } else if(params.state == EncryptedWaitOnline) {
            
            [str appendString:[NSString stringWithFormat:NSLocalizedString(@"MessageAction.Secret.WaitingToGetOnline",nil), conversation.encryptedChat.peerUser.first_name] withColor:GRAY_TEXT_COLOR];
            
            [str endEditing];
            return str;
        } else if(params.state == EncryptedAllowed && conversation.top_message == -1) {
            
            NSString *actionFormat = [UsersManager currentUserId] == conversation.encryptedChat.admin_id ? NSLocalizedString(@"MessageAction.Secret.UserJoined",nil) : NSLocalizedString(@"MessageAction.Secret.CreatedSecretChat",nil);
            
            [str appendString:[NSString stringWithFormat:actionFormat,conversation.encryptedChat.peerUser.first_name] withColor:GRAY_TEXT_COLOR];
            
            
            [str endEditing];
            return str;
        }
       
    }
    return str;
}

-(TLInputEncryptedChat *)inputPeer {
    return [TL_inputEncryptedChat createWithChat_id:self.n_id access_hash:self.access_hash];
}

@end
