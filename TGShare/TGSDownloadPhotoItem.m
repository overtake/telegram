//
//  TGSDownloadPhotoItem.m
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSDownloadPhotoItem.h"
#import "TLFileLocation+Extensions.h"
@implementation TGSDownloadPhotoItem


-(id)initWithObject:(TL_fileLocation *)object size:(int)size {
    if(self = [super initWithObject:object]) {
        
        if (!object)
            return nil;
        
        self.isEncrypted = NO;
        self.path = [object path];
        self.fileType = DownloadFileImage;
        self.size = size;
        self.dc_id = object.dc_id;
        self.n_id = self.isEncrypted ? object.volume_id : object.secret;
        
    }
    return self;
}




-(TLInputFileLocation *)input {
    TL_fileLocation *location = self.object;
    return [TL_inputFileLocation createWithVolume_id:location.volume_id local_id:location.local_id secret:location.secret];
}

@end
