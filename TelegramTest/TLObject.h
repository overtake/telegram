//
//  TLObject.h
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/25/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerializedData.h"

@interface TLObject : NSObject

- (void)serialize:(SerializedData *)stream;
- (void)unserialize:(SerializedData *)stream;
@end
