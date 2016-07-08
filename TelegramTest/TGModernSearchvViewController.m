//
//  TGModernSearchvViewController.m
//  Telegram
//
//  Created by keepcoder on 06/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernSearchvViewController.h"
#import "TGModernSearchSignals.h"
#import "TGSettingsTableView.h"
#import "TGModernSearchResult.h"
#import "SearchSeparatorItem.h"
#import "SearchLoadMoreItem.h"
#import "TGModernSearchItem.h"
#import "SearchMessageTableItem.h"
#import "SearchLoaderItem.h"
#import "SearchHashtagItem.h"
@interface TGSearchClipView : NSClipView
@end

@implementation TGSearchClipView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor whiteColor] set];
    NSRectFill(dirtyRect);
    
    [DIALOG_BORDER_COLOR set];
    NSRectFill(NSMakeRect(NSWidth(self.frame) - DIALOG_BORDER_WIDTH, dirtyRect.origin.y, DIALOG_BORDER_WIDTH, dirtyRect.size.height));
}

@end

@interface TGSearchTableView : TGSettingsTableView

@end

@implementation TGSearchTableView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self =[super initWithFrame:frameRect]) {
        [self setBackgroundColor:[NSColor clearColor]];
        id document = self.scrollView.documentView;
        TGSearchClipView *clipView = [[TGSearchClipView alloc] initWithFrame:self.scrollView.contentView.bounds];
        [clipView setWantsLayer:YES];
        [clipView setDrawsBackground:YES];
        [self.scrollView setContentView:clipView];
        self.scrollView.documentView = document;
        
        [[self.scrollView verticalScroller] setHidden:YES];
    }
    
    return self;
}


- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    if(![[Telegram rightViewController] isModalViewActive]) {
        return !appWindow().navigationController.isLocked;
    }
    
    if(item && (![item isKindOfClass:[SearchSeparatorItem class]] && ![item isKindOfClass:[SearchLoadMoreItem class]])) {
        TGModernSearchItem *searchItem = (TGModernSearchItem *)item;
        if(searchItem.conversation) {
            [[Telegram rightViewController] modalViewSendAction:searchItem.conversation];
        }
    }
    
    return NO;
}



- (void)selectionDidChange:(NSInteger)row item:(TMRowItem *)item {
    
    if(item && ([item isKindOfClass:[SearchMessageTableItem class]] || [item isKindOfClass:[TGModernSearchItem class]])) {
        TGModernSearchItem *searchItem = (TGModernSearchItem *) item;
        
        TL_conversation *conversation = searchItem.conversation;
        TL_localMessage *message = nil;
        
        if([item isKindOfClass:[SearchMessageTableItem class]]) {
            message = [(SearchMessageTableItem *)searchItem message];
        } else {
            StandartViewController *controller = (StandartViewController *) [[Telegram leftViewController] currentTabController];
            
            if([controller isKindOfClass:[StandartViewController class]] && conversation) {
                [controller hideSearchViewControllerWithConversationUsed:conversation];
            }
            
        }
        
        if(conversation){
            [appWindow().navigationController showMessagesViewController:conversation withMessage:message];
            [self setSelectedByHash:item.hash];
        }
    } else if(item && [item isKindOfClass:[SearchHashtagItem class]]) {
        
        TMViewController *controller = [[Telegram leftViewController] currentTabController];
        if([controller isKindOfClass:[StandartViewController class]]) {
         //   [self dontLoadHashTagsForOneRequest];
            [Telegram saveHashTags:((SearchHashtagItem *)item).hashtag peer_id:0];
            [(StandartViewController *)controller searchByString:((SearchHashtagItem *)item).hashtag];
        }
    }
}

- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *)item {
    return !([item isKindOfClass:[SearchSeparatorItem class]] || [item isKindOfClass:[SearchLoaderItem class]] || [item isKindOfClass:[SearchLoadMoreItem class]]);
}

@end

@interface TGModernSearchvViewController ()
@property (nonatomic,strong) id<SDisposable> dispose;
@property (nonatomic,strong) TGSettingsTableView *tableView;
@property (nonatomic, strong) TMView *noResultsView;


@property (nonatomic, strong) SearchSeparatorItem *messagesSeparator;
@property (nonatomic, strong) SearchSeparatorItem *globalUsersSeparator;

@end

@implementation TGModernSearchvViewController

-(void)loadView {
    [super loadView];
    
    weak();
    
    [self.view setBackgroundColor:[NSColor whiteColor]];
    
    _noResultsView = [[TMView alloc] initWithFrame:self.view.bounds];
    [_noResultsView setDrawBlock:^{
        [DIALOG_BORDER_COLOR set];
        NSRectFill(NSMakeRect(weakSelf.view.bounds.size.width - DIALOG_BORDER_WIDTH, 0, DIALOG_BORDER_WIDTH, weakSelf.view.bounds.size.height));
    }];
    
    [_noResultsView setAutoresizesSubviews:YES];
    
    NSImageView *noResultsImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, image_noResults().size.width, image_noResults().size.height)];
    [noResultsImageView setImage:image_noResults()];
    [noResultsImageView setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin | NSViewWidthSizable | NSViewHeightSizable];
    
    [_noResultsView setCenterByView:self.view];
    [_noResultsView addSubview:noResultsImageView];
    [_noResultsView setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin | NSViewWidthSizable | NSViewHeightSizable];
    [noResultsImageView setCenterByView:self.view];
    [self.view addSubview:_noResultsView];

    
    
    _messagesSeparator = [[SearchSeparatorItem alloc] initWithOneName:NSLocalizedString(@"Search.Separator.Messages", nil) pluralName:NSLocalizedString(@"Search.Separator.Messages", nil)];
    
    _globalUsersSeparator = [[SearchSeparatorItem alloc] initWithOneName:NSLocalizedString(@"Search.Separator.GlobalSearch", nil) pluralName:NSLocalizedString(@"Search.Separator.GlobalSearch", nil)];
    
    
    _tableView = [[TGSearchTableView alloc] initWithFrame:self.view.frame];
    
    _tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    
    [self.view addSubview:_tableView.containerView];

}

-(void)search:(NSString *)search {
    
    search = [search trim];
    
    [_dispose dispose];
    
    SSignal *usersAndChats = [TGModernSearchSignals usersAndChatsSignal:search];
    SSignal *globalUsers = [TGModernSearchSignals globalUsersSignal:search];
    SSignal *messages = [TGModernSearchSignals messagesSignal:search];
    
    SSignal *combined = search.length >= 5 ? [SSignal combineSignals:@[usersAndChats,globalUsers,messages] withInitialStates:@[[NSNull null],[NSNull null],[NSNull null]]] : [SSignal combineSignals:@[usersAndChats,messages] withInitialStates:@[[NSNull null],[NSNull null]]];
    
    _dispose = [combined startWithNext:^(NSArray *result) {
        
        [_tableView removeAllItems:NO];
        
        void (^moreblock)(NSArray *items) = ^(NSArray *items) {
            SearchLoadMoreItem *more = [[SearchLoadMoreItem alloc] initWithObject:items callback:^(SearchLoadMoreItem *item){
                
                [_tableView insert:item.items startIndex:[_tableView indexOfItem:item] tableRedraw:YES];
                [_tableView removeItem:item tableRedraw:YES];
            }];
            
            [_tableView addItem:more tableRedraw:NO];
        };
        
        const int moreCount = 3;
        
        
        id first = result.count >= 1 ? result[0] : nil;
        id second = result.count >= 2 ? result[1] : nil;
        id thrid = result.count >= 3 ? result[2] : nil;
        
        if(first && first != [NSNull null]) {
            if([first count] > 0) {
                [_tableView insert:[first subarrayWithRange:NSMakeRange(0, MIN([first count],moreCount))] startIndex:_tableView.count tableRedraw:NO];
                if([first count] > moreCount) {
                    moreblock([first subarrayWithRange:NSMakeRange(moreCount, [first count]-moreCount)]);
                }
            }
        }
        
        if(second && second != [NSNull null]) {
            if([second count] > 0) {
                if(_tableView.count > 0)
                    [_tableView addItem:result.count == 3 ? _globalUsersSeparator : _messagesSeparator tableRedraw:NO];
                
                [_tableView insert:[second subarrayWithRange:NSMakeRange(0, MIN([second count],moreCount))] startIndex:_tableView.count tableRedraw:NO];
                if([second count] > 3 && result.count == 3) {
                    moreblock([second subarrayWithRange:NSMakeRange(moreCount, [second count]-moreCount)]);
                }
            }
        } else if(second) {
            if(_tableView.count > 0)
                [_tableView addItem:result.count == 3 ? _globalUsersSeparator : _messagesSeparator tableRedraw:NO];
            [_tableView addItem:[[SearchLoaderItem alloc] init] tableRedraw:NO];
        }
        
        
        if(thrid && thrid != [NSNull null]) {
            if([thrid count] > 0) {
                if(_tableView.count > 0)
                    [_tableView addItem:_messagesSeparator tableRedraw:NO];
                [_tableView insert:thrid startIndex:_tableView.count tableRedraw:NO];
            }
        } else if(thrid) {
            if(_tableView.count > 0)
                [_tableView addItem:_messagesSeparator tableRedraw:NO];
            [_tableView addItem:[[SearchLoaderItem alloc] init] tableRedraw:NO];
        }
        
        [_tableView reloadData];
        
        [_tableView.containerView setHidden:_tableView.count == 0];
        
    } error:^(id error) {
        
        
        
    } completed:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_dispose dispose];
    [_tableView removeAllItems:NO];
    [_tableView reloadData];
}

-(void)dealloc {
    [_tableView clear];
}


-(int)selectedPeerId {
    return ((TGModernSearchItem *)self.tableView.selectedItem).conversation.peer_id;
}

- (void)selectFirst {
    
    if(self.tableView.count > 0) {
        [self.tableView.list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:[TGModernSearchItem class]] || [obj isKindOfClass:[SearchMessageTableItem class]]) {
                [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:idx] byExtendingSelection:NO];
                [self.tableView scrollRowToVisible:idx];
                *stop = YES;
            }
        }];
    }
}

-(void)dontLoadHashTagsForOneRequest {
    
}

@end
