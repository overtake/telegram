//
//  TGPVUserBehavior.m
//  Telegram
//
//  Created by keepcoder on 12.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGPVUserBehavior.h"
#import "TGPhotoViewer.h"
@implementation TGPVUserBehavior


@synthesize conversation = _conversation;
@synthesize user = _user;
@synthesize request = _request;
@synthesize state = _state;



-(void)load:(int)max_id callback:(void (^)(NSArray *))callback {
    
    if(self.state != TGPVMediaBehaviorLoadingStateFull && !_request) {
        _request = [RPCRequest sendRequest:[TLAPI_photos_getUserPhotos createWithUser_id:_user.inputUser offset:1 max_id:0 limit:1000] successHandler:^(RPCRequest *request, TL_photos_photos *response) {
            
            NSMutableArray *converted = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < response.photos.count; i++) {
                
                TL_photo *photo = response.photos[i];
                
                PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:(int)[@([photo n_id]) hash] media:((TL_photoSize *)[photo.sizes lastObject]).location peer_id:_user.n_id];
                
                [converted addObject:previewObject];
            }
            
            self.state = TGPVMediaBehaviorLoadingStateFull;
            
            if(callback) callback(converted);
            
            
        } errorHandler:nil];
    }
    
    
}


-(NSArray *)convertObjects:(NSArray *)list {
    NSMutableArray *converted = [[NSMutableArray alloc] init];
    
    [list enumerateObjectsUsingBlock:^(PreviewObject *obj, NSUInteger idx, BOOL *stop) {
        
        
        if([[obj.media media] isKindOfClass:[TL_fileLocation class]]) {
            
            
            TGImageObject *imgObj = [[TGImageObject alloc] initWithLocation:obj.media placeHolder:nil sourceId:_user.n_id size:0];
            
            TGPhotoViewerItem *item = [[TGPhotoViewerItem alloc] initWithImageObject:imgObj previewObject:obj];
            
            [converted addObject:item];
        }
        
    }];
    
    return converted;
}

-(void)clear {
    [_request cancelRequest];
    _request = nil;
}


@end
