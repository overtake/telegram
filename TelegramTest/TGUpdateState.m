//
//  TGUpdateState.m
//  Messenger for Telegram
//
//  Created by keepcoder on 28.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGUpdateState.h"

@implementation TGUpdateState

-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        _pts = [aDecoder decodeIntForKey:@"pts"];
        _qts = [aDecoder decodeIntForKey:@"qts"];
        _date = [aDecoder decodeIntForKey:@"date"];
        _seq = [aDecoder decodeIntForKey:@"seq"];
        _pts_count = [aDecoder decodeIntForKey:@"pts_count"];
    }
    return self;
}


-(void)setPts:(int)pts {
    if(_pts < pts || !_checkMinimum)
        _pts = pts;
}

-(void)setSeq:(int)seq {
    if(_seq < seq || !_checkMinimum)
        _seq = seq;
}

-(void)setQts:(int)qts {
    if(_qts < qts || !_checkMinimum)
        _qts = qts;
}

-(void)setDate:(int)date {
    if(_date < date || !_checkMinimum)
        _date = date;
}

-(void)setPts_count:(int)pts_count {
    if(_pts_count < pts_count || !_checkMinimum)
        _pts_count = pts_count;
}

-(id)initWithPts:(int)pts qts:(int)qts date:(int)date seq:(int)seq pts_count:(int)pts_count {
    
    if(self = [super init]) {
        _pts = pts;
        _qts = qts;
        _date = date;
        _seq = seq;
        
        self.checkMinimum = YES;
    }
    
    return self;
    
}

-(NSString *)description {
    return [NSString stringWithFormat:@"pts:%d, qts:%d, seq:%d, date:%d",self.pts,self.qts,self.seq,self.date];
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.pts forKey:@"pts"];
    [aCoder encodeInt:self.qts forKey:@"qts"];
    [aCoder encodeInt:self.date forKey:@"date"];
    [aCoder encodeInt:self.seq forKey:@"seq"];
    [aCoder encodeInt:self.pts_count forKey:@"pts_count"];
}

@end
