//
//  PhotoTableItem.h
//  Telegram
//
//  Created by keepcoder on 04.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreviewObject.h"
#import "TGImageObject.h"
@interface PhotoTableItem : TMRowItem


@property (nonatomic,assign) NSSize size;

@property (nonatomic,strong) NSArray *previewObjects;

-(id)initWithPreviewObjects:(NSArray *)previewObjects;

@end
