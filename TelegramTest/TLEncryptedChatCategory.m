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

-(BOOL)isDeactivated {
    return NO;
}

-(TLChatType)type {
    return TLChatTypeNormal;
}

-(BOOL)isCreator {return NO;}

-(BOOL)isKicked {return NO;}

-(BOOL)isLeft {return NO;}

-(BOOL)isAdmins_enabled {return NO;}

-(BOOL)isAdmin {return NO;}

-(BOOL)isEditor {return NO;}

-(BOOL)isModerator {return NO;}

-(BOOL)isBroadcast {return NO;}

-(BOOL)isVerified {return NO;}

-(BOOL)isMegagroup {return NO;}

-(BOOL)isRestricted {return NO;}

-(BOOL)isDemocracy {return NO;}

-(BOOL)isSignatures {return NO;}

-(BOOL)isMin {return NO;}

-(BOOL)isExplicit_content {return NO;}

-(BOOL)isChannel {return NO;}

-(BOOL)left {return NO;}

@end
