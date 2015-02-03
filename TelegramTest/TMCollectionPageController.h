//
//  TMCollectionPageController.h
//  Messenger for Telegram
//
//  Created by keepcoder on 13.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "TMPreviewItem.h"
@interface TMCollectionPageController : TMViewController
@property (nonatomic,strong) TL_conversation *conversation;


-(void)didAddMediaItem:(id<TMPreviewItem>)item;
-(void)didDeleteMediaItem:(id<TMPreviewItem>)item;

-(void)showAllMedia;
-(void)showFiles;
-(void)checkCap;
@end
