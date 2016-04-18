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
#import "TGVideoViewerItem.h"
#import "TGExternalImageObject.h"
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
        
        TL_localMessage *message = obj.media;
        
        if([obj.media isKindOfClass:[TLPhotoSize class]]) {
            
            TGPVImageObject *imgObj = [[TGPVImageObject alloc] initWithLocation:[(TL_photoSize *)obj.media location] placeHolder:obj.reservedObject sourceId:_user.n_id size:0];
            
            imgObj.imageSize = NSMakeSize([(TL_photoSize *)obj.media w], [(TL_photoSize *)obj.media h]);
            
            TGPhotoViewerItem *item = [[[obj.reservedObject isKindOfClass:[NSDictionary class]] ? TGVideoViewerItem.class : TGPhotoViewerItem.class alloc] initWithImageObject:imgObj previewObject:obj];
            
            
            
            [converted addObject:item];
        } else if([message.media isKindOfClass:[TL_messageMediaDocument class]] || [message.media isKindOfClass:[TL_messageMediaDocument_old44 class]]) {
            
            TL_documentAttributeVideo *video = (TL_documentAttributeVideo *) [message.media.document attributeWithClass:[TL_documentAttributeVideo class]];
            
            id item;
            
            if(video) {
                TGPVImageObject *imgObj = [[TGPVImageObject alloc] initWithLocation:message.media.document.thumb.location thumbData:nil size:message.media.document.thumb.size];
                
                imgObj.imageSize = NSMakeSize(video.w, video.h);
                
                imgObj.imageProcessor = [ImageUtils b_processor];
                
                item = [[TGVideoViewerItem alloc] initWithImageObject:imgObj previewObject:obj];

            } else {
                TGPVDocumentObject *imgObj = [[TGPVDocumentObject alloc] initWithMessage:obj.media placeholder:[[NSImage alloc] initWithContentsOfFile:mediaFilePath(obj.media)]];
                
                item = [[TGPhotoViewerItem alloc] initWithImageObject:imgObj previewObject:obj];
                
            }
            
            if(item)
                [converted addObject:item];
            
            
        } else if([message.media isKindOfClass:[TL_messageMediaBotResult class]]) {
            
            id item;
            
            if([message.media.bot_result.type isEqualToString:kBotInlineTypeVideo]) {
                
                TGExternalImageObject *imgObj = [[TGExternalImageObject alloc] initWithURL:message.media.bot_result.thumb_url];
                
                imgObj.imageSize = NSMakeSize(MAX(640,message.media.bot_result.w), MAX(480,message.media.bot_result.h));
                
                imgObj.imageProcessor = [ImageUtils b_processor];
                
                item = [[TGVideoViewerItem alloc] initWithImageObject:imgObj previewObject:obj];
            }
            
            if(item)
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
