//
//  ShareViewController.m
//  TGShare
//
//  Created by keepcoder on 01.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ShareViewController.h"
#import "TGS_RPCRequest.h"
#import "TGS_MTNetwork.h"

#import "TMTableView.h"

#import "TGS_ConversationRowView.h"
#import "TGSModalSenderView.h"
#import "TMSearchTextField.h"
#import "BTRButton.h"

@interface TGSSearchRowItem : TMRowItem

@end


@implementation TGSSearchRowItem

static long h_r_l;

+(void)initialize {
    h_r_l = rand_long();
}

-(NSUInteger)hash {
    return h_r_l;
}

@end



@interface TGSSearchRowView : TMRowView
@property (nonatomic,strong) TMSearchTextField *searchField;
@end


@implementation TGSSearchRowView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _searchField = [[TMSearchTextField alloc] initWithFrame:NSMakeRect(5, 5, NSWidth(frameRect) - 20 , 30)];
        
        [_searchField setCenterByView:self];
        
        [self addSubview:_searchField];
  
    }
    
    return self;
}



@end

@interface ShareViewController ()<TMTableViewDelegate,TMSearchTextFieldDelegate>
@property (nonatomic,strong) TMTableView *tableView;

@property (nonatomic,strong) TGSModalSenderView *modalView;

@property (nonatomic,strong) TGSSearchRowItem *searchItem;
@property (nonatomic,assign) BOOL isLoaded;
@property (nonatomic,assign) BOOL isLocked;


@property (nonatomic,strong) BTRButton *sendButton;
@property (nonatomic,strong) BTRButton *cancelButton;

@property (nonatomic,strong) NSArray *searchItems;

@property (nonatomic,strong) NSMutableArray *items;

@property (nonatomic,strong) TGSSearchRowView *searchRowView;

@property (nonatomic,strong) NSMutableArray *contacts;

@property (nonatomic,assign) BOOL isSearchActive;


@end

@implementation ShareViewController

- (NSString *)nibName {
    return @"ShareViewController";
}

static ShareViewController *shareViewController;

- (void)loadView {
    [super loadView];
    
    shareViewController = self;
    
    _isLoaded = NO;
    
    _contacts = [[NSMutableArray alloc] init];
    _items = [[NSMutableArray alloc] init];
    
    _searchRowView = [[TGSSearchRowView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.view.bounds), 60)];
    
    _searchRowView.searchField.delegate = self;
    
    _modalView = [[TGSModalSenderView alloc] initWithFrame:self.view.bounds];
    
    [TGCache setMemoryLimit:20*1024*1024 group:IMGCACHE];
    
    _tableView = [[TMTableView alloc] initWithFrame:NSMakeRect(0, 50, NSWidth(self.view.bounds), NSHeight(self.view.bounds) - 50)];
    
    _tableView.tm_delegate = self;
    
    
    [self.view addSubview:_tableView.containerView];
    
    _cancelButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, roundf(NSWidth(self.view.frame)/2), 50)];
    
    _cancelButton.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    [_cancelButton setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
    
    [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forControlState:BTRControlStateNormal];
    
    
    weak();
    
    [_cancelButton addBlock:^(BTRControlEvents events) {
        
        NSError *cancelError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
        [weakSelf.extensionContext cancelRequestWithError:cancelError];
        
    } forControlEvents:BTRControlEventClick];
    
    [self.view addSubview:_cancelButton];
    

    _sendButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(_cancelButton.frame), 0, NSWidth(_cancelButton.frame), 50)];
    
    _sendButton.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    [_sendButton setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
    
    [_sendButton setTitle:NSLocalizedString(@"Share", nil) forControlState:BTRControlStateNormal];
    
    [_sendButton addBlock:^(BTRControlEvents events) {
        
        [weakSelf sendItems];
        
    } forControlEvents:BTRControlEventClick];
    
    [self.view addSubview:_sendButton];
    

    TMView *topSeparator = [[TMView alloc] initWithFrame:NSMakeRect(0, 49, NSWidth(self.view.frame), DIALOG_BORDER_WIDTH)];
    
    topSeparator.backgroundColor = DIALOG_BORDER_COLOR;
    
    [self.view addSubview:topSeparator];
    
    
    TMView *centerSeparator = [[TMView alloc] initWithFrame:NSMakeRect(NSWidth(_sendButton.frame) - 1, 0, DIALOG_BORDER_WIDTH, 50)];
    
    centerSeparator.backgroundColor = DIALOG_BORDER_COLOR;
    
    [self.view addSubview:centerSeparator];
    
    // Insert code here to customize the view
    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
    NSLog(@"Attachments = %@", item.attachments);
    
    
    
    
    _searchItem = [[TGSSearchRowItem alloc] init];
    
    [self.tableView removeAllItems:YES];
    
    [self.tableView insert:_searchItem atIndex:0 tableRedraw:YES];
    
    [self addScrollEvent];
    
    [TGSAppManager setMainView:self.view];
    

    [[TGS_MTNetwork instance] startNetwork];
    
    [self loadContacts];
    
}

-(void)searchFieldTextChange:(NSString *)searchString {
    
    _isSearchActive = searchString.length > 0;
    
    if(searchString.length > 0) {
        
        NSMutableString *transformed = [searchString mutableCopy];
        CFMutableStringRef bufferRef = (__bridge CFMutableStringRef)transformed;
        CFStringTransform(bufferRef, NULL, kCFStringTransformLatinCyrillic, false);
        
        NSMutableString *reversed = [searchString mutableCopy];
        bufferRef = (__bridge CFMutableStringRef)reversed;
        CFStringTransform(bufferRef, NULL, kCFStringTransformLatinCyrillic, true);
        
        NSArray *searchConversation = [_items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(self.user.first_name BEGINSWITH[c] %@) OR (self.user.first_name BEGINSWITH[c] %@) OR (self.user.first_name BEGINSWITH[c] %@)  OR (self.user.last_name BEGINSWITH[c] %@) OR (self.user.last_name BEGINSWITH[c] %@) OR (self.user.last_name BEGINSWITH[c] %@) OR (self.user.username BEGINSWITH[c] %@) OR (self.chat.title CONTAINS[c] %@) OR (self.chat.title CONTAINS[c] %@) OR (self.chat.title CONTAINS[c] %@)",searchString,transformed,reversed,searchString,transformed,reversed,searchString,transformed,reversed,searchString]];
        
        
        NSArray *searchContacts = [_contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"((self.user.first_name BEGINSWITH[c] %@) OR (self.user.first_name BEGINSWITH[c] %@) OR (self.user.first_name BEGINSWITH[c] %@)  OR (self.user.last_name BEGINSWITH[c] %@) OR (self.user.last_name BEGINSWITH[c] %@) OR (self.user.last_name BEGINSWITH[c] %@) OR (self.user.username BEGINSWITH[c] %@) )",searchString,transformed,reversed,searchString,transformed,reversed,searchString]];
        
        _searchItems = [searchConversation arrayByAddingObjectsFromArray:searchContacts];
     
        
    }
    
    NSRange range = NSMakeRange(1, _tableView.count-1);
    
    [[_tableView.list subarrayWithRange:range] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_tableView removeItem:obj tableRedraw:NO];
    }];
    
    [_tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] withAnimation:_tableView.defaultAnimation];
    
    
    [_tableView insert:_isSearchActive ? _searchItems : _items startIndex:1 tableRedraw:YES];
    
    
}




+(void)loadContacts {
    [shareViewController loadContacts];
}

+(void)close {
    
    NSError *cancelError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
    [shareViewController.extensionContext cancelRequestWithError:cancelError];
}

-(void)loadContacts {
    
    [TGS_RPCRequest sendRequest:[TLAPI_contacts_getContacts createWithN_hash:@""] successHandler:^(id request, id response) {
        
        [[response users] enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
            
            [_contacts addObject:[[TGS_ConversationRowItem alloc] initWithConversation:[TL_dialog createWithPeer:[TL_peerUser createWithUser_id:obj.n_id] top_message:0 read_inbox_max_id:0 unread_count:0 notify_settings:[TL_peerNotifySettingsEmpty create]] user:obj]];
            
        }];
        
        [self loadNext];
        
    } errorHandler:^(id request, RpcError *error) {
        
    }];
    
}

-(void)loadNext {
    
    if(_isLoaded)
        return;
    
    CHECK_LOCKER(_isLocked)
    
    _isLocked = YES;
    
     NSArray *items = [_tableView.list copy];
    
    __block TGS_ConversationRowItem *rowItem = [items lastObject];
    
    int date = 0;
    
    if([rowItem isKindOfClass:[TGS_ConversationRowItem class]]) {
        date = rowItem.date;
    }

    
    [TGS_RPCRequest sendRequest:[TLAPI_messages_getDialogs createWithOffset_date:date offset_id:0 offset_peer:[TL_inputPeerEmpty create] limit:100] successHandler:^(TGS_RPCRequest *request, TL_messages_dialogsSlice *response) {
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        [[response dialogs] enumerateObjectsUsingBlock:^(TLDialog *obj, NSUInteger idx, BOOL *stop) {
            
            TLMessage *message = [[response.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %d",obj.top_message]] lastObject];
            
            TGS_ConversationRowItem *item;
            
            if([obj.peer isKindOfClass:[TL_peerChat class]]) {
                NSArray *chats = [[response chats] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %d",obj.peer.chat_id]];
                
                if(chats.count == 1) {
                    item = [[TGS_ConversationRowItem alloc] initWithConversation:obj chat:chats[0]];
                }
            } else if([obj.peer isKindOfClass:[TL_peerUser class]]) {
                NSArray *users = [_contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.user.n_id == %d",obj.peer.user_id]];
                
                if(users.count == 1) {
                    item = users[0];
                } else {
                    users = [[response users] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %d",obj.peer.user_id]];
                    
                    if(users.count == 1)
                        item = [[TGS_ConversationRowItem alloc] initWithConversation:obj user:users[0]];
                }
            }
            
            item.date = message.date;
            if(item) {
                [items addObject:item];
            }
            
        }];
        
        [ASQueue dispatchOnMainQueue:^{
            
            [_items addObjectsFromArray:items];
            
            _isLocked = NO;
            
            if(!_isLoaded) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self loadNext];
                });
            }
            
            if(_isSearchActive)
                return;
            
            [_tableView insert:items startIndex:_tableView.count tableRedraw:YES];
            
            if([response isKindOfClass:[TL_messages_dialogs class]]) {
                _isLoaded = YES;
                [self removeScrollEvent];
            } else if(_tableView.count - 1 == [response n_count]) {
                _isLoaded = YES;
                [self removeScrollEvent];
            }
            
            
            
        }];
        
        
        
    } errorHandler:^(TGS_RPCRequest *request, RpcError *error) {
        _isLoaded = NO;
    } timeout:30 queue:[ASQueue globalQueue].nativeQueue];

}

- (void) addScrollEvent {
    id clipView = [[_tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

-(void)scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)notify {
    
    
    if(_tableView.scrollView.isNeedUpdateBottom && !_isLoaded && !_isSearchActive) {
        [self loadNext];
    }
    
}

- (void) removeScrollEvent {
    id clipView = [[_tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:clipView];
}


- (IBAction)send:(id)sender {
    NSExtensionItem *outputItem = [[NSExtensionItem alloc] init];
    
    NSArray *outputItems = @[outputItem];
    [self.extensionContext completeRequestReturningItems:outputItems completionHandler:nil];
}




- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return row == 0 ? 60 : 50;
}
- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    return row == 0 ? _searchRowView : [_tableView cacheViewForClass:[TGS_ConversationRowView class] identifier:NSStringFromClass([TGS_ConversationRowView class]) withSize:NSMakeSize(NSWidth(self.view.frame), [self rowHeight:row item:item])];
}
- (void)selectionDidChange:(NSInteger)row item:(TGS_ConversationRowItem *) item {
    
}

-(void)sendItems {
    
    NSArray *items = self.extensionContext.inputItems;
    
    [self.view addSubview:_modalView];
    
    
    NSMutableArray *rowItems = [[NSMutableArray alloc] init];
    
    [self.tableView.list enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, _tableView.count - 1)] options:0 usingBlock:^(TGS_ConversationRowItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.isSelected) {
            [rowItems addObject:obj];
        }
        
    }];
    
    if(rowItems.count == 0)
        return;
    
    [_modalView sendItems:items rowItems:rowItems completionHandler:^{
        
        [self.extensionContext completeRequestReturningItems:items completionHandler:nil];
        
    } errorHandler:^{
        
        NSError *cancelError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSExecutableRuntimeMismatchError userInfo:nil];
        [self.extensionContext cancelRequestWithError:cancelError];
        
    }];
}



- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return row > 0;
}
- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return row > 0;
}
@end

