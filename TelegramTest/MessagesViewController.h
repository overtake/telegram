//
//  MessagesViewController.h
//  TelegramTest
//
//  Created by keepcoder on 10/29/13.
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
#import "TGMessagesHintView.h"
#import "TGCompressItem.h"
#import "TGInputMessageTemplate.h"
@class MessagesBottomView;

@interface SearchSelectItem : NSObject
@property (nonatomic,assign) BOOL isCurrent;
@property (nonatomic,weak) MessageTableItem *item;
@property (nonatomic,strong,readonly) NSMutableArray *marks;
@end


@class MessageTableItem;

@interface MessagesViewController : TMViewController<NSTableViewDataSource, NSTableViewDelegate,NSTextFieldDelegate, NSTextViewDelegate,MessagesDelegate>


typedef enum {
    MessagesViewControllerStateNone,
    MessagesViewControllerStateEditable,
    MessagesViewControllerStateFiltred,
    MessagesViewControllerStateEditMessage
} MessagesViewControllerState;

@property (nonatomic, strong) NSMutableArray *selectedMessages;
@property (nonatomic, strong,readonly) MessagesTableView *table;
@property (nonatomic, strong) MessagesBottomView *bottomView;
@property (nonatomic,strong,readonly) TGInputMessageTemplate * editTemplate;


typedef enum {
    ShowMessageTypeReply = 1 << 0,
    ShowMessageTypeSearch = 1 << 1,
    ShowMessageTypeUnreadMark = 1 << 2,
    ShowMessageTypeDateJump = 1 << 3,
    ShowMessageTypeSaveScrolled = 1 << 4
} ShowMessageType;


-(void)setConversation:(TL_conversation *)conversation;
-(TL_conversation *)conversation;

@property (nonatomic) MessagesViewControllerState state;

@property (nonatomic,copy) dispatch_block_t didUpdatedTable;

- (void)sendTypingWithAction:(TLSendMessageAction *)action;
- (void)sendMessage;
- (void)setCellsEditButtonShow:(BOOL)show animated:(BOOL)animated;
- (void)setSelectedMessage:(MessageTableItem *)item selected:(BOOL)selected;
- (void)deleteSelectedMessages;
- (void) deleteSelectedMessages:(dispatch_block_t)deleteAcceptBlock;
- (void)cancelSelectionAndScrollToBottom:(BOOL)scrollToBottom;
- (void)unSelectAll:(BOOL)animated;
- (void)bottomViewChangeSize:(int)height animated:(BOOL)animated;
- (void)setStringValueToTextField:(NSString *)stringValue;
- (NSString *)inputText;

- (void)showForwardMessagesModalView;

- (void)drop;

//- (void)updateHeaderHeight:(BOOL)update animated:(BOOL)animated;
- (void)jumpToLastMessages:(BOOL)force;
- (void)saveInputText;

- (void)setCurrentConversation:(TL_conversation *)dialog withMessageJump:(TL_localMessage *)message;
- (void)setCurrentConversation:(TL_conversation *)dialog withMessageJump:(TL_localMessage *)message force:(BOOL)force;
- (void)setCurrentConversation:(TL_conversation *)dialog;



- (void)showMessage:(TL_localMessage *)message fromMsg:(TL_localMessage *)fromMsg flags:(int)flags;
- (void)showMessage:(TL_localMessage *)message fromMsg:(TL_localMessage *)fromMsg switchDiscussion:(BOOL)switchDiscussion;
- (void)showMessage:(TL_localMessage *)message fromMsg:(TL_localMessage *)fromMsg animated:(BOOL)animated selectText:(NSString *)text switchDiscussion:(BOOL)switchDiscussion flags:(int)flags;

- (void)setHistoryFilter:(Class)filter force:(BOOL)force;
- (void)updateLoading;
- (MessageTableItem *)objectAtIndex:(NSUInteger)position;
- (NSUInteger)indexOfObject:(MessageTableItem *)item;
- (MessageTableItem *)itemOfMsgId:(long)msg_id randomId:(long)randomId;

+(NSMenu *)destructMenu:(dispatch_block_t)ttlCallback click:(dispatch_block_t)click;
+(NSMenu *)notifications:(dispatch_block_t)callback conversation:(TL_conversation *)conversation click:(dispatch_block_t)click;

+(BOOL)canDeleteMessages:(NSArray *)messages inConversation:(TL_conversation *)conversation;

- (NSUInteger)messagesCount;

- (void)clearHistory:(TL_conversation *)dialog;
- (void)leaveOrReturn:(TL_conversation *)dialog;
- (void)deleteDialog:(TL_conversation *)dialog;

- (void)deleteDialog:(TL_conversation *)dialog callback:(dispatch_block_t)callback;
- (void)deleteDialog:(TL_conversation *)dialog callback:(dispatch_block_t)callback startDeleting:(dispatch_block_t)startDeleting;

- (void)deleteItem:(MessageTableItem *)item;
- (void)resendItem:(MessageTableItem *)item;


-(void)showBotStartButton:(NSString *)startParam bot:(TLUser *)bot;



- (void)sendImage:(NSString *)file_path forConversation:(TL_conversation *)conversation file_data:(NSData *)data caption:(NSString *)caption;
- (void)sendImage:(NSString *)file_path forConversation:(TL_conversation *)conversation file_data:(NSData *)data;
- (void)sendVideo:(NSString *)file_path forConversation:(TL_conversation *)conversation;
- (void)sendDocument:(NSString *)file_path forConversation:(TL_conversation *)conversation;
- (void)sendImage:(NSString *)file_path forConversation:(TL_conversation *)conversation file_data:(NSData *)data isMultiple:(BOOL)isMultiple addCompletionHandler:(dispatch_block_t)completeHandler;

- (void)sendAttachments:(NSArray *)attachments forConversation:(TL_conversation *)conversation addCompletionHandler:(dispatch_block_t)completeHandler;

- (void)addImageAttachment:(NSString *)file_path forConversation:(TL_conversation *)conversation file_data:(NSData *)data addCompletionHandler:(dispatch_block_t)completeHandler;


- (void)sendVideo:(NSString *)file_path forConversation:(TL_conversation *)conversation caption:(NSString *)caption addCompletionHandler:(dispatch_block_t)completeHandler;
- (void)sendDocument:(NSString *)file_path forConversation:(TL_conversation *)conversation caption:(NSString *)caption addCompletionHandler:(dispatch_block_t)completeHandler;


- (void)sendVideo:(NSString *)file_path forConversation:(TL_conversation *)conversation addCompletionHandler:(dispatch_block_t)completeHandler;
- (void)sendDocument:(NSString *)file_path forConversation:(TL_conversation *)conversation addCompletionHandler:(dispatch_block_t)completeHandler;


-(void)sendSticker:(TLDocument *)sticker forConversation:(TL_conversation *)conversation addCompletionHandler:(dispatch_block_t)completeHandler;

- (void)sendAudio:(NSString *)file_path forConversation:(TL_conversation *)conversation waveforms:(NSData *)waveforms;
- (void)sendMessage:(NSString *)message forConversation:(TL_conversation *)conversation;
- (void)sendLocation:(CLLocationCoordinate2D)coordinates forConversation:(TL_conversation *)conversation;
- (void)forwardMessages:(NSArray *)messages conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback;
- (void)shareContact:(TLUser *)contact forConversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback;
- (void)sendSecretTTL:(int)ttl forConversation:(TL_conversation *)conversation;
- (void)sendSecretTTL:(int)ttl forConversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback;
- (void)sendFoundGif:(TLMessageMedia *)media forConversation:(TL_conversation *)conversation;
- (void)sendCompressedItem:(TGCompressItem *)compressedItem;
- (void)sendContextBotResult:(TLBotInlineResult *)botContextResult via_bot_id:(int)via_bot_id via_bot_name:(NSString *)via_bot_name queryId:(long)queryId forConversation:(TL_conversation *)conversation;
-(void)sendStartBot:(NSString *)startParam forConversation:(TL_conversation *)conversation bot:(TLUser *)bot;

- (NSArray *)messageTableItemsFromMessages:(NSArray *)input;
+ (NSArray *)messageTableItemsFromMessages:(NSArray *)input;
- (void)hideTopInfoView:(BOOL)animated;
- (void)showTopInfoView:(BOOL)animated;

//- (void)showConnectionController:(BOOL)animated;
//- (void)hideConnectionController:(BOOL)animated;

-(void)showSearchBox;
-(BOOL)searchBoxIsVisible;
-(void)nextSearchResult;
-(void)prevSearchResult;

-(NSArray *)messageList;


-(void)reloadData;


-(void)setFwdMessages:(NSArray *)messages forConversation:(TL_conversation *)conversation;
-(NSArray *)fwdMessages:(TL_conversation *)conversation;
-(void)clearFwdMessages:(TL_conversation *)conversation;

-(void)performForward:(TL_conversation *)conversation;

-(void)checkWebpage:(NSString *)link;


-(void)showOrHideChannelDiscussion;

-(void)tryRead;

-(BOOL)contextAbility;

-(void)selectInputTextByText:(NSString *)text;

-(TGMessagesHintView *)hintView;

-(void)setEditableMessage:(TL_localMessage *)message;
-(void)forceSetEditSentMessage:(BOOL)rollback;
-(TGInputMessageTemplateType)templateType;

-(void)showOrHideESGController:(BOOL)animated toggle:(BOOL)toggle;
-(BOOL)isShownESGController;
-(BOOL)canShownESGController;



@end
