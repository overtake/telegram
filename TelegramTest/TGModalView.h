//
//  TGModalView.h
//  Telegram
//
//  Created by keepcoder on 08.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGModalView : TMView

-(void)show:(NSWindow *)window animated:(BOOL)animated;
-(void)close:(BOOL)animated;


@property (nonatomic,strong,readonly) BTRButton *ok;
@property (nonatomic,strong,readonly) BTRButton *cancel;

-(void)enableCancelAndOkButton;
-(void)okAction;
-(void)cancelAction;


-(void)modalViewDidShow;
-(void)modalViewDidHide;

@property (assign) BOOL acceptEvents;
@property (assign,nonatomic) BOOL opaqueContent;

-(void)setContainerFrameSize:(NSSize)size;
-(NSSize)containerSize;
@end
