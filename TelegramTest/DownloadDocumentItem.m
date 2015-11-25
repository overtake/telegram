//
//  DownloadDocumentItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 13.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DownloadDocumentItem.h"
#import "FileUtils.h"
#import "ImageCache.h"
#import <AVFoundation/AVFoundation.h>
#import "MessageTableItemAudioDocument.h"
@implementation DownloadDocumentItem



-(id)initWithObject:(TLMessage *)object {
    if(self = [super initWithObject:object]) {
        self.isEncrypted = [object isKindOfClass:[TL_destructMessage class]];
        self.n_id = object.media.document.n_id;
        self.path = [NSString stringWithFormat:@"%@/%lu.download",[SettingsArchiver documentsFolder],object.media.document.n_id];
        self.fileType = DownloadFileDocument;
        self.dc_id = object.media.document.dc_id;
        self.size = object.media.document.size;
    }
    return self;
}

-(void)setDownloadState:(DownloadState)downloadState {
    if(self.downloadState != DownloadStateCompleted && downloadState == DownloadStateCompleted) {
        NSString *old_path = self.path;
        
        
        self.path = mediaFilePath([(TL_localMessage *)self.object media]);
        
        NSError *error = nil;
        
        [[NSFileManager defaultManager] moveItemAtPath:old_path toPath:self.path error:&error];
        
        if(![self.path isEqualToString:old_path] && error && error.code == 516) {
            [[NSFileManager defaultManager] removeItemAtPath:old_path error:&error];
        }
        
        TL_outDocument *document = [TL_outDocument outWithDocument:(TL_document *)((TLMessageMedia *)[(TL_localMessage *)self.object media]).document file_path:self.path];
        
        
         TL_documentAttributeAudio *attr = (TL_documentAttributeAudio *) [document attributeWithClass:[TL_documentAttributeAudio class]];
        
        if(attr && !attr.performer.length == 0 && attr.title.length == 0) {
            
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:self.path]];
            NSDictionary *tags = audioTags(asset);
            
            attr.title = tags[@"songName"];
            attr.performer = tags[@"artist"];
            
        }
        
        ((TLMessageMedia *)[(TL_localMessage *)self.object media]).document = document;
        
        [(TL_localMessage *)self.object save:NO];
        
    }
    [super setDownloadState:downloadState];
}


-(TLInputFileLocation *)input {
    TLMessage *message = self.object;
    if(self.isEncrypted)
        return [TL_inputEncryptedFileLocation createWithN_id:message.media.document.n_id access_hash:message.media.document.access_hash];
    
    return [TL_inputDocumentFileLocation createWithN_id:message.media.document.n_id access_hash:message.media.document.access_hash];
}

@end

/*
 
 
 
 */
