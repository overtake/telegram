//
//  TGImageAttachmentsController.h
//  Telegram
//
//  Created by keepcoder on 20.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGImageAttachment.h"


@protocol TGImageAttachmentsControllerDelegate <NSObject>

-(void)didChangeAttachmentsCount:(int)futureCount;

@end

@interface TGImageAttachmentsController : TMView


@property (nonatomic,weak) id<TGImageAttachmentsControllerDelegate> delegate;

@property (nonatomic,assign,readonly) BOOL isShown;

-(void)hide:(BOOL)animated deleteItems:(BOOL)deleteItems;
-(void)show:(TL_conversation *)conversation animated:(BOOL)animated;

-(void)addItems:(NSArray *)items animated:(BOOL)animated;

-(void)removeItem:(TGImageAttachment *)attachment animated:(BOOL)animated;

-(NSArray *)attachments;


@end
