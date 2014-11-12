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


-(void)load:(int)max_id callback:(void (^)(NSArray *))callback {
    
    if(_state == TGPVMediaBehaviorLoadingStateLocal) {
        [[Storage manager] media:^(NSArray *list) {
            
            
            if(self != nil) {
                [ASQueue dispatchOnStageQueue:^{
                    callback(list);
                    
                    if(list.count == 0)
                        _state = TGPVMediaBehaviorLoadingStateRemote;
                    
                }];
            }
           
            
          
            
        } max_id:max_id peer_id:_conversation.peer_id];
    } else if(_state == TGPVMediaBehaviorLoadingStateRemote) {
        
        [self loadRemote:max_id callback:callback];
        
    }
    
}


-(void)loadRemote:(int)max_id callback:(void (^)(NSArray *previewObjects))callback {
    
    [_request cancelRequest];
    
   _request = [RPCRequest sendRequest:[TLAPI_messages_search createWithPeer:_conversation.inputPeer q:@"" filter:[TL_inputMessagesFilterPhotos create] min_date:0 max_date:0 offset:0 max_id:max_id limit:100] successHandler:^(RPCRequest *request, id response) {
       
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
            TGPhoto *photo = [[obj media] media].photo;
            
            
            TGPhotoSize *photoSize = ((TGPhotoSize *)[photo.sizes lastObject]);
            
            TGImageObject *imgObj = [[TGImageObject alloc] initWithLocation:photoSize.location placeHolder:nil sourceId:_conversation.peer_id size:photoSize.size];
            
            TGPhotoViewerItem *item = [[TGPhotoViewerItem alloc] initWithImageObject:imgObj previewObject:obj];
            
            [converted addObject:item];
        } else {
            int i = 0;
        }
        
    }];
    
    return converted;
}

-(void)dealloc {
    
}


@end
