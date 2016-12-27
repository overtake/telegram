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
@interface TGPhotoViewer : NSWindow

typedef enum {
    TGPhotoViewerMinStyle,
    TGPhotoViewerFullStyle
} TGPhotoViewerStyle;


@property (nonatomic,strong,readonly) TGPVContainer *photoContainer;
@property (nonatomic,strong,readonly) TGPVControls *controls;

@property (nonatomic,assign,readonly) TGPhotoViewerStyle viewerStyle;


@property (nonatomic,weak) TelegramWindow *invokeWindow;

-(void)show:(PreviewObject *)item conversation:(TL_conversation *)conversation;
-(void)show:(PreviewObject *)item conversation:(TL_conversation *)conversation isReversed:(BOOL)isReversed;
-(void)show:(PreviewObject *)item user:(TLUser *)user;
-(void)show:(PreviewObject *)item;
-(void)showDocuments:(PreviewObject *)item conversation:(TL_conversation *)conversation;

-(void)showChatPhotos:(PreviewObject *)item chat:(TLChat *)chat;

-(void)prepareUser:(TLUser *)user;


+(id<TGPVBehavior>)behavior;

-(void)hide;

+(TGPhotoViewer *)viewer;

+(TGPhotoViewerItem *)currentItem;

+(void)deleteItem:(TGPhotoViewerItem *)item;

+(void)nextItem;
+(void)prevItem;

+(BOOL)isVisibility;

+(void)copyClipboard;

+(void)increaseZoom;
+(void)decreaseZoom;
@end
