//
//  TGImageAttachment.h
//  Telegram
//
//  Created by keepcoder on 20.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "BTRImageView.h"
#import "TGAttachObject.h"
@class TGImageAttachmentsController;

@interface TGImageAttachment : TMView

@property (nonatomic,weak) TGImageAttachmentsController *controller;

@property (nonatomic,strong,readonly) TGAttachObject *item;

-(id)initWithItem:(TGAttachObject *)attach;

-(void)setDeleteAccept:(BOOL)accept;

-(void)loadImage;

@end
