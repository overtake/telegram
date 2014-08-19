//
//  EncryptedKeyWindow.h
//  Messenger for Telegram
//
//  Created by keepcoder on 08.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EncryptedKeyWindow : NSPanel<TMHyperlinkTextFieldDelegate>


+ (void)showForChat:(TL_encryptedChat *)chat;

@end
