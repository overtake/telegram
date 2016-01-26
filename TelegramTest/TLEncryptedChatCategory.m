//
//  TLEncryptedChatCategory.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLEncryptedChatCategory.h"

@implementation TLEncryptedChat (Category)

- (EncryptedParams *)encryptedParams {
    return [EncryptedParams findAndCreate:self.n_id];
}

- (TL_conversation *)dialog {
    return [[DialogsManager sharedManager] find:self.n_id];
}

-(NSString *)username {
    return @"";
}

@end
