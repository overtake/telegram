//
//  MessagesViewController.h
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/29/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MessagesTableView.h"
#import "UploadOperation.h"
#import "TMElements.h"
#import "MessagesDelegate.h"
#import "MessageInputGrowingTextView.h"
#import "ConnectionStatusViewControllerView.h"
#import <CoreLocation/CoreLocation.h>
#import "TGCTextMark.h"
@interface SearchSelectItem : NSObject
@property (nonatomic,assign) BOOL isCurrent;
@property (nonatomic,strong) MessageTableItem *item;
@property (nonatomic,strong,readonly) NSMutableArray *marks;
@end


@class MessageTableItem;

@interface MessagesViewController : TMViewController<NSTableViewDataSource, NSTableViewDelegate,NSTextFieldDelegate, NSTextViewDelegate,MessagesDelegate>


typedef enum {
    MessagesViewControllerStateNone,
    MessagesViewControllerStateEditable,
    MessagesViewControllerStateFiltred
} MessagesViewControllerState;

@property (nonatomic, strong) NSMutableArray *selectedMessages;
@property (nonatomic, strong,readonly) MessagesTableView *table;
@property (nonatomic, strong) TL_conversation *conversation;

@property (nonatomic) MessagesViewControllerState state;

@property (nonatomic,copy) dispatch_block_t didUpdatedTable;

- (void)sendTypingWithAction:(TLSendMessageAction *)action;
- (void)sendMessage;
- (void)setCellsEditButtonShow:(BOOL)show animated:(BOOL)animated;
- (void)setSelectedMessage:(MessageTableItem *)item selected:(BOOL)selected;
- (void)deleteSelectedMessages;
- (void)cancelSelectionAndScrollToBottom;
- (void)unSelectAll:(BOOL)animated;
- (void)bottomViewChangeSize:(int)height animated:(BOOL)animated;
- (void)setStringValueToTextField:(NSString *)stringValue;
- (NSString *)inputText;
- (void)drop;

//- (void)updateHeaderHeight:(BOOL)update animated:(BOOL)animated;

- (void)saveInputText;

- (void)setCurrentConversation:(TL_conversation *)dialog withJump:(int)messageId historyFilter:(Class)historyFilter;
- (void)setCurrentConversation:(TL_conversation *)dialog;

- (void)setHistoryFilter:(Class)filter force:(BOOL)force;
- (void)updateLoading;
- (MessageTableItem *)objectAtIndex:(NSUInteger)position;
- (NSUInteger)indexOfObject:(MessageTableItem *)item;
- (MessageTableItem *)itemOfMsgId:(int)msg_id;

+(NSMenu *)destructMenu:(dispatch_block_t)ttlCallback click:(dispatch_block_t)click;
+(NSMenu *)notifications:(dispatch_block_t)callback conversation:(TL_conversation *)conversation click:(dispatch_block_t)click;

- (NSUInteger)messagesCount;

- (void)clearHistory:(TL_conversation *)dialog;
- (void)leaveOrReturn:(TL_conversation *)dialog;
- (void)deleteDialog:(TL_conversation *)dialog;

- (void)deleteDialog:(TL_conversation *)dialog callback:(dispatch_block_t)callback;
- (void)deleteDialog:(TL_conversation *)dialog callback:(dispatch_block_t)callback startDeleting:(dispatch_block_t)startDeleting;

- (void)deleteItem:(MessageTableItem *)item;
- (void)resendItem:(MessageTableItem *)item;


- (void)sendImage:(NSString *)file_path file_data:(NSData *)data;
- (void)sendVideo:(NSString *)file_path;
- (void)sendDocument:(NSString *)file_path;


- (void)sendImage:(NSString *)file_path file_data:(NSData *)data addCompletionHandler:(dispatch_block_t)completeHandler;
- (void)sendVideo:(NSString *)file_path addCompletionHandler:(dispatch_block_t)completeHandler;
;
- (void)sendDocument:(NSString *)file_path addCompletionHandler:(dispatch_block_t)completeHandler;
;

-(void)sendSticker:(TLDocument *)sticker addCompletionHandler:(dispatch_block_t)completeHandler;

- (void)sendAudio:(NSString *)file_path;
- (void)sendMessage:(NSString *)message ;
- (void)sendLocation:(CLLocationCoordinate2D)coordinates;
- (void)forwardMessages:(NSArray *)messages conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback;
- (void)shareContact:(TLUser *)contact conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback;
- (void)sendSecretTTL:(int)ttl;

- (void)sendSecretTTL:(int)ttl callback:(dispatch_block_t)callback;

- (NSArray *)messageTableItemsFromMessages:(NSArray *)input;

- (void)hideTopInfoView:(BOOL)animated;
- (void)showTopInfoView:(BOOL)animated;

//- (void)showConnectionController:(BOOL)animated;
//- (void)hideConnectionController:(BOOL)animated;

-(void)showSearchBox;


-(NSArray *)messageList;


-(void)reloadData;
@end
