//
//  TMPreviewController.h
//  Messenger for Telegram
//
//  Created by keepcoder on 11.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMPreviewPhotoItem.h"
#import "PreviewObject.h"
@interface TMMediaController : NSObject<QLPreviewPanelDataSource,QLPreviewPanelDelegate>
{
    @public NSMutableArray *items;
}

@property (nonatomic, assign) int currentItemPosition;
@property (nonatomic, strong) QLPreviewPanel *panel;
@property (nonatomic, strong) NSView *previewView;

-(BOOL)isOpened;

+(TMMediaController *)controller;

+(void)setCurrentController:(TMMediaController *)controller;
+(TMMediaController *)getCurrentController;

-(void)saveItem:(id<TMPreviewItem>)item;
- (NSUInteger)count;
-(NSMutableArray *)media:(int)hash;
-(void)show:(id<TMPreviewItem>)showItem;
-(void)close;
-(void)prepare:(id)object completionHandler:(dispatch_block_t)completionHandler;
-(void)refreshCurrentPreviewItem;
-(void)addItem:(NSString *)path;
-(void)removeAllObjects;
-(id<TMPreviewItem>)currentItem;
-(void)nextItem;
-(void)prevItem;
- (void)deleteItem:(id<TMPreviewItem>)item;
-(void)reloadData:(NSInteger)currentIndex;
-(id<TMPreviewItem>)convert:(PreviewObject *)from;
-(BOOL)isExist:(id<TMPreviewItem>)item in:(NSArray *)list;

- (BOOL)remoteLoad:(TL_conversation *)conversation completionHandler:(void (^)(NSArray *items))completionHandler;
@end
