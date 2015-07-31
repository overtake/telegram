//
//  TMMediaUserPictureController.m
//  Messenger for Telegram
//
//  Created by keepcoder on 12.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMMediaUserPictureController.h"
#import "TLPeer+Extensions.h"
#include <set>
#include <map>

@interface TMMediaUserPictureController ()



@property (nonatomic) std::map<NSUInteger, bool> *listCacheHash;

@property (nonatomic,strong) TLUser *user;

@end

@implementation TMMediaUserPictureController

@synthesize user = _user;

+(TMMediaUserPictureController *)controller {
    static TMMediaUserPictureController *controller;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[TMMediaUserPictureController alloc] init];
        controller.listCacheHash = new std::map<NSUInteger, bool>();
     //   [Notification addObserver:controller selector:@selector(didChangeUserPicture:) name:USER_UPDATE_PHOTO];
    });
    return controller;
}

-(void)didChangeUserPicture:(NSNotification *)notification {
    
    PreviewObject *object = [notification.userInfo objectForKey:KEY_PREVIEW_OBJECT];
    BOOL previous = [[notification.userInfo objectForKey:KEY_PREVIOUS] boolValue];
    
    
    
    TMPreviewUserPicture *item = [self convert:object];
    
    if(!item) return;
    
    
    if(_user.n_id == object.peerId) {
        if(previous) {
            if(self->items.count > 0)
                [self->items removeObjectAtIndex:0];
        } else {
            if(![self isExist:item in:self->items]) {
                [self->items insertObject:item atIndex:0];
            }
        }
        NSInteger currentIndex = self.panel.currentPreviewItemIndex+1;
        [self reloadData:currentIndex];
    } else {
        NSMutableArray *list = [self media:object.peerId];
        if(previous) {
            if(list.count > 0)
                [list removeObjectAtIndex:0];
        } else {
            if(![self isExist:item in:list])
                [list insertObject:item atIndex:0];
        }
        
    }
    
}

- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <TMPreviewItem>)item {
    
    NSImageView * reserved = [item previewObject].reservedObject;
    
    if(!reserved || reserved.visibleRect.size.height <= 0)
        return NSZeroRect;
    
    NSRect viewFrameInWindowCoords = [reserved convertRect:reserved.bounds toView:nil];
    return [[NSApp mainWindow] convertRectToScreen:viewFrameInWindowCoords];
}

-(id)previewPanel:(QLPreviewPanel *)panel transitionImageForPreviewItem:(id<TMPreviewItem>)item contentRect:(NSRect *)contentRect {
    
    
    
    return [[item previewObject].reservedObject image];
}

- (bool) initialized:(NSUInteger)peer_id {
    std::map<NSUInteger, bool>::iterator it = _listCacheHash->find(peer_id);
    if(it != self.listCacheHash->end())
        return it->second;
    return false;
}

- (BOOL)remoteLoad:(TL_conversation *)conversation completionHandler:(void (^)(NSArray *))completionHandler {
    return NO;
}


-(void)prepare:(TLUser *)user completionHandler:(dispatch_block_t)completionHandler {

    
    if(user == nil) {
        self->items = [[NSMutableArray alloc] init];
    }
    
    _user = user;
    
    if(![self initialized:_user.n_id] && _user) {
        
        [RPCRequest sendRequest:[TLAPI_photos_getUserPhotos createWithUser_id:_user.inputUser offset:1 max_id:0 limit:1000] successHandler:^(RPCRequest *request, TL_photos_photos *response) {
            
            NSMutableArray *media = [self media:_user.n_id];
            [media removeAllObjects];
            
            for (int i = 0; i < response.photos.count; i++) {
                
                TL_photo *photo = response.photos[i];
                
                PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:(int)[@([photo n_id]) hash] media:((TL_photoSize *)[photo.sizes lastObject]).location peer_id:_user.n_id];
                
                id<TMPreviewItem> item = [self convert:previewObject];
                
                if(!item) continue;
                
                [media addObject:item];
            }
            self->items = media;
            _listCacheHash->insert(std::pair<NSUInteger, bool>(_user.n_id, true));
            
            if(completionHandler) completionHandler();
            
        
        } errorHandler:nil];
        
    } else {
        self->items = [self media:_user.n_id];
        if(completionHandler) completionHandler();
    }

}





-(id<TMPreviewItem>)convert:(PreviewObject *)from {
    if( [from.media isKindOfClass:[TL_fileLocation class]]) {
        return [[TMPreviewUserPicture alloc] initWithItem:from];
    }
    
    
    
    return nil;
}

-(void)saveItem:(TMPreviewUserPicture *)item {
 //   [[Storage manager] insertUserProfilePhoto:_user.n_id media:[item previewObject].media];
}

@end
