//
//  TGPVMediaBehavior.m
//  Telegram
//
//  Created by keepcoder on 11.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGPVMediaBehavior.h"
#import "TGPhotoViewer.h"
#import "ChatHistoryController.h"
#import "PhotoHistoryFilter.h"
#import "MessageTableItem.h"
@interface TGPVMediaBehavior () <MessagesDelegate>

@end

@implementation TGPVMediaBehavior

@synthesize conversation = _conversation;
@synthesize user = _user;
@synthesize request = _request;
@synthesize state = _state;
@synthesize totalCount = _totalCount;

@synthesize controller = _controller;


-(id)initWithConversation:(TL_conversation *)conversation commonItem:(PreviewObject *)object {
    
    if(self = [super init]) {
        _conversation = conversation;
        _controller = [[ChatHistoryController alloc] initWithController:self historyFilter:[PhotoHistoryFilter class]];
        
        if(object != nil)
            [_controller addItemWithoutSavingState:[[self messageTableItemsFromMessages:@[object.media]] firstObject]];
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
    return [MessageTableItem messageTableItemsFromMessages:messages];
}

-(void)jumpToLastMessages:(BOOL)force {
    
}

-(TL_conversation *)conversation {
    return _conversation;
}

-(void)updateLoading {
    
}

-(void)load:(long)max_id next:(BOOL)next limit:(int)limit callback:(void (^)(NSArray *))callback {
    
    
    [_controller request:next anotherSource:YES sync:NO selectHandler:^(NSArray *result, NSRange range) {
        
        NSMutableArray * previewObjects = [NSMutableArray array];
        
        [result enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
            
            PreviewObject *preview = [[PreviewObject alloc] initWithMsdId:obj.message.n_id media:obj.message peer_id:obj.message.peer_id];
            
            [previewObjects addObject:preview];
        }];
        
        [ASQueue dispatchOnStageQueue:^{
            callback(previewObjects);
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
        
        
        if([[(TL_localMessage *)obj.media media] isKindOfClass:[TL_messageMediaPhoto class]]) {
            TLPhoto *photo = [((TL_localMessage *)[obj media]) media].photo;
            
            
            TL_photoSize *photoSize = ((TL_photoSize *)[photo.sizes lastObject]);
            
            
            NSImage *thumb;
            
            if(photo.sizes.count > 0) {
                TL_photoCachedSize *cached = photo.sizes[0];
                thumb = [[NSImage alloc] initWithData:cached.bytes];
            }
           
            
            TGPVImageObject *imgObj = [[TGPVImageObject alloc] initWithLocation:photoSize.location placeHolder:obj.reservedObject ? obj.reservedObject : thumb sourceId:_conversation.peer_id size:photoSize.size];
            
            imgObj.imageSize = NSMakeSize([photoSize w], [photoSize h]);
            
            TGPhotoViewerItem *item = [[TGPhotoViewerItem alloc] initWithImageObject:imgObj previewObject:obj];
            
            [converted addObject:item];
        }
        
    }];
    
    return converted;
}

-(void)dealloc {
    
}


@end
