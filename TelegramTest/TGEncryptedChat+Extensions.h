//
//  TGEncryptedChat+Extensions.h
//  Telegram P-Edition
//
//  Created by keepcoder on 25.12.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TLRPC.h"

@interface TGEncryptedChat (Extensions)
-(TGUser *)peerUser;
-(NSString *)title;
-(TGChatPhoto *)photo;
-(TGInputEncryptedChat *)inputPeer;
@end
