//
//  ClassStore.h
//  Telegram
//
//  Created by keepcoder on 05.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SerializedData.h"
#import "TLObject.h"




@interface ClassStore : NSObject

+(NSMutableDictionary *)cs_classes;
+(NSMutableDictionary *)cs_constuctors;

+ (id)TLDeserialize:(SerializedData*)stream;
+ (void)TLSerialize:(TLObject*)obj stream:(SerializedData*)stream;

+ (id)deserialize:(NSData*)data;
+ (id)constructObject:(NSInputStream *)is;

+ (NSData*)serialize:(TLObject*)obj;
+ (NSData*)serialize:(TLObject*)obj isCacheSerialize:(bool)isCacheSerialize;

+ (SerializedData*)streamWithConstuctor:(int)constructor;
@end
