//
//  PhotoCollectionImageView.h
//  Telegram
//
//  Created by keepcoder on 05.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGImageView.h"
#import "PhotoCollectionImageObject.h"


@class TMCollectionPageController;

@interface PhotoCollectionImageView : TGImageView

@property (nonatomic,weak) TMCollectionPageController *controller;


@end
