//
//  TGModernConversationHistoryController.h
//  Telegram
//
//  Created by keepcoder on 24.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TGModernCHStateCache,
    TGModernCHStateLocal,
    TGModernCHStateRemote,
    TGModernCHStateFull
} TGModernCHState;


@protocol TGModernConversationHistoryControllerDelegate <NSObject>

-(void)didLoadedConversations:(NSArray *)conversations withRange:(NSRange)range;

-(int)conversationsLoadingLimit;

@end

@interface TGModernConversationHistoryController : NSObject

@property (nonatomic,assign,readonly) TGModernCHState state;
@property (atomic,assign,readonly) int offset;
@property (atomic,assign,readonly) int remoteOffset;
@property (atomic,assign,readonly) int localOffset;
@property (atomic,assign,readonly) BOOL isLoading;

-(id)initWithQueue:(ASQueue *)queue delegate:(id<TGModernConversationHistoryControllerDelegate>)deleagte;

-(void)requestNextConversation;

-(void)clear;

@end
