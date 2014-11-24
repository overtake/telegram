//
//  DownloadAudioItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 14.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DownloadAudioItem.h"
#import "FileUtils.h"
@implementation DownloadAudioItem

-(id)initWithObject:(TLMessage *)object {
    if(self = [super initWithObject:object]) {
        self.isEncrypted = [object isKindOfClass:[TL_destructMessage class]];
        self.n_id = object.media.audio.n_id;
        self.path = mediaFilePath(object.media);
        self.fileType = DownloadFileAudio;
        self.dc_id = object.media.audio.dc_id;
        self.size = object.media.audio.size;
    }
    return self;
}

-(TLInputFileLocation *)input {
    TLMessage *message = self.object;
    if(self.isEncrypted)
        return [TL_inputEncryptedFileLocation createWithN_id:message.media.audio.n_id access_hash:message.media.audio.access_hash];
    
    return [TL_inputAudioFileLocation createWithN_id:message.media.audio.n_id access_hash:message.media.audio.access_hash];
}

@end
