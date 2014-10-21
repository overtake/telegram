//
//  MTConnection.m
//  Telegram P-Edition
//
//  Created by keepcoder on 17.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MTConnection.h"
#import "AppDelegate.h"
@implementation MTConnection

-(instancetype)initWithContext:(MTContext *)context datacenterId:(NSInteger)datacenterId {
    if(self = [super initWithContext:context datacenterId:datacenterId]) {
        self.delegate = self;
    }
    return self;
}

- (void)mtProtoNetworkAvailabilityChanged:(MTProto *)mtProto isNetworkAvailable:(bool)isNetworkAvailable {
    if(isNetworkAvailable) {
        [[Telegram sharedInstance] setAccountOnline];
    }
    if(!isNetworkAvailable) {
        [Telegram setConnectionState:ConnectingStatusTypeWaitingNetwork];
    }
}
- (void)mtProtoConnectionStateChanged:(MTProto *)mtProto isConnected:(bool)isConnected {
    
    if(isConnected) {
        [[Telegram sharedInstance] setAccountOnline];
    }
    
    [Telegram setConnectionState:isConnected ?ConnectingStatusTypeConnected : ConnectingStatusTypeConnecting];
    

}
- (void)mtProtoConnectionContextUpdateStateChanged:(MTProto *)mtProto isUpdatingConnectionContext:(bool)isUpdatingConnectionContext {

}
- (void)mtProtoServiceTasksStateChanged:(MTProto *)mtProto isPerformingServiceTasks:(bool)isPerformingServiceTasks {
    
}
@end
