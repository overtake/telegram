//
//  NSArrayCategory.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Reverse)
-(NSArray *)findElementsWithRecursion:(NSString *)q;
@end

@interface NSMutableArray (Reverse)
@end