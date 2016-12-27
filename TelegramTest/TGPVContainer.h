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

@protocol TGPVContainerDelegate <NSObject>

-(NSRect)requestShowRect:(TGPhotoViewerItem *)item;

@end

@interface TGPVContainer : TMView


@property (nonatomic,strong,readonly) TGPhotoViewerItem *currentViewerItem;

@property (nonatomic,strong) TL_conversation *conversation;


@property (assign) id <TGPVContainerDelegate> delegate;

-(void)setCurrentViewerItem:(TGPhotoViewerItem *)currentViewerItem animated:(BOOL)animated;

-(BOOL)ifVideoFullScreenPlayingNeedToogle;

-(BOOL)isInImageContainer:(NSEvent *)event;
-(void)increaseZoom;
-(void)decreaseZoom;

-(void)updateSize;

-(void)copy:(id)sender;

@end
