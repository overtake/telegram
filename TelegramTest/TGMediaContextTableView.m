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

-(instancetype)initWithFrame:(NSRect)frameRect size:(NSSize)size {
    if(self = [super initWithFrame:frameRect]) {
        _imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(MIN(- roundf((size.width - NSWidth(self.frame))/2),0), MIN(- roundf((size.height - NSHeight(self.frame))/2),0), size.width, size.height)];
        self.wantsLayer = YES;
        self.layer.borderColor = [NSColor whiteColor].CGColor;
        self.layer.borderWidth = 1;
        [self addSubview:_imageView];
    }
    
    return self;
}

@end

@interface TGGifPlayerItemView : TMView {
    SMDelayedBlockHandle _handle;
    BOOL _prevState;
}
@property (nonatomic,strong) TGVTVideoView *player;
@property (nonatomic,strong) TMLoaderView *loaderView;

@property (nonatomic,strong) DownloadEventListener *downloadEventListener;

@property (nonatomic,strong) TLWebPage *webpage;
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
        
        _fakeMessage.media = [TL_messageMediaDocument createWithDocument:nil];
        
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

-(void)setWebpage:(TLWebPage *)webpage {
    
    [self.downloadItem removeEvent:_downloadEventListener];
    _prevState = NO;
    [_player setPath:nil];
    
    _webpage = webpage;
    
    _fakeMessage.media.document = _webpage.document;
}

-(void)dealloc {
    [self.downloadItem removeEvent:_downloadEventListener];
}

-(void)updateContainer {
    
    _prevState = NO;
    
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
    if(self.webpage.document != nil) {
        return self.webpage.document.path_with_cache;
    } else {
        return path_for_external_link(self.webpage.content_url);
    }
}

-(BOOL)isset {
    if(self.webpage.document != nil) {
        return self.webpage.document.isset;
    } else {
        return fileSize(self.path) > 0;
    }
}

-(NSUInteger)hash {
    return self.webpage.document != nil ? self.webpage.document.n_id : [self.webpage.content_url hash];
}


-(DownloadItem *)downloadItem {
    
    DownloadItem *item = [DownloadQueue find:self.hash];
    
    return item;
}


-(void)startDownload {
    
    if(!self.isset) {
                
        DownloadItem *item;
        
        if(!self.downloadItem) {
            if(self.webpage.document != nil) {
                item = [[DownloadDocumentItem alloc] initWithObject:_fakeMessage];
            } else {
                item = [[DownloadExternalItem alloc] initWithObject:self.webpage.content_url];
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
        
        BOOL completelyVisible = self.visibleRect.size.width > 0 && self.visibleRect.size.height > 0; //idx >= visibleRange.location && idx <= visibleRange.location + visibleRange.length;
                
        return  completelyVisible && ((self.window != nil && self.window.isKeyWindow) || notification == nil) && self.isset;
        
    };
    
    cancel_delayed_block(_handle);
    
    dispatch_block_t block = ^{
        BOOL nextState = check_block();
        
        if(_prevState != nextState || !nextState) {
            [_player setPath:nextState ? self.path : nil];
        }
        
        _prevState = nextState;
    };
    
    
    
   // if(check_block()) {
   //     _handle = perform_block_after_delay(0.02, block);
   // } else {
        block();
  //  }
    
    
    
    
}



-(void)viewDidMoveToWindow {
    if(self.window == nil) {
        
        [self removeScrollEvent];
        [_player pause];
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
        
        [_gifs enumerateObjectsUsingBlock:^(TL_webPage *webpage, NSUInteger idx, BOOL * _Nonnull stop) {
            
            TGImageObject *imageObject;
            
            if(webpage.photo.sizes.count > 0) {
                
                TLPhotoSize *size = webpage.photo.sizes[MIN(2,webpage.photo.sizes.count-1)];
                
                imageObject = [[TGImageObject alloc] initWithLocation:size.location placeHolder:nil sourceId:0 size:size.size];
            } else if([webpage.document.thumb isKindOfClass:[TL_photoSize class]] || [webpage.document.thumb isKindOfClass:[TL_photoCachedSize class]]) {
                
                TLPhotoSize *size = webpage.document.thumb;
                
                imageObject = [[TGImageObject alloc] initWithLocation:size.location placeHolder:webpage.document.thumb.bytes.length > 0 ?[[NSImage alloc] initWithData:webpage.document.thumb.bytes] : nil sourceId:0 size:size.size];
            } else if(webpage.thumb_url.length > 0) {
                imageObject = [[TGExternalImageObject alloc] initWithURL:webpage.thumb_url];
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
    
    
    if(self.subviews.count > item.gifs.count) {
        
        NSRange range = NSMakeRange(item.gifs.count, self.subviews.count - item.gifs.count);


        NSArray *copy = [self.subviews copy];
        
        [copy enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:0 usingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [obj removeFromSuperview];
            
        }];
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
    
    
    [item.gifs enumerateObjectsUsingBlock:^(TL_webPage *webpage, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
        NSSize size = [item.proportions[idx] sizeValue];
        
        TMView *container = self.subviews.count > idx ? self.subviews[idx] : nil;
        
        NSRect rect = NSMakeRect(x, 0, (idx == (item.gifs.count - 1) && !(item.table.count-1 == item.rowId) ? NSWidth(self.frame) - x : size.width - containerWidthDif), NSHeight(self.frame));
        
        if([webpage.type isEqualToString:@"gifv"] || (webpage.document && [webpage.document.mime_type isEqualToString:@"video/mp4"] && [webpage.document attributeWithClass:[TL_documentAttributeAnimated class]] != nil)) {
            
            TGGifPlayerItemView *videoContainer;
            
            if(false) {
                videoContainer = (TGGifPlayerItemView *) container;
                [videoContainer setFrame:rect];
            } else {
                videoContainer = [[TGGifPlayerItemView alloc] initWithFrame:rect];
                [self addSubview:videoContainer];
            }
            
            videoContainer.size = size;
            
            videoContainer.webpage = webpage;
            videoContainer.table = item.table;
            videoContainer.item = item;
            [videoContainer setImageObject:item.imageObjects[idx]];
            [videoContainer startDownload];
            
           
            container = videoContainer;
            
        } else if(![item.imageObjects[idx] isKindOfClass:[NSNull class]]) {
            
            TGPicItemView *picContainer = [[TGPicItemView alloc] initWithFrame:rect size:size];
            [picContainer.imageView setObject:item.imageObjects[idx]];
            container = picContainer;
            [self addSubview:container];
        }
        
        if(container != nil) {
            
            x+= NSWidth(container.frame);
        }
        
    }];
    
    
    
    
    
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
    
    TL_webPage *webpage = item.gifs[row];
    
    __block TLDocument *document = webpage.document;
    
    
    if(document == nil) {
        
        NSMutableArray *attrs = [[NSMutableArray alloc] init];
        [attrs addObject:[TL_documentAttributeAnimated create]];
        [attrs addObject:[TL_documentAttributeImageSize createWithW:webpage.w h:webpage.h]];
        [attrs addObject:[TL_documentAttributeFilename createWithFile_name:@"giphy.gif"]];
        
        [attrs addObject:[TL_documentAttributeImageSize createWithW:webpage.w h:webpage.h]];
        
        TGGifSearchRowView *view = [self viewAtColumn:0 row:[self indexOfItem:item] makeIfNecessary:NO];
        
        NSImage *image = view.subviews[row].subviews[0].layer.contents;
        
        NSSize thumbSize = strongsize(NSMakeSize(webpage.w, webpage.h), 90);
        document = [TL_externalDocument createWithN_id:webpage.n_id date:[[MTNetwork instance] getTime] mime_type:@"video/mp4" thumb:[TL_photoCachedSize createWithType:@"x" location:[TL_fileLocationUnavailable createWithVolume_id:rand_long() local_id:0 secret:0] w:thumbSize.width h:thumbSize.height bytes:jpegNormalizedData(image)] external_url:webpage.url search_q:@"" perform_date:webpage.date external_webpage:webpage attributes:attrs];
    }
    
    if(_choiceHandler) {
        _choiceHandler(document);
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
        [gifs enumerateObjectsUsingBlock:^(TL_webPage *webpage, NSUInteger idx, BOOL * _Nonnull stop) {
            
            TL_documentAttributeVideo *video = (TL_documentAttributeVideo *) [webpage.document attributeWithClass:[TL_documentAttributeVideo class]];
            
            int w = MAX(video.w,webpage.w);
            int h = MAX(video.h,webpage.h);
            
            if(webpage.photo.sizes.count > 0 && video == nil) {
                TLPhotoSize *s = webpage.photo.sizes[MIN(webpage.photo.sizes.count-1,2)];
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
    
    [_items addObjectsFromArray:items];
    
    
    NSMutableArray *draw = [items mutableCopy];
    
    dispatch_block_t next = ^{
        
        int rowCount = MIN(floor(NSWidth(self.frame)/100),draw.count);
        
        NSMutableArray *r = [[draw subarrayWithRange:NSMakeRange(0, rowCount)] mutableCopy];
        
        NSArray *s = [self makeRow:r isLastRowItem:r.count < rowCount];
        
        [draw removeObjectsInArray:r];
        
        TGGifSearchRowItem *item = [[TGGifSearchRowItem alloc] initWithObject:[r copy] sizes:[s copy]];
        [self addItem:item tableRedraw:YES];
        
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