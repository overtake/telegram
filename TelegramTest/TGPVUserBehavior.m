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
@synthesize totalCount = _totalCount;


static NSMutableDictionary *count;

-(id)init {
    if(self = [super init]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            count = [[NSMutableDictionary alloc] init];
        });
    }
    
    return self;
}


-(void)load:(long)max_id next:(BOOL)next limit:(int)limit callback:(void (^)(NSArray *))callback {
    
    if(self.state != TGPVMediaBehaviorLoadingStateFull && !_request) {
        
        __block NSMutableArray *converted = count[@(_user.n_id)];
        
        if(converted.count > 0) {
            
            if(callback) callback(converted.count > 0 ? [converted subarrayWithRange:NSMakeRange(1, converted.count - 1)] : @[]);
              _state = TGPVMediaBehaviorLoadingStateFull;
            return;
        }
        
        
        _request = [RPCRequest sendRequest:[TLAPI_photos_getUserPhotos createWithUser_id:_user.inputUser offset:0 max_id:0 limit:1000] successHandler:^(RPCRequest *request, TL_photos_photos *response) {
            
            converted = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < response.photos.count; i++) {
                
                
                TL_photo *photo = response.photos[i];
                
                PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:[photo n_id] media:[photo.sizes lastObject] peer_id:_user.n_id];
                
                previewObject.date = [(TL_photo *)response.photos[response.photos.count - i - 1] date];
                
                previewObject.access_hash = photo.access_hash;
                
                [converted addObject:previewObject];
            }
            
            _state = TGPVMediaBehaviorLoadingStateFull;
            
            count[@(_user.n_id)] = converted;
            
           
            if(callback) callback(converted.count > 0 ? [converted subarrayWithRange:NSMakeRange(1, converted.count - 1)] : @[]);
            
            
        } errorHandler:nil];
    }
    
    
}


-(void)removeItems:(NSArray *)items {
    NSMutableArray *converted = count[@(_user.n_id)];
    
    [converted removeObjectsInArray:items];
    
}

-(void)addItems:(NSArray *)items {
    NSMutableArray *converted = count[@(_user.n_id)];
    
    [converted insertObjects:items atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, items.count)]];
    
}

-(int)totalCount {
    return (int)[count[@(_user.n_id)] count] ;
}

-(NSArray *)convertObjects:(NSArray *)list {
    NSMutableArray *converted = [[NSMutableArray alloc] init];
    
    [list enumerateObjectsUsingBlock:^(PreviewObject *obj, NSUInteger idx, BOOL *stop) {
        
        
        if([obj.media isKindOfClass:[TL_photoSize class]]) {
            
            
            TGPVImageObject *imgObj = [[TGPVImageObject alloc] initWithLocation:[(TL_photoSize *)obj.media location] placeHolder:obj.reservedObject sourceId:_user.n_id size:0];
            
            imgObj.imageSize = NSMakeSize([(TL_photoSize *)obj.media w], [(TL_photoSize *)obj.media h]);
            
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
