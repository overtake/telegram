//
//  DocumentSenderItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DocumentSenderItem.h"
#import "ImageUtils.h"
#import "TGCache.h"
#import "TLFileLocation+Extensions.h"
#import "TGSendTypingManager.h"
#import "webp/decode.h"
#import "FileUtils.h"
#import "StickersPanelView.h"
#import <AVFoundation/AVFoundation.h>
#import "MessageTableItem.h"
@interface DocumentSenderItem ()

@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) UploadOperation *uploader;
@property (nonatomic, strong) UploadOperation *uploaderThumb;
@property (nonatomic) BOOL isThumbUploaded;
@property (nonatomic) BOOL isFileUploaded;

@property (nonatomic, strong) id inputFile;
@property (nonatomic, strong) id thumbFile;

@end

@implementation DocumentSenderItem

-(void)setState:(MessageState)state {
    [super setState:state];
}

- (id)initWithPath:(NSString *)path forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags caption:(NSString *)caption {
    if(self = [super init]) {
        self.mimeType = mimetypefromExtension([path pathExtension]);
        self.filePath = path;
        self.conversation = conversation;
        
        long randomId = rand_long();
        
        
        NSMutableArray *attrs = [[NSMutableArray alloc] init];
        
        
        
        TL_documentAttributeFilename *filenameAttr = [TL_documentAttributeFilename createWithFile_name:[self.filePath lastPathComponent]];
        
        [attrs addObject:filenameAttr];
        
        __block NSData *thumbData;
        __block NSImage *thumbImage;
        __block NSString *thumbName;
        
        
        
        if([_mimeType hasPrefix:@"audio/"]) {
            AVURLAsset* asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
            
            NSArray *k = [NSArray arrayWithObjects:@"commonMetadata", nil];
            
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            
            __block  NSImage *artworkImage;
            
            [asset loadValuesAsynchronouslyForKeys:k completionHandler: ^{
                NSArray *artworks = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                                   withKey:AVMetadataCommonKeyArtwork keySpace:AVMetadataKeySpaceCommon];
                
                for (AVMetadataItem *i in artworks)
                {
                    NSString *keySpace = i.keySpace;
                    NSImage *im = nil;
                    
                    id value;
                    if ([keySpace isEqualToString:AVMetadataKeySpaceID3])
                    {
                        value = i.value;
                    }
                    else if ([keySpace isEqualToString:AVMetadataKeySpaceiTunes]) {
                        value = i.value;
                    }
                    
                    if([value isKindOfClass:[NSDictionary class]]) {
                        value = [value objectForKey:@"data"];
                    }
                    
                    if([value isKindOfClass:[NSData class]]) {
                        value = value;
                    } else
                        value = nil;
                    
                    if(value)
                        im = [[NSImage alloc] initWithData:[value copyWithZone:nil]];
                    
                    
                    if (im)
                    {
                        artworkImage = im;
                    }
                }
                
                dispatch_semaphore_signal(sema);
                
                
            }];
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
            
            if(artworkImage)
            {
                thumbImage = strongResize(artworkImage, 90);
                thumbData = jpegNormalizedData(thumbImage);
                thumbName = @"cover.jpg";
            }
            
            NSDictionary *tags = audioTags(asset);
            
            NSString *songName = tags[@"songName"];
            NSString *artistName = tags[@"artist"];
            
            //[TL_documentAttributeAudio createWithDuration:CMTimeGetSeconds(asset.duration) title:songName performer:artistName]
            
            [attrs addObject:[TL_documentAttributeAudio createWithFlags:0 duration:CMTimeGetSeconds(asset.duration) title:songName performer:artistName waveform:nil]];
            
        }
        
        
        dispatch_block_t thumbBlock = ^ {
            if(!thumbImage) {
                thumbImage = previewImageForDocument(self.filePath);
                
                thumbData = jpegNormalizedData(thumbImage);
                thumbName = @"thumb.jpg";
            }
        };
        
        if([self.filePath hasSuffix:@"webp"] && fileSize(self.filePath) < 128000) {
            NSData *data = [[NSData alloc] initWithContentsOfFile:self.filePath];
            int width = 0;
            int heigth = 0;
            if (WebPGetInfo(data.bytes, data.length, &width, &heigth) && width > 100 & heigth > 100)
            {
                [attrs addObject:[TL_documentAttributeSticker createWithAlt:@"" stickerset:[TL_inputStickerSetEmpty create]]];
                [attrs addObject:[TL_documentAttributeImageSize createWithW:width h:heigth]];
                
                NSString *sp = [NSString stringWithFormat:@"%@/%ld.webp",[FileUtils path],randomId];
                
                [[NSFileManager defaultManager] copyItemAtPath:self.filePath toPath:sp error:nil];
                
                NSImage *sticker = [NSImage imageWithWebP:sp error:nil];
                
                [TGCache cacheImage:sticker forKey:[NSString stringWithFormat:@"s:%ld",randomId] groups:@[IMGCACHE]];
                
                thumbImage = strongResize(sticker, 128);
                
                thumbData = [NSImage convertToWebP:thumbImage quality:1.0 preset:WEBP_PRESET_ICON configBlock:^(WebPConfig *config) {
                    
                } error:nil];
                
                thumbName = @"thumb.webp";
                
            } else
                thumbBlock();
        } else
            thumbBlock();
        
        
        TLPhotoSize *size;
        if(thumbImage) {
            
            size = [TL_photoCachedSize createWithType:thumbName location:[TL_fileLocation createWithDc_id:0 volume_id:randomId local_id:0 secret:0] w:thumbImage.size.width h:thumbImage.size.height bytes:thumbData];
            
            [TGCache cacheImage:thumbImage forKey:size.location.cacheKey groups:@[IMGCACHE]];
            
        } else {
            size = [TL_photoSizeEmpty createWithType:thumbName];
        }
        
        TL_documentAttributeLocalFile *fileAttr = [TL_documentAttributeLocalFile createWithFile_path:path];
        
        [attrs addObject:fileAttr];
        
        TL_messageMediaDocument *document = [TL_messageMediaDocument createWithDocument:[TL_document createWithN_id:randomId access_hash:0 date:[[MTNetwork instance] getTime] mime_type:self.mimeType size:(int)fileSize(self.filePath) thumb:size dc_id:0 attributes:attrs] caption:caption];
        
        self.message = [MessageSender createOutMessage:@"" media:document conversation:conversation additionFlags:additionFlags];
        
    }
    
    return self;
}

- (id)initWithPath:(NSString *)path forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags {
    return [self initWithPath:path forConversation:conversation additionFlags:additionFlags caption:nil];
   
}



- (void)performRequest {
    
    TL_documentAttributeFilename *fileName = (TL_documentAttributeFilename *) [self.message.media.document attributeWithClass:[TL_documentAttributeFilename class]];
    
    NSString *export = exportPath(self.message.randomId,extensionForMimetype(self.message.media.document.mime_type));
    
    if(!self.filePath)
        self.filePath = export;
    
    if(![self.filePath isEqualToString:export]) {
        [[NSFileManager defaultManager] copyItemAtPath:self.filePath toPath:export error:nil];
        self.filePath = export;
        [self.message save:YES];
    }
    
    
    
    weak();
    self.uploader = [[UploadOperation alloc] init];
    [self.uploader setUploadComplete:^(UploadOperation *uploader, id input) {
        weakSelf.inputFile = input;
        weakSelf.isFileUploaded = YES;
        [weakSelf sendMessage];
    }];
    [self.uploader setUploadProgress:^(UploadOperation *operation, NSUInteger current, NSUInteger total) {
        weakSelf.progress = (float)current/ (float)total * 100.0f;
    }];
    
    [self.uploader setUploadTypingNeed:^(UploadOperation *operation) {
        [TGSendTypingManager addAction:[TL_sendMessageUploadDocumentAction createWithProgress:weakSelf.progress] forConversation:weakSelf.conversation];
    }];
    
    [self.uploader setUploadStarted:^(UploadOperation *operation, NSData *data) {
        [TGSendTypingManager addAction:[TL_sendMessageUploadDocumentAction createWithProgress:weakSelf.progress] forConversation:weakSelf.conversation];
    }];
    
    
    [self.uploader setFilePath:self.filePath];
    [self.uploader setFileName:fileName.file_name];
    [self.uploader ready:UploadDocumentType];
    
    TLPhotoSize *size = [self.message.media.document thumb];
    
    if([size isKindOfClass:[TL_photoCachedSize class]]) {
        self.uploaderThumb = [[UploadOperation alloc] init];
        
        [self.uploaderThumb setFileData:size.bytes];
        [self.uploaderThumb setUploadComplete:^(UploadOperation *tu, id inputThumb) {
            weakSelf.thumbFile = inputThumb;
            weakSelf.isThumbUploaded = YES;
            [weakSelf sendMessage];
        }];
        [self.uploaderThumb ready:UploadImageType];
        
    } else {
        self.isThumbUploaded = YES;
        [self sendMessage];
    }
    
}

- (void)sendMessage {
    if(!self.isFileUploaded || !self.isThumbUploaded)
        return;
    
    id media;
    
    __block BOOL isNewDocument = [self.inputFile isKindOfClass:[TLInputFile class]];
    
   
    if(isNewDocument) {
        if([self.thumbFile isKindOfClass:[TLInputFile class]]) {
            media = [TL_inputMediaUploadedThumbDocument createWithFile:self.inputFile thumb:self.thumbFile mime_type:self.message.media.document.mime_type attributes:[self.message.media.document.serverAttributes mutableCopy] caption:self.message.media.caption];
        } else {
            media = [TL_inputMediaUploadedDocument createWithFile:self.inputFile mime_type:self.message.media.document.mime_type attributes:[self.message.media.document.serverAttributes mutableCopy] caption:self.message.media.caption];
        }
    } else {
        TLDocument *document = (TLDocument *)self.inputFile;
        media = [TL_inputMediaDocument createWithN_id:[TL_inputDocument createWithN_id:document.n_id access_hash:document.access_hash] caption:self.message.media.caption];
    }
    
    
    id request = nil;
    
    request = [TLAPI_messages_sendMedia createWithFlags:[self senderFlags] peer:self.conversation.inputPeer reply_to_msg_id:self.message.reply_to_msg_id media:media random_id:self.message.randomId  reply_markup:[TL_replyKeyboardMarkup createWithFlags:0 rows:[@[]mutableCopy]]];
    
    
    weak();
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TLUpdates *response) {
        
        strongWeak();
        
        if(strongSelf != nil) {
            [strongSelf updateMessageId:response];
            
            TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[[strongSelf updateNewMessageWithUpdates:response] message]];
            
            if(msg == nil)
            {
                [strongSelf cancel];
                return;
            }
            
            strongSelf.message.n_id = msg.n_id;
            strongSelf.message.date = msg.date;
            
            
            TL_localMessage *message = strongSelf.message;
            
            if(isNewDocument) {
                message.media.document.thumb = [msg media].document.thumb;
                message.media.document.thumb.bytes = nil;
            }
            
            
            
            if([self.message.media.document.mime_type hasSuffix:@"webp"]) {
                NSString *sp = [NSString stringWithFormat:@"%@/%ld.webp",[FileUtils path],message.media.document.n_id];
                
                NSString *np = [NSString stringWithFormat:@"%@/%ld.webp",[FileUtils path],[msg media].document.n_id];
                
                [[NSFileManager defaultManager] moveItemAtPath:sp toPath:np error:nil];
                
                [TGCache changeKey:[NSString stringWithFormat:@"s:%ld",message.media.document.n_id] withKey:[NSString stringWithFormat:@"s:%ld",[msg media].document.n_id]];
            }
            
            
            
            message.n_id = msg.n_id;
            message.date = msg.date;
            
            message.media.document.dc_id = [msg media].document.dc_id;
            message.media.document.size = [msg media].document.size;
            message.media.document.access_hash = [msg media].document.access_hash;
            message.media.document.n_id = [msg media].document.n_id;
            
            if([message.media.document isKindOfClass:[TL_compressDocument class]]) {
                message.media = [msg media];
            }
            
            strongSelf.tableItem.message.media = message.media;
            
            
            NSString *ep = exportPath(self.message.randomId,extensionForMimetype(self.message.media.document.mime_type));
            
            if([[NSFileManager defaultManager] fileExistsAtPath:ep isDirectory:NULL]) {
                [[NSFileManager defaultManager] moveItemAtPath:ep toPath:mediaFilePath(self.message) error:nil];
            }
            
            
            if(![message.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
                
                [message.media.document.thumb.bytes writeToFile:[message.media.document.thumb.location path] atomically:NO];
            }
            
            
            self.uploader = nil;
            self.uploaderThumb = nil;
            
            message.dstate = DeliveryStateNormal;
            
            [self.message save:YES];
            
            strongSelf.state = MessageSendingStateSent;
            
            
            strongSelf = nil;
        }
        
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        strongWeak();
        
        if(strongSelf != nil) {
            strongSelf.uploader = nil;
            
            if([strongSelf checkErrorAndReUploadFile:error path:strongSelf.filePath])
                return;
            
            strongSelf.state = MessageSendingStateError;
            
            strongSelf = nil;
        }
        
        
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
}

-(void)cancel {
    [self.uploader cancel];
    [self.uploaderThumb cancel];
    [super cancel];
}

@end
