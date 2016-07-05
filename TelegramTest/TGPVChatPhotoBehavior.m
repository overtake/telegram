//
//  TGPVChatPhotoBehavior.m
//  Telegram
//
//  Created by keepcoder on 18/05/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGPVChatPhotoBehavior.h"
#import "ChatPhotoHistoryFilter.h"
#import "TGPhotoViewerItem.h"
@interface TGPVChatPhotoBehavior () <MessagesDelegate>
@property (nonatomic,strong) PreviewObject *commonItem;
@end



@implementation TGPVChatPhotoBehavior

@synthesize conversation = _conversation;
@synthesize chat = _chat;
@synthesize request = _request;
@synthesize state = _state;
@synthesize totalCount = _totalCount;

@synthesize controller = _controller;




-(id)initWithConversation:(TL_conversation *)conversation commonItem:(PreviewObject *)object {
    
    if(self = [self initWithConversation:conversation commonItem:object filter:[ChatPhotoHistoryFilter class]]) {
        
    }
    
    return self;
}

-(id)initWithConversation:(TL_conversation *)conversation commonItem:(PreviewObject *)object filter:(Class)filter {
    if(self = [super init]) {
        _conversation = conversation;
        _controller = [[ChatHistoryController alloc] initWithController:self historyFilter:filter];
        _commonItem = object;

    }
    
    return self;
}

-(void)addItems:(NSArray *)items {
    
}

-(void)receivedMessage:(MessageTableItem *)message position:(int)position itsSelf:(BOOL)force {
    
}

-(void)deleteItems:(NSArray *)items orMessageIds:(NSArray *)ids {
    
}

-(void)flushMessages {
    
}

-(void)receivedMessageList:(NSArray *)list inRange:(NSRange)range itsSelf:(BOOL)force {
    
}

- (void)didAddIgnoredMessages:(NSArray *)items {
    
}

-(NSArray *)messageTableItemsFromMessages:(NSArray *)messages  {
    
    NSMutableArray *previewObjects = [NSMutableArray array];
    
    [messages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
        
        TLPhotoSize *photoSize = [obj.action.photo.sizes lastObject];
        
        if(![photoSize.location.cacheKey isEqualToString:[(TLPhotoSize *)_commonItem.media location].cacheKey]) {
            PreviewObject *preview = [[PreviewObject alloc] initWithMsdId:obj.action.photo.n_id media:photoSize peer_id:obj.peer_id];
            preview.reservedObject = obj;
            preview.date = obj.date;
            [previewObjects addObject:preview];
        } else {
            _commonItem.reservedObject = obj;
        }
        
    }];
    
    return previewObjects;
}

-(void)jumpToLastMessages:(BOOL)force {
    
}

-(TL_conversation *)conversation {
    return _conversation;
}

-(void)updateLoading {
    
}

-(void)load:(long)max_id next:(BOOL)next limit:(int)limit callback:(void (^)(NSArray *))callback {
    
    [_controller request:next anotherSource:YES sync:NO selectHandler:^(NSArray *result, NSRange range,HistoryFilter *filter) {
        
        [ASQueue dispatchOnStageQueue:^{
            callback(result);
        }];
        
    }];
    
    
}

-(void)removeItems:(NSArray *)items {
    
}

-(void)addItems {
    
}

-(int)totalCount {
    return [_controller itemsCount];
}

-(void)clear {
    [_request cancelRequest];
}

-(NSArray *)convertObjects:(NSArray *)list {
    NSMutableArray *converted = [[NSMutableArray alloc] init];
    
    [list enumerateObjectsUsingBlock:^(PreviewObject *obj, NSUInteger idx, BOOL *stop) {
        
        TL_photoSize *photoSize = (TL_photoSize *)obj.media;

        TGPVImageObject *imgObj = [[TGPVImageObject alloc] initWithLocation:photoSize.location placeHolder:obj.reservedObject sourceId:_conversation.peer_id size:photoSize.size];
        
        imgObj.imageSize = NSMakeSize([photoSize w], [photoSize h]);
        
        TGPhotoViewerItem *item = [[TGPhotoViewerItem alloc] initWithImageObject:imgObj previewObject:obj];
        
        [converted addObject:item];
        
    }];
    
    return converted;
}

-(void)dealloc {
    
}

@end
