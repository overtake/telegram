//
//  AudioSenderItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 02.06.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "AudioSenderItem.h"
#import "TGOpusAudioPlayerAU.h"

@interface AudioSenderItem ()
@property (nonatomic,strong) UploadOperation *operation;
@end

@implementation AudioSenderItem


-(void)setState:(MessageState)state {
    [super setState:state];
}

- (id)initWithPath:(NSString *)filePath forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags {
    if(self = [super init]) {
        self.filePath = filePath;
        self.conversation = conversation;
        
        NSTimeInterval duration = [TGOpusAudioPlayerAU durationFile:filePath];

        TL_messageMediaAudio *audio = [TL_messageMediaAudio createWithAudio:[TL_audio createWithN_id:0 access_hash:0 date:(int)[[MTNetwork instance] getTime] duration:roundf(duration) mime_type:@"opus" size:(int)fileSize(filePath) dc_id:0]];
        
        
        self.message = [MessageSender createOutMessage:@"" media:audio conversation:conversation];
        
        self.message.flags|=TGREADEDCONTENT;
        
        if(additionFlags & (1 << 4))
            self.message.from_id = 0;

    }
    return self;
}

-(void)performRequest {
        
    self.operation = [[UploadOperation alloc] init];
    
    
    NSString *export = exportPath(self.message.randomId,@"mp3");
    
    if(!self.filePath)
        self.filePath = export;
    
    if(![self.filePath isEqualToString:export]) {
        [[NSFileManager defaultManager] copyItemAtPath:self.filePath toPath:export error:nil];
        self.filePath = export;
        [self.message save:YES];
    }
    
    
    weak();
    
    [self.operation setUploadProgress:^(UploadOperation *uploader, NSUInteger current, NSUInteger total) {
        
        weakSelf.progress =  ((float)current/(float)total) * 100.0f;
        
    }];
    
    
    [self.operation setUploadComplete:^(UploadOperation *uploader, id input) {
        
        TL_inputMediaUploadedAudio *media = [TL_inputMediaUploadedAudio createWithFile:input duration:((TL_localMessage *)weakSelf.message).media.audio.duration mime_type:@"audio/mpeg"];
        
        
        id request = nil;
        
        if(weakSelf.conversation.type == DialogTypeBroadcast) {
            request = [TLAPI_messages_sendBroadcast createWithContacts:[weakSelf.conversation.broadcast inputContacts] random_id:[weakSelf.conversation.broadcast generateRandomIds] message:@"" media:media];
        } else {
            request = [TLAPI_messages_sendMedia createWithFlags:[self senderFlags] peer:weakSelf.conversation.inputPeer reply_to_msg_id:weakSelf.message.reply_to_msg_id media:media random_id:weakSelf.message.randomId  reply_markup:[TL_replyKeyboardMarkup createWithFlags:0 rows:[@[]mutableCopy]]];
        }
        
        weakSelf.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TLUpdates *response) {
            
            
            [weakSelf updateMessageId:response];
            
            TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[[weakSelf updateNewMessageWithUpdates:response] message]];
            
            if(msg == nil)
            {
                [weakSelf cancel];
                return;
            }
            
            
            if(weakSelf.conversation.type != DialogTypeBroadcast)  {
                weakSelf.message.n_id = msg.n_id;
                weakSelf.message.date = msg.date;
                
            } else {
                
                
            }
            
            
            
            TLPhotoSize *newSize = [[msg media].photo.sizes lastObject];
            
            if(weakSelf.message.media.photo.sizes.count > 1) {
                TL_photoSize *size = weakSelf.message.media.photo.sizes[1];
                size.location = newSize.location;
            } else {
                weakSelf.message.media = msg.media;
            }
            
            
            NSString *filePath = mediaFilePath(msg.media);
            
            
            if ([[NSFileManager defaultManager] isReadableFileAtPath:weakSelf.filePath]) {
                [[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:weakSelf.filePath] toURL:[NSURL fileURLWithPath:filePath] error:nil];
            }
            
            weakSelf.operation = nil;
            
            weakSelf.message.dstate = DeliveryStateNormal;
            
           [weakSelf.message save:YES];
            weakSelf.state = MessageSendingStateSent;
  
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            weakSelf.state = MessageSendingStateError;
        } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
        
        
    }];
    
    [self.operation setUploadCancelled:^(UploadOperation *uploader) {
        
    }];
    
    [self.operation setFilePath:self.filePath];
    [self.operation ready:UploadAudioType];
}


@end
