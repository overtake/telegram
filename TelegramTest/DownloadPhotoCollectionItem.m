//
//  DownloadPhotoCollectionItem.m
//  Telegram
//
//  Created by keepcoder on 05.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DownloadPhotoCollectionItem.h"
#import "TLFileLocation+Extensions.h"
@implementation DownloadPhotoCollectionItem


-(id)initWithObject:(TL_fileLocation *)object size:(int)size {
    if(self = [super initWithObject:object size:size]) {
        self.path = [object squarePath];
    }
    return self;
}
@end
