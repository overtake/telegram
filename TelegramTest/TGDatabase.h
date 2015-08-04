//
//  TGDatabase.h
//  Telegram
//
//  Created by keepcoder on 04.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@interface TGDatabase : NSObject


+(SSignal *)requestMessagesWith:(int)date limit:(int)limit;

@end
