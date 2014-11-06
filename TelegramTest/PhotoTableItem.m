//
//  PhotoTableItem.m
//  Telegram
//
//  Created by keepcoder on 04.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PhotoTableItem.h"

@implementation PhotoTableItem

-(id)initWithPreviewObjects:(NSArray *)previewObjects {
    if(self = [super init]) {
        _previewObjects = previewObjects;
    }
    
    return self;
}

-(NSUInteger)hash {
    if(_previewObjects.count > 0)
        return [(TGImageObject *)_previewObjects[0] sourceId];
    
    
    return 0;
}

@end
