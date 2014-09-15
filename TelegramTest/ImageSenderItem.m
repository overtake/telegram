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

@interface ImageSenderItem ()
@property (nonatomic, strong) UploadOperation *uploadOperation;
@property (nonatomic, strong) NSImage *image;
@end

@implementation ImageSenderItem

-(void)setState:(MessageState)state {
    [super setState:state];
}

- (id)initWithImage:(NSImage *)image forDialog:(TL_conversation *)dialog {
    if(self = [super init]) {
        
        self.dialog = dialog;
       
        
        image = prettysize(image);
        
        NSSize realSize = image.size;
        NSSize maxSize = strongsizeWithMinMax(image.size, MIN_IMG_SIZE.height, MIN_IMG_SIZE.width);
        
        
        self.image = [ImageUtils imageResize:image newSize:NSMakeSize(MAX(25,realSize.width), MAX(25,realSize.height))];
        
        if(realSize.width > MIN_IMG_SIZE.width && realSize.height > MIN_IMG_SIZE.height && maxSize.width == MIN_IMG_SIZE.width && maxSize.height == MIN_IMG_SIZE.height) {
            
            int difference = roundf( (realSize.width - maxSize.width) /2);
            
            image = cropImage(image,maxSize, NSMakePoint(difference, 0));
            
        }
        
        
        NSData *preview = compressImage([image TIFFRepresentation], 0.1);
        
        
        TL_photoCachedSize *size = [TL_photoCachedSize createWithType:@"x" location:[TL_fileLocation createWithDc_id:0 volume_id:rand_long() local_id:0 secret:0] w:realSize.width h:realSize.height bytes:preview];
        
       
        
        TL_photoSize *size1 = [TL_photoSize createWithType:@"x" location:size.location w:realSize.width h:realSize.height size:0];
        
        NSMutableArray *sizes = [[NSMutableArray alloc] init];
        
        [sizes addObject:size];
        [sizes addObject:size1];

        TL_messageMediaPhoto *photo = [TL_messageMediaPhoto createWithPhoto:[TL_photo createWithN_id:0 access_hash:0 user_id:0 date:(int)[[MTNetwork instance] getTime] caption:@"photo" geo:[TL_geoPointEmpty create] sizes:sizes]];
        
        
        
       
        
        [[ImageCache sharedManager] setImage:image forLocation:size.location];
      
        self.message = [MessageSender createOutMessage:@"" media:photo dialog:dialog];
        
        [compressImage([self.image TIFFRepresentation], 0.83) writeToFile:mediaFilePath(self.message.media) atomically:YES];
        [self.message save:YES];
        
        
        
    }
    return self;
}

-(void)performRequest {
    
    self.uploadOperation = [[UploadOperation alloc] init];
    
    self.filePath = mediaFilePath(self.message.media);
    
    weakify();
    
    [self.uploadOperation setUploadComplete:^(UploadOperation *operation, id input) {
        
    
        
        __block BOOL isFirstSend = [input isKindOfClass:[TGInputFile class]];
        
        id media = nil;
        if(isFirstSend) {
            media = [TL_inputMediaUploadedPhoto createWithFile:input];
        } else {
            TGPhoto *photo = input;
            media = [TL_inputMediaPhoto createWithPhoto_id:[TL_inputPhoto createWithN_id:photo.n_id access_hash:photo.access_hash]];
        }
        
        
        id request = nil;
        
        if(strongSelf.dialog.type == DialogTypeBroadcast) {
            request = [TLAPI_messages_sendBroadcast createWithContacts:[strongSelf.dialog.broadcast inputContacts] message:@"" media:media];
        } else {
            request = [TLAPI_messages_sendMedia createWithPeer:strongSelf.dialog.inputPeer media:media random_id:rand_long()];
        }
        
        strongSelf.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
            TL_messages_statedMessage *obj = response;
            
            
            [SharedManager proccessGlobalResponse:response];
            
            TGMessage *msg;
            
          
            if(strongSelf.dialog.type != DialogTypeBroadcast)  {
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
            
            
            TGPhotoSize *newSize = [msg.media.photo.sizes lastObject];
            
            if(strongSelf.message.media.photo.sizes.count > 1) {
                TL_photoSize *size =strongSelf.message.media.photo.sizes[1];
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
    
    
    [self.uploadOperation setFilePath:self.filePath];
    [self.uploadOperation setFileName:@"photo.jpeg"];
    [self.uploadOperation ready:UploadImageType];
}

-(void)cancel {
    [self.uploadOperation cancel];
    [super cancel];
}

@end
