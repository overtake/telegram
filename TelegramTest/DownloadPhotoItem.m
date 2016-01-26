//
//  DownloadPhotoItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 13.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DownloadPhotoItem.h"
#import "FileUtils.h"
#import "TLFileLocation+Extensions.h"
@implementation DownloadPhotoItem



-(id)initWithObject:(TL_fileLocation *)object size:(int)size {
    if(self = [super initWithObject:object]) {
        
        if (!object) 
            return nil;
        self.isEncrypted = object.local_id == -1;
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
    if(self.isEncrypted)
        return [TL_inputEncryptedFileLocation createWithN_id:location.volume_id access_hash:location.secret];
    return [TL_inputFileLocation createWithVolume_id:location.volume_id local_id:location.local_id secret:location.secret];
}
@end
