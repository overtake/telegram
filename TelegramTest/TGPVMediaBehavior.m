//
//  TGPVMediaBehavior.m
//  Telegram
//
//  Created by keepcoder on 11.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGPVMediaBehavior.h"
#import "TGPhotoViewer.h"
@implementation TGPVMediaBehavior

@synthesize conversation = _conversation;
@synthesize user = _user;
@synthesize request = _request;
@synthesize state = _state;
@synthesize totalCount = _totalCount;

-(void)load:(long)max_id next:(BOOL)next limit:(int)limit callback:(void (^)(NSArray *))callback {
    
    if(_state == TGPVMediaBehaviorLoadingStateLocal) {
       
        [[Storage manager] media:^(NSArray *list) {
            
            
            if(self != nil) {
                [ASQueue dispatchOnStageQueue:^{
                    callback(list);
                    
                    if(list.count == 0 && next)
                        _state = _conversation.type == DialogTypeSecretChat ? TGPVMediaBehaviorLoadingStateFull : TGPVMediaBehaviorLoadingStateRemote;
                    
                }];
            }
       
        } max_id:max_id peer_id:_conversation.peer_id next:next limit:limit];
        
    } else if(_state == TGPVMediaBehaviorLoadingStateRemote) {
        
        [self loadRemote:max_id limit:limit callback:callback];
        
    }
    
}

-(void)removeItems:(NSArray *)items {
    
}

-(void)addItems {
    
}

-(int)totalCount {
    return [[Storage manager] countOfMedia:_conversation.peer_id];
}


-(void)loadRemote:(long)max_id limit:(int)limit callback:(void (^)(NSArray *previewObjects))callback {
    
    [_request cancelRequest];
    
   _request = [RPCRequest sendRequest:[TLAPI_messages_search createWithPeer:_conversation.inputPeer q:@"" filter:[TL_inputMessagesFilterPhotoVideo create] min_date:0 max_date:0 offset:0 max_id:(int)max_id limit:limit] successHandler:^(RPCRequest *request, id response) {
       
       if(self == nil)
           return;
       
       
        NSMutableArray *messages = [response messages];
        
       [TL_localMessage convertReceivedMessages:messages];
       
        NSMutableArray *previewObjects = [[NSMutableArray alloc] init];
       
        
        [messages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
            
            if(![obj isKindOfClass:[TL_messageEmpty class]]) {
                PreviewObject *preview = [[PreviewObject alloc] initWithMsdId:obj.n_id media:obj peer_id:obj.peer_id];
                
                [[Storage manager] insertMedia:obj];
                
                [previewObjects addObject:preview];
            }
        }];
       
       if(messages.count == 0)
           _state = TGPVMediaBehaviorLoadingStateFull;
       
       _request = nil;
       
        if(callback)
            callback(previewObjects);
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        _request = nil;
      
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
}


-(void)clear {
    [_request cancelRequest];
}

-(NSArray *)convertObjects:(NSArray *)list {
    NSMutableArray *converted = [[NSMutableArray alloc] init];
    
    [list enumerateObjectsUsingBlock:^(PreviewObject *obj, NSUInteger idx, BOOL *stop) {
        
        
        if([[obj.media media] isKindOfClass:[TL_messageMediaPhoto class]]) {
            TLPhoto *photo = [[obj media] media].photo;
            
            
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

-(BOOL)isReversedContentView {
    return [Telegram rightViewController].navigationViewController.currentController != [Telegram rightViewController].collectionViewController;
}


@end
