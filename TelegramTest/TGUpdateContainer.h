//
//  TGUpdateContainer.h
//  Messenger for Telegram
//
//  Created by keepcoder on 28.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGUpdateContainer : NSObject
@property (nonatomic,assign) int beginSeq;
@property (nonatomic,assign) int pts;
@property (nonatomic,assign) int qts;
@property (nonatomic,assign) int date;
@property (nonatomic,assign) int pts_count;
@property (nonatomic,strong) id update;

-(id)initWithSequence:(int)seq pts:(int)pts date:(int)date qts:(int)qts pts_count:(int)pts_count update:(id)update;

-(BOOL)isEmpty;

@end
