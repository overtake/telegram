//
//  TMTypingManager.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/30/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMTypingObject.h"

@interface TMTypingManager : NSObject
+ (TMTypingManager *) sharedManager;
- (TMTypingObject *) typeObjectForDialog:(TL_conversation *)dialog;
- (void) drop;
@end
