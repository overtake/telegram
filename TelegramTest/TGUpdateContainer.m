//
//  TGUpdateContainer.m
//  Messenger for Telegram
//
//  Created by keepcoder on 28.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGUpdateContainer.h"

@implementation TGUpdateContainer

-(id)initWithSequence:(int)seq pts:(int)pts date:(int)date qts:(int)qts pts_count:(int)pts_count update:(id)update {
    if(self = [super init]) {
        self.beginSeq = seq;
        self.pts = pts;
        self.date = date;
        self.qts = qts;
        self.pts_count = pts_count;
        self.update = update;
    }
    return self;
}

-(BOOL)isEmpty {
    return self.beginSeq == 0 && self.pts == 0 && self.qts == 0 && self.pts_count == 0;
}

@end
