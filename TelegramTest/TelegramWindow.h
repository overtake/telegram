//
//  TelegramWindow.h
//  TelegramTest
//
//  Created by keepcoder on 02.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GRCustomizableWindow.h"
#import "TGWindowArchiver.h"
@interface TelegramWindow : NSWindow<NSWindowDelegate>
@property (nonatomic, strong) TMViewController *rootViewController;
@property (nonatomic,strong) TGWindowArchiver *autoSaver;
- (void)realClose;
- (void)initialize;
- (void)initialize:(TGWindowArchiver *)archiver;

@property (nonatomic,assign,getter = isAcceptEvents) BOOL acceptEvents;
@end
