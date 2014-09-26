//
//  DocumentSenderItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DocumentSenderItem.h"
#import "ImageUtils.h"
#import "ImageCache.h"
@interface DocumentSenderItem ()

@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) UploadOperation *uploader;
@property (nonatomic, strong) UploadOperation *uploaderThumb;
@property (nonatomic, strong) NSImage *thumbImage;
@property (nonatomic, strong) NSData *thumbData;

@property (nonatomic) BOOL isThumbUploaded;
@property (nonatomic) BOOL isFileUploaded;

@property (nonatomic, strong) id inputFile;
@property (nonatomic, strong) id thumbFile;

@end

@implementation DocumentSenderItem

-(void)setState:(MessageState)state {
    [super setState:state];
}

- (id)initWithPath:(NSString *)path forDialog:(TL_conversation *)dialog {
    
    if(self = [super init]) {
        self.mimeType = [FileUtils mimetypefromExtension:[path pathExtension]];
        self.filePath = path;
        self.dialog = dialog;
        
        
        self.thumbImage = previewImageForDocument(self.filePath);
        
        long randomId = rand_long();
        
        TGPhotoSize *size;
        if(self.thumbImage) {
            self.thumbData = [self.thumbImage TIFFRepresentation];
            
            NSSize realSize = strongsize(self.thumbImage.size, 90);
            
            size = [TL_photoCachedSize createWithType:@"x" location:[TL_fileLocation createWithDc_id:0 volume_id:randomId local_id:0 secret:0] w:realSize.width h:realSize.height bytes:self.thumbData];
            
            [[ImageCache sharedManager] setImage:self.thumbImage forLocation:size.location];
            
        } else {
            size = [TL_photoSizeEmpty createWithType:@"x"];
        }
        
        TL_messageMediaDocument *document = [TL_messageMediaDocument createWithDocument:[TL_outDocument createWithN_id:randomId access_hash:0 user_id:UsersManager.currentUserId date:[[MTNetwork instance] getTime] file_name:[self.filePath lastPathComponent] mime_type:self.mimeType size:(int)fileSize(self.filePath) thumb:size dc_id:0 file_path:self.filePath]];
        
        self.message = [MessageSender createOutMessage:@"" media:document dialog:dialog];
        
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
    [self.uploader setFilePath:self.filePath];
    [self.uploader setFileName:self.message.media.document.file_name];
    [self.uploader ready:UploadDocumentType];
    
    TGPhotoSize *size = [self.message.media.document thumb];
    
    if([size isKindOfClass:[TL_photoCachedSize class]]) {
        self.uploaderThumb = [[UploadOperation alloc] init];
        
        NSData *data = [strongResize([[NSImage alloc] initWithData:size.bytes], IS_RETINA ? 45 : 90) TIFFRepresentation];
    
        [self.uploaderThumb setFileData:compressImage(data, 0.4)];
        [self.uploaderThumb setFileName:@"thumb.jpg"];
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
    
    __block BOOL isNewDocument = [self.inputFile isKindOfClass:[TGInputFile class]];
    
    if(isNewDocument) {
        if([self.thumbFile isKindOfClass:[TGInputFile class]]) {
            media = [TL_inputMediaUploadedThumbDocument createWithFile:self.inputFile thumb:self.thumbFile file_name:self.uploader.fileName mime_type:self.mimeType];
        } else {
            media = [TL_inputMediaUploadedDocument createWithFile:self.inputFile file_name:self.uploader.fileName mime_type:self.mimeType];
        }
    } else {
        TGDocument *document = (TGDocument *)self.inputFile;
        media = [TL_inputMediaDocument createWithDocument_id:[TL_inputDocument createWithN_id:document.n_id access_hash:document.access_hash]];
    }
    
    
    id request = nil;
    
    if(self.dialog.type == DialogTypeBroadcast) {
        request = [TLAPI_messages_sendBroadcast createWithContacts:[self.dialog.broadcast inputContacts] message:@"" media:media];
    } else {
        request = [TLAPI_messages_sendMedia createWithPeer:self.dialog.inputPeer media:media random_id:rand_long()];
    }
    
    
 
    weakify();
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_statedMessage *obj) {
        
        
        [SharedManager proccessGlobalResponse:obj];
        
        TGMessage *msg;
        
        
        if(strongSelf.dialog.type != DialogTypeBroadcast)  {
            msg = [obj message];
            strongSelf.message.n_id = [obj message].n_id;
            strongSelf.message.date = [obj message].date;
            
        } else {
            TL_messages_statedMessages *stated = (TL_messages_statedMessages *) obj;
            [Notification perform:MESSAGE_LIST_RECEIVE data:@{KEY_MESSAGE_LIST:stated.messages}];
            [Notification perform:MESSAGE_LIST_UPDATE_TOP data:@{KEY_MESSAGE_LIST:stated.messages,@"update_real_date":@(YES)}];
            
            msg = stated.messages[0];
            
        }
        
        
        
        
        if(isNewDocument) {
            [strongSelf.uploader saveFileInfo:msg.media.document];
            id thumb = [msg media].document.thumb;
            if(![thumb isKindOfClass:[TL_photoSizeEmpty class]] && thumb) {
                [strongSelf.uploaderThumb saveFileInfo:[TL_photoEmpty createWithN_id:0]];
            }
        }

        [[NSFileManager defaultManager] removeItemAtPath:exportPath(self.message.randomId,[self.message.media.document.file_name pathExtension]) error:nil];
        
        TL_localMessage *message = strongSelf.message;
        message.n_id = msg.n_id;
        message.date = msg.date;
        message.dstate = DeliveryStateNormal;
        message.media.document.dc_id = [msg media].document.dc_id;
        message.media.document.size = [msg media].document.size;
        message.media.document.access_hash = [msg media].document.access_hash;
        message.media.document.n_id = [msg media].document.n_id;
    
        message.media.document.thumb = [msg media].document.thumb;
        message.media.document.thumb.bytes = nil;
        
        if(![message.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
           
            [self.thumbData writeToFile:locationFilePath(message.media.document.thumb.location, @"tiff") atomically:NO];
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
