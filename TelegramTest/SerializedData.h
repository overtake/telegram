//
//  SerializedData.h
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/25/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SerializedData : NSObject
@property (nonatomic, strong) NSInputStream *input;
@property (nonatomic, strong) NSOutputStream *ouput;
@property BOOL isCacheSerialize;

- (void)writeInt:(int)num;
- (void)writeLong:(long)num;
- (void)writeDouble:(double)value;
- (void)writeBool:(BOOL)value;
- (void)writeData:(NSData *)data;
- (void)writeByteArray:(NSData *)data;
- (void)writeString:(NSString *)string;

- (int)readInt;
- (long)readLong;
- (double)readDouble;
- (BOOL)readBool;
- (NSData *)readData:(int)count;
- (NSData *)readByteArray;
- (NSString *)readString;

- (NSData *)getOutput;
@end
