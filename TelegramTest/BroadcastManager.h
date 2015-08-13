//
//  BroadcastManager.h
//  Telegram
//
//  Created by keepcoder on 06.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SharedManager.h"
#import "TL_broadcast.h"

@interface BroadcastMemberChecker : NSObject
- (void) reloadParticipants;
@end;

@interface BroadcastManager : SharedManager

- (BroadcastMemberChecker *)broadcastMembersCheckerById:(int)broadcastId;


@end
