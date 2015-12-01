
//
//  MessagesViewController.m
//  TelegramTest
//
//  Created by keepcedr on 10/29/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//
#import "TGSendTypingManager.h"
#import "MessagesViewController.h"
#import "MessageTableCellGifView.h"
#import "NSString+Size.h"
#import "MessageSender.h"
#import "TLPeer+Extensions.h"
#import "MessagesBottomView.h"
#import "CMath.h"
#import "ImageCache.h"
#import "SpacemanBlocks.h"
#import "EmojiViewController.h"

#import "NSImage+RHResizableImageAdditions.h"
#import "Telegram.h"
#import "AppDelegate.h"
#import "SJExpandingTextView.h"
#import "MessageTableItem.h"
#import "EncryptedParams.h"
#import "NSString+Extended.h"
#import "NSDate-Utilities.h"
#import "NSArray+BlockFiltering.h"

#import "MessageTypingView.h"
#import "MessageTableElements.h"

#import "FileUtils.h"
#import "SelfDestructionController.h"
#import "MessageTableNavigationTitleView.h"
#import "TelegramPopover.h"
#import "TMMediaController.h"
#import "TMNameTextField.h"
#import "MessageTableItemAudio.h"
#import "ImageUtils.h"
#import "EncryptedKeyWindow.h"

#import "ChatHistoryController.h"
#import "ChannelHistoryController.h"

#import "TMBottomScrollView.h"
#import "ReadHistroryTask.h"
#import "TMTaskRequest.h"
#import "PhotoVideoHistoryFilter.h"
#import "PhotoHistoryFilter.h"
#import "DocumentHistoryFilter.h"
#import "VideoHistoryFilter.h"
#import "AudioHistoryFilter.h"
#import "ChannelFilter.h"
#import "NoMessagesView.h"
#import "TMAudioRecorder.h"
#import "MessagesTopInfoView.h"
#import "HackUtils.h"
#import "SearchMessagesView.h"
#import "TGPhotoViewer.h"
#import <MtProtoKit/MTEncryption.h>
#import "StickersPanelView.h"
#import "StickerSenderItem.h"
#import "RequestKeySecretSenderItem.h"
#import "ExternalDocumentSecretSenderItem.h"
#import "TGPasslock.h"
#import "NSString+FindURLs.h"
#import "ImageAttachSenderItem.h"
#import "FullUsersManager.h"
#import "StartBotSenderItem.h"
#import "TGHelpPopup.h"
#import "TGAudioPlayerWindow.h"
#import "MessagesUtils.h"
#import "ChannelImportantFilter.h"
#import "TGModalDeleteChannelMessagesView.h"
#import "ComposeActionDeleteChannelMessagesBehavior.h"

#import "TGModernUserViewController.h"
#import "TGModernChatInfoViewController.h"
#import "TGModernChannelInfoViewController.h"
#define HEADER_MESSAGES_GROUPING_TIME (10 * 60)

#define SCROLLDOWNBUTTON_OFFSET 1500





@implementation SearchSelectItem

-(id)init {
    if(self = [super init]) {
        _marks = [[NSMutableArray alloc] init];
    }
    
    return self;
}


-(void)clear {
    ((MessageTableItemText *)self.item).mark = nil;
    [self.marks removeAllObjects];
    _marks = nil;
}

@end

@interface MessagesViewController () <SettingsListener,TMNavagationDelegate> {
    __block SMDelayedBlockHandle _delayedBlockHandle;
}

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableDictionary *cacheTextForPeer;
@property (nonatomic, assign) BOOL locked;

@property (nonatomic,strong) NSMutableDictionary *typingReservation;
@property (nonatomic, strong) ChatHistoryController *historyController;
@property (nonatomic, strong) SelfDestructionController *destructionController;
@property (nonatomic, strong) RPCRequest *typingRequest;

@property (nonatomic,strong) TL_localMessage *jumpMessage;
//Bottom
@property (nonatomic, strong) MessageTypingView *typingView;



@property (nonatomic, strong) TMNameTextField *nameTextField;


@property (nonatomic, strong) NoMessagesView *noMessagesView;
@property (nonatomic, strong) TMBottomScrollView *jumpToBottomButton;

@property (nonatomic, assign) BOOL isMarkIsset;


@property (nonatomic,assign) int lastBottomOffsetY;
@property (nonatomic,assign) int lastBottomScrollOffset;

@property (nonatomic, strong) TMTextButton *normalNavigationLeftView;
@property (nonatomic, strong) MessageTableNavigationTitleView *normalNavigationCenterView;
@property (nonatomic, strong) TMTextButton *normalNavigationRightView;

@property (nonatomic, strong) TMTextButton *editableNavigationRightView;
@property (nonatomic, strong) TMTextButton *editableNavigationLeftView;

@property (nonatomic, strong) TMTextButton *filtredNavigationLeftView;
@property (nonatomic, strong) TMTextButton *filtredNavigationCenterView;



@property (nonatomic,strong) MessagesTopInfoView *topInfoView;

@property (nonatomic,assign) int ignoredCount;

@property (nonatomic,strong) SearchMessagesView *searchMessagesView;


@property (nonatomic,strong) NSMutableArray *searchItems;

@property (nonatomic,strong) id activity;

@property (nonatomic,strong) MessageTableItemUnreadMark *unreadMark;

@property (nonatomic,strong) StickersPanelView *stickerPanel;

@property (nonatomic,strong) NSMutableDictionary *fwdCache;

@property (nonatomic,strong) NSMutableArray *replyMsgsStack;

@property (nonatomic,strong) RPCRequest *webPageRequest;
@property (nonatomic,strong) NSString *noWebpageString;

@property (nonatomic, strong) TL_conversation *conversation;

@property (nonatomic, strong) TGMessagesHintView *hintView;

@property (nonatomic,assign) BOOL needNextRequest;

@end

@implementation MessagesViewController

- (id)init {
    self = [super init];
    [self initialize];
    return self;
}


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    [self initialize];
    return self;
}


- (void)initialize {
    self.fwdCache = [[NSMutableDictionary alloc] init];
}

- (NoMessagesView *)noMessagesView {
    if(self->_noMessagesView)
        return self->_noMessagesView;
    
    NoMessagesView *view = [[NoMessagesView alloc] initWithFrame:NSMakeRect(0, 60, self.view.bounds.size.width, self.view.bounds.size.height-60)];
    
    self->_noMessagesView = view;
    return self.noMessagesView;
}

- (void)jumpToLastMessages:(BOOL)force {
    
    BOOL animated = YES;
    
    
    if(!force) {
        if(self.replyMsgsStack.count > 0)
        {
            TL_localMessage *msg = [self.replyMsgsStack lastObject];
            
            [self.replyMsgsStack removeObject:[self.replyMsgsStack lastObject]];
            
            [self showMessage:msg fromMsg:nil animated:YES selectText:nil switchDiscussion:NO flags:ShowMessageTypeReply];
            return;
        }
    }
    
    
    
    if(_historyController.prevState != ChatHistoryStateFull || force) {
        
        [self flushMessages];
        
        [self.historyController drop:YES];
        
        self.isMarkIsset = NO;
                
        self.historyController = nil;
        
        self.historyController = [[[self hControllerClass] alloc] initWithController:self historyFilter:self.defHFClass];
        animated = NO;
        
        
        [self loadhistory:0 toEnd:YES prev:NO isFirst:YES];
    }
    
    [self.table.scrollView scrollToPoint:NSMakePoint(0, 0) animation:animated];
}

-(Class)hControllerClass {
    return self.conversation.type == DialogTypeChannel ? [ChannelHistoryController class] : [ChatHistoryController class];
}

-(Class)defHFClass {
    return self.conversation.type == DialogTypeChannel ? (self.conversation.chat.isMegagroup || self.conversation.chat.type == TLChatTypeForbidden ? [ChannelFilter class] : [ChannelImportantFilter class]) : [HistoryFilter class];
}


-(NSArray *)messageList {
    return [self.messages copy];
}

-(void)reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table reloadData];
    });
}

- (void)loadView {

    [super loadView];
    
    _replyMsgsStack = [[NSMutableArray alloc] init];
    
    self.typingReservation = [[NSMutableDictionary alloc] init];
    
    self.locked = NO;
    self.cacheTextForPeer = [Storage inputTextForPeers];
    
    [Notification addObserver:self selector:@selector(messageReadNotification:) name:MESSAGE_READ_EVENT];
    [Notification addObserver:self selector:@selector(messageTableItemUpdate:) name:UPDATE_MESSAGE_ITEM];
    [Notification addObserver:self selector:@selector(messageTableItemsWebPageUpdate:) name:UPDATE_WEB_PAGE_ITEMS];
    [Notification addObserver:self selector:@selector(messageTableItemsReadContents:) name:UPDATE_READ_CONTENTS];
    [Notification addObserver:self selector:@selector(messageTableItemsEntitiesUpdate:) name:UPDATE_MESSAGE_ENTITIES];
    [Notification addObserver:self selector:@selector(messageTableItemsHoleUpdate:) name:UPDATE_MESSAGE_GROUP_HOLE];
    
    [Notification addObserver:self selector:@selector(didChangeDeleteDialog:) name:DIALOG_DELETE];
    
    [Notification addObserver:self selector:@selector(updateMessageViews:) name:UPDATE_MESSAGE_VIEWS];
    
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowBecomeNotification:) name:NSWindowDidBecomeKeyNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowBecomeNotification:) name:NSWindowDidResignKeyNotification object:self.view.window];
    
    [Notification addObserver:self selector:@selector(updateChat:) name:CHAT_UPDATE_TYPE];
    
    self.messages = [[NSMutableArray alloc] init];
    self.selectedMessages = [[NSMutableArray alloc] init];
    
    weak();
    
    //Navigation
    self.normalNavigationRightView = [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.Edit", nil)];
    [self.normalNavigationRightView setTapBlock:^{
        [weakSelf setCellsEditButtonShow:YES animated:YES];
    }];
    [self.normalNavigationRightView setDisableColor:NSColorFromRGB(0xa0a0a0)];
    
    
    
    
    self.filtredNavigationCenterView = [TMTextButton standartUserProfileButtonWithTitle:@"nil"];
    
    [self.filtredNavigationCenterView setFont:TGSystemFont(14)];
    [self.filtredNavigationCenterView setAlignment:NSCenterTextAlignment];
    
    [self.filtredNavigationCenterView setTextColor:BLUE_UI_COLOR];
    
    [self.filtredNavigationCenterView setFrameOrigin:NSMakePoint(0, -13)];
    
    
    
    
    self.filtredNavigationLeftView = [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.Cancel", nil)];
    
    
    [self.filtredNavigationLeftView setTapBlock:^{ 
        [weakSelf setHistoryFilter:[weakSelf defHFClass] force:NO];
    }];
    
    self.normalNavigationCenterView = [[MessageTableNavigationTitleView alloc] initWithFrame:NSZeroRect];
    [self.normalNavigationCenterView setController:self];
    
    [self.normalNavigationCenterView setTapBlock:^{
        [weakSelf.navigationViewController showInfoPage:weakSelf.conversation];
    }];
    self.centerNavigationBarView = self.normalNavigationCenterView;
    
    
    
    self.editableNavigationLeftView = [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.DeleteAll", nil)];
    
    [self.editableNavigationLeftView setTapBlock:^{
          [weakSelf clearHistory:weakSelf.conversation];
    }];
    
    
    self.editableNavigationRightView = [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.Done", nil)];
    [self.editableNavigationRightView setTapBlock:^{
        [weakSelf unSelectAll];
    }];
    
    
    
    //Center
    _table = [[MessagesTableView alloc] initWithFrame:self.view.bounds];
    [self.table setAutoresizesSubviews:YES];
    [self.table.containerView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    [self.table setDelegate:self];
    [self.table setDataSource:self];
    [self.table setViewController:self];
    
     self.table.layer.superlayer.backgroundColor = NSColorFromRGB(0xffffff).CGColor;
    
    
    [self.view addSubview:self.table.containerView];
    
    self.typingView = [[MessageTypingView alloc] initWithFrame:self.view.bounds];
    
    self.bottomView = [[MessagesBottomView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, 58)];
    self.bottomView.messagesViewController = self;
    [self.bottomView setAutoresizesSubviews:YES];
    [self.bottomView setAutoresizingMask:NSViewWidthSizable];
    [self bottomViewChangeSize:58 animated:NO];
    [self.view addSubview:self.bottomView];
    
    
    [self.view addSubview:self.noMessagesView];
    [self showNoMessages:NO];
    
    
    self.jumpToBottomButton = [[TMBottomScrollView alloc] initWithFrame:NSMakeRect(0, 0, 44, 44)];
    [self.jumpToBottomButton setAutoresizingMask:NSViewMinXMargin];
    [self.jumpToBottomButton setHidden:YES];
    [self.jumpToBottomButton setCallback:^{
        [weakSelf jumpToLastMessages:NO];
    }];
    [self.view addSubview:self.jumpToBottomButton];
    
    
    self.topInfoView = [[MessagesTopInfoView alloc] initWithFrame:NSMakeRect(0,self.view.frame.size.height, self.view.frame.size.width, 40)];
    
    self.topInfoView.controller = self;
    
    [self.topInfoView setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewWidthSizable];
    
    [self.view addSubview:self.topInfoView];
    
   
    
    self.searchMessagesView = [[SearchMessagesView alloc] initWithFrame:NSMakeRect(0, NSHeight(self.view.frame), NSWidth(self.view.frame), 40)];
    [self.searchMessagesView setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewWidthSizable];
    
    self.searchMessagesView.controller = self;
    
    [self.view addSubview:self.searchMessagesView];
    
    self.searchItems = [[NSMutableArray alloc] init];
    
    
    
    [self.searchMessagesView setHidden:YES];
    
    
    self.stickerPanel = [[StickersPanelView alloc] initWithFrame:NSMakeRect(0, NSHeight(self.bottomView.frame), NSWidth(self.view.frame), 76)];
    self.stickerPanel.messagesViewController = self;
    
    [self.view addSubview:self.stickerPanel];
    
    [self.stickerPanel hide:NO];

    
    
    
    self.hintView = [[TGMessagesHintView alloc] initWithFrame:NSMakeRect(0, NSHeight(self.bottomView.frame), NSWidth(self.view.frame), 100)];
    
     [self.hintView setHidden:YES];
    
    [self.view addSubview:self.hintView];
    
}

-(void)didChangeDeleteDialog:(NSNotification *)notification {
    TL_conversation *conversation = notification.userInfo[KEY_DIALOG];
    
    if(conversation.peer_id == _conversation.peer_id) {
        [self.navigationViewController goBackWithAnimation:YES];
    }
    
}

-(void)_didStackRemoved {
    
    self.conversation = nil;
    [self.historyController stopChannelPolling];
    [self flushMessages];
    
   
    
}


-(void)messageTableItemUpdate:(NSNotification *)notification {
    
    MessageTableItem *item = notification.userInfo[@"item"];
    
    [item makeSizeByWidth:item.makeSize];
    
    NSUInteger index = [self indexOfObject:item];
    
    if(index != NSNotFound)
        [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    
    
}

-(void)messageTableItemsReadContents:(NSNotification *)notification  {
    NSArray *messages = notification.userInfo[KEY_MESSAGE_ID_LIST];
        
    [self.historyController items:messages complete:^(NSArray *items) {
        
        [items enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
            
            MessageTableItem *item = [self itemOfMsgId:obj.channelMsgId];
            
            NSUInteger index = [self indexOfObject:item];
            
            if(index != NSNotFound) {
                [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            }
            
        }];
        
    }];
    
}


-(void)messageTableItemsWebPageUpdate:(NSNotification *)notification {
    
    NSArray *messages = notification.userInfo[KEY_DATA][@(self.conversation.peer_id)];
    
    TLWebPage *webpage = notification.userInfo[KEY_WEBPAGE];
    
    [self.historyController items:messages complete:^(NSArray *items) {
        
        [items enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
            
            MessageTableItemText *item = (MessageTableItemText *) [self itemOfMsgId:obj.channelMsgId];
            
            NSUInteger index = [self indexOfObject:item];
            
            item.message.media.webpage = webpage;
            
            [item updateWebPage];
            
            item.isHeaderMessage = item.isHeaderMessage || item.webpage != nil;
            
            if(index != NSNotFound) {
                [self.table noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:index]];
                
                [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            }
            
        }];
        
    }];
    
    
}

-(void)updateMessageViews:(NSNotification *)notification {
    
    
    if(self.conversation.peer_id == [notification.userInfo[KEY_PEER_ID] intValue]) {
        [self.historyController items:notification.userInfo[KEY_MESSAGE_ID_LIST] complete:^(NSArray *items) {
            NSDictionary *data = notification.userInfo[KEY_DATA];
            
            [items enumerateObjectsUsingBlock:^(TL_localMessage *message, NSUInteger idx, BOOL *stop) {
                
                MessageTableItem *item = [self itemOfMsgId:message.channelMsgId];
                
                NSUInteger index = [self indexOfObject:item];
                
                item.message.views = [data[@(item.message.n_id)] intValue];
                
                BOOL upd = [item updateViews];
                
                if(upd && index != NSNotFound) {
                    [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                }
            }];
            
        }];
    }
    
}

-(void)messageTableItemsHoleUpdate:(NSNotification *)notification {
    
    
    if(self.historyController.filter.class == [ChannelImportantFilter class]) {
        TGMessageGroupHole *hole = notification.userInfo[KEY_GROUP_HOLE];
        
        if(hole.peer_id == self.conversation.peer_id) {
            [self.historyController items:@[@(hole.uniqueId)] complete:^(NSArray *items) {
                
                MessageTableItemHole *item;
                
                if(items.count == 1) {
                    
                    item = (MessageTableItemHole *) [self itemOfMsgId:[[items firstObject] channelMsgId]];
                    
                    if(hole.messagesCount != 0) {
                        
                        NSUInteger index = [self indexOfObject:item];
                        
                        [item updateWithHole:hole];
                        
                        if(index != NSNotFound) {
                            [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                        }
                    } else {
                        [Notification perform:MESSAGE_DELETE_EVENT data:@{KEY_DATA:@[@{KEY_PEER_ID:@(hole.peer_id),KEY_MESSAGE_ID:@(hole.uniqueId)}]}];
                    }
                } else {
                    [Notification performOnStageQueue:MESSAGE_RECEIVE_EVENT data:@{KEY_MESSAGE:[TL_localMessageService createWithHole:hole]}];
                }
            }];
        }
    }

}

-(void)messageTableItemsEntitiesUpdate:(NSNotification *)notification {
    
    TL_localMessage *message = notification.userInfo[KEY_MESSAGE];
    
    
    if(message.peer_id == self.conversation.peer_id) {
        [self.historyController items:@[@(message.n_id)] complete:^(NSArray *items){
            
            [items enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
                
                MessageTableItemText *item = (MessageTableItemText *) [self itemOfMsgId:obj.channelMsgId];
                
                NSUInteger index = [self indexOfObject:item];
                
                [item updateEntities];
                
                if(index != NSNotFound) {
                    [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                }
                
            }];
        }];
    }
    
    
}


-(void)showSearchBox {
    
    if(!self.searchMessagesView.isHidden) {
        [self.searchMessagesView becomeFirstResponder];
        return;
    }
    
    
    [self.searchMessagesView showSearchBox:^(TL_localMessage *msg, NSString *searchString) {
        
        [self showMessage:msg fromMsg:nil animated:NO selectText:searchString switchDiscussion:NO flags:ShowMessageTypeReply];
        
    } closeCallback:^{
         [self hideSearchBox:YES];
    }];
   
    
 //   [self hideConnectionController:YES];
 //   [self hideTopInfoView:YES];
    
    [self.searchMessagesView setHidden:NO];
    

    NSSize newSize = NSMakeSize(self.table.scrollView.frame.size.width, self.view.frame.size.height - _lastBottomOffsetY - 40);
    NSPoint newPoint = NSMakePoint(0,self.view.frame.size.height-40);
    
    [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
        [context setDuration:0.3];
        [[self.searchMessagesView animator] setFrameOrigin:newPoint];
        [[self.table.scrollView animator] setFrameSize:newSize];
        [self.searchMessagesView setNeedsDisplay:YES];
        
    } completionHandler:^{
        [self.searchMessagesView becomeFirstResponder];
    }];
    
}

-(BOOL)searchBoxIsVisible {
    return !self.searchMessagesView.isHidden;
}


-(void)hideSearchBox:(BOOL)animated {
    
    if(self.searchMessagesView.isHidden)
        return;
    
    if(self.historyController != nil && self.historyController.prevState != ChatHistoryStateFull)
        [self jumpToLastMessages:YES];
    
    [self.searchItems enumerateObjectsUsingBlock:^(SearchSelectItem *obj, NSUInteger idx, BOOL *stop) {
        
        [obj clear];
        
        if([self indexOfObject:obj.item] != NSNotFound) {
            [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[self.messages indexOfObject:obj.item]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
        
        
        
    }];
    
    
    [self.searchItems removeAllObjects];

    
    NSSize newSize = NSMakeSize(self.table.scrollView.frame.size.width, self.view.frame.size.height-_lastBottomOffsetY);
    NSPoint newPoint = NSMakePoint(0, self.view.frame.size.height);
    
    if(animated) {
        [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
            [context setDuration:0.3];
            [[self.searchMessagesView animator] setFrameOrigin:newPoint];
            [[self.table.scrollView animator] setFrameSize:newSize];
            [self.searchMessagesView setNeedsDisplay:YES];
            
        } completionHandler:^{
            [self.searchMessagesView setHidden:YES];
            [self.searchMessagesView resignFirstResponder];
        }];
    } else {
        [self.searchMessagesView setFrameOrigin:newPoint];
        [self.table.scrollView setFrameSize:newSize];
        [self.searchMessagesView setNeedsDisplay:YES];
        [self.searchMessagesView setHidden:YES];
    }
    
}


- (void)setCellsEditButtonShow:(BOOL)show animated:(BOOL)animated {
    
    if(![self acceptState: show ? MessagesViewControllerStateEditable : MessagesViewControllerStateNone])
        return;
    
   // if(self.bottomView.stateBottom == MessagesBottomViewNormalState || self.bottomView.stateBottom == MessagesBottomViewActionsState)
  //  {
        [self setState: show ? MessagesViewControllerStateEditable : MessagesViewControllerStateNone animated:animated];
        for(int i = 0; i < self.messages.count; i++) {
            MessageTableCellContainerView *cell = (MessageTableCellContainerView *)[self cellForRow:i];
            if([cell isKindOfClass:[MessageTableCellContainerView class]] && [cell canEdit]) {
                [cell setEditable:show animation:animated];
            }
        }
  //  }
    
    
    
}




-(NSAttributedString *)stringForSharedMedia:(NSString *)mediaString {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    
    [string appendString:mediaString withColor:BLUE_UI_COLOR];
    
    [string setFont:TGSystemFont(14) forRange:NSMakeRange(0, string.length)];
    
    [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:headerMediaIcon()]];
    
    [string setAlignment:NSCenterTextAlignment range:NSMakeRange(0, string.length)];
    
    return string;
}


static NSTextAttachment *headerMediaIcon() {
    static NSTextAttachment *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSMutableAttributedString textAttachmentByImage:[image_HeaderDropdownArrow() imageWithInsets:NSEdgeInsetsMake(0, 5, 0, 4)]];
    });
    return instance;
}

- (void)showNoMessages:(BOOL)show {
    
    [ASQueue dispatchOnMainQueue:^{
        
        if((self.conversation.user.isBot && ( (self.historyController.nextState == ChatHistoryStateFull &&  (self.messages.count == 2 && [self.messages[1] isKindOfClass:[MessageTableItemServiceMessage class]]))))) {
          
            [self.bottomView setStateBottom:MessagesBottomViewBlockChat];
            
            if(self.bottomView.onClickToLockedView == nil) {
                weak();
                
                [self.bottomView setOnClickToLockedView:^{
                    [weakSelf sendMessage:@"/start" forConversation:weakSelf.conversation];
                    [weakSelf.bottomView setOnClickToLockedView:nil];
                    [weakSelf.bottomView setStateBottom:weakSelf.state == MessagesViewControllerStateEditable ? MessagesBottomViewActionsState : MessagesBottomViewNormalState];
                }];
            }

        } else if(self.bottomView.onClickToLockedView == nil || self.bottomView.botStartParam.length == 0) {
            
            MessagesBottomViewState nState = self.state == MessagesViewControllerStateEditable ? MessagesBottomViewActionsState : MessagesBottomViewNormalState;
            
            if(nState != self.bottomView.stateBottom) {
                [self.bottomView setStateBottom:nState];
                [self.bottomView setSectedMessagesCount:self.selectedMessages.count enable:[self canDeleteMessages]];
            }
            
            
            
            
            [self.bottomView setOnClickToLockedView:nil];
        }
       
        
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.noMessagesView setHidden:!show];
        
        [self.table.containerView setHidden:show];
        [CATransaction commit];
        
        [self updateLoading];
    }];
}

-(void)updateLoading {
    
    [ASQueue dispatchOnMainQueue:^{
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.noMessagesView setLoading:self.historyController.isProccessing || _needNextRequest];
        [CATransaction commit];
    }];
}

-(void)showBotStartButton:(NSString *)startParam bot:(TLUser *)bot {
    [self.bottomView setStateBottom:MessagesBottomViewBlockChat];
    self.bottomView.botStartParam = startParam;
    
    
    
    weak();
    [self.bottomView setOnClickToLockedView:^{
       
        TL_conversation *conversation = weakSelf.conversation;
        
        [ASQueue dispatchOnStageQueue:^{
            
            StartBotSenderItem *sender = [[StartBotSenderItem alloc] initWithMessage:conversation.type == DialogTypeChat || conversation.type == DialogTypeChannel ? [NSString stringWithFormat:@"/start@%@",bot.username] : @"/start" forConversation:conversation bot:bot startParam:startParam];
            sender.tableItem = [[weakSelf messageTableItemsFromMessages:@[sender.message]] lastObject];
            [weakSelf.historyController addItem:sender.tableItem conversation:conversation callback:nil sentControllerCallback:nil];
            
            [ASQueue dispatchOnMainQueue:^{
                
                [weakSelf.bottomView setOnClickToLockedView:nil];
                [weakSelf.bottomView setStateBottom:MessagesBottomViewNormalState];
                
            }];
       
        }];
    
        
    }];
    
    
    if(startParam.length > 0 && ![[startParam lowercaseString] isEqualToString:@"start"]) {
        self.bottomView.onClickToLockedView();
    }
}


- (void)updateChat:(NSNotification *)notify {
    TLChat *chat = [notify.userInfo objectForKey:KEY_CHAT];
    
    if(self.conversation.type == DialogTypeChat && self.conversation.peer.chat_id == chat.n_id) {
        [self.bottomView setStateBottom:MessagesBottomViewNormalState];
    }
}

- (void)setState:(MessagesViewControllerState)state {
    [self setState:state animated:NO];
    
}

-(BOOL)acceptState:(MessagesViewControllerState)state {
    return self.conversation.canEditConversation || state == MessagesViewControllerStateNone;
}

- (void)setState:(MessagesViewControllerState)state animated:(BOOL)animated {
    
    self->_state = state;
    
    id rightView, leftView, centerView;
    
    centerView = self.normalNavigationCenterView;
    
    
    if(state == MessagesViewControllerStateNone) {
        rightView = self.normalNavigationRightView;
        leftView = [self standartLeftBarView];
        
        [self.bottomView setState:MessagesBottomViewNormalState animated:animated];
        
    } else if(state == MessagesViewControllerStateFiltred) {
        rightView = self.filtredNavigationLeftView;
        leftView = self.normalNavigationLeftView;
        centerView = self.filtredNavigationCenterView;
        
        self.filtredNavigationCenterView.attributedStringValue = [self stringForSharedMedia:[self.historyController.filter description]];
        // [self.filtredNavigationCenterView sizeToFit];
        
    } else {
        rightView = self.editableNavigationRightView;
        leftView = self.conversation.type == DialogTypeChannel ? [self standartLeftBarView]  : self.editableNavigationLeftView;
        [self.bottomView setState:MessagesBottomViewActionsState animated:animated];
    }
    
    if(!self.conversation.canEditConversation)
        rightView = nil;
    
    if(self.rightNavigationBarView != rightView)
        [self setRightNavigationBarView:rightView animated:YES];
    
    if(self.leftNavigationBarView != leftView)
        [self setLeftNavigationBarView:leftView animated:YES];
    
    if(self.centerNavigationBarView != centerView) {
        [self setCenterNavigationBarView:centerView];
    }
    
}

- (void)rightButtonAction {
    
    if([[TMAudioRecorder sharedInstance] isRecording])
        return;
    
    [[[Telegram sharedInstance] firstController] closeAllPopovers];
    
    [self.navigationViewController showInfoPage:self.conversation];
}




+(NSMenu *)destructMenu:(dispatch_block_t)ttlCallback click:(dispatch_block_t)click {
    NSMenu *submenu = [[NSMenu alloc] init];
    
    MessagesViewController *controller = [Telegram rightViewController].messagesViewController;
    
    
    
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Secret.SelfDestruct.Off",nil) withBlock:^(id sender) {
        if(click) click();
        [controller sendSecretTTL:0 forConversation:controller.conversation callback:ttlCallback];
    }]];
    
    if(controller.conversation.encryptedChat.encryptedParams.layer != 1)
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSecond",nil),1] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:1 forConversation:controller.conversation callback:ttlCallback];
        }]];
    
    [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),2] withBlock:^(id sender) {
        if(click) click();
        [controller sendSecretTTL:2 forConversation:controller.conversation callback:ttlCallback];
    }]];
    
    if(controller.conversation.encryptedChat.encryptedParams.layer != 1)
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),3] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:3 forConversation:controller.conversation callback:ttlCallback];
        }]];
    
    if(controller.conversation.encryptedChat.encryptedParams.layer != 1)
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),4] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:4 forConversation:controller.conversation callback:ttlCallback];
        }]];

    [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),5] withBlock:^(id sender) {
        if(click) click();
        [controller sendSecretTTL:5 forConversation:controller.conversation callback:ttlCallback];
    }]];
    
    if(controller.conversation.encryptedChat.encryptedParams.layer != 1) {
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),6] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:6 forConversation:controller.conversation callback:ttlCallback];
        }]];
        
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),7] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:7 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),8] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:8 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),9] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:9 forConversation:controller.conversation callback:ttlCallback];
        }]];
        
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),10] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:10 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),11] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:11 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),12] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:12 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),13] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:13 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),14] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:14 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),15] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:15 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),30] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:30 forConversation:controller.conversation callback:ttlCallback];
        }]];

    }
    
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Secret.SelfDestruct.1m",nil) withBlock:^(id sender) {
        if(click) click();
        [controller sendSecretTTL:60 forConversation:controller.conversation callback:ttlCallback];
    }]];
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Secret.SelfDestruct.1h",nil) withBlock:^(id sender) {
        if(click) click();
        [controller sendSecretTTL:60*60 forConversation:controller.conversation callback:ttlCallback];
    }]];
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Secret.SelfDestruct.1d",nil) withBlock:^(id sender) {
        if(click) click();
        [controller sendSecretTTL:60*60*24 forConversation:controller.conversation callback:ttlCallback];
    }]];
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Secret.SelfDestruct.1w",nil) withBlock:^(id sender) {
        if(click) click();
        [controller sendSecretTTL:60*60*24*7 forConversation:controller.conversation callback:ttlCallback];
    }]];
    
    
    return submenu;
}


+(NSMenu *)notifications:(dispatch_block_t)callback conversation:(TL_conversation *)conversation click:(dispatch_block_t)click {
    
    
    NSMenu *submenu = [[NSMenu alloc] init];
    
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Notifications.Menu.Enable",nil) withBlock:^(id sender) {
        if(click) click();
        [conversation muteOrUnmute:callback until:0];
    }]];
    
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Notifications.Menu.Mute1Hour",nil) withBlock:^(id sender) {
        if(click) click();
        [conversation muteOrUnmute:callback until:60*60 + 60];
    }]];
    
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Notifications.Menu.Mute8Hours",nil) withBlock:^(id sender) {
        if(click) click();
        [conversation muteOrUnmute:callback until:8*60*60 + 60];
    }]];
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Notifications.Menu.Mute2Days",nil) withBlock:^(id sender) {
        if(click) click();
        [conversation muteOrUnmute:callback until:2*24*60*60 + 60];
    }]];
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Notifications.Menu.Disable",nil) withBlock:^(id sender) {
        if(click) click();
        [conversation muteOrUnmute:callback until:365*24*60*60];
    }]];

    
    return submenu;
}


-(NSArray *)fwdMessages:(TL_conversation *)conversation {
    return self.fwdCache[@(conversation.peer_id)];
}


-(void)clearFwdMessages:(TL_conversation *)conversation {
    [self.fwdCache removeObjectForKey:@(conversation.peer_id)];
    
    if(self.conversation.peer_id == conversation.peer_id)
    {
        [self.bottomView updateFwdMessage:YES animated:YES];
    }
}

-(void)setFwdMessages:(NSArray *)fwdMessages forConversation:(TL_conversation *)conversation {
    self.fwdCache[@(conversation.peer_id)] = fwdMessages;
    
    if(self.conversation.peer_id == conversation.peer_id)
    {
        [self.bottomView updateFwdMessage:YES animated:NO];
    }
    
}

-(void)performForward:(TL_conversation *)conversation {
    [ASQueue dispatchOnMainQueue:^{
        
        NSArray *fwdMessages = [self fwdMessages:conversation];
        
        if(fwdMessages.count > 0) {
            [self forwardMessages:fwdMessages conversation:conversation callback:nil];
            [self clearFwdMessages:conversation];
        }
        
    }];
}

- (void)setHistoryFilter:(Class)filter force:(BOOL)force {
    
    assert([NSThread isMainThread]);
    
    if(self.conversation.type == DialogTypeChannel)
        filter = self.historyController.filter.class;
    
    if(self.historyController.filter.class != filter || force) {
        self.ignoredCount = 0;
        [self flushMessages];
        _historyController = [[self.historyController.class alloc] initWithController:self historyFilter:filter];
        [self loadhistory:0 toEnd:YES prev:NO isFirst:YES];
        self.state = MessagesViewControllerStateNone;
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self becomeFirstResponder];
    [TMMediaController setCurrentController:[TMMediaController controller]];

    
    [self tryRead];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.conversation.type == DialogTypeChannel) {
        [[FullChatManager sharedManager] performLoad:self.conversation.chat.n_id force:YES callback:nil];
    }
    
//
    [self.table reloadData];
    
    [self setState:self.state];
    if(self.state == MessagesViewControllerStateEditable)
        [self.bottomView setSectedMessagesCount:self.selectedMessages.count enable:[self canDeleteMessages]];
    
    #ifdef __MAC_10_10
    
    if([NSUserActivity class] && (self.conversation.type == DialogTypeChat || self.conversation.type == DialogTypeUser)) {
        NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:USER_ACTIVITY_CONVERSATION];
     //   activity.webpageURL = [NSURL URLWithString:@"http://telegram.org/dl"];
        activity.userInfo = @{@"peer":@{
                                      @"id":@(abs(self.conversation.peer_id)),
                                      @"type":self.conversation.type == DialogTypeChat ? @"group" : @"user"},
                              @"user_id":@([UsersManager currentUserId])};
        
        activity.title = @"org.telegram.conversation";
        
        self.activity = activity;
        
        [self.activity becomeCurrent];
    }
    
#endif
    
    if(self.conversation) {
        [Notification perform:@"ChangeDialogSelection" data:@{KEY_DIALOG:self.conversation, @"sender":self}];
    }
    
    [self.table.scrollView setHasVerticalScroller:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    [Notification perform:@"ChangeDialogSelection" data:@{}];
    
   [self.table.scrollView setHasVerticalScroller:NO];
    
    if(![globalAudioPlayer().delegate isKindOfClass:[TGAudioPlayerWindow class]]) {
        [globalAudioPlayer() stop];
        [globalAudioPlayer().delegate audioPlayerDidFinishPlaying:globalAudioPlayer()];
    }
    
}

-(void)viewDidDisappear:(BOOL)animated {
    
    
    if(NSClassFromString(@"NSUserActivity")) {
        [self.activity invalidate];
    }
    
}



- (void)scrollDidChange {
    
//    int bp = 0;
//    
//    [self.messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        
//        MessageTableCellGifView *view = [self.table viewAtColumn:0 row:idx makeIfNecessary:NO];
//        
//        if(view && [view isKindOfClass:[MessageTableCellGifView class]]) {
//            NSRange visibleRange = [_table rowsInRect:_table.visibleRect];
//            
//            if(idx < visibleRange.location || idx > visibleRange.location + visibleRange.length) {
//                [view pauseAnimation];
//            } else {
//                [view resumeAnimation];
//            }
//        }
//        
//       
//        
//    }];
    
}



- (void)setStringValueToTextField:(NSString *)stringValue {
    if(stringValue)
        [self.bottomView setInputMessageString:stringValue disableAnimations:NO];
}

- (NSString *)inputText {
    return self.bottomView.inputMessageString;
}

- (void) addScrollEvent {
    id clipView = [[self.table enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

- (void) removeScrollEvent {
    id clipView = [[self.table enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:clipView];
}

- (void)bottomViewChangeSize:(int)height animated:(BOOL)animated {
    if(height == _lastBottomOffsetY)
        return;
    
    _lastBottomOffsetY = height;
    
    
    NSRect newFrame = NSMakeRect(0, _lastBottomOffsetY, self.table.scrollView.frame.size.width, self.view.frame.size.height - _lastBottomOffsetY);
    
    if(animated) {
        
        [[self.table.scrollView animator] setFrame:newFrame];
        
        [[self.noMessagesView animator] setFrame:newFrame];
        
        [[self.stickerPanel animator] setFrameOrigin:NSMakePoint(NSMinX(self.stickerPanel.frame), height)];
        [[self.hintView animator] setFrameOrigin:NSMakePoint(NSMinX(self.hintView.frame), height)];
    } else {
        [self.table.scrollView setFrame:newFrame];
        [self.noMessagesView setFrame:newFrame];
        
        [self.stickerPanel setFrameOrigin:NSMakePoint(NSMinX(self.stickerPanel.frame), height)];
        [self.hintView setFrameOrigin:NSMakePoint(NSMinX(self.hintView.frame), height)];
    }
    
    
   
    [self jumpToBottomButtonDisplay];
    
    
}

- (CAAnimation *)animationForTablePosition:(NSPoint)from to:(NSPoint)to {
    CAAnimation *positionAnimation = [TMAnimations postionWithDuration:5.0 fromValue:from toValue:to];
    
    
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    return positionAnimation;
}

- (void)showTopInfoView:(BOOL)animated {
    
    
    
    NSRect topRect = NSMakeRect(0,self.view.frame.size.height-40, self.view.frame.size.width, 40);
    NSRect tableRect = NSMakeRect(0, self.table.scrollView.frame.origin.y, self.table.scrollView.frame.size.width, self.view.frame.size.height - _lastBottomOffsetY - 40);
    
    if(animated) {
        [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
            [context setDuration:0.3];
            [[self.topInfoView animator] setFrame:topRect];
            [[self.table.scrollView animator] setFrame:tableRect];
            [self.topInfoView setNeedsDisplay:YES];
        } completionHandler:nil];
    } else {
        self.topInfoView.frame = topRect;
        [self.table.scrollView setFrame:tableRect];
    }
    
}


- (void)hideTopInfoView:(BOOL)animated {
    
    NSSize newSize = NSMakeSize(self.table.scrollView.frame.size.width, self.view.frame.size.height-_lastBottomOffsetY);
    NSPoint newPoint = NSMakePoint(0, self.view.frame.size.height);
    if(animated) {
        [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
            [context setDuration:0.3];
            [[self.table.scrollView animator] setFrameSize:newSize];
            [[self.topInfoView animator] setFrameOrigin:newPoint];
            [self.topInfoView setNeedsDisplay:YES];
        } completionHandler:nil];
        
    } else {
        [self.table.scrollView setFrameSize:newSize];
        [self.topInfoView setFrameOrigin:newPoint];
    }
    
}

-(void)showOrHideChannelDiscussion {
    
    
    [self.replyMsgsStack removeAllObjects];
    
    if(self.table.scrollView.documentOffset.y > 0) {
        NSRange range = [self.table rowsInRect:[self.table visibleRect]];
        __block MessageTableItem *item;
        
        [self.messages enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if(![obj isKindOfClass:[MessageTableItemHole class]] && idx >= 2) {
                item = obj;
                *stop = YES;
            }
            
            
        }];
        
        
        if(item) {
            [self showMessage:item.message fromMsg:nil flags:0];
            return;
        } 

    }
    
    
    Class f = !self.normalNavigationCenterView.discussIsEnabled ? [ChannelImportantFilter class] : [ChannelFilter class];
    
    [self.historyController setFilter:[[f alloc] initWithController:self.historyController peer:_conversation.peer]];
    
    [self flushMessages];
    [self loadhistory:0 toEnd:YES prev:NO isFirst:YES];

    
    
}

//- (void)showConnectionController:(BOOL)animated {
//    
//    [self hideTopInfoView:NO];
//    
//    self.connectionController.alphaValue = 0.0;
//    [self.connectionController setHidden:NO];
//    NSRect topRect = NSMakeRect(0,self.view.frame.size.height-20, self.view.frame.size.width, 20);
//    NSRect tableRect = NSMakeRect(0, self.table.scrollView.frame.origin.y, self.table.scrollView.frame.size.width, self.view.frame.size.height - _lastBottomOffsetY - 20);
//    
//    if(animated) {
//        [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
//            [context setDuration:0.3];
//            [[self.connectionController animator] setAlphaValue:1.0f];
//            [[self.connectionController animator] setFrame:topRect];
//            [[self.table.scrollView animator] setFrame:tableRect];
//        } completionHandler:nil];
//    } else {
//        self.connectionController.frame = topRect;
//        [self.connectionController setAlphaValue:1.0f];
//        [self.table.scrollView setFrame:tableRect];
//    }
//    
//}


//- (void)hideConnectionController:(BOOL)animated {
//    self.connectionController.alphaValue = 1.0f;
//    [self.connectionController setHidden:NO];
//    NSSize newSize = NSMakeSize(self.table.scrollView.frame.size.width, self.view.frame.size.height-_lastBottomOffsetY);
//    NSPoint newPoint = NSMakePoint(0, self.view.frame.size.height);
//    if(animated) {
//        [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
//            [context setDuration:0.3];
//            [[self.table.scrollView animator] setFrameSize:newSize];
//            [[self.connectionController animator] setFrameOrigin:newPoint];
//            [[self.connectionController animator] setAlphaValue:0.0f];
//            
//            
//        } completionHandler:^{
//            [self.connectionController setHidden:YES];
//            if([self.topInfoView isShown])
//                [self showTopInfoView:YES];
//        }];
//        
//    } else {
//        [self.table.scrollView setFrameSize:newSize];
//        [self.connectionController setHidden:YES];
//        [self.connectionController setFrameOrigin:newPoint];
//        if([self.topInfoView isShown])
//            [self showTopInfoView:NO];
//    }
//    
//}

- (void)showForwardMessagesModalView {
    [[Telegram rightViewController] showForwardMessagesModalView:self.conversation messagesCount:self.selectedMessages.count];
}


- (void)jumpToBottomButtonDisplay {
    [self.jumpToBottomButton sizeToFit];
    [self.jumpToBottomButton setFrameOrigin:NSMakePoint(self.view.bounds.size.width - self.jumpToBottomButton.bounds.size.width - 30, self.bottomView.bounds.size.height + 30)];
}


- (void)updateScrollBtn {
    static int min_go_size = 5000;
    static int max_go_size = 1000;
    
    float offset = self.table.scrollView.documentOffset.y;
    
    
    
    if([self.table.scrollView isAnimating])
        return;
    
    _lastBottomScrollOffset = offset;
    
    
    BOOL hide = !(self.table.scrollView.documentSize.height > min_go_size && offset > min_go_size);
    
    
    
    if(hide) {
        hide = !(self.isMarkIsset && offset > max_go_size);
    }
    
    if(hide && (offset - self.table.scrollView.bounds.size.height) > SCROLLDOWNBUTTON_OFFSET) {
        hide = self.jumpToBottomButton.messagesCount == 0;
    }
//    
//
    
    if(hide)
    {
        hide = self.replyMsgsStack.count == 0;
        
        if(!hide)
        {
            MessageTableItem *item = [self itemOfMsgId:[[_replyMsgsStack lastObject] channelMsgId]];
            
            if(item) {
                NSRect rowRect = [self.table rectOfRow:[self indexOfObject:item]];
                
                hide = CGRectContainsRect([self.table visibleRect], rowRect) || self.table.scrollView.documentOffset.y < rowRect.origin.y;
                
                
                if(hide) {
                    [_replyMsgsStack removeLastObject];
                }
            }
            
           
            
        }
    }
    
    if(hide) {
        [self.historyController prevStateAsync:^(ChatHistoryState state) {
            
            BOOL h = hide || state == ChatHistoryStateFull;
            
            if(self.jumpToBottomButton.isHidden != h) {
                [self.jumpToBottomButton setHidden:h];
                [self jumpToBottomButtonDisplay];
            }
            
        }];
    } else {
        if(self.jumpToBottomButton.isHidden != hide) {
            [self.jumpToBottomButton setHidden:hide];
            [self jumpToBottomButtonDisplay];
        }
    }
    
}

- (void)scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)aNotification {
    [self updateScrollBtn];
    
    [self scrollDidChange];
    
    if([self.table.scrollView isNeedUpdateTop] && [self.historyController filterWithNext:NO].prevState != ChatHistoryStateFull) {
        
        [self.historyController prevStateAsync:^(ChatHistoryState state) {
            if(state != ChatHistoryStateFull) {
                [self loadhistory:0 toEnd:NO prev:YES isFirst:NO];
            }
        }];
        
   } else if([self.table.scrollView isNeedUpdateBottom]) {
        
        [self.historyController nextStateAsync:^(ChatHistoryState state) {
            if(state != ChatHistoryStateFull) {
                [self loadhistory:0 toEnd:NO prev:NO isFirst:NO];
            }
        }];
        
        
    }
    
    
}

- (void) dealloc {
    [Notification removeObserver:self];
}

- (void) drop {
    self.conversation = nil;
    // [self.historyController setDialog:nil];
    [self.historyController drop:YES];
    self.historyController = nil;
    [self.messages removeAllObjects];
    [self.table deselectRow:self.table.selectedRow];
    [self.table reloadData];
    [Notification removeObserver:self];
}

-(void)dialogDeleteNotification:(NSNotification *)notify {
    TL_conversation *dialog = [notify.userInfo objectForKey:KEY_DIALOG];
    if(self.conversation.peer.peer_id == dialog.peer.peer_id) {
        [self.messages removeAllObjects];
        [self.table reloadData];
    }
}

- (void)windowBecomeNotification:(NSNotification *)notify {
    [self becomeFirstResponder];
    [self tryRead];
    [self.normalNavigationCenterView setDialog:self.conversation];
    
    
    
    if(self.unreadMark) {
        self.unreadMark.removeType = RemoveUnreadMarkAfterSecondsType;
        
        dispatch_after_seconds(5, ^{
            
            [self deleteItem:self.unreadMark];
            self.unreadMark = nil;
            
        });
    }
}

- (void)messageReadNotification:(NSNotification *)notify {
    
    NSArray *readed = [notify.userInfo objectForKey:KEY_MESSAGE_ID_LIST];
    
    [ASQueue dispatchOnMainQueue:^{
        [self.historyController items:readed complete:^(NSArray * filtred) {
            
            [filtred enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
               MessageTableItem *item = [self itemOfMsgId:obj.channelMsgId];
                
                item.message.flags&= ~TGUNREADMESSAGE;
                
                NSUInteger index = [self indexOfObject:item];
                
                if(index != NSNotFound) {
                    [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                }
                
            }];
            
            
        }];
    }]; 
    
}

- (MessageTableCell *)cellForRow:(NSInteger)row {
    return [self.table viewAtColumn:0 row:row makeIfNecessary:NO];
}


- (void)receivedMessage:(MessageTableItem *)message position:(int)position itsSelf:(BOOL)force  {
    
    
    NSArray *items;
    
    NSRange range = [self insertMessageTableItemsToList:@[message] startPosition:position needCheckLastMessage:YES backItems:&items checkActive:!force];
    
    if(range.length) {
        if(message.message.from_id != [UsersManager currentUserId]) {
            if(self.table.scrollView.documentOffset.y > SCROLLDOWNBUTTON_OFFSET) {
                [self.jumpToBottomButton setHidden:NO];
                [self.jumpToBottomButton setMessagesCount:self.jumpToBottomButton.messagesCount + 1];
                [self jumpToBottomButtonDisplay];
            }
            
        }
        
        [self insertAndGoToEnd:range forceEnd:force items:items];
        [self didUpdateTable];
    }
}


- (void)didAddIgnoredMessages:(NSArray *)items {
    self.ignoredCount+= (int)items.count;
}

-(void)setIgnoredCount:(int)ignoredCount {
    
    [CATransaction begin];
    
    [CATransaction disableActions];
    
    self->_ignoredCount = ignoredCount;
    if(ignoredCount > 0) {
        [self.filtredNavigationLeftView setStringValue:[NSString stringWithFormat:@"%@ (%@)",NSLocalizedString(@"Profile.Cancel", nil),[NSString stringWithFormat:NSLocalizedString(ignoredCount == 1 ? @"Messages.scrollToBottomNewMessage" : @"Messages.scrollToBottomNewMessages", nil), ignoredCount]]];
    } else
        [self.filtredNavigationLeftView setStringValue:NSLocalizedString(@"Profile.Cancel", nil)];
    
    [self.filtredNavigationLeftView sizeToFit];
    
    self.rightNavigationBarView = self.rightNavigationBarView;
    
    [CATransaction commit];
}


-(void)forceAddUnreadMark {
    if(!_unreadMark)
    {
        _unreadMark = [[MessageTableItemUnreadMark alloc] initWithCount:0 type:RemoveUnreadMarkAfterSecondsType];
    }
    
    [self messagesLoadedTryToInsert:@[_unreadMark] pos:0 next:NO];
}

- (void)insertAndGoToEnd:(NSRange)range forceEnd:(BOOL)forceEnd items:(NSArray *)items {
    
    
   // [CATransaction begin];
    StandartViewController *controller = (StandartViewController *) [[Telegram leftViewController] currentTabController];
    if([controller isKindOfClass:[StandartViewController class]] && controller.isSearchActive && forceEnd) {
        [(StandartViewController *)controller hideSearchViewControllerWithConversationUsed:self.conversation];
    }
    
    NSRect prevRect;
    
    if(self.unreadMark && self.unreadMark.removeType == RemoveUnreadMarkNoneType)
    {
        prevRect = [self.table rectOfRow:[self indexOfObject:self.unreadMark]];
    }
    
    
    BOOL isScrollToEnd = [self.table.scrollView isScrollEndOfDocument];
    
    forceEnd = isScrollToEnd ? NO : forceEnd;
    
    int height = 0;
    
    for (MessageTableItem *item in items) {
        height+=item.viewSize.height;
    }
    
    
  //   [self.table beginUpdates];
    
    
    [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] withAnimation:NSTableViewAnimationEffectNone];
    
    
//     [self.table endUpdates];
    
    
    
    if(isScrollToEnd || forceEnd) {
        if(_historyController.prevState != ChatHistoryStateFull) {
            [self jumpToLastMessages:YES];
            return;
        } else {
             [self.table.scrollView scrollToEndWithAnimation:YES];
        }
    }

     MessageTypingView *typingCell = [self.table viewAtColumn:0 row:0 makeIfNecessary:NO];
    
    if([typingCell isKindOfClass:[MessageTypingView class]]) {
        
        if([typingCell isActive]) {
            CALayer *parentLayer = typingCell.layer.superlayer.superlayer;
            
            [typingCell.layer.superlayer removeFromSuperlayer];
            [parentLayer insertSublayer:typingCell.layer.superlayer atIndex: (int) [parentLayer.sublayers count]];
        }
    }
   
    __block BOOL addAnimation = YES;
    
     NSRange visibleRange = [self.table rowsInRect:self.table.visibleRect];
    
    [items enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
            
        NSUInteger row = [self indexOfObject:obj];
            
        if(row < visibleRange.location || row > (visibleRange.location+visibleRange.length) ) {
            addAnimation = NO;
                
            *stop = YES;
                
        }
            
    }];
    
    
    if(self.unreadMark && self.unreadMark.removeType == RemoveUnreadMarkNoneType)
    {
        NSUInteger idx = [self indexOfObject:self.unreadMark];
        NSRect rect = [self.table rectOfRow:idx];
        
        
        if(NSMinY(rect) + NSHeight(rect) > NSHeight(self.table.scrollView.frame)) {
            addAnimation = (rect.origin.y - 1) != (self.table.scrollView.documentOffset.y + NSHeight(self.table.scrollView.frame)) && (NSMaxY(rect) < self.table.scrollView.documentOffset.y);
            
            if(!addAnimation)
                forceEnd = YES;
            
            [self scrollToUnreadItem:NO];
            
            if(rect.origin.y + height  > NSHeight(self.table.scrollView.frame) && addAnimation)
            {
                height= rect.origin.y - prevRect.origin.y;
                
                addAnimation = height > 0;
            }
        }
        
    }

    
    if(!addAnimation) {
        if(!isScrollToEnd && !forceEnd) {
            [self.table.scrollView scrollToPoint:NSMakePoint(self.table.scrollView.documentOffset.x, self.table.scrollView.documentOffset.y + height) animation:NO];
        }

        return;
    }
    
    

    
   

    NSUInteger count = visibleRange.location+visibleRange.length + 10;
    
    for (NSUInteger i = range.location; i < count && i < self.messages.count; i++) {
        
        MessageTableCell *cell = [self.table viewAtColumn:0 row:i makeIfNecessary:NO];
        
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        
        animation.duration = 0.2;
        
        
        CALayer *presentLayer = (CALayer *)[cell.layer.superlayer presentationLayer];
        
        
        float cellY = cell.layer.superlayer.frame.origin.y - height;
        
        if(presentLayer && [cell.layer.superlayer animationForKey:@"position"]) {
            float presentY = [[presentLayer valueForKeyPath:@"frame.origin.y"] floatValue];
            
            cellY = presentY;
        }
        

        
        NSPoint fromValue = NSMakePoint(0, cellY);
        
        NSPoint toValue = NSMakePoint(0, cell.layer.superlayer.frame.origin.y);
        
        NSValue *fromValueValue = [NSValue value:&fromValue withObjCType:@encode(CGPoint)];
        NSValue *toValueValue = [NSValue value:&toValue withObjCType:@encode(CGPoint)];
        
        animation.fromValue = fromValueValue;
        animation.toValue = toValueValue;
        [animation setValue:@(CALayerPositionAnimation) forKey:@"type"];
        
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        
        animation.removedOnCompletion = YES;
        
        [cell.layer.superlayer removeAllAnimations];
        
        [cell.layer.superlayer addAnimation:animation forKey:@"position"];
    }
    
    //  [CATransaction commit];
    
}


- (void)receivedMessageList:(NSArray *)list inRange:(NSRange)range itsSelf:(BOOL)force {
    
    
    
    NSArray *items;
    
    NSRange r = [self insertMessageTableItemsToList:list startPosition:range.location needCheckLastMessage:YES backItems:&items checkActive:!force];
    
    if(r.length) {
        [self insertAndGoToEnd:r forceEnd:force items:items];
        [self didUpdateTable];
    }
    
}

- (void) deleteSelectedMessages {
    
    if(![self canDeleteMessages])
        return;
    
    NSMutableDictionary *peers = [NSMutableDictionary dictionary];
    
    [self.selectedMessages enumerateObjectsUsingBlock:^(MessageTableItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableDictionary *data = peers[@(item.message.peer_id)];
        
        if(!data) {
            data = [NSMutableDictionary dictionary];
            peers[@(item.message.peer_id)] = data;
            data[@"conversation"] = item.message.conversation;
            data[@"ids"] = [NSMutableArray array];
            data[@"messages"] = [NSMutableArray array];
        }
        
        if(item.message.dstate == DeliveryStateNormal) {
            
            if([item.message isChannelMessage])
                [data[@"ids"] addObject:@(item.message.channelMsgId)];
            else if([item.message isKindOfClass:[TL_destructMessage class]])
                [data[@"ids"] addObject:@(item.message.randomId)];
            else
                [data[@"ids"] addObject:@(item.message.n_id)];
            
            [data[@"messages"] addObject:item];
            
        }
        
        
    }];
    
    
    
    [peers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSDictionary  *obj, BOOL * _Nonnull stop) {
        
        TL_conversation *conversation = obj[@"conversation"];
        NSMutableArray *array = obj[@"ids"];
        NSMutableArray *messages = obj[@"messages"];
        
        id request = [TLAPI_messages_deleteMessages createWithN_id:array];
        
        if(conversation.type == DialogTypeChannel) {
            
            
            request = [TLAPI_channels_deleteMessages createWithChannel:[TL_inputChannel createWithChannel_id:conversation.peer.channel_id access_hash:conversation.chat.access_hash] n_id:array];
            
            if(array.count > 0 && ![[(MessageTableItem *)messages[0] message] n_out] && [[(MessageTableItem *)messages[0] message] from_id] != 0) {
                TGModalDeleteChannelMessagesView *modalDeleteView = [[TGModalDeleteChannelMessagesView alloc] initWithFrame:[[[NSApp delegate] mainWindow].contentView bounds]];
                
                ComposeAction *action = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionDeleteChannelMessagesBehavior class] filter:@[] object:conversation.chat reservedObjects:@[array]];
                
                action.result = [[ComposeResult alloc] initWithMultiObjects:@[@(YES),@(YES),@(NO),@(NO)]];
                
                
                action.result.singleObject = [[(MessageTableItem *)messages[0] message] fromUser];
                
                [modalDeleteView showWithAction:action];
                
                return;
                
            }
            
            
        }
        
        dispatch_block_t completeBlock = ^ {
            
            if(conversation.type != DialogTypeChannel) {
                [[DialogsManager sharedManager] deleteMessagesWithMessageIds:array];
            }
            
        };
        
        if(conversation.type == DialogTypeSecretChat) {
            
            if(!conversation.canSendMessage)
            {
                completeBlock();
                return;
            }
            
            
            DeleteRandomMessagesSenderItem *sender = [[DeleteRandomMessagesSenderItem alloc] initWithConversation:self.conversation random_ids:array];
            
            [sender send];
            
            [[DialogsManager sharedManager] deleteMessagesWithRandomMessageIds:array isChannelMessages:NO];
            
            completeBlock();
            
        } else {
            [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
                
                if(conversation.type == DialogTypeChannel)
                {
                    [[MTNetwork instance].updateService.proccessor addUpdate:[TL_updateDeleteChannelMessages createWithChannel_id:conversation.peer.channel_id messages:array pts:[response pts] pts_count:[response pts_count]]];
                }
                
                completeBlock();
                
                
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                completeBlock();
            }];
        }
        
    }];
    
    
    [self unSelectAll];
    
}

-(void)flushMessages {
    self.locked = YES;
    [self.selectedMessages removeAllObjects];
    [self.messages removeAllObjects];
    [self.messages addObject:[[MessageTableItemTyping alloc] init]];
    [self.table reloadData];
    
    self.locked = NO;
    
    [self didUpdateTable];
    
    
}

- (void)deleteItems:(NSArray *)messages orMessageIds:(NSArray *)ids {
    
  //  [self.table beginUpdates];
    
    if(self.messages.count > 0) {
        NSUInteger count = self.selectedMessages.count;
        
        
        [messages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            MessageTableItem *item = [self itemOfMsgId:obj.channelMsgId];
            
            NSUInteger row = [self.messages indexOfObject:item];
            
            if(row != NSNotFound) {
                [self.messages removeObjectAtIndex:row];
                [self.selectedMessages removeObject:item];
                
                [self.table removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationEffectFade];
                [item clean];
            }

            
        }];
        
        
        if(_unreadMark && [self indexOfObject:_unreadMark] == 1) {
            [self.messages removeObjectAtIndex:1];
            [self.table removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:1] withAnimation:NSTableViewAnimationEffectFade];
        }

        
        __block NSInteger row = self.messages.count - 1;
        __block MessageTableItem *backItem = nil;
        [self.messages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MessageTableItem *item, NSUInteger idx, BOOL *stop) {
            BOOL isHeaderMessage = item.isHeaderMessage;
            [self isHeaderMessage:item prevItem:backItem];
            if(item.isHeaderMessage != isHeaderMessage) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:row];
                [self.table noteHeightOfRowsWithIndexesChanged:indexSet];
                [self.table reloadDataForRowIndexes:indexSet columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            }
            backItem = item;
            row--;
        }];
        
        
        [self didUpdateTable];
        
        if(count != self.selectedMessages.count) {
            if(self.selectedMessages.count)
                [self.bottomView setSectedMessagesCount:self.selectedMessages.count enable:[self canDeleteMessages]];
            else
                [self.bottomView setStateBottom:MessagesBottomViewNormalState];
        }
    }
    
   // [self.table endUpdates];
    
}

-(BOOL)canDeleteMessages {
    
    NSMutableArray *msgs = [[NSMutableArray alloc] init];
    
    [self.selectedMessages enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        [msgs addObject:obj.message];
    }];
    
    return [MessagesViewController canDeleteMessages:msgs inConversation:self.conversation];
}

+(BOOL)canDeleteMessages:(NSArray *)messages inConversation:(TL_conversation *)conversation {
    
    __block BOOL accept = YES;
    
    [messages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
        
        accept =obj.conversation.type == DialogTypeChannel ? ( obj.chat.isCreator || (obj.chat.isEditor && (obj.from_id != 0 || obj.n_out)) || (obj.chat.isModerator && obj.from_id != 0) || obj.n_out) : YES;
        
        if(!accept) {
            *stop = YES;
        }
        
    }];
    
    return accept;
    
}

- (MessageTableItem *) findMessageItemById:(long)msgId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.message.channelMsgId == %ld", msgId];
    
    NSArray *filtred = [self.messages filteredArrayUsingPredicate:predicate];
    
    if(filtred.count == 1) {
        return [filtred objectAtIndex:0];
    }
    return nil;
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    return NO;
}


// notifications

- (void)setSelectedMessage:(MessageTableItem *)item selected:(BOOL)selected {
    if(selected) {
        if([self.selectedMessages indexOfObject:item] == NSNotFound) {
            [self.selectedMessages addObject:item];
        }
    } else {
        [self.selectedMessages removeObject:item];
    }
    
    [self.bottomView setSectedMessagesCount:self.selectedMessages.count enable:[self canDeleteMessages]];
}

-(void)unSelectAll {
    [self unSelectAll:YES];
}

- (void)unSelectAll:(BOOL)animated {
    [self setCellsEditButtonShow:NO animated:animated];
    for(MessageTableItem *item in self.selectedMessages)
        item.isSelected = NO;
    
    [self.selectedMessages removeAllObjects];
    
    for(NSUInteger i = 0; i < self.messages.count; i++) {
        NSTableRowView *rowView = [self.table rowViewAtRow:i makeIfNecessary:NO];
        if(!rowView)
            continue;
        
        MessageTableCellContainerView *view = [[rowView subviews] objectAtIndex:0];
        if(view && [view isKindOfClass:[MessageTableCellContainerView class]]) {
            [view setSelected:NO animation:animated];
        }
    }
}



- (BOOL)becomeFirstResponder {
    [self.bottomView becomeFirstResponder];
    return YES;
}


- (NSUInteger)messagesCount {
    return self.messages.count;
}


- (void)saveInputText {
    if(!self.bottomView.inputMessageString) [self.bottomView setInputMessageString:@"" disableAnimations:YES];
    
    if(!self.conversation || !self.conversation.cacheKey)
        return;
    
    [self.cacheTextForPeer setObject:self.bottomView.inputMessageString forKey:self.conversation.cacheKey];
    [Storage saveInputTextForPeers:self.cacheTextForPeer];
    
    
    if(self.conversation.type == DialogTypeSecretChat && self.conversation.encryptedChat.encryptedParams.layer < 23)
        return;
    
    NSArray *emoji = [self.bottomView.inputMessageString getEmojiFromString:NO];
    
    
    
    if([self.bottomView.inputMessageString isEqualToString:[emoji lastObject]])
    {
        emoji = [self.bottomView.inputMessageString getEmojiFromString:YES];
        
        [self.stickerPanel showAndSearch:[emoji lastObject] animated:YES];
    } else
    {
        [self.stickerPanel hide:YES];
    }
    
    
}

- (void)showMessage:(TL_localMessage *)message fromMsg:(TL_localMessage *)fromMsg flags:(int)flags {
    [self showMessage:message fromMsg:fromMsg animated:YES selectText:nil switchDiscussion:NO flags:flags];
}

- (void)showMessage:(TL_localMessage *)message fromMsg:(TL_localMessage *)fromMsg switchDiscussion:(BOOL)switchDiscussion {
    [self showMessage:message fromMsg:fromMsg animated:YES selectText:nil switchDiscussion:switchDiscussion flags:0];
}

- (void)showMessage:(TL_localMessage *)message fromMsg:(TL_localMessage *)fromMsg animated:(BOOL)animated selectText:(NSString *)text switchDiscussion:(BOOL)switchDiscussion flags:(int)flags  {
    
    _needNextRequest = YES;
    
    
    if(fromMsg != nil)
        [_replyMsgsStack addObject:fromMsg];
    
    MessageTableItem *item = message.hole != nil ? [self itemOfMsgId:channelMsgId(message.hole.min_id, message.peer_id)] : [self itemOfMsgId:message.channelMsgId];
    
    if(item && (flags & ShowMessageTypeReply) > 0) {
        [self scrollToItem:item animated:YES centered:YES highlight:YES];
        
        return;
    }
    
    TL_conversation *conversation = self.conversation;
    
    __block TL_localMessage *msg = conversation.type == DialogTypeChannel && fromMsg == nil && ((flags & ShowMessageTypeUnreadMark) == 0 && (flags & ShowMessageTypeSearch) == 0) ? [[Storage manager] lastImportantMessageAroundMinId: message.hole ? channelMsgId(message.hole.min_id, message.peer_id) : message.channelMsgId] : [[Storage manager] messageById:message.hole ? message.hole.min_id : message.n_id inChannel:-message.to_id.channel_id];
    
    if((flags & ShowMessageTypeUnreadMark) > 0 && conversation.type == DialogTypeChannel && !msg) {
        [self flushMessages];
    }
    
    
    dispatch_block_t block = ^{
        
        if(conversation != self.conversation || !msg) {
            _needNextRequest = NO;
            return;
        }
        
        if(switchDiscussion)
            [self.normalNavigationCenterView enableDiscussion:!self.normalNavigationCenterView.discussIsEnabled force:YES];
        
        
        self.historyController = [[[self hControllerClass] alloc] initWithController:self historyFilter:conversation.type == DialogTypeChannel ? ( flags == 0 ? self.normalNavigationCenterView.discussIsEnabled || conversation.chat.isMegagroup ? [ChannelFilter class] : [ChannelImportantFilter class] : msg.isImportantMessage ? self.historyController.filter.class : [ChannelFilter class]) : [HistoryFilter class]];
        
        [self.normalNavigationCenterView enableDiscussion:[self.historyController.filter isKindOfClass:[ChannelFilter class]] force:YES];
        
        
        NSUInteger index = [self indexOfObject:[self itemOfMsgId:msg.channelMsgId]];
        
        __block NSRect rect = NSZeroRect;
        
        int yTopOffset = 0;
        
        if(index != NSNotFound) {
            rect = [self.table rectOfRow:index];
            
            yTopOffset =  self.table.scrollView.documentOffset.y + NSHeight(self.table.containerView.frame) - (rect.origin.y);
            
        }
        
        [self removeScrollEvent];
        
        
        if((flags & ShowMessageTypeUnreadMark) > 0 && msg.isChannelMessage ) {
            [self flushMessages];
        }
        
        
        int count = NSHeight(self.table.containerView.frame)/20;
        
        self.historyController.selectLimit = count/2 + 20;
        
        [self.historyController loadAroundMessagesWithMessage:msg prevLimit:count nextLimit:(flags & ShowMessageTypeUnreadMark) > 0 ? 1 : count selectHandler:^(NSArray *result, NSRange range, id controller) {
            
            if(controller == self.historyController && _conversation.peer_id == conversation.peer_id) {
                [self flushMessages];
                
                _needNextRequest = NO;
                
               
                NSUInteger index = [result indexOfObjectPassingTest:^BOOL(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    BOOL res = obj.message.channelMsgId == msg.channelMsgId;
                    
                    *stop = res;
                    
                    return res;
                }];
                
                MessageTableItem *item = result[index];
                
                if((flags & ShowMessageTypeUnreadMark) > 0) {
                    
                    if(index != 0 && index != NSNotFound) {
                        _unreadMark = [[MessageTableItemUnreadMark alloc] initWithCount:0 type:RemoveUnreadMarkAfterSecondsType];
                        
                        NSMutableArray *copy = [result mutableCopy];
                        [copy insertObject:_unreadMark atIndex:index];
                        
                        result = copy;
                    }
                    
                }
                
                [self messagesLoadedTryToInsert:result pos:range.location next:YES];
                
                
                
                [self.table setNeedsDisplay:YES];
                [self.table display];
                
                if((flags & ShowMessageTypeUnreadMark) > 0) {
                    
                    [self scrollToUnreadItem:NO];
                    
                } else if(rect.origin.y == 0 || ((flags & ShowMessageTypeReply) > 0 || (flags & ShowMessageTypeSearch) > 0)) {
                    [self scrollToItem:item animated:NO centered:YES highlight:fromMsg != nil];
                } else {
                    
                    __block NSRect drect = [self.table rectOfRow:[self indexOfObject:item]];
                    
                    
                    dispatch_block_t block = ^{
                        
                        drect.origin.y -= (NSHeight(self.table.containerView.frame)  -yTopOffset);
                        
                        drect.origin.y = MAX(0,drect.origin.y);
                        
                        [self.table.scrollView scrollToPoint:drect.origin animation:NO];
                        
                    };
                    
                    if(NSEqualRects(drect, NSZeroRect)) {
                        
                        dispatch_async(dispatch_get_main_queue(), block);
                    } else {
                        block();
                    }
                    
                    
                }
                
                if(index < 10) {
                    [self requestNextHistory];
                }
                
                [self addScrollEvent];
            }
            
        }];
        
    };
    
    if(!msg) {
        
        _needNextRequest = YES;
        
        [self flushMessages];
        
        
        
        id request = [TLAPI_messages_getMessages createWithN_id:[@[@(message.n_id)] mutableCopy]];
        
        if(self.conversation.type == DialogTypeChannel) {
            request = [TLAPI_channels_getMessages createWithChannel:message.conversation.inputPeer n_id:[@[@(message.hole ? message.hole.min_id : message.n_id)] mutableCopy]];
        }
        
        [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_messages * response) {
            
            _needNextRequest = NO;
            
            if(response.messages.count > 0 && ![response.messages[0] isKindOfClass:[TL_messageEmpty class]]) {
                msg = [TL_localMessage convertReceivedMessage:response.messages[0]];
                
                [response.messages removeAllObjects];
                [SharedManager proccessGlobalResponse:response];
                
                if(![msg isKindOfClass:[TL_messageEmpty class]]) {
                    block();
                } else {
                    if((flags & ShowMessageTypeUnreadMark)) {
                        [self jumpToLastMessages:YES];
                    }
                }
            }
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
             [self jumpToLastMessages:YES];
            
        } timeout:10];
        
        
    } else {
        block();
    }
    
}


-(void)selectInputTextByText:(NSString *)text {
    [self.bottomView selectInputTextByText:text];
}

- (void)setCurrentConversation:(TL_conversation *)dialog withMessageJump:(TL_localMessage *)message force:(BOOL)force {
  
    [self loadViewIfNeeded];
    
    [self hideSearchBox:NO];
    
    if(![globalAudioPlayer().delegate isKindOfClass:[TGAudioPlayerWindow class]]) {
        [globalAudioPlayer() stop];
        [globalAudioPlayer().delegate audioPlayerDidFinishPlaying:globalAudioPlayer()];
    }
    
    
    if(!self.locked &&  (((message != nil && message.channelMsgId != _jumpMessage.channelMsgId) || force) || [self.conversation.peer peer_id] != [dialog.peer peer_id] )) {
        
        self.jumpMessage = message;
        self.conversation = dialog;
        
        [Notification perform:@"ChangeDialogSelection" data:@{KEY_DIALOG:self.conversation, @"sender":self}];
        
        [self.normalNavigationCenterView enableDiscussion:NO force:NO];
        
        [_replyMsgsStack removeAllObjects];
        
        NSString *cachedText = [self.cacheTextForPeer objectForKey:dialog.cacheKey];
        [self becomeFirstResponder];
        
        [self.noMessagesView setConversation:dialog];
        
        
        _isMarkIsset = NO;
        
        [self.table.scrollView dropScrollData];
        
        [self.topInfoView setConversation:dialog];
        
        [self.jumpToBottomButton setHidden:YES];
        
        [self.typingView setDialog:dialog];
        
        [self.historyController drop:NO];
        
        [self.normalNavigationCenterView setDialog:dialog];
        
        
        [self.bottomView setDialog:dialog];
        
        
        self.historyController = [[[self hControllerClass] alloc] initWithController:self historyFilter:[self defHFClass]];
        
        self.state = MessagesViewControllerStateNone;
        
        
        [self.bottomView setInputMessageString:cachedText ? cachedText : @"" disableAnimations:YES];
        
        [self unSelectAll:NO];
        
        [self.typingReservation removeAllObjects];
        [self removeScrollEvent];
        
  
        
        if(message != nil) {
            [self showMessage:message fromMsg:nil flags:ShowMessageTypeSearch];
        } else if(dialog.last_marked_message != -1 && dialog.last_marked_message < dialog.universalTopMessage && dialog.universalTopMessage < TGMINFAKEID) {
            
            TL_localMessage *msg =  [[TL_localMessage alloc] init];
            
            msg.n_id = dialog.last_marked_message;
            msg.to_id = dialog.peer;
            
            [self showMessage:msg fromMsg:nil flags:ShowMessageTypeUnreadMark];
            
        } else {
            
           
            [self flushMessages];
            
            [self loadhistory:0 toEnd:YES prev:NO isFirst:YES];
        }
        
        [self addScrollEvent];
        
        if(self.conversation.type == DialogTypeChannel) {
            [self.historyController startChannelPolling];
           
        }
    }
}

-(void)setCurrentConversation:(TL_conversation *)dialog withMessageJump:(TL_localMessage *)message   {

    [self setCurrentConversation:dialog withMessageJump:message force:NO];
    
}


-(void)setCurrentConversation:(TL_conversation *)dialog {
    [self setCurrentConversation:dialog withMessageJump:nil];
}



- (void)cancelSelectionAndScrollToBottom {
    [self unSelectAll:NO];
    self.state = MessagesViewControllerStateNone;
    [self.table.scrollView scrollToEndWithAnimation:YES];
}

- (void)tryRead {
    if(!self.view.isHidden && self.view.window.isKeyWindow && ![TGPasslock isVisibility]) {
        if(_delayedBlockHandle)
            _delayedBlockHandle(YES);
        
        [ASQueue dispatchOnStageQueue:^{
            if(self.conversation.last_marked_message != self.conversation.top_message) {
                self.conversation.last_marked_message = self.conversation.top_message;
                self.conversation.last_marked_date = [[MTNetwork instance] getTime];
                [self.conversation save];
            }
        }];
        
       
        _delayedBlockHandle = perform_block_after_delay(0.2f, ^{
            _delayedBlockHandle = nil;
            if(self.conversation.unread_count > 0 || (self.conversation.unread_important_count > 0) || self.conversation.peer.user_id == [UsersManager currentUserId]) {
                [self readHistory:0];
            }
        });
    }
}



- (void)readHistory:(int)offset{
    if(!self.conversation || (self.conversation.unread_count == 0 && self.conversation.unread_important_count == 0) || (self.conversation.type != DialogTypeSecretChat && (self.conversation.chat.isKicked || self.conversation.chat.left)))
        return;
    
    [[DialogsManager sharedManager] markAllMessagesAsRead:self.conversation];
    
    
    
    self.conversation.unread_count = 0;
    self.conversation.unread_important_count = 0;
    _conversation.read_inbox_max_id = self.conversation.type == DialogTypeChannel ? self.conversation.top_important_message : self.conversation.top_message;
    
    [self.conversation save];
    
    [Notification perform:[Notification notificationNameByDialog:self.conversation action:@"unread_count"] data:@{KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:self.conversation],KEY_DIALOG:self.conversation}];
    
    [MessagesManager updateUnreadBadge];
        
    ReadHistroryTask *task = [[ReadHistroryTask alloc] initWithParams:@{@"conversation":self.conversation}];
    
    [TMTaskRequest addTask:task];
    
    
}

- (void)messagesLoadedTryToInsert:(NSArray *) array pos:(NSUInteger)pos next:(BOOL)next {
    
    assert([NSThread currentThread] == [NSThread mainThread]);
    
    if(array.count > 0) {
        self.locked = YES;
        
        if(self.messages.count > 1) {
        //    dispatch_async(dispatch_get_main_queue(), ^{
            
            NSRange range = [self insertMessageTableItemsToList:array startPosition:pos needCheckLastMessage:NO backItems:nil checkActive:NO];
            NSSize oldsize = self.table.scrollView.documentSize;
            NSPoint offset = self.table.scrollView.documentOffset;
            
            [self.table beginUpdates];
            [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] withAnimation:NSTableViewAnimationEffectNone];
            [self.table endUpdates];
            
            if(!next) {
                NSSize newsize = self.table.scrollView.documentSize;
                
                [self.table.scrollView scrollToPoint:NSMakePoint(0, newsize.height - oldsize.height + offset.y) animation:NO];
            }
            
            [self didUpdateTable];
            self.locked = NO;
            
            
            
           // });
        } else {
             [self insertMessageTableItemsToList:array startPosition:pos needCheckLastMessage:NO backItems:nil checkActive:NO];
            [self.table reloadData];
            [self didUpdateTable];
            self.locked = NO;
            
        }
    } else {
        [self didUpdateTable];
    }
    
    
    if(_conversation.user.isBot && _historyController.nextState == ChatHistoryStateFull) {
        
        [[FullUsersManager sharedManager] loadUserFull:_conversation.user callback:^(TL_userFull *userFull) {
            
            if(userFull.bot_info.n_description.length > 0) {
                TL_localMessageService *service = [TL_localMessageService createWithFlags:0 n_id:0 from_id:0 to_id:_conversation.peer date:0 action:[TL_messageActionBotDescription createWithTitle:userFull.bot_info.n_description] fakeId:0 randomId:rand_long() dstate:DeliveryStateNormal];
                
                NSArray *items;
                
                NSRange range = [self insertMessageTableItemsToList:[self messageTableItemsFromMessages:@[service]] startPosition:_messages.count needCheckLastMessage:YES backItems:&items checkActive:NO];
                [self.table beginUpdates];
                [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] withAnimation:NSTableViewAnimationEffectNone];
                [self.table endUpdates];
                
                
                [self didUpdateTable];
            }
            
        }];
        
    }
}


- (void)didUpdateTable {
    [self showNoMessages:self.messages.count == 1 || (self.conversation.user.isBot && self.messages.count == 2 && [self.messages[1] isKindOfClass:[MessageTableItemServiceMessage class]])];
    
    
    if(self.conversation.user.isBot &&  (self.messages.count == 1 || (self.messages.count == 2 && [self.messages[1] isKindOfClass:[MessageTableItemServiceMessage class]]))) {
        [self showBotStartButton:@"start" bot:self.conversation.user];
    } else if(self.conversation.user.isBot) {
        [self.bottomView setStateBottom:MessagesBottomViewNormalState];
    }
    
    BOOL isHaveMessages = NO;
    for(MessageTableItem *item in self.messages) {
        if(item.message && !item.message.action) {
            isHaveMessages = YES;
            break;
        }
    }
    
    if(!isHaveMessages) {
        [self.normalNavigationLeftView setDisable:YES];
    } else {
        [self.normalNavigationLeftView setDisable:NO];
    }
    
    [self updateScrollBtn];
    
    [self.table setNeedsDisplay:YES];
    [self.table display];
    
    
    if(self.conversation.type == DialogTypeUser && (self.conversation.user.type == TLUserTypeRequest)) {
        
        __block BOOL showReport = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"showreport_%d",self.conversation.user.n_id]];
        
        __block BOOL alwaysShowReport = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"always_showreport1_%d",self.conversation.user.n_id]];
        
        if(self.messages.count > 1 && (!showReport && !alwaysShowReport)) {
            if(self.messages.count > 2 || self.historyController.nextState == ChatHistoryStateFull) {
                
                showReport = YES;
                
                [self.messages enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, self.messages.count - 1)] options:0 usingBlock:^(MessageTableItem*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if(obj.message.n_out) {
                        showReport = NO;
                        *stop = YES;
                    }
                    
                }];
                
                alwaysShowReport = showReport;
                
                [[NSUserDefaults standardUserDefaults] setBool:showReport forKey:[NSString stringWithFormat:@"showreport_%d",self.conversation.user.n_id]];
            }
        }
        
        if(showReport) {
            [_topInfoView setConversation:self.conversation];
        }
        
    }
    
}

-(void)requestNextHistory {
    [self loadhistory:0 toEnd:NO prev:NO isFirst:NO];
}

- (void)loadhistory:(int)message_id toEnd:(BOOL)toEnd prev:(BOOL)prev isFirst:(BOOL)isFirst {
    if(!self.conversation || _locked)
        return;
    

    NSSize size = self.table.scrollView.documentSize;
    
    int count = size.height/20;
    
    self.historyController.selectLimit = isFirst ? count : 50;
    
     [self removeScrollEvent];
    
    _needNextRequest = NO;
    
    
    
    [self.historyController request:!prev anotherSource:YES sync:isFirst selectHandler:^(NSArray *prevResult, NSRange range1, id controller) {
        
        NSUInteger pos = prev ? 0 : self.messages.count;
        
        if(self.historyController == controller) {
            [self messagesLoadedTryToInsert:prevResult pos:pos next:!prev];
            
            if(self.didUpdatedTable) {
                self.didUpdatedTable();
            }
            
            if(prevResult.count+1 < 10 && prevResult.count > 0) {
                [self loadhistory:0 toEnd:YES prev:prev isFirst:NO];
            }
            
            [self addScrollEvent];
        }

    }];
}

-(void)scrollToRect:(NSRect)rect isCenter:(BOOL)isCenter animated:(BOOL)animated {
    
    if(isCenter) {
        rect.origin.y += roundf((self.table.containerView.frame.size.height - rect.size.height) / 2) ;
    }
    
    if(self.table.scrollView.documentSize.height > NSHeight(self.table.containerView.frame))
        rect.origin.y-=NSHeight(self.table.scrollView.frame)-rect.size.height;
    
    if(rect.origin.y < 0)
        rect.origin.y = 0;
    
    [self.table.scrollView scrollToPoint:rect.origin animation:animated];
    
    
    [self updateScrollBtn];
    
}


- (void)scrollToUnreadItem:(BOOL)animated {
    
    if(self.unreadMark != nil) {
        [self scrollToItem:self.unreadMark animated:animated centered:NO highlight:NO];
    }
}

- (void)scrollToItem:(MessageTableItem *)item animated:(BOOL)animated centered:(BOOL)centered highlight:(BOOL)highlight {
    
    if(item) {
        NSUInteger index = [self indexOfObject:item];
        
        NSRect rect = [self.table rectOfRow:index];
        
        
        
    //
        
        if(centered) {
            if(self.table.scrollView.documentOffset.y > rect.origin.y)
                rect.origin.y -= roundf((self.table.containerView.frame.size.height - rect.size.height) / 2) ;
            else
                rect.origin.y += roundf((self.table.containerView.frame.size.height - rect.size.height) / 2) ;
            
            [self.table.scrollView.clipView scrollRectToVisible:rect animated:animated completion:^(BOOL scrolled) {
                if(highlight) {
                    
                    if(index != NSNotFound) {
                        MessageTableCellContainerView *cell = (MessageTableCellContainerView *)[self cellForRow:index];
                        
                        if(cell && [cell isKindOfClass:[MessageTableCellContainerView class]]) {
                            
                            for(int i = 0; i < self.messages.count; i++) {
                                MessageTableCellContainerView *cell2 = (MessageTableCellContainerView *)[self cellForRow:i];
                                if(cell2 && [cell2 isKindOfClass:[MessageTableCellContainerView class]]) {
                                    [cell2 stopSearchSelection];
                                }
                            }
                            
                            
                            [cell searchSelection];
                        }
                    }
                    
                    [self updateScrollBtn];
                }
            }];

        } else {
            [self scrollToRect:rect isCenter:centered animated:animated];
        }
        
    }
}


- (NSArray *)messageTableItemsFromMessages:(NSArray *)input{
    NSMutableArray *array = [NSMutableArray array];
    for(TLMessage *message in input) {
        MessageTableItem *item = [MessageTableItem messageItemFromObject:message];
        if(item) {
            //[item makeSizeByWidth:self.table.containerSize.width];
            item.isSelected = NO;
            [array addObject:item];
        }
    }
    return array;
}


- (NSRange)insertMessageTableItemsToList:(NSArray *)array startPosition:(NSInteger)pos needCheckLastMessage:(BOOL)needCheckLastMessage backItems:(NSArray **)back checkActive:(BOOL)checkActive {
    assert([NSThread isMainThread]);
    
    
   // if(pos != 1)
   //     return NSMakeRange(pos, 0);
    
    if(![[NSApplication sharedApplication] isActive] && checkActive) {
        
        if(!self.unreadMark) {
            _unreadMark = [[MessageTableItemUnreadMark alloc] initWithCount:0 type:RemoveUnreadMarkNoneType];
            if(array.count > 0)
                array = [array arrayByAddingObjectsFromArray:@[_unreadMark]];
        }
    }
    
 //   [self.table beginUpdates];
    
    if(back != NULL)
        *back = array;
    
    if(pos > self.messages.count)
        pos = self.messages.count-1;
    
    
    if(pos == 0)
        pos++;
    
    
    [self.messages insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(pos, array.count)]];
    
    
    NSInteger max = MIN(pos + array.count + 1, self.messages.count );
    
    __block MessageTableItem *backItem = max == self.messages.count ? nil : self.messages[max - 1];
    
    
    NSRange range = NSMakeRange(0, backItem ? max - 1 : max);
    
    NSMutableIndexSet *rld = [[NSMutableIndexSet alloc] init];
    
    
    
    [self.messages enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:NSEnumerationReverse usingBlock:^(MessageTableItem *current, NSUInteger idx, BOOL *stop) {
        
        
        [current setTable:_table];
        [backItem setTable:_table];
        
        BOOL isCHdr = current.isHeaderMessage;
        BOOL isCFwdHdr = current.isHeaderForwardedMessage;

        BOOL isBHdr = backItem.isHeaderMessage;
        BOOL isBFwdHdr = backItem.isHeaderForwardedMessage;
        
        
        [self isHeaderMessage:current prevItem:backItem];
        
        
        if(pos != 1 && idx < pos) {
            if(isCHdr != current.isHeaderMessage ||
               isCFwdHdr != current.isHeaderForwardedMessage)
            {
                [rld addIndex:idx];
            }
            
            if(isBHdr != backItem.isHeaderMessage ||
               isBFwdHdr != backItem.isHeaderForwardedMessage) {
                [rld addIndex:idx-1];
            }
        }
        
        
        [current makeSizeByWidth:current.makeSize];
        [backItem makeSizeByWidth:backItem.makeSize];
        backItem = current;
        
    }];
    
    
    if(rld.count > 0)
    {
        [[NSAnimationContext currentContext] setDuration:0];
        [self.table noteHeightOfRowsWithIndexesChanged:rld];
        [self.table reloadDataForRowIndexes:rld columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    }
    

    if(needCheckLastMessage && pos > 1) {
        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, pos - 2)];
        [[NSAnimationContext currentContext] setDuration:0];
        [self.table noteHeightOfRowsWithIndexesChanged:set];
        [self.table reloadDataForRowIndexes:set columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    }
    
   // [self.table endUpdates];
    
    
    [self tryRead];
    
    
    return NSMakeRange(pos, array.count);
}




- (void)isHeaderMessage:(MessageTableItem *)item prevItem:(MessageTableItem *)prevItem {
    if([item isKindOfClass:[MessageTableItemTyping class]] || [item isKindOfClass:[MessageTableItemUnreadMark class]])
        return;
    
    item.isHeaderMessage = YES;
    item.isHeaderForwardedMessage = YES;
    
    if(item.message.isChannelMessage && item.message.from_id == 0) {
        return;
    }
    
    if(prevItem.message && item.message && ![item isReplyMessage] && (!item.message.media.webpage || [item.message.media.webpage isKindOfClass:[TL_webPageEmpty class]])) {
        if(!prevItem.message.action && !item.message.action) {
            if(prevItem.message.from_id == item.message.from_id && ABS(prevItem.message.date - item.message.date) < HEADER_MESSAGES_GROUPING_TIME) {
                item.isHeaderMessage = NO;
            }
            
            if(!item.isHeaderMessage && prevItem.isForwadedMessage && ABS(prevItem.message.fwd_date - item.message.fwd_date) < HEADER_MESSAGES_GROUPING_TIME) {
                item.isHeaderForwardedMessage = NO;
            }
        }
    }
    
}

- (void)deleteItem:(MessageTableItem *)item {
    
    NSUInteger row = [self.messages indexOfObject:item];
    if(row != NSNotFound) {
        [self.messages removeObjectAtIndex:row];
        [self.selectedMessages removeObject:item];
        
        [self.table beginUpdates];
        
        [self.table removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationEffectFade];
        
        [self.table endUpdates];
        
        [item clean];
    }
}

- (void)resendItem:(MessageTableItem *)item {
    NSUInteger row = [self indexOfObject:item];
    if(row != NSNotFound) {
        item.message.date = [[MTNetwork instance] getTime];
        [item.message save:YES];
        
        
        
        [item rebuildDate];
        
        [self.table beginUpdates];
        
        NSUInteger nRow = 1;
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:nRow];
        if(row != 0) {
            
            [self.messages removeObjectAtIndex:row];
            
            [self.messages insertObject:item atIndex:nRow];
            
            
            [self isHeaderMessage:item prevItem:[self.messages objectAtIndex:MIN(self.messages.count-1,nRow+1)]];
            
            if(row != nRow)
                [self.table moveRowAtIndex:row toIndex:nRow];
            
            [self.table noteHeightOfRowsWithIndexesChanged:set];
            
        }
        
        
        [self.table reloadDataForRowIndexes:set columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        [item.messageSender addEventListener:self.historyController];
        [item.messageSender send];
        
        [self.table endUpdates];
    }
}

- (MessageTableItem *)firstMessageItem {
    for(MessageTableItem *object in self.messages) {
        if(object.message.n_id != 0)
            return object;
    }
    return nil;
}

- (MessageTableItem *)lastMessageItem {
    NSUInteger count = self.messages.count;
    for(NSUInteger i = count-1; i != NSUIntegerMax; i--) {
        id object = [self.messages objectAtIndex:i];
        if([object isKindOfClass:[MessageTableItem class]] && ![object isKindOfClass:[MessageTableItemTyping class]]) {
            return object;
        }
    }
    return nil;
}

-(void)setConversation:(TL_conversation *)conversation {
    _conversation = conversation;
}

- (void)sendMessage {
    NSString *message = [self.bottomView.inputMessageString trim];
    
    
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([[message stringByTrimmingCharactersInSet: set] length] == 0) {
        return;
    } else if([message stringByReplacingOccurrencesOfString:@"\n" withString:@""].length == 0) {
        return;
    }
    
    
#ifdef  TGDEBUG
    if([message isEqualToString:@"send100messages"]) {
        
        TL_conversation *conversation = _conversation;
        for (int i = 1; i <= 100; i++) {
            [self sendMessage:[NSString stringWithFormat:@"messageId:%d",i] forConversation:conversation];
        }
        
        return;
    }
    
#endif
    
    if(!self.conversation.canSendMessage)  {
        NSBeep();
        return;
    }
    
    if(message.length > 0) {
        
        
        [self.bottomView setInputMessageString:@"" disableAnimations:NO];
        [self sendMessage:message forConversation:self.conversation callback:^{
            [_typingReservation removeAllObjects];
        }];
        
    }
}

-(void)sendMessage:(NSString *)message forConversation:(TL_conversation *)conversation {
    [self sendMessage:message forConversation:conversation callback:nil];
}



- (void)sendMessage:(NSString *)message forConversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback {
    
    if(!conversation.canSendMessage)
        return;
    
    BOOL noWebpage = [self noWebpage:message];
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    
    if([SettingsArchiver checkMaskedSetting:EmojiReplaces])
        message = [message replaceSmilesToEmoji];
    
    NSArray *array = [message getEmojiFromString:YES];
    if(array.count > 0) {
        [[EmojiViewController instance] saveEmoji:array];
    }
    
    [Telegram saveHashTags:message peer_id:0];
    
    [self readHistory:0];
    
    [ASQueue dispatchOnStageQueue:^{
        
        
        Class cs = conversation.type == DialogTypeSecretChat ? [MessageSenderSecretItem class] : [MessageSenderItem class];
        
        static const NSInteger messagePartLimit = 4096;
        NSMutableArray *preparedItems = [[NSMutableArray alloc] init];
        
        if (message.length <= messagePartLimit) {
            MessageSenderItem *sender = [[cs alloc] initWithMessage:message forConversation:conversation noWebpage:noWebpage additionFlags:self.senderFlags];
            sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
            [self.historyController addItem:sender.tableItem conversation:conversation callback:callback sentControllerCallback:nil];
            
        }
        
        else
        {
            for (NSUInteger i = 0; i < message.length; i += messagePartLimit)
            {
                NSString *substring = [message substringWithRange:NSMakeRange(i, MIN(messagePartLimit, message.length - i))];
                if (substring.length != 0) {
                    
                    MessageSenderItem *sender = [[cs alloc] initWithMessage:substring forConversation:conversation noWebpage:noWebpage  additionFlags:self.senderFlags];
                    sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
                    
                    [preparedItems insertObject:sender.tableItem atIndex:0];
                    
                    
                }
                
            }
            
            [self.historyController addItems:preparedItems conversation:conversation callback:callback sentControllerCallback:nil];
        }
        
        [self performForward:self.conversation];
        
    }];
}


- (void)sendLocation:(CLLocationCoordinate2D)coordinates forConversation:(TL_conversation *)conversation {
    if(!conversation.canSendMessage)
        return;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ASQueue dispatchOnStageQueue:^{
        
        Class cs = self.conversation.type == DialogTypeSecretChat ? [LocationSenderItem class] : [LocationSenderItem class];
        
        LocationSenderItem *sender = [[cs alloc] initWithCoordinates:coordinates conversation:conversation additionFlags:self.senderFlags];
        sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
        [self.historyController addItem:sender.tableItem];
        
    }];
    
}

- (void)sendVideo:(NSString *)file_path forConversation:(TL_conversation *)conversation {
    [self sendVideo:file_path forConversation:conversation addCompletionHandler:nil];
}

-(void)sendVideo:(NSString *)file_path forConversation:(TL_conversation *)conversation addCompletionHandler:(dispatch_block_t)completeHandler {
    if(!conversation.canSendMessage) return;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ASQueue dispatchOnStageQueue:^{
        SenderItem *sender;
        
        if(!check_file_size(file_path)) {
            alert_bad_files(@[[file_path lastPathComponent]]);
            return;
        }
        
        if(self.conversation.type == DialogTypeSecretChat) {
            sender = [[FileSecretSenderItem alloc] initWithPath:file_path uploadType:UploadVideoType forConversation:conversation];
        } else {
            sender = [[VideoSenderItem alloc] initWithPath:file_path forConversation:conversation additionFlags:self.senderFlags];
        }
        sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
        [self.historyController addItem:sender.tableItem sentControllerCallback:completeHandler];
    }];
}

- (void)sendDocument:(NSString *)file_path forConversation:(TL_conversation *)conversation {
    [self sendDocument:file_path forConversation:conversation addCompletionHandler:nil];
}


- (void)sendDocument:(NSString *)file_path forConversation:(TL_conversation *)conversation addCompletionHandler:(dispatch_block_t)completeHandler {
    if(!conversation.canSendMessage) return;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ASQueue dispatchOnStageQueue:^{
        
        if(!check_file_size(file_path)) {
            alert_bad_files(@[[file_path lastPathComponent]]);
            return;
        }
        
        SenderItem *sender;
        if(self.conversation.type == DialogTypeSecretChat) {
            sender = [[FileSecretSenderItem alloc] initWithPath:file_path uploadType:UploadDocumentType forConversation:conversation];
        } else {
            sender = [[DocumentSenderItem alloc] initWithPath:file_path forConversation:conversation additionFlags:self.senderFlags];
        }
        
        sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
        [self.historyController addItem:sender.tableItem sentControllerCallback:completeHandler];
    }];
}


-(void)sendSticker:(TLDocument *)sticker forConversation:(TL_conversation *)conversation addCompletionHandler:(dispatch_block_t)completeHandler {
    if(!conversation.canSendMessage) return;
    
    if(self.conversation.type == DialogTypeSecretChat && self.conversation.encryptedChat.encryptedParams.layer < 23)
        return;
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        NSMutableDictionary *sc = [transaction objectForKey:@"stickersUsed" inCollection:STICKERS_COLLECTION];
        
        if(!sc)
        {
            sc = [[NSMutableDictionary alloc] init];
        }
        
        sc[@(sticker.n_id)] = @([sc[@(sticker.n_id)] intValue]+1);
        
        [transaction setObject:sc forKey:@"stickersUsed" inCollection:STICKERS_COLLECTION];
        
    }];
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [self.bottomView closeEmoji];
    
    
    [ASQueue dispatchOnStageQueue:^{
        
        
        SenderItem *sender;
        
        if(self.conversation.type != DialogTypeSecretChat) {
            sender = [[StickerSenderItem alloc] initWithDocument:sticker forConversation:conversation additionFlags:self.senderFlags];
        } else {
            sender = [[ExternalDocumentSecretSenderItem alloc] initWithConversation:conversation document:sticker];
        }
        
       
        sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
        [self.historyController addItem:sender.tableItem sentControllerCallback:completeHandler];
        
    }];
    
}


- (void)sendAudio:(NSString *)file_path forConversation:(TL_conversation *)conversation {
    
    if(!conversation.canSendMessage) return;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ASQueue dispatchOnStageQueue:^{
        
        if(!check_file_size(file_path)) {
            alert_bad_files(@[[file_path lastPathComponent]]);
            return;
        }
        
        SenderItem *sender;
        if(self.conversation.type == DialogTypeSecretChat) {
            sender = [[FileSecretSenderItem alloc] initWithPath:file_path uploadType:UploadAudioType forConversation:conversation];
        } else {
            sender = [[AudioSenderItem alloc] initWithPath:file_path forConversation:conversation additionFlags:self.senderFlags];
        }
        
        sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
        [self.historyController addItem:sender.tableItem];
    }];
}

- (void)forwardMessages:(NSArray *)messages conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback {
    
    if(!conversation.canSendMessage)
        return;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ASQueue dispatchOnStageQueue:^{
        
        
        void (^fwd_blck) (NSArray *fwd_msgs) = ^(NSArray *fwd_messages) {
            ForwardSenterItem *sender = [[ForwardSenterItem alloc] initWithMessages:fwd_messages forConversation:conversation additionFlags:self.senderFlags];
            sender.tableItems = [[self messageTableItemsFromMessages:sender.fakes] reversedArray];
            [self.historyController addItems:sender.tableItems conversation:conversation callback:callback sentControllerCallback:nil];
        };
        
        
        if(messages.count < 50) {
            fwd_blck(messages);
        } else {
            
            NSMutableArray *copy = [messages mutableCopy];
            
            while (copy.count > 0) {
                
                NSArray *fwd = [copy subarrayWithRange:NSMakeRange(0, MIN(copy.count,50))];
                
                [copy removeObjectsInArray:fwd];
                
                fwd_blck(fwd);
                
                
            }
        }
        
        
        
    }];
}

- (void)shareContact:(TLUser *)contact forConversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback  {
    
    if(!self.conversation.canSendMessage) return;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ASQueue dispatchOnStageQueue:^{
        
        ShareContactSenterItem *sender = [[ShareContactSenterItem alloc] initWithContact:contact forConversation:conversation additionFlags:self.senderFlags];
        
        sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
        [self.historyController addItem:sender.tableItem conversation:conversation callback:callback sentControllerCallback:nil];
    }];
}

- (void)sendSecretTTL:(int)ttl forConversation:(TL_conversation *)conversation {
    [self sendSecretTTL:ttl forConversation:conversation callback:nil];
}

- (void)sendSecretTTL:(int)ttl forConversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback {
    
    if(!conversation.canSendMessage || conversation.type != DialogTypeSecretChat) {
        if(callback) callback();
        return;
    }
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    NSUInteger lastTTL = [EncryptedParams findAndCreate:conversation.peer.peer_id].ttl;
    
    if(lastTTL == -1 || lastTTL != ttl ) {
        
        [ASQueue dispatchOnStageQueue:^{
            
            SetTTLSenderItem *sender = [[SetTTLSenderItem alloc] initWithConversation:conversation ttl:ttl];
            
            sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
            
            [self.historyController addItem:sender.tableItem conversation:conversation callback:callback sentControllerCallback:nil];
        }];
        
    } else if(callback) callback();
}


- (void)sendImage:(NSString *)file_path forConversation:(TL_conversation *)conversation file_data:(NSData *)data {
    [self sendImage:file_path forConversation:conversation file_data:data isMultiple:YES addCompletionHandler:nil];
}

- (void)sendAttachments:(NSArray *)attachments forConversation:(TL_conversation *)conversation addCompletionHandler:(dispatch_block_t)completeHandler {
    if(!conversation.canSendMessage || conversation.type == DialogTypeSecretChat)
        return;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ASQueue dispatchOnStageQueue:^{
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        [attachments enumerateObjectsUsingBlock:^(TGAttachObject *obj, NSUInteger idx, BOOL *stop) {
            
            SenderItem *sender = [[[obj senderClass] alloc] initWithConversation:conversation attachObject:obj additionFlags:self.senderFlags];
            
            
            sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
            [items addObject:sender.tableItem];
 
        }];
        
       
        [self.historyController addItems:items conversation:conversation sentControllerCallback:completeHandler];
        
        
    }];
}

- (void)addImageAttachment:(NSString *)file_path forConversation:(TL_conversation *)conversation file_data:(NSData *)data addCompletionHandler:(dispatch_block_t)completeHandler {
    if(self.conversation.type == DialogTypeSecretChat || (!file_path && !data))
        return;
    
    [[Storage yap] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        NSMutableArray *attachments = [transaction objectForKey:conversation.cacheKey inCollection:ATTACHMENTS];
        
        if(!attachments) {
            attachments = [[NSMutableArray alloc] init]; 
        }
        
        TGAttachObject *attach = [[TGAttachObject alloc] initWithOriginFile:file_path orData:data peer_id:conversation.peer_id];
        
        [attachments addObject:attach];
        
        [transaction setObject:attachments forKey:conversation.cacheKey inCollection:ATTACHMENTS];
        
        [ASQueue dispatchOnMainQueue:^{
            
            [self.bottomView addAttachment:[[TGImageAttachment alloc] initWithItem:attach]];
            
            if(completeHandler) completeHandler();
        }];
        
    }];
    
}


-(void)sendImage:(NSString *)file_path forConversation:(TL_conversation *)conversation file_data:(NSData *)data isMultiple:(BOOL)isMultiple addCompletionHandler:(dispatch_block_t)completeHandler {
    if(!conversation.canSendMessage)
        return;
    
    if(self.conversation.type != DialogTypeSecretChat && (isMultiple || self.bottomView.attachmentsCount > 0)) {
        [self addImageAttachment:file_path  forConversation:conversation file_data:data addCompletionHandler:completeHandler];
        
        return;
    }

    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ASQueue dispatchOnStageQueue:^{
        
        
        NSImage *originImage;
        
        if(data) {
            originImage = [[NSImage alloc] initWithData:data];
        } else {
            originImage = imageFromFile(file_path);
        }
        
        
        
        originImage = prettysize(originImage);
        
        
        
        if(originImage.size.width / 10 > originImage.size.height) {
            
            NSString *path = file_path;
            
            
            if(!file_path) {
                path = exportPath(rand_long(), @"jpg");
                [data writeToFile:path atomically:YES];
            }
            
           
            [ASQueue dispatchOnMainQueue:^{
                [self sendDocument:path forConversation:conversation addCompletionHandler:completeHandler];
            }];
            
            
            return;
        }
        
        
        originImage = strongResize(originImage, 1280);
        
        
        NSData *imageData = jpegNormalizedData(originImage);
        
        

        MTLog(@"imageSize: %ld kb",imageData.length / 1024);
        
        
       
        SenderItem *sender;
        
        if(self.conversation.type == DialogTypeSecretChat) {
            sender = [[FileSecretSenderItem alloc] initWithImage:originImage uploadType:UploadImageType forConversation:conversation];
        } else {
            sender = [[ImageSenderItem alloc] initWithImage:originImage jpegData:imageData forConversation:conversation additionFlags:self.senderFlags];
        }
        
        sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
        [self.historyController addItem:sender.tableItem sentControllerCallback:completeHandler];
    }];
}


- (void)addReplayMessage:(TL_localMessage *)message animated:(BOOL)animated {
    
    if((message.to_id.class == [TL_peerChannel class] || message.to_id.class == [TL_peerChat class] || message.to_id.class == [TL_peerUser class]) && message.peer_id == _conversation.peer_id)  {
        [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            
            [transaction setObject:message forKey:self.conversation.cacheKey inCollection:REPLAY_COLLECTION];
            
        }];
        
        [self.bottomView updateReplayMessage:YES animated:animated];
        
        if(self.navigationViewController.currentController != self)
        {
            [self setCurrentConversation:message.conversation];
            [self.navigationViewController gotoViewController:self];
        }
    }
}

-(void)removeReplayMessage:(BOOL)update animated:(BOOL)animated {
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        [transaction removeObjectForKey:self.conversation.cacheKey inCollection:REPLAY_COLLECTION];
        
    }];
    
    
    [self.bottomView updateReplayMessage:update animated:animated];
}


-(TL_localMessage *)replyMessage {
    
    __block TL_localMessage *replyMessage;
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        replyMessage = [transaction objectForKey:self.conversation.cacheKey inCollection:REPLAY_COLLECTION];
        
    }];
    
    return replyMessage;
    
}


-(int)senderFlags {
    if(self.conversation.type != DialogTypeChannel)
        return self.historyController.filter.additionSenderFlags;
    
    return [self.bottomView sendMessageAsAdmin] ? self.historyController.filter.additionSenderFlags : self.conversation.canSendChannelMessageAsUser ? 0 : self.historyController.filter.additionSenderFlags;
}

-(void)markAsNoWebpage {
    
    _noWebpageString = [self.inputText webpageLink];
    
    [self checkWebpage:nil];
    
}

-(BOOL)noWebpage:(NSString *)message {
    return [_noWebpageString isEqualToString:[message webpageLink]];
}

-(void)checkWebpage:(NSString *)link {
    
    if(self.conversation.type == DialogTypeSecretChat || self.conversation.type == DialogTypeBroadcast)
        return;
    
    
    if([link isEqualToString:_noWebpageString] && _noWebpageString != nil)
    {
        [self updateWebpage];
        return;
    }
    
    
    __block TLWebPage *localWebpage =  [Storage findWebpage:link];
    
    if((!localWebpage || ![localWebpage isKindOfClass:[TL_webPageEmpty class]]) && link && ![localWebpage isKindOfClass:[TL_webPage class]]) {
        
        [_webPageRequest cancelRequest];
        
        _webPageRequest = [RPCRequest sendRequest:[TLAPI_messages_getWebPagePreview createWithMessage:link] successHandler:^(RPCRequest *request, TL_messageMediaWebPage *response) {
            
            if([response isKindOfClass:[TL_messageMediaWebPage class]]) {
                
                [Storage addWebpage:response.webpage forLink:link];
                
                if(![response.webpage isKindOfClass:[TL_webPageEmpty class]] && _webPageRequest) {
                    
                    [self updateWebpage];
                    
                }
            } else if([response isKindOfClass:[TL_messageMediaEmpty class]]) {
                [Storage addWebpage:[TL_webPageEmpty createWithN_id:0] forLink:link];
            }
            
            
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
        }];
        
    } else  {
        [self updateWebpage];
    }
    
    
}


-(void)updateWebpage {
    [self.bottomView updateWebpage:YES];
}


//Table methods

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return self.messages.count;
}

- (BOOL) tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}

- (CGFloat) tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    MessageTableItem *item = [self.messages objectAtIndex:row];
    return item.viewSize.height;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    
    
//    NSDate *methodStart = [NSDate date];
//    
//    /* ... Do whatever you need to do ... */
//    
//    NSDate *methodFinish = [NSDate date];
//    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
//    MTLog(@"executionTime = %f", executionTime);
    
    MessageTableItem *item = [self.messages objectAtIndex:row];
    MessageTableCell *cell = nil;
    
    if(item.message.hole != nil) {
        
        static NSString *const kRowIdentifier = @"holeItem";
        cell = [self.table makeViewWithIdentifier:kRowIdentifier owner:self];
        if(!cell) {
            cell = [[MessageTableCellHoleView alloc] initWithFrame:self.view.bounds];
            cell.identifier = kRowIdentifier;
            cell.messagesViewController = self;
        }
        
    } else if(item.class == [MessageTableItemServiceMessage class]) {
        
        static NSString *const kRowIdentifier = @"service";
        cell = [self.table makeViewWithIdentifier:kRowIdentifier owner:self];
        if(!cell) {
            cell = [[MessageTableCellServiceMessage alloc] initWithFrame:self.view.bounds];
            cell.identifier = kRowIdentifier;
            cell.messagesViewController = self;
        }
    } else if(item.class == [MessageTableItemText class]) {
        static NSString *const kRowIdentifier = @"text";
        cell = [self.table makeViewWithIdentifier:kRowIdentifier owner:self];
        
        
        if(!cell) {
            cell = [[MessageTableCellTextView alloc] initWithFrame:self.view.bounds];
            cell.identifier = kRowIdentifier;
            cell.messagesViewController = self;
            
        }
        
    } else if(item.class == [MessageTableItemPhoto class]) {
        static NSString *const kRowIdentifier = @"photo";
        cell = [self.table makeViewWithIdentifier:kRowIdentifier owner:self];
        if(!cell) {
            cell = [[MessageTableCellPhotoView alloc] initWithFrame:self.view.bounds];
            cell.identifier = kRowIdentifier;
            cell.messagesViewController = self;
        }
    } else if(item.class == [MessageTableItemVideo class]) {
        static NSString *const kRowIdentifier = @"video";
        cell = [self.table makeViewWithIdentifier:kRowIdentifier owner:self];
        if(!cell) {
            cell = [[MessageTableCellVideoView alloc] initWithFrame:self.view.bounds];
            cell.identifier = kRowIdentifier;
            cell.messagesViewController = self;
        }
    } else if(item.class == [MessageTableItemGeo class]) {
        static NSString *const kRowIdentifier = @"geo";
        cell = [self.table makeViewWithIdentifier:kRowIdentifier owner:self];
        if(!cell) {
            cell = [[MessageTableCellGeoView alloc] initWithFrame:self.view.bounds];
            cell.identifier = kRowIdentifier;
            cell.messagesViewController = self;
        }
    } else if(item.class == [MessageTableItemContact class]) {
        static NSString *const kRowIdentifier = @"contact";
        cell = [self.table makeViewWithIdentifier:kRowIdentifier owner:self];
        if(!cell) {
            cell = [[MessageTableCellContactView alloc] initWithFrame:self.view.bounds];
            cell.identifier = kRowIdentifier;
            cell.messagesViewController = self;
        }
    } else if(item.class == [MessageTableItemAudio class]) {
        static NSString *const kRowIdentifier = @"audio";
        cell = [self.table makeViewWithIdentifier:kRowIdentifier owner:self];
        if(!cell) {
            cell = [[MessageTableCellAudioView alloc] initWithFrame:self.view.bounds];
            cell.identifier = kRowIdentifier;
            cell.messagesViewController = self;
        }
    } else if(item.class == [MessageTableItemGif class]) {
        static NSString *const kRowIdentifier = @"gif";
        cell = [self.table makeViewWithIdentifier:kRowIdentifier owner:self];
        if(!cell) {
            cell = [[MessageTableCellGifView alloc] initWithFrame:self.view.bounds];
            cell.identifier = kRowIdentifier;
            cell.messagesViewController = self;
        }
    } else if(item.class == [MessageTableItemDocument class]) {
        static NSString *const kRowIdentifier = @"document";
        cell = [self.table makeViewWithIdentifier:kRowIdentifier owner:self];
        if(!cell) {
            cell = [[MessageTableCellDocumentView alloc] initWithFrame:self.view.bounds];
            cell.identifier = kRowIdentifier;
            cell.messagesViewController = self;
        }
    } else if(item.class == [MessageTableItemAudioDocument class]) {
        static NSString *const kRowIdentifier = @"auido_document";
        cell = [self.table makeViewWithIdentifier:kRowIdentifier owner:self];
        if(!cell) {
            cell = [[MessageTablecellAudioDocumentView alloc] initWithFrame:self.view.bounds];
            cell.identifier = kRowIdentifier;
            cell.messagesViewController = self;
        }
    } else if(item.class == [MessageTableItemUnreadMark class]) {
        static NSString *const kRowIdentifier = @"unread_mark_cell";
        cell = [self.table makeViewWithIdentifier:kRowIdentifier owner:self];
        
        if(!cell) {
            cell = [[MessageTableCellUnreadMarkView alloc] initWithFrame:self.view.bounds];
            cell.identifier = kRowIdentifier;
            cell.messagesViewController = self;
        }
    } else if(item.class == [MessageTableItemSocial class]) {
      
        static NSString *const kRowIdentifier = @"social_cell";
        cell = [self.table makeViewWithIdentifier:kRowIdentifier owner:self];
        
        if(!cell) {
            cell = [[MessageTableCellSocialView alloc] initWithFrame:self.view.bounds];
            cell.identifier = kRowIdentifier;
            cell.messagesViewController = self;
        }

        
    } else if(item.class == [MessageTableItemSticker class]) {
        
        static NSString *const kRowIdentifier = @"sticker_cell";
        cell = [self.table makeViewWithIdentifier:kRowIdentifier owner:self];
        
        if(!cell) {
            cell = [[MessageTableCellStickerView alloc] initWithFrame:self.view.bounds];
            cell.identifier = kRowIdentifier;
            cell.messagesViewController = self;
        }
        
        
    } else if(!(item.class == [MessageTableCellServiceMessage class]) && !(item.class == [MessageTableItemTyping class])) {
        
        assert(NO);
        
        static NSString *const kRowIdentifier = @"else";
        cell = (MessageTableCellContainerView *)[self.table makeViewWithIdentifier:kRowIdentifier owner:self];
        if(!cell) {
            cell = [[MessageTableCellContainerView alloc] initWithFrame:self.view.bounds];
            cell.identifier = kRowIdentifier;
            cell.messagesViewController = self;
        }
        
    } else if([item isKindOfClass:[MessageTableItemTyping class]]) {
        return self.typingView;
    }
    
    NSDate *start = [NSDate new];
    
    [cell setItem:item];
   
    
    if([cell isKindOfClass:[MessageTableCellContainerView class]]) {
        MessageTableCellContainerView *containerView = (MessageTableCellContainerView *)cell;
        [containerView setEditable:self.state == MessagesViewControllerStateEditable animation:NO];
    }
    
    double time = ABS([start timeIntervalSinceNow]);
    if(time > 0.010) {
        MTLog(@"cell #%@, %f", NSStringFromClass([cell class]), time);
    }
    
    return cell;
}


- (void)backOrClose:(NSMenuItem *)sender {
    if(self.state == MessagesViewControllerStateEditable) {
        [self unSelectAll];
    } else {
        [[Telegram rightViewController] navigationGoBack];
    }
}

- (MessageTableItem *)objectAtIndex:(NSUInteger)position {
    return [self.messages objectAtIndex:position];
}

- (NSUInteger)indexOfObject:(MessageTableItem *)item {
    return [self.messages indexOfObject:item];
}

- (MessageTableItem *)itemOfMsgId:(long)msg_id {
    return [self findMessageItemById:msg_id];
}

- (void)clearHistory:(TL_conversation *)dialog {
    
    weak();
    
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Conversation.Confirm.ClearHistory", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.UndoneAction", nil) block:^(NSNumber *result) {
        if([result intValue] == 1000) {
            [[DialogsManager sharedManager] clearHistory:dialog completeHandler:^{
                if(weakSelf.conversation == dialog) {
                    weakSelf.conversation = nil;
                    [weakSelf setCurrentConversation:dialog];
                }
            }];
        }
    }];
    [alert addButtonWithTitle:NSLocalizedString(@"Confirm.ClearHistory", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"Profile.Cancel", nil)];
    [alert show];
}




- (void)leaveOrReturn:(TL_conversation *)dialog {
    TLInputUser *input = [[UsersManager currentUser] inputUser];
    
    id request = dialog.chat.left ? [TLAPI_messages_addChatUser createWithChat_id:dialog.chat.n_id user_id:input fwd_limit:50] : [TLAPI_messages_deleteChatUser createWithChat_id:dialog.chat.n_id user_id:input];
    
    
    if(dialog.chat.left) {
        [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
            
            [[FullChatManager sharedManager] performLoad:dialog.chat.n_id callback:nil];
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
        }];
    } else {
        [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
        }];
    }

}

- (void)deleteDialog:(TL_conversation *)dialog callback:(dispatch_block_t)callback startDeleting:(dispatch_block_t)startDeleting {
   
    
    weak();
    
    
    if(!dialog)
    {
        if(callback) callback();
        return;
    }
    
    dispatch_block_t block = ^{
        [[DialogsManager sharedManager] deleteDialog:dialog completeHandler:^{
            
            if(callback) callback();
            
            if(dialog == weakSelf.conversation) {
                [[Telegram sharedInstance] showNotSelectedDialog];
                weakSelf.conversation = nil;
            }
        }];
    };
    
    if(dialog.type == DialogTypeSecretChat) {
        block();
        return;
    }
    
    if(dialog.type == DialogTypeChat && dialog.chat.left) {
        if(startDeleting != nil)
            startDeleting();
        block();
        return;
    }
    
    NSAlert *alert = [NSAlert alertWithMessageText:dialog.type == DialogTypeChannel && dialog.chat.isCreator ? (NSLocalizedString(dialog.chat.isMegagroup ? @"Conversation.Confirm.DeleteGroup" : @"Conversation.Confirm.DeleteChannel", nil)) : (dialog.type == DialogTypeChat && dialog.chat.type == TLChatTypeNormal ? NSLocalizedString(@"Conversation.Confirm.LeaveAndClear", nil) :  NSLocalizedString(@"Conversation.Confirm.DeleteAndClear", nil)) informativeText:dialog.type == DialogTypeChannel && dialog.chat.isCreator ? NSLocalizedString(dialog.chat.isMegagroup ? @"Conversation.Confirm.DeleteSupergroupInfo" : @"Conversation.Confirm.DeleteChannelInfo", nil) : NSLocalizedString(@"Conversation.Confirm.UndoneAction", nil) block:^(NSNumber *result) {
        if([result intValue] == 1000) {
            if(startDeleting != nil)
                startDeleting();
            block();
        }
    }];
    
    NSString *buttonText = dialog.type == DialogTypeChannel && dialog.chat.isAdmin && !dialog.chat.isMegagroup ? NSLocalizedString(@"Conversation.Confirm.DeleteChannel", nil) : (dialog.type == DialogTypeChat && dialog.chat.type == TLChatTypeNormal ? NSLocalizedString(@"Conversation.DeleteAndExit", nil) : NSLocalizedString(@"Conversation.Delete", nil));
    
    [alert addButtonWithTitle:buttonText];
    [alert addButtonWithTitle:NSLocalizedString(@"Profile.Cancel", nil)];
    [alert show];
}

-(void)deleteDialog:(TL_conversation *)dialog callback:(dispatch_block_t)callback {
    [self deleteDialog:dialog callback:callback startDeleting:nil];
}

- (void)deleteDialog:(TL_conversation *)dialog {
    [self deleteDialog:dialog callback:nil];
}


@end