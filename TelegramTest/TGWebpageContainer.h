//
//  TGWebpageContainer.h
//  Telegram
//
//  Created by keepcoder on 01.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGWebPageObject.h"
#import "TMLoaderView.h"
#import "TGImageView.h"
#import "MessageTableItem.h"
#import "TGCTextView.h"
@interface TGWebpageContainer : TMView

@property (nonatomic,strong,readonly) TMLoaderView *loaderView;
@property (nonatomic,strong,readonly) TGImageView *imageView;

@property (nonatomic,strong) TMTextField *author;
@property (nonatomic,strong) TMTextField *date;

@property (nonatomic,strong) TMTextField *siteName;

@property (nonatomic,strong) TGCTextView *descriptionField;

@property (nonatomic,weak) TGWebpageObject *webpage;
@property (nonatomic,weak) MessageTableItem *item;

-(void)updateState:(TMLoaderViewState)state;

-(NSSize)containerSize;
-(int)maxTextWidth;
-(int)textX;

-(void)showPhoto;

-(int)textY;


@end
