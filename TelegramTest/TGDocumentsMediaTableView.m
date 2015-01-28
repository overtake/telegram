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
@interface TGDocumentsController : NSObject<MessagesDelegate>
@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,strong) TGDocumentsMediaTableView *tableView;
@property (nonatomic,strong) ChatHistoryController *loader;
@property (nonatomic,strong) NSMutableArray *items;
-(id)initWithTableView:(TGDocumentsMediaTableView *)tableView;

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
    
    
    self.items = [[NSMutableArray alloc] init];
    
    
    [self.tableView reloadData];
    
    [_loader drop:NO];
    
    _loader = [[ChatHistoryController alloc] initWithController:self historyFilter:[DocumentHistoryFilter class]];
    
    [_loader setPrevState:ChatHistoryStateFull];
    
    [self loadNext:YES];

}

-(void)loadNext:(BOOL)isFirst {
    
    [_loader request:YES anotherSource:YES sync:isFirst selectHandler:^(NSArray *result, NSRange range) {
        
        NSArray *filtred = [result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.class == %@", [MessageTableItemDocument class]]];
        
         [self.items addObjectsFromArray:filtred];
        
        //dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.items.count - filtred.count, filtred.count)] withAnimation:NSTableViewAnimationEffectNone];
            
            if(self.items.count < 30 && _loader.nextState != ChatHistoryStateFull) {
                [self loadNext:NO];
            }
            
      //  });
        
    }];
    
}


-(void)receivedMessage:(MessageTableItem *)message position:(int)position itsSelf:(BOOL)force {
    
    [self.items insertObject:message atIndex:0];
    
    [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationEffectFade];
    
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
    
    [self.items insertObjects:list atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, list.count)]];
    
    [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, list.count)] withAnimation:NSTableViewAnimationEffectFade];
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

-(void)setConversation:(TL_conversation *)conversation {
    
    self.controller.conversation = conversation;
    
    // update;
}


- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return self.controller.items.count;
}

- (BOOL) tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}

- (CGFloat) tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 60;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    MessageTableItem *item = [self.controller.items objectAtIndex:row];
    TGDocumentMediaRowView *cell = nil;
    
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
