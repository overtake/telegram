//
//  TGSplitView.h
//  TelegramModern
//
//  Created by keepcoder on 24.06.15.
//  Copyright (c) 2015 telegram. All rights reserved.
//

#import "TGView.h"
#import "TGViewController.h"


struct TGSplitProportion
{
    int min;
    int max;
};

typedef enum {
    TGSplitViewStateSingleLayout,
    TGSplitViewStateDualLayout,
    TGSplitViewStateTripleLayout
} TGSplitViewState;

@protocol TGSplitViewDelegate <NSObject>

-(void)splitViewDidNeedResizeController:(NSRect)rect;

@end

@protocol TGSplitControllerDelegate <NSObject>

-(void)splitViewDidNeedSwapToLayout:(TGSplitViewState)state;
-(void)splitViewDidNeedMinimisize:(TGViewController *)controller;
-(void)splitViewDidNeedFullsize:(TGViewController *)controller;
-(BOOL)splitViewIsMinimisize:(TGViewController *)controller;
@end



@interface TGSplitView : TGView

@property (nonatomic,assign,readonly) TGSplitViewState state;
@property (nonatomic,assign) BOOL canChangeState;
@property (nonatomic,weak) id <TGSplitControllerDelegate> delegate;



-(void)addController:(TGViewController<TGSplitViewDelegate> *)controller proportion:( struct TGSplitProportion )proportion;
-(void)removeController:(TGViewController<TGSplitViewDelegate> *)controller;
-(void)removeAllControllers;

-(void)setProportion:(struct TGSplitProportion)proportion forState:(TGSplitViewState)state;

-(void)updateStartSize:(NSSize)size forController:(TGViewController<TGSplitViewDelegate> *)controller;


-(void)update;

@end
