//
//  TGPhotoViewerItem.h
//  Telegram
//
//  Created by keepcoder on 10.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGImageObject.h"
@interface TGPhotoViewerItem : NSObject

@property (nonatomic,strong,readonly) TGImageObject *imageObject;
@property (nonatomic,strong,readonly) PreviewObject *previewObject;
@property (nonatomic,strong,readonly) NSString *stringDate;
-(id)initWithImageObject:(TGImageObject *)imageObject previewObject:(PreviewObject *)previewObject;

@end
