//
//  TelegramFirstResponder.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TelegramFirstController : NSObject

@property (nonatomic, weak) TMViewController *viewController;
@property (nonatomic, weak) TMViewController *oldViewController;


- (IBAction)backOrClose:(NSMenuItem *)sender;
- (IBAction)newMessage:(NSMenuItem *)sender;

- (BOOL)closeAllPopovers;

@end
