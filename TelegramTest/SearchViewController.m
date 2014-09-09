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
#import "TGEncryptedChatCategory.h"
#import "TGEncryptedChat+Extensions.h"
#import "DialogTableItemView.h"
#import "SearchLoadMoreCell.h"
#import "HackUtils.h"
#import "TGPeer+Extensions.h"

typedef enum {
    SearchSectionDialogs,
    SearchSectionContacts,
    SearchSectionUsers,
    SearchSectionMessages
} SearchSection;

@interface SearchParams : NSObject
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSString *searchString;

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *dialogs;
@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic) int messages_offset;
@property (nonatomic) int messages_count;

@property (atomic) BOOL isStorageLoaded;
@property (atomic) BOOL isRemoteLoaded;
@property (atomic) BOOL isLoading;
@property (atomic) BOOL isFinishLoading;


@property (atomic) BOOL isNeedRemoteLoad;
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

@property (nonatomic, strong) SearchLoadMoreItem *dialogsLoadMoreItem;
@property (nonatomic, strong) SearchLoadMoreItem *contactsLoadMoreItem;
@property (nonatomic, strong) SearchLoadMoreItem *usersLoadMoreItem;
@property (nonatomic, strong) SearchLoadMoreItem *messagesLoadMoreItem;
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
  //  [self.tableView setBackgroundColor:[NSColor redColor]];
    [self.view addSubview:self.tableView.containerView];
    
    [self.tableView setBackgroundColor:[NSColor whiteColor]];
    
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
    
    [self remoteSearch:self.searchParams];
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
    } else if ([item isKindOfClass:[DialogTableItem class]]) {
        DialogTableItemView *view = (DialogTableItemView *)[self.tableView cacheViewForClass:[DialogTableItemView class] identifier:@"SearchTableItem"];
        [view setSwipePanelActive:NO];
        return view;
        
    } if ([item isKindOfClass:[SearchLoaderItem class]]) {
        return [self.tableView cacheViewForClass:[SearchLoaderCell class] identifier:@"SearchTableLoader" withSize:NSMakeSize(self.view.bounds.size.width, DIALOG_CELL_HEIGHT)];
    } if ([item isKindOfClass:[SearchLoadMoreItem class]]) {
        return [self.tableView cacheViewForClass:[SearchLoadMoreCell class] identifier:@"SearchTableLoadMore" withSize:NSMakeSize(self.view.bounds.size.width, 40)];
    } else {
        return [self.tableView cacheViewForClass:[SearchTableCell class] identifier:@"SearchTableCell" withSize:NSMakeSize(self.view.bounds.size.width, DIALOG_CELL_HEIGHT)];
    }
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
        return YES;
    }
    
    if(item && (![item isKindOfClass:[SearchSeparatorItem class]])) {
        DialogTableItem *searchItem = (DialogTableItem *)item;
        
        if(searchItem.dialog) {
            [[Telegram rightViewController] modalViewSendAction:searchItem.dialog];
        } else if(searchItem.user) {
            [[Telegram rightViewController] modalViewSendAction:[[DialogsManager sharedManager] findByUserId:searchItem.user.n_id]];
        }
                
    }

    return NO;
}



- (void)selectionDidChange:(NSInteger)row item:(TMRowItem *)item {
    
    if(item && ([item isKindOfClass:[DialogTableItem class]] || [item isKindOfClass:[SearchItem class]])) {
        SearchItem *searchItem = (SearchItem *) item;
        
        TL_conversation *dialog = searchItem.dialog;
        
        if(!dialog)
            dialog = searchItem.user.dialog;
        
        int msg_id = [searchItem respondsToSelector:@selector(message)] ? searchItem.message.n_id : 0;
        
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
    
    
    //MessagesLoader
    if(isNeedSeparator && params.isNeedRemoteLoad) {
        [self.tableView addItem:self.messagesSeparator tableRedraw:NO];
        [self.messagesSeparator setItemCount:-1];
        isOneSearchResult = NO;
    }
    if(params.isNeedRemoteLoad)
        [self.tableView addItem:self.messagesLoaderItem tableRedraw:NO];

    [self.tableView reloadData];
    
    if(isOneSearchResult) {
        [self showMore:SearchSectionContacts animation:NO];
        [self showMore:SearchSectionDialogs animation:NO];
        [self showMore:SearchSectionUsers animation:NO];
    }
    
    
    
   
    
    if(params.isRemoteLoaded) {
        [self showMessagesResults:params];
    } else {
        [self.noResultsView setHidden:self.tableView.count > 0];
        [self.tableView.containerView setHidden:self.tableView.count == 0];
    }
    
    DLog(@"search time %f", [params.startDate timeIntervalSinceNow]);

}

- (void)remoteSearch:(SearchParams *)params {
    if(params != self.searchParams || self.searchParams.isLoading || self.searchParams.isFinishLoading)
        return;
    
    self.searchParams.isLoading = YES;
    
    [RPCRequest sendRequest:[TLAPI_messages_search createWithPeer:[TL_inputPeerEmpty create] q:params.searchString filter:[TL_inputMessagesFilterEmpty create] min_date:0 max_date:0 offset:params.messages_offset max_id:0 limit:50] successHandler:^(RPCRequest *request, TL_messages_messagesSlice *response) {
        
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
        
        params.messages_offset += (int)response.messages.count;
        
        
        if(params.messages_offset == params.messages_count)
            params.isFinishLoading = YES;
        
        if(!params.messages)
            params.messages = [NSMutableArray array];
        
        for(TGMessage *message in response.messages)
            [params.messages addObject:[[SearchItem alloc] initWithMessageItem:message searchString:params.searchString]];
        
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
    
    if(!params.messages_count) {
        [self.tableView removeItem:self.messagesSeparator];
        [self.tableView removeItem:self.messagesLoadMoreItem];
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.tableView.containerView setHidden:self.tableView.count == 0];
        [self.noResultsView setHidden:self.tableView.count > 0];
        [CATransaction commit];
        return;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.tableView.containerView setHidden:NO];
    [self.noResultsView setHidden:YES];
    [CATransaction commit];
    
    if(params.messages_offset <= 50) {
        if([self.tableView isItemInList:self.messagesSeparator]) {
            [self.messagesSeparator setItemCount:params.messages_count];
            [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:self.tableView.count - 1] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
    }
    
    int start = MAX(0, params.messages_offset - 50);
    NSRange range = NSMakeRange(start, params.messages_offset - start);
    NSArray *insertMessagesArray = [params.messages subarrayWithRange:range];
    
    [self.tableView setDefaultAnimation:params.messages_offset <= 50 ? NSTableViewAnimationEffectNone : NSTableViewAnimationSlideUp];
    [self.tableView insert:insertMessagesArray startIndex:self.tableView.count tableRedraw:YES];
    
    
    DLog(@"count %lu", self.tableView.count);
    
}

- (void)searchByString:(NSString *)searchString {
    
    [self.tableView.containerView setHidden:NO];
    [self.noResultsView setHidden:YES];
    if(searchString.length == 0) {
        self.searchParams = nil;
        
    
        [self.tableView removeAllItems:YES];
        [self.tableView addItem:[[SearchLoaderItem alloc] init] tableRedraw:YES];
        return;
    }

    double duration = 0.1;
    
    __block SearchParams *searchParams = [[SearchParams alloc] init];
    searchParams.searchString = searchString;
    searchParams.startDate = [NSDate date];
    
    self.searchParams = searchParams;
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
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
        
            for(TGChat *chat in searchChats) {
                TL_conversation *dialog = chat.dialog;
                if(dialog && !dialog.fake)
                    [dialogs addObject:dialog];
                else
                    [dialogsNeedCheck addObject:@(-chat.n_id)];
            }
            
            //Users
            NSArray *searchUsers = [[[UsersManager sharedManager] all] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(self.fullName CONTAINS[c] %@) OR (self.phone CONTAINS[c] %@) OR (self.fullName CONTAINS[c] %@) OR (self.phone CONTAINS[c] %@) OR (self.fullName CONTAINS[c] %@) OR (self.phone CONTAINS[c] %@)", searchString, searchString, transform, transform, transformReverse, transformReverse]];
            
            searchUsers = [searchUsers sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(TGUser *obj1, TGUser *obj2) {
                if(obj1.lastSeenTime > obj2.lastSeenTime) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedDescending;
                }
            }];
            
            for(TGUser *user in searchUsers) {
                TL_conversation *dialog = user.dialog;
                if(dialog && !dialog.fake)
                    [dialogs addObject:dialog];
                else
                    [dialogsNeedCheck addObject:@(user.n_id)];
            }
            
            if((self.type & SearchTypeDialogs) == SearchTypeDialogs) {
                [[Storage manager] searchDialogsByPeers:dialogsNeedCheck needMessages:NO searchString:nil completeHandler:^(NSArray *dialogsDB, NSArray *messagesDB, NSArray *searchMessagesDB) {
                    
                    
                    [ASQueue dispatchOnStageQueue:^{
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
                        
                        
                        NSMutableArray *cachePeers = [NSMutableArray array];
                        
                        searchParams.dialogs = [NSMutableArray array];
                        for(TL_conversation *dialog in insertedDialogs) {
                            
                            [cachePeers addObject:@(dialog.peer.peer_id)];
                            
                            [searchParams.dialogs addObject:[[DialogTableItem alloc] initWithDialogItem:dialog selectString:searchParams.searchString]];
                        }
                        
                        searchParams.users = [NSMutableArray array];
                        searchParams.contacts = [NSMutableArray array];
                        
                        if((self.type & SearchTypeContacts) == SearchTypeContacts) {
                            for(TGUser *user in searchUsers) {
                                if([cachePeers indexOfObject:@(user.n_id)] == NSNotFound) {
                                    id item = [[SearchItem alloc] initWithUserItem:user searchString:searchParams.searchString];
                                    [(user.type == TGUserTypeContact ? searchParams.contacts : searchParams.users) addObject:item];
                                }
                            }
                        }
                        
                        
                        
                        [[ASQueue mainQueue] dispatchOnQueue:^{
                            searchParams.isStorageLoaded = YES;
                            
                            [self showSearchResults:searchParams];
                        }];
                        
                    }];
                }];
            } else {
                if((self.type & SearchTypeContacts) == SearchTypeContacts) {
                    
                    searchParams.users = [NSMutableArray array];
                    searchParams.contacts = [NSMutableArray array];
                    
                    for(TGUser *user in searchUsers) {
                        id item = [[SearchItem alloc] initWithUserItem:user searchString:searchParams.searchString];
                        
                        [(user.type == TGUserTypeContact ? searchParams.contacts : searchParams.users) addObject:item];
                    }
                    
                   
                    
                    [[ASQueue mainQueue] dispatchOnQueue:^{
                        [self showSearchResults:searchParams];
                    }];
                    
                }
                
            }
            
            
        }];
        
        searchParams.isNeedRemoteLoad = (self.type & SearchTypeMessages) == SearchTypeMessages;
        
        if((self.type & SearchTypeMessages) == SearchTypeMessages) {
             [self remoteSearch:searchParams];
        }
        
       
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [TMTableView setCurrent:self.tableView];
}

@end