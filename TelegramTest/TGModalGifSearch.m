//
//  TGModalGifSearch.m
//  Telegram
//
//  Created by keepcoder on 03/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGModalGifSearch.h"
#import "TMTableView.h"
#import "TMSearchTextField.h"
#import "UIImageView+AFNetworking.h"

@interface TGGifSearchRowItem : TMRowItem
@property (nonatomic,strong) NSArray *gifs;
@property (nonatomic,assign) long randKey;
@end

@implementation TGGifSearchRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _gifs = object;
        _randKey = rand_long();
    }
    
    return self;
}

-(NSUInteger)hash {
    return _randKey;
}

@end


@interface TGGifSearchRowView : TMRowView

@end


@implementation TGGifSearchRowView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        int s = NSHeight(frameRect);
        
        for (int i = 0; i < 4; i++) {
            NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(i == 0 ? 10 : 10+ (i*s) + 2, 1, s, s)];
            [self addSubview:imageView];
        
        }
        
    }
    
    return self;
}


-(void)redrawRow {
    [super redrawRow];
    
    TGGifSearchRowItem *item = (TGGifSearchRowItem *)[self rowItem];
    
    [self.subviews enumerateObjectsUsingBlock:^(NSImageView * imageView, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(idx < item.gifs.count) {
            TL_foundGifExternal *gif = item.gifs[idx];
            [imageView setImageWithURL:[NSURL URLWithString:gif.thumb_url]];
        } else {
            imageView.image = nil;
        }
    
    }];
    
    
}

@end


@interface TGModalGifSearch () <TMSearchTextFieldDelegate,TMTableViewDelegate>
@property (nonatomic,strong) TMTableView *tableView;
@property (nonatomic,strong) TMSearchTextField *searchField;

@end

@implementation TGModalGifSearch

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        [self setContainerFrameSize:NSMakeSize(300, 300)];
        
        [self initialize];
    }
    
    return self;
}


-(void)initialize {
    _tableView = [[TMTableView alloc] initWithFrame:NSMakeRect(0, 0, self.containerSize.width, self.containerSize.height-50)];
    [self addSubview:_tableView.containerView];
    
    
    _tableView.tm_delegate = self;
    
    _searchField = [[TMSearchTextField alloc] initWithFrame:NSMakeRect(10, self.containerSize.height - 40, self.containerSize.width - 20, 30)];
    _searchField.delegate = self;
    [self addSubview:_searchField];
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return [self size].height;
}
- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}
- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    return [_tableView cacheViewForClass:[TGGifSearchRowView class] identifier:@"TGGifSearchRowView" withSize:NSMakeSize(self.containerSize.width, self.size.height)];
}
- (void)selectionDidChange:(NSInteger)row item:(TMRowItem *) item {
    
}
- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return NO;
}
- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return NO;
}


-(void)searchFieldTextChange:(NSString *)searchString {
    [RPCRequest sendRequest:[TLAPI_messages_searchGifs createWithQ:searchString offset:0] successHandler:^(id request, TL_messages_foundGifs *response) {
        
        
        [self drawResponse:response.results];
        
    } errorHandler:^(id request, RpcError *error) {
        
        
    }];
}

-(NSSize)size {
    int s = (self.containerSize.width - 20 - 8) / 4;
    return NSMakeSize(s, s);
}

-(void)drawResponse:(NSArray *)gifs {
    [self.tableView removeAllItems:YES];
    
    NSMutableArray *row = [[NSMutableArray alloc] init];
    
    [gifs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(row.count < 4) {
            [row addObject:obj];
        } else  {
            TGGifSearchRowItem *item = [[TGGifSearchRowItem alloc] initWithObject:[row copy]];
            [row removeAllObjects];
            [row addObject:obj];
            
            [_tableView addItem:item tableRedraw:NO];
        }
        
    }];
    
    if(row.count > 0) {
        TGGifSearchRowItem *item = [[TGGifSearchRowItem alloc] initWithObject:row];
        [_tableView addItem:item tableRedraw:NO];
    }
    
    [_tableView reloadData];
    
}

@end
