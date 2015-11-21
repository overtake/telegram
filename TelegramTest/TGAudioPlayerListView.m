//
//  TGAudioPlayerListView.m
//  Telegram
//
//  Created by keepcoder on 03.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGAudioPlayerListView.h"
#import "TGAudioRowView.h"
#import "ChatHistoryController.h"
#import "MP3HistoryFilter.h"
#import "MessageTableItemAudioDocument.h"
#import "NSString+Extended.h"
#import "TGAudioPlayerWindow.h"
@interface TGAudioSearchRowItem : TMRowItem

@end


@implementation TGAudioSearchRowItem

static long h_r_l;

+(void)initialize {
    h_r_l = rand_long();
}

-(NSUInteger)hash {
    return h_r_l;
}

@end



@interface TGAudioSearchRowView : TMRowView
@property (nonatomic,strong) TMSearchTextField *searchField;
@property (nonatomic,strong) TGAudioPlayerListView *controller;

@end


@implementation TGAudioSearchRowView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _searchField = [[TMSearchTextField alloc] initWithFrame:NSMakeRect(5, 5, NSWidth(frameRect) - 20 , 30)];
        
        [_searchField setCenterByView:self];
        
       
        
        [self addSubview:_searchField];
        
    }
    
    return self;
}

-(void)redrawRow {
     _searchField.delegate = _controller.self;
}


@end


@interface TGAudioPlayerListView () <TMTableViewDelegate,MessagesDelegate,TMSearchTextFieldDelegate>
@property (nonatomic,strong) TMTableView *tableView;
@property (nonatomic,strong) ChatHistoryController *h_controller;

@property (nonatomic,strong) TGAudioSearchRowView *searchRow;


@property (nonatomic,strong) NSMutableArray *fullItems;

@property (nonatomic,strong) DownloadEventListener *globalDownloadListener;

@property (nonatomic,strong) TMTextField *emptyTextField;

@end

@implementation TGAudioPlayerListView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _tableView = [[TMTableView alloc] initWithFrame:self.bounds];
        
        _tableView.tm_delegate = self;
        
        [self addSubview:_tableView.containerView];
        
        
        _searchRow = [[TGAudioSearchRowView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.bounds), 40)];
        _searchRow.controller = self;
        
        weak();
        
        _globalDownloadListener = [[DownloadEventListener alloc] init];
        
        [_globalDownloadListener setCompleteHandler:^(DownloadItem *item) {
            
            [ASQueue dispatchOnMainQueue:^{
                [weakSelf reloadData];
            }];
            
        }];
        
        
        _emptyTextField = [TMTextField defaultTextField];
        
        [_emptyTextField setStringValue:NSLocalizedString(@"NoAudioDescription", nil)];
        
        [_emptyTextField setFont:TGSystemFont(13)];
        
        [_emptyTextField setTextColor:GRAY_TEXT_COLOR];
        
        
        NSSize size = [[_emptyTextField cell] cellSizeForBounds:NSMakeRect(0, 0, NSWidth(self.frame) - 40, NSHeight(self.frame))];

        
        [_emptyTextField setFrameSize:size];
        
        [_emptyTextField setCenterByView:self];
        
        [self addSubview:_emptyTextField];
        
    }
    
    return self;
}


-(void)onShow {
    
    __block int selectedIdx = -1;
    
    [_fullItems enumerateObjectsUsingBlock:^(TGAudioRowItem *obj, NSUInteger idx, BOOL *stop) {
        obj.isSelected = [obj hash] == _selectedId;
        
        if(obj.isSelected)
        {
            selectedIdx = (int) idx;
        }
        
    }];

    
    if(![self.tableView rowIsVisible:selectedIdx])
        [self.tableView.scrollView.clipView scrollPoint:[self.tableView rectOfRow:selectedIdx].origin];
}


- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return row == 0 ? 40 : 50;
}
- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}
- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    return row == 0 ? _searchRow : [_tableView cacheViewForClass:[TGAudioRowView class] identifier:NSStringFromClass([TGAudioRowView class]) withSize:NSMakeSize(NSWidth(self.frame), 50)];
}
- (void)selectionDidChange:(NSInteger)row item:(TGAudioRowItem *) item {
    
    if(_changedAudio)
    {
        _changedAudio(item.document);
    }
    
}
- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    
    
    return YES;
}
- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {

    
    return row > 0;
}


-(void)setConversation:(TL_conversation *)conversation {
    _conversation = conversation;
    [self reload];

}


-(void)reload {
    
    if(_conversation) {
        _list = @[];
        [_tableView removeAllItems:YES];
        _fullItems = [[NSMutableArray alloc] init];
        _h_controller = [[ChatHistoryController alloc] initWithController:self historyFilter:[MP3HistoryFilter class]];
        [_searchRow.searchField setStringValue:@""];
        [_tableView insert:[[TGAudioSearchRowItem alloc] init] atIndex:0 tableRedraw:YES];
        
        [self loadNext];
    } else {
        [_tableView removeAllItems:YES];
        _fullItems = nil;
        _list = nil;
        _h_controller = nil;
    }
    
    [self check];
    
}

-(void)loadNext {
    
    if(_h_controller.nextState != ChatHistoryStateFull) {
        [_h_controller request:YES anotherSource:YES sync:NO selectHandler:^(NSArray *result, NSRange range, id controller) {
            
            NSArray *f = [result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.class == %@",[MessageTableItemAudioDocument class]]];
            
            _list = [_list arrayByAddingObjectsFromArray:f];
            
            NSMutableArray *convert = [[NSMutableArray alloc] init];
            
            [f enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                TGAudioRowItem *item = [[TGAudioRowItem alloc] initWithObject:obj];
                
                item.isSelected = [item hash] == _selectedId;
                
                [convert addObject:item];
            }];
            
            
            
            [_fullItems addObjectsFromArray:convert];
            
            [self resort];
            
            if(_tableView.count > 0) {
                 [_tableView removeItemsInRange:NSMakeRange(1, _tableView.count-1) tableRedraw:YES];
            }
            
            [_tableView insert:_fullItems startIndex:1 tableRedraw:YES];
            
            [self check];
            
            if([TGAudioPlayerWindow currentItem] == nil && _tableView.count > 1 && [TGAudioPlayerWindow autoStart]) {
                [self selectNext];
            }
            
            [self loadNext];
            
        }];
    }
    
}

-(BOOL)becomeFirstResponder {
    return [self.searchRow.searchField becomeFirstResponder];
}



-(void)check {
    [_emptyTextField setHidden:_tableView.count > 1 || _searchRow.searchField.stringValue.length > 0];
    [_tableView.containerView setHidden:!_emptyTextField.isHidden];
}


-(void)setSelectedId:(long)messageId {
    _selectedId = messageId;
    
    __block TGAudioRowItem *selectedRow = nil;
    __block int selectedIdx = -1;
    
    [_fullItems enumerateObjectsUsingBlock:^(TGAudioRowItem *obj, NSUInteger idx, BOOL *stop) {
        obj.isSelected = [obj hash] == messageId;
        
        if(obj.isSelected)
        {
            selectedRow = obj;
            selectedIdx = (int) idx;
        }
        
    }];
    
    if(_fullItems.count > 1 && selectedIdx != -1)
    {
        
        NSUInteger startIdx = MAX(selectedIdx-1,0);
        NSUInteger length = MIN(3, _fullItems.count - selectedIdx);
        
        NSArray *dif = [_fullItems subarrayWithRange:NSMakeRange(startIdx, length)];
        
        
        [dif enumerateObjectsUsingBlock:^(TGAudioRowItem *obj, NSUInteger idx, BOOL *stop) {
            
            if(obj != selectedRow)
            {
                if(!obj.document.isset)
                {
                    [obj.document startDownload:NO force:YES];
                }
            }
            
        }];
    }
    
    [self.tableView redrawAll];
    
    
    
    if(![self.tableView rowIsVisible:selectedIdx])
        [self.tableView.scrollView.clipView scrollPoint:[self.tableView rectOfRow:selectedIdx].origin];

}

-(void)reloadData {
    [_tableView redrawAll];
}

-(void)close {
    _conversation = nil;
    [_h_controller drop:YES];
    _h_controller = nil;
}

-(void)selectNext {
    
    [ASQueue dispatchOnMainQueue:^{
        long rowId = (long) [_tableView indexOfItem:[_tableView itemByHash:_selectedId]];
        
        if(rowId == NSNotFound)
        {
            rowId = 0;
        }
        
        rowId++;
        
        if(rowId == _tableView.count ) {
            rowId = 1;
        }
        
        _changedAudio([(TGAudioRowItem *)[_tableView itemAtPosition:rowId] document]);
    }];
    
   
    
}
-(void)selectPrev {
    [ASQueue dispatchOnMainQueue:^{
        long rowId = (long) [_tableView indexOfItem:[_tableView itemByHash:_selectedId]];
        
        if(rowId == NSNotFound)
        {
            rowId = 0;
        }
        
        rowId--;
        
        if(rowId < 1) {
            rowId = (int)_tableView.count - 1;
        }
        
        _changedAudio([(TGAudioRowItem *)[_tableView itemAtPosition:rowId] document]);
    }];
}

-(void)receivedMessage:(MessageTableItem *)message position:(int)position itsSelf:(BOOL)force {
    if([message isKindOfClass:[MessageTableItemAudioDocument class]]) {
        
        if(!message.isset) {
            [message startDownload:NO force:YES];
            
            [message.downloadItem addEvent:_globalDownloadListener];
        }
        
        TGAudioRowItem *item = [[TGAudioRowItem alloc] initWithObject:message];
        
        [_fullItems insertObject:item atIndex:1];
        
        [self resort];
        
        NSUInteger pos = [self posAsItem:item];
        
        BOOL accept = YES;
        
        if(self.searchRow.searchField.stringValue.length > 0) {
            accept = [item.trackName searchInStringByWordsSeparated:self.searchRow.searchField.stringValue];
            pos = _fullItems.count-1;
        }
        
        _tableView.defaultAnimation = NSTableViewAnimationEffectFade;
        [_tableView insert:item atIndex:pos+1 tableRedraw:YES];
        _tableView.defaultAnimation = NSTableViewAnimationEffectNone;
        
        
        [self check];
    }
}


-(void)resort {
    [_fullItems sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self.document.message.date" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"self.document.message.n_id" ascending:YES]]];
}

-(NSUInteger)posAsItem:(TGAudioRowItem *)item {
    return [_fullItems indexOfObject:item];
}

-(void)deleteItems:(NSArray *)dItems orMessageIds:(NSArray *)ids {
    
    
    NSArray *items = [_fullItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.document.message.n_id IN (%@)",ids]];
    
    [items enumerateObjectsUsingBlock:^(TGAudioRowItem *obj, NSUInteger idx, BOOL *stop) {
        [_fullItems removeObject:obj];
        
        if(_selectedId == obj.hash) {
            [self selectNext];
        }
        
        _tableView.defaultAnimation = NSTableViewAnimationEffectFade;
        [_tableView removeItem:obj];
        _tableView.defaultAnimation = NSTableViewAnimationEffectNone;
        
    }];
    
    [self check];
}

-(void)flushMessages {
    
}

-(void)receivedMessageList:(NSArray *)list inRange:(NSRange)range itsSelf:(BOOL)force {
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self receivedMessage:obj position:(int)idx itsSelf:force];
    }];
}
- (void)didAddIgnoredMessages:(NSArray *)items {
    
}


-(NSArray *)messageTableItemsFromMessages:(NSArray *)messages {
    NSMutableArray *array = [NSMutableArray array];
    for(TLMessage *message in messages) {
        MessageTableItem *item = [MessageTableItem messageItemFromObject:message];
        if(item) {
            [array insertObject:item atIndex:0];
        }
    }
    return array;
}


-(void)updateLoading {
    
}


- (void) searchFieldTextChange:(NSString*)searchString {
    
    if(_fullItems.count > 0) {
        NSArray *items = _fullItems;
        
        if(searchString.length > 0) {
            items = [_fullItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TGAudioRowItem *evaluatedObject, NSDictionary *bindings) {
                
                return [evaluatedObject.trackName searchInStringByWordsSeparated:searchString];
                
            }]];
        }
        
        
        [_tableView removeItemsInRange:NSMakeRange(1, _tableView.list.count - 1) tableRedraw:YES];
        
        [_tableView insert:items startIndex:1 tableRedraw:YES];
    }
    
}

@end





