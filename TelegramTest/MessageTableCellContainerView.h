//
//  MessageTableCellContainerView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCell.h"
#import "SenderHeader.h"
#import "TMCircularProgress.h"

typedef enum {
    CellStateNormal = 2,
    CellStateSending = 4,
    CellStateCancelled = 8,
    CellStateDownloading = 16,
    CellStateNeedDownload = 32
} CellState;

typedef enum {
    MessageTableCellUnread,
    MessageTableCellRead,
    MessageTableCellSending,
    MessageTableCellSendingError
} MessageTableCellState;

@interface MessageTableCellContainerView : MessageTableCell<SenderListener>

@property (nonatomic, assign) CellState cellState;
@property (nonatomic) MessageTableCellState actionState;
@property (nonatomic, strong) TMView *containerView;

@property (nonatomic, strong) TMCircularProgress *progressView;

- (void)cancelDownload;
- (void)deleteAndCancel:(MessageTableItem *)item;
- (void)deleteAndCancel;
- (void)doAfterDownload;
- (void)startDownload:(BOOL)cancel downloadItemClass:(Class)itemClass;
- (void)updateCellState;
//- (void)checkStartDownload:(SettingsMask)setting size:(int)size downloadItemClass:(Class)itemClass;
- (void)setProgressFrameSize:(NSSize)newsize;
-(void)updateDownloadState;
- (BOOL)canEdit;

- (void)uploadProgressHandler:(SenderItem *)item animated:(BOOL)animation;
- (void)downloadProgressHandler:(DownloadItem *)item;

- (void)searchSelection;
- (void)stopSearchSelection;


- (void)setSelected:(BOOL)selected animation:(BOOL)animation;
- (void)setEditable:(BOOL)editable animation:(BOOL)animation;

- (void)setProgressToView:(NSView *)view;
- (void)setProgressContainerVisibility:(BOOL)visibility;
- (void)setProgressStyle:(TMCircularProgressStyle)style;


- (void)checkActionState:(BOOL)redraw;

@end
