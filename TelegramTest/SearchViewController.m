//
//  SearchViewController.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/28/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchSeparatorItem.h"
#import "SearchSeparatorTableCell.h"
#import "SearchItem.h"
#import "SearchTableCell.h"
#import "Telegram.h"
#import "DialogTableView.h"
#import "TLEncryptedChatCategory.h"
#import "TLEncryptedChat+Extensions.h"
#import "ConversationTableItemView.h"
#import "SearchLoadMoreCell.h"
#import "HackUtils.h"
#import "TLPeer+Extensions.h"
#import "SearchMessageCellView.h"
#import "SearchMessageTableItem.h"
typedef enum {
    SearchSectionDialogs,
    SearchSectionContacts,
    SearchSectionUsers,
    SearchSectionMessages,
    SearchSectionGlobalUsers
} SearchSection;

@interface SearchParams : NSObject
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSString *searchString;

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *dialogs;
@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) NSMutableArray *globalUsers;

@property (nonatomic) int messages_offset;

@property (nonatomic) int messages_count;

@property (nonatomic,assign) int messages_inserted;

@property (nonatomic) int local_offset;
@property (nonatomic) int remote_offset;

@property (atomic) BOOL isStorageLoaded;
@property (atomic) BOOL isRemoteLoaded;
@property (atomic) BOOL isNeedRemoteLoad;

@property (atomic) BOOL isLoading;
@property (atomic) BOOL isFinishLoading;

@property (atomic) BOOL isRemoteGlobalUsersLoaded;
@property (atomic) BOOL isNeedGlobalUsersLoad;


@end

@implementation SearchParams

@end


@interface SearchView : TMView
@end

@implementation SearchView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [DIALOG_BORDER_COLOR set];
    NSRectFill(NSMakeRect(self.bounds.size.width - DIALOG_BORDER_WIDTH, 0, DIALOG_BORDER_WIDTH, self.bounds.size.height));
}

@end

@interface SearchViewController()

@property (nonatomic, strong) SearchParams *searchParams;
@property (nonatomic, strong) DialogTableView *tableView;
@property (nonatomic, strong) TMView *noResultsView;
@property (nonatomic, strong) NSImageView *noResultsImageView;

@property (nonatomic, strong) SearchSeparatorItem *contactsSeparator;
@property (nonatomic, strong) SearchSeparatorItem *usersSeparator;
@property (nonatomic, strong) SearchSeparatorItem *messagesSeparator;
@property (nonatomic, strong) SearchSeparatorItem *globalUsersSeparator;

@property (nonatomic, strong) SearchLoadMoreItem *dialogsLoadMoreItem;
@property (nonatomic, strong) SearchLoadMoreItem *contactsLoadMoreItem;
@property (nonatomic, strong) SearchLoadMoreItem *usersLoadMoreItem;
@property (nonatomic, strong) SearchLoadMoreItem *messagesLoadMoreItem;
@property (nonatomic, strong) SearchLoadMoreItem *globalUsersLoadMoreItem;
@property (nonatomic, strong) SearchLoaderItem *messagesLoaderItem;

@end

@implementation SearchViewController

- (void)loadView {
    [super loadView];
    weakify();
    
    
    [self.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    
    self.contactsSeparator = [[SearchSeparatorItem alloc] initWithOneName:NSLocalizedString(@"Search.Separator.Contact", nil) pluralName:NSLocalizedString(@"Search.Separator.Contacts", nil)];
    self.usersSeparator = [[SearchSeparatorItem alloc] initWithOneName:NSLocalizedString(@"Search.Separator.User", nil) pluralName:NSLocalizedString(@"Search.Separator.Users", nil)];
    self.messagesSeparator = [[SearchSeparatorItem alloc] initWithOneName:NSLocalizedString(@"Search.Separator.Message", nil) pluralName:NSLocalizedString(@"Search.Separator.Messages", nil)];
    
    self.globalUsersSeparator = [[SearchSeparatorItem alloc] initWithOneName:NSLocalizedString(@"Search.Separator.GlobalSearch", nil) pluralName:NSLocalizedString(@"Search.Separator.GlobalSearch", nil)];
    
    self.dialogsLoadMoreItem = [[SearchLoadMoreItem alloc] init];
    [self.dialogsLoadMoreItem setClickBlock:^{
        [strongSelf showMore:SearchSectionDialogs animation:YES];
    }];
    
    self.contactsLoadMoreItem = [[SearchLoadMoreItem alloc] init];
    [self.contactsLoadMoreItem setClickBlock:^{
        [strongSelf showMore:SearchSectionContacts animation:YES];
    }];
    
    self.usersLoadMoreItem = [[SearchLoadMoreItem alloc] init];
    [self.usersLoadMoreItem setClickBlock:^{
        [strongSelf showMore:SearchSectionUsers animation:YES];
    }];
    
    
    self.globalUsersLoadMoreItem = [[SearchLoadMoreItem alloc] init];
    [self.globalUsersLoadMoreItem setClickBlock:^{
        [strongSelf showMore:SearchSectionGlobalUsers animation:YES];
    }];
    
    
    self.messagesLoadMoreItem = [[SearchLoadMoreItem alloc] init];
    [self.messagesLoadMoreItem setClickBlock:^{
        [strongSelf showMore:SearchSectionMessages animation:YES];
    }];
    
    self.messagesLoaderItem = [[SearchLoaderItem alloc] init];
    
    [self.view setBackgroundColor:[NSColor whiteColor]];

    self.noResultsView = [[TMView alloc] initWithFrame:self.view.bounds];
    [self.noResultsView setDrawBlock:^{
        [DIALOG_BORDER_COLOR set];
        NSRectFill(NSMakeRect(strongSelf.view.bounds.size.width - DIALOG_BORDER_WIDTH, 0, DIALOG_BORDER_WIDTH, strongSelf.view.bounds.size.height));
    }];
    
    [self.noResultsView setAutoresizesSubviews:YES];
    
    self.noResultsImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, image_noResults().size.width, image_noResults().size.height)];
    [self.noResultsImageView setImage:image_noResults()];
    [self.noResultsImageView setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin | NSViewWidthSizable | NSViewHeightSizable];
   
    
    
    [self.noResultsView setCenterByView:self.view];
    [self.noResultsView addSubview:self.noResultsImageView];
    [self.noResultsView setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin | NSViewWidthSizable | NSViewHeightSizable];
    [self.noResultsImageView setCenterByView:self.view];
    [self.view addSubview:self.noResultsView];
    
    
    self.tableView = [[DialogTableView alloc] initWithFrame:self.view.bounds];
    self.tableView.tm_delegate = self;
    [self.tableView addItem:[[SearchLoaderItem alloc] init] tableRedraw:NO];
    [self.tableView reloadData];
    [self.view addSubview:self.tableView.containerView];
    
    
    
    [Notification addObserver:self selector:@selector(notificationDialogSelectionChanged:) name:@"ChangeDialogSelection"];
    
    [self addScrollEvent];
}

- (void)addScrollEvent {
    id clipView = [[self.tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

- (void)scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)aNotification {
    if(![self.tableView.scrollView isNeedUpdateBottom] || self.searchParams.isLoading || self.searchParams.isFinishLoading)
        return;
    
    if((self.type & SearchTypeMessages) == SearchTypeMessages) {
        if(self.searchParams.isStorageLoaded)
        {
            [self remoteSearch:self.searchParams];
        } else {
            [self localSearch:self.searchParams];
        }
    }
    
    
   // ;
}

//table
- (void)notificationDialogSelectionChanged:(NSNotification *)notify {
    id sender = [notify.userInfo objectForKey:@"sender"];
    
    if(sender != self) {
        TL_conversation *dialog = [notify.userInfo objectForKey:KEY_DIALOG];
        [self.tableView cancelSelection];

        if(![dialog isKindOfClass:NSNull.class]) {
            NSUInteger hash = [SearchItem hash:[[SearchItem alloc] initWithDialogItem:dialog searchString:self.searchParams.searchString]];
            [self.tableView setSelectedByHash:hash];
        }
    }
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *)item {
    if([item isKindOfClass:[SearchSeparatorItem class]]) {
        return [self.tableView cacheViewForClass:[SearchSeparatorTableCell class] identifier:@"SearchSeparatorTableCell" withSize:NSMakeSize(self.view.bounds.size.width, 27)];
    } else if ([item isKindOfClass:[ConversationTableItem class]]) {
        ConversationTableItemView *view = (ConversationTableItemView *)[self.tableView cacheViewForClass:[ConversationTableItemView class] identifier:@"SearchTableItem"];
        [view setSwipePanelActive:NO];
        return view;
        
    } if ([item isKindOfClass:[SearchLoaderItem class]]) {
        return [self.tableView cacheViewForClass:[SearchLoaderCell class] identifier:@"SearchTableLoader" withSize:NSMakeSize(self.view.bounds.size.width, DIALOG_CELL_HEIGHT)];
    } if ([item isKindOfClass:[SearchLoadMoreItem class]]) {
        return [self.tableView cacheViewForClass:[SearchLoadMoreCell class] identifier:@"SearchTableLoadMore" withSize:NSMakeSize(self.view.bounds.size.width, 40)];
    } else if([item isKindOfClass:[SearchItem class]]) {
        return [self.tableView cacheViewForClass:[SearchTableCell class] identifier:@"SearchTableCell" withSize:NSMakeSize(self.view.bounds.size.width, DIALOG_CELL_HEIGHT)];
    } else if([item isKindOfClass:[SearchMessageTableItem class]]) {
        return [self.tableView cacheViewForClass:[SearchMessageTableItem class] identifier:@"SearchMessageTableItem" withSize:NSMakeSize(self.view.bounds.size.width, DIALOG_CELL_HEIGHT)];
    }
    
    return nil;
}

- (BOOL) isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
//    if([i/tem isKindOfClass:[SearchSeparatorItem class]]) {
//        return YES;
//    }
    return NO;
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *)item {
    if([item isKindOfClass:[SearchSeparatorItem class]]) {
        return 27;
    } else if([item isKindOfClass:[SearchLoaderItem class]]) {
        return 40;
    } else if([item isKindOfClass:[SearchLoadMoreItem class]])  {
        return 40;
    } else {
        return DIALOG_CELL_HEIGHT;
    }
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    if(![[Telegram rightViewController] isModalViewActive]) {
        return ![Telegram rightViewController].navigationViewController.isLocked;
    }
    
    if(item && (![item isKindOfClass:[SearchSeparatorItem class]])) {
        ConversationTableItem *searchItem = (ConversationTableItem *)item;
        
        if(searchItem.conversation) {
            [[Telegram rightViewController] modalViewSendAction:searchItem.conversation];
        } else if(searchItem.user) {
            [[Telegram rightViewController] modalViewSendAction:[[DialogsManager sharedManager] findByUserId:searchItem.user.n_id]];
        }
        
        
        
    }

    return NO;
}



- (void)selectionDidChange:(NSInteger)row item:(TMRowItem *)item {
    
    if(item && ([item isKindOfClass:[ConversationTableItem class]] || [item isKindOfClass:[SearchItem class]])) {
        SearchItem *searchItem = (SearchItem *) item;
        
        TL_conversation *dialog = searchItem.conversation;
        
        if(!dialog)
            dialog = searchItem.user.dialog;
        
        int msg_id = [searchItem respondsToSelector:@selector(message)] ? searchItem.message.n_id : 0;
        
        if([item isKindOfClass:[SearchMessageTableItem class]]) {
            msg_id = [[(SearchMessageTableItem *)searchItem lastMessage] n_id];
        } else {
            TMViewController *controller = [[Telegram leftViewController] currentTabController];
            
            if([controller isKindOfClass:[StandartViewController class]]) {
                [(StandartViewController *)controller searchByString:@""];
            }
            
        }
        
        if(dialog){
            BOOL success = [[Telegram rightViewController] showByDialog:dialog withJump:msg_id historyFilter:[HistoryFilter class] sender:self];
            if(!success) {
                [[Telegram rightViewController].messagesViewController setCurrentConversation:dialog withJump:msg_id historyFilter:[HistoryFilter class]];
            }
            [self.tableView setSelectedByHash:item.hash];
        }
    }
}

- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *)item {
    return [item isKindOfClass:[SearchSeparatorItem class]] || [item isKindOfClass:[SearchLoaderItem class]] || [item isKindOfClass:[SearchLoadMoreItem class]] ? NO : YES;
}

//table

static int insertCount = 3;


- (void)showMore:(SearchSection)section animation:(BOOL)animation {
    
    id separatorItem = nil;
    NSArray *items = nil;
    
    switch (section) {
        case SearchSectionContacts:
            separatorItem = self.contactsLoadMoreItem;
            items = self.searchParams.contacts;
            break;
        case SearchSectionDialogs:
            separatorItem = self.dialogsLoadMoreItem;
            items = self.searchParams.dialogs;
            break;
        case SearchSectionMessages:
            separatorItem = self.messagesLoadMoreItem;
            items = self.searchParams.messages;
            break;
        case SearchSectionUsers:
            separatorItem = self.usersLoadMoreItem;
            items = self.searchParams.users;
            break;
        case SearchSectionGlobalUsers:
            separatorItem = self.globalUsersLoadMoreItem;
            items = self.searchParams.globalUsers;
            break;
            
        default:
            break;
    }
    
    
    [self.tableView setDefaultAnimation:animation ? NSTableViewAnimationSlideUp : NSTableViewAnimationEffectNone];
    NSInteger pos = [self.tableView positionOfItem:separatorItem];
    [self.tableView removeItem:separatorItem];
    
    NSMutableArray *insertItems = [[NSMutableArray alloc] init];
    for(int i = insertCount; i < items.count; i++) {
        [insertItems addObject:[items objectAtIndex:i]];
    }
    
    [self.tableView insert:insertItems startIndex:pos tableRedraw:YES];
    [self.tableView setDefaultAnimation:NSTableViewAnimationEffectNone];
}

- (void)showSearchResults:(SearchParams *)params {
    if(params != self.searchParams) {
        return;
    }
    
    assert([NSThread isMainThread]);
    
    [self.tableView removeAllItems:NO];
    
    BOOL isNeedSeparator = NO;
    BOOL isOneSearchResult = YES;
    
    if(params.dialogs.count) {
        
        if(params.dialogs.count > insertCount) {
            for(int i = 0; i < insertCount; i++)
                [self.tableView addItem:[params.dialogs objectAtIndex:i] tableRedraw:NO];
            
            self.dialogsLoadMoreItem.num = (int)params.dialogs.count - insertCount;
            [self.tableView addItem:self.dialogsLoadMoreItem tableRedraw:NO];
        } else {
            [self.tableView insert:params.dialogs startIndex:[self.tableView count] tableRedraw:NO];
        }
        
        isNeedSeparator = YES;
    }
    
    if(params.contacts.count) {
        if(isNeedSeparator) {
            [self.tableView addItem:self.contactsSeparator tableRedraw:NO];
            [self.contactsSeparator setItemCount:(int)params.contacts.count];
            isOneSearchResult = NO;
        }
        
        if(params.contacts.count > insertCount) {
            for(int i = 0; i < insertCount; i++)
                [self.tableView addItem:[params.contacts objectAtIndex:i] tableRedraw:NO];
            
            self.contactsLoadMoreItem.num = (int)params.contacts.count - insertCount;
            [self.tableView addItem:self.contactsLoadMoreItem tableRedraw:NO];
        } else {
            [self.tableView insert:params.contacts startIndex:[self.tableView count] tableRedraw:NO];
        }
        
        isNeedSeparator = YES;
    }
    
    if(params.users.count) {
        if(isNeedSeparator) {
            [self.tableView addItem:self.usersSeparator tableRedraw:NO];
            [self.usersSeparator setItemCount:(int)params.users.count];
            isOneSearchResult = NO;
        }
        
        if(params.users.count > insertCount) {
            for(int i = 0; i < insertCount; i++)
                [self.tableView addItem:[params.users objectAtIndex:i] tableRedraw:NO];
            
            self.usersLoadMoreItem.num = (int)params.users.count - insertCount;
            [self.tableView addItem:self.usersLoadMoreItem tableRedraw:NO];
        } else {
            [self.tableView insert:params.users startIndex:[self.tableView count] tableRedraw:NO];
        }
        
        isNeedSeparator = YES;
    }
    
    if(params.globalUsers.count > 0) {
        if(isNeedSeparator) {
            [self.tableView addItem:self.globalUsersSeparator tableRedraw:NO];
            isOneSearchResult = NO;
        }
        
        if(params.globalUsers.count > insertCount) {
            [self.tableView insert:[params.globalUsers subarrayWithRange:NSMakeRange(0, insertCount-1)] startIndex:[self.tableView count] tableRedraw:NO];
            
            self.globalUsersLoadMoreItem.num = (int)params.globalUsers.count - insertCount;
            [self.tableView addItem:self.globalUsersLoadMoreItem tableRedraw:NO];
        } else {
            [self.tableView insert:params.globalUsers startIndex:[self.tableView count] tableRedraw:NO];
        }
        
        isNeedSeparator = YES;
    }
    
    if(params.messages.count > 0) {
        if(isNeedSeparator) {
            [self.tableView addItem:self.messagesSeparator tableRedraw:NO];
            isOneSearchResult = NO;
        }
        
        [self.tableView insert:params.messages startIndex:[self.tableView count] tableRedraw:NO];
        
        isNeedSeparator = NO;
  
    }
    
    
    //MessagesLoader
    if(isNeedSeparator && params.isNeedRemoteLoad) {
        [self.tableView addItem:self.messagesSeparator tableRedraw:NO];
        [self.messagesSeparator setItemCount:-1];
        isOneSearchResult = NO;
    }
    if(params.isNeedRemoteLoad)
        [self.tableView addItem:self.messagesLoaderItem tableRedraw:NO];
    
    
    if(params.isNeedGlobalUsersLoad && !params.isRemoteGlobalUsersLoaded)
        [self.tableView addItem:self.messagesLoaderItem tableRedraw:NO];
    
    [self.tableView reloadData];
    
    if(isOneSearchResult) {
        [self showMore:SearchSectionContacts animation:NO];
        [self showMore:SearchSectionDialogs animation:NO];
        [self showMore:SearchSectionUsers animation:NO];
        [self showMore:SearchSectionGlobalUsers animation:NO];
    }
    
    
    if(params.isRemoteLoaded) {
        [self showMessagesResults:params];
    } else {
        [self.tableView.containerView setHidden:self.tableView.count == 0];
    }

    
    
    
    DLog(@"search time %f", [params.startDate timeIntervalSinceNow]);

}

- (void)remoteSearch:(SearchParams *)params {
    if(params != self.searchParams || self.searchParams.isLoading || self.searchParams.isFinishLoading)
        return;
    
    self.searchParams.isLoading = YES;
    
    [RPCRequest sendRequest:[TLAPI_messages_search createWithPeer:[TL_inputPeerEmpty create] q:params.searchString filter:[TL_inputMessagesFilterEmpty create] min_date:0 max_date:0 offset:params.remote_offset max_id:0 limit:50] successHandler:^(RPCRequest *request, TL_messages_messagesSlice *response) {
        
        if(params != self.searchParams)
            return;
        
        self.searchParams.isLoading = NO;
        
        [[UsersManager sharedManager] add:response.users];
        [[ChatsManager sharedManager] add:response.chats];
        
        [TL_localMessage convertReceivedMessages:[response messages]];
        
        [[MessagesManager sharedManager] add:response.messages];
        
        [[Storage manager] insertChats:response.chats completeHandler:nil];
    
        if(!params.messages_count)
            params.messages_count = response.n_count ? response.n_count : (int)response.messages.count;
        
      
        params.remote_offset += (int)response.messages.count;
        
        if(params.messages_offset == params.messages_count)
            params.isFinishLoading = YES;
        
        if(!params.messages)
            params.messages = [NSMutableArray array];
        
        NSMutableArray *filterIds = [[NSMutableArray alloc] init];
        
        [params.messages enumerateObjectsUsingBlock:^(SearchMessageTableItem *obj, NSUInteger idx, BOOL *stop) {
            [filterIds addObject:@(obj.lastMessage.n_id)];
        }];
        
        NSArray *filtred = [response.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(self.n_id IN %@)",filterIds]];
        
        for(TL_localMessage *message in filtred) {
            
              [params.messages addObject:[[SearchMessageTableItem alloc] initWithMessage:message selectedText:params.searchString]];
        }
        
        params.messages_offset += (int)filtred.count;
        
        
        params.isRemoteLoaded = YES;
        if(params.isStorageLoaded) {
            [self showMessagesResults:params];
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        if(params != self.searchParams)
            return;
        
        self.searchParams.isLoading = NO;
    }];
}

- (void)showMessagesResults:(SearchParams *)params {
    if(params != self.searchParams)
        return;
    
    [self.tableView setDefaultAnimation:NSTableViewAnimationEffectNone];
    [self.tableView removeItem:self.messagesLoaderItem];
    
    if(!params.messages.count) {
        [self.tableView removeItem:self.messagesSeparator];
        [self.tableView removeItem:self.messagesLoadMoreItem];
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.tableView.containerView setHidden:self.tableView.count == 0];
        [CATransaction commit];
        return;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.tableView.containerView setHidden:NO];
    [CATransaction commit];
    
    if(params.messages_offset <= 50) {
        if([self.tableView isItemInList:self.messagesSeparator]) {
            [self.messagesSeparator setItemCount:params.messages_count];
            [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:self.tableView.count - 1] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
    }
    
   // int start = MAX(0, params.messages_offset - 50);
    NSRange range = NSMakeRange(params.messages_inserted, params.messages_offset - params.messages_inserted);
    
    params.messages_inserted+=range.length;
    
    
    NSArray *insertMessagesArray = [params.messages subarrayWithRange:range];
    
   // [self.tableView setDefaultAnimation:NSTableViewAnimationEffectNone];
    [self.tableView insert:insertMessagesArray startIndex:self.tableView.count tableRedraw:YES];
    
    
    DLog(@"count %lu", self.tableView.count);
    
    
}

- (void)searchByString:(NSString *)searchString {
    
    [self.tableView.containerView setHidden:NO];
    
    if(searchString.length == 0) {
        self.searchParams = nil;
        
    
        [self.tableView removeAllItems:YES];
        [self.tableView addItem:[[SearchLoaderItem alloc] init] tableRedraw:YES];
//        [self.tableView reloadData];
        return;
    }

    double duration = 0.1;
    
    __block SearchParams *searchParams = [[SearchParams alloc] init];
    searchParams.searchString = searchString;
    searchParams.startDate = [NSDate date];
    
    self.searchParams = searchParams;
    
    
    dispatch_after_seconds(duration, ^{
        
        if(self.searchParams != searchParams) {
            return;
        }
        
        
        [ASQueue dispatchOnStageQueue:^{
            NSMutableString *transform = [searchString mutableCopy];
            CFMutableStringRef bufferRef = (__bridge CFMutableStringRef)transform;
            CFStringTransform(bufferRef, NULL, kCFStringTransformLatinCyrillic, false);
            
            NSMutableString *transformReverse = [searchString mutableCopy];
            bufferRef = (__bridge CFMutableStringRef)transformReverse;
            CFStringTransform(bufferRef, NULL, kCFStringTransformLatinCyrillic, true);
            
            NSMutableArray *dialogs = [NSMutableArray array];
            NSMutableArray *dialogsNeedCheck = [NSMutableArray array];

            
            
            //Chats
            NSArray *searchChats = [[[ChatsManager sharedManager] all] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"((self.title CONTAINS[c] %@) OR (self.title CONTAINS[c] %@) OR (self.title CONTAINS[c] %@))", searchString, transform, transformReverse]];
        
            for(TLChat *chat in searchChats) {
                TL_conversation *dialog = chat.dialog;
                if(dialog && !dialog.fake)
                    [dialogs addObject:dialog];
                else
                    [dialogsNeedCheck addObject:@(-chat.n_id)];
            }
            
            //Users
            NSArray *searchUsers = [[[UsersManager sharedManager] all] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(self.fullName CONTAINS[c] %@) OR (self.phone CONTAINS[c] %@) OR (self.fullName CONTAINS[c] %@) OR (self.phone CONTAINS[c] %@) OR (self.fullName CONTAINS[c] %@) OR (self.phone CONTAINS[c] %@) ",searchString, searchString, transform, transform, transformReverse, transformReverse]];
            
            searchUsers = [searchUsers sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(TLUser *obj1, TLUser *obj2) {
                if(obj1.lastSeenTime > obj2.lastSeenTime) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedDescending;
                }
            }];
            
            for(TLUser *user in searchUsers) {
                TL_conversation *dialog = user.dialog;
                if(dialog && !dialog.fake)
                    [dialogs addObject:dialog];
                else
                    [dialogsNeedCheck addObject:@(user.n_id)];
            }
            
            
            NSMutableArray *cachePeers = [NSMutableArray array];
            
            
            if((self.type & SearchTypeDialogs) == SearchTypeDialogs) {
                
                
                
                
                [[Storage manager] searchDialogsByPeers:dialogsNeedCheck needMessages:NO searchString:nil completeHandler:^(NSArray *dialogsDB, NSArray *messagesDB, NSArray *searchMessagesDB) {
                    
                    
                    [[DialogsManager sharedManager] add:dialogsDB];
                    [[MessagesManager sharedManager] add:messagesDB];
                        
                    [dialogs addObjectsFromArray:dialogsDB];
                        
                    NSArray *insertedDialogs = [dialogs sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(TL_conversation *dialog1, TL_conversation *dialog2) {
                        if(dialog1.last_message_date > dialog2.last_message_date) {
                            return NSOrderedAscending;
                        } else {
                            return NSOrderedDescending;
                        }
                    }];
                        
                        
                    searchParams.dialogs = [NSMutableArray array];
                    for(TL_conversation *conversation in insertedDialogs) {
                            
                        [cachePeers addObject:@(conversation.peer.peer_id)];
                            
                        [searchParams.dialogs addObject:[[SearchItem alloc] initWithDialogItem:conversation searchString:searchString]];
                    }
                    
                    
                }];
                
                
            }
            
            
            if((self.type & SearchTypeContacts) == SearchTypeContacts) {
                
                searchParams.users = [NSMutableArray array];
                searchParams.contacts = [NSMutableArray array];
                
                for(TLUser *user in searchUsers) {
                    
                    if([cachePeers indexOfObject:@(user.n_id)] == NSNotFound) {
                        id item = [[SearchItem alloc] initWithUserItem:user searchString:searchParams.searchString];
                        
                        if(user.type == TLUserTypeContact) {
                            [searchParams.dialogs addObject:item];
                        }
                        
                        [cachePeers addObject:@(user.n_id)];
                        
                    }
                    
                }
                
            }
            
            if((self.type & SearchTypeGlobalUsers) == SearchTypeGlobalUsers && searchParams.searchString.length >= 5) {
                
                searchParams.globalUsers = [[NSMutableArray alloc] init];
                
                NSArray *filtred = [UsersManager findUsersByName:searchString];
                
                [filtred enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
                    
                    SearchItem *item = [[SearchItem alloc] initWithGlobalItem:obj searchString:searchString];
                    
                    [searchParams.globalUsers addObject:item];
                    
                }];
                
                
            }
            
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                [self showSearchResults:searchParams];
            }];
            
            searchParams.isNeedRemoteLoad = (self.type & SearchTypeMessages) == SearchTypeMessages;
            
            if((self.type & SearchTypeMessages) == SearchTypeMessages) {
                
                dispatch_after_seconds(0.1, ^{
                    // [self remoteSearch:searchParams];
                    [self localSearch:searchParams];
                });
            }
            
            searchParams.isNeedGlobalUsersLoad = ((self.type & SearchTypeGlobalUsers) == SearchTypeGlobalUsers && searchParams.searchString.length >= 5);
            
            if((self.type & SearchTypeGlobalUsers) == SearchTypeGlobalUsers && searchParams.searchString.length >= 5) {
                dispatch_after_seconds(0.1, ^{
                    [self remoteGlobalSearch:searchParams];
                });
            }
            
            
        }];
        
      
        
       
    });
}



- (void)showGlobalSearchResults:(SearchParams *)params {
    
}

-(void)remoteGlobalSearch:(SearchParams *)params {
    params.isLoading = YES;
    
    [RPCRequest sendRequest:[TLAPI_contacts_search createWithQ:params.searchString limit:100] successHandler:^(RPCRequest *request, TL_contacts_found *response) {
        
        
        if(self.searchParams != params)
            return;
        
        params.isLoading = NO;
        params.isRemoteGlobalUsersLoaded = YES;
        
        if(response.users.count > 0) {
            
            
            NSMutableArray *ids = [[NSMutableArray alloc] init];
            
            [params.globalUsers enumerateObjectsUsingBlock:^(SearchItem *obj, NSUInteger idx, BOOL *stop) {
                [ids addObject:@([obj.user n_id])];
            }];
            
            
            
            
            NSArray *filtred = [response.users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(self.n_id IN %@)",ids]];
            
            [[UsersManager sharedManager] add:filtred withCustomKey:@"n_id" update:YES];
            
            [filtred enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [params.globalUsers addObject:[[SearchItem alloc] initWithGlobalItem:obj searchString:params.searchString]];
            }];
            
        }
        
        [[ASQueue mainQueue] dispatchOnQueue:^{
            [self showSearchResults:params];
        }];
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
          params.isLoading = NO;
        
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
}


-(void)localSearch:(SearchParams *)params {
    
    
    self.searchParams.isLoading = YES;
    
    [[Storage manager] searchMessagesBySearchString:params.searchString offset:params.local_offset completeHandler:^(NSInteger count, NSArray *messages) {
        
        [ASQueue dispatchOnStageQueue:^{
            if(self.searchParams != params)
                return;
            
            [[MessagesManager sharedManager] add:messages];
            
            
            self.searchParams.isLoading = NO;
            
            params.local_offset += (int) count;
            
            
            params.messages_offset+= (int)count;
            
            params.messages_count+=(int)count;
            
            
            if(!params.messages)
                params.messages = [NSMutableArray array];
            
            for(TL_localMessage *message in messages)
                [params.messages addObject:[[SearchMessageTableItem alloc] initWithMessage:message selectedText:params.searchString]];
            
            if(params.messages.count > 0) {
                [[ASQueue mainQueue] dispatchOnQueue:^{
                     [self showMessagesResults:params];
                }];
            }
            
            
            
            if(count < 50) {
                params.isStorageLoaded = YES;
                params.messages_count = 0;
                [self remoteSearch:params];
            }

        }];
        
        
    }];
    
  
    
  
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tableView cancelSelection];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [TMTableView setCurrent:self.tableView];
}

@end