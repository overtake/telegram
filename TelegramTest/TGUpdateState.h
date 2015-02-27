//
//  TGUpdateState.h
//  Messenger for Telegram
//
//  Created by keepcoder on 28.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGUpdateState : NSObject<NSCoding>
@property (nonatomic,assign) int pts;
@property (nonatomic,assign) int qts;
@property (nonatomic,assign) int date;
@property (nonatomic,assign) int seq;
@property (nonatomic,assign) int pts_count;

@property (nonatomic,assign) BOOL checkMinimum;

-(id)initWithPts:(int)pts qts:(int)qts date:(int)date seq:(int)seq pts_count:(int)pts_count;
@end
