//
//  ImageSengerItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ImageAttachSenderItem.h"
#import "TGAttachObject.h"
#import "TGSendTypingManager.h"
#import "MessageTableItemPhoto.h"
@interface ImageAttachSenderItem ()

@property (nonatomic, strong) TGAttachObject *attach;

@end

@implementation ImageAttachSenderItem


-(id)initWithConversation:(TL_conversation *)conversation attachObject:(TGAttachObject *)attach additionFlags:(int)additionFlags {
    
    if(self = [super initWithConversation:conversation]) {
        
        _attach = attach;
        
       
        NSString *path =  attach.generatedPath;
        
       TL_photoCachedSize *size = [TL_photoCachedSize createWithType:@"x" location:[TL_fileLocation createWithDc_id:0 volume_id:rand_long() local_id:0 secret:0] w:attach.imageSize.width h:attach.imageSize.height bytes:attach.previewData];
        
        
        TL_photoSize *size1 = [TL_photoSize createWithType:@"x" location:size.location w:attach.imageSize.width h:attach.imageSize.height size:0];
        
        NSMutableArray *sizes = [[NSMutableArray alloc] init];
        
        [sizes addObject:size];
        [sizes addObject:size1];
        
        TL_messageMediaPhoto *photo = [TL_messageMediaPhoto createWithPhoto:[TL_photo createWithN_id:attach.unique_id access_hash:0 date:(int)[[MTNetwork instance] getTime] sizes:sizes] caption:attach.caption];
        
        
        [TGCache cacheImage:attach.image forKey:size.location.cacheKey groups:@[IMGCACHE]];
        
        self.message = [MessageSender createOutMessage:@"" media:photo conversation:conversation];
        
        if(additionFlags & (1 << 4))
            self.message.from_id = 0;

         [[NSFileManager defaultManager] copyItemAtPath:path toPath:mediaFilePath(self.message) error:nil];
        
        [self.message save:YES];
        
        
        
    }
    return self;
}

-(void)didEndUploading:(id)uploadedFile {
    
    _attach.uploader = nil;
    
    self.filePath = mediaFilePath(self.message);
    
    TLInputMedia *media;
    
    if([uploadedFile isKindOfClass:[TL_inputPhoto class]]) {
        media = [TL_inputMediaPhoto createWithN_id:uploadedFile caption:self.message.media.caption];
    } else {
        media = [TL_inputMediaUploadedPhoto createWithFile:uploadedFile caption:self.message.media.caption];
    }
    
    id request = nil;
    
    if(self.conversation.type == DialogTypeBroadcast) {
        request = [TLAPI_messages_sendBroadcast createWithContacts:[self.conversation.broadcast inputContacts] random_id:[self.conversation.broadcast generateRandomIds] message:@"" media:media];
    } else {
        request = [TLAPI_messages_sendMedia createWithFlags:[self senderFlags] peer:self.conversation.inputPeer reply_to_msg_id:self.message.reply_to_msg_id media:media random_id:self.message.randomId reply_markup:[TL_replyKeyboardMarkup createWithFlags:0 rows:[@[]mutableCopy]]] ;
    }
    
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
            
            
            [[Storage manager] setFileInfo:[TL_inputPhoto createWithN_id:msg.media.photo.n_id access_hash:msg.media.photo.access_hash] forPathHash:fileMD5(strongSelf.filePath)];
            
            if(strongSelf.conversation.type != DialogTypeBroadcast)  {
                strongSelf.message.n_id = msg.n_id;
                strongSelf.message.date = msg.date;
                
            }
            
            TLPhotoSize *newSize = [msg.media.photo.sizes lastObject];
            
            if(strongSelf.message.media.photo.sizes.count > 1) {
                TL_photoSize *size =strongSelf.message.media.photo.sizes[1];
                [TGCache changeKey:size.location.cacheKey withKey:newSize.location.cacheKey];
                size.location = newSize.location;
                
            } else {
                ((TL_localMessage *)strongSelf.message).media = msg.media;
            }
            
            // fix file location for download image after clearing cache.
            {
                MessageTableItemPhoto *item = (MessageTableItemPhoto *)strongSelf.tableItem;
                
                item.imageObject.location = newSize.location;
            }
            
            strongSelf.message.dstate = DeliveryStateNormal;
            
            [strongSelf.message save:YES];
            
            [[NSFileManager defaultManager] moveItemAtPath:strongSelf.filePath toPath:mediaFilePath(strongSelf.message) error:nil];
            
            
            [[NSFileManager defaultManager] removeItemAtPath:_attach.generatedPath error:nil];
            
            
            PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:strongSelf.message.n_id media:strongSelf.message peer_id:strongSelf.message.peer_id];
            
            [Notification perform:MEDIA_RECEIVE data:@{KEY_PREVIEW_OBJECT:previewObject}];
            
            
            strongSelf.state = MessageSendingStateSent;
        }
        
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        
        
        weakSelf.attach.uploader = nil;
        
        if([weakSelf checkErrorAndReUploadFile:error path:weakSelf.attach.generatedPath])
            return;
        
        weakSelf.state = MessageSendingStateError;
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
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
    
    
    id uploadedFile = [[Storage manager] fileInfoByPathHash:fileMD5(_attach.generatedPath)];
    
    if(!uploadedFile) {
        
        self.progress = ((float)_attach.uploader.readedBytes/(float)_attach.uploader.total_size) * 100.0f;
        
        [_attach.uploader setUploadComplete:^(UploadOperation *operation, id input) {
            
            [weakSelf didEndUploading:input];
            
        }];
        
        if(_attach.uploader.uploadState == UploadNoneState) {
            [_attach.uploader setFilePath:_attach.generatedPath];
            [_attach.uploader ready:UploadImageType];
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
