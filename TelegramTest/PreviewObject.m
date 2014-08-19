//
//  PreviewObject.m
//  Messenger for Telegram
//
//  Created by keepcoder on 10.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PreviewObject.h"

@implementation PreviewObject

@synthesize msg_id = _msg_id;
@synthesize media = _media;
@synthesize peerId = _peerId;

-(id)initWithMsdId:(int)msg_id media:(id)media peer_id:(int)peer_id {
    if(self = [super init]) {
        _msg_id = msg_id;
        _media = media;
        _peerId = peer_id;
    }
    
    return self;
}

@end
