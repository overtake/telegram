//
//  TMTypingObject.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/30/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMTypingObject : NSObject

- (id) initWithDialog:(TL_conversation *)dialog;
- (NSArray *) writeArray;

- (void) addMember:(NSUInteger)uid;
- (void) removeMember:(NSUInteger)uid;

@end
