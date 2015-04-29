//
//  main.m
//  TGKeeper
//
//  Created by keepcoder on 18.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...
        MTLog(@"Hello, World!");
        
        if ([NSUserNotification class] && [NSUserNotificationCenter class]) {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"=))0";
            notification.informativeText = @"privet kak dela";
            
            [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
        }
        
        sleep(5);
        
    }
    return 0;
}

