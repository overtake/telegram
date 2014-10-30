//
//  VideoSenderItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "VideoSenderItem.h"
#import "ImageCache.h"
#import "ImageStorage.h"
#import "ImageUtils.h"
@interface VideoSenderItem ()
@property (nonatomic,strong) NSString *path_for_file;
@property (nonatomic,strong) UploadOperation *uploader;
@property (nonatomic,assign) BOOL isCompressed;
@end

@implementation VideoSenderItem

-(void)setState:(MessageState)state {
    [super setState:state];
}


-(id)initWithPath:(NSString *)path_for_file forConversation:(TL_conversation *)conversation {
    if(self = [super init]) {
        self.path_for_file = path_for_file;
        self.conversation = conversation;
        NSDictionary *params = [[MessageSender videoParams:path_for_file] mutableCopy];
        
        int duration = [[params objectForKey:@"duration"] intValue];
        NSSize size = NSSizeFromString([params objectForKey:@"size"]);
        
        NSImage *thumbImage = [params objectForKey:@"image"];
        
        TGPhotoSize *cachedSize;
        NSData *imageData = nil;
        if(thumbImage) {
            imageData = [thumbImage TIFFRepresentation];
            
            imageData = compressImage(imageData, 0.1);
            
            if(imageData) {
                cachedSize = [TL_photoCachedSize createWithType:@"jpeg" location:[TL_fileLocation createWithDc_id:0 volume_id:rand_long() local_id:0 secret:0] w:thumbImage.size.width h:thumbImage.size.height bytes:imageData];
            }
        }
        
        
        if(!cachedSize) {
            cachedSize = [TL_photoSizeEmpty createWithType:@"x"];
        }
        

        TL_messageMediaVideo *video = [TL_messageMediaVideo createWithVideo:[TL_video createWithN_id:0 access_hash:0 user_id:[UsersManager currentUserId] date:(int)[[MTNetwork instance] getTime] caption:@"Video" duration:duration mime_type:@"mp4" size:0  thumb:cachedSize dc_id:0 w:size.width h:size.height]];

        [[ImageCache sharedManager] setImage:thumbImage forLocation:[cachedSize location]];

        self.message = [MessageSender createOutMessage:@"" media:video dialog:conversation];
        
        

    }

    return self;
}

-(void)performRequest {
    
    
    
    NSData *thumbData = self.message.media.video.thumb.bytes;
    int duration = self.message.media.video.duration;
    NSSize size = NSMakeSize(self.message.media.video.w, self.message.media.video.h);
    
    self.uploader = [[UploadOperation alloc] init];
    
    weakify();
    [self.uploader setUploadComplete:^(UploadOperation *video, id input) {
        
        __block BOOL isFirstSend = [input isKindOfClass:[TGInputFile class]];
        __block id media = nil;

        dispatch_block_t block = ^{
            

            id request = nil;
            
            if(strongSelf.conversation.type == DialogTypeBroadcast) {
                request = [TLAPI_messages_sendBroadcast createWithContacts:[strongSelf.conversation.broadcast inputContacts] message:@"" media:media];
            } else {
                request = [TLAPI_messages_sendMedia createWithPeer:strongSelf.conversation.inputPeer media:media random_id:rand_long()];
            }
            
            
            strongSelf.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
                TL_messages_statedMessage *obj = response;
                
                [SharedManager proccessGlobalResponse:response];
                
                
                TGMessage *msg;
                
                
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
                    [strongSelf.uploader saveFileInfo:msg.media.video];
                }
                
                
                
                strongSelf.message.media.video.dc_id = [msg media].video.dc_id;
                strongSelf.message.media.video.size = [msg media].video.size;
                strongSelf.message.media.video.access_hash = [msg media].video.access_hash;
                strongSelf.message.media.video.n_id = [msg media].video.n_id;
                
                
                
                [[NSFileManager defaultManager] moveItemAtPath:strongSelf.path_for_file toPath:mediaFilePath(strongSelf.message.media) error:nil];
            
                
                strongSelf.uploader = nil;
                
                strongSelf.message.dstate = DeliveryStateNormal;
                
                
                [strongSelf.message save:YES];
                strongSelf.state = MessageSendingStateSent;
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                strongSelf.state = MessageSendingStateError;
            }];
        };

        if(!isFirstSend) {
            TGVideo *video = input;
            media = [TL_inputMediaVideo createWithVideo_id:[TL_inputVideo createWithN_id:video.n_id access_hash:video.access_hash]];
            block();
        } else {
            
            if(thumbData) {
                UploadOperation *thumbUpload = [[UploadOperation alloc] init];
                [thumbUpload setUploadComplete:^(UploadOperation *thumb, TL_inputFile *inputThumbFile) {
                    
                    media = [TL_inputMediaUploadedThumbVideo createWithFile:input thumb:inputThumbFile duration:duration w:size.width h:size.height mime_type:@"mp4"];
                    
                    block();
                }];
                
                [thumbUpload setFileData:thumbData];
                [thumbUpload ready:UploadImageType];
            } else {
                media = [TL_inputMediaUploadedVideo createWithFile:input duration:duration w:size.width h:size.height mime_type:@"mp4"];
                block();
            }
        }
        
        
        
       
    }];
    
    
    [self.uploader setUploadProgress:^(UploadOperation *operation, NSUInteger current, NSUInteger total) {
        strongSelf.progress =VIDEO_COMPRESSED_PROGRESS + (((float)current/(float)total) * (100.0f - VIDEO_COMPRESSED_PROGRESS));
    }];
    
    
    [MessageSender compressVideo:self.path_for_file randomId:[self.message randomId] completeHandler:^(BOOL success,NSString *c) {
        
       
        if(self.state == MessageSendingStateCancelled)
            return;
        
        self.isCompressed = YES;
        
        self.path_for_file = c;
            
        [self.uploader setFilePath:self.path_for_file];
        [self.uploader ready:UploadVideoType];
        
        if(success)
            [self.message save:YES];
            
        ((TL_localMessage *)self.message).media.video.size = self.uploader.total_size;
        self.state = self.state;
    } progressHandler:^(float progress) {
        self.progress = (progress/1.0f) * VIDEO_COMPRESSED_PROGRESS;
    }];

    
}

- (void)cancel {
    if(self.isCompressed)
        [[NSFileManager defaultManager] removeItemAtPath:self.path_for_file error:nil];
    
    [self.uploader cancel];
    [super cancel];
}

@end
