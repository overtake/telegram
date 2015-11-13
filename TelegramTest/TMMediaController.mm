//
//  TMPreviewController.m
//  Messenger for Telegram
//
//  Created by keepcoder on 11.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMMediaController.h"
#import "FileUtils.h"
#import "TLFileLocation+Extensions.h"
#import "ImageCache.h"
#import "TLPeer+Extensions.h"
#import "TMPreviewDocumentItem.h"
#include <map>
#include <set>
#import "TMPreviewItem.h"
#import "TMPreviewVideoItem.h"
#import "TMPreviewAudioItem.h"
#import "TMPreviewUserPicture.h"
#import "HackUtils.h"
#import "MessageTableItem.h"
#import "MessageTableCellPhotoView.h"
#import "MessageTableCellVideoView.h"
#import "MessageTableCellDocumentView.h"
#import "ImageUtils.h"
#import "TMPreviewCollectionPhotoItem.h"
#import "TMMediaUserPictureController.h"


@interface QLPreviewPanel (BugFix)
@end

@implementation QLPreviewPanel (BugFix)

//DYNAMIC_PROPERTY(NeedClose);
//
//- (void)close {
//    if([[self getNeedClose] boolValue]) {
//        [super close];
//}
//
//-(void)setNeedToClose:(BOOL)needClose {
//    [self setNeedClose:@(needClose)];
//}

@end

@interface TMSavePanel : NSSavePanel
@end

@implementation TMSavePanel

+ (TMSavePanel *)sharedInstance {
    static TMSavePanel *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TMSavePanel alloc] init];
    });
    return instance;
}

- (void)sendEvent:(NSEvent *)theEvent {
    if(theEvent.type == 10 && theEvent.keyCode == 53) {
        [self cancel:nil];
    } else {
        [super sendEvent:theEvent];
    }
}

-(void)_reactToPanelDismissalWithReturnCode:(id)object {
    
}


@end


@interface TMNextImageView : TMView
@property (nonatomic, strong) TMView *previewView;
@property (nonatomic, strong) NSButton *nextButton;
@end

@implementation TMNextImageView

#define kSwipeMinimumLength 0.1


- (void)mouseDown:(NSEvent *)theEvent {
    
    if(theEvent.clickCount == 1 && [self isPreviewViewInEvent:theEvent]) {
       [[TMMediaController getCurrentController] nextItem];
    } else {
        [super mouseDown:theEvent];
    }
    
}

static NSMutableDictionary *twoFingersTouches;

//- (void)beginGestureWithEvent:(NSEvent *)event
//{
//    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
//    
//    twoFingersTouches = [[NSMutableDictionary alloc] init];
//    
//    for (NSTouch *touch in touches) {
//        [twoFingersTouches setObject:touch forKey:touch.identity];
//    }
//}
//
//- (void)endGestureWithEvent:(NSEvent *)event
//{
//    if (!twoFingersTouches)
//        return;
//    
//    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
//    
//    // release twoFingersTouches early
//    NSMutableDictionary *beginTouches = [twoFingersTouches copy];
//    twoFingersTouches = nil;
//    
//    NSMutableArray *magnitudes = [[NSMutableArray alloc] init];
//    
//    for (NSTouch *touch in touches)
//    {
//        NSTouch *beginTouch = [beginTouches objectForKey:touch.identity];
//        
//        if (!beginTouch)
//            continue;
//        
//        float magnitude = touch.normalizedPosition.x - beginTouch.normalizedPosition.x;
//        [magnitudes addObject:[NSNumber numberWithFloat:magnitude]];
//    }
//    
//    // Need at least two points
//    if ([magnitudes count] < 2)
//        return;
//    
//    float sum = 0;
//    
//    for (NSNumber *magnitude in magnitudes)
//        sum += [magnitude floatValue];
//    
//    // Handle natural direction in Lion
//    BOOL naturalDirectionEnabled = [[[NSUserDefaults standardUserDefaults] valueForKey:@"com.apple.swipescrolldirection"] boolValue];
//    
//    if (naturalDirectionEnabled)
//        sum *= -1;
//    
//    // See if absolute sum is long enough to be considered a complete gesture
//    float absoluteSum = fabsf(sum);
//    
//    if (absoluteSum < kSwipeMinimumLength) return;
//    
//    // Handle the actual swipe
//    if (sum > 0)
//    {
//        [self backSwipe];
//    } else
//    {
//        [self nextSwipe];
//    }
//}

//- (void)nextSwipe {
//    [[TMMediaController getCurrentController].panel performSelector:@selector(selectNextItem) withObject:nil];
//}
//
//- (void)backSwipe {
//    [[TMMediaController getCurrentController].panel performSelector:@selector(selectPreviousItem) withObject:nil];
//}


+(NSMenuItem *)rightMenuForItem:(id<TMPreviewItem>)item {
    
}


- (void)rightMouseDown:(NSEvent *)theEvent {
    [super rightMouseDown:theEvent];
    
    if([self isPreviewViewInEvent:theEvent]) {
        NSMenu *menu = [[NSMenu alloc] init];
        
        TMMediaController *controller = [TMMediaController getCurrentController];
        
        NSMenuItem *nextItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"MediaPreview.NextItem", nil) withBlock:^(id sender) {
            [controller nextItem];
        }];
        
        unichar c = NSRightArrowFunctionKey;
        [nextItem setKeyEquivalent:[NSString stringWithCharacters:&c length:1]];
        [nextItem setKeyEquivalentModifierMask:0];
        
        if(controller.count < 2) {
            [nextItem setAction:NULL];
        }
        [menu addItem:nextItem];
        
        NSMenuItem *previousItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"MediaPreview.PreviousItem", nil) withBlock:^(id sender) {
            [controller.panel performSelector:@selector(selectPreviousItem) withObject:nil];
        }];
        c = NSLeftArrowFunctionKey;
        [previousItem setKeyEquivalent:[NSString stringWithCharacters:&c length:1]];
        [previousItem setKeyEquivalentModifierMask:0];
        if(controller.count < 2) {
            [previousItem setAction:NULL];
        }
        [menu addItem:previousItem];
        
        
        [menu addItem:[NSMenuItem separatorItem]];
   
        
        NSMenuItem *saveMenuItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"MediaPreview.SaveItem", nil) withBlock:^(id sender) {
            [controller performSelector:@selector(performSave) withObject:nil];
        }];
        [saveMenuItem setKeyEquivalent:@"s"];
        [saveMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
        [menu addItem:saveMenuItem];
        

        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"MediaPreview.SaveToDownloads", nil) withBlock:^(id sender) {
            [controller performSelector:@selector(performSaveToDownloads) withObject:nil];
        }]];
        
        [menu addItem:[NSMenuItem separatorItem]];
        NSMenuItem *copyToClipboardItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.CopyToClipboard", nil) withBlock:^(id sender) {
            [controller performSelector:@selector(copy:) withObject:nil];
        }];
        
        [copyToClipboardItem setKeyEquivalent:@"c"];
        [copyToClipboardItem setKeyEquivalentModifierMask:NSCommandKeyMask];
        
        if(![controller.currentItem isKindOfClass:[TMPreviewPhotoItem class]] && ![controller.currentItem isKindOfClass:[TMPreviewUserPicture class]]) {
            
            if([controller.currentItem isKindOfClass:[TMPreviewDocumentItem class]]) {
                TMPreviewDocumentItem *item = (TMPreviewDocumentItem *)controller.currentItem;
                if(![item.document.mime_type hasPrefix:@"image/"]) {
                    [copyToClipboardItem setAction:NULL];
                }
            } else {
                [copyToClipboardItem setAction:NULL];
            }
            
        }
        [menu addItem:copyToClipboardItem];
        
        if(controller.class == TMMediaController.class) {
            [menu addItem:[NSMenuItem separatorItem]];
//            [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"MediaPreview.Forward", nil) withBlock:^(id sender) {
//               // [controller.panel performSelector:@selector(selectPreviousItem) withObject:nil];
//                
//                id<TMPreviewItem> previewItem = controller.currentItem;
//                
//                TL_localMessage *msg = previewItem.previewObject.media;
//                
//                
//                
//                [[Telegram rightViewController] showByDialog:msg.conversation sender:controller];
//                [[Telegram rightViewController].messagesViewController setState:MessagesViewControllerStateNone];
//                [[Telegram rightViewController].messagesViewController unSelectAll:NO];
//                
//                MessageTableItem *item  = [MessageTableItem messageItemFromObject:previewItem.previewObject.media];
//                
//                [[Telegram rightViewController].messagesViewController setSelectedMessage:item selected:YES];
//                
//                
//                [[Telegram rightViewController] showForwardMessagesModalView:[Telegram rightViewController].messagesViewController.conversation messagesCount:1];
//                
//                [[TMMediaController controller] close];
//                
//                
//            }]];
//            [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"MediaPreview.Delete", nil) withBlock:^(id sender) {
//                id<TMPreviewItem> previewItem = controller.currentItem;
//                
//                TL_localMessage *msg = previewItem.previewObject.media;
//                
//                [[Telegram rightViewController] showByDialog:msg.conversation sender:controller];
//                
//                [[Telegram rightViewController].messagesViewController setState:MessagesViewControllerStateNone];
//                [[Telegram rightViewController].messagesViewController unSelectAll:NO];
//                
//                MessageTableItem *item  = [MessageTableItem messageItemFromObject:previewItem.previewObject.media];
//                [[Telegram rightViewController].messagesViewController setSelectedMessage:item selected:YES];
//                
//                [[Telegram rightViewController].messagesViewController deleteSelectedMessages];
//                
//                [[TMMediaController controller] deleteItem:previewItem];
//                
//            }]];
//            
//            [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"MediaPreview.GoToMessage", nil) withBlock:^(id sender) {
//                id<TMPreviewItem> previewItem = controller.currentItem;
//                
//                TL_localMessage *msg = previewItem.previewObject.media;
//                
//                [[Telegram rightViewController] showByDialog:msg.conversation withJump:msg.n_id historyFilter:[HistoryFilter class] sender:controller];
//            
//            }]];
            
        }
        
        
        
        [NSMenu popUpContextMenu:menu withEvent:theEvent forView:self.previewView];
        
    }
}

- (TMView *)previewView {
    if(self->_previewView)
        return self->_previewView;
    
    NSArray *buttons = [HackUtils findElementsByClass:@"QLControlButton" inView:[TMMediaController getCurrentController].panel.contentView];
    
    [buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *identifier = [obj performSelector:@selector(controlIdentifier) withObject:nil withObject:nil];
        if([identifier isEqualToString:@"previous-item"] || [identifier isEqualToString:@"next-item"]) {
            
            TMButton *view = [[TMButton alloc] initWithFrame:[obj bounds]];
            [view setWantsLayer:YES];
            [view.layer setOpacity:0];
            [obj addSubview:view];
            SEL selector = [identifier isEqualToString:@"next-item"] ? @selector(nextItemCheck) : @selector(prevItemCheck);
            [view setTarget:[TMMediaController controller] selector:selector];
        }
    }];
    
    NSArray *array = [HackUtils findElementsByClass:@"QLOverlayBorderView" inView:[TMMediaController getCurrentController].panel.contentView];
    if(array.count > 0) {
      
        NSView *panelPreviewView = [array objectAtIndex:0];
        self.previewView = [[TMView alloc] initWithFrame:panelPreviewView.bounds];
        [self.previewView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [panelPreviewView addSubview:self.previewView];
    }
    return self->_previewView;
}

- (BOOL)isPreviewViewInEvent:(NSEvent *)theEvent {
    if(!self.previewView)
        return NO;
    
    if(![self.previewView visibleRect].size.width)
        return NO;
    
    NSPoint point = [self.previewView convertPoint:theEvent.locationInWindow fromView:self];
    return point.x > 0 && point.y > 0 && point.x < self.previewView.bounds.size.width && point.y < self.previewView.bounds.size.height - 20;
}

@end

@interface TMMediaController ()

@property (nonatomic) std::map<NSUInteger, bool> *listCacheHash;
@property (nonatomic,strong,readonly) NSMutableDictionary *cachedMedia;
@property (nonatomic,strong) NSMutableDictionary *itsFull;
@property (nonatomic,strong,readonly) TL_conversation *dialog;
@property (nonatomic, strong) TMNextImageView *nextImageView;
@property (nonatomic,strong) RPCRequest *request;

@end



@implementation TMMediaController
@synthesize dialog = _dialog;
@synthesize currentItemPosition = _currentItemPosition;
@synthesize listCacheHash = _listCacheHash;

static TMMediaController* currentController;

-(id)init {
    if(self = [super init]) {
        _panel = [QLPreviewPanel sharedPreviewPanel];
        
        self->items = [[NSMutableArray alloc] init];
        _cachedMedia = [[NSMutableDictionary alloc] init];
        self.itsFull = [[NSMutableDictionary alloc] init];
        
        static TMNextImageView *nextImageView;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSView *contentView = self.panel.contentView;
            nextImageView = [[TMNextImageView alloc] initWithFrame:contentView.bounds];
            [nextImageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
            [contentView addSubview:nextImageView];
        });
        
        self.nextImageView = nextImageView;
    }
    return self;
}



- (NSUInteger)count {
    return items.count;
}

-(void)showInFinder:(id)sender {
    id<TMPreviewItem> item = self->items[_panel.currentPreviewItemIndex];
    if([item previewItemURL]) {
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[item.url]];
    }
}

- (void)deleteItem:(id<TMPreviewItem>)item  {
    
    NSUInteger index = [self->items indexOfObject:item];
    
    if(index != NSNotFound) {
        if(self->items.count > 1)
            [self nextItem];
        else
            [self close];
        [self->items removeObject:item];
    }
    
  //   [[Telegram rightViewController].collectionViewController didDeleteMediaItem:item];
    
}

-(void)didAddMedia:(NSNotification *)notification {
    
    
    PreviewObject *object = [notification.userInfo objectForKey:KEY_PREVIEW_OBJECT];
    
    id <TMPreviewItem> item = [self convert:object];
    if(!item)
        return;
    
    
    
    if(_dialog.peer.peer_id == object.peerId) {
        if(![self isExist:item in:self->items]) {
            [self->items insertObject:item atIndex:0];
            NSInteger currentIndex = _panel.currentPreviewItemIndex+1; // this is bad O_o
            [self reloadData:currentIndex];
        }
    } else {
        NSMutableArray *list = [self media:object.peerId];
        if(![self isExist:item in:list])
            [list insertObject:item atIndex:0];
    }
    
  //  [[Telegram rightViewController].collectionViewController didAddMediaItem:item];
}

-(NSMutableArray *)media:(int)hash {
    NSMutableArray *media = [_cachedMedia objectForKey:@(hash)];
    if(!media) {
        media = [[NSMutableArray alloc] init];
        [_cachedMedia setObject:media forKey:@(hash)];
    }
    
    return media;
}

-(void)saveItem:(id<TMPreviewItem>)item {
    //need save media, or no :)
    
    
}

-(void)dealloc {
    [Notification removeObserver:self];
    if(_listCacheHash)
        _listCacheHash->clear();
}

+(void)setCurrentController:(TMMediaController *)controller {
    currentController = controller;
}

+(TMMediaController *)getCurrentController {
    return currentController;
}


-(void)nextItemCheck
{
    [[TMMediaController getCurrentController] nextItem];
}

-(void)prevItemCheck
{
    [[TMMediaController getCurrentController] prevItem];
}

-(void)nextItem {
    MTLog(@"nextItem");
    if(self->items.count > 0) {
        NSUInteger index = [self->items indexOfObject:[self currentItem]];
        
        if(index != NSNotFound) {
            if(index == self->items.count-1) {
              //  if([self remoteLoad:self.dialog completionHandler:nil])
                //    return;
              //  else
                    index = 0;
                
            } else
                ++index;
        }
        
        self->_panel.currentPreviewItemIndex = index;
    }
}

-(void)prevItem {
    MTLog(@"prevItem");
    if(self->items.count > 0) {
        NSUInteger index = [self->items indexOfObject:[self currentItem]];
        
        if(index != NSNotFound) {
            if(index == 0) {
                index = self->items.count-1;
            } else
                --index;
        }
        
        self->_panel.currentPreviewItemIndex = index;
    }
}

- (void)performSave {
    [self save:nil];
}
-(BOOL)isOpened {
    return [QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible];
}

-(void)close {
    if([self isOpened]) {
        //[_panel setNeedToClose:YES];
        [_panel orderOut:nil];
        //[_panel setNeedToClose:NO];
    }
    
}


- (BOOL)remoteLoad:(TL_conversation *)conversation completionHandler:(void (^)(NSArray *))completionHandler {
    
//    
//    if(self.request || self.itsFull[@(conversation.peer.peer_id)] != nil)
//        return NO;
//    
//    id <TMPreviewItem> lastItem = [items lastObject];
//
//    int max_id = [lastItem previewObject].msg_id;
//    
//    self.request = [RPCRequest sendRequest:[TLAPI_messages_search createWithPeer:self.dialog.inputPeer q:@"" filter:[TL_inputMessagesFilterPhotos create] min_date:0 max_date:0 offset:0 max_id:max_id limit:100] successHandler:^(RPCRequest *request, id response) {
//        
//        NSMutableArray *messages = [response messages];
//        
//        [TL_localMessage convertReceivedMessages:messages];
//        
//        NSMutableArray *cache = [self media:conversation.peer.peer_id];
//        
//        
//        NSMutableArray *added = [[NSMutableArray alloc] init];
//        
//        [messages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
//            
//            PreviewObject *preview = [[PreviewObject alloc] initWithMsdId:obj.n_id media:obj peer_id:obj.peer_id];
//            
//            id<TMPreviewItem> item = [self convert:preview];
//            
//            if(item) {
//                [[Storage manager] insertMedia:obj];
//                [cache addObject:item];
//                [added addObject:item];
//            }
//            
//        }];
//        
//        if(messages.count == 0) {
//            self.itsFull[@(conversation.peer.peer_id)] = @(YES);
//        }
//        
//        self.request = nil;
//        
//        if([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible])  {
//            [_panel reloadData];
//            
//            [self nextItem];
//        }
//        
//        if(completionHandler)
//            completionHandler(added);
//        
//    } errorHandler:^(RPCRequest *request, RpcError *error) {
//        
//        self.request = nil;
//        
//     //   [self remoteLoad:conversation];
//        
//    } timeout:10];
//    
    return YES;
}

-(void)prepare:(TL_conversation *)object  completionHandler:(dispatch_block_t)completionHandler {
    
    _dialog = object;
    
    if(_dialog && ![self initialized:_dialog.peer.peer_id]) {
        [[Storage manager] media:^(NSArray *list) {
            
            NSMutableArray *media = [self media:_dialog.peer.peer_id];
            [media removeAllObjects];
            for (int i = 0; i < list.count; i++) {
                id<TMPreviewItem> item = [self convert:list[i]];
                
                if(!item) continue;
                [media addObject:item];
                
            }
            self->items = media;
            _listCacheHash->insert(std::pair<NSUInteger, bool>(_dialog.peer.peer_id, true));
            
            if(completionHandler) completionHandler();
            
        } max_id:0 filterMask:HistoryFilterPhoto peer:_dialog.peer next:YES limit:10000];
    } else if(_dialog) {
        self->items = [self media:_dialog.peer.peer_id];
        if(completionHandler) completionHandler();
    }
}

- (bool) initialized:(NSUInteger)peer_id {
    std::map<NSUInteger, bool>::iterator it = _listCacheHash->find(peer_id);
    if(it != self.listCacheHash->end())
        return it->second;
    return false;
}

- (void)show:(id<TMPreviewItem>)showItem {
    [TMMediaController setCurrentController:self];
    _currentItemPosition = 0;
    [[NSApp mainWindow] makeFirstResponder:nil];
    [_panel updateController];
    
    if(showItem) {
        int i = 0;
        BOOL toadd = YES;
        NSArray *each = [self->items copy];
        
        for (id<TMPreviewItem> item in each ) {
            if([item isEqualToItem:showItem]) {
                _currentItemPosition = i;
                [self->items removeObject:item];
                toadd = NO;
                break;
            }
            ++i;
        }
        
        [self->items insertObject:showItem atIndex:_currentItemPosition];
        
        if(toadd) {
            [self saveItem:showItem];
        }
    }
    
    if(self->items.count > 0) {
        if([self isOpened]) {
            _panel.delegate = self;
            _panel.dataSource = self;
            [self reloadData:_currentItemPosition];
        }
        
        else {
         
            [_panel makeKeyAndOrderFront:self];
           


        }
        
    } else {
        [_panel orderOut:nil];
    }
}

-(id<TMPreviewItem>)convert:(PreviewObject *)from {
    
    id<TMPreviewItem> item;
    
    if([[(TL_localMessage *)from.media media] isKindOfClass:[TL_messageMediaDocument class]]) {
        item = [[TMPreviewDocumentItem alloc] initWithItem:from];
    }
    
    if([[(TL_localMessage *)from.media media] isKindOfClass:[TL_messageMediaPhoto class]]) {
        item = [[TMPreviewPhotoItem alloc] initWithItem:from];
    }
    
    if([[(TL_localMessage *)from.media media] isKindOfClass:[TL_messageMediaVideo class]]) {
        item = [[TMPreviewVideoItem alloc] initWithItem:from];
    }
    
    if([[(TL_localMessage *)from.media media] isKindOfClass:[TL_messageMediaAudio class]]) {
        item = [[TMPreviewAudioItem alloc] initWithItem:from];
    }

    return item;
}

-(BOOL)isExist:(id<TMPreviewItem>)item in:(NSArray *)list {
    for (id<TMPreviewItem>current in list) {
        if([current isEqualToItem:item])
        {
            return YES;
        }
    }
    return NO;
}

-(id<TMPreviewItem>)currentItem {
    return (id <TMPreviewItem>) _panel.currentPreviewItem;
}



- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index {
    return self->items[index];
}

+(TMMediaController *)controller {
    static TMMediaController *controller;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[TMMediaController alloc] init];
        
        controller.listCacheHash = new std::map<NSUInteger, bool>();
      //  [Notification addObserver:controller selector:@selector(didAddMedia:) name:MEDIA_RECEIVE];
        
    });
    
    return controller;
}

-(BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event {
    return YES;
}

-(id)previewPanel:(QLPreviewPanel *)panel transitionImageForPreviewItem:(id<TMPreviewItem>)item contentRect:(NSRect *)contentRect {
    
    
    if([item previewObject].reservedObject) {
        
        NSImageView *imageView = [item previewObject].reservedObject;
        return imageView.image;
    }
    
    MessagesViewController *controller = [Telegram rightViewController].messagesViewController;
    MessageTableItem *messageItem = [controller itemOfMsgId:item.previewObject.msg_id];
    
    NSInteger row = [controller indexOfObject:messageItem];
    NSView *cellView = nil;
    
    @try {
        cellView = [controller.table viewAtColumn:0 row:row makeIfNecessary:NO];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    NSImage *previewView = nil;
    if(cellView) {
        if([cellView isKindOfClass:[MessageTableCellPhotoView class]]) {
            MessageTableCellPhotoView *photoView = (MessageTableCellPhotoView *)cellView;
            previewView = photoView.imageView.image;
        } else if([cellView isKindOfClass:[MessageTableCellVideoView class]]) {
            MessageTableCellVideoView *videoView = (MessageTableCellVideoView *)cellView;
            previewView = videoView.imageView.image;
        } else if([cellView isKindOfClass:[MessageTableCellDocumentView class]]) {
            MessageTableCellDocumentView *documentView = (MessageTableCellDocumentView *)cellView;
            previewView = documentView.thumbView.image;
        }
    }

    
    
    return previewView;
}

- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <TMPreviewItem>)item {
    
    
    if([item previewObject].reservedObject) {
        NSImageView * reserved = [item previewObject].reservedObject;
        
        if(!reserved || reserved.visibleRect.size.height <= 0)
            return NSZeroRect;
        
        NSRect viewFrameInWindowCoords = [reserved convertRect:reserved.bounds toView:nil];
        return [[NSApp mainWindow] convertRectToScreen:viewFrameInWindowCoords];
    }
    
    MessagesViewController *controller = [Telegram rightViewController].messagesViewController;
    MessageTableItem *messageItem = [controller itemOfMsgId:item.previewObject.msg_id];
    
    NSInteger row = [controller indexOfObject:messageItem];
    NSView *cellView = nil;

    @try {
        cellView = [controller.table viewAtColumn:0 row:row makeIfNecessary:NO];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    NSView *previewView = nil;
    if(cellView) {
        if([cellView isKindOfClass:[MessageTableCellPhotoView class]]) {
            MessageTableCellPhotoView *photoView = (MessageTableCellPhotoView *)cellView;
            previewView = photoView.imageView;
        } else if([cellView isKindOfClass:[MessageTableCellVideoView class]]) {
            MessageTableCellVideoView *videoView = (MessageTableCellVideoView *)cellView;
            previewView = videoView.imageView;
        } else if([cellView isKindOfClass:[MessageTableCellDocumentView class]]) {
            MessageTableCellDocumentView *documentView = (MessageTableCellDocumentView *)cellView;
            previewView = documentView.thumbView;
        }
    }
    
    if(previewView && previewView.visibleRect.size.height > 0) {
        NSRect viewFrameInWindowCoords = [previewView convertRect:previewView.bounds toView:nil];
        return [controller.table.window convertRectToScreen:viewFrameInWindowCoords];
    }
    
    return NSZeroRect;
    
//    MTLog(@"log");
    
//    return viewFrameInWindowCoords;
//    float documentOffset = controller.table.scrollView.documentOffset.y;
//    NSRect tableRect = controller.table.scrollView.frame;
//    
//    
//    float offset = documentOffset-iconRect.origin.y + ( tableRect.size.height - iconRect.size.height ) +  (messageItem.isForwadedMessage ? 10 : 28 );
//    
//    
//    if((offset + iconRect.size.height/2) < 0 || offset > (tableRect.size.height + iconRect.size.height)) {
//        return NSZeroRect;
//    }
//    
//    iconRect.origin.y = offset;
//    iconRect.origin.x = 358;
//    
//    
//    
//    iconRect = [controller.table.window convertRectToScreen:iconRect];
//    return iconRect;
}



- (IBAction)copy:(id)sender {
    if(![self.nextImageView.previewView visibleRect].size.width)
        return;
    
    if(self.currentItem) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        [pasteboard writeObjects:[NSArray arrayWithObject:self.currentItem.url]];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if(![self.nextImageView.previewView visibleRect].size.width)
        return NO;
    
    if(menuItem.action == @selector(paste:))
        return NO;
    
    if(menuItem.action == @selector(selectAll:))
        return NO;
    
    return YES;
}

- (IBAction)paste:(id)sender {
}

- (IBAction)selectAll:(id)sender {
}

- (IBAction)save:(id)sender {
    if(![self.nextImageView.previewView visibleRect].size.width)
        return;
    
    if(self.currentItem) {
        TMSavePanel *panel = [[TMSavePanel alloc] init];
        __block id<TMPreviewItem> item = (id<TMPreviewItem>) _panel.currentPreviewItem;
        
        NSString *fileName = item.fileName;
        
        [panel setNameFieldStringValue:fileName];
        [panel beginSheetModalForWindow:_panel completionHandler:^(NSInteger result){
            if (result == NSFileHandlingPanelOKButton) {
                NSURL *file = [panel URL];
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:item.url.path] ) {
//                    MTLog(@"file %@", file);
                    [[NSFileManager defaultManager] copyItemAtURL:item.url toURL:file error:nil];
                }
            } else if(result == NSFileHandlingPanelCancelButton) {
                
            }
        }];
    }
}

- (void)performSaveToDownloads {
    if(self.currentItem) {
        NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES)[0];
        
        NSString *filePath = [NSString stringWithFormat:@"file://localhost%@/%@", applicationSupportPath, self.currentItem.fileName];
        
        if ( [[NSFileManager defaultManager] isReadableFileAtPath:self.currentItem.url.path] ) {
            NSError *error;
            [[NSFileManager defaultManager] copyItemAtURL:self.currentItem.url toURL:[[NSURL alloc] initWithString:filePath] error:&error];
        }
    }
}


-(void)reloadData:(NSInteger)currentIndex {
    if([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible])  {
        if(self->items.count > 0) {
            if(self->items.count-1 < currentIndex)
                currentIndex = self->items.count-1;
            
            [_panel setCurrentPreviewItemIndex:currentIndex];
        } else {
            [self close];
        }
    }
}


-(void)refreshCurrentPreviewItem {
    [_panel refreshCurrentPreviewItem];
}

-(void)addItem:(NSString *)path {
    [self->items addObject:[[TMPreviewPhotoItem alloc] initWithPath:path]];
}

-(void)removeAllObjects {
    [self->items removeAllObjects];
    _currentItemPosition = 0;
}



- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel  {
    return self->items.count;
    
}

@end
