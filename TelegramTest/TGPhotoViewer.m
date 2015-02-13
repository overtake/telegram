//
//  TGPhotoViewer.m
//  Telegram
//
//  Created by keepcoder on 10.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGPhotoViewer.h"
#import "TGPVContainer.h"
#import "TGPVControls.h"
#import "TGPVBehavior.h"
#import "TGPVMediaBehavior.h"
#import "TGPVImageView.h"
#import "TLFileLocation+Extensions.h"
#import "TGPVUserBehavior.h"
#import "TGPVEmptyBehavior.h"
#import "TGCache.h"
@interface TGPhotoViewer ()
@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,strong) TLUser *user;



@property (nonatomic,strong) TMView *background;

@property (nonatomic,strong) NSMutableArray *list;
@property (nonatomic,assign) NSInteger currentItemId;
@property (nonatomic,strong) TGPhotoViewerItem *currentItem;

@property (nonatomic,assign) BOOL isVisibility;
@property (nonatomic,strong) id <TGPVBehavior> behavior;

@property (nonatomic,assign) BOOL waitRequest;
@property (nonatomic,assign) int totalCount;

@end


@implementation TGPhotoViewer

-(void)mouseDown:(NSEvent *)theEvent {
    
}


-(void)orderOut:(id)sender {
    
     [self runAnimation:NO];
    
    [super orderOut:sender];
   
    [_photoContainer setCurrentViewerItem:nil animated:NO];
     _isVisibility = NO;
    _list = nil;
    _currentItem = nil;
    _currentItemId = 0;
    _waitRequest = NO;
    [_behavior clear];
    _behavior = nil;
    [TGCache removeAllCachedImages:@[PVCACHE]];

    [[NSApp mainWindow] makeFirstResponder:nil];
}


+(BOOL)isVisibility {
    return [self viewer].isVisibility;
}

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
    if(self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen]) {
        
       [self initialize];
    }
    
    return self;
}

static const int controlsHeight = 75;

- (void)initialize {
    
    
    [TGCache setMemoryLimit:32*1024*1024 group:PVCACHE];
    [TGCache setCountLimit:25 group:PVCACHE];

  //  [CATransaction begin];
    
    
    [(NSView *)self.contentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    self.background = [[TMView alloc] initWithFrame:[self.contentView bounds]];
    
    self.background.wantsLayer = YES;
    self.background.layer.backgroundColor = NSColorFromRGBWithAlpha(0x222222, 0.7).CGColor;
    
    
    weakify();
    
    [self.background setCallback:^ {
        
        NSEvent *currentEvent = [NSApp currentEvent];
        
        NSPoint location = [currentEvent locationInWindow];
        
        NSPoint containerPoint = strongSelf.photoContainer.frame.origin;
        
        if(location.x > containerPoint.x)
            [[TGPhotoViewer viewer] hide];
        else
            [TGPhotoViewer prevItem];
    }];
    
    [self.background setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [self.contentView addSubview:self.background];
    
    
    _photoContainer = [[TGPVContainer alloc] initWithFrame:NSMakeRect(0, 0, 300, 600)];
    

    [self.contentView addSubview:self.photoContainer];
    
    
    _controls = [[TGPVControls alloc] initWithFrame:NSMakeRect(0, 0, 400, controlsHeight)];
    
    
    [self.controls setCenterByView:self.contentView];
    
    [self.controls setFrameOrigin:NSMakePoint(NSMinX(self.controls.frame), 16)];
    
    [self.contentView addSubview:self.controls];
    
    
    [Notification addObserver:self selector:@selector(didReceivedMedia:) name:MEDIA_RECEIVE];
    [Notification addObserver:self selector:@selector(didDeleteMessages:) name:MESSAGE_DELETE_EVENT];
    [Notification addObserver:self selector:@selector(didAddedPhoto:) name:USER_UPDATE_PHOTO];
        
}


-(void)didAddedPhoto:(NSNotification *)notification {
    
    
    BOOL todelete = [notification.userInfo[KEY_PREVIOUS] boolValue];
    
    PreviewObject *previewObject = notification.userInfo[KEY_PREVIEW_OBJECT];
    
    TLUser *user = notification.userInfo[KEY_USER];
    
    
    [ASQueue dispatchOnStageQueue:^{
        
        if(todelete) {
           
            
        } else {
            
            if(self.isVisibility && self.user == user) {
                
                [self insertObjects:@[previewObject]];
                
            } else {
                TGPVUserBehavior *behavior = [[TGPVUserBehavior alloc] init];
                behavior.user = user;
                
                [behavior addItems:@[previewObject]];
            }
            
        }
        
    }];
    
}


-(void)mouseMoved:(NSEvent *)theEvent {
    
 //
    
    NSPoint point = [theEvent locationInWindow];
    
    TGPVControlHighlightType highlight;
    
    if(![self.controls hitTest:point]) {
        if([self.photoContainer hitTest:point]) {
            highlight = TGPVControlHighLightNext;
        } else if(point.x > NSMinX(self.photoContainer.frame)) {
            highlight = TGPVControlHighLightPrev;
        } else  {
            highlight = TGPVControlHighLightClose;
        }
        
        [self.controls highlightControl:highlight];
    } else {
       [self.controls mouseMoved:theEvent];
    }
    
   
    
   
}


-(void)didDeleteMessages:(NSNotification *)notification {
    
    if(!_isVisibility)
        return;
    
    [ASQueue dispatchOnStageQueue:^{
        
        NSArray *ids = notification.userInfo[KEY_MESSAGE_ID_LIST];
        
        [ids enumerateObjectsUsingBlock:^(NSNumber *msg_id, NSUInteger idx, BOOL *stop) {
            
            [_list enumerateObjectsUsingBlock:^(TGPhotoViewerItem *obj, NSUInteger idx, BOOL *stop) {
                
                if(obj.previewObject.msg_id == [msg_id intValue]) {
                    
                    [self deleteItem:obj];
                    
                    *stop = YES;
                }
                
            }];
            
        }];
        
        [self resort];
        
    }];
    
}

-(void)didReceivedMedia:(NSNotification *)notification {
    
    PreviewObject *previewObject = notification.userInfo[KEY_PREVIEW_OBJECT];
    
    if(!_isVisibility || _conversation.peer_id != previewObject.peerId)
        return;
    
    
    [ASQueue dispatchOnStageQueue:^{
        [_list addObjectsFromArray:[self.behavior convertObjects:@[previewObject]]];
        
        [self resort];
    }];
}

+(id)behavior {
    return [[self viewer] behavior];
}

+(void)deleteItem:(TGPhotoViewerItem *)item {
    [[self viewer] deleteItem:item];
}

-(void)resort {
    [ASQueue dispatchOnStageQueue:^{
        
        [_list sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"previewObject.msg_id" ascending:NO]]];
        
        _totalCount = MAX([_behavior totalCount],(int)[self listCount]);
        
        [[ASQueue mainQueue] dispatchOnQueue:^{
            self.currentItemId = [self indexOfObject:self.currentItem.previewObject];
        }];
        
    } synchronous:YES];
}


-(void)deleteItem:(TGPhotoViewerItem *)item {
    
    
    [ASQueue dispatchOnStageQueue:^{
        
        
        NSInteger index = [self indexOfObject:item.previewObject];
        
        [_list removeObject:item];
        
        if(_list.count == 0) {
            [ASQueue dispatchOnMainQueue:^{
                [self hide];
            }];
        } else {
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                
                NSInteger pos = [self indexOfObject:_currentItem.previewObject];
                
                if(pos == NSNotFound) {
                    
                    pos = MAX(index - 1, 0);
                    
//                    if(index != 0)
//                        pos--;
                    
                    if(pos >= ([self listCount] - 1)) {
                        pos = [self listCount] - 1;
                    }
                }
                
                
                
                self.currentItemId = pos;
                
            }];
        }
        
        [self.behavior removeItems:@[item.previewObject]];
        
        self.totalCount = [self.behavior totalCount];
        
    }];
}


+(TGPhotoViewerItem *)currentItem {
    return [[self viewer] currentItem];
}


+(TGPhotoViewer *)viewer {
    static TGPhotoViewer *viewer;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        viewer = [[TGPhotoViewer alloc] initWithContentRect:[NSScreen mainScreen].frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:[NSScreen mainScreen]];
        [viewer setLevel:NSScreenSaverWindowLevel];
        [viewer setOpaque:NO];
        viewer.backgroundColor = [NSColor clearColor];
    });

    return viewer;
    
}


-(NSInteger)indexOfObject:(PreviewObject *)item {
    
    __block NSInteger idx = NSNotFound;
    
    [ASQueue dispatchOnStageQueue:^{
        [self.list enumerateObjectsUsingBlock:^(TGPhotoViewerItem *obj, NSUInteger index, BOOL *stop) {
            
            if(obj.previewObject.msg_id == item.msg_id) {
                idx = index;
                *stop = YES;
            }
            
        }];
    } synchronous:YES];
    
    return idx;
}


-(TGPhotoViewerItem *)itemAtIndex:(NSUInteger)index {
    __block TGPhotoViewerItem *item;
    
    [ASQueue dispatchOnStageQueue:^{
        
        item = _list[index];
        
    } synchronous:YES];
    
    return item;
}


-(void)runAnimation:(BOOL)show {
    
    
    float prevAlpha = show ? 0.0f : 1.0f;
    float nextAlpha = show ? 1.0f : 0.0f;
    
    [self.background setAlphaValue:prevAlpha];
    [self.controls setAlphaValue:prevAlpha];
    [self.photoContainer setAlphaValue:prevAlpha];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        
        [context setDuration:0.2];
        
        [[self.background animator] setAlphaValue:nextAlpha];
        [[self.controls animator] setAlphaValue:nextAlpha];
        [[self.photoContainer animator] setAlphaValue:nextAlpha];
        
    } completionHandler:^{
        
    }];
}

-(void)show:(PreviewObject *)item conversation:(TL_conversation *)conversation {
    _conversation = conversation;
    
    
    _controls.convertsation = conversation;
    _photoContainer.conversation = conversation;
    
    
    _behavior = [[TGPVMediaBehavior alloc] init];
    [_behavior setConversation:_conversation];
    
    [ASQueue dispatchOnStageQueue:^{
        
        self.list = [[NSMutableArray alloc] init];
        [self insertObjects:@[item]];
        
    } synchronous:YES];
    
    self.currentItemId = 0;
    
    [self makeKeyAndOrderFront:self];
    
    [self mouseEntered:[NSApp currentEvent]];
    
    _waitRequest = YES;
    
    
    [self.behavior load:[[[self itemAtIndex:[self listCount]-1] previewObject] msg_id] next:NO limit:10000 callback:^(NSArray *previewObjects) {
        
        [self insertObjects:previewObjects];
        
        _waitRequest = NO;
    }];
    
}


-(void)show:(PreviewObject *)item user:(TLUser *)user {
    
    
    _behavior = [[TGPVUserBehavior alloc] init];
    [_behavior setUser:user];
    
    [ASQueue dispatchOnStageQueue:^{
        
        self.list = [[NSMutableArray alloc] init];
        [self insertObjects:@[item]];
        
    } synchronous:YES];
    
    self.currentItemId = 0;
    
    [self makeKeyAndOrderFront:self];
    
}

-(void)show:(PreviewObject *)item {
    
    _behavior = [[TGPVEmptyBehavior alloc] init];
    
    [ASQueue dispatchOnStageQueue:^{
        
        self.list = [[NSMutableArray alloc] init];
        [self insertObjects:@[item]];
        
    } synchronous:YES];
    
    self.currentItemId = 0;
    
    [self makeKeyAndOrderFront:self];
}

-(void)makeKeyAndOrderFront:(id)sender {
    
     [self runAnimation:YES];
    
    [self setFrame:[NSScreen mainScreen].frame display:NO];
    
    [super makeKeyAndOrderFront:nil];
    
    
    [[NSApp mainWindow] makeFirstResponder:self.photoContainer];
    

    _isVisibility = YES;
    [self.controls update];
}



-(NSUInteger)listCount {
    
    __block NSUInteger count;
    
    [ASQueue dispatchOnStageQueue:^{
        
        count = self.list.count;
        
    } synchronous:YES];
    
    return count;
}


-(void)nextItem {
    
    if([self.behavior isReversedContentView]) {
        
        [self performPrevItem];
        
        return;
        
    }
    
    [self performNextItem];
    

}

-(void)prevItem {
    
    
    if([self.behavior isReversedContentView]) {
        
        [self performNextItem];
        
        return;
        
    }
    
    [self performPrevItem];

}

-(void)performNextItem {
    NSUInteger count = [self listCount];
    
    if(count > 0) {
        if(self.currentItemId < (count - 1)) {
            [self setCurrentItemId:[self currentItemId]+1];
        }
    }
}

-(void)performPrevItem {
    NSUInteger count = [self listCount];
    
    if(count > 0 && self.currentItemId != 0) {
        [self setCurrentItemId:[self currentItemId]-1];
    }

}

+(void)prevItem {
    [[self viewer] prevItem];
}

+(void)nextItem {
    [[self viewer] nextItem];
}

-(void)setCurrentItemId:(NSInteger)currentItemId {
    
    if(currentItemId == NSNotFound)
        return;
    
    _currentItemId = currentItemId;
    
    _currentItem = [self itemAtIndex:currentItemId];
    
    
    

    [self.controls setCurrentPosition:[self.behavior isReversedContentView] ? _totalCount - _currentItemId : _currentItemId+1 ofCount:_totalCount];
    
    [[self photoContainer] setCurrentViewerItem:_currentItem animated:NO];
    
    
    if( (_currentItemId + 15 ) >= [self listCount] && !_waitRequest) {
        
        _waitRequest = YES;
        
        
        [self.behavior load:[[[self itemAtIndex:[self listCount]-1] previewObject] msg_id] next:YES limit:100 callback:^(NSArray *previewObjects) {
            
            [self insertObjects:previewObjects];
            
            _waitRequest = NO;
        }];
        
    }
    
    [ASQueue dispatchOnStageQueue:^{
        
       
        NSInteger max = MIN(_currentItemId + 5, [self listCount]-1);
        
        NSInteger min = MAX(_currentItemId - 5, 0);
        
        NSRange range = NSMakeRange(MIN(min, max), abs((int)(max - min)));
        
        
        [_list enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:NSEnumerationReverse usingBlock:^(TGPhotoViewerItem *obj, NSUInteger idx, BOOL *stop) {
            
            if(![TGCache cachedImage:obj.imageObject.location.cacheKey group:@[PVCACHE]]) {
                 [obj.imageObject initDownloadItem];
            }
            
        }];
        
    }];
}

-(void)insertObjects:(NSArray *)previewObjects {
    
    [ASQueue dispatchOnStageQueue:^{
        [self.list addObjectsFromArray:[self.behavior convertObjects:previewObjects]];
                
        [self resort];
    }];
}


-(void)prepareUser:(TLUser *)user {
    TGPVUserBehavior *behavior = [[TGPVUserBehavior alloc] init];
    [behavior setUser:user];
    [behavior load:0 next:YES limit:0 callback:nil];
}



-(void)hide {
    [self orderOut:self];
}


@end
