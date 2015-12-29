#import "TGMediaContextTableView.h"
#import "TMTableView.h"
#import "TMSearchTextField.h"
#import "UIImageView+AFNetworking.h"
#import "SpacemanBlocks.h"
#import "TGImageView.h"
#import "TGExternalImageObject.h"
#import "TGVTVideoView.h"
#import "TMLoaderView.h"
#import "DownloadQueue.h"
#import "DownloadDocumentItem.h"
#import "DownloadExternalItem.h"
#import "MessagesBottomView.h"

@interface TGPicItemView : TMView
@property (nonatomic,strong) TGImageView *imageView;
@end


@implementation TGPicItemView

static NSImage *tgContextPicCap() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 1, 1);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [NSColorFromRGB(0xf1f1f1) set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:4 yRadius:4];
        [path fill];
        
        [image unlockFocus];
    });
    return image;
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _imageView = [[TGImageView alloc] initWithFrame:NSZeroRect];
        
        NSImage *image = [tgContextPicCap() copy];
        image.size = _imageView.frame.size;
        [_imageView setImage:image];
        
        self.wantsLayer = YES;
        self.layer.borderColor = [NSColor whiteColor].CGColor;
        self.layer.borderWidth = 1;
        [self addSubview:_imageView];
    }
    
    return self;
}


-(void)setSize:(NSSize)size {
    [_imageView setFrame:NSMakeRect(MIN(- roundf((size.width - NSWidth(self.frame))/2),0), MIN(- roundf((size.height - NSHeight(self.frame))/2),0), size.width, size.height)];
}

@end

@interface TGGifPlayerItemView : TMView {
    SMDelayedBlockHandle _handle;
    BOOL _prevState;
}
@property (nonatomic,strong) TGVTVideoView *player;
@property (nonatomic,strong) TMLoaderView *loaderView;

@property (nonatomic,strong) DownloadEventListener *downloadEventListener;

@property (nonatomic,strong) TLBotContextResult *botResult;
@property (nonatomic,assign) NSSize size;
@property (nonatomic,strong) TGImageObject *imageObject;

@property (nonatomic,strong) TL_localMessage *fakeMessage;


@property (nonatomic,weak) TMTableView *table;
@property (nonatomic,weak) TMRowItem *item;



@end


@implementation TGGifPlayerItemView

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {

        
        _fakeMessage = [[TL_localMessage alloc] init];
        
        _fakeMessage.media = [TL_messageMediaDocument createWithDocument:nil caption:@""];
        
        self.wantsLayer = YES;
        self.layer.borderColor = [NSColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0;
        _loaderView = [[TMLoaderView alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
        [_loaderView setStyle:TMCircularProgressDarkStyle];
        
        
        _player = [[TGVTVideoView alloc] initWithFrame:NSZeroRect];
        
        
        [self addSubview:_player];
        
        
        [self addSubview:_loaderView];
        
        
        
        _downloadEventListener = [[DownloadEventListener alloc] init];
        
        weak();
        
        [_downloadEventListener setCompleteHandler:^(DownloadItem *item) {
            
            __strong TGGifPlayerItemView *strongSelf = weakSelf;
            
            [ASQueue dispatchOnMainQueue:^{
                if(strongSelf != nil) {
                    [strongSelf startDownload];
                }
            }];
            
            
        }];
        
        [_downloadEventListener setProgressHandler:^(DownloadItem *item) {
            __strong TGGifPlayerItemView *strongSelf = weakSelf;
            
            [ASQueue dispatchOnMainQueue:^{
                if(strongSelf != nil) {
                    [strongSelf.loaderView setProgress:item.progress animated:YES];
                }
            }];
        }];
        
        [_downloadEventListener setErrorHandler:^(DownloadItem *item) {
            __strong TGGifPlayerItemView *strongSelf = weakSelf;
            
            [ASQueue dispatchOnMainQueue:^{
                if(strongSelf != nil) {
                    
                }
            }];
        }];
        
        
    }
    
    return self;
}

-(void)setSize:(NSSize)size {
    _size = size;
    [_player setFrame:NSMakeRect(MIN(- roundf((size.width - NSWidth(self.frame))/2),0), MIN(- roundf((size.height - NSHeight(self.frame))/2),0), MAX(size.width,NSWidth(self.frame)), MAX(size.height,NSHeight(self.frame)))];
}

-(void)setBotResult:(TLBotContextResult *)botResult {
    
    [self.downloadItem removeEvent:_downloadEventListener];
    _prevState = NO;
    [_player setPath:nil];
    
    _botResult = botResult;
    
    _fakeMessage.media.document = _botResult.document;
}


-(void)setImageObject:(TGImageObject *)imageObject {
    if([imageObject isKindOfClass:[ImageObject class]]) {
        _imageObject = imageObject;
    } else
        _imageObject = nil;
}

-(void)dealloc {
    [self.downloadItem removeEvent:_downloadEventListener];
}

-(void)updateContainer {
    
    _prevState = NO;
    [_loaderView removeFromSuperview];
    [self addSubview:_loaderView];
    [_loaderView setHidden:self.isset];
    
    if(_loaderView.isHidden) {
        [_loaderView setCurrentProgress:0];
    } else {
        [_loaderView setProgress:self.downloadItem.progress animated:YES];
        [_loaderView setCenterByView:self];
    }
    
    [_player setImageObject:_imageObject];
    
    [self _didScrolledTableView:nil];
}

-(NSString *)path {
    if(self.botResult.document != nil) {
        return self.botResult.document.path_with_cache;
    } else {
        return path_for_external_link(self.botResult.content_url);
    }
}

-(BOOL)isset {
    if(self.botResult.document != nil) {
        return self.botResult.document.isset;
    } else {
        return fileSize(self.path) > 0;
    }
}

-(NSUInteger)hash {
    return self.botResult.document != nil ? self.botResult.document.n_id : [self.botResult.content_url hash];
}


-(DownloadItem *)downloadItem {
    
    DownloadItem *item = [DownloadQueue find:self.hash];
    
    return item;
}


-(void)startDownload {
    
    if(!self.isset) {
                
        DownloadItem *item;
        
        if(!self.downloadItem) {
            if(self.botResult.document != nil) {
                item = [[DownloadDocumentItem alloc] initWithObject:_fakeMessage];
            } else {
                item = [[DownloadExternalItem alloc] initWithObject:self.botResult.content_url];
            }
            
            
            [item start];
            
            [self.downloadItem addEvent:self.downloadEventListener];
        }
        
        
    }
    
    [self updateContainer];
}

-(void)cancelDownload {
    [[self downloadItem] cancel];
}


-(void)_didScrolledTableView:(NSNotification *)notification {
    
    BOOL (^check_block)() = ^BOOL() {
        
        BOOL completelyVisible = self.visibleRect.size.width > 0 && self.visibleRect.size.height > 20;
                
        return  completelyVisible && ((self.window != nil && self.window.isKeyWindow) || notification == nil) && self.isset;
        
    };
    
    cancel_delayed_block(_handle);
        
    dispatch_block_t block = ^{
        BOOL nextState = check_block();
        
        if(_prevState != nextState) {
            [_player setPath:nextState ? self.path : nil];
        }
        
        _prevState = nextState;
    };
    
    if(!check_block())
        block();
    else
        _handle = perform_block_after_delay(0.03, block);
    
}

-(void)removeFromSuperview {
    [super removeFromSuperview];
    [_player setPath:nil];
}

-(void)viewDidMoveToWindow {
    if(self.window == nil) {
        
        [self removeScrollEvent];
        [_player setPath:nil];
        [self.downloadItem removeEvent:_downloadEventListener];
        
    } else {
        [self addScrollEvent];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didScrolledTableView:) name:NSWindowDidBecomeKeyNotification object:self.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didScrolledTableView:) name:NSWindowDidResignKeyNotification object:self.window];
    }
}

-(void)addScrollEvent {
    id clipView = [[self.item.table enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didScrolledTableView:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
    
}

-(void)removeScrollEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end


@interface TGGifSearchRowItem : TMRowItem
@property (nonatomic,strong) NSArray *gifs;
@property (nonatomic,assign) long randKey;
@property (nonatomic,strong) NSArray *proportions;
@property (nonatomic,strong) NSArray *imageObjects;

@end

@implementation TGGifSearchRowItem

-(id)initWithObject:(id)object sizes:(NSArray *)sizes {
    if(self = [super initWithObject:object]) {
        _gifs = object;
        _randKey = rand_long();
        _proportions = sizes;
        
        NSMutableArray *imageObjects = [NSMutableArray array];
        
        [_gifs enumerateObjectsUsingBlock:^(TLBotContextResult *botResult, NSUInteger idx, BOOL * _Nonnull stop) {
            
            TGImageObject *imageObject;
            
            if(botResult.photo.sizes.count > 0) {
                
                TLPhotoSize *size = botResult.photo.sizes[MIN(2,botResult.photo.sizes.count-1)];
                
                imageObject = [[TGImageObject alloc] initWithLocation:size.location placeHolder:nil sourceId:0 size:size.size];
            } else if([botResult.document.thumb isKindOfClass:[TL_photoSize class]] || [botResult.document.thumb isKindOfClass:[TL_photoCachedSize class]]) {
                
                TLPhotoSize *size = botResult.document.thumb;
                
                imageObject = [[TGImageObject alloc] initWithLocation:size.location placeHolder:botResult.document.thumb.bytes.length > 0 ?[[NSImage alloc] initWithData:botResult.document.thumb.bytes] : nil sourceId:0 size:size.size];
            } else if(botResult.thumb_url.length > 0) {
                imageObject = [[TGExternalImageObject alloc] initWithURL:botResult.thumb_url];
            } else if([botResult.type isEqualToString:@"photo"] && botResult.content_url.length > 0) {
                imageObject = [[TGExternalImageObject alloc] initWithURL:botResult.content_url];
            }
            
            imageObject.imageSize = [sizes[idx] sizeValue];
            
            if(imageObject == nil)
                imageObject = (TGImageObject *) [[NSNull alloc] init];
            
            [imageObjects addObject:imageObject];
        }];
        
        _imageObjects = [imageObjects copy];
        
    }
    
    return self;
}



-(NSUInteger)hash {
    return _randKey;
}

@end


@interface TGGifSearchRowView : TMRowView
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@end


@implementation TGGifSearchRowView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
    }
    
    return self;
}


-(void)redrawRow {
    [super redrawRow];
    
    
    TGGifSearchRowItem *item = (TGGifSearchRowItem *)[self rowItem];
    
    [self removeAllSubviews];
    
    if(self.subviews.count > item.gifs.count) {
        
        NSRange range = NSMakeRange(item.gifs.count, self.subviews.count - item.gifs.count);


        NSArray *copy = [self.subviews copy];
        
        [copy enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:0 usingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [obj removeFromSuperview];
            
        }];
        
        assert(self.subviews.count == item.gifs.count);
    }
    
    
    
    __block int x = 0;
    __block float max_x = 0;
    [item.proportions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSSize size = [obj sizeValue];
        max_x+= size.width;
    }];
    
    int containerWidthDif = 0;
    
    if(max_x > NSWidth(self.frame)) {
        containerWidthDif = ceil((max_x - NSWidth(self.frame)) / (float)item.gifs.count);
    }
    
    
    [item.gifs enumerateObjectsUsingBlock:^(TLBotContextResult *botResult, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
        NSSize size = [item.proportions[idx] sizeValue];
        
        TMView *container; //self.subviews.count > idx ? self.subviews[idx] : nil;
        
        NSRect rect = NSMakeRect(x, 0, (idx == (item.gifs.count - 1) && !(item.table.count-1 == item.rowId) ? NSWidth(self.frame) - x : size.width - containerWidthDif), NSHeight(self.frame));
        
        if([botResult.content_type isEqualToString:@"video/mp4"] || (botResult.document && [botResult.document.mime_type isEqualToString:@"video/mp4"] && [botResult.document attributeWithClass:[TL_documentAttributeAnimated class]] != nil)) {
            
            TGGifPlayerItemView *videoContainer;
            
            if(container && [container isKindOfClass:[TGGifPlayerItemView class]]) {
                videoContainer = (TGGifPlayerItemView *) container;
                [videoContainer setFrame:rect];
            } else {
                [container removeFromSuperview];
                videoContainer = [[TGGifPlayerItemView alloc] initWithFrame:rect];
                [self addSubview:videoContainer];
            }
            
            videoContainer.size = size;
            
            videoContainer.botResult = botResult;
            videoContainer.table = item.table;
            videoContainer.item = item;
            [videoContainer setImageObject:item.imageObjects[idx]];
            [videoContainer startDownload];
            
           
            container = videoContainer;
            
        } else if(![item.imageObjects[idx] isKindOfClass:[NSNull class]]) {
            
            TGPicItemView *picContainer;
            
            if(container && [container isKindOfClass:[TGPicItemView class]]) {
                picContainer = (TGPicItemView *) container;
                [container setFrame:rect];
            } else {
                [container removeFromSuperview];
                picContainer = [[TGPicItemView alloc] initWithFrame:rect];
                [self addSubview:picContainer];
            }
            
            [picContainer setSize:size];
            [picContainer.imageView setObject:item.imageObjects[idx]];
            container = picContainer;
           
        } else {
            [container removeFromSuperview];
            container = nil;
        }
        
        if(container != nil) {
            
            x+= NSWidth(container.frame);
        }
        
    }];
    
    
    int bp = 0;
    
    assert(self.subviews.count == item.gifs.count);
}

-(void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
    
    NSView *view = [self hitTest:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
    
    
    NSUInteger index = [self.subviews indexOfObject:view.superview];
    
    
    TGGifSearchRowItem *item = (TGGifSearchRowItem *)[self rowItem];
    
    if(index < item.gifs.count) {
        [item.table.tm_delegate selectionDidChange:index item:item];
    }
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}

@end


@interface TGMediaContextTableView () <TMTableViewDelegate>
@property (nonatomic,strong) NSMutableArray *items;
@end

@implementation TGMediaContextTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.tm_delegate = self;
        _items = [NSMutableArray array];
        [self addScrollEvent];
    }
    
    return self;
}



- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return 100;
}
- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}
- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    return [self cacheViewForClass:[TGGifSearchRowView class] identifier:@"TGGifSearchRowView" withSize:NSMakeSize(NSWidth(self.frame), 100)];
}
- (void)selectionDidChange:(NSInteger)row item:(TGGifSearchRowItem *) item {
    
    TLBotContextResult *botResult = item.gifs[row];
    
    if(_choiceHandler) {
        _choiceHandler(botResult);
    }
    
}
- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}
- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}


-(NSArray *)makeRow:(NSMutableArray *)gifs isLastRowItem:(BOOL)isLastRowItem {
    
    
    __block int currentWidth = 0;
    __block int maxHeight = 100;
    NSMutableArray *sizes = [[NSMutableArray alloc] init];
    
    dispatch_block_t block = ^{
        [gifs enumerateObjectsUsingBlock:^(TLBotContextResult *botResult, NSUInteger idx, BOOL * _Nonnull stop) {
            
            TL_documentAttributeVideo *video = (TL_documentAttributeVideo *) [botResult.document attributeWithClass:[TL_documentAttributeVideo class]];
            
            int w = MAX(video.w,botResult.w);
            int h = MAX(video.h,botResult.h);
            
            if(botResult.photo.sizes.count > 0 && video == nil) {
                TLPhotoSize *s = botResult.photo.sizes[MIN(botResult.photo.sizes.count-1,2)];
                w = s.w;
                h = s.h;
            }
            
            NSSize size = convertSize(NSMakeSize(w,h), NSMakeSize(INT32_MAX, maxHeight));
            
            if(size.width < maxHeight || size.height < maxHeight) {
                int max = MAX(maxHeight - size.width,maxHeight - size.height);
                
                size.width+=max;
                size.height+=max;
                
            
            }
            
            if(!isLastRowItem && idx == (gifs.count - 1)) {
                if(currentWidth+size.width < NSWidth(self.frame)) {
                    int dif = NSWidth(self.frame) - (currentWidth+size.width);
                    
                    size.width+=dif;
                    size.height+=dif;
                }
                
            }
            
            currentWidth+=size.width;
            
            [sizes addObject:[NSValue valueWithSize:size]];
            
        }];
    };
    
    
    
    
    while (1) {
        currentWidth = 0;
        [sizes removeAllObjects];
        
        block();
        
        if((currentWidth - NSWidth(self.frame)) > 100 && gifs.count > 1) {
            [gifs removeLastObject];
            continue;
        }
        
        
        if((currentWidth < NSWidth(self.frame) && !isLastRowItem) && gifs.count > 0) {
            
            maxHeight+=(6*gifs.count);
            
        } else
            break;
        
    }
    
    
    return sizes;
    
}


-(void)clear {
    [self removeAllItems:YES];
    _items = [NSMutableArray array];
}


-(void)drawResponse:(NSArray *)items {
    
    NSMutableArray *filter = [NSMutableArray array];
    
    [items enumerateObjectsUsingBlock:^(TLBotContextResult *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(!((obj.document == nil || [obj.document isKindOfClass:[TL_documentEmpty class]]) && (obj.photo == nil || [obj.photo isKindOfClass:[TL_photoEmpty class]]) && obj.content_url.length ==0)) {
            [filter addObject:obj];
        }
        
    }];
    
    items = filter;
    
    [_items addObjectsFromArray:items];
    
    
    TGGifSearchRowItem *prevItem = [self.list lastObject];
    
     int f = floor(NSWidth(self.frame)/100);
    
     NSMutableArray *draw = [items mutableCopy];
    
    
    __block BOOL redrawPrev = NO;
    
    
    if(prevItem && prevItem.gifs.count < f) {
        [draw insertObjects:prevItem.gifs atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, prevItem.gifs.count)]];
        
        redrawPrev = YES;
    }
    
    dispatch_block_t next = ^{
        
        int rowCount = MIN(f,(int)draw.count);
        
        NSMutableArray *r = [[draw subarrayWithRange:NSMakeRange(0, rowCount)] mutableCopy];
        
        NSArray *s = [self makeRow:r isLastRowItem:r.count < rowCount || (f > rowCount && r.count <= rowCount)];
        
        [draw removeObjectsInArray:r];
        
        TGGifSearchRowItem *item = [[TGGifSearchRowItem alloc] initWithObject:[r copy] sizes:[s copy]];
       
        if(redrawPrev) {
            NSUInteger index = [self.list indexOfObject:prevItem];
            
            [self.list replaceObjectAtIndex:index withObject:item];
            [self reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            
            redrawPrev = NO;
        } else {
            [self addItem:item tableRedraw:YES];
        }
    };
    
    while (draw.count > 0) {
        next();
    }
    
}

-(void)draw {
    
}

-(void)addScrollEvent {
    id clipView = [[self enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didScrolledTableView:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
    
}

-(void)removeScrollEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)_didScrolledTableView:(NSNotification *)notification {
    if(_needLoadNext) {
        _needLoadNext([self.scrollView isNeedUpdateBottom]);
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end