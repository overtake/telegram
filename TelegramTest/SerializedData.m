//
//  SerializedData.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/25/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "SerializedData.h"

#import <MTProtoKit/MTLogging.h>

@implementation SerializedData

@synthesize input;
@synthesize ouput;

- (id) init {
    self = [super init];
    if(self) {
        
    }
    return self;
}

- (void)writeInt:(int) num {
    @try {
        uint8_t buffer[4];
        memcpy(buffer, &num, 4);
        
        
        [self.ouput write:buffer maxLength:4];
    } @catch(NSException *exception) {
        MTLog(@"Write int exception");
    }
}

- (int)readInt {
    uint8_t buffer[4];
    NSInteger len = [self.input read:buffer maxLength:4];
    if(len > 0) {
        int intValue;
        memcpy(&intValue, buffer, 4);
        return intValue;
    } else {
        MTLog(@"Read int buffer length = 0");
        return 0;
    }
}


- (void)writeLong:(long) num {
    @try {
        uint8_t buffer[8];
        memcpy(buffer, &num, 8);
        [self.ouput write:buffer maxLength:8];
    } @catch(NSException *exception) {
        MTLog(@"Write int exception");
    }
}

-(long)readLong {
    uint8_t buffer[8];
    NSInteger len = [self.input read:buffer maxLength:8];
    if(len > 0) {
        long longValue;
        memcpy(&longValue, buffer, 8);
        return longValue;
    } else {
        MTLog(@"Read dobule buffer length = 0");
        return 0;
    }
}

- (void)writeDouble:(double)value {
    @try {
        uint8_t buffer[8];
        memcpy(buffer, &value, 8);
        [self.ouput write:buffer maxLength:8];
    } @catch(NSException *exception) {
        MTLog(@"Write int exception");
    }
}

- (double)readDouble {
    uint8_t buffer[8];
    NSInteger len = [self.input read:buffer maxLength:8];
    if(len > 0) {
        double doubleValue;
        memcpy(&doubleValue, buffer, 8);
        return doubleValue;
    } else {
        MTLog(@"Read dobule buffer length = 0");
        return 0;
    }
}

- (void)writeBool:(BOOL)value {
    if (value) {
        [self writeInt:0x997275b5];
    } else {
        [self writeInt:0xbc799737];
    }
}

- (BOOL)readBool {
    int consructor = [self readInt];
    if (consructor == 0x997275b5) {
        return YES;
    } else if (consructor == 0xbc799737) {
        return NO;
    }
    MTLog(@"Not bool");
    return NO;
}

- (void)writeData:(NSData*)data {
    @try {
        [self.ouput write:[data bytes] maxLength:[data length]];
    } @catch(NSException *exception) {
        MTLog(@"Write data exception");
    }
}

- (NSData*)readData:(int)count {
    @try {
        uint8_t *buf = malloc(count);
        NSInteger len = [self.input read:buf maxLength:count];
        if(len > 0) {
            
            return [[NSData alloc] initWithBytesNoCopy:buf length:count freeWhenDone:true];
        } else {
            MTLog(@"Read data length = 0");
        }
    } @catch(NSException *exception) {
        MTLog(@"Read data exception");
    }
}

- (NSData*)readByteArray {
    uint8_t buf;
    int length = 0;
    
    if([self.input read:&buf maxLength:1] < 1) {
        MTLog(@"readByteArray read error #1");
        return 0;
    }
    
    length |= buf;
    int sl = 1;
    if(length >= 254) {
        length = 0;
        
        uint8_t buff[3];
        NSInteger len = [self.input read:buff maxLength:3];
        if(len > 0) {
            memcpy(&length, buff, 3);
        } else {
            MTLog(@"Read length buffer length = %ld", (long)len);
            return 0;
        }
        sl = 4;
    }
    
    uint8_t *buff = malloc(length);
    if(length)
        [self.input read:buff maxLength:length];
  
    NSData *bytes = [[NSData alloc] initWithBytesNoCopy:buff length:length freeWhenDone:true];
    
    int i=sl;
    
    while((length + i) % 4 != 0) {
        uint8_t length;
        if([self.input read:&length maxLength:1] < 1) {
            MTLog(@"readByteArray read error #4");
        }
        i++;
    }
    return bytes;
}

- (NSString*)readString {
    NSData *data = [self readByteArray];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

- (void)writeByteArray:(NSData*)data {
    NSInteger length = [data length];
    if(length <= 253) {
        uint8_t len = length;
        [self.ouput write:&len maxLength:1];
    } else {
        uint8_t len = 254;
        [self.ouput write:&len maxLength:1];
        
        uint8_t buff[3];
        int lengthInt = (int)length;
        memcpy(buff, &lengthInt, 3);
        
        [self.ouput write:buff maxLength:3];
//        len = length;
//        [self.ouput write:&len maxLength:1];
//        len = length >> 8;
//        [self.ouput write:&len maxLength:1];
//        len = length >> 16;
//        [self.ouput write:&len maxLength:1];
    }
    
    
    if(length > 0) {
        [self.ouput write:[data bytes] maxLength:[data length]];
    }
    
    
    int i = length <= 253 ? 1 : 4;
    while((length + i) % 4 != 0){
        uint8_t n = 0;
        [self.ouput write:&n maxLength:1];
        i++;
    }
}

- (void)writeString:(NSString*)string {
    [self writeByteArray:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSData*)getOutput {
    [ouput close];
    return  [ouput propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
}

@end
