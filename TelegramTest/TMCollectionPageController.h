//
//  TMCollectionPageController.h
//  Messenger for Telegram
//
//  Created by keepcoder on 13.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "TMPreviewItem.h"

@class PhotoCollectionImageObject;

@interface TMCollectionPageController : TMViewController
@property (nonatomic,strong) TL_conversation *conversation;


-(void)didAddMediaItem:(id<TMPreviewItem>)item;
-(void)didDeleteMediaItem:(id<TMPreviewItem>)item;

-(void)showAllMedia;
-(void)showFiles;
-(void)showSharedLinks;
-(void)checkCap;

-(void)setIsEditable:(BOOL)isEditable animated:(BOOL)animated;

@property (nonatomic,assign,readonly) BOOL isEditable;

- (void)setSectedMessagesCount:(NSUInteger)count enable:(BOOL)enable;

-(BOOL)isSelectedItem:(PhotoCollectionImageObject *)item;
-(void)setSelected:(BOOL)selected forItem:(PhotoCollectionImageObject *)item;

-(NSArray *)selectedItems;

@end
