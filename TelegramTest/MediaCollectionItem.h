//
//  MediaCollectionItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 08.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PreviewObject.h"

@interface MediaCollectionItem : NSObject
@property (nonatomic,strong) NSString *path;
@property (nonatomic,strong) NSImage *image;
@property (nonatomic,strong,readonly) PreviewObject *previewObject;
@property (nonatomic,assign,readonly) NSSize size;

@property (nonatomic,strong) id item;

@property (nonatomic,strong) NSCollectionView *collectionView;
-(id)initWithPreviewObject:(PreviewObject *)previewObject;

@end
