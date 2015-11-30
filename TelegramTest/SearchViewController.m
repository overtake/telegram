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
#import "TLEncryptedChatCategory.h"
#import "TLEncryptedChat+Extensions.h"
#import "SearchLoadMoreCell.h"
#import "HackUtils.h"
#import "TLPeer+Extensions.h"
#import "SearchMessageCellView.h"
#import "SearchMessageTableItem.h"
#import "SearchHashtagItem.h"
#import "SearchHashtagCellView.h"
#import "TGConversationsTableView.h"
typedef enum {
    SearchSectionDialogs,
    SearchSectionContacts,
    SearchSectionUsers,
    SearchSectionMessages,
    SearchSectionGlobalUsers,
    SearchSectionChannels
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

@property (nonatomic,strong) NSArray *suggested_hashtags;


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
@property (nonatomic, strong) TMTableView *tableView;
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
@property (nonatomic, strong) SearchLoadMoreItem *globalChannelsLoadMoreItem;
@property (nonatomic, strong) SearchLoaderItem *messagesLoaderItem;


@property (nonatomic,assign) BOOL dontLoadHashtagsForOneRequest;

@end

@implementation SearchViewController

- (void)loadView {
    [super loadView];
    weakify();
    
    [self.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    self.contactsSeparator = [[SearchSeparatorItem alloc] initWithOneName:NSLocalizedString(@"Search.Separator.Contacts", nil) pluralName:NSLocalizedString(@"Search.Separator.Contacts", nil)];
    self.usersSeparator = [[SearchSeparatorItem alloc] initWithOneName:NSLocalizedString(@"Search.Separator.User", nil) pluralName:NSLocalizedString(@"Search.Separator.Users", nil)];
    self.messagesSeparator = [[SearchSeparatorItem alloc] initWithOneName:NSLocalizedString(@"Search.Separator.Messages", nil) pluralName:NSLocalizedString(@"Search.Separator.Messages", nil)];
    
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
    
    
    self.globalChannelsLoadMoreItem = [[SearchLoadMoreItem alloc] init];
    [self.globalChannelsLoadMoreItem setClickBlock:^{
        [strongSelf showMore:SearchSectionChannels animation:YES];
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
    
    
    self.tableView = [[TGConversationsTableView alloc] initWithFrame:self.view.bounds];
    self.tableView.tm_delegate = self;
    [self.tableView addItem:[[SearchLoaderItem alloc] init] tableRedraw:NO];
    [self.tableView reloadData];
    [self.view addSubview:self.tableView.containerView];
    
    [Notification addObserver:self selector:@selector(notificationDialogSelectionChanged:) name:@"ChangeDialogSelection"];
    
    [self addScrollEvent];
}

-(void)dontLoadHashTagsForOneRequest {
    _dontLoadHashtagsForOneRequest = YES;
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
        }
    }
    
}


//table
- (void)notificationDialogSelectionChanged:(NSNotification *)notify {
    id sender = [notify.userInfo objectForKey:@"sender"];
    
    if(sender != self) {
        TL_conversation *dialog = [notify.userInfo objectForKey:KEY_DIALOG];
        [self.tableView cancelSelection];

        if(![dialog isKindOfClass:NSNull.class] && dialog && self.searchParams.searchString.length > 0) {
            NSUInteger hash = [SearchItem hash:[[SearchItem alloc] initWithDialogItem:dialog searchString:self.searchParams.searchString]];
            [self.tableView setSelectedByHash:hash];
        }
    }
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *)item {
    if([item isKindOfClass:[SearchSeparatorItem class]]) {
        return [self.tableView cacheViewForClass:[SearchSeparatorTableCell class] identifier:@"SearchSeparatorTableCell" withSize:NSMakeSize(self.view.bounds.size.width, 27)];
    } else if ([item isKindOfClass:[SearchLoaderItem class]]) {
        return [self.tableView cacheViewForClass:[SearchLoaderCell class] identifier:@"SearchTableLoader" withSize:NSMakeSize(self.view.bounds.size.width, 66)];
    } if ([item isKindOfClass:[SearchLoadMoreItem class]]) {
        return [self.tableView cacheViewForClass:[SearchLoadMoreCell class] identifier:@"SearchTableLoadMore" withSize:NSMakeSize(self.view.bounds.size.width, 40)];
    } else if([item isKindOfClass:[SearchItem class]]) {
        return [self.tableView cacheViewForClass:[SearchTableCell class] identifier:@"SearchTableCell" withSize:NSMakeSize(self.view.bounds.size.width, 66)];
    } else if([item isKindOfClass:[SearchMessageTableItem class]]) {
        return [self.tableView cacheViewForClass:[SearchMessageCellView class] identifier:@"SearchMessageTableItem" withSize:NSMakeSize(self.view.bounds.size.width, 66)];
    } else if([item isKindOfClass:[SearchHashtagItem class]]) {
        return [self.tableView cacheViewForClass:[SearchHashtagCellView class] identifier:@"SearchHashtagCellView" withSize:NSMakeSize(self.view.bounds.size.width, 40)];
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
    } else if([item isKindOfClass:[SearchHashtagItem class]])  {
        return 40;
    } else {
        return 66;
    }
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    if(![[Telegram rightViewController] isModalViewActive]) {
        
        BOOL res = ![Telegram rightViewController].navigationViewController.isLocked;
        
        
        return res;
    }
    
    if(item && (![item isKindOfClass:[SearchSeparatorItem class]])) {
        TGConversationTableItem *searchItem = (TGConversationTableItem *)item;
        
        if(searchItem.conversation) {
            [[Telegram rightViewController] modalViewSendAction:searchItem.conversation];
        }
    }

    return NO;
}



- (void)selectionDidChange:(NSInteger)row item:(TMRowItem *)item {
    
    if(item && ([item isKindOfClass:[TGConversationTableItem class]] || [item isKindOfClass:[SearchItem class]])) {
        SearchItem *searchItem = (SearchItem *) item;
        
        TL_conversation *dialog = searchItem.conversation;
        
        if(!dialog)
            dialog = searchItem.user.dialog;
        
        int msg_id = [searchItem respondsToSelector:@selector(message)] ? searchItem.message.n_id : 0;
        
        if([item isKindOfClass:[SearchMessageTableItem class]]) {
            msg_id = [[(SearchMessageTableItem *)searchItem message] n_id];
        } else {
            StandartViewController *controller = (StandartViewController *) [[Telegram leftViewController] currentTabController];
            
            if([controller isKindOfClass:[StandartViewController class]] && dialog) {
                [controller hideSearchViewControllerWithConversationUsed:dialog];
            }
            
            
        }
        
        if(dialog){
            
            
            [appWindow().navigationController showMessagesViewController:dialog withMessage:searchItem.message];
            
            
          
          //  [self searchByString:@""];
            
//            BOOL success = [[Telegram rightViewController] showByDialog:dialog withJump:msg_id historyFilter:[HistoryFilter class] sender:self];
//            if(!success) {
//                [[Telegram rightViewController].messagesViewController setCurrentConversation:dialog withJump:msg_id historyFilter:[HistoryFilter class]];
//            }
            [self.tableView setSelectedByHash:item.hash];
        }
    } else if(item && [item isKindOfClass:[SearchHashtagItem class]]) {
        
        TMViewController *controller = [[Telegram leftViewController] currentTabController];
        
        if([controller isKindOfClass:[StandartViewController class]]) {
            [self dontLoadHashTagsForOneRequest];
            [Telegram saveHashTags:((SearchHashtagItem *)item).hashtag peer_id:0];
            [(StandartViewController *)controller searchByString:((SearchHashtagItem *)item).hashtag];
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
    
    
    if(params.suggested_hashtags.count > 0) {
        
        
        [self.tableView insert:params.suggested_hashtags startIndex:[self.tableView count] tableRedraw:NO];
        
        isNeedSeparator = YES;
        
    }
    
    if(params.dialogs.count) {
        
        if(isNeedSeparator) {
            [self.tableView addItem:self.contactsSeparator tableRedraw:NO];
            isOneSearchResult = NO;
        }
        
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
            for(int i = 0; i < insertCount; i++)
                [self.tableView addItem:[params.globalUsers objectAtIndex:i] tableRedraw:NO];
            
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
     //   [self.tableView.containerView setHidden:self.tableView.count == 0];
    }

    
    
    
    MTLog(@"search time %f", [params.startDate timeIntervalSinceNow]);

}

- (void)remoteSearch:(SearchParams *)params {
    if(params != self.searchParams || self.searchParams.isLoading || self.searchParams.isFinishLoading)
        return;
    
    self.searchParams.isLoading = YES;
    
    
    int offset_id = [[(SearchMessageTableItem *)[params.messages lastObject] message] n_id];
    int offset_date = [[(SearchMessageTableItem *)[params.messages lastObject] message] date];
    
    id request = ACCEPT_FEATURE ? [TLAPI_messages_searchGlobal createWithQ:params.searchString offset_date:offset_date offset_peer:[TL_inputPeerEmpty create] offset_id:offset_id limit:50] : [TLAPI_messages_search createWithFlags:0 peer:[TL_inputPeerEmpty create] q:params.searchString filter:[TL_inputMessagesFilterEmpty create] min_date:0 max_date:0 offset:params.remote_offset max_id:0 limit:50];
    
    [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_messagesSlice *response) {

        
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
            [filterIds addObject:@(obj.message.n_id)];
        }];
        
        NSArray *filtred = [response.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(self.n_id IN %@)",filterIds]];
        
        for(TL_localMessage *message in filtred) {
            
              [params.messages addObject:[[SearchMessageTableItem alloc] initWithMessage:message selectedText:params.searchString]];
        }
        
        params.messages_offset += (int)filtred.count;
        
        
        params.isRemoteLoaded = YES;
        [self showMessagesResults:params];
        
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
    
    
    self.messagesSeparator.itemCount = params.isLoading  ? -1 : (int)params.messages.count;
    
    if(!params.messages.count) {
        [self.tableView removeItem:self.messagesSeparator];
        [self.tableView removeItem:self.messagesLoadMoreItem];
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.tableView.containerView setHidden:self.tableView.count == 0];
        [CATransaction commit];
        return;
    } else if(self.searchParams.dialogs.count > 0) {
        [self.tableView addItem:self.messagesSeparator tableRedraw:YES];
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.tableView.containerView setHidden:NO];
    [CATransaction commit];
    
    if(params.messages_offset <= 50) {
        if([self.tableView isItemInList:self.messagesSeparator]) {
          //  [self.messagesSeparator setItemCount:params.messages_count];
            [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:self.tableView.count - 1] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
    }
    
    NSRange range = NSMakeRange(params.messages_inserted, params.messages_offset - params.messages_inserted);
    
    params.messages_inserted+=range.length;
    
    
    NSArray *insertMessagesArray = [params.messages subarrayWithRange:range];
    
    [self.tableView insert:insertMessagesArray startIndex:self.tableView.count tableRedraw:YES];
    
    
    MTLog(@"count %lu", self.tableView.count);
    
}

-(int)selectedPeerId {
    return ((SearchItem *)self.tableView.selectedItem).conversation.peer_id;
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
    
    
        if(self.searchParams != searchParams) {
            return;
        }
        
    
            
            NSMutableArray *dialogs = [NSMutableArray array];
            NSMutableArray *dialogsNeedCheck = [NSMutableArray array];

            
    
            //Chats
            NSArray *searchChats = [[ChatsManager sharedManager] searchWithString:searchString selector:@"title"];
        
            for(TLChat *chat in searchChats) {
                TL_conversation *dialog = chat.dialog;
                if(dialog && !dialog.fake && ([chat isKindOfClass:[TLChat class]] && !chat.isDeactivated))
                    [dialogs addObject:dialog];
                else if ([chat isKindOfClass:[TLChat class]] && !chat.isDeactivated)
                    [dialogsNeedCheck addObject:@(-chat.n_id)];
            }
            
            //Users
            NSArray *searchUsers = [[UsersManager sharedManager] searchWithString:searchString selector:@"fullName"];
    
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
                
                
                if([searchString hasPrefix:@"#"] && !_dontLoadHashtagsForOneRequest) {
                    
                    NSString *hs = [searchString substringFromIndex:1];
                    
                    
                    __block NSMutableDictionary *tags;
                    
                    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                        
                        tags = [transaction objectForKey:@"htags" inCollection:@"hashtags"];
                        
                    }];
                    
                    
                    NSArray *list = [[tags allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        
                        return obj1[@"count"] < obj2[@"count"];
                        
                    }];
                    
                    
                    if(hs.length > 0)
                    {
                        list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag BEGINSWITH[c] %@",hs]];
                    }
                    
                    
                    if(list.count > 0)
                    {
                        
                        NSMutableArray *items = [[NSMutableArray alloc] init];
                        
                        [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            [items addObject:[[SearchHashtagItem alloc] initWithObject:obj[@"tag"]]];
                        }];
                        
                        searchParams.suggested_hashtags = items;
                    }
                    
                    [ASQueue dispatchOnMainQueue:^{
                         [self showSearchResults:searchParams];
                    }];
                    
               }
                
                
                _dontLoadHashtagsForOneRequest = NO;
                
                
                [[Storage manager] searchDialogsByPeers:dialogsNeedCheck needMessages:NO searchString:nil completeHandler:^(NSArray *dialogsDB) {
                    
                    [[DialogsManager sharedManager] add:dialogsDB];
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
            
            if((self.type & SearchTypeGlobalUsers) == SearchTypeGlobalUsers) {
                
                searchParams.globalUsers = [[NSMutableArray alloc] init];
                
                NSArray *filtred = [UsersManager findUsersByName:searchString];
                
                [filtred enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
                    
                    if(searchParams.searchString.length >= 5 || obj.isContact) {
                        SearchItem *item = [[SearchItem alloc] initWithGlobalItem:obj searchString:searchString];
                        
                        [searchParams.globalUsers addObject:item];
                    }
                }];
                
                
            }
            
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                [self showSearchResults:searchParams];
            }];
            
            searchParams.isNeedRemoteLoad = (self.type & SearchTypeMessages) == SearchTypeMessages;
            
            if((self.type & SearchTypeMessages) == SearchTypeMessages) {
                
                
                NSString *string = searchParams.searchString;
                
                NSString *specialCharacterString = @"!~`@#$%^&*-+();:={}[],.<>?\\/\"\'";
                NSCharacterSet *specialCharacterSet = [NSCharacterSet
                                                       characterSetWithCharactersInString:specialCharacterString];
                
                
                while ([string.lowercaseString rangeOfCharacterFromSet:specialCharacterSet].location != NSNotFound) {
                    string = [string substringFromIndex:1];
                }
                
                if(string.length == 0) {
                    self.searchParams.isNeedRemoteLoad = NO;
                    self.searchParams.isFinishLoading = YES;
                } else {
                    dispatch_after_seconds(0.1, ^{
                         [self remoteSearch:searchParams];
                    });
                }
                
                
            }
            
            searchParams.isNeedGlobalUsersLoad = ((self.type & SearchTypeGlobalUsers) == SearchTypeGlobalUsers && searchParams.searchString.length >= 5);
            
            if((self.type & SearchTypeGlobalUsers) == SearchTypeGlobalUsers && searchParams.searchString.length >= 5) {
                dispatch_after_seconds(0.1, ^{
                    [self remoteGlobalSearch:searchParams];
                });
            }
            
            
      //  }];
    
    
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
        
        if(response.users.count > 0 || response.chats > 0) {
            
            NSMutableArray *chatIds = [[NSMutableArray alloc] init];
            
            NSMutableArray *ids = [[NSMutableArray alloc] init];
            
            [params.globalUsers enumerateObjectsUsingBlock:^(SearchItem *obj, NSUInteger idx, BOOL *stop) {
                if(obj.user)
                    [ids addObject:@([obj.user n_id])];
                else
                    [chatIds addObject:@([obj.chat n_id])];
            }];
            
            

            NSArray *acceptUsers = [response.users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(self.n_id IN %@)",ids]];
            
            NSArray *acceptChats = [response.chats filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(self.n_id IN %@)",ids]];
            
            [[UsersManager sharedManager] add:acceptUsers withCustomKey:@"n_id" update:YES];
            
            [[ChatsManager sharedManager] add:acceptChats];
            
            [[acceptChats arrayByAddingObjectsFromArray:acceptUsers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView.scrollView.contentView setFrameSize:self.tableView.scrollView.frame.size];

    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
    });
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