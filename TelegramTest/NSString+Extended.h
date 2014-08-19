//
//  NSString+Extended.h
//  Telegram
//
//  Created by Dmitry Kondratyev on 11/18/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extended)
- (NSString *)htmlentities;
- (NSString *)trim;
- (NSString *)singleLine;
- (NSString *)URLDecode;
- (NSSize)sizeForTextFieldForWidth:(int)width;
- (NSArray *)getEmojiFromString;
@end
