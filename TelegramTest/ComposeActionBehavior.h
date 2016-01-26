//
//  ComposeActionObserver.h
//  Telegram
//
//  Created by keepcoder on 28.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ComposeBehaviorDelegate <NSObject>

-(void)behaviorDidStartRequest;

-(void)behaviorDidEndRequest:(id)response;

@end

@class ComposeAction;

@interface ComposeActionBehavior : NSObject

@property (nonatomic,strong,readonly) ComposeAction *action;

@property (nonatomic,strong) id <ComposeBehaviorDelegate> delegate;

-(void)composeDidChangeSelected;
-(void)composeDidCancel;
-(void)composeDidDone;

-(NSUInteger)limit;

-(id)initWithAction:(ComposeAction *)action;


-(NSString *)doneTitle;

-(NSAttributedString *)centerTitle;

-(NSString *)leftEditTitle;
-(NSString *)rightEditTitle;

@end
