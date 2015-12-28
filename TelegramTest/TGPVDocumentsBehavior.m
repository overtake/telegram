//
//  TGPVDocumentsBehavior.m
//  Telegram
//
//  Created by keepcoder on 23.10.15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGPVDocumentsBehavior.h"
#import "TGPhotoViewerItem.h"
#import "TGPVDocumentObject.h"
#import "DocumentHistoryFilter.h"
#import "MessageTableItem.h"
@interface TGPVDocumentsBehavior () <MessagesDelegate>

@end

@implementation TGPVDocumentsBehavior
@synthesize conversation = _conversation;
@synthesize user = _user;
@synthesize request = _request;
@synthesize state = _state;
@synthesize totalCount = _totalCount;

@synthesize controller = _controller;


-(id)initWithConversation:(TL_conversation *)conversation commonItem:(PreviewObject *)object {
    
    if(self = [super init]) {
        _conversation = conversation;
        _controller = [[ChatHistoryController alloc] initWithController:self historyFilter:[DocumentHistoryFilter class]];
        
        if(object != nil)
            [_controller addMessageWithoutSavingState:object.media];
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
        
        PreviewObject *preview = [[PreviewObject alloc] initWithMsdId:obj.n_id media:obj peer_id:obj.peer_id];
        
        [previewObjects addObject:preview];
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
    return [[Storage manager] countOfMedia:_conversation.peer_id];
}


-(void)clear {
    [_request cancelRequest];
}

-(NSArray *)convertObjects:(NSArray *)list {
    NSMutableArray *converted = [[NSMutableArray alloc] init];
    
    [list enumerateObjectsUsingBlock:^(PreviewObject *obj, NSUInteger idx, BOOL *stop) {
        
        
        if([obj.media isKindOfClass:[TLPhotoSize class]]) {
            
            TGPVImageObject *imgObj = [[TGPVImageObject alloc] initWithLocation:[(TL_photoSize *)obj.media location] placeHolder:obj.reservedObject sourceId:_user.n_id size:0];
            
            imgObj.imageSize = NSMakeSize([(TL_photoSize *)obj.media w], [(TL_photoSize *)obj.media h]);
            
            TGPhotoViewerItem *item = [[TGPhotoViewerItem alloc] initWithImageObject:imgObj previewObject:obj];
            
            [converted addObject:item];
        } else if([[(TL_localMessage *)obj.media media] isKindOfClass:[TL_messageMediaDocument class]]) {
            
            TL_messageMediaDocument *media = (TL_messageMediaDocument *) [(TL_localMessage *)obj.media media];
            
            if([media.document.mime_type hasPrefix:@"image"] && ![media.document.mime_type hasSuffix:@"gif"]) {
                TL_documentAttributeImageSize *size = (TL_documentAttributeImageSize *) [[media document] attributeWithClass:[TL_documentAttributeImageSize class]];
                
                TGPVDocumentObject *imgObj = [[TGPVDocumentObject alloc] initWithMessage:obj.media placeholder:nil];
                
                if(size) {
                    imgObj.imageSize = NSMakeSize(size.w, size.h);
                } else {
                    if(imgObj.placeholder.size.width == 0) {
                        imgObj.imageSize = NSMakeSize(500, 500);
                    }
                }
                
                TGPhotoViewerItem *item = [[TGPhotoViewerItem alloc] initWithImageObject:imgObj previewObject:obj];
                [converted addObject:item];
            }
        }
        
    }];
    
    return converted;
}

-(void)dealloc {
    
}



@end
