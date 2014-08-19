//
//  TGEncryptedChatCategory.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGEncryptedChat (Category)

- (EncryptedParams *)encryptedParams;
- (TL_conversation *)dialog;
@end
