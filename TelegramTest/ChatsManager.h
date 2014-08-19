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
@end
