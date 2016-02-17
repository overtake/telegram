//
//  TGModalCompressingView.m
//  Telegram
//
//  Created by keepcoder on 15/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGModalCompressingView.h"
#import "TGCompressItem.h"
#import "TGDocumentThumbObject.h"
#import "TGImageView.h"

@interface TGComressRowItem : TMRowItem

@property (nonatomic,strong) TGCompressItem *compressItem;
@property (nonatomic,strong) TGThumbnailObject *thumbObject;

@end


@implementation TGComressRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _compressItem = object;
        _thumbObject = [[TGDocumentThumbObject alloc] initWithFilepath:_compressItem.path];
        _thumbObject.imageSize = NSMakeSize(50, 50);
    }
    
    return self;
}

-(NSUInteger)hash {
    return [_compressItem.path hash];
}

@end



@interface TGComressRowView : TMRowView
@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,strong) TMTextField *statusTextField;
@property (nonatomic,strong) TMView *progressView;
@property (nonatomic,strong) BTRButton *cancelButton;
@end


@implementation TGComressRowView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _progressView = [[TMView alloc] initWithFrame:NSMakeRect(1, 1, 0, NSHeight(frameRect) - 2)];
        _progressView.backgroundColor = BLUE_COLOR_SELECT;
        _progressView.wantsLayer = YES;
        _progressView.layer.cornerRadius = 4;
        [self addSubview:_progressView];

        
        _imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(5, 5, 50, 50)];
        [_imageView setCornerRadius:4];
        [self addSubview:_imageView];
        
        _statusTextField = [TMTextField defaultTextField];
        
        [self addSubview:_statusTextField];
        
        _cancelButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(frameRect) - 60, 0, 60, 16)];
        
        
        [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forControlState:BTRControlStateNormal];
        [_cancelButton setTitleFont:TGSystemFont(13) forControlState:BTRControlStateNormal];
        [_cancelButton setTitleColor:BLUE_UI_COLOR forControlState:BTRControlStateNormal];
        [_cancelButton setCenteredYByView:self];
        
        dispatch_block_t cancelBlock = ^{
            [self.item.compressItem cancel];
        };
        
        [_cancelButton addBlock:^(BTRControlEvents events) {
            
            cancelBlock();
            
        } forControlEvents:BTRControlEventMouseDownInside];
        
        _cancelButton.backgroundColor = [NSColor whiteColor];
        _cancelButton.heightBugFix = 4;
        [self addSubview:_cancelButton];
    }
    
    return self;
}

-(TGComressRowItem *)item {
    return (TGComressRowItem *)[self rowItem];
}

-(void)redrawRow {
    [_imageView setObject:self.item.thumbObject];
    [self updateProgressWithAnimated:NO];
}

-(void)updateProgressWithAnimated:(BOOL)animated {
    
    _progressView.backgroundColor = self.item.compressItem.state == TGCompressItemStateCompressingFail ? [NSColor redColor] : BLUE_COLOR_SELECT;
    
    id view = animated ? [_progressView animator] : _progressView;
    
    int w = MAX(0,(NSWidth(self.frame) - 60) * ((float)self.item.compressItem.progress/100.0f) - 2);
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [view setFrameSize:NSMakeSize(w, NSHeight(self.frame) - 2)];
}


@end

@interface TGModalCompressingView ()<TMTableViewDelegate,TGCompressDelegate>
@property (nonatomic,strong) TMTableView *tableView;
@property (nonatomic,strong) NSMutableArray *compressedItems;
@end

@implementation TGModalCompressingView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _tableView = [[TMTableView alloc] initWithFrame:self.bounds];
        
        [self addSubview:_tableView.containerView];
        _tableView.defaultAnimation = NSTableViewAnimationEffectFade;
        _tableView.tm_delegate = self;
        
        _compressedItems = [NSMutableArray array];
        
        [self updateContainerSize];
    }
    
    return self;
}


-(void)compressAndSendAfterItems:(NSArray *)items {
    
    [_tableView removeAllItems:YES];
    
    [items enumerateObjectsUsingBlock:^(TGCompressItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        
        item.delegate = self;
        
        [_tableView addItem:[[TGComressRowItem alloc] initWithObject:item] tableRedraw:YES];
        
        [item readyAndStart];
        
    }];
    
    [self updateContainerSize];
}

-(void)addCompressItem:(TGCompressItem *)item {
    
    
    item.delegate = self;
    [_tableView addItem:[[TGComressRowItem alloc] initWithObject:item] tableRedraw:YES];
    [self updateContainerSize];
    
    [item readyAndStart];
}


-(void)updateContainerSize {
    [self setContainerFrameSize:NSMakeSize(300, MIN(300,self.tableView.count * 60))];
    [self.tableView.containerView setFrameSize:self.containerSize];
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TGComressRowItem *) item {
    return  60;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TGComressRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TGComressRowItem *) item {
    return [self.tableView cacheViewForClass:[TGComressRowView class] identifier:NSStringFromClass([TGComressRowView class]) withSize:NSMakeSize(self.containerSize.width, 60)];
}

- (void)selectionDidChange:(NSInteger)row item:(TGComressRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TGComressRowItem *) item {
    return NO;
}

- (BOOL)isSelectable:(NSInteger)row item:(TGComressRowItem *) item {
    return NO;
}

-(void)didStartCompressing:(TGCompressItem *)item {
    
}

-(void)didEndCompressing:(TGCompressItem *)item success:(BOOL)success {
    
    TGComressRowItem *rowItem = (TGComressRowItem *) [_tableView itemByHash:[item.path hash]];
    
    if(item.state == TGCompressItemStateCompressingSuccess) {
        [_controller sendCompressedItem:item];
        
        [_tableView removeItem:rowItem];
    }
    
    [self updateContainerSize];
    
    if(_tableView.count == 0) {
        [super close:YES];
    }
    
    
}

-(void)close:(BOOL)animated {
    //disable closing before compress all items
}

-(void)didProgressUpdate:(TGCompressItem *)item progress:(int)progress {
    TGComressRowItem *rowItem = (TGComressRowItem *) [_tableView itemByHash:[item.path hash]];
    
    NSUInteger idx = [_tableView indexOfItem:rowItem];
    if(idx != NSNotFound) {
        TGComressRowView *view = [_tableView viewAtColumn:0 row:idx makeIfNecessary:NO];
        
        [view updateProgressWithAnimated:YES];
    }
    
   
}

-(void)didCancelCompressing:(TGCompressItem *)item {
    TGComressRowItem *rowItem = (TGComressRowItem *) [_tableView itemByHash:[item.path hash]];
    
    [_tableView removeItem:rowItem];
    
    [self updateContainerSize];
    
    if(_tableView.count == 0) {
        [super close:YES];
    }

}

@end
