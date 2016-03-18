//
//  TGDocumentsMediaTableView.m
//  Telegram
//
//  Created by keepcoder on 27.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGDocumentsMediaTableView.h"
#import "DocumentHistoryFilter.h"
#import "ChatHistoryController.h"
#import "MessageTableItemDocument.h"
#import "TGSearchRowView.h"
#import "TGSharedMediaCap.h"
#import "MessageTableItemAudioDocument.h"
#import "SpacemanBlocks.h"
#import "ChannelHistoryController.h"
@interface TGDocumentsController : NSObject<MessagesDelegate>
@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,weak) TGDocumentsMediaTableView *tableView;
@property (nonatomic,strong) ChatHistoryController *loader;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) NSMutableArray *defaultItems;
-(id)initWithTableView:(TGDocumentsMediaTableView *)tableView;

@property (nonatomic,strong) TGSearchRowView *searchView;
@property (nonatomic,strong) TGSearchRowItem *searchItem;
@property (nonatomic,assign) BOOL inSearch;

@end


@interface TGDocumentsMediaTableView ()

@property (nonatomic,strong) TGDocumentsController *controller;
@property (nonatomic,assign,getter=isEditable) BOOL editable;
@property (nonatomic,strong) NSMutableArray *selectedItems;
@property (nonatomic,strong) SMDelayedBlockHandle remoteBlock;


@property (nonatomic,weak) RPCRequest *request;

-(void)checkCap;
@end

@implementation TGDocumentsController

-(id)initWithTableView:(TGDocumentsMediaTableView *)tableView {
    if(self = [super init]) {
        _tableView = tableView;
    }
    return self;
}


-(void)setConversation:(TL_conversation *)conversation{
    _conversation = conversation;
    
    self.defaultItems = [[NSMutableArray alloc] init];
    
    
    self.items = [[NSMutableArray alloc] init];
    
    self.inSearch = NO;
    
    self.searchItem = [[TGSearchRowItem alloc] init];
    self.searchItem.table = self.tableView;
    
    self.searchView = [[TGSearchRowView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.tableView.frame), 50)];
    self.searchView.rowItem = self.searchItem;
    
    
    [self.items addObject:self.searchItem];
    
    [self.tableView reloadData];
    
    
    _loader = nil;
    
    
    if(_conversation) {
        _loader = [[self.conversation.type == DialogTypeChannel ? ChatHistoryController.class : ChannelHistoryController.class alloc] initWithController:self historyFilter:[self.tableView historyFilter]];
        
            
        [_loader.filter setState:ChatHistoryStateFull next:NO];
    } else {
        [_loader drop:YES];
        _loader = nil;
    }
    
    [self loadNext:YES];

}

-(void)loadNext:(BOOL)isFirst {
    
    _loader.selectLimit = _loader.nextState != ChatHistoryStateRemote ? 50 : 50;
    
    weak();
    
    [_loader request:YES anotherSource:YES sync:isFirst selectHandler:^(NSArray *result, NSRange range,id controller) {
        
        strongWeak();
        
        if(strongSelf != nil) {
            strongSelf.tableView.isProgress = NO;
            
            
            NSArray *filtred = [result filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                
                return [strongSelf.tableView acceptMessageItem:evaluatedObject];
                
            }]];
            
            [filtred enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
                [obj makeSizeByWidth:NSWidth(strongSelf.tableView.frame) - 60];
            }];
            
            [strongSelf.items addObjectsFromArray:filtred];
            
            [strongSelf.defaultItems addObjectsFromArray:filtred];
            
            [strongSelf.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(strongSelf.items.count - filtred.count, filtred.count)] withAnimation:NSTableViewAnimationEffectNone];
            
            
            [strongSelf.tableView checkCap];
            
            
            if(strongSelf.items.count < 30 && [_loader filterWithNext:YES].nextState != ChatHistoryStateFull) {
                [strongSelf loadNext:NO];
            }
        }
        
        
        
    }];
    
}


-(void)receivedMessage:(MessageTableItem *)message position:(int)position itsSelf:(BOOL)force {
    
    if([self.tableView acceptMessageItem:message]) {
        [self.items insertObject:message atIndex:1];
        [message makeSizeByWidth:NSWidth(self.tableView.frame) - 60];
        [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:1] withAnimation:NSTableViewAnimationEffectFade];
        
        [self.tableView checkCap];
    }
}

-(void)deleteItems:(NSArray *)items orMessageIds:(NSArray *)ids {
    
    if(self.items.count > 1) {
        
        [items enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
            
            NSUInteger itemIndex = [self.items indexOfObject:obj];
            if(itemIndex != NSNotFound) {
                [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:itemIndex] withAnimation:NSTableViewAnimationEffectFade];
            }
        }];
        
        [self.items removeObjectsInArray:items];
        [self.tableView checkCap];
    }
    
}

-(void)flushMessages {
    [self.items removeAllObjects];
    
    [self.tableView reloadData];
    [self.tableView checkCap];
}

-(void)receivedMessageList:(NSArray *)list inRange:(NSRange)range itsSelf:(BOOL)force {
    
    list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        return [self.tableView acceptMessageItem:evaluatedObject];
        
    }]];
    
    [list enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        [obj makeSizeByWidth:NSWidth(self.tableView.frame) - 60];
    }];
    
    [self.items insertObjects:list atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, list.count)]];
    
    [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, list.count)] withAnimation:NSTableViewAnimationEffectFade];
    
    [self.tableView checkCap];
}

- (void)didAddIgnoredMessages:(NSArray *)items {
    
}


-(NSArray *)messageTableItemsFromMessages:(NSArray *)messages {
    
    NSMutableArray *array = [NSMutableArray array];
    for(TLMessage *message in messages) {
        message.flags|= (1 << 30);
        MessageTableItem *item = [MessageTableItem messageItemFromObject:message];
        if(item) {
            [array addObject:item];
        }
    }
    return array;
   
}

-(void)updateLoading {
    
}

@end

@interface TGDocumentsClipView : NSClipView
@property (nonatomic, weak) TGDocumentsMediaTableView *tableView;
@end

@implementation TGDocumentsClipView

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    if([self inLiveResize]) {
        NSRange visibleRows = [self.tableView rowsInRect:self.tableView.scrollView.contentView.bounds];
        if(visibleRows.length > 0) {
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:0];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            NSInteger count = visibleRows.location + visibleRows.length;
            for(NSInteger i = visibleRows.location; i < count; i++) {
                MessageTableItem *item = self.tableView.controller.items[i];
                
                if([item isKindOfClass:[MessageTableItem class]]) {
                   // [self.tableView prepareItem:item];
                    [item makeSizeByWidth:newSize.width - 60];
                    id view = [self.tableView viewAtColumn:0 row:i makeIfNecessary:NO];
                    
                    if(view)
                        [array addObject:view];
                }
                
            }
            
            [self.tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:visibleRows]];
            
            for(MessageTableCell *cell in array) {
                [cell resizeAndRedraw];
            }
            
            [NSAnimationContext endGrouping];
        }
        
        
        
        
    } else {
        for(NSUInteger i = 0; i < self.tableView.controller.items.count; i++) {
            MessageTableItem *item = self.tableView.controller.items[i];
            if([item isKindOfClass:[MessageTableItem class]])
                [item makeSizeByWidth:newSize.width - 60];
        }
    }
    
    
}

-(void)viewDidEndLiveResize {
    [self.tableView reloadData];
}

@end


@implementation TGDocumentsMediaTableView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.dataSource = self;
        self.delegate = self;
        self.controller = [[TGDocumentsController alloc] initWithTableView:self];
        
        id document = self.scrollView.documentView;
        TGDocumentsClipView *clipView = [[TGDocumentsClipView alloc] initWithFrame:self.scrollView.contentView.bounds];
        clipView.tableView = document;
        [clipView setWantsLayer:YES];
        [clipView setDrawsBackground:YES];
        [self.scrollView setContentView:clipView];
        self.scrollView.documentView = document;
        
        
        [self.containerView setHidden:YES];
        
        [self addScrollEvent];
    }
    
    return self;
}

-(void)checkCap {
    
    [self.collectionViewController checkCap];
}

-(BOOL)isFlipped {
    return YES;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void) searchFieldTextChange:(NSString*)searchString {
    [self reloadWithString:searchString];
}


-(NSPredicate *)searchPredicateWithString:(NSString *)string {
    return [NSPredicate predicateWithFormat:@"self.fileName CONTAINS[cd] %@",string];
}

-(void)reloadWithString:(NSString *)string {
    
    
    self.controller.inSearch = string.length != 0;
    
    
    NSArray *f = [self.controller.defaultItems filteredArrayUsingPredicate:[self searchPredicateWithString:string]];
    
    if(string.length == 0) {
        f = self.controller.defaultItems;
    }
    
    
    NSRange removeRange = NSMakeRange(1, self.controller.items.count - 1);
    
    [self.controller.items removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:removeRange]];
    
    [self removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:removeRange] withAnimation:NSTableViewAnimationEffectNone];
    
    [self.controller.items addObjectsFromArray:f];
    
    [self insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1,f.count)] withAnimation:NSTableViewAnimationEffectNone];
    

    
    [self checkCap];
    
    [self.controller.searchView.searchField becomeFirstResponder];
    
    if(_remoteBlock)
        cancel_delayed_block(_remoteBlock);
    
    if(_request)
        [_request cancelRequest];
    
    weak();
    
    _remoteBlock = perform_block_after_delay(0.4, ^{
        
        strongWeak();
        
        if(strongSelf != nil) {
            strongSelf.remoteBlock = nil;
            
            [strongSelf remoteSearch:string];
        }
        
        
        
    });
    
}


-(void)remoteSearch:(NSString *)search {
    
    if(_request)
        [_request cancelRequest];
    
    
    MessageTableItem *item = [self.controller.items lastObject];
    
    if(![item isKindOfClass:[MessageTableItem class]])
        item = nil;
    
    weak();
    
    _request = [RPCRequest sendRequest:[TLAPI_messages_search createWithFlags:0 peer:self.controller.conversation.inputPeer q:search filter:[self remoteFilter] min_date:0 max_date:0 offset:0 max_id:item.message.n_id limit:100] successHandler:^(id request, id response) {
        
        strongWeak();
        
        if(strongSelf != nil) {
            [TL_localMessage convertReceivedMessages:[response messages]];
            
            NSArray *converted = [self.controller messageTableItemsFromMessages:[response messages]];
            
            NSArray *filtred = [converted filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                
                return [strongSelf acceptMessageItem:evaluatedObject];
                
            }]];
            
            [filtred enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
                [obj makeSizeByWidth:NSWidth(strongSelf.frame) - 60];
            }];
            
            [strongSelf.controller.items addObjectsFromArray:filtred];
            
            
            [strongSelf insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(strongSelf.controller.items.count - filtred.count, filtred.count)] withAnimation:NSTableViewAnimationEffectNone];
        }
        
    } errorHandler:^(id request, RpcError *error) {
        
    }];
}


-(id)remoteFilter {
    return [TL_inputMessagesFilterDocument create];
}

-(void)setEditable:(BOOL)editable animated:(BOOL)animated {
    _editable = editable;
    
    
    
    self.selectedItems = [[NSMutableArray alloc] init];
    
    [self.controller.items enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(idx > 0) {
            TGDocumentMediaRowView *row = [self viewAtColumn:0 row:idx makeIfNecessary:NO];
            
            [row setEditable:editable animated:animated];
        }
        
        
    }];
    
}

-(BOOL)isEditable {
    return [self.collectionViewController isEditable];
}

-(BOOL)isNeedCap {
    return self.controller.defaultItems.count == 0;
}

-(void)setConversation:(TL_conversation *)conversation {
    
    self.isProgress = YES;
    
    self.controller.conversation = conversation;
    
    self.selectedItems = [[NSMutableArray alloc] init];
    
    [self.controller.searchView.searchField setStringValue:@""];
    
    [self addScrollEvent];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.controller.searchView.searchField becomeFirstResponder];
    });
}


- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return self.controller.items.count;
}

- (BOOL) tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}

- (CGFloat) tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return row == 0 ? NSHeight(self.controller.searchView.frame) : [self heightWithItem:self.controller.items[row]];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    MessageTableItem *item = [self.controller.items objectAtIndex:row];
    TGDocumentMediaRowView *cell = nil;
    
    
    if(row == 0) {
        
        [self.controller.searchView redrawRow];
        
        return self.controller.searchView;
        
    }
    
    NSString *kRowIdentifier = NSStringFromClass([self rowViewClass]);
    
    cell = [self makeViewWithIdentifier:kRowIdentifier owner:self];
    if(!cell) {
        cell = [[[self rowViewClass] alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.bounds), [self heightWithItem:item])];
        cell.identifier = kRowIdentifier;
    }
    
    item.table = self;
    
    [cell setFrameSize:NSMakeSize(NSWidth(self.bounds),[self heightWithItem:item])];
    cell.messagesViewController = self.collectionViewController.messagesViewController;
    [cell setItem:item];
    
    
    return cell;
}

-(void)setSelected:(BOOL)selected forItem:(MessageTableItem *)item {
    
    
    if(selected) {
        [_selectedItems addObject:item];
    } else {
        [_selectedItems removeObject:item];
    }
    
    
    NSMutableArray *messages = [NSMutableArray array];
    
    [_selectedItems enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [messages addObject:obj.message];
    }];
    
    [self.collectionViewController setSectedMessagesCount:self.selectedItems.count enable:[MessagesViewController canDeleteMessages:messages inConversation:self.controller.conversation]];

}

-(BOOL)isSelectedItem:(MessageTableItem *)item {
    return [self.selectedItems indexOfObject:item] != NSNotFound;
}

-(NSArray *)selectedItems {
    return _selectedItems;
}

- (void)scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)aNotification {
    
    if(self.controller.loader.nextState == ChatHistoryStateFull || ![self.scrollView isNeedUpdateBottom] || [self.controller inSearch])
        return;
    
    [self.controller loadNext:NO];
}

-(Class)rowViewClass {
    return [TGDocumentMediaRowView class];
}

-(Class)historyFilter {
    return [DocumentHistoryFilter class];
}

- (void)prepareItem:(MessageTableItem *)item {
    
}

-(BOOL)acceptMessageItem:(MessageTableItem *)item {
    return [item isKindOfClass:[MessageTableItemDocument class]];
}

-(int)heightWithItem:(MessageTableItem *)item {
    return 60;
}

-(NSArray *)items {
    return self.controller.defaultItems;
}

-(NSUInteger)indexOfItem:(NSObject *)item {
    return [self.controller.items indexOfObject:item];
}

- (void) addScrollEvent {
    id clipView = [[self enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

-(void)clear {
    [super clear];
    
}

-(void)dealloc {
    
}

@end
