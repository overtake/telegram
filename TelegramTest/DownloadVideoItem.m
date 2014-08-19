//
//  DownloadVideoItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 13.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DownloadVideoItem.h"
#import "FileUtils.h"
@implementation DownloadVideoItem



-(id)initWithObject:(TGMessage *)object {
    if(self = [super initWithObject:object]) {
        self.isEncrypted = [object isKindOfClass:[TL_destructMessage class]];
        self.n_id = object.media.video.n_id;
        self.path = mediaFilePath(object.media);
        self.fileType = DownloadFileVideo;
        self.dc_id = object.media.video.dc_id;
        self.size = object.media.video.size;
    }
    return self;
}


-(TGInputFileLocation *)input {
    TGMessage *message = [self object];
    if(self.isEncrypted)
        return [TL_inputEncryptedFileLocation createWithN_id:self.n_id access_hash:message.media.video.access_hash];
    return [TL_inputVideoFileLocation createWithN_id:self.n_id access_hash:message.media.video.access_hash];
}


@end
