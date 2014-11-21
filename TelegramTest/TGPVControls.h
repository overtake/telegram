//
//  TGPVControls.h
//  Telegram
//
//  Created by keepcoder on 11.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGPVControls : TMView

@property (nonatomic,strong) TL_conversation *convertsation;
-(void)update;
-(void)setCurrentPosition:(NSUInteger)position ofCount:(NSUInteger)count;


typedef enum  {
    TGPVControlHighLightPrev,
    TGPVControlHighLightNext,
    TGPVControlHighLightClose
} TGPVControlHighlightType;

-(void)highlightControl:(TGPVControlHighlightType)type;

@end
