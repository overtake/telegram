//
//  ImageSengerItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ImageSenderItem.h"
#import "ImageCache.h"
#import "ImageStorage.h"
#import "FileUtils.h"
#import "ImageUtils.h"
#import "PreviewObject.h"
#import "TGCache.h"
#import "TLFileLocation+Extensions.h"
#import "TGSendTypingManager.h"
#import "TGTimer.h"
@interface ImageSenderItem ()
@property (nonatomic, strong) UploadOperation *uploadOperation;
@property (nonatomic, strong) NSImage *image;
@end

@implementation ImageSenderItem

-(void)setState:(MessageState)state {
    [super setState:state];
}

- (id)initWithImage:(NSImage *)image jpegData:(NSData *)jpegData forConversation:(TL_conversation *)conversation {
    if(self = [super init]) {
        
        self.conversation = conversation;
       
        
        
        
        image = prettysize(image);
        
        NSSize realSize = image.size;
        NSSize maxSize = strongsize(realSize, 250);
        
        
        if(realSize.width < 50 || realSize.height < 50)
            self.image = [ImageUtils imageResize:image newSize:NSMakeSize(MAX(100,realSize.width), MAX(100,realSize.height))];
        else
            self.image = image;
        
        if(realSize.width > MIN_IMG_SIZE.width && realSize.height > MIN_IMG_SIZE.height && maxSize.width == MIN_IMG_SIZE.width && maxSize.height == MIN_IMG_SIZE.height) {
            
            int difference = roundf( (realSize.width - maxSize.width) /2);
            
            image = cropImage(image,maxSize, NSMakePoint(difference, 0));
            
        }
        
        NSImage *rendered = renderedImage(image, maxSize);
        
        NSData *preview = compressImage(jpegNormalizedData(rendered), 0.1);
        
        
        TL_photoCachedSize *size = [TL_photoCachedSize createWithType:@"x" location:[TL_fileLocation createWithDc_id:0 volume_id:rand_long() local_id:0 secret:0] w:realSize.width h:realSize.height bytes:preview];
        
       
        
        TL_photoSize *size1 = [TL_photoSize createWithType:@"x" location:size.location w:realSize.width h:realSize.height size:0];
        
        NSMutableArray *sizes = [[NSMutableArray alloc] init];
        
        [sizes addObject:size];
        [sizes addObject:size1];

        TL_messageMediaPhoto *photo = [TL_messageMediaPhoto createWithPhoto:[TL_photo createWithN_id:0 access_hash:0 user_id:0 date:(int)[[MTNetwork instance] getTime] caption:@"photo" geo:[TL_geoPointEmpty create] sizes:sizes]];
        
        
        [TGCache cacheImage:rendered forKey:size.location.cacheKey groups:@[IMGCACHE]];
      
        self.message = [MessageSender createOutMessage:@"" media:photo dialog:conversation];
        
        [jpegData writeToFile:mediaFilePath(self.message.media) atomically:YES];
        [self.message save:YES];
        
        
        
    }
    return self;
}

-(void)performRequest {
    
    self.uploadOperation = [[UploadOperation alloc] init];
    
    self.filePath = mediaFilePath(self.message.media);
    
    weakify();
    
    [self.uploadOperation setUploadComplete:^(UploadOperation *operation, id input) {
        
    
        
        __block BOOL isFirstSend = [input isKindOfClass:[TLInputFile class]];
        
        id media = nil;
        if(isFirstSend) {
            media = [TL_inputMediaUploadedPhoto createWithFile:input];
        } else {
            TLPhoto *photo = input;
            media = [TL_inputMediaPhoto createWithN_id:[TL_inputPhoto createWithN_id:photo.n_id access_hash:photo.access_hash]];
        }
        
        
        id request = nil;
        
        if(strongSelf.conversation.type == DialogTypeBroadcast) {
            request = [TLAPI_messages_sendBroadcast createWithContacts:[strongSelf.conversation.broadcast inputContacts] message:@"" media:media];
        } else {
            request = [TLAPI_messages_sendMedia createWithPeer:strongSelf.conversation.inputPeer media:media random_id:rand_long()];
        }
        
        strongSelf.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
            TL_messages_statedMessage *obj = response;
            
            
            [SharedManager proccessGlobalResponse:response];
            
            TLMessage *msg;
            
          
            if(strongSelf.conversation.type != DialogTypeBroadcast)  {
                msg = [obj message];
                strongSelf.message.n_id = [obj message].n_id;
                strongSelf.message.date = [obj message].date;
                
            } else {
                TL_messages_statedMessages *stated = (TL_messages_statedMessages *) response;
                [Notification perform:MESSAGE_LIST_RECEIVE data:@{KEY_MESSAGE_LIST:stated.messages}];
                [Notification perform:MESSAGE_LIST_UPDATE_TOP data:@{KEY_MESSAGE_LIST:stated.messages,@"update_real_date":@(YES)}];
                
                msg = stated.messages[0];
                
            }
            
            
            if(isFirstSend) {
                [strongSelf.uploadOperation saveFileInfo:msg.media.photo];
            }
            
            
            TLPhotoSize *newSize = [msg.media.photo.sizes lastObject];
            
            if(strongSelf.message.media.photo.sizes.count > 1) {
                TL_photoSize *size =strongSelf.message.media.photo.sizes[1];
                [TGCache changeKey:size.location.cacheKey withKey:newSize.location.cacheKey];
                size.location = newSize.location;
                
            } else {
                ((TL_localMessage *)strongSelf.message).media = msg.media;
            }
            
           
            strongSelf.uploadOperation = nil;
            
            strongSelf.message.dstate = DeliveryStateNormal;
            
            [strongSelf.message save:YES];
            
            [[Storage manager] insertMedia:strongSelf.message];
            
            [[NSFileManager defaultManager] moveItemAtPath:strongSelf.filePath toPath:mediaFilePath(strongSelf.message.media) error:nil];
            
           
            
            PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:strongSelf.message.n_id media:strongSelf.message peer_id:strongSelf.message.peer_id];
            
            [Notification perform:MEDIA_RECEIVE data:@{KEY_PREVIEW_OBJECT:previewObject}];
            
            
            strongSelf.state = MessageSendingStateSent;
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            strongSelf.state = MessageSendingStateError;
            strongSelf.uploadOperation = nil;
        }];
        
    }];
    
    
    [self.uploadOperation setUploadProgress:^(UploadOperation *operation, NSUInteger current, NSUInteger total) {
        strongSelf.progress = ((float)current/(float)total) * 100.0f;
    }];
    
    [self.uploadOperation setUploadTypingNeed:^(UploadOperation *operation) {
        [TGSendTypingManager addAction:[TL_sendMessageUploadPhotoAction create] forConversation:strongSelf.conversation];
    }];
    
    [self.uploadOperation setUploadStarted:^(UploadOperation *operation, NSData *data) {
        [TGSendTypingManager addAction:[TL_sendMessageUploadPhotoAction create] forConversation:strongSelf.conversation];
    }];
    
    
    [self.uploadOperation setFilePath:self.filePath];
    [self.uploadOperation setFileName:@"photo.jpeg"];
    [self.uploadOperation ready:UploadImageType];
}


-(void)cancel {
    [self.uploadOperation cancel];
    [super cancel];
}



@end
