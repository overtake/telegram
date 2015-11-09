//
//  TGPVChatBehavior.m
//  Telegram
//
//  Created by keepcoder on 13.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGPVEmptyBehavior.h"
#import "TGPhotoViewer.h"
#import "TGPVDocumentObject.h"

@implementation TGPVEmptyBehavior
@synthesize conversation = _conversation;
@synthesize user = _user;
@synthesize request = _request;
@synthesize state = _state;
@synthesize totalCount = _totalCount;

-(void)load:(long)max_id next:(BOOL)next limit:(int)limit callback:(void (^)(NSArray *))callback {
    
    if(callback)
        callback(@[]);
    
    
}

-(void)clear {
    
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
            
            
            TGPVDocumentObject *imgObj = [[TGPVDocumentObject alloc] initWithMessage:obj.media placeholder:[[NSImage alloc] initWithContentsOfFile:mediaFilePath([(TL_localMessage *)obj.media media])]];
            
            
            TGPhotoViewerItem *item = [[TGPhotoViewerItem alloc] initWithImageObject:imgObj previewObject:obj];
            [converted addObject:item];
        }
        
    }];
    
    return converted;
}

-(void)removeItems:(NSArray *)items {
    
}

-(void)addItems {
    
}

-(int)totalCount {
    return 1;
}



@end
