//
//  TMCollectionPageController.m
//  Messenger for Telegram
//
//  Created by keepcoder on 13.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMCollectionPageController.h"
#import "TMCollectionViewController.h"
#import "TMMediaController.h"
#import "PhotoCollectionTableView.h"
#import "TLFileLocation+Extensions.h"
#import "TGPVMediaBehavior.h"
#import "PhotoHistoryFilter.h"
#import "VideoHistoryFilter.h"
#import "DocumentHistoryFilter.h"
#import "AudioHistoryFilter.h"
@interface TMCollectionPageController ()<TMTableViewDelegate>
@property (nonatomic,strong) PhotoCollectionTableView *photoCollection;
@property (nonatomic,strong) NSMutableArray *items;

@property (nonatomic,assign) BOOL locked;

@property (nonatomic,strong) NSMutableArray *waitItems;

@property (nonatomic,strong) TGPVMediaBehavior *behavior;




-(void)reloadData;
-(BOOL)updateSize:(NSSize)newSize;
@end

@interface TMCollectionPageView : TMView
@property (nonatomic,strong) TMCollectionPageController *controller;

@end

@implementation TMCollectionPageView

-(void)setFrameSize:(NSSize)newSize {
    
   // BOOL isUpdated = [self.controller updateSize:newSize];
    
    [super setFrameSize:newSize];
    
  //  if(!isUpdated)
        [_controller reloadData];
   // else
       // [_controller.photoCollection noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _controller.photoCollection.list.count)]];
   
}

@end

@implementation TMCollectionPageController

-(id)initWithFrame:(NSRect)frame {
    if(self = [super initWithFrame:frame]) {
        
    }
    
    return self;
}




-(void)loadView {
    
    [TGCache setMemoryLimit:50*1024*1024 group:PCCACHE];
    
     self.view = [[TMCollectionPageView alloc] initWithFrame:self.frameInit];
    
    TMTextField *nameTextField = [TMTextField defaultTextField];
    [nameTextField setAlignment:NSCenterTextAlignment];
    [nameTextField setAutoresizingMask:NSViewWidthSizable];
    [nameTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
    [nameTextField setTextColor:NSColorFromRGB(0x222222)];
    [[nameTextField cell] setTruncatesLastVisibleLine:YES];
    [[nameTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    [nameTextField setDrawsBackground:NO];
    
    [nameTextField setFrameOrigin:NSMakePoint(nameTextField.frame.origin.x, -15)];
    
    [nameTextField setStringValue:NSLocalizedString(@"Profile.Photos", nil)];
    
    
    self.centerNavigationBarView = (TMView *) nameTextField;
    
    
    self.items = [[NSMutableArray alloc] init];
    
    self.behavior = [[TGPVMediaBehavior alloc] init];
    
    _photoCollection = [[PhotoCollectionTableView alloc] initWithFrame:self.view.bounds];
    
     [_photoCollection setFrame:self.view.bounds];
    
    _photoCollection.tm_delegate = self;
    
    [_photoCollection setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    
    [(TMCollectionPageView *)self.view setController:self];
    
    [self.view addSubview:_photoCollection.containerView];
    
    
    id clipView = [[self.photoCollection enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];

    
    
    self.rightNavigationBarView = (TMView *)[TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.Media", nil)];
    
    weakify();
    
    
    [(TMTextButton *) self.rightNavigationBarView setTapBlock:^{
        
        [[strongSelf filterMenu] popUpForView:strongSelf.rightNavigationBarView center:YES];
        
    }];
    
    
}


-(void)didDeleteMessages:(NSNotification *)notification {

    
    NSArray *ids = notification.userInfo[KEY_MESSAGE_ID_LIST];
    
    NSMutableArray *items_to_delete = [[NSMutableArray alloc] init];
    
    [ids enumerateObjectsUsingBlock:^(NSNumber *msg_id, NSUInteger idx, BOOL *stop) {
            
        [self.items enumerateObjectsUsingBlock:^(PhotoCollectionImageObject *obj, NSUInteger idx, BOOL *stop) {
                
            if(obj.previewObject.msg_id == [msg_id intValue]) {
                    
                [items_to_delete addObject:obj];
                    
                *stop = YES;
            }
                
        }];
            
    }];
    
    [self.items removeObjectsInArray:items_to_delete];
    
    [self reloadData];
    
    
}

-(void)didReceivedMedia:(NSNotification *)notification {
    
    PreviewObject *previewObject = notification.userInfo[KEY_PREVIEW_OBJECT];
    
    if(_conversation.peer_id != previewObject.peerId)
        return;
    
    
    [self.items addObjectsFromArray:[self convertItems:@[previewObject]]];
    
    [self resort];
    
    [self reloadData];
        
    
}

-(void)resort {
    [self.items sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"previewObject.msg_id" ascending:NO]]];
}


-(void)didAddMediaItem:(PreviewObject *)item {
    
    TL_localMessage *msg = item.media;
    
    if(_conversation.peer_id != msg.peer_id)
        return;
    
    [_items insertObjects:[self convertItems:@[item]] atIndexes:[NSIndexSet indexSetWithIndex:0]];
    
    [self reloadData];
    
}
-(void)didDeleteMediaItem:(PreviewObject *)item {
    TL_localMessage *msg = item.media;
    
    if(_conversation.peer_id != msg.peer_id)
        return;
    
    __block id item_for_delete;
    
    [_items enumerateObjectsUsingBlock:^(PhotoCollectionImageObject *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.previewObject.msg_id == msg.n_id) {
            item_for_delete = obj;
            *stop = YES;
        }
        
    }];
    
    [self.items removeObject:item_for_delete];
    
    [self reloadData];
}


- (void)scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)aNotification {
    
    if(!self.locked && [self.photoCollection.scrollView isNeedUpdateBottom]) {
        [self loadRemote];
    }

}


static const int maxWidth = 120;

-(NSSize)itemSize {
    float size = NSWidth(self.view.frame)/[self columns];
    
 //   NSLog(@"%f",size);
    
    return NSMakeSize(size, size);
    
}

-(int)columns {
    return floor(NSWidth(self.view.frame)/maxWidth);
}

-(int)rows {
    return floor(NSHeight(self.view.frame)/maxWidth);
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return [self itemSize].height;
}

- (int)visibilityCount {
    return [self columns] * [self rows] * 2;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(PhotoTableItem *) item {
    
    static NSString* const kRowIdentifier = @"photoCollectionView";
    
    id photoTableItemView = [self.photoCollection cacheViewForClass:[PhotoTableItemView class] identifier:kRowIdentifier];
    item.size = [self itemSize];
    return photoTableItemView;
}

- (void)selectionDidChange:(NSInteger)row item:(TMRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return NO;
}

- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return NO;
}


-(void)setConversation:(TL_conversation *)conversation {
    self->_conversation = conversation;
    
    [self view];
    
    [self.items removeAllObjects];
    
    [self.waitItems removeAllObjects];
    self.locked = NO;
    
    
    self.behavior = [[TGPVMediaBehavior alloc] init];
    self.behavior.conversation = conversation;
    
    
    
    [self.behavior load:INT32_MAX next:YES limit:100 callback:^(NSArray *previewObjects) {
        
        [[ASQueue mainQueue] dispatchOnQueue:^{
            int limit = [self visibilityCount];
            
            self.waitItems = [[self convertItems:previewObjects] mutableCopy];
            
            if(self.waitItems.count > limit) {
                
                self.items = [[self.waitItems subarrayWithRange:NSMakeRange(0, limit)] mutableCopy];
                
            } else {
                self.items = [self.waitItems mutableCopy];
            }
            
            
            [self.waitItems removeObjectsInArray:self.items];
            
            [self reloadData];
            
            if(self.items.count < 50) {
                [self loadRemote];
            }
        }];
    }];
    
}


-(void)loadRemote {
    
    if(self.waitItems.count > 0) {
        
        
        self.locked = YES;
        
        int limit = [self visibilityCount];
        
        
        NSArray *items;
        
        if(self.waitItems.count > limit) {
            items = [self.waitItems subarrayWithRange:NSMakeRange(0, limit)];
        } else {
            items = [self.waitItems copy];
        }
        
        [self.waitItems removeObjectsInArray:items];
        
        [self addNextItems:items];
        
        self.locked = NO;
        
        
    } else {
        self.locked = YES;
        
        [self.behavior load:[[[self.items lastObject] previewObject] msg_id] next:YES limit:100 callback:^(NSArray *previewObjects) {
            [[ASQueue mainQueue] dispatchOnQueue:^{
                if(previewObjects.count > 0) {
                    
                    NSArray *converted = [self convertItems:previewObjects];
                    
                    [self addNextItems:converted];
                    
                }
                
                self.locked = NO;
            }];
            
        }];
    }
    
   
}

-(NSArray *)convertItems:(NSArray *)items {
    
    NSMutableArray *converted = [[NSMutableArray alloc] init];
    
    [items enumerateObjectsUsingBlock:^(PreviewObject *previewObject, NSUInteger idx, BOOL *stop) {
        
        PhotoCollectionImageObject *object = [self imageObjectWithPreview:previewObject];
        
        if(object)
            [converted addObject:object];
        
    }];
    
    return converted;
    
}



-(NSArray *)convertedRows:(NSArray *)items {
    
    
    __block int columnId = 0;
    
    __block int idx = 0;
    
    int count = [self columns];
    
    __block NSMutableArray *columnObjects = [[NSMutableArray alloc] init];
    
    NSMutableArray *converted = [[NSMutableArray alloc] init];
    
    [items enumerateObjectsUsingBlock:^(TGImageObject *obj, NSUInteger pos, BOOL *stop) {
        
        BOOL addColumn = NO;
        
        if(idx < count) {
            
            [columnObjects addObject:obj];
            
            idx++;
            
            addColumn = idx == count || pos == items.count-1;
        }
        
        if(addColumn) {
            PhotoTableItem *columnItem = [[PhotoTableItem alloc] initWithPreviewObjects:[columnObjects copy]];
            columnItem.size = [self itemSize];
            [converted addObject:columnItem];
            columnId++;
            idx = 0;
            [columnObjects removeAllObjects];
            
        }
    }];
    
    return converted;
}



-(void)reloadData {
    
    
    [self.photoCollection removeAllItems:NO];
    
    [self.photoCollection insert:[self convertedRows:self.items] startIndex:0 tableRedraw:NO];

    [self.photoCollection reloadData];
    
   
}


-(void)addNextItems:(NSArray *)items {
    
    int count = [self columns];
    
    PhotoTableItem *lastItem = [self.photoCollection.list lastObject];
    
    
    NSArray *insert = @[];
    
    int startIndex = (int)self.photoCollection.list.count;
    
    if(lastItem && lastItem.previewObjects.count < count) {
        
        int dif = count - (int)lastItem.previewObjects.count;
        
        if(items.count > dif) {
            lastItem.previewObjects = [lastItem.previewObjects arrayByAddingObjectsFromArray:[items subarrayWithRange:NSMakeRange(0, dif)]];
            items = [items subarrayWithRange:NSMakeRange(dif, items.count - dif)];
        } else {
            lastItem.previewObjects = [lastItem.previewObjects arrayByAddingObjectsFromArray:items];
            items = @[];
        }
        
    //    insert = [insert arrayByAddingObject:lastItem];
      //  startIndex--;
        
    }
    
    insert = [insert arrayByAddingObjectsFromArray:[self convertedRows:items]];
    
    
    [self.items addObjectsFromArray:items];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
       // [self reloadData];
        
        if(lastItem)
            [self.photoCollection reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:startIndex-1] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
         [self.photoCollection insert:insert startIndex:startIndex tableRedraw:YES];
    });
}

-(PhotoCollectionImageObject *)imageObjectWithPreview:(PreviewObject *)previewObject {
    
    TLPhoto *photo = [(TL_localMessage *)previewObject.media media].photo;
    
    PhotoCollectionImageObject *imageObject;
    
    if(photo.sizes.count) {
        
//        NSImage *cachePhoto;
        
        int idx = photo.sizes.count == 1 ? 0 : 1;
        
        TLPhotoSize* photoSize =  ((TLPhotoSize *)photo.sizes[idx]);
        
        
//        NSString *path = [photoSize.location squarePath];
        
//        if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
//            
//            for(TLPhotoSize *photoSize in photo.sizes) {
//                if([photoSize isKindOfClass:[TL_photoCachedSize class]]) {
//                    cachePhoto = [[NSImage alloc] initWithData:photoSize.bytes];
//                    break;
//                }
//            }
//            
//        }
        
        
        
     //   if(cachePhoto) {
          //  cachePhoto = decompressedImage(cachePhoto);
            
            
          //  cachePhoto = cropCenterWithSize(cachePhoto, NSMakeSize(maxWidth, maxWidth));
            
          //  [[PhotoCollectionImageView cache] setObject:cachePhoto forKey:photoSize.location.cacheKey];
   //     }
    
            
//        
//
//        
//        if(cachePhoto && cachePhoto.size.width < photoSize.w) {
//            float scale =  photoSize.w/cachePhoto.size.width;
//            
//            cachePhoto.size = NSMakeSize(scale*cachePhoto.size.width, scale*cachePhoto.size.height);
//            
//        }
//        
//        
//        if(cachePhoto && cachePhoto.size.height < photoSize.h) {
//            float scale =  photoSize.h/cachePhoto.size.height;
//            
//            cachePhoto.size = NSMakeSize(scale*cachePhoto.size.width, scale*cachePhoto.size.height);
//            
//        }
//        
//        cachePhoto = cropCenterWithSize(cachePhoto, NSMakeSize(maxWidth, maxWidth));
//        
        
        imageObject = [[PhotoCollectionImageObject alloc] initWithLocation:photoSize.location placeHolder:nil sourceId:arc4random()];
        imageObject.previewObject = previewObject;
        
    }
    
    
    return imageObject;
}


-(NSMenu *)filterMenu {
    NSMenu *filterMenu = [[NSMenu alloc] init];
    
    [filterMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.Filter.Photos",nil) withBlock:^(id sender) {
        [[Telegram rightViewController] showByDialog:self.conversation withJump:0 historyFilter:[PhotoHistoryFilter class] sender:self];
    }]];
    
    [filterMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.Filter.Video",nil) withBlock:^(id sender) {
        [[Telegram rightViewController] showByDialog:self.conversation withJump:0 historyFilter:[VideoHistoryFilter class] sender:self];
    }]];
    
    
    [filterMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.Filter.Files",nil) withBlock:^(id sender) {
       [[Telegram rightViewController] showByDialog:self.conversation withJump:0 historyFilter:[DocumentHistoryFilter class] sender:self];
    }]];
    
    [filterMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.Filter.Audio",nil) withBlock:^(id sender) {
        [[Telegram rightViewController] showByDialog:self.conversation withJump:0 historyFilter:[AudioHistoryFilter class] sender:self];
    }]];
    
    return filterMenu;
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Notification removeObserver:self];
    
    
    [self.items removeAllObjects];
    
    [self.photoCollection removeAllItems:NO];
    [self.photoCollection reloadData];
    [TGCache removeAllCachedImages:@[PCCACHE]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Notification addObserver:self selector:@selector(didReceivedMedia:) name:MEDIA_RECEIVE];
    [Notification addObserver:self selector:@selector(didDeleteMessages:) name:MESSAGE_DELETE_EVENT];
}

@end
