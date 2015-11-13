//
//  TGPhotoViewer.h
//  Telegram
//
//  Created by keepcoder on 10.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TGPVContainer.h"
#import "TGPhotoViewerItem.h"
#import "TGPVBehavior.h"
#import "TGPVControls.h"
@interface TGPhotoViewer : NSPanel


@property (nonatomic,strong,readonly) TGPVContainer *photoContainer;
@property (nonatomic,strong,readonly) TGPVControls *controls;


@property (nonatomic,weak) TelegramWindow *invokeWindow;

-(void)show:(PreviewObject *)item conversation:(TL_conversation *)conversation;
-(void)show:(PreviewObject *)item conversation:(TL_conversation *)conversation isReversed:(BOOL)isReversed;
-(void)show:(PreviewObject *)item user:(TLUser *)user;
-(void)show:(PreviewObject *)item;
-(void)showDocuments:(PreviewObject *)item conversation:(TL_conversation *)conversation;
-(void)prepareUser:(TLUser *)user;


+(id<TGPVBehavior>)behavior;

-(void)hide;

+(TGPhotoViewer *)viewer;

+(TGPhotoViewerItem *)currentItem;

+(void)deleteItem:(TGPhotoViewerItem *)item;

+(void)nextItem;
+(void)prevItem;

+(BOOL)isVisibility;


+(void)increaseZoom;
+(void)decreaseZoom;
@end
