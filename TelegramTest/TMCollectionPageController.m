//
//  TMCollectionPageController.m
//  Messenger for Telegram
//
//  Created by keepcoder on 13.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMCollectionPageController.h"
#import "TMMediaController.h"
#import "PhotoCollectionTableView.h"
#import "TLFileLocation+Extensions.h"
#import "TGPVMediaBehavior.h"
#import "PhotoHistoryFilter.h"
#import "VideoHistoryFilter.h"
#import "DocumentHistoryFilter.h"
#import "AudioHistoryFilter.h"
#import "TGDocumentsMediaTableView.h"
#import "DownloadVideoItem.h"
#import "TGSharedMediaCap.h"
#import "TGSharedLinksTableView.h"
#import "TGAudioPlayerWindow.h"
@interface TMCollectionPageController ()<TMTableViewDelegate>
@property (nonatomic,strong) PhotoCollectionTableView *photoCollection;
@property (nonatomic,strong) NSMutableArray *items;

@property (nonatomic,assign) BOOL locked;

@property (nonatomic,strong) NSMutableArray *waitItems;

@property (nonatomic,strong) TGPVMediaBehavior *behavior;


@property (nonatomic,strong) TGDocumentsMediaTableView *documentsTableView;
@property (nonatomic,strong) TGSharedLinksTableView *sharedLinksTableView;


@property (nonatomic,strong) TMTextField *centerTextField;
@property (nonatomic,strong) TGSharedMediaCap *mediaCap;
@property (nonatomic,assign) BOOL isProgress;



@property (nonatomic, strong) TMTextButton *deleteButton;
@property (nonatomic, strong) TMTextButton *messagesSelectedCount;
@property (nonatomic, strong) TMTextButton *forwardButton;

@property (nonatomic, strong) TMView *actionsView;

@property (nonatomic,strong) NSMutableArray *selectedItems;

-(void)reloadData;
-(BOOL)updateSize:(NSSize)newSize;
@end

@interface TMCollectionPageView : TMView
@property (nonatomic,strong) TMCollectionPageController *controller;

@end

@implementation TMCollectionPageView

-(void)setFrameSize:(NSSize)newSize {
    
    
    [super setFrameSize:newSize];
    [_controller reloadData];
  
}

@end

@implementation TMCollectionPageController

-(id)initWithFrame:(NSRect)frame {
    if(self = [super initWithFrame:frame]) {
        
    }
    
    return self;
}




-(void)loadView {
    
     weak();
   // [super loadView];
    
    [TGCache setMemoryLimit:100*1024*1024 group:PCCACHE];
    
     self.view = [[TMCollectionPageView alloc] initWithFrame:NSZeroRect];
    
    
    [self setTitle:NSLocalizedString(@"Conversation.Filter.Photos", nil)];
    
    [self.centerTextField setClickBlock:^{
        
        TMMenuPopover *menuPopover = [[TMMenuPopover alloc] initWithMenu:[weakSelf filterMenu]];
        
        [menuPopover showRelativeToRect:weakSelf.centerNavigationBarView.bounds ofView:weakSelf.centerNavigationBarView preferredEdge:CGRectMinYEdge];
        
    }];
    
    
    
    self.items = [[NSMutableArray alloc] init];
    
    self.behavior = [[TGPVMediaBehavior alloc] init];
    
    _photoCollection = [[PhotoCollectionTableView alloc] initWithFrame:self.view.bounds];
    
    _photoCollection.viewController = self;
    
     [_photoCollection setFrame:self.view.bounds];
    
    _photoCollection.tm_delegate = self;
    
    
    
    TMTextButton *selectRightButton =  [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.Edit", nil)];;
    
    [selectRightButton setTapBlock:^ {
        
        [weakSelf setIsEditable:!weakSelf.isEditable animated:YES];
        
    }];
    
    self.rightNavigationBarView = (TMView *)selectRightButton;
    
    
    [(TMCollectionPageView *)self.view setController:self];
    
    [self.view addSubview:_photoCollection.containerView];
    
    
    id clipView = [[self.photoCollection enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];

    
    self.documentsTableView = [[TGDocumentsMediaTableView alloc] initWithFrame:self.frameInit];
    self.documentsTableView.collectionViewController = self;
    
    [self.view addSubview:self.documentsTableView.containerView];
    
    [self.documentsTableView.containerView setHidden:YES];
    
    
    self.sharedLinksTableView = [[TGSharedLinksTableView alloc] initWithFrame:self.frameInit];
    self.sharedLinksTableView.collectionViewController = self;
    
    [self.view addSubview:self.sharedLinksTableView.containerView];
    
    [self.sharedLinksTableView.containerView setHidden:YES];
    
    
    
    self.mediaCap = [[TGSharedMediaCap alloc] initWithFrame:self.view.bounds cap:image_SadAttach() text:NSLocalizedString(@"SharedMedia.NoSharedMedia", nil)];
    
    
    [self.view addSubview:self.mediaCap];
    
   // [self.mediaCap setHidden:YES];
    
    
    [self.view addSubview:self.actionsView];
    
  //  [self.actionsView setHidden:YES];
    
    
    
   
    
}

-(void)showContextPopup {
    [[self filterMenu] popUpForView:self.centerNavigationBarView center:YES];
}

-(void)setTitle:(NSString *)title {
    [self setCenterBarViewTextAttributed:[self stringForSharedMedia:title]];
}


-(void)setIsEditable:(BOOL)isEditable animated:(BOOL)animated {
    _isEditable = isEditable;
    
     TMTextButton *btn = (TMTextButton *)self.rightNavigationBarView;
    
    [btn setStringValue:!isEditable ? NSLocalizedString(@"Profile.Edit", nil) : NSLocalizedString(@"Profile.Cancel", nil)];
    
    [btn sizeToFit];
    
    self.rightNavigationBarView = (TMView *) btn;
    
    self.selectedItems = [[NSMutableArray alloc] init];
    
    [self.documentsTableView setEditable:isEditable animated:animated];
    [self.sharedLinksTableView setEditable:isEditable animated:animated];
    [self.photoCollection reloadData];
    
    
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        
        [context setDuration:animated ? 0.2 : 0];
        
        [[self.actionsView animator] setFrameOrigin:NSMakePoint(0, isEditable ? 0 : - NSHeight(self.actionsView.frame))];
        [[self.photoCollection.containerView animator] setFrame:NSMakeRect(0, _isEditable ? NSHeight(self.actionsView.frame) : 0, NSWidth(self.navigationViewController.view.frame), NSHeight(self.navigationViewController.view.frame) - 48 - (_isEditable ? NSHeight(self.actionsView.frame) : 0))];
        [[self.documentsTableView.containerView animator] setFrame:NSMakeRect(0, _isEditable ? NSHeight(self.actionsView.frame) : 0, NSWidth(self.navigationViewController.view.frame), NSHeight(self.navigationViewController.view.frame) - 48 - (_isEditable ? NSHeight(self.actionsView.frame) : 0))];
        [[self.sharedLinksTableView.containerView animator] setFrame:NSMakeRect(0, _isEditable ? NSHeight(self.actionsView.frame) : 0, NSWidth(self.navigationViewController.view.frame), NSHeight(self.navigationViewController.view.frame) - 48 - (_isEditable ? NSHeight(self.actionsView.frame) : 0))];
        
    } completionHandler:^{
        
    }];
    
    
    
   // [self.actionsView setHidden:!_isEditable];
    
    

    
}


-(void)didDeleteMessages:(NSNotification *)notification {

    
    NSArray *peer_update_data = notification.userInfo[KEY_DATA];
    
    NSMutableArray *items_to_delete = [[NSMutableArray alloc] init];
    
    [peer_update_data enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
        
        if(self.conversation.peer_id == [data[KEY_PEER_ID] intValue]) {
            [self.items enumerateObjectsUsingBlock:^(PhotoCollectionImageObject *obj, NSUInteger idx, BOOL *stop) {
                
                if(obj.previewObject.msg_id == [data[KEY_MESSAGE_ID] intValue]) {
                    
                    [items_to_delete addObject:obj];
                    
                    *stop = YES;
                }
                
            }];
        }
            
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
    
 //   MTLog(@"%f",size);
    
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


-(void)showFiles {
    [self.documentsTableView.containerView setHidden:NO];
    [self.photoCollection.containerView setHidden:YES];
    [self.sharedLinksTableView.containerView setHidden:YES];
    
    [self setTitle:NSLocalizedString(@"Conversation.Filter.Files", nil)];
    [self checkCap];
    [self setIsEditable:NO animated:NO];
}

-(void)showSharedLinks {
    [self.sharedLinksTableView.containerView setHidden:NO];
    [self.photoCollection.containerView setHidden:YES];
    [self.documentsTableView.containerView setHidden:YES];
    
    [self setTitle:NSLocalizedString(@"Conversation.Filter.SharedLinks", nil)];
    [self checkCap];
    [self setIsEditable:NO animated:NO];
}

-(void)showAllMedia {
    [self.documentsTableView.containerView setHidden:YES];
    [self.photoCollection.containerView setHidden:NO];
    [self.sharedLinksTableView.containerView setHidden:YES];
    
    [self setTitle:NSLocalizedString(@"Profile.SharedMedia", nil)];
    [self checkCap];
    [self setIsEditable:NO animated:NO];
}



-(void)setConversation:(TL_conversation *)conversation {
    
    
    
    self->_conversation = conversation;
    
    self.isProgress = YES;
    
    self.selectedItems = [[NSMutableArray alloc] init];
   
    
    
    
    [self setSectedMessagesCount:0 enable:NO];
   
    [self view];
    
   
    
    [self.documentsTableView setConversation:conversation];
    [self.sharedLinksTableView setConversation:conversation];
    
    [self.items removeAllObjects];
    
    [self.waitItems removeAllObjects];
    self.locked = NO;
    
    
    self.behavior = [[TGPVMediaBehavior alloc] initWithConversation:_conversation commonItem:nil];
    self.behavior.conversation = conversation;
    
    
    
    [self.behavior load:INT32_MAX next:YES limit:100 callback:^(NSArray *previewObjects) {
        
        [[ASQueue mainQueue] dispatchOnQueue:^{
            
            self.isProgress = NO;
            
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


-(void)setSelected:(BOOL)selected forItem:(MessageTableItem *)item {
    
    if(selected) {
        [_selectedItems addObject:item];
    } else {
        [_selectedItems removeObject:item];
    }
    
    NSMutableArray *messages = [NSMutableArray array];
    
    [_selectedItems enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [messages addObject:obj.message];
    }];
    
    [self setSectedMessagesCount:self.selectedItems.count enable:[MessagesViewController canDeleteMessages:messages inConversation:_conversation]];
}

-(BOOL)isSelectedItem:(PhotoCollectionImageObject *)item {
    return [self.selectedItems indexOfObject:item] != NSNotFound;
}

-(NSArray *)selectedItems {
    return _selectedItems;
}



-(NSAttributedString *)stringForSharedMedia:(NSString *)mediaString {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    
    [string appendString:mediaString withColor:BLUE_UI_COLOR];
    
    [string setFont:TGSystemFont(14) forRange:NSMakeRange(0, string.length)];
    
    [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:[NSMutableAttributedString textAttachmentByImage:[image_HeaderDropdownArrow() imageWithInsets:NSEdgeInsetsMake(0, 5, 1, 4)]]]];
    
    [string setAlignment:NSCenterTextAlignment range:NSMakeRange(0, string.length)];
    
    return string;
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
           
            [ASQueue dispatchOnMainQueue:^{
                if(previewObjects.count > 0) {
                    
                    NSArray *converted = [self convertItems:previewObjects];
                    
                    [self addNextItems:converted];
                    
                }
                
                self.locked = NO;
                
                if(self.items.count < 20 && [self.behavior.controller filterWithNext:YES].nextState != ChatHistoryStateFull) {
                    [self loadRemote];
                }
                
                
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
    
    [self checkCap];
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
        
        [self checkCap];
        
    });
}

-(void)checkCap {
    if(![self.documentsTableView.containerView isHidden]) {
        [self.mediaCap setHidden:![self.documentsTableView isNeedCap]];
        [self.mediaCap updateCap:image_NoFiles() text:NSLocalizedString(@"SharedMedia.NoFiles", nil)];
        [self.mediaCap setProgress:self.documentsTableView.isProgress];
    } else if(![self.sharedLinksTableView.containerView isHidden]) {
        [self.mediaCap setHidden:![self.sharedLinksTableView isNeedCap]];
        [self.mediaCap updateCap:image_NoSharedLinks() text:NSLocalizedString(@"SharedMedia.NoSharedLinks", nil)];
        [self.mediaCap setProgress:self.sharedLinksTableView.isProgress];
        
    } else {
        [self.mediaCap setHidden:self.photoCollection.count != 0];
        [self.mediaCap updateCap:image_SadAttach() text:NSLocalizedString(@"SharedMedia.NoSharedMedia", nil)];
        [self.mediaCap setProgress:self.isProgress];
    }
    
    
}

-(PhotoCollectionImageObject *)imageObjectWithPreview:(PreviewObject *)previewObject {
    
    TLMessageMedia *media = [(TL_localMessage *)previewObject.media media];
    
    PhotoCollectionImageObject *imageObject;
    
    
    if([media isKindOfClass:[TL_messageMediaPhoto class]]) {
        
        TLPhoto *photo = media.photo;
        
        if(photo.sizes.count) {
            
            //        NSImage *cachePhoto;
            
            int idx = photo.sizes.count == 1 ? 0 : 1;
            
            TLPhotoSize* photoSize =  ((TLPhotoSize *)photo.sizes[idx]);
            
            
            imageObject = [[PhotoCollectionImageObject alloc] initWithLocation:photoSize.location placeHolder:nil sourceId:arc4random() size:photoSize.size];
            imageObject.previewObject = previewObject;
            
        }
    } else if([media isKindOfClass:[TL_messageMediaVideo class]]) {
        
        TLVideo *video = media.video;
        
        imageObject = [[PhotoCollectionImageObject alloc] initWithLocation:[video.thumb isKindOfClass:[TL_photoCachedSize class]] ? nil : video.thumb.location placeHolder:[video.thumb isKindOfClass:[TL_photoCachedSize class]] ? [[NSImage alloc] initWithData:video.thumb.bytes] : nil sourceId:arc4random()];
        imageObject.previewObject = previewObject;
        
        previewObject.reservedObject = [[DownloadVideoItem alloc] initWithObject:previewObject.media];
        
    }
    
    
    return imageObject;
}


-(NSMenu *)filterMenu {
    NSMenu *filterMenu = [[NSMenu alloc] init];
    
    [filterMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Profile.SharedMedia",nil) withBlock:^(id sender) {
        
        [self showAllMedia];
        
    }]];
    
//    [filterMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.Filter.Video",nil) withBlock:^(id sender) {
//        [[Telegram rightViewController] showByDialog:self.conversation withJump:0 historyFilter:[VideoHistoryFilter class] sender:self];
//    }]];
//    
    
    [filterMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.Filter.Files",nil) withBlock:^(id sender) {
        [self showFiles];
    }]];
    
    [filterMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.Filter.SharedLinks",nil) withBlock:^(id sender) {
        [self showSharedLinks];
    }]];
    
    
    [filterMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Modern.SharedMedia.Audio",nil) withBlock:^(id sender) {
        [TGAudioPlayerWindow show:_conversation playerState:TGAudioPlayerWindowStatePlayList];
    }]];
    
//    [filterMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.Filter.Audio",nil) withBlock:^(id sender) {
//        [[Telegram rightViewController] showByDialog:self.conversation withJump:0 historyFilter:[AudioHistoryFilter class] sender:self];
//    }]];
    
    return filterMenu;
}


-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [Notification removeObserver:self];
    
    
    [self.items removeAllObjects];
    
    [self.photoCollection removeAllItems:NO];
    [self.photoCollection reloadData];
    
    
    [TGCache removeAllCachedImages:@[PCCACHE]];
    
    [self.documentsTableView setConversation:nil];
    [self.sharedLinksTableView setConversation:nil];
    
    [_behavior drop];
    _behavior = nil;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self setIsEditable:NO animated:NO];
    
    
    [Notification addObserver:self selector:@selector(didReceivedMedia:) name:MEDIA_RECEIVE];
    [Notification addObserver:self selector:@selector(didDeleteMessages:) name:MESSAGE_DELETE_EVENT];
}



- (TMView *)actionsView {
    if(self->_actionsView)
        return self->_actionsView;
    
    weak();
    
    self->_actionsView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, weakSelf.view.bounds.size.width, 58)];
    [self.actionsView setWantsLayer:YES];
    [self.actionsView setAutoresizesSubviews:YES];
    [self.actionsView setAutoresizingMask:NSViewWidthSizable];
    
    
    
    self.actionsView.backgroundColor = [NSColor whiteColor];
    
    self.deleteButton = [TMTextButton standartButtonWithTitle:NSLocalizedString(@"Messages.Selected.Delete", nil) standartImage:image_MessageActionDeleteActive() disabledImage:image_MessageActionDelete()];
    
    [self.deleteButton setAutoresizingMask:NSViewMaxXMargin ];
    [self.deleteButton setTapBlock:^{
       
        [weakSelf.messagesViewController setState:MessagesViewControllerStateNone];
        [weakSelf.messagesViewController unSelectAll:NO];
        
        
        if(![weakSelf.documentsTableView.containerView isHidden]) {
            
            
            [weakSelf.documentsTableView.selectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                [weakSelf.messagesViewController setSelectedMessage:obj selected:YES];
            }];
            
            
        } if(![weakSelf.sharedLinksTableView.containerView isHidden]) {
            
            [weakSelf.sharedLinksTableView.selectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                [weakSelf.navigationViewController.messagesViewController setSelectedMessage:obj selected:YES];
            }];
        } else {
            
            [weakSelf.selectedItems enumerateObjectsUsingBlock:^(PhotoCollectionImageObject *obj, NSUInteger idx, BOOL *stop) {
                
                MessageTableItem *item  = [MessageTableItem messageItemFromObject:obj.previewObject.media];
                
                [weakSelf.navigationViewController.messagesViewController setSelectedMessage:item selected:YES];
            }];
            
        }
        
       [[Telegram rightViewController].messagesViewController deleteSelectedMessages];
        
        [weakSelf setIsEditable:NO animated:YES];
        
    }];
    self.deleteButton.disableColor = NSColorFromRGB(0xa1a1a1);
    [self.actionsView addSubview:self.deleteButton];
    
    
    self.messagesSelectedCount = [TMTextButton standartUserProfileNavigationButtonWithTitle:@""];
    self.messagesSelectedCount.textColor = DARK_BLACK;
    self.messagesSelectedCount.font = TGSystemFont(14);
    [self.messagesSelectedCount setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
    [self.actionsView addSubview:self.messagesSelectedCount];
    
    self.forwardButton = [TMTextButton standartButtonWithTitle:NSLocalizedString(@"Messages.Selected.Forward", nil) standartImage:image_MessageActionForwardActive() disabledImage:image_MessageActionForward()];
    
    [self.forwardButton setAutoresizingMask:NSViewMinXMargin];
    self.forwardButton.disableColor = NSColorFromRGB(0xa1a1a1);
    
    [self.forwardButton setTapBlock:^{
        
        
        [weakSelf.messagesViewController setState:MessagesViewControllerStateNone];
        [weakSelf.messagesViewController unSelectAll:NO];
        
        
        NSUInteger count = 0;
        
        if(![weakSelf.documentsTableView.containerView isHidden]) {
            
            count = weakSelf.documentsTableView.selectedItems.count;
            
            [weakSelf.documentsTableView.selectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                [weakSelf.messagesViewController setSelectedMessage:obj selected:YES];
            }];
            
            
        } if(![weakSelf.sharedLinksTableView.containerView isHidden]) {
            count = weakSelf.sharedLinksTableView.selectedItems.count;
            
            [weakSelf.sharedLinksTableView.selectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                [weakSelf.messagesViewController setSelectedMessage:obj selected:YES];
            }];
        } else {
            
            count = weakSelf.selectedItems.count;
            
            [weakSelf.selectedItems enumerateObjectsUsingBlock:^(PhotoCollectionImageObject *obj, NSUInteger idx, BOOL *stop) {
                
                MessageTableItem *item  = [MessageTableItem messageItemFromObject:obj.previewObject.media];
                
                [weakSelf.messagesViewController setSelectedMessage:item selected:YES];
            }];
            
        }
        
        [weakSelf.messagesViewController showForwardMessagesModalView];
        
        [weakSelf setIsEditable:NO animated:YES];
        
    }];
    
    [self.actionsView setDrawBlock:^{
        
        [GRAY_BORDER_COLOR set];
        
        NSRectFill(NSMakeRect(0, NSHeight(weakSelf.actionsView.frame) - 1, NSWidth(weakSelf.actionsView.frame), 1));
        
        [weakSelf.forwardButton setFrameOrigin:NSMakePoint(weakSelf.actionsView.bounds.size.width - weakSelf.forwardButton.bounds.size.width - 22, roundf((weakSelf.actionsView.bounds.size.height - weakSelf.deleteButton.bounds.size.height) / 2))];
        [weakSelf.deleteButton setFrameOrigin:NSMakePoint(30, roundf((weakSelf.actionsView.bounds.size.height - weakSelf.deleteButton.bounds.size.height) / 2) )];
        [weakSelf.messagesSelectedCount setCenterByView:weakSelf.actionsView];
        
    }];
    
    
    
    [self.actionsView addSubview:self.forwardButton];
    
    return self.actionsView;
}

- (void)setSectedMessagesCount:(NSUInteger)count enable:(BOOL)enable {
    
    if(count == 0) {
        [self.messagesSelectedCount setHidden:YES];
        [self.forwardButton setDisable:YES];
        [self.deleteButton setDisable:YES];
        return;
    } else {
        [self.forwardButton setDisable:NO];
        [self.deleteButton setDisable:!enable];
    }
    
    [self.messagesSelectedCount setHidden:NO];
    
    [self.messagesSelectedCount setStringValue:[NSString stringWithFormat:NSLocalizedString(count == 1 ? @"Edit.selectMessage" : @"Edit.selectMessages", nil), count]];
    [self.messagesSelectedCount sizeToFit];
    [self.messagesSelectedCount setFrameOrigin:NSMakePoint(roundf((self.actionsView.bounds.size.width - self.messagesSelectedCount.bounds.size.width) /2), roundf((self.actionsView.bounds.size.height - self.messagesSelectedCount.bounds.size.height)/2))];
    
}


@end
