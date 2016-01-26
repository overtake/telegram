//
//  PreviewObject.m
//  Messenger for Telegram
//
//  Created by keepcoder on 10.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PreviewObject.h"

@implementation PreviewObject


-(id)initWithMsdId:(long)msg_id media:(id)media peer_id:(int)peer_id {
    if(self = [super init]) {
        _msg_id = msg_id;
        _media = media;
        _peerId = peer_id;
    }
    
    return self;
}

-(int)date {
    return [self.media isKindOfClass:[TLMessage class]] ? [(TLMessage *)self.media date] : _date;
}

-(BOOL)isEqual:(PreviewObject *)object {
    return self.msg_id == object.msg_id;
}

-(BOOL)isEqualTo:(PreviewObject *)object {
    return self.msg_id == object.msg_id;
}

-(NSUInteger)hash {
    return self.msg_id;
}


@end
