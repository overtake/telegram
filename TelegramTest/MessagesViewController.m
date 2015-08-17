
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
#import "OnlineNotificationManager.h"

#import "TMBottomScrollView.h"
#import "ReadHistroryTask.h"
#import "TMTaskRequest.h"
#import "PhotoVideoHistoryFilter.h"
#import "PhotoHistoryFilter.h"
#import "DocumentHistoryFilter.h"
#import "VideoHistoryFilter.h"
#import "AudioHistoryFilter.h"
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

@interface MessagesViewController () <SettingsListener> {
    __block SMDelayedBlockHandle _delayedBlockHandle;
}

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableDictionary *cacheTextForPeer;
@property (nonatomic, assign) BOOL locked;

@property (nonatomic,strong) NSMutableDictionary *typingReservation;
@property (nonatomic, strong) ChatHistoryController *historyController;
@property (nonatomic, strong) SelfDestructionController *destructionController;
@property (nonatomic, strong) RPCRequest *typingRequest;

@property (nonatomic,assign) int jumpMessageId;
//Bottom
@property (nonatomic, strong) MessageTypingView *typingView;



@property (nonatomic, strong) TMNameTextField *nameTextField;


@property (nonatomic, strong) NoMessagesView *noMessagesView;
@property (nonatomic, strong) TMBottomScrollView *jumpToBottomButton;

@property (nonatomic, strong) TelegramPopover *popover;

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

- (void)jumpToLastMessages {
    
    BOOL animated = YES;
    
    
    if(self.replyMsgsStack.count > 0)
    {
        int msg_id = [[self.replyMsgsStack lastObject] intValue];
        
        [self.replyMsgsStack removeObject:[self.replyMsgsStack lastObject]];
        
        [self showMessage:msg_id fromMsgId:0 animated:YES selectText:nil];
        return;
    }
    
    if(_historyController.prevState != ChatHistoryStateFull) {
        
        
        
        [self flushMessages];
        
        [self.historyController drop:YES];
        
        self.isMarkIsset = NO;
                
        self.historyController = nil;
        
        self.historyController = [[ChatHistoryController alloc] initWithController:self];
        animated = NO;
        
        
        [self loadhistory:0 toEnd:YES prev:NO isFirst:YES];
    }
    
    [self.table.scrollView scrollToPoint:NSMakePoint(0, 0) animation:animated];
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
    
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowBecomeNotification:) name:NSWindowDidBecomeKeyNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowBecomeNotification:) name:NSWindowDidResignKeyNotification object:self.view.window];
    
    [Notification addObserver:self selector:@selector(changeDialogSelectionNotification:) name:@"ChangeDialogSelection"];
    [Notification addObserver:self selector:@selector(updateChat:) name:CHAT_UPDATE_TYPE];
    
    self.messages = [[NSMutableArray alloc] init];
    self.selectedMessages = [[NSMutableArray alloc] init];
    
    __block MessagesViewController *strongSelf = self;
    
    //Navigation
    self.normalNavigationRightView = [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.Edit", nil)];
    [self.normalNavigationRightView setTapBlock:^{
        [strongSelf setCellsEditButtonShow:YES animated:YES];
    }];
    [self.normalNavigationRightView setDisableColor:NSColorFromRGB(0xa0a0a0)];
    
    
    
    
    self.filtredNavigationCenterView = [TMTextButton standartUserProfileButtonWithTitle:@"nil"];
    
    [self.filtredNavigationCenterView setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
    [self.filtredNavigationCenterView setAlignment:NSCenterTextAlignment];
    
    [self.filtredNavigationCenterView setTextColor:BLUE_UI_COLOR];
    
    [self.filtredNavigationCenterView setFrameOrigin:NSMakePoint(0, -13)];
    
    
    [self.filtredNavigationCenterView setTapBlock:^ {
        NSMenu *menu = [strongSelf filterMenu];
        
        [menu popUpForView:strongSelf.filtredNavigationCenterView center:YES];
        
    }];
    
    
    [self.filtredNavigationCenterView setStringValue:NSLocalizedString(@"Shared Media", nil)];
    
    
    self.filtredNavigationLeftView = [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.Cancel", nil)];
    
    
    [self.filtredNavigationLeftView setTapBlock:^{
        [strongSelf setHistoryFilter:[HistoryFilter class] force:NO];
    }];
    
    self.normalNavigationCenterView = [[MessageTableNavigationTitleView alloc] initWithFrame:NSZeroRect];
    
    
    [self.normalNavigationCenterView setTapBlock:^{
        switch (strongSelf.conversation.type) {
            case DialogTypeChat:
                if(strongSelf.conversation.chat.type == TLChatTypeNormal && !strongSelf.conversation.chat.left)
                    [[Telegram rightViewController] showChatInfoPage:strongSelf.conversation.chat];
                break;
                
            case DialogTypeSecretChat:
                [[Telegram sharedInstance] showUserInfoWithUserId:strongSelf.conversation.encryptedChat.peerUser.n_id conversation:strongSelf.conversation sender:strongSelf];
                break;
                
            case DialogTypeUser: {
                [[Telegram sharedInstance] showUserInfoWithUserId:strongSelf.conversation.user.n_id conversation:strongSelf.conversation sender:strongSelf];
                break;
            }
                
            case DialogTypeBroadcast:
                 [[Telegram rightViewController] showBroadcastInfoPage:strongSelf.conversation.broadcast];
                
            default:
                break;
        }
    }];
    self.centerNavigationBarView = self.normalNavigationCenterView;
    
    
    
    self.editableNavigationLeftView = [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.DeleteAll", nil)];
    
    [self.editableNavigationLeftView setTapBlock:^{
          [strongSelf clearHistory:strongSelf.conversation];
    }];
    
    
    self.editableNavigationRightView = [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.Done", nil)];
    [self.editableNavigationRightView setTapBlock:^{
        [strongSelf unSelectAll];
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
        [strongSelf jumpToLastMessages];
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
    
    
   [self.historyController drop:NO];
    
    self.historyController = nil;
    
    self.historyController = [[ChatHistoryController alloc] initWithController:self];
    
    [self.searchMessagesView setHidden:YES];
    
    
    self.stickerPanel = [[StickersPanelView alloc] initWithFrame:NSMakeRect(0, NSHeight(self.bottomView.frame), NSWidth(self.view.frame), 76)];
    
    
    [self.view addSubview:self.stickerPanel];
    
    [self.stickerPanel hide:NO];

    
}



-(void)messageTableItemUpdate:(NSNotification *)notification {
    
    MessageTableItem *item = notification.userInfo[@"item"];
    
    NSUInteger index = [self indexOfObject:item];
    
    if(index != NSNotFound)
        [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    
    
}

-(void)messageTableItemsReadContents:(NSNotification *)notification  {
    NSArray *messages = notification.userInfo[KEY_MESSAGE_ID_LIST];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.message.n_id IN (%@)", messages];
    
    NSArray *items = [[HistoryFilter messageItems:self.conversation.peer_id] filteredArrayUsingPredicate:predicate];
    
    [items enumerateObjectsUsingBlock:^(MessageTableItemText *obj, NSUInteger idx, BOOL *stop) {
        
        NSUInteger index = [self indexOfObject:obj];
        
        if(index != NSNotFound) {            
            [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
        
    }];
    
}



-(void)messageTableItemsWebPageUpdate:(NSNotification *)notification {
    
    NSArray *messages = notification.userInfo[KEY_MESSAGE_ID_LIST];
    
    
    NSArray *items = [HistoryFilter items:messages];
    
    [items enumerateObjectsUsingBlock:^(MessageTableItemText *obj, NSUInteger idx, BOOL *stop) {
       
        NSUInteger index = [self indexOfObject:obj];
        
        

        [obj updateWebPage];
        
        obj.isHeaderMessage = obj.isHeaderMessage || obj.webpage != nil;
        
        if(index != NSNotFound) {
            [self.table noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:index]];
            
            [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
        
    }];
    
    
    
}

-(void)messageTableItemsEntitiesUpdate:(NSNotification *)notification {
    
    TL_localMessage *message = notification.userInfo[KEY_MESSAGE];
    
    
    NSArray *items = [HistoryFilter items:@[@(message.n_id)]];
    
    [items enumerateObjectsUsingBlock:^(MessageTableItemText *obj, NSUInteger idx, BOOL *stop) {
        
        NSUInteger index = [self indexOfObject:obj];
        
        [obj updateEntities];
        
        if(index != NSNotFound) {
            [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
        
    }];
}


-(void)showSearchBox {
    
    if(!self.searchMessagesView.isHidden) {
        [self.searchMessagesView becomeFirstResponder];
        return;
    }
    
    
    
    __block int currentId = 0;
    
    
    dispatch_block_t clearItems = ^ {
        [self.searchItems enumerateObjectsUsingBlock:^(SearchSelectItem *obj, NSUInteger idx, BOOL *stop) {
            
            [obj clear];
            
            [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[self.messages indexOfObject:obj.item]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            
        }];
        
        
        [self.searchItems removeAllObjects];
        currentId = -1;
    };
    
    dispatch_block_t next = ^ {
        if(self.searchItems.count > 0) {
            
            SearchSelectItem *searchItem = self.searchItems[currentId];
            
            [self.table clearSelection];
            
            NSUInteger row = [self.messages indexOfObject:searchItem.item];
            
            NSRect rowRect = [self.table rectOfRow:row];
            
            [self.table.scrollView scrollToPoint:rowRect.origin animation:NO];
            
            [self scrollToRect:rowRect isCenter:YES animated:NO];
            
        }
    };
    
    [self.searchMessagesView showSearchBox:^(int msg_id, NSString *searchString) {
        
        [self showMessage:msg_id fromMsgId:0 animated:NO selectText:searchString];
        
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

/*
 [self.searchMessagesView showSearchBox:^(NSString *search) {
 
 clearItems();
 
 [self.messages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
 
 if([obj isKindOfClass:[MessageTableItemText class]]) {
 
 SearchSelectItem *searchItem = [[SearchSelectItem alloc] init];
 
 searchItem.item = obj;
 
 
 NSRange range = [obj.message.message rangeOfString:search options:NSCaseInsensitiveSearch];
 while(range.location != NSNotFound)
 {
 TGCTextMark *mark = [[TGCTextMark alloc] initWithRange:range color:NSColorFromRGBWithAlpha(0xe5bf29, 0.3) isReal:NO];
 
 [searchItem.marks addObject:mark];
 
 ((MessageTableItemText *)obj).mark = searchItem;
 
 [self.searchItems addObject:searchItem];
 
 [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:idx] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
 
 
 range = [obj.message.message  rangeOfString:search options:NSCaseInsensitiveSearch range:NSMakeRange(range.location + 1, [obj.message.message length] - range.location - 1)];
 }
 
 }
 
 }];
 
 if(self.searchItems.count > 0) {
 currentId++;
 next();
 }
 
 
 
 } next:^ {
 
 currentId++;
 
 if(currentId >= self.searchItems.count)
 currentId = 0;
 
 next();
 
 
 
 } prevCallback:^{
 
 currentId--;
 
 if(currentId < 0)
 currentId = (int) self.searchItems.count - 1;
 
 next();
 
 
 
 
 } closeCallback:^{
 
 [self hideSearchBox:YES];
 
 }];
 */

-(void)hideSearchBox:(BOOL)animated {
    
    
    
    
    if(self.searchMessagesView.isHidden)
        return;
    
    if(self.historyController.prevState != ChatHistoryStateFull)
        [self jumpToLastMessages];
    
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
    
    if(self.bottomView.stateBottom == MessagesBottomViewNormalState || self.bottomView.stateBottom == MessagesBottomViewActionsState)
    {
        [self setState: show ? MessagesViewControllerStateEditable : MessagesViewControllerStateNone animated:animated];
        for(int i = 0; i < self.messages.count; i++) {
            MessageTableCellContainerView *cell = (MessageTableCellContainerView *)[self cellForRow:i];
            if([cell isKindOfClass:[MessageTableCellContainerView class]] && [cell canEdit]) {
                [cell setEditable:show animation:animated];
            }
        }
    }
    
    
    
}

-(void)_didStackRemoved {
    [self flushMessages];
}


-(NSAttributedString *)stringForSharedMedia:(NSString *)mediaString {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    
    [string appendString:mediaString withColor:BLUE_UI_COLOR];
    
    [string setFont:[NSFont fontWithName:@"HelveticaNeue" size:14] forRange:NSMakeRange(0, string.length)];
    
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
                [self.bottomView setSectedMessagesCount:self.selectedMessages.count];
            }
            
            
            
            
            [self.bottomView setOnClickToLockedView:nil];
        }
       
        
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.noMessagesView setHidden:!show];
        [self.table.containerView setHidden:show];
        [CATransaction commit];
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
            
            StartBotSenderItem *sender = [[StartBotSenderItem alloc] initWithMessage:conversation.type == DialogTypeChat ? [NSString stringWithFormat:@"/start@%@",bot.username] : @"/start" forConversation:conversation bot:bot startParam:startParam];
            sender.tableItem = [[weakSelf messageTableItemsFromMessages:@[sender.message]] lastObject];
            [weakSelf.historyController addItem:sender.tableItem conversation:conversation callback:nil sentControllerCallback:nil];
            
            [ASQueue dispatchOnMainQueue:^{
                
                [weakSelf.bottomView setOnClickToLockedView:nil];
                [weakSelf.bottomView setStateBottom:MessagesBottomViewNormalState];
                
            }];
       
        }];
    
        
    }];
}


- (void)changeDialogSelectionNotification:(NSNotification *)notify {
    if([[notify.userInfo objectForKey:KEY_DIALOG] class] == [NSNull class])
        self.conversation = nil;
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

- (void)setState:(MessagesViewControllerState)state animated:(BOOL)animated {
    self->_state = state;
    
    id rightView, leftView, centerView;
    
    centerView = self.normalNavigationCenterView;
    
    if(state == MessagesViewControllerStateNone && self.historyController.filter.class != HistoryFilter.class) {
        state = MessagesViewControllerStateFiltred;
    }
    
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
        leftView = self.editableNavigationLeftView;
        [self.bottomView setState:MessagesBottomViewActionsState animated:animated];
    }
    
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
    
    
    if(self.conversation.type == DialogTypeChat) {
        if(self.conversation.chat.type == TLChatTypeNormal && !self.conversation.chat.left)
            [[Telegram rightViewController] showChatInfoPage:self.conversation.chat];
    } else if(self.conversation.type == DialogTypeSecretChat) {
        TLUser *user = self.conversation.encryptedChat.peerUser;
        [[Telegram sharedInstance] showUserInfoWithUserId:user.n_id conversation:self.conversation sender:self];
    } else {
        TLUser *user = self.conversation.user;
        [[Telegram sharedInstance] showUserInfoWithUserId:user.n_id conversation:self.conversation sender:self];
    }
}


-(NSMenu *)filterMenu {
    NSMenu *filterMenu = [[NSMenu alloc] init];
    
    
    [filterMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.Filter.Photos",nil) withBlock:^(id sender) {
        [[Telegram rightViewController] showCollectionPage:self.conversation];
    }]];
    
    [filterMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.Filter.Video",nil) withBlock:^(id sender) {
        [self setHistoryFilter:[VideoHistoryFilter class] force:NO];
    }]];
    
    
    [filterMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.Filter.Files",nil) withBlock:^(id sender) {
        [self setHistoryFilter:[DocumentHistoryFilter class] force:NO];
    }]];
    
    [filterMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.Filter.Audio",nil) withBlock:^(id sender) {
        [self setHistoryFilter:[AudioHistoryFilter class] force:NO];
    }]];
    
    return filterMenu;
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
    
    if(self.historyController.filter.class != filter || force) {
        self.ignoredCount = 0;
        self.historyController.filter = [[filter alloc] initWithController:self.historyController];
        [self flushMessages];
        [self loadhistory:0 toEnd:YES prev:NO isFirst:YES];
        self.state = filter != HistoryFilter.class ? MessagesViewControllerStateFiltred : MessagesViewControllerStateNone;
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
    
    [self.table reloadData];
    
    [self setState:self.state];
    if(self.state == MessagesViewControllerStateEditable)
        [self.bottomView setSectedMessagesCount:self.selectedMessages.count];
    
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
}

-(void)viewDidDisappear:(BOOL)animated {
    
    
    
    if(NSClassFromString(@"NSUserActivity")) {
        [self.activity invalidate];
    }
}


- (void)scrollDidStart {
    for(int i = 0; i < self.messages.count; i++) {
        MessageTableCellGifView *view = [self.table viewAtColumn:0 row:i makeIfNecessary:NO];
        if(view && [view isKindOfClass:[MessageTableCellGifView class]]) {
            [view pauseAnimation];
        }
    }
}

- (void)scrollDidEnd {
    for(int i = 0; i < self.messages.count; i++) {
        MessageTableCellGifView *view = [self.table viewAtColumn:0 row:i makeIfNecessary:NO];
        if(view && [view isKindOfClass:[MessageTableCellGifView class]]) {
            [view resumeAnimation];
        }
    }
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
        
    } else {
        [self.table.scrollView setFrame:newFrame];
        [self.noMessagesView setFrame:newFrame];
        
        [self.stickerPanel setFrameOrigin:NSMakePoint(NSMinX(self.stickerPanel.frame), height)];
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



- (void)jumpToBottomButtonDisplay {
    [self.jumpToBottomButton sizeToFit];
    [self.jumpToBottomButton setFrameOrigin:NSMakePoint(self.view.bounds.size.width - self.jumpToBottomButton.bounds.size.width - 30, self.bottomView.bounds.size.height + 30)];
}


- (void)updateScrollBtn {
    static int min_go_size = 5000;
    static int max_go_size = 1000;
    
    float offset = self.table.scrollView.documentOffset.y;
    
    
    
    if(fabsf(_lastBottomScrollOffset - offset) < 100 || [self.table.scrollView isAnimating])
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
//    if(hide) {
//        hide = self.historyController.prevState == ChatHistoryStateFull;
//    }
    
    if(hide)
    {
        hide = self.replyMsgsStack.count == 0;
        
        if(!hide)
        {
            MessageTableItem *item = [self itemOfMsgId:[[_replyMsgsStack lastObject] intValue]];
            
            NSRect rowRect = [self.table rectOfRow:[self indexOfObject:item]];
            
            hide = CGRectContainsRect([self.table visibleRect], rowRect) || self.table.scrollView.documentOffset.y < rowRect.origin.y;
            
            
            if(hide) {
                [_replyMsgsStack removeLastObject];
            }
            
        }
    }
    
    
    if(self.jumpToBottomButton.isHidden != hide) {
        [self.jumpToBottomButton setHidden:hide];
        [self jumpToBottomButtonDisplay];
    }
    
}

- (void)scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)aNotification {
    [self updateScrollBtn];
    
    if([self.table.scrollView isNeedUpdateTop] && self.historyController.prevState != ChatHistoryStateFull) {
        
        [self loadhistory:0 toEnd:NO prev:YES isFirst:NO];
        
    } else if([self.table.scrollView isNeedUpdateBottom] && self.historyController.nextState != ChatHistoryStateFull) {
        
        [self loadhistory:0 toEnd:NO prev:NO isFirst:NO];
    }
    
    
}

- (void) dealloc {
    [Notification removeObserver:self];
}

- (void) drop {
    self.conversation = nil;
    // [self.historyController setDialog:nil];
    [ChatHistoryController drop];
    [self.historyController drop:YES];
    self.historyController = nil;
    [self.messages removeAllObjects];
    [self.table deselectRow:self.table.selectedRow];
    [self.table reloadData];
}

-(void)dialogDeleteNotification:(NSNotification *)notify {
    TL_conversation *dialog = [notify.userInfo objectForKey:KEY_DIALOG];
    if(self.conversation.peer.peer_id == dialog.peer.peer_id) {
        [self.messages removeAllObjects];
        [self.table reloadData];
    }
}

- (void)sendTypingWithAction:(TLSendMessageAction *)action {
    
    
    
    NSMutableDictionary *list = [_typingReservation objectForKey:@(self.conversation.peer_id)];
    
    
    if(!list)
    {
        list = [[NSMutableDictionary alloc] init];
        [_typingReservation setObject:list forKey:@(self.conversation.peer_id)];
    }
    
    if(list[NSStringFromClass(action.class)] == nil) {
        
        [list setObject:action forKey:NSStringFromClass(action.class)];
        
        if(self.conversation.type == DialogTypeBroadcast)
            return;
        
        
        [self.typingRequest cancelRequest];
        
        id request;
        
        if(self.conversation.type == DialogTypeSecretChat)
            request = [TLAPI_messages_setEncryptedTyping createWithPeer:(TLInputEncryptedChat *)[self.conversation.encryptedChat inputPeer] typing:YES];
         else
            request = [TLAPI_messages_setTyping createWithPeer:[self.conversation inputPeer] action:action];
    
        
        self.typingRequest = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {

            dispatch_after_seconds(4, ^{
                [list removeObjectForKey:NSStringFromClass(action.class)];
            });
            
            
        } errorHandler:nil];
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.message.n_id IN %@", readed];
    
    NSArray *filtred = [self.messages filteredArrayUsingPredicate:predicate];
    
    for (MessageTableItem *msg in filtred) {
        msg.message.flags&= ~TGUNREADMESSAGE;
        MessageTableCellContainerView *view = (MessageTableCellContainerView *)[self cellForRow:[self.messages indexOfObject:msg]];
        if([view isKindOfClass:[MessageTableCellContainerView class]]) {
            [view checkActionState:YES];
        }
    }
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
            [self jumpToLastMessages];
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
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableArray *random = [[NSMutableArray alloc] init];
    for(MessageTableItem *item in self.selectedMessages) {
        if(item.message.n_id && item.message.dstate == DeliveryStateNormal) {
            [array addObject:@(item.message.n_id)];
        }
        
        if([item.message isKindOfClass:[TL_destructMessage class]]) {
            [random addObject:@(item.message.randomId)];
        }
    }
    
    
    id request = [TLAPI_messages_deleteMessages createWithN_id:array];
    
    
    dispatch_block_t completeBlock = ^ {
        [[Storage manager] deleteMessages:array completeHandler:nil];
        [Notification perform:MESSAGE_DELETE_EVENT data:@{KEY_MESSAGE_ID_LIST:array}];
        [self unSelectAll];
    };
    
    if(self.conversation.type == DialogTypeSecretChat) {
        
        if(!self.conversation.canSendMessage)
        {
            completeBlock();
            return;
        }
        
        
        DeleteRandomMessagesSenderItem *sender = [[DeleteRandomMessagesSenderItem alloc] initWithConversation:self.conversation random_ids:random];
        
        [sender send];
        
        completeBlock();
        
    } else {
        [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
            
            completeBlock();
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            completeBlock();
        }];
    }
    
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

- (void)deleteMessages:(NSArray *)ids {
    
  //  [self.table beginUpdates];
    
    if(self.messages.count > 0) {
        NSUInteger count = self.selectedMessages.count;
        
        for (NSNumber *msg_id in ids) {
            MessageTableItem *message = [self findMessageItemById:[msg_id intValue]];
            
            if(message != nil) {
                NSUInteger row = [self.messages indexOfObject:message];
                [self.messages removeObjectAtIndex:row];
                [self.selectedMessages removeObject:message];
                
                [self.table removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationEffectFade];
                [message clean];
            }
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
                [self.bottomView setSectedMessagesCount:self.selectedMessages.count];
            else
                [self.bottomView setStateBottom:MessagesBottomViewNormalState];
        }
    }
    
   // [self.table endUpdates];
    
}

- (MessageTableItem *) findMessageItemById:(int)msgId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.message.n_id == %d", msgId];
    
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
    
    [self.bottomView setSectedMessagesCount:self.selectedMessages.count];
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

- (void)showMessage:(int)messageId fromMsgId:(int)msgId {
    [self showMessage:messageId fromMsgId:msgId animated:YES selectText:nil];
}

- (void)showMessage:(int)messageId fromMsgId:(int)fromMsgId animated:(BOOL)animated selectText:(NSString *)text {
    
    MessageTableItem *item = [self itemOfMsgId:messageId];
    
    if(fromMsgId != 0)
        [_replyMsgsStack addObject:@(fromMsgId)];
    
    if(item)
    {
        [self scrollToItem:item animated:animated centered:YES highlight:YES];
    } else {
        
        
        dispatch_block_t block = ^{
            
            
            
            [self.historyController drop:NO];
            
            self.historyController = [[ChatHistoryController alloc] initWithController:self historyFilter:[HistoryFilter class]];
            
            self.historyController.min_id = messageId;
            self.historyController.start_min = messageId;
            self.historyController.max_id = messageId;
            self.historyController.need_save_to_db = NO;
            self.historyController.maxDate = 0;
            self.historyController.minDate = 0;
            [self.historyController removeAllItems];
            
            
            [self flushMessages];
            
            [self loadhistory:messageId toEnd:YES prev:messageId != 0 isFirst:YES];
        };
        
        TL_localMessage *msg = [[Storage manager] messageById:messageId];
        
        
        if(!msg) {
            
            [RPCRequest sendRequest:[TLAPI_messages_getMessages createWithN_id:[@[@(messageId)] mutableCopy]] successHandler:^(RPCRequest *request, TL_messages_messages * response) {
                
                if(response.messages.count > 0) {
                    TLMessage *msg = response.messages[0];
                    
                    if(![msg isKindOfClass:[TL_messageEmpty class]]) {
                        block();
                    }
                }
                
                
                
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                
                
            } timeout:10];
            
            
        } else {
            block();
        }
    
        
    
    
        
    }
    
}

- (void)setCurrentConversation:(TL_conversation *)dialog withJump:(int)messageId historyFilter:(Class)historyFilter force:(BOOL)force {
    [self hideSearchBox:NO];
        
    if(!self.locked &&  (((messageId != 0 && messageId != self.jumpMessageId) || force) || [self.conversation.peer peer_id] != [dialog.peer peer_id] || self.historyController.filter.class != historyFilter)) {
        
        [TGHelpPopup popover].fadeDuration = 0;
        [TGHelpPopup close];
        
        [_replyMsgsStack removeAllObjects];
        
        self.jumpMessageId = messageId;
        self.conversation = dialog;
        
        NSString *cachedText = [self.cacheTextForPeer objectForKey:dialog.cacheKey];
        [self becomeFirstResponder];
        
        [self.noMessagesView setConversation:dialog];
        
        
        _isMarkIsset = NO;
        
        [self.table.scrollView dropScrollData];
        
        [self.topInfoView setConversation:dialog];
        
        [self.jumpToBottomButton setHidden:YES];
        
        [self.typingView setDialog:dialog];
        
        
        if(!historyFilter)
            historyFilter = [HistoryFilter class];
        
        [self.historyController drop:NO];
        
        self.historyController = [[ChatHistoryController alloc] initWithController:self historyFilter:historyFilter];
        
        
        
        if(messageId != 0) {
            self.historyController.min_id = messageId;
            self.historyController.start_min = messageId;
            self.historyController.max_id = messageId;
            self.historyController.need_save_to_db = NO;
            self.historyController.maxDate = 0;
            self.historyController.minDate = 0;
            [self.historyController removeAllItems];
        }
        
        if(dialog.top_message != dialog.last_marked_message) {
            [self.historyController removeAllItems];
        }
        
        
        
        [self.normalNavigationCenterView setDialog:dialog];
        
        
        [self.bottomView setDialog:dialog];
        
        
        self.state = MessagesViewControllerStateNone;
        
        
        [self.bottomView setInputMessageString:cachedText ? cachedText : @"" disableAnimations:YES];
        
        [self unSelectAll:NO];
        
        
        
        [self.typingReservation removeAllObjects];
        [self removeScrollEvent];
        
        [self flushMessages];
        
        [self loadhistory:messageId toEnd:YES prev:messageId != 0 isFirst:YES];
        [self addScrollEvent];
        
    }
}

-(void)setCurrentConversation:(TL_conversation *)dialog withJump:(int)messageId historyFilter:(__unsafe_unretained Class)historyFilter {

    [self setCurrentConversation:dialog withJump:messageId historyFilter:historyFilter force:NO];
    
}


-(void)setCurrentConversation:(TL_conversation *)dialog {
    [self setCurrentConversation:dialog withJump:0 historyFilter:[HistoryFilter class]];
}



- (void)cancelSelectionAndScrollToBottom {
    [self unSelectAll];
    self.state = MessagesViewControllerStateNone;
    [self.table.scrollView scrollToEndWithAnimation:YES];
}

- (void)tryRead {
    if(!self.view.isHidden && self.view.window.isKeyWindow && self.historyController.filter.class == HistoryFilter.class && ![TGPasslock isVisibility]) {
        if(_delayedBlockHandle)
            _delayedBlockHandle(YES);
        
        if(self.conversation.last_marked_message != self.conversation.top_message) {
            self.conversation.last_marked_message = self.conversation.top_message;
            self.conversation.last_marked_date = [[MTNetwork instance] getTime];
            [self.conversation save];
        }
        
        
        _delayedBlockHandle = perform_block_after_delay(0.2f, ^{
            _delayedBlockHandle = nil;
            if(self.conversation.unread_count > 0 || self.conversation.peer.user_id == [UsersManager currentUserId]) {
                [self readHistory:0];
            }
        });
    }
}



- (void)readHistory:(int)offset{
    if(!self.conversation || self.conversation.unread_count == 0)
        return;
    
     [(MessagesManager *)[MessagesManager sharedManager] markAllInDialog:self.conversation callback:^(NSArray *ids) {
         
     }];
    
    
    
    self.conversation.unread_count = 0;
    
    [self.conversation save];
    
    [Notification perform:[Notification notificationNameByDialog:self.conversation action:@"unread_count"] data:@{KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:self.conversation]}];
    
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
                TL_localMessageService *service = [TL_localMessageService createWithN_id:0 flags:0 from_id:0 to_id:_conversation.peer date:0 action:[TL_messageActionBotDescription createWithTitle:userFull.bot_info.n_description] fakeId:0 randomId:rand_long() dstate:DeliveryStateNormal];
                
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
    
}



- (void)loadhistory:(int)message_id toEnd:(BOOL)toEnd prev:(BOOL)prev isFirst:(BOOL)isFirst {
    if(!self.conversation || self.historyController.isProccessing || _locked)
        return;
    
    prev = prev || (isFirst && _historyController.conversation.top_message != _historyController.conversation.last_marked_message && _historyController.conversation.last_marked_message != 0 && _historyController.conversation.unread_count > 0);
    
    if(!prev && isFirst) {
        _historyController.prevState = ChatHistoryStateFull;
    }
    
    NSSize size = self.table.scrollView.documentSize;
    
    int count = size.height/20;
    
    self.historyController.selectLimit = isFirst ? count : 50;
    
    
    
    _needNextRequest = NO;
    
    [self.historyController request:!prev anotherSource:YES sync:isFirst selectHandler:^(NSArray *prevResult, NSRange range) {
        
       if(prevResult.count > 0) {
            MessageTableItem *item = prevResult[0];
            if(self.conversation.peer_id != item.message.peer_id)
                return;
        }
        
        
        // assert(prevResult.count > 0);
        
        if(message_id != 0 && prev && self.historyController.prevState == ChatHistoryStateRemote) {
            self.historyController.nextState = self.historyController.prevState;
        }
        
        
       NSUInteger pos = prev ? 0 : self.messages.count;
        if(isFirst && prev) {
            
            _needNextRequest = YES;
            
            [_historyController request:YES anotherSource:YES sync:isFirst selectHandler:^(NSArray *result, NSRange range) {
                
                _needNextRequest = NO;
                
                self.isMarkIsset = YES;
                
                [self updateScrollBtn];
                
                self.unreadMark = [[MessageTableItemUnreadMark alloc] initWithCount:_historyController.conversation.unread_count type:RemoveUnreadMarkAfterSecondsType];
                
                
                NSArray *completeResult = message_id == 0 && self.historyController.filter.class == HistoryFilter.class && prevResult.count > 0 ? [prevResult arrayByAddingObject:self.unreadMark] : prevResult;
                
                NSArray *nextResult = [completeResult arrayByAddingObjectsFromArray:result];
                
                
                [self messagesLoadedTryToInsert:nextResult pos:0 next:NO];
                
                
                id item = message_id == 0 ? self.unreadMark : [self findMessageItemById:message_id];
                
                NSUInteger index = [self indexOfObject:item];
                NSRect rect = [self.table rectOfRow:index];
                
                [self scrollToRect:rect isCenter:message_id != 0  animated:NO];
                //bug fix
                
                
                
                if([item isKindOfClass:[MessageTableItemText class]] && [self searchBoxIsVisible]) {
                    MessageTableItemText *textItem = item;
                    
                    [self.searchItems enumerateObjectsUsingBlock:^(SearchSelectItem *obj, NSUInteger idx, BOOL *stop) {
                        
                        [obj clear];
                        
                    }];
                    
                    NSRange range = [textItem.message.message rangeOfString:self.searchMessagesView.currentString options:NSCaseInsensitiveSearch];
                    
                    if(range.location != NSNotFound)
                    {
                        SearchSelectItem *searchItem = [[SearchSelectItem alloc] init];
                        searchItem.item = textItem;
                        
                        searchItem.isCurrent = YES;
                        
                        [searchItem.marks addObject:[[TGCTextMark alloc] initWithRange:range color:NSColorFromRGBWithAlpha(0xe5bf29, 0.3) isReal:NO]];
                        
                        [textItem setMark:searchItem];
                        
                        [self.searchItems addObject:searchItem];
                        
                    }
                    
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSUInteger idx = [self indexOfObject:item];
                    if(message_id && idx != NSNotFound) {
                        MessageTableCellContainerView *cell = (MessageTableCellContainerView *)[self cellForRow:idx];
                        
                        if(cell && [cell isKindOfClass:[MessageTableCellContainerView class]]) {
                            
                            for(int i = 0; i < self.messages.count; i++) {
                                MessageTableCellContainerView *cell2 = (MessageTableCellContainerView *)[self cellForRow:i];
                                if(cell2 && [cell2 isKindOfClass:[MessageTableCellContainerView class]]) {
                                    [cell2 stopSearchSelection];
                                }
                            }
                            
                           [cell searchSelection];
                            
                            if([item isKindOfClass:[MessageTableItemText class]] && [(MessageTableItemText *)item mark] != nil) {
                                [cell setItem:item];
                            }
                        }
                    }
                });
                
                
                if(result.count < _historyController.selectLimit)
                    [self loadhistory:0 toEnd:YES prev:NO isFirst:NO];
                
               
                
            }];
            
        } else {
            [self messagesLoadedTryToInsert:prevResult pos:pos next:!prev];
            
            if(self.didUpdatedTable) {
                self.didUpdatedTable();
            }
            
            if(prevResult.count < _historyController.selectLimit) {
                [self loadhistory:0 toEnd:YES prev:NO isFirst:NO];
            }
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
            //
            //        if(rect.origin.y < 0)
            //            rect.origin.y = 0;
            
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
            [array insertObject:item atIndex:0];
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
        
        
        [current makeSizeByWidth:MAX(NSWidth([Telegram rightViewController].view.frame) - 150,100)];
        [backItem makeSizeByWidth:MAX(NSWidth([Telegram rightViewController].view.frame) - 150,100)];
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
            
            
            [self isHeaderMessage:item prevItem:[self.messages objectAtIndex:nRow+1]];
            
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


- (void)sendMessage {
    NSString *message = [self.bottomView.inputMessageString trim];
    
    if([message isEqualToString:@"performcrash"]) {
        [ASQueue dispatchOnStageQueue:^{
            [(TMView *)self.conversation becomeFirstResponder];
        }];
        return;
    }
    
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
    
    [self setHistoryFilter:HistoryFilter.class force:self.historyController.prevState != ChatHistoryStateFull];
    
    
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
            MessageSenderItem *sender = [[cs alloc] initWithMessage:message forConversation:conversation noWebpage:noWebpage];
            sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
            [self.historyController addItem:sender.tableItem conversation:conversation callback:callback sentControllerCallback:nil];
            
        }
        
        else
        {
            for (NSUInteger i = 0; i < message.length; i += messagePartLimit)
            {
                NSString *substring = [message substringWithRange:NSMakeRange(i, MIN(messagePartLimit, message.length - i))];
                if (substring.length != 0) {
                    
                    MessageSenderItem *sender = [[cs alloc] initWithMessage:substring forConversation:conversation noWebpage:noWebpage];
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
    
    [self setHistoryFilter:HistoryFilter.class force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ASQueue dispatchOnStageQueue:^{
        
        Class cs = self.conversation.type == DialogTypeSecretChat ? [LocationSenderItem class] : [LocationSenderItem class];
        
        LocationSenderItem *sender = [[cs alloc] initWithCoordinates:coordinates conversation:conversation];
        sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
        [self.historyController addItem:sender.tableItem];
        
    }];
    
}

- (void)sendVideo:(NSString *)file_path forConversation:(TL_conversation *)conversation {
    [self sendVideo:file_path forConversation:conversation addCompletionHandler:nil];
}

-(void)sendVideo:(NSString *)file_path forConversation:(TL_conversation *)conversation addCompletionHandler:(dispatch_block_t)completeHandler {
    if(!conversation.canSendMessage) return;
    
    [self setHistoryFilter:HistoryFilter.class force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ASQueue dispatchOnStageQueue:^{
        SenderItem *sender;
        
        if(!check_file_size(file_path)) {
            alert_bad_files(@[[file_path lastPathComponent]]);
            return;
        }
        
        if(self.conversation.type == DialogTypeSecretChat) {
            sender = [[FileSecretSenderItem alloc] initWithPath:file_path uploadType:UploadVideoType forConversation:conversation];
        } else {
            sender = [[VideoSenderItem alloc] initWithPath:file_path forConversation:conversation];
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
    
    [self setHistoryFilter:HistoryFilter.class force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ASQueue dispatchOnStageQueue:^{
        
        if(!check_file_size(file_path)) {
            alert_bad_files(@[[file_path lastPathComponent]]);
            return;
        }
        
        SenderItem *sender;
        if(self.conversation.type == DialogTypeSecretChat) {
            sender = [[FileSecretSenderItem alloc] initWithPath:file_path uploadType:UploadDocumentType forConversation:conversation];
        } else {
            sender = [[DocumentSenderItem alloc] initWithPath:file_path forConversation:conversation];
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
    
    [self setHistoryFilter:HistoryFilter.class force:self.historyController.prevState != ChatHistoryStateFull];
    
    [self.bottomView closeEmoji];
    
    
    
    
    
    [ASQueue dispatchOnStageQueue:^{
        
        
        SenderItem *sender;
        
        if(self.conversation.type != DialogTypeSecretChat) {
            sender = [[StickerSenderItem alloc] initWithDocument:sticker forConversation:conversation];
        } else {
            sender = [[ExternalDocumentSecretSenderItem alloc] initWithConversation:conversation document:sticker];
        }
        
       
        sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
        [self.historyController addItem:sender.tableItem sentControllerCallback:completeHandler];
        
    }];
    
}


- (void)sendAudio:(NSString *)file_path forConversation:(TL_conversation *)conversation {
    
    if(!conversation.canSendMessage) return;
    
    [self setHistoryFilter:HistoryFilter.class force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ASQueue dispatchOnStageQueue:^{
        
        if(!check_file_size(file_path)) {
            alert_bad_files(@[[file_path lastPathComponent]]);
            return;
        }
        
        SenderItem *sender;
        if(self.conversation.type == DialogTypeSecretChat) {
            sender = [[FileSecretSenderItem alloc] initWithPath:file_path uploadType:UploadAudioType forConversation:conversation];
        } else {
            sender = [[AudioSenderItem alloc] initWithPath:file_path forConversation:conversation];
        }
        
        sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
        [self.historyController addItem:sender.tableItem];
    }];
}

- (void)forwardMessages:(NSArray *)messages conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback {
    
    if(!conversation.canSendMessage)
        return;
    
    [self setHistoryFilter:HistoryFilter.class force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ASQueue dispatchOnStageQueue:^{
        
        
        void (^fwd_blck) (NSArray *fwd_msgs) = ^(NSArray *fwd_messages) {
            ForwardSenterItem *sender = [[ForwardSenterItem alloc] initWithMessages:fwd_messages forConversation:conversation];
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
    
    [self setHistoryFilter:HistoryFilter.class force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ASQueue dispatchOnStageQueue:^{
        
        ShareContactSenterItem *sender = [[ShareContactSenterItem alloc] initWithContact:contact forConversation:conversation];
        
        sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
        [self.historyController addItem:sender.tableItem conversation:conversation callback:callback sentControllerCallback:nil];
    }];
}

- (void)sendSecretTTL:(int)ttl forConversation:(TL_conversation *)conversation {
    [self sendSecretTTL:ttl forConversation:conversation callback:nil];
}

- (void)sendSecretTTL:(int)ttl forConversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback {
    
    if(!conversation.canSendMessage) {
        if(callback) callback();
        return;
    }
    
    [self setHistoryFilter:HistoryFilter.class force:self.historyController.prevState != ChatHistoryStateFull];
    
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
    
    [self setHistoryFilter:HistoryFilter.class force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ASQueue dispatchOnStageQueue:^{
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        [attachments enumerateObjectsUsingBlock:^(TGAttachObject *obj, NSUInteger idx, BOOL *stop) {
            
            SenderItem *sender = [[[obj senderClass] alloc] initWithConversation:conversation attachObject:obj];
            
            
            sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
            [items addObject:sender.tableItem];
 
        }];
        
       
        [self.historyController addItems:items conversation:conversation sentControllerCallback:completeHandler];
        
        
    }];
}

- (void)addImageAttachment:(NSString *)file_path forConversation:(TL_conversation *)conversation file_data:(NSData *)data addCompletionHandler:(dispatch_block_t)completeHandler {
    if(self.conversation.type == DialogTypeSecretChat)
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

    
    [self setHistoryFilter:HistoryFilter.class force:self.historyController.prevState != ChatHistoryStateFull];
    
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
            sender = [[ImageSenderItem alloc] initWithImage:originImage jpegData:imageData forConversation:conversation];
        }
        
        sender.tableItem = [[self messageTableItemsFromMessages:@[sender.message]] lastObject];
        [self.historyController addItem:sender.tableItem sentControllerCallback:completeHandler];
    }];
}


- (void)addReplayMessage:(TL_localMessage *)message animated:(BOOL)animated {
    
    if(message.to_id.class == [TL_peerChat class] || message.to_id.class == [TL_peerUser class])  {
        [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            
            [transaction setObject:message forKey:self.conversation.cacheKey inCollection:REPLAY_COLLECTION];
            
        }];
        
        [self.bottomView updateReplayMessage:YES animated:animated];
        
        if([Telegram rightViewController].navigationViewController.currentController != self)
        {
            [[Telegram rightViewController] showByDialog:message.conversation sender:self];
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
    
    
    if(item.class == [MessageTableItemServiceMessage class]) {
        
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

- (MessageTableItem *)itemOfMsgId:(int)msg_id {
    return [self findMessageItemById:msg_id];
}

- (void)clearHistory:(TL_conversation *)dialog {
    
    weakify();
    
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Conversation.Confirm.ClearHistory", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.UndoneAction", nil) block:^(NSNumber *result) {
        if([result intValue] == 1000) {
            [[DialogsManager sharedManager] clearHistory:dialog completeHandler:^{
                if(strongSelf.conversation == dialog) {
                    [strongSelf.historyController removeAllItems];
                    strongSelf.conversation = nil;
                    [strongSelf setCurrentConversation:dialog];
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
    weakify();
    
    
    if(!dialog)
    {
        if(callback) callback();
        return;
    }
    
    dispatch_block_t block = ^{
        [[DialogsManager sharedManager] deleteDialog:dialog completeHandler:^{
            if(dialog == strongSelf.conversation) {
                [strongSelf.historyController removeAllItems];
                [[Telegram sharedInstance] showNotSelectedDialog];
                strongSelf.conversation = nil;
                
                if(callback) callback();
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
    
    NSAlert *alert = [NSAlert alertWithMessageText:dialog.type == DialogTypeChat && dialog.chat.type == TLChatTypeNormal ? NSLocalizedString(@"Conversation.Confirm.LeaveAndClear", nil) :  NSLocalizedString(@"Conversation.Confirm.DeleteAndClear", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.UndoneAction", nil) block:^(NSNumber *result) {
        if([result intValue] == 1000) {
            if(startDeleting != nil)
                startDeleting();
            block();
        }
    }];
    
    NSString *buttonText = dialog.type == DialogTypeChat && dialog.chat.type == TLChatTypeNormal ? NSLocalizedString(@"Conversation.DeleteAndExit", nil) : NSLocalizedString(@"Conversation.Delete", nil);
    
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