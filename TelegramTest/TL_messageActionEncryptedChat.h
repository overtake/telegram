//
//  TL_messageActionEncryptedChatCreated.h
//  Telegram P-Edition
//
//  Created by keepcoder on 25.01.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface TL_messageActionEncryptedChat : TLMessageAction
+(TL_messageActionEncryptedChat*)createWithTitle:(NSString*)title;
@end