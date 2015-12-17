//
//  TGCompressItem.m
//  Telegram
//
//  Created by keepcoder on 16/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGCompressItem.h"
#import "QueueManager.h"
@implementation TGCompressItem


-(id)initWithPath:(NSString *)path conversation:(TL_conversation *)conversation {
    if(self = [super init]) {
        _path = path;
        _conversation = conversation;
        _progress = 0.0f;
        
    }
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        _path = [aDecoder decodeObjectForKey:@"path"];
        _conversation = [[DialogsManager sharedManager] find:[aDecoder decodeIntegerForKey:@"peer_id"]];
        self.size = [aDecoder decodeSizeForKey:@"size"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_path forKey:@"path"];
    [aCoder encodeInteger:_conversation.peer_id forKey:@"peer_id"];
    [aCoder encodeSize:self.size forKey:@"size"];
}


-(NSString *)mime_type {
    return @"unknown";
}

-(NSArray *)attributes {
    return @[];
}

-(void)start {
    
}

-(void)readyAndStart {
    [[QueueManager sharedManager] add:self];
}

- (void)setState:(TGCompressItemState)uploadState {
    @synchronized(self) {
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isCancelled"];
        _state = uploadState;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
        [self didChangeValueForKey:@"isCancelled"];
    }
}


- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isFinished {
    return self.state == TGCompressItemStateCompressingFail || self.state == TGCompressItemStateCompressingSuccess || self.state == TGCompressItemStateCompressingCancel;
}

- (BOOL)isExecuting {
    return self.state == TGCompressItemStateWaitingCompress;
}

- (BOOL)isCancelled {
    return self.state == TGCompressItemStateCompressingFail;
}

-(void)cancel {
    
}

@end
