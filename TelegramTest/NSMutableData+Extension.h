//
//  NSMutableData+Extension.h
//  TelegramTest
//
//  Created by keepcoder on 06.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableData (Extension)
-(id)initWithRandomBytes:(int)length;
-(void)addRandomBytes:(int)length;
-(NSMutableData *)addPadding:(int)bits;
@end
