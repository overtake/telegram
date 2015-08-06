//
//  TGPVContainer.h
//  Telegram
//
//  Created by keepcoder on 10.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGImageView.h"
#import "TGPhotoViewerItem.h"


@interface TGPVContainer : TMView


@property (nonatomic,strong,readonly) TGPhotoViewerItem *currentViewerItem;

@property (nonatomic,strong) TL_conversation *conversation;


-(void)setCurrentViewerItem:(TGPhotoViewerItem *)currentViewerItem animated:(BOOL)animated;

-(BOOL)ifVideoFullScreenPlayingNeedToogle;

-(BOOL)isInImageContainer:(NSEvent *)event;
-(void)increaseZoom;
-(void)decreaseZoom;
@end
