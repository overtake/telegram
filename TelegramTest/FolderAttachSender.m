//
//  FolderAttachSender.m
//  Telegram
//
//  Created by keepcoder on 02/09/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "FolderAttachSender.h"
#import "TGAttachFolder.h"
#import "TGSendTypingManager.h"
@interface FolderAttachSender ()
@property (nonatomic, strong) TGAttachObject *attach;
@end

@implementation FolderAttachSender
-(id)initWithConversation:(TL_conversation *)conversation attachObject:(TGAttachFolder *)attach additionFlags:(int)additionFlags {
    if(self = [super initWithConversation:conversation]) {
        
        _attach = attach;
        
        NSMutableArray *attrs = [NSMutableArray array];
        
        TL_documentAttributeLocalFile *fileAttr = [TL_documentAttributeLocalFile createWithFile_path:attach.generatedPath];
        TL_documentAttributeFilename *fileName = [TL_documentAttributeFilename createWithFile_name:[attach.file lastPathComponent]];
        
        [attrs addObject:fileAttr];
        [attrs addObject:fileName];
        
        TL_messageMediaDocument *document = [TL_messageMediaDocument createWithDocument:[TL_document createWithN_id:rand_long() access_hash:0 date:[[MTNetwork instance] getTime] mime_type:mimetypefromExtension([fileAttr.file_path pathExtension]) size:(int)fileSize(fileAttr.file_path) thumb:[TL_photoSizeEmpty createWithType:@""] dc_id:0 version:0 attributes:attrs] caption:attach.caption];
        
        TL_localMessage *message = [MessageSender createOutMessage:@"" media:document conversation:conversation additionFlags:additionFlags];;
        message.randomId = attach.unique_id;

        self.message = message;
        [self.message save:YES];
        
    }
    
    return self;
}

-(NSString *)path {
    TL_documentAttributeLocalFile *fileAttr = (TL_documentAttributeLocalFile *) [self.message.media.document attributeWithClass:[TL_documentAttributeLocalFile class]];
    return fileAttr.file_path;
}

-(void)didEndUploading:(id)inputFile {
    
    _attach.uploader = nil;

    
    
    
    id media;
    
    __block BOOL isNewDocument = [inputFile isKindOfClass:[TLInputFile class]];
    
    
    if(isNewDocument) {
        media = [TL_inputMediaUploadedDocument createWithFile:inputFile mime_type:self.message.media.document.mime_type attributes:[self.message.media.document.serverAttributes mutableCopy] caption:self.message.media.caption];
    } else {
        TLDocument *document = (TLDocument *)inputFile;
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
            
            
            
            message.n_id = msg.n_id;
            message.date = msg.date;
            
            message.media.document.dc_id = [msg media].document.dc_id;
            message.media.document.size = [msg media].document.size;
            message.media.document.access_hash = [msg media].document.access_hash;
            message.media.document.n_id = [msg media].document.n_id;
            
            if([message.media.document isKindOfClass:[TL_compressDocument class]]) {
                message.media = [msg media];
            }
            
            strongSelf.message.media = message.media;
            
            
            NSString *ep = exportPath(strongSelf.message.randomId,extensionForMimetype(strongSelf.message.media.document.mime_type));
            
            if([[NSFileManager defaultManager] fileExistsAtPath:ep isDirectory:NULL]) {
                [[NSFileManager defaultManager] moveItemAtPath:ep toPath:mediaFilePath(strongSelf.message) error:nil];
            }
            
            
            if(![message.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
                
                [message.media.document.thumb.bytes writeToFile:[message.media.document.thumb.location path] atomically:NO];
            }
            
            
            
            message.dstate = DeliveryStateNormal;
            
            [strongSelf.message save:YES];
            
            strongSelf.state = MessageSendingStateSent;
            
            
            strongSelf = nil;
        }
        
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        strongWeak();
        
        if(strongSelf != nil) {
            if([strongSelf checkErrorAndReUploadFile:error path:strongSelf.filePath])
                return;
            
            strongSelf.state = MessageSendingStateError;
            
            strongSelf = nil;
        }
        
        
    } timeout:0 queue:[ASQueue globalQueue]._dispatch_queue];
}

-(void)performRequest {
    
    
    weak();
    
    self.progress = 0;
    
    if(!_attach.uploader) {
        
        _attach.uploader = [[UploadOperation alloc] init];
    }
    
    
    
    [_attach.uploader setUploadProgress:^(UploadOperation *operation, NSUInteger current, NSUInteger total) {
        weakSelf.progress = ((float)current/(float)total) * 100.0f;
    }];
    
    [_attach.uploader setUploadTypingNeed:^(UploadOperation *operation) {
        [TGSendTypingManager addAction:[TL_sendMessageUploadPhotoAction createWithProgress:weakSelf.progress] forConversation:weakSelf.conversation];
    }];
    
    [_attach.uploader setUploadStarted:^(UploadOperation *operation, NSData *data) {
        [TGSendTypingManager addAction:[TL_sendMessageUploadPhotoAction createWithProgress:weakSelf.progress] forConversation:weakSelf.conversation];
    }];
    
    
    id uploadedFile = [[Storage manager] fileInfoByPathHash:fileMD5(self.path)];
    
    if(!uploadedFile) {
        
        self.progress = ((float)_attach.uploader.readedBytes/(float)_attach.uploader.total_size) * 100.0f;
        
        [_attach.uploader setUploadComplete:^(UploadOperation *operation, id input) {
            
            [weakSelf didEndUploading:input];
            
        }];
        
        if(_attach.uploader.uploadState == UploadNoneState) {
            [_attach.uploader setFilePath:self.path];
            [_attach.uploader ready:UploadDocumentType];
        }
        
    } else {
        
        [self didEndUploading:uploadedFile];
    }
    
}


-(void)cancel {
    [_attach.uploader cancel];
    _attach.uploader = nil;
    [super cancel];
}

-(void)dealloc {
    [_attach.uploader cancel];
    _attach.uploader = nil;
}


@end
