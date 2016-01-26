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
#import "TGSendTypingManager.h"
@interface VideoSenderItem ()
@property (nonatomic,strong) NSString *path_for_file;
@property (nonatomic,strong) UploadOperation *uploader;
@property (nonatomic,assign) BOOL isCompressed;
@end

@implementation VideoSenderItem

-(void)setState:(MessageState)state {
    [super setState:state];
}


-(id)initWithPath:(NSString *)path_for_file forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags {
    if(self = [super init]) {
        self.path_for_file = path_for_file;
        self.conversation = conversation;
        NSDictionary *params = [[MessageSender videoParams:path_for_file thumbSize:strongsize(NSMakeSize(640, 480), 90)] mutableCopy];
        
        int duration = [[params objectForKey:@"duration"] intValue];
        NSSize size = NSSizeFromString([params objectForKey:@"size"]);
        
        NSImage *thumbImage = [params objectForKey:@"image"];
        
        TLPhotoSize *cachedSize;
        NSData *imageData = nil;
        if(thumbImage) {
            imageData = jpegNormalizedData(thumbImage);
            
            imageData = compressImage(imageData, 0.1);
            
            if(imageData) {
                cachedSize = [TL_photoCachedSize createWithType:@"jpeg" location:[TL_fileLocation createWithDc_id:0 volume_id:rand_long() local_id:0 secret:0] w:thumbImage.size.width h:thumbImage.size.height bytes:imageData];
            }
        }
        
        
        if(!cachedSize) {
            cachedSize = [TL_photoSizeEmpty createWithType:@"x"];
        }
        

        TL_messageMediaVideo *video = [TL_messageMediaVideo createWithVideo:[TL_video createWithN_id:0 access_hash:0 date:(int)[[MTNetwork instance] getTime] duration:duration mime_type:mimetypefromExtension([path_for_file pathExtension]) size:0 thumb:cachedSize dc_id:0 w:size.width h:size.height] caption:@""];

        [[ImageCache sharedManager] setImage:thumbImage forLocation:[cachedSize location]];

        self.message = [MessageSender createOutMessage:@"" media:video conversation:conversation];
        
        if(additionFlags & (1 << 4))
            self.message.from_id = 0;


    }

    return self;
}

-(void)performRequest {
    
    
    
    NSData *thumbData = self.message.media.video.thumb.bytes;
    int duration = self.message.media.video.duration;
    NSSize size = NSMakeSize(self.message.media.video.w, self.message.media.video.h);
    
    
    NSString *export = exportPath(self.message.randomId,@"mp4");
    
    if(!self.path_for_file)
        self.path_for_file = export;
    

    
    self.uploader = [[UploadOperation alloc] init];
    
    weakify();
    [self.uploader setUploadComplete:^(UploadOperation *video, id input) {
        
        __block BOOL isFirstSend = [input isKindOfClass:[TLInputFile class]];
        __block id media = nil;

        dispatch_block_t block = ^{
            

            id request = nil;
            
            if(strongSelf.conversation.type == DialogTypeBroadcast) {
                request = [TLAPI_messages_sendBroadcast createWithContacts:[strongSelf.conversation.broadcast inputContacts] random_id:[strongSelf.conversation.broadcast generateRandomIds] message:@"" media:media];
            } else {
                request = [TLAPI_messages_sendMedia createWithFlags:[self senderFlags] peer:strongSelf.conversation.inputPeer reply_to_msg_id:strongSelf.message.reply_to_msg_id media:media random_id:strongSelf.message.randomId  reply_markup:[TL_replyKeyboardMarkup createWithFlags:0 rows:[@[]mutableCopy]]];
            }
            
            
            strongSelf.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TLUpdates *response) {

                
                [SharedManager proccessGlobalResponse:response];
               
                [strongSelf updateMessageId:response];
                
                if(response.updates.count < 2)
                {
                    [strongSelf cancel];
                    return;
                }
                
                
                TLMessage *msg = [TL_localMessage convertReceivedMessage:(TLMessage *) ( [response.updates[1] message])];
                
                
                if(strongSelf.conversation.type != DialogTypeBroadcast)  {
                    
                    strongSelf.message.n_id = msg.n_id;
                    strongSelf.message.date = msg.date;
                    
                } 
                
                
                strongSelf.message.media.video.dc_id = [msg media].video.dc_id;
                strongSelf.message.media.video.size = [msg media].video.size;
                strongSelf.message.media.video.access_hash = [msg media].video.access_hash;
                strongSelf.message.media.video.n_id = [msg media].video.n_id;
                
                
                
                [[NSFileManager defaultManager] moveItemAtPath:strongSelf.path_for_file toPath:mediaFilePath(strongSelf.message.media) error:nil];
            
                NSImage *thumb = [MessageSender videoParams:mediaFilePath(strongSelf.message.media) thumbSize:strongsize(NSMakeSize(640, 480), 250)][@"image"];
                
                
                strongSelf.message.media.video.thumb = [TL_photoCachedSize createWithType:@"x" location:msg.media.video.thumb.location w:thumb.size.width h:thumb.size.height bytes:jpegNormalizedData(thumb)];
                
                strongSelf.uploader = nil;
                
                strongSelf.message.dstate = DeliveryStateNormal;
                
                
                [strongSelf.message save:YES];
                strongSelf.state = MessageSendingStateSent;
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                
                strongSelf.uploader = nil;
                
                if([strongSelf checkErrorAndReUploadFile:error path:strongSelf.filePath])
                    return;
                
                strongSelf.state = MessageSendingStateError;
            } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
        };

        if(!isFirstSend) {
            TLVideo *video = input;
            media = [TL_inputMediaVideo createWithN_id:[TL_inputVideo createWithN_id:video.n_id access_hash:video.access_hash] caption:@""];
            block();
        } else {
            
            if(thumbData) {
                UploadOperation *thumbUpload = [[UploadOperation alloc] init];
                [thumbUpload setUploadComplete:^(UploadOperation *thumb, TL_inputFile *inputThumbFile) {
                    
                    media = [TL_inputMediaUploadedThumbVideo createWithFile:input  thumb:inputThumbFile duration:duration w:size.width h:size.height mime_type:mimetypefromExtension(@"mp4") caption:@""];
                    
                    block();
                }];
                
                [thumbUpload setFileData:thumbData];
                [thumbUpload ready:UploadImageType];
            } else {
                media = [TL_inputMediaUploadedVideo createWithFile:input duration:duration w:size.width h:size.height mime_type:mimetypefromExtension(@"mp4") caption:self.message.media.caption];
                block();
            }
        }
        
        
        
       
    }];
    
    
    [self.uploader setUploadProgress:^(UploadOperation *operation, NSUInteger current, NSUInteger total) {
        strongSelf.progress =VIDEO_COMPRESSED_PROGRESS + (((float)current/(float)total) * (100.0f - VIDEO_COMPRESSED_PROGRESS));
    }];
    
    [self.uploader setUploadTypingNeed:^(UploadOperation *operation) {
        [TGSendTypingManager addAction:[TL_sendMessageUploadVideoAction createWithProgress:strongSelf.progress] forConversation:strongSelf.conversation];
    }];
    
    [self.uploader setUploadStarted:^(UploadOperation *operation, NSData *data) {
        [TGSendTypingManager addAction:[TL_sendMessageUploadVideoAction createWithProgress:strongSelf.progress] forConversation:strongSelf.conversation];
    }];
    
    
    [MessageSender compressVideo:self.path_for_file randomId:[self.message randomId] completeHandler:^(BOOL success,NSString *c) {
        
       
        if(self.state == MessageSendingStateCancelled)
            return;
        
        self.isCompressed = YES;
        
        self.path_for_file = c;
            
        [self.uploader setFilePath:self.path_for_file];
        [self.uploader ready:UploadVideoType];
        
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
