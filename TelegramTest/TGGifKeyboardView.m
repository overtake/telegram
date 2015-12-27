#import "TGGifKeyboardView.h"
#import "TMSearchTextField.h"
#import "SpacemanBlocks.h"
#import "TGMediaContextTableView.h"
#import "MessagesBottomView.h"
@interface TGGifKeyboardView () <TMSearchTextFieldDelegate> {
    __block SMDelayedBlockHandle _delayedBlockHandle;
}
@property (nonatomic,strong) TGMediaContextTableView *tableView;
@property (nonatomic,strong) TMSearchTextField *searchField;

@property (nonatomic,weak) RPCRequest *request;

@property (nonatomic,strong) NSMutableArray *items;
@end

@implementation TGGifKeyboardView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        [self initialize];
    }
    
    return self;
}


-(void)initialize {
    _tableView = [[TGMediaContextTableView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.frame), NSHeight(self.frame))];
    [self addSubview:_tableView.containerView];
    
    weak();
    
    [_tableView setChoiceHandler:^(TLDocument *document) {
        __strong TGGifKeyboardView *strongSelf = weakSelf;
        
        if(strongSelf != nil) {
            [strongSelf.messagesViewController sendFoundGif:[TL_messageMediaDocument createWithDocument:document caption:@""] forConversation:strongSelf.messagesViewController.conversation];
            [strongSelf.messagesViewController.bottomView.smilePopover close];
        }
    }];
    
}


-(void)searchFieldTextChange:(NSString *)searchString {
    
    [_tableView clear];
    
    if(searchString.length == 0) {
        [_tableView drawResponse:@[]];
        return;
    }
    
    cancel_delayed_block(_delayedBlockHandle);
    
    [_request cancelRequest];
    
    _delayedBlockHandle = perform_block_after_delay(0.5, ^{
        _request = [RPCRequest sendRequest:[TLAPI_messages_searchGifs createWithQ:searchString offset:0] successHandler:^(id request, TL_messages_foundGifs *response) {
            
            NSMutableArray *items = [NSMutableArray array];
            [response.results enumerateObjectsUsingBlock:^(TL_foundGif *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [items addObject:obj.webpage];
            }];
            
            [_tableView drawResponse:items];
            
        } errorHandler:^(id request, RpcError *error) {
            [_tableView drawResponse:@[]];
            
        }];
    });
    
    
}

-(int)gifsHash {
    
    __block int hash = 0;
    
    NSMutableArray *high = [NSMutableArray array];
    NSMutableArray *low = [NSMutableArray array];
    
    [_items enumerateObjectsUsingBlock:^(TLWebPage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [high addObject:@(obj.document.n_id >> 32)];
        [low addObject:@(obj.document.n_id & 0xFFFFFFFFL)];
    }];
    
    
    [high sortUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return [obj1 compare:obj2];
    }];
    
    [low sortUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return [obj1 compare:obj2];
    }];
    
    
    NSMutableArray *compared = [NSMutableArray array];
    
    for (int i = 0; i < low.count; i++) {
        [compared addObject:high[i]];
        [compared addObject:low[i]];
    }
    
    
    
    [compared enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        hash = (hash * 20261) + [obj intValue];
    }];
    
    return (int)(hash % 0x7FFFFFFF);
    
    return hash;
}

-(void)prepareSavedGifvs {
    
    
    [[Storage yap] asyncReadWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        
        NSMutableArray *result = [transaction objectForKey:@"recent_gifs" inCollection:RECENT_GIFS];
        
        [self proccessAndSendToDraw:result];
        
        [self checkRemoteWithHash];
    }];
    
    
}

-(void)checkRemoteWithHash {
    [RPCRequest sendRequest:[TLAPI_messages_getSavedGifs createWithN_hash:[self gifsHash]] successHandler:^(id request, TL_messages_savedGifs *response) {
        
        [self proccessAndSendToDraw:response.gifs];
        
    } errorHandler:^(id request, RpcError *error) {
        
    }];
}

-(void)proccessAndSendToDraw:(NSArray *)items {
    
    NSMutableArray *result = [NSMutableArray array];
    
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TL_webPage *webpage = [[TL_webPage alloc] init];
        webpage.document = obj;
        webpage.type = @"gifv";
        [result addObject:webpage];
    }];
    
    _items = result;
    
    [_tableView drawResponse:result];
}

-(void)clear {
    [_tableView clear];
}

@end