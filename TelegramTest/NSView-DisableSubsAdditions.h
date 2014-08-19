//
//  NSView-DisableSubsAdditions.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/4/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSView (DisableSubsAdditions)

- (void)disableSubViews;
- (void)enableSubViews;

@end
