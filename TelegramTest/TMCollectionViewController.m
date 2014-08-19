//
//  TMCollectionViewController.m
//  Messenger for Telegram
//
//  Created by keepcoder on 08.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMCollectionViewController.h"
#import "MediaCollectionItem.h"
#import "TMPreviewPhotoItem.h"
#import "MediaCollectionItemView.h"
#import "TGMessage+Extensions.h"
@implementation TMCollectionView

- (NSCollectionViewItem *)newItemForRepresentedObject:(MediaCollectionItem *)object {
    NSCollectionViewItem *item = [object item];
    if (item == nil) {
      
        item = [super newItemForRepresentedObject:object];
     //   [object setItem:item];
       
    }
    
    [(MediaCollectionItemView *)item.view setItem:object];
    
    return item;
}




@end

@implementation CollectionScrollView

-(void)scrollWheel:(NSEvent *)theEvent {
    
    [super scrollWheel:theEvent];
    
//    if (theEvent.phase==NSEventPhaseMayBegin) {
//       
//        [super scrollWheel:theEvent];
//        [[self nextResponder] scrollWheel:theEvent];
//        return;
//  
//    }
//    
//    if (theEvent.phase == NSEventPhaseBegan || (theEvent.phase==NSEventPhaseNone && theEvent.momentumPhase==NSEventPhaseNone)) {
//        currentScrollIsHorizontal = fabs(theEvent.scrollingDeltaX) > fabs(theEvent.scrollingDeltaY);
//    }
//    
//    if ( currentScrollIsHorizontal ) {
//        [super scrollWheel:theEvent];
//    } else {
//        NSPoint scrollPoint = [[self contentView] bounds].origin;
//        scrollPoint.x += rintf([theEvent deltaY]);
//       [[self documentView] scrollPoint: scrollPoint];
//        
//        if(scrollPoint.x == 0 || scrollPoint.x < 0  || (scrollPoint.x + self.frame.size.width)  > [[self documentView] frame].size.width) {
//            [[self nextResponder] scrollWheel:theEvent];
//        }
//        
//    }
//    
//    if(self.isNeedUpdateRight) {
//        
//    }

}





@end

@interface TMCollectionViewController ()

@property (nonatomic,assign,getter = isLocked) BOOL locked;
@property (nonatomic,assign) BOOL loaded;
@property (nonatomic,strong) NSMutableArray *cachedItems;
@property (nonatomic,weak) TL_conversation *conversation;

@end

@implementation TMCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        id clipView = [[(CollectionScrollView *)self.view enclosingScrollView] contentView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                     name:NSViewBoundsDidChangeNotification
                                                   object:clipView];
    }
    return self;
}

- (void) scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)aNotification {
   
    CollectionScrollView *scrollView = (CollectionScrollView *)self.view;
                                        
    if(!_locked && !_loaded && (scrollView.documentOffset.y + scrollView.contentView.frame.size.height)  > scrollView.documentSize.height) {
        [self cacheLoad];
    }
}

-(void)awakeFromNib {
    _data = [[NSMutableArray alloc] init];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cache = [[NSMutableDictionary alloc] init];
    });
    
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

static NSMutableDictionary *_cache;


-(void)setItems:(NSArray *)items conversation:(TL_conversation *)conversation {
    
    _conversation = conversation;
    
    NSRange range = NSMakeRange(0, [[arrayController arrangedObjects] count]);
    [arrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
 
    _cachedItems = [items mutableCopy];
    
    _loaded = NO;
    _locked = NO;
     [self cacheLoad];
    
    
}

- (void)cacheLoad {
    
    NSMutableArray *toadd = [[NSMutableArray alloc] init];
    NSArray *items = [_cachedItems copy];
    
    int limit = 0;
    _locked = YES;
    
    for (id<TMPreviewItem> item in items) {
        if([item isKindOfClass:[TMPreviewPhotoItem class]]) {
            PreviewObject *previewObject = [item previewObject];
            
            MediaCollectionItem *mediaItem = [_cache objectForKey:@(previewObject.msg_id)];
            if(!mediaItem) {
                mediaItem = [[MediaCollectionItem alloc] initWithPreviewObject:previewObject];
                [_cache setObject:mediaItem forKey:@(previewObject.msg_id)];
            }
            mediaItem.collectionView = self.collectionController;
            if(mediaItem) {
                [toadd addObject:mediaItem];
            }
            
            [_cachedItems removeObject:item];
            
            if(limit++ == 100) {
                break;
            }
            
        }
    }
    
    
    
    [arrayController addObjects:toadd];
    _locked = NO;
    if(limit < 70) {
        [self remoteLoad];
    }

}



- (void)remoteLoad {
    _locked = YES;
    MediaCollectionItem *lastItem = [_data lastObject];
    
    int max_id = [lastItem previewObject].msg_id;
    
    
    
    [RPCRequest sendRequest:[TLAPI_messages_search createWithPeer:_conversation.inputPeer q:@"" filter:[TL_inputMessagesFilterPhotos create] min_date:0 max_date:0 offset:0 max_id:max_id limit:100] successHandler:^(RPCRequest *request, id response) {
        
        
        
        
        [ASQueue dispatchOnStageQueue:^{
            NSArray *msgs = [response messages];
            NSMutableArray *add = [[NSMutableArray alloc] init];
            [msgs enumerateObjectsUsingBlock:^(TL_localMessage * obj, NSUInteger idx, BOOL *stop) {
                
                if([obj.media isKindOfClass:[TL_messageMediaPhoto class]]) {
                    
                    [[Storage manager] insertMedia:obj];
                    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:obj.n_id media:obj peer_id:obj.peer_id];
                    [Notification perform:MEDIA_RECEIVE data:@{KEY_PREVIEW_OBJECT:previewObject}];
                    
                    MediaCollectionItem *mediaItem = [[MediaCollectionItem alloc] initWithPreviewObject:previewObject];
                    
                    if(_cache[@(previewObject.msg_id)] == nil) {
                        [_cache setObject:mediaItem forKey:@(previewObject.msg_id)];
                        [add addObject:mediaItem];
                    }
                }
            }];
            
            if(msgs.count < 100) {
                _loaded = YES;
            }
            
            [LoopingUtils runOnMainQueueAsync:^{
                 [arrayController addObjects:add];
                
                 _locked = NO;
            }];
            
           
        
        }];
        
    } errorHandler:nil];
}

@end
