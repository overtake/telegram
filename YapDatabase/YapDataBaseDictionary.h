//
//  YapDataBaseDictionary.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/5/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(OLDKEYS)

+ (id)sharedKeySetForKeysNew:(NSArray *)keys;

@end

@interface NSMutableDictionary(OLDKEYS)

+ (id)dictionaryWithSharedKeySetNew:(id)keyset;

@end
