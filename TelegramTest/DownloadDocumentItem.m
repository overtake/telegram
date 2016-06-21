//
//  DownloadDocumentItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 13.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DownloadDocumentItem.h"
#import "FileUtils.h"
#import <AVFoundation/AVFoundation.h>
#import "MessageTableItemAudioDocument.h"
@implementation DownloadDocumentItem



-(id)initWithObject:(TL_localMessage *)object {
    if(self = [super initWithObject:object]) {
        self.isEncrypted = [object isKindOfClass:[TL_destructMessage class]];
        self.n_id = self.document.n_id;
        self.path =  [NSString stringWithFormat:@"%@/%lu.download",[SettingsArchiver documentsFolder],self.document.n_id];
        self.fileType = DownloadFileDocument;
        self.dc_id = self.document.dc_id;
        self.size =  self.document.size;
    }
    return self;
}

-(TL_document *)document {
    TL_localMessage *message = self.object;
    
    if([message.media isKindOfClass:[TL_messageMediaBotResult class]]) {
        return (TL_document *) message.media.bot_result.document;
    }
    
    return (TL_document *) message.media.document;
}

-(void)setDownloadState:(DownloadState)downloadState {
    if(self.downloadState != DownloadStateCompleted && downloadState == DownloadStateCompleted) {
       
        NSString *old_path = self.path;
        
        self.path = mediaFilePath(self.object);
        
        NSError *error = nil;
        
        [[NSFileManager defaultManager] moveItemAtPath:old_path toPath:self.path error:&error];
        
        if(![self.path isEqualToString:old_path] && error && error.code == 516) {
            [[NSFileManager defaultManager] removeItemAtPath:old_path error:&error];
        }
        
    }
    [super setDownloadState:downloadState];
}


-(TLInputFileLocation *)input {
    if(self.isEncrypted)
        return [TL_inputEncryptedFileLocation createWithN_id:self.document.n_id access_hash:self.document.access_hash];
    
    return [TL_inputDocumentFileLocation createWithN_id:self.document.n_id access_hash:self.document.access_hash];
}

@end


