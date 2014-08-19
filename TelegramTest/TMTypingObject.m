//
//  TMTypingObject.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/30/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTypingObject.h"

@interface TMTypingObject()
@property (nonatomic, strong) NSMutableDictionary *writeMembetsDictionary;
@property (nonatomic, strong) TL_conversation *dialog;
@end

@implementation TMTypingObject

- (id) initWithDialog:(TL_conversation *)dialog {
    self = [super init];
    if(self) {
        self.dialog = dialog;
        self.writeMembetsDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) addMember:(NSUInteger)uid {
    __block NSNumber *number = [NSNumber numberWithUnsignedInteger:uid];
    __block NSUInteger time = [[NSDate date] timeIntervalSince1970];
    
    
    BOOL needNotification = [self.writeMembetsDictionary objectForKey:number] == nil;
    [self.writeMembetsDictionary setObject:[NSNumber numberWithUnsignedInteger:time] forKey:number];
    if(needNotification)
        [self performNotification];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if([[self.writeMembetsDictionary objectForKey:number] integerValue] == time) {
            [self.writeMembetsDictionary removeObjectForKey:number];
            [self performNotification];
        }
    });
}

- (void) removeMember:(NSUInteger)uid {
    NSNumber *number = [NSNumber numberWithUnsignedInteger:uid];
    if([self.writeMembetsDictionary objectForKey:number]) {
        [self.writeMembetsDictionary removeObjectForKey:number];
        [self performNotification];
    }
}

- (void) performNotification {
    [Notification perform:[Notification notificationNameByDialog:self.dialog action:@"typing"] data:[NSDictionary dictionaryWithObjectsAndKeys:[self writeArray], @"users", nil]];
}

- (NSArray *) writeArray {
    return [self.writeMembetsDictionary keysOfEntriesPassingTest:^(id key, id obj, BOOL *stop) {
        return YES;
    }].allObjects;
}

- (void) dealloc {
    [Notification removeObserver:self];
}

@end
