//
//  TGSignalUtils.h
//  Telegram
//
//  Created by keepcoder on 27/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGSignalUtils : NSObject
+(SSignal *)countdownSignal:(int)count delay:(int)delay ;
@end
