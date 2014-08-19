//
//  TLObject.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/25/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TLObject.h"

@implementation TLObject

- (void)serialize:(SerializedData *)stream {
    DLog(@"");
    [NSException raise:@"Error" format:@"Not implemented"];
}

- (void)unserialize:(SerializedData *)stream {
    DLog(@"");
    [NSException raise:@"Error" format:@"Not implemented"];
}
@end
