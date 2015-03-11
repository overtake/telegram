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

- (id)initWithPath:(NSString *)filePath forConversation:(TL_conversation *)conversation {
    if(self = [super init]) {
        self.filePath = filePath;
        self.conversation = conversation;
        
        NSTimeInterval duration = [TGOpusAudioPlayerAU durationFile:filePath];

        TL_messageMediaAudio *audio = [TL_messageMediaAudio createWithAudio:[TL_audio createWithN_id:0 access_hash:0 user_id:[UsersManager currentUserId] date:(int)[[MTNetwork instance] getTime] duration:roundf(duration) mime_type:@"opus" size:(int)fileSize(filePath) dc_id:0]];
        
        
        self.message = [MessageSender createOutMessage:@"" media:audio conversation:conversation];
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
            request = [TLAPI_messages_sendBroadcast createWithContacts:[weakSelf.conversation.broadcast inputContacts] message:@"" media:media];
        } else {
            request = [TLAPI_messages_sendMedia createWithPeer:weakSelf.conversation.inputPeer reply_to_id:weakSelf.message.reply_to_id media:media random_id:rand_long()];
        }
        
        weakSelf.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_statedMessage *response) {
            
            [SharedManager proccessGlobalResponse:response];
            
            
            
            TLMessage *msg;
            
            
            if(weakSelf.conversation.type != DialogTypeBroadcast)  {
                msg = [response message];
                weakSelf.message.n_id = [response message].n_id;
                weakSelf.message.date = [response message].date;
                
            } else {
                TL_messages_statedMessages *stated = (TL_messages_statedMessages *) response;
                [Notification perform:MESSAGE_LIST_RECEIVE data:@{KEY_MESSAGE_LIST:stated.messages}];
                [Notification perform:MESSAGE_LIST_UPDATE_TOP data:@{KEY_MESSAGE_LIST:stated.messages,@"update_real_date":@(YES)}];
                
                msg = stated.messages[0];
                
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
        }];
        
        
    }];
    
    [self.operation setUploadCancelled:^(UploadOperation *uploader) {
        
    }];
    
    [self.operation setFilePath:self.filePath];
    [self.operation ready:UploadAudioType];
}


@end
