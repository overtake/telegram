//
//  ImageSecretSenderItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 18.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "FileSecretSenderItem.h"
#import "ImageUtils.h"
#import "ImageCache.h"
#import "ImageStorage.h"
#import "NSMutableData+Extension.h"
#import "TLFileLocation+Extensions.h"
#import "TGOpusAudioPlayerAU.h"
#import "PreviewObject.h"
#import "SelfDestructionController.h"
#import "DeleteRandomMessagesSenderItem.h"
#import "TGCache.h"
#import "NSData+Extensions.h"
@interface FileSecretSenderItem ()
//@property (nonatomic,strong) NSImage *thumb;
//@property (nonatomic,strong) NSData *thumbData;
@property (nonatomic,assign) UploadType uploadType;
@property (nonatomic,strong) UploadOperation *uploader;
@property (nonatomic,strong) NSString *mimeType;

@property (nonatomic,strong) NSData *key;
@property (nonatomic,strong) NSData *iv;

@property (nonatomic,strong) id media;


@end

@implementation FileSecretSenderItem


-(void)setState:(MessageState)state {
    [super setState:state];
}

- (id)initWithImage:(NSImage *)image uploadType:(UploadType)uploadType forConversation:(TL_conversation *)conversation {
     if(self = [super initWithConversation:conversation]) {
        [self initializeWithImage:image filePath:nil uploadType:uploadType];
    }
    return self;
}

- (void)initializeWithImage:(NSImage *)image filePath:(NSString *)filePath uploadType:(UploadType)uploadType  {
    
    self.filePath = filePath;
    self.uploadType = uploadType;
    
    TLMessageMedia *media;
    
    int ttl = self.params.ttl;
    
    self.message = [TL_destructMessage createWithN_id:0 flags:TGOUTUNREADMESSAGE from_id:[UsersManager currentUserId] to_id:[TL_peerSecret createWithChat_id:self.conversation.peer.chat_id] date:[[MTNetwork instance] getTime] message:@"" media:media destruction_time:0 randomId:rand_long() fakeId:[MessageSender getFakeMessageId] ttl_seconds:ttl == -1 ? 0 : ttl out_seq_no:-1 dstate:DeliveryStatePending];
    
     self.mimeType = mimetypefromExtension([self.filePath pathExtension]);
    
    if(self.uploadType == UploadImageType) {
        
        image = prettysize(image);
        
         NSSize maxSize = strongsizeWithMinMax(image.size, MIN_IMG_SIZE.height, MIN_IMG_SIZE.width);
        
        NSImage *thumb = strongResize(image, 90);
        
        NSData *thumbData = compressImage(jpegNormalizedData(thumb), 0.1);
        
        NSSize origin = image.size;
        
        NSMutableArray *sizes = [[NSMutableArray alloc] init];
        
        
        TL_photoSize *photoSize = [TL_photoSize createWithType:@"x" location:[TL_fileLocation createWithDc_id:0 volume_id:rand_long() local_id:-1 secret:rand_long()] w:origin.width h:origin.height size:0];
        
        
        TL_photoCachedSize *cachedSize = [TL_photoCachedSize createWithType:@"x" location:photoSize.location w:thumb.size.width h:thumb.size.height bytes:thumbData];
        
        [sizes addObject:cachedSize];
        [sizes addObject:photoSize];
        
        media = [TL_messageMediaPhoto createWithPhoto:[TL_photo createWithN_id:self.uploader.identify access_hash:0 date:[[MTNetwork instance] getTime] sizes:sizes] caption:@""];
        
        
        [TGCache cacheImage:renderedImage(image, maxSize) forKey:photoSize.location.cacheKey groups:@[IMGCACHE]];
        
        [jpegNormalizedData(image) writeToFile:mediaFilePath(media) atomically:YES];
        
        self.message.media = media;
        
        [self.message save:YES];
        
    } else if( self.uploadType == UploadVideoType ) {
        NSDictionary *params = [MessageSender videoParams:self.filePath thumbSize:strongsize(NSMakeSize(640, 480), 90)];
        
        NSImage *thumb = [params objectForKey:@"image"];
        int duration = [[params objectForKey:@"duration"] intValue];
        NSSize size = NSSizeFromString([params objectForKey:@"size"]);
        
        
        NSData *imageData = [thumb TIFFRepresentation];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        NSNumber *compressionFactor = [NSNumber numberWithFloat:0.5];
        NSDictionary *imageProps = [NSDictionary dictionaryWithObject:compressionFactor
                                                               forKey:NSImageCompressionFactor];
        NSData *thumbData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
        
        TL_photoCachedSize *photoSize = [TL_photoCachedSize createWithType:@"x" location:[TL_fileLocation createWithDc_id:0 volume_id:rand_long() local_id:0 secret:0] w:image.size.width h:image.size.height bytes:thumbData];
        
        
        media = [TL_messageMediaVideo createWithVideo:[TL_video createWithN_id:self.uploader.identify access_hash:0 date:[[MTNetwork instance] getTime] duration:duration mime_type:self.mimeType size:0 thumb:photoSize dc_id:0 w:size.width h:size.height] caption:@""];
        
    } else if(self.uploadType == UploadDocumentType) {
        
        CGImageRef quickLookIcon = QLThumbnailImageCreate(NULL, (__bridge CFURLRef)[NSURL fileURLWithPath:self.filePath], CGSizeMake(90, 90), nil);
        
        NSData *thumbData;
        NSImage *thumb;
        if (quickLookIcon != NULL) {
          thumb = [[NSImage alloc] initWithCGImage:quickLookIcon size:NSMakeSize(0, 0)];
            CFRelease(quickLookIcon);
            
            thumbData = compressImage([ thumb TIFFRepresentation], 0.4);
        }
        
        TLPhotoSize *size = [TL_photoCachedSize createWithType:@"x" location:[TL_fileLocation createWithDc_id:0 volume_id:0 local_id:0 secret:0] w:thumb.size.width h:thumb.size.height bytes:thumbData];
        
        if(!thumbData) {
            size = [TL_photoSizeEmpty createWithType:@"x"];
        }
        
       
        
        
        
        media = [TL_messageMediaDocument createWithDocument:[TL_outDocument createWithN_id:rand_long() access_hash:0 date:[[MTNetwork instance] getTime] mime_type:self.mimeType size:(int)fileSize(self.filePath) thumb:size dc_id:0 file_path:self.filePath attributes:[@[[TL_documentAttributeFilename createWithFile_name:[filePath lastPathComponent]]] mutableCopy]]];
    } else if(self.uploadType == UploadAudioType) {
        
        NSTimeInterval duration = [TGOpusAudioPlayerAU durationFile:filePath];
        
        media = [TL_messageMediaAudio createWithAudio:[TL_audio createWithN_id:0 access_hash:0 date:(int)[[MTNetwork instance] getTime] duration:roundf(duration) mime_type:@"opus" size:(int)fileSize(filePath) dc_id:0]];
    }
    
    
   
    self.message.media = media;
    
    

}

- (id)initWithPath:(NSString *)filePath uploadType:(UploadType)uploadType forConversation:(TL_conversation *)conversation {
    if(self = [super initWithConversation:conversation]) {
        [self initializeWithImage:nil filePath:filePath uploadType:uploadType];
    }
    return self;
}


-(void)setMessage:(TL_localMessage *)message {
    [super setMessage:message];
    
    self.action = [[TGSecretAction alloc] initWithActionId:self.message.n_id chat_id:self.conversation.peer.peer_id decryptedData:[self deleteRandomMessageData] senderClass:[DeleteRandomMessagesSenderItem class] layer:self.params.layer];
    
    [self.action save];
}



-(NSData *)decryptedMessageLayer1 {
    return  [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageWithRandom_id:@(self.random_id) random_bytes:self.random_bytes message:@"" media:self.media]];
}

-(NSData *)decryptedMessageLayer17 {
    return [Secret17__Environment serializeObject:[Secret17_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(17) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret17_DecryptedMessage decryptedMessageWithRandom_id:@(self.message.randomId) ttl:@(((TL_destructMessage *)self.message).ttl_seconds) message:self.message.message media:self.media]]];
}

-(NSData *)decryptedMessageLayer20 {
    return [Secret20__Environment serializeObject:[Secret20_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(20) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret20_DecryptedMessage decryptedMessageWithRandom_id:@(self.message.randomId) ttl:@(((TL_destructMessage *)self.message).ttl_seconds) message:self.message.message media:self.media]]];
}

-(NSData *)decryptedMessageLayer23 {
    return [Secret23__Environment serializeObject:[Secret23_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(23) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret23_DecryptedMessage decryptedMessageWithRandom_id:@(self.message.randomId) ttl:@(((TL_destructMessage *)self.message).ttl_seconds) message:self.message.message media:self.media]]];
}

-(void)performRequest {
    
    self.uploader = [[UploadOperation alloc] init];
    self.key = [[NSMutableData alloc] initWithRandomBytes:32];
    self.iv = [[NSMutableData alloc] initWithRandomBytes:32];
    
   if(self.conversation.encryptedChat.encryptedParams.state != EncryptedAllowed)
        return;
    
    
    
    NSString *export;
    
    if([self.message.media isKindOfClass:[TL_messageMediaDocument class]]) {
        export = exportPath(self.message.randomId,[self.message.media.document.file_name pathExtension]);
    } else if([self.message.media isKindOfClass:[TL_messageMediaAudio class]]) {
        export = exportPath(self.message.randomId,@"mp3");
    } else if([self.message.media isKindOfClass:[TL_messageMediaPhoto class]]) {
        export = mediaFilePath(self.message.media);
    }
    
    
    
    if(!self.filePath)
        self.filePath = export;
    
    if(![self.filePath isEqualToString:export] && export) {
        [[NSFileManager defaultManager] copyItemAtPath:self.filePath toPath:export error:nil];
        self.filePath = export;
        [self.message save:YES];
    }
    
    
    
    weakify();
    [self.uploader setUploadComplete:^(UploadOperation *uploader,TL_inputEncryptedFile *inputFile) {
        
        
        if(strongSelf.uploadType == UploadImageType) {
            
            TL_photoCachedSize *size = strongSelf.message.media.photo.sizes[0];
            
            TL_photoSize *origin = [strongSelf.message.media.photo.sizes lastObject];
            
            
            if(strongSelf.params.layer == 1) {
                strongSelf.media = [Secret1_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:size.bytes thumb_w:@(size.w) thumb_h:@(size.h) w:@(origin.w) h:@(origin.h) size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
                
            } else if(strongSelf.params.layer == 17) {
                 strongSelf.media = [Secret17_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:size.bytes thumb_w:@(size.w) thumb_h:@(size.h) w:@(origin.w) h:@(origin.h) size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
            } else if(strongSelf.params.layer == 20) {
                strongSelf.media = [Secret20_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:size.bytes thumb_w:@(size.w) thumb_h:@(size.h) w:@(origin.w) h:@(origin.h) size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
            } else if(strongSelf.params.layer == 23) {
                strongSelf.media = [Secret23_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:size.bytes thumb_w:@(size.w) thumb_h:@(size.h) w:@(origin.w) h:@(origin.h) size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
            }
        }
    
        
        TL_destructMessage *msg = (TL_destructMessage *) strongSelf.message;
        
        if (strongSelf.uploadType == UploadVideoType) {
            if(strongSelf.params.layer == 1) {
                strongSelf.media = [Secret1_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb:msg.media.video.thumb.bytes thumb_w:@(msg.media.video.thumb.w) thumb_h:@(msg.media.video.thumb.h) duration:@(msg.media.video.duration) w:@(msg.media.video.w) h:@(msg.media.video.h) size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
                
            } else if(strongSelf.params.layer == 17) {
                strongSelf.media = [Secret17_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb:msg.media.video.thumb.bytes thumb_w:@(msg.media.video.thumb.w) thumb_h:@(msg.media.video.thumb.h) duration:@(msg.media.video.duration) mime_type:@"mp4" w:@(msg.media.video.w) h:@(msg.media.video.h) size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
            } else if(strongSelf.params.layer == 20) {
                strongSelf.media = [Secret20_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb:msg.media.video.thumb.bytes thumb_w:@(msg.media.video.thumb.w) thumb_h:@(msg.media.video.thumb.h) duration:@(msg.media.video.duration) mime_type:@"mp4" w:@(msg.media.video.w) h:@(msg.media.video.h) size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
            } else if(strongSelf.params.layer == 23) {
                strongSelf.media = [Secret23_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb:msg.media.video.thumb.bytes thumb_w:@(msg.media.video.thumb.w) thumb_h:@(msg.media.video.thumb.h) duration:@(msg.media.video.duration) mime_type:@"mp4" w:@(msg.media.video.w) h:@(msg.media.video.h) size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
            }
            
        }
        
        if(strongSelf.uploadType == UploadDocumentType) {
            if(strongSelf.params.layer == 1) {
                strongSelf.media = [Secret1_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:strongSelf.message.media.document.thumb.bytes thumb_w:@(msg.media.document.thumb.w) thumb_h:@(msg.media.document.thumb.h) file_name:[strongSelf.filePath lastPathComponent] mime_type:strongSelf.mimeType size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
                
            } else if(strongSelf.params.layer == 17) {
                strongSelf.media = [Secret17_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:strongSelf.message.media.document.thumb.bytes thumb_w:@(msg.media.document.thumb.w) thumb_h:@(msg.media.document.thumb.h) file_name:[strongSelf.filePath lastPathComponent] mime_type:strongSelf.mimeType size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
            } else if(strongSelf.params.layer == 20) {
                strongSelf.media = [Secret20_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:strongSelf.message.media.document.thumb.bytes thumb_w:@(msg.media.document.thumb.w) thumb_h:@(msg.media.document.thumb.h) file_name:[strongSelf.filePath lastPathComponent] mime_type:strongSelf.mimeType size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
            } else if(strongSelf.params.layer == 23) {
                strongSelf.media = [Secret23_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:strongSelf.message.media.document.thumb.bytes == nil ? [[NSData alloc] initWithEmptyBytes:16] : strongSelf.message.media.document.thumb.bytes thumb_w:@(msg.media.document.thumb.w) thumb_h:@(msg.media.document.thumb.h) file_name:[strongSelf.filePath lastPathComponent] mime_type:strongSelf.mimeType size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
            }
        }
        
        
        if(strongSelf.uploadType == UploadAudioType) {
            if(strongSelf.params.layer == 1) {
                strongSelf.media = [Secret1_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:@(msg.media.audio.duration) size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
                
            } else if(strongSelf.params.layer == 17) {
                strongSelf.media = [Secret17_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:@(msg.media.audio.duration) mime_type:@"opus" size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
            } else if(strongSelf.params.layer == 20) {
                strongSelf.media = [Secret20_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:@(msg.media.audio.duration) mime_type:@"opus" size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
            } else if(strongSelf.params.layer == 23) {
                strongSelf.media = [Secret23_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:@(msg.media.audio.duration) mime_type:@"opus" size:@(uploader.total_size) key:strongSelf.key iv:strongSelf.iv];
            }
        }
        
        
        TLAPI_messages_sendEncryptedFile *request = [TLAPI_messages_sendEncryptedFile createWithPeer:[TL_inputEncryptedChat createWithChat_id:strongSelf.action.chat_id access_hash:strongSelf.action.params.access_hash] random_id:((TL_destructMessage *)strongSelf.message).randomId data:[MessageSender getEncrypted:strongSelf.action.params  messageData:[strongSelf decryptedMessageLayer]] file:inputFile];
        
        
        
        strongSelf.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_sentEncryptedFile *response) {
            
            
            ((TL_destructMessage *)strongSelf.message).date = [response date];
            
            ((TL_destructMessage *)strongSelf.message).n_id = [MessageSender getFutureMessageId];
            
            
            TLPhotoSize *size = strongSelf.uploadType == UploadImageType ? [((TL_destructMessage *)strongSelf.message).media.photo.sizes objectAtIndex:0] : ((TL_destructMessage *)strongSelf.message).media.video.thumb;
            
            TLFileLocation *newLocation = [TL_fileLocation createWithDc_id:[response.file dc_id] volume_id:[response.file n_id] local_id:size.location.local_id secret:response.file.access_hash];
            
            
            [TGCache changeKey:size.location.cacheKey withKey:newLocation.cacheKey];
            
            [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                [transaction setObject:@{@"key":strongSelf.key,@"iv":strongSelf.iv} forKey:[NSString stringWithFormat:@"%lu",[response.file n_id]] inCollection:ENCRYPTED_IMAGE_COLLECTION];
            }];
            
            
            
            if(strongSelf.uploadType == UploadImageType) {
                [[((TL_destructMessage *)strongSelf.message).media.photo.sizes objectAtIndex:0] setLocation:newLocation];
                [[((TL_destructMessage *)strongSelf.message).media.photo.sizes objectAtIndex:1] setLocation:newLocation];
                
            }
            
            if(strongSelf.uploadType == UploadVideoType ) {
                [strongSelf.message media].video.access_hash = newLocation.secret;
                [strongSelf.message media].video.dc_id = newLocation.dc_id;
                [strongSelf.message media].video.n_id = newLocation.volume_id;
                [strongSelf.message media].video.size = uploader.total_size;
                
                [[NSFileManager defaultManager] moveItemAtPath:strongSelf.filePath toPath:mediaFilePath([strongSelf.message media]) error:nil];
                
            }
            
            if(strongSelf.uploadType == UploadDocumentType) {
                [strongSelf.message media].document.access_hash = newLocation.secret;
                [strongSelf.message media].document.dc_id = newLocation.dc_id;
                [strongSelf.message media].document.n_id = newLocation.volume_id;
                [strongSelf.message media].document.size = uploader.total_size;
                
                [[NSFileManager defaultManager] removeItemAtPath:exportPath(strongSelf.message.randomId,[strongSelf.message.media.document.file_name pathExtension]) error:nil];
            }
            
            if(strongSelf.uploadType == UploadAudioType) {
                [strongSelf.message media].audio.access_hash = newLocation.secret;
                [strongSelf.message media].audio.dc_id = newLocation.dc_id;
                [strongSelf.message media].audio.n_id = newLocation.volume_id;
                [strongSelf.message media].audio.size = uploader.total_size;
                
                [[NSFileManager defaultManager] moveItemAtPath:strongSelf.filePath toPath:mediaFilePath([strongSelf.message media]) error:nil];
                
            }
            
            
            
            strongSelf.uploader = nil;
            
            strongSelf.message.dstate = DeliveryStateNormal;
            [strongSelf.message save:YES];
            
            
            if(strongSelf.uploadType == UploadImageType) {
                NSImage *image  = imageFromFile(strongSelf.filePath);
                
                [[NSFileManager defaultManager] moveItemAtPath:strongSelf.filePath toPath:mediaFilePath(strongSelf.message.media) error:nil];
                
                [TGCache cacheImage:renderedImage(image, strongsizeWithMinMax(image.size, MIN_IMG_SIZE.height, MIN_IMG_SIZE.width)) forKey:newLocation.cacheKey groups:@[IMGCACHE]];
                
                
                PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:strongSelf.message.n_id media:strongSelf.message peer_id:strongSelf.message.peer_id];
                
                [Notification perform:MEDIA_RECEIVE data:@{KEY_PREVIEW_OBJECT:previewObject}];

            }
            
            
            strongSelf.state = MessageSendingStateSent;
            
 
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            strongSelf.state = MessageSendingStateError;
        }];
    }];
    
    [self.uploader setUploadProgress:^(UploadOperation *operation, NSUInteger current, NSUInteger total) {
        if(strongSelf.uploadType == UploadVideoType) {
            strongSelf.progress =VIDEO_COMPRESSED_PROGRESS + (((float)current/(float)total) * (100.0f - VIDEO_COMPRESSED_PROGRESS));
        } else {
            strongSelf.progress =  ((float)current/(float)total) * 100.0f;
        }
        
    }];

    if(self.uploadType == UploadVideoType) {
       [MessageSender compressVideo:self.filePath randomId:[self.message randomId] completeHandler:^(BOOL success, NSString *compressedPath) {
           
           self.filePath = compressedPath;
           
            [self.uploader setFilePath:compressedPath];
            [self.uploader encryptedready:self.uploadType key:self.key iv:self.iv];
                
            ((TL_destructMessage *)self.message).media.video.size = self.uploader.total_size;
           
            if(success)
                [self.message save:YES];
           
            self.state = self.state;
        } progressHandler:^(float progress) {
            self.progress = progress/1.0f * VIDEO_COMPRESSED_PROGRESS;
        
        }];
        
    } else {
        [self.uploader setFilePath:self.filePath];
        [self.uploader encryptedready:self.uploadType key:self.key iv:self.iv];
    }
    
}

-(void)setUploaderType:(UploadType)type {
    self.uploadType = type;
}

-(void)cancel {
    if(self.uploadType == UploadVideoType) {
        [[NSFileManager defaultManager] removeItemAtPath:self.uploader.filePath error:nil];
    }
    [self.uploader cancel];
    [super cancel];
}

@end
