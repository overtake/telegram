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
#import "EmojiViewController.h"
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

- (id)initWithPath:(NSString *)path forConversation:(TL_conversation *)conversation {
    
    if(self = [super init]) {
        self.mimeType = [FileUtils mimetypefromExtension:[path pathExtension]];
        self.filePath = path;
        self.conversation = conversation;
        
        self.mimeType = [FileUtils mimetypefromExtension:[path pathExtension]];
        
        long randomId = rand_long();
        
        
        NSMutableArray *attrs = [[NSMutableArray alloc] init];
        
        [attrs addObject:[TL_documentAttributeFilename createWithFile_name:[self.filePath lastPathComponent]]];
        
        __block NSData *thumbData;
        __block NSImage *thumbImage;
        __block NSString *thumbName;
        
        dispatch_block_t thumbBlock = ^ {
            thumbImage = previewImageForDocument(self.filePath);
            thumbData = jpegNormalizedData(thumbImage);
            thumbName = @"thumb.jpg";
        };
        
        if([self.filePath hasSuffix:@"webp"] && fileSize(self.filePath) < 128000) {
            NSData *data = [[NSData alloc] initWithContentsOfFile:self.filePath];
            int width = 0;
            int heigth = 0;
            if (WebPGetInfo(data.bytes, data.length, &width, &heigth) && width > 200 & heigth > 200)
            {
                [attrs addObject:[TL_documentAttributeSticker create]];
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
        
        
        
        TL_messageMediaDocument *document = [TL_messageMediaDocument createWithDocument:[TL_outDocument createWithN_id:randomId access_hash:0 date:[[MTNetwork instance] getTime] mime_type:self.mimeType size:(int)fileSize(self.filePath) thumb:size dc_id:0 file_path:self.filePath attributes:attrs]];
        
        self.message = [MessageSender createOutMessage:@"" media:document dialog:conversation];
        
    }
    
    return self;
}



- (void)performRequest {
    
    NSString *export = exportPath(self.message.randomId,[self.message.media.document.file_name pathExtension]);
    
    if(!self.filePath)
        self.filePath = export;
    
    if(![self.filePath isEqualToString:export]) {
        [[NSFileManager defaultManager] copyItemAtPath:self.filePath toPath:export error:nil];
        self.filePath = export;
        [self.message save:YES];
    }
    
    
    
    weakify();
    self.uploader = [[UploadOperation alloc] init];
    [self.uploader setUploadComplete:^(UploadOperation *uploader, id input) {
        strongSelf.inputFile = input;
        strongSelf.isFileUploaded = YES;
        [strongSelf sendMessage];
    }];
    [self.uploader setUploadProgress:^(UploadOperation *operation, NSUInteger current, NSUInteger total) {
        strongSelf.progress = (float)current/ (float)total * 100.0f;
    }];
    
    [self.uploader setUploadTypingNeed:^(UploadOperation *operation) {
        [TGSendTypingManager addAction:[TL_sendMessageUploadDocumentAction create] forConversation:strongSelf.conversation];
    }];
    
    [self.uploader setUploadStarted:^(UploadOperation *operation, NSData *data) {
        [TGSendTypingManager addAction:[TL_sendMessageUploadDocumentAction create] forConversation:strongSelf.conversation];
    }];
    
    
    [self.uploader setFilePath:self.filePath];
    [self.uploader setFileName:self.message.media.document.file_name];
    [self.uploader ready:UploadDocumentType];
    
    TLPhotoSize *size = [self.message.media.document thumb];
    
    if([size isKindOfClass:[TL_photoCachedSize class]]) {
        self.uploaderThumb = [[UploadOperation alloc] init];
        
        [self.uploaderThumb setFileData:size.bytes];
        [self.uploaderThumb setFileName:size.type];
        [self.uploaderThumb setUploadComplete:^(UploadOperation *tu, id inputThumb) {
            strongSelf.thumbFile = inputThumb;
            strongSelf.isThumbUploaded = YES;
            [strongSelf sendMessage];
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
            media = [TL_inputMediaUploadedThumbDocument createWithFile:self.inputFile thumb:self.thumbFile mime_type:self.mimeType attributes:self.message.media.document.attributes];
        } else {
            media = [TL_inputMediaUploadedDocument createWithFile:self.inputFile mime_type:self.mimeType attributes:self.message.media.document.attributes];
        }
    } else {
        TLDocument *document = (TLDocument *)self.inputFile;
        media = [TL_inputMediaDocument createWithN_id:[TL_inputDocument createWithN_id:document.n_id access_hash:document.access_hash]];
    }
    
    
    id request = nil;
    
    if(self.conversation.type == DialogTypeBroadcast) {
        request = [TLAPI_messages_sendBroadcast createWithContacts:[self.conversation.broadcast inputContacts] message:@"" media:media];
    } else {
        request = [TLAPI_messages_sendMedia createWithPeer:self.conversation.inputPeer media:media random_id:rand_long()];
    }
    
    
    weakify();
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_statedMessage *obj) {
        
        
        [SharedManager proccessGlobalResponse:obj];
        
        TLMessage *msg;
        
        if(strongSelf.conversation.type != DialogTypeBroadcast)  {
            msg = [obj message];
        } else {
            TL_messages_statedMessages *stated = (TL_messages_statedMessages *) obj;
            [Notification perform:MESSAGE_LIST_RECEIVE data:@{KEY_MESSAGE_LIST:stated.messages}];
            [Notification perform:MESSAGE_LIST_UPDATE_TOP data:@{KEY_MESSAGE_LIST:stated.messages,@"update_real_date":@(YES)}];
            
            msg = stated.messages[0];
            
        }
        
        
        TL_localMessage *message = strongSelf.message;
        
        if(isNewDocument) {
            [strongSelf.uploader saveFileInfo:msg.media.document];
            id thumb = [msg media].document.thumb;
            if(![thumb isKindOfClass:[TL_photoSizeEmpty class]] && thumb) {
                [strongSelf.uploaderThumb saveFileInfo:[TL_photoEmpty createWithN_id:0]];
            }
            
            
            message.media.document.thumb = [msg media].document.thumb;
            message.media.document.thumb.bytes = nil;
        }

        [[NSFileManager defaultManager] removeItemAtPath:exportPath(self.message.randomId,[self.message.media.document.file_name pathExtension]) error:nil];
        
        
        NSString *sp = [NSString stringWithFormat:@"%@/%ld.webp",[FileUtils path],message.media.document.n_id];
        
        NSString *np = [NSString stringWithFormat:@"%@/%ld.webp",[FileUtils path],[msg media].document.n_id];
        
        [[NSFileManager defaultManager] moveItemAtPath:sp toPath:np error:nil];
        
        [TGCache changeKey:[NSString stringWithFormat:@"s:%ld",message.media.document.n_id] withKey:[NSString stringWithFormat:@"s:%ld",[msg media].document.n_id]];
       
        message.n_id = msg.n_id;
        message.date = msg.date;
        message.dstate = DeliveryStateNormal;
        message.media.document.dc_id = [msg media].document.dc_id;
        message.media.document.size = [msg media].document.size;
        message.media.document.access_hash = [msg media].document.access_hash;
        message.media.document.n_id = [msg media].document.n_id;
    
        
      
        
        
        
        
        if(![message.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
           
            [message.media.document.thumb.bytes writeToFile:locationFilePath(message.media.document.thumb.location, @"tiff") atomically:NO];
        }
        
        
        if(message.media.document.isSticker) {
            [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                
                NSArray *stickers = [transaction objectForKey:@"localStickers" inCollection:STICKERS_COLLECTION];
                
                if(!stickers)
                    stickers = @[];
                
                NSMutableArray *deserialized = [[NSMutableArray alloc] init];
                
                BOOL needSave = YES;
                
                for (int i = 0; i < stickers.count; i++) {
                    [deserialized addObject:[TLClassStore deserialize:stickers[i]]];
                    
                    TLDocument *doc = deserialized[i];
                    
                    if(doc.n_id == message.media.document.n_id)
                        needSave = NO;
                }
                
                
                if(needSave) {
                    
                    stickers = [stickers arrayByAddingObject:[TLClassStore serialize:self.message.media.document]];
                    
                    [transaction setObject:stickers forKey:@"localStickers" inCollection:STICKERS_COLLECTION];
                    
                }
                
                
                
            }];
            
            [EmojiViewController reloadStickers];
            
        }
        
        
        
        
        self.uploader = nil;
        self.uploaderThumb = nil;
        
        self.message.dstate = DeliveryStateNormal;
        
        [self.message save:YES];
            
        strongSelf.state = MessageSendingStateSent;
      
       
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        strongSelf.state = MessageSendingStateError;
    }];
}

-(void)cancel {
    [self.uploader cancel];
    [self.uploaderThumb cancel];
    [super cancel];
}

@end
