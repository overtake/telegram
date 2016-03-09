//
//  TGPhotoViewerItem.m
//  Telegram
//
//  Created by keepcoder on 10.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGPhotoViewerItem.h"
#import "TGDateUtils.h"
@implementation TGPhotoViewerItem

-(id)initWithImageObject:(TGImageObject *)imageObject previewObject:(PreviewObject *)previewObject {
    if(self = [super init]) {
        _imageObject = imageObject;
        _previewObject = previewObject;
    }
    
    return self;
}

-(void)startDownload {
    
}

-(BOOL)isEqualTo:(TGPhotoViewerItem *)object {
    return self.previewObject.msg_id == object.previewObject.msg_id;
}

-(DownloadItem *)downloadItem {
    return self.imageObject.downloadItem;
}
-(BOOL)isset {
    return self.imageObject.isset;
}

@end
