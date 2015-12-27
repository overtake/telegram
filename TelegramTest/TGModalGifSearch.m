////
////  TGModalGifSearch.m
////  Telegram
////
////  Created by keepcoder on 03/12/15.
////  Copyright © 2015 keepcoder. All rights reserved.
////
//
#import "TGModalGifSearch.h"
//#import "TMTableView.h"
//#import "TMSearchTextField.h"
//#import "UIImageView+AFNetworking.h"
//#import "SpacemanBlocks.h"
//#import "TGImageView.h"
//#import "TGExternalImageObject.h"
//#import "TGVTVideoView.h"
//#import "TMLoaderView.h"
//#import "DownloadQueue.h"
//#import "DownloadDocumentItem.h"
//#import "DownloadExternalItem.h"
//@interface TGGifPlayerItemView : TMView
//@property (nonatomic,strong) TGVTVideoView *player;
//@property (nonatomic,strong) TMLoaderView *loaderView;
//
//@property (nonatomic,strong) DownloadEventListener *downloadEventListener;
//
//@property (nonatomic,strong) TLWebPage *webpage;
//@property (nonatomic,assign) NSSize size;
//
//@property (nonatomic,strong) TL_localMessage *fakeMessage;
//
//
//@property (nonatomic,weak) TMTableView *table;
//@property (nonatomic,weak) TMRowItem *item;
//@end
//
//
//@implementation TGGifPlayerItemView
//
//-(id)initWithFrame:(NSRect)frameRect imageSize:(NSSize)size webpage:(TLWebPage *)webpage {
//    if(self = [super initWithFrame:frameRect]) {
//        _webpage = webpage;
//        _size = size;
//        
//        _fakeMessage = [[TL_localMessage alloc] init];
//        _fakeMessage.media = [TL_messageMediaDocument createWithDocument:_webpage.document caption:@""];
//        
//        self.wantsLayer = YES;
//        self.layer.borderColor = [NSColor whiteColor].CGColor;
//        self.layer.borderWidth = 1.0;
//        
//        _loaderView = [[TMLoaderView alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
//        [_loaderView setStyle:TMCircularProgressDarkStyle];
//        
//        
//        _player = [[TGVTVideoView alloc] initWithFrame:NSMakeRect(- roundf((size.height - NSHeight(self.frame))/2), - roundf((size.height - NSHeight(self.frame))/2), size.width, size.height)];
//        
//        [self addSubview:_player];
//        
//        
//        [self addSubview:_loaderView];
//        
//        [_loaderView setCenterByView:self];
//        
//        _downloadEventListener = [[DownloadEventListener alloc] init];
//        
//        weak();
//        
//        [_downloadEventListener setCompleteHandler:^(DownloadItem *item) {
//            
//            __strong TGGifPlayerItemView *strongSelf = weakSelf;
//            
//            [ASQueue dispatchOnMainQueue:^{
//                if(strongSelf != nil) {
//                    [strongSelf.player setPath:strongSelf.path];
//                    [strongSelf.player pause];
//                    
//                    [strongSelf updateContainer];
//                }
//            }];
//            
//            
//        }];
//        
//        [_downloadEventListener setProgressHandler:^(DownloadItem *item) {
//            __strong TGGifPlayerItemView *strongSelf = weakSelf;
//            
//            [ASQueue dispatchOnMainQueue:^{
//                if(strongSelf != nil) {
//                    [strongSelf.loaderView setProgress:item.progress animated:YES];
//                }
//            }];
//        }];
//        
//        [_downloadEventListener setErrorHandler:^(DownloadItem *item) {
//            __strong TGGifPlayerItemView *strongSelf = weakSelf;
//            
//            [ASQueue dispatchOnMainQueue:^{
//                if(strongSelf != nil) {
//                    
//                }
//            }];
//        }];
//        
//        
//    }
//    
//    return self;
//}
//
//-(void)updateContainer {
//    [_loaderView setHidden:self.isset];
//    
//    if(_loaderView.isHidden) {
//        [_loaderView setCurrentProgress:0];
//    } else {
//        [_loaderView setProgress:self.downloadItem.progress animated:YES];
//    }
//    
//    [self _didScrolledTableView:nil];
//}
//
//-(NSString *)path {
//    if(self.webpage.document != nil) {
//        return self.webpage.document.path_with_cache;
//    } else {
//        return path_for_external_link(self.webpage.content_url);
//    }
//}
//
//-(BOOL)isset {
//    if(self.webpage.document != nil) {
//        return self.webpage.document.isset;
//    } else {
//        return fileSize(self.path) > 0;
//    }
//}
//
//-(NSUInteger)hash {
//    return self.webpage.document != nil ? self.webpage.document.n_id : [self.webpage.content_url hash];
//}
//
//
//-(DownloadItem *)downloadItem {
//    
//    DownloadItem *item = [DownloadQueue find:self.hash];
//    
//    return item;
//}
//
//
//-(void)startDownload {
//    
//    if(!self.isset) {
//        
//        DownloadItem *item;
//        
//        if(!self.downloadItem) {
//            if(self.webpage.document != nil) {
//                item = [[DownloadDocumentItem alloc] initWithObject:_fakeMessage];
//            } else {
//                item = [[DownloadExternalItem alloc] initWithObject:self.webpage.content_url];
//            }
//            
//            
//            [item start];
//            
//            [self.downloadItem addEvent:self.downloadEventListener];
//        }
//        
//        
//    } else {
//        [_player setPath:self.path];
//    }
//    
//    [self updateContainer];
//}
//
//-(void)cancelDownload {
//    [[self downloadItem] cancel];
//}
//
//
//-(void)_didScrolledTableView:(NSNotification *)notification {
//    
//    BOOL (^check_block)() = ^BOOL() {
//        
//        BOOL completelyVisible = self.visibleRect.size.width > 0 && self.visibleRect.size.height > 0;
//        
//        return  completelyVisible && ((self.window != nil && self.window.isKeyWindow) || notification == nil) && self.isset;
//        
//    };
//    
//    if(check_block()) {
//        [_player resume];
//    } else {
//        [_player pause];
//    }
//    
//}
//
//
//
//-(void)viewDidMoveToWindow {
//    if(self.window == nil) {
//        
//        [self removeScrollEvent];
//        [_player pause];
//        [_player setPath:nil];
//        
//    } else {
//        [self addScrollEvent];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didScrolledTableView:) name:NSWindowDidBecomeKeyNotification object:self.window];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didScrolledTableView:) name:NSWindowDidResignKeyNotification object:self.window];
//    }
//}
//
//-(void)addScrollEvent {
//    id clipView = [[self.item.table enclosingScrollView] contentView];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(_didScrolledTableView:)
//                                                 name:NSViewBoundsDidChangeNotification
//                                               object:clipView];
//    
//}
//
//-(void)removeScrollEvent {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//
//@end
//
//
//@interface TGGifSearchRowItem : TMRowItem
//@property (nonatomic,strong) NSArray *gifs;
//@property (nonatomic,assign) long randKey;
//@property (nonatomic,strong) NSArray *proportions;
//@property (nonatomic,strong) NSArray *imageObjects;
//
//@end
//
//@implementation TGGifSearchRowItem
//
//-(id)initWithObject:(id)object sizes:(NSArray *)sizes {
//    if(self = [super initWithObject:object]) {
//        _gifs = object;
//        _randKey = rand_long();
//        _proportions = sizes;
//        
//        NSMutableArray *imageObjects = [NSMutableArray array];
//        
//        [_gifs enumerateObjectsUsingBlock:^(TL_foundGif *gif, NSUInteger idx, BOOL * _Nonnull stop) {
//            
//            TGImageObject *imageObject;
//            
//            if([gif.webpage.document.thumb isKindOfClass:[TL_photoSize class]] || [gif.webpage.document.thumb isKindOfClass:[TL_photoCachedSize class]]) {
//                
//                TLPhotoSize *size = gif.webpage.document.thumb;
//                
//                imageObject = [[TGImageObject alloc] initWithLocation:size.location placeHolder:nil sourceId:0 size:size.size];
//            } else if(gif.webpage.thumb_url.length > 0) {
//                imageObject = [[TGExternalImageObject alloc] initWithURL:gif.webpage.thumb_url];
//            }
//                
//            imageObject.imageSize = [sizes[idx] sizeValue];
//            
//            [imageObjects addObject:imageObject];
//        }];
//        
//        _imageObjects = [imageObjects copy];
//        
//    }
//    
//    return self;
//}
//
//
//
//-(NSUInteger)hash {
//    return _randKey;
//}
//
//@end
//
//
//@interface TGGifSearchRowView : TMRowView
//@property (nonatomic, strong) NSTrackingArea *trackingArea;
//@end
//
//
//@implementation TGGifSearchRowView
//
//-(instancetype)initWithFrame:(NSRect)frameRect {
//    if(self = [super initWithFrame:frameRect]) {
//       
//    }
//    
//    return self;
//}
//
//
//-(void)redrawRow {
//    [super redrawRow];
//    
//    [self removeAllSubviews];
//    
//    
//    TGGifSearchRowItem *item = (TGGifSearchRowItem *)[self rowItem];
//    
//    __block int x = 0;
//    __block float max_x = 0;
//    [item.proportions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//         NSSize size = [obj sizeValue];
//        max_x+= size.width;
//    }];
//    
//    int containerWidthDif = 0;
//    
//    if(max_x > NSWidth(self.frame)) {
//        containerWidthDif = ceil((max_x - NSWidth(self.frame)) / (float)item.gifs.count);
//    }
//    
//    
//    [item.gifs enumerateObjectsUsingBlock:^(TL_foundGif *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        
//        
//        NSSize size = [item.proportions[idx] sizeValue];
//        
//        TGGifPlayerItemView *containerView = [[TGGifPlayerItemView alloc] initWithFrame:NSMakeRect(x, 0, (idx == item.gifs.count - 1 ? NSWidth(self.frame) - x : size.width - containerWidthDif), NSHeight(self.frame)) imageSize:size webpage:obj.webpage];
//        
//        containerView.table = item.table;
//        containerView.item = item;
//        
//        [containerView.player setImageObject:item.imageObjects[idx]];
//        
//        [containerView startDownload];
//
//        [self addSubview:containerView];
//        
//        x+= NSWidth(containerView.frame);
//        
//    }];
//    
//}
//
//-(void)updateTrackingAreas
//{
//    if(_trackingArea != nil) {
//        [self removeTrackingArea:_trackingArea];
//    }
//    
//    
//    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways | NSTrackingInVisibleRect);
//    _trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
//                                                  options:opts
//                                                    owner:self
//                                                 userInfo:nil];
//    [self addTrackingArea:_trackingArea];
//}
//
//-(void)mouseMoved:(NSEvent *)theEvent {
//    [super mouseMoved:theEvent];
//    
//    NSView *view = [self hitTest:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
//    
//    [self.subviews enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        
//        obj.layer.borderColor = GRAY_BORDER_COLOR.CGColor;
//        
//    }];
//    
//    view.layer.borderColor = BLUE_UI_COLOR.CGColor;
//}
//
//-(void)mouseUp:(NSEvent *)theEvent {
//    [super mouseUp:theEvent];
//    
//    NSView *view = [self hitTest:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
//    
//    
//    NSUInteger index = [self.subviews indexOfObject:view.superview];
//    
//    
//     TGGifSearchRowItem *item = (TGGifSearchRowItem *)[self rowItem];
//    
//    if(index < item.gifs.count) {
//        [item.table.tm_delegate selectionDidChange:index item:item];
//    }
//    
//}
//
//-(void)mouseDown:(NSEvent *)theEvent {
//    
//}
//
//@end
//
//
//@interface TGModalGifSearch () <TMSearchTextFieldDelegate,TMTableViewDelegate> {
//    __block SMDelayedBlockHandle _delayedBlockHandle;
//}
//@property (nonatomic,strong) TMTableView *tableView;
//@property (nonatomic,strong) TMSearchTextField *searchField;
//
//@property (nonatomic,weak) RPCRequest *request;
//@end
//
@implementation TGModalGifSearch
//
//- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
//    
//    // Drawing code here.
//}
//
//-(instancetype)initWithFrame:(NSRect)frameRect {
//    if(self = [super initWithFrame:frameRect]) {
//        [self setContainerFrameSize:NSMakeSize(350, 300)];
//        
//        [self initialize];
//    }
//    
//    return self;
//}
//
//
//-(void)initialize {
//    _tableView = [[TMTableView alloc] initWithFrame:NSMakeRect(0, 0, self.containerSize.width, self.containerSize.height-50)];
//    [self addSubview:_tableView.containerView];
//    
//    
//    _tableView.tm_delegate = self;
//    
//    _searchField = [[TMSearchTextField alloc] initWithFrame:NSMakeRect(10, self.containerSize.height - 40, self.containerSize.width - 20, 30)];
//    _searchField.delegate = self;
//    [self addSubview:_searchField];
//}
//
//- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
//    return 100;
//}
//- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
//    return NO;
//}
//- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
//    return [_tableView cacheViewForClass:[TGGifSearchRowView class] identifier:@"TGGifSearchRowView" withSize:NSMakeSize(self.containerSize.width, 100)];
//}
//- (void)selectionDidChange:(NSInteger)row item:(TGGifSearchRowItem *) item {
//    
//    TLFoundGif *gif = item.gifs[row];
//    
//    
//    [self close:YES];
//    
//    __block TLDocument *document = gif.webpage.document;
//    __block TLWebPage *webpage = gif.webpage;
//    
//    
//    if(document == nil) {
//        
//        NSMutableArray *attrs = [[NSMutableArray alloc] init];
//        [attrs addObject:[TL_documentAttributeAnimated create]];
//        [attrs addObject:[TL_documentAttributeImageSize createWithW:gif.webpage.w h:gif.webpage.h]];
//        [attrs addObject:[TL_documentAttributeFilename createWithFile_name:@"giphy.gif"]];
//        
//        [attrs addObject:[TL_documentAttributeImageSize createWithW:webpage.w h:webpage.h]];
//        
//        TGGifSearchRowView *view = [_tableView viewAtColumn:0 row:[_tableView indexOfItem:item] makeIfNecessary:NO];
//        
//        NSImage *image = view.subviews[row].subviews[0].layer.contents;
//        
//         NSSize thumbSize = strongsize(NSMakeSize(webpage.w, webpage.h), 90);
//        document = [TL_externalDocument createWithN_id:webpage.n_id date:[[MTNetwork instance] getTime] mime_type:@"video/mp4" thumb:[TL_photoCachedSize createWithType:@"x" location:[TL_fileLocationUnavailable createWithVolume_id:rand_long() local_id:0 secret:0] w:thumbSize.width h:thumbSize.height bytes:jpegNormalizedData(image)] external_url:webpage.url search_q:self.searchField.stringValue perform_date:webpage.date external_webpage:webpage attributes:attrs];
//    }
//    
//    TLMessageMedia *media = [TL_messageMediaDocument createWithDocument:document caption:@""];
//    
//    [self.messagesViewController sendFoundGif:media forConversation:self.messagesViewController.conversation];
//    
//    
//    
//}
//- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
//    return NO;
//}
//- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
//    return NO;
//}
//
//
//-(void)searchFieldTextChange:(NSString *)searchString {
//    
//    if(searchString.length == 0) {
//        [self drawResponse:@[]];
//        return;
//    }
//    
//    cancel_delayed_block(_delayedBlockHandle);
//    
//    [_request cancelRequest];
//    
//    _delayedBlockHandle = perform_block_after_delay(0.5, ^{
//        _request = [RPCRequest sendRequest:[TLAPI_messages_searchGifs createWithQ:searchString offset:0] successHandler:^(id request, TL_messages_foundGifs *response) {
//            
//            [self drawResponse:response.results];
//            
//        } errorHandler:^(id request, RpcError *error) {
//            [self drawResponse:@[]];
//            
//        }];
//    });
//    
//    
//}
//
//-(void)modalViewDidShow {
//    [super modalViewDidShow];
//    dispatch_after_seconds(0.2, ^{
//        [self.searchField becomeFirstResponder];
//    });
//    
//}
//
//-(NSSize)size {
//    int s = (self.containerSize.width - 20 - 8) / 4;
//    return NSMakeSize(s, s);
//}
//
//
//-(NSArray *)makeRow:(NSMutableArray *)gifs {
//    
//    __block BOOL first = YES;
//    
//    __block int currentWidth = 0;
//    __block int maxHeight = 100;
//    NSMutableArray *sizes = [[NSMutableArray alloc] init];
//    
//    dispatch_block_t block = ^{
//        [gifs enumerateObjectsUsingBlock:^(TL_foundGif *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            
//            TL_documentAttributeVideo *video = (TL_documentAttributeVideo *) [obj.webpage.document attributeWithClass:[TL_documentAttributeVideo class]];
//            
//            int w = MAX(video.w,obj.webpage.w);
//            int h = MAX(video.h,obj.webpage.h);
//            
//            NSSize size = convertSize(NSMakeSize(w,h), NSMakeSize(INT32_MAX, maxHeight));
//            
//            currentWidth+=size.width;
//            
//            [sizes addObject:[NSValue valueWithSize:size]];
//            
//        }];
//    };
//    
//
//    
//    
//    while (1) {
//        currentWidth = 0;
//        [sizes removeAllObjects];
//        
//        block();
//        
//        if(first) {
//            first = NO;
//            if((currentWidth - self.containerSize.width) > 100)
//                [gifs removeLastObject];
//            
//            continue;
//        }
//        
//        
//        
//        if(currentWidth < self.containerSize.width && gifs.count > 1) {
//    
//            maxHeight+=(6*gifs.count);
//            
//        } else
//            break;
//        
//    }
//    
//    
//    return sizes;
//    
//}
//
//
//-(void)drawResponse:(NSArray *)gifs {
//    [self.tableView removeAllItems:YES];
//    
//    NSMutableArray *row = [[NSMutableArray alloc] init];
//    NSMutableArray *sizes = [[NSMutableArray alloc] init];
//    
//    __block int currentWidth = 0;
//    
//    __block BOOL doneRow = NO;
//    
//    
//    NSMutableArray *draw = [gifs mutableCopy];
//    
//    dispatch_block_t next = ^{
//        NSMutableArray *r = [[draw subarrayWithRange:NSMakeRange(0, MIN(3,draw.count))] mutableCopy];
//        
//        NSArray *s = [self makeRow:r];
//        
//        [draw removeObjectsInArray:r];
//        
//
//        
//        TGGifSearchRowItem *item = [[TGGifSearchRowItem alloc] initWithObject:[r copy] sizes:[s copy]];
//        [_tableView addItem:item tableRedraw:YES];
//
//    };
//    
//    while (draw.count > 0) {
//        next();
//    }
//    
//    
//    return;
//    
//    [gifs enumerateObjectsUsingBlock:^(TL_foundGif *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        
//        
//        TL_documentAttributeVideo *video = (TL_documentAttributeVideo *) [obj.webpage.document attributeWithClass:[TL_documentAttributeVideo class]];
//        
//        int w = MAX(video.w,obj.webpage.w);
//        int h = MAX(video.h,obj.webpage.h);
//        
//        NSSize size = convertSize(NSMakeSize(w,h), NSMakeSize(INT32_MAX, 100));
//        
//        currentWidth+=size.width;
//        
//        
//        
//        if(!doneRow) {
//            [row addObject:obj];
//            [sizes addObject:[NSValue valueWithSize:size]];
//        } else  {
//            TGGifSearchRowItem *item = [[TGGifSearchRowItem alloc] initWithObject:[row copy] sizes:[sizes copy]];
//            [row removeAllObjects];
//            [sizes removeAllObjects];
//            [row addObject:obj];
//            [sizes addObject:[NSValue valueWithSize:size]];
//            [_tableView addItem:item tableRedraw:NO];
//            
//            doneRow = NO;
//            currentWidth = 0;
//        }
//        
//        doneRow = currentWidth > self.containerSize.width;
//        
//    }];
//    
//    if(row.count > 0) {
//        TGGifSearchRowItem *item = [[TGGifSearchRowItem alloc] initWithObject:row];
//        [_tableView addItem:item tableRedraw:NO];
//    }
//    
//    [_tableView reloadData];
//    
//}
//
@end
