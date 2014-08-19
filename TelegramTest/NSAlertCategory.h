//
//  NSAlertCategory.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/5/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAlert (Category)
+ (NSAlert *)alertWithMessageText:(NSString *)message informativeText:(NSString *)informativeText block:(void (^)(id))block;
- (void)show;
@end
