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


@interface TMCollectionPageController ()<TMTableViewDelegate>
@property (nonatomic,strong) PhotoCollectionTableView *photoCollection;
@property (nonatomic,strong) NSMutableArray *items;

@property (nonatomic,assign) BOOL locked;

@property (nonatomic,strong) NSMutableArray *waitItems;

@property (nonatomic,strong) TGPVMediaBehavior *behavior;


@property (nonatomic,strong) TGDocumentsMediaTableView *documentsTableView;

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
    
     weakify();
    
    [TGCache setMemoryLimit:100*1024*1024 group:PCCACHE];
    
     self.view = [[TMCollectionPageView alloc] initWithFrame:self.frameInit];
    
    _centerTextField = [TMTextField defaultTextField];
    [_centerTextField setAlignment:NSCenterTextAlignment];
    [_centerTextField setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
    [_centerTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
    [_centerTextField setTextColor:NSColorFromRGB(0x222222)];
    [[_centerTextField cell] setTruncatesLastVisibleLine:YES];
    [[_centerTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    [_centerTextField setDrawsBackground:NO];
    
    [_centerTextField setClickBlock:^{
        
        TMMenuPopover *menuPopover = [[TMMenuPopover alloc] initWithMenu:[strongSelf filterMenu]];
        
        [menuPopover showRelativeToRect:strongSelf.centerNavigationBarView.bounds ofView:strongSelf.centerNavigationBarView preferredEdge:CGRectMinYEdge];
        
    }];
    
    TMView *centerView = [[TMView alloc] initWithFrame:NSZeroRect];
    
    self.centerNavigationBarView = centerView;
    
    [centerView addSubview:_centerTextField];
    
    [self setTitle:NSLocalizedString(@"Conversation.Filter.Photos", nil)];
    
    self.items = [[NSMutableArray alloc] init];
    
    self.behavior = [[TGPVMediaBehavior alloc] init];
    
    _photoCollection = [[PhotoCollectionTableView alloc] initWithFrame:self.view.bounds];
        
     [_photoCollection setFrame:self.view.bounds];
    
    _photoCollection.tm_delegate = self;
    
    
    
    TMTextButton *selectRightButton =  [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.Edit", nil)];;
    
    [selectRightButton setTapBlock:^ {
        
        strongSelf.isEditable = !strongSelf.isEditable;
        
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
    
    
    [self.view addSubview:self.documentsTableView.containerView];
    
    [self.documentsTableView.containerView setHidden:YES];
    
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
    [_centerTextField setAttributedStringValue:[self stringForSharedMedia:title]];
    
    [_centerTextField sizeToFit];
    
    [_centerTextField setCenterByView:self.centerNavigationBarView];
    
    [_centerTextField setFrameOrigin:NSMakePoint(_centerTextField.frame.origin.x, 13)];
}


-(void)setIsEditable:(BOOL)isEditable {
    _isEditable = isEditable;
    
     TMTextButton *btn = (TMTextButton *)self.rightNavigationBarView;
    
    [btn setStringValue:!isEditable ? NSLocalizedString(@"Profile.Edit", nil) : NSLocalizedString(@"Profile.Cancel", nil)];
    
    [btn sizeToFit];
    
    self.rightNavigationBarView = (TMView *) btn;
    
    self.selectedItems = [[NSMutableArray alloc] init];
    
    [self.documentsTableView setEditable:isEditable animated:YES];
    [self reloadData];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        
        [[self.actionsView animator] setFrameOrigin:NSMakePoint(0, isEditable ? 0 : - NSHeight(self.actionsView.frame))];
        [[self.photoCollection.containerView animator] setFrame:NSMakeRect(0, _isEditable ? NSHeight(self.actionsView.frame) : 0, NSWidth([Telegram rightViewController].view.frame), NSHeight([Telegram rightViewController].view.frame) - 48 - (_isEditable ? NSHeight(self.actionsView.frame) : 0))];
        [[self.documentsTableView.containerView animator] setFrame:NSMakeRect(0, _isEditable ? NSHeight(self.actionsView.frame) : 0, NSWidth([Telegram rightViewController].view.frame), NSHeight([Telegram rightViewController].view.frame) - 48 - (_isEditable ? NSHeight(self.actionsView.frame) : 0))];
        
        
    } completionHandler:^{
        
    }];
    
    
    
   // [self.actionsView setHidden:!_isEditable];
    
    

    
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


-(void)showFiles {
    [self.documentsTableView.containerView setHidden:NO];
    [self.photoCollection.containerView setHidden:YES];
    [self.documentsTableView setConversation:self.conversation];
    [self setTitle:NSLocalizedString(@"Conversation.Filter.Files", nil)];
    [self checkCap];
    [self setIsEditable:NO];
}

-(void)showAllMedia {
    [self.documentsTableView.containerView setHidden:YES];
    [self.photoCollection.containerView setHidden:NO];
    [self setTitle:NSLocalizedString(@"Profile.SharedMedia", nil)];
    [self checkCap];
    [self setIsEditable:NO];
}

-(void)setConversation:(TL_conversation *)conversation {
    self->_conversation = conversation;
    
    self.isProgress = YES;
    
    self.selectedItems = [[NSMutableArray alloc] init];
   
    
    self.isEditable = NO;
    
    [self setSectedMessagesCount:0];
   
    [self view];
    
    [self showAllMedia];
    
    [self.documentsTableView setConversation:conversation];
    
    
    [self.items removeAllObjects];
    
    [self.waitItems removeAllObjects];
    self.locked = NO;
    
    
    self.behavior = [[TGPVMediaBehavior alloc] init];
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
    
    [self setSectedMessagesCount:self.selectedItems.count];
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
    
    [string setFont:[NSFont fontWithName:@"HelveticaNeue" size:14] forRange:NSMakeRange(0, string.length)];
    
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
    if([self.photoCollection.containerView isHidden]) {
        [self.mediaCap setHidden:![self.documentsTableView isNeedCap]];
        [self.mediaCap updateCap:image_NoFiles() text:NSLocalizedString(@"SharedMedia.NoFiles", nil)];
        [self.mediaCap setProgress:self.documentsTableView.isProgress];
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
            
            
            imageObject = [[PhotoCollectionImageObject alloc] initWithLocation:photoSize.location placeHolder:nil sourceId:arc4random()];
            imageObject.previewObject = previewObject;
            
        }
    } else if([media isKindOfClass:[TL_messageMediaVideo class]]) {
        
        TLVideo *video = media.video;
        
        imageObject = [[PhotoCollectionImageObject alloc] initWithLocation:video.thumb.location placeHolder:nil sourceId:arc4random()];
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
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Notification addObserver:self selector:@selector(didReceivedMedia:) name:MEDIA_RECEIVE];
    [Notification addObserver:self selector:@selector(didDeleteMessages:) name:MESSAGE_DELETE_EVENT];
}



- (TMView *)actionsView {
    if(self->_actionsView)
        return self->_actionsView;
    
    weakify();
    
    self->_actionsView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, strongSelf.view.bounds.size.width, 58)];
    [self.actionsView setWantsLayer:YES];
    [self.actionsView setAutoresizesSubviews:YES];
    [self.actionsView setAutoresizingMask:NSViewWidthSizable];
    
    
    
    self.actionsView.backgroundColor = [NSColor whiteColor];
    
    self.deleteButton = [TMTextButton standartButtonWithTitle:NSLocalizedString(@"Messages.Selected.Delete", nil) standartImage:image_MessageActionDeleteActive() disabledImage:image_MessageActionDelete()];
    
    [self.deleteButton setAutoresizingMask:NSViewMaxXMargin ];
    [self.deleteButton setTapBlock:^{
       
        [[Telegram rightViewController].messagesViewController setState:MessagesViewControllerStateNone];
        [[Telegram rightViewController].messagesViewController unSelectAll:NO];
        
        
        if(![strongSelf.documentsTableView.containerView isHidden]) {
            
            
            [strongSelf.documentsTableView.selectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                [[Telegram rightViewController].messagesViewController setSelectedMessage:obj selected:YES];
            }];
            
            
        } else {
            
            [strongSelf.selectedItems enumerateObjectsUsingBlock:^(PhotoCollectionImageObject *obj, NSUInteger idx, BOOL *stop) {
                
                MessageTableItem *item  = [MessageTableItem messageItemFromObject:obj.previewObject.media];
                
                [[Telegram rightViewController].messagesViewController setSelectedMessage:item selected:YES];
            }];
            
        }
        
       [[Telegram rightViewController].messagesViewController deleteSelectedMessages];
        
        strongSelf.isEditable = NO;
        
    }];
    self.deleteButton.disableColor = NSColorFromRGB(0xa1a1a1);
    [self.actionsView addSubview:self.deleteButton];
    
    
    self.messagesSelectedCount = [TMTextButton standartUserProfileNavigationButtonWithTitle:@""];
    self.messagesSelectedCount.textColor = DARK_BLACK;
    self.messagesSelectedCount.font = [NSFont fontWithName:@"HelveticaNeue" size:14];
    [self.messagesSelectedCount setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
    [self.actionsView addSubview:self.messagesSelectedCount];
    
    self.forwardButton = [TMTextButton standartButtonWithTitle:NSLocalizedString(@"Messages.Selected.Forward", nil) standartImage:image_MessageActionForwardActive() disabledImage:image_MessageActionForward()];
    
    [self.forwardButton setAutoresizingMask:NSViewMinXMargin];
    self.forwardButton.disableColor = NSColorFromRGB(0xa1a1a1);
    
    [self.forwardButton setTapBlock:^{
        
        
        [[Telegram rightViewController].messagesViewController setState:MessagesViewControllerStateNone];
        [[Telegram rightViewController].messagesViewController unSelectAll:NO];
        
        
        NSUInteger count = 0;
        
        if(![strongSelf.documentsTableView.containerView isHidden]) {
            
            count = strongSelf.documentsTableView.selectedItems.count;
            
            [strongSelf.documentsTableView.selectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                [[Telegram rightViewController].messagesViewController setSelectedMessage:obj selected:YES];
            }];
            
            
        } else {
            
            count = strongSelf.selectedItems.count;
            
            [strongSelf.selectedItems enumerateObjectsUsingBlock:^(PhotoCollectionImageObject *obj, NSUInteger idx, BOOL *stop) {
                
                MessageTableItem *item  = [MessageTableItem messageItemFromObject:obj.previewObject.media];
                
                [[Telegram rightViewController].messagesViewController setSelectedMessage:item selected:YES];
            }];
            
        }
        
        [[Telegram rightViewController] showForwardMessagesModalView:strongSelf.conversation messagesCount:count];
        
        strongSelf.isEditable = NO;
        
    }];
    
    [self.actionsView setDrawBlock:^{
        
        [GRAY_BORDER_COLOR set];
        
        NSRectFill(NSMakeRect(0, NSHeight(strongSelf.actionsView.frame) - 1, NSWidth(strongSelf.actionsView.frame), 1));
        
        [strongSelf.forwardButton setFrameOrigin:NSMakePoint(strongSelf.actionsView.bounds.size.width - strongSelf.forwardButton.bounds.size.width - 22, roundf((strongSelf.actionsView.bounds.size.height - strongSelf.deleteButton.bounds.size.height) / 2))];
        [strongSelf.deleteButton setFrameOrigin:NSMakePoint(30, roundf((strongSelf.actionsView.bounds.size.height - strongSelf.deleteButton.bounds.size.height) / 2) )];
        [strongSelf.messagesSelectedCount setCenterByView:strongSelf.actionsView];
        
    }];
    
    
    
    [self.actionsView addSubview:self.forwardButton];
    
    return self.actionsView;
}

- (void)setSectedMessagesCount:(NSUInteger)count {
    
    if(count == 0) {
        [self.messagesSelectedCount setHidden:YES];
        [self.forwardButton setDisable:YES];
        [self.deleteButton setDisable:YES];
        return;
    } else {
        [self.deleteButton setDisable:NO];
        [self.forwardButton setDisable:NO];
    }
    
    [self.messagesSelectedCount setHidden:NO];
    
    [self.messagesSelectedCount setStringValue:[NSString stringWithFormat:NSLocalizedString(count == 1 ? @"Edit.selectMessage" : @"Edit.selectMessages", nil), count]];
    [self.messagesSelectedCount sizeToFit];
    [self.messagesSelectedCount setFrameOrigin:NSMakePoint(roundf((self.actionsView.bounds.size.width - self.messagesSelectedCount.bounds.size.width) /2), roundf((self.actionsView.bounds.size.height - self.messagesSelectedCount.bounds.size.height)/2))];
    
}


@end
