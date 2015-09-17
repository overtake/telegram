//
//  TGMessageHole.m
//  Telegram
//
//  Created by keepcoder on 27.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGMessageHole.h"
#import "Storage.h"
@implementation TGMessageHole

-(id)initWithUniqueId:(int)uniqueId peer_id:(int)peer_id min_id:(int)min_id max_id:(int)max_id date:(int)date count:(int)count {
    if(self = [super init]) {
        _uniqueId = uniqueId;
        _peer_id = peer_id;
        _min_id = min_id;
        _max_id = max_id;
        _date = date;
        _messagesCount = count;
    }
    
    return self;
}

-(id)initWithUniqueId:(int)uniqueId peer_id:(int)peer_id min_id:(int)min_id max_id:(int)max_id date:(int)date count:(int)count isImploded:(BOOL)isImploded;
{
    if(self = [self initWithUniqueId:uniqueId peer_id:peer_id min_id:min_id max_id:max_id date:date count:count]) {
        _isImploded = isImploded;
    }
    
    return self;
}

-(void)save {
    [[Storage manager] insertMessagesHole:self];
}

-(void)remove {
    [[Storage manager] removeHole:self];
}

-(void)setMessagesCount:(int)messagesCount {
    _messagesCount = MAX(0,messagesCount);
}

-(int)type {
    return 2;
}

@end
