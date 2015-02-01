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
@interface TGDocumentsController : NSObject<MessagesDelegate>
@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,strong) TGDocumentsMediaTableView *tableView;
@property (nonatomic,strong) ChatHistoryController *loader;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) NSMutableArray *searchItems;
-(id)initWithTableView:(TGDocumentsMediaTableView *)tableView;

@property (nonatomic,strong) TGSearchRowView *searchView;
@property (nonatomic,strong) TGSearchRowItem *searchItem;

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
    
    self.searchItems = [[NSMutableArray alloc] init];
    
    
    self.items = [[NSMutableArray alloc] init];
    
    self.searchItem = [[TGSearchRowItem alloc] init];
    self.searchItem.table = self.tableView;
    
    self.searchView = [[TGSearchRowView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.tableView.frame), 50)];
    self.searchView.rowItem = self.searchItem;
    
    
    [self.items addObject:self.searchItem];
    
    [self.tableView reloadData];
    
    [_loader drop:NO];
    
    _loader = [[ChatHistoryController alloc] initWithController:self historyFilter:[DocumentHistoryFilter class]];
    
    [_loader setPrevState:ChatHistoryStateFull];
    
    [self loadNext:YES];

}

-(void)loadNext:(BOOL)isFirst {
    
    _loader.selectLimit = _loader.nextState != ChatHistoryStateRemote ? 500 : 50;
    
    [_loader request:YES anotherSource:YES sync:isFirst selectHandler:^(NSArray *result, NSRange range) {
        
        NSArray *filtred = [result filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            
            return [evaluatedObject isKindOfClass:[MessageTableItemDocument class]];
            
        }]];
        
         [self.items addObjectsFromArray:filtred];
        
         [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.items.count - filtred.count, filtred.count)] withAnimation:NSTableViewAnimationEffectNone];
            
        if(self.items.count < 30 && _loader.nextState != ChatHistoryStateFull) {
            [self loadNext:NO];
        }
        
    }];
    
}


-(void)receivedMessage:(MessageTableItem *)message position:(int)position itsSelf:(BOOL)force {
    
    if([message isKindOfClass:[MessageTableItemDocument class]]) {
        [self.items insertObject:message atIndex:1];
        
        [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:1] withAnimation:NSTableViewAnimationEffectFade];
    }
}

-(void)deleteMessages:(NSArray *)ids {
    
    NSArray *items = [self.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.message.n_id IN %@",ids]];
    
    [items enumerateObjectsUsingBlock:^(MessageTableItemDocument *obj, NSUInteger idx, BOOL *stop) {
        
        [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:[self.items indexOfObject:obj]] withAnimation:NSTableViewAnimationEffectFade];
        
    }];
    
    [self.items removeObjectsInArray:items];
    
    
    
}

-(void)flushMessages {
    [self.items removeAllObjects];
    
    [self.tableView reloadData];
}

-(void)receivedMessageList:(NSArray *)list inRange:(NSRange)range itsSelf:(BOOL)force {
    
    list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        return [evaluatedObject isKindOfClass:[MessageTableItemDocument class]];
        
    }]];
    
    [self.items insertObjects:list atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, list.count)]];
    
    [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, list.count)] withAnimation:NSTableViewAnimationEffectFade];
}

- (void)didAddIgnoredMessages:(NSArray *)items {
    
}


-(NSArray *)messageTableItemsFromMessages:(NSArray *)messages {
    return [[Telegram rightViewController].messagesViewController messageTableItemsFromMessages:messages];
}

-(void)updateLoading {
    
}

@end


@interface TGDocumentsMediaTableView ()
@property (nonatomic,strong) TGDocumentsController *controller;

@end

@implementation TGDocumentsMediaTableView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.dataSource = self;
        self.delegate = self;
        self.controller = [[TGDocumentsController alloc] initWithTableView:self];
        [self addScrollEvent];
    }
    
    return self;
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


-(void)reloadWithString:(NSString *)string {
    
    NSArray *f = [[self.controller.items subarrayWithRange:NSMakeRange(1, self.controller.items.count - 1)] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.fileName CONTAINS[cd] %@",string]];
    
    
    [self.controller.items removeAllObjects];
    
    [self.controller.items addObject:self.controller.searchItem];
    
    
    [self.controller.items addObjectsFromArray:f];
    
    [self reloadData];
    
}

-(void)setConversation:(TL_conversation *)conversation {
    
    self.controller.conversation = conversation;
    
    [self addScrollEvent];
}


- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return self.controller.items.count;
}

- (BOOL) tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}

- (CGFloat) tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return row == 0 ? NSHeight(self.controller.searchView.frame) : 60;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    MessageTableItem *item = [self.controller.items objectAtIndex:row];
    TGDocumentMediaRowView *cell = nil;
    
    
    if(row == 0) {
        
        [self.controller.searchView redrawRow];
        
        return self.controller.searchView;
        
    }
    
    static NSString *const kRowIdentifier = @"documentMediaView";
    cell = [self makeViewWithIdentifier:kRowIdentifier owner:self];
    if(!cell) {
        cell = [[TGDocumentMediaRowView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.bounds), 60)];
        cell.identifier = kRowIdentifier;
    }
    
    [cell setItem:item];
    
    
    return cell;
}


- (void)scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)aNotification {
    
    if(self.controller.loader.nextState == ChatHistoryStateFull || ![self.scrollView isNeedUpdateBottom])
        return;
    
    [self.controller loadNext:NO];
}


- (void) addScrollEvent {
    id clipView = [[self enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

@end
