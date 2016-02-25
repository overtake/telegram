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

- (id)initWithPath:(NSString *)filePath forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags waveforms:(NSData *)waveforms {
    if(self = [super init]) {
        self.filePath = filePath;
        self.conversation = conversation;
        
        NSTimeInterval duration = [TGOpusAudioPlayerAU durationFile:filePath];
        
        NSMutableArray *attrs = [NSMutableArray array];
        
        
        [attrs addObject:[TL_documentAttributeAudio createWithFlags:(1 << 10) duration:roundf(duration) title:nil performer:nil waveform:waveforms]];

        TL_messageMediaDocument *audio = [TL_messageMediaDocument createWithDocument:[TL_document createWithN_id:0 access_hash:0 date:[[MTNetwork instance] getTime] mime_type:@"audio/ogg" size:(int)fileSize(filePath) thumb:[TL_photoSizeEmpty createWithType:@"x"] dc_id:0 attributes:attrs] caption:@""];
        
        self.message = [MessageSender createOutMessage:@"" media:audio conversation:conversation additionFlags:additionFlags];
        
        self.message.flags|=TGREADEDCONTENT;
        

    }
    return self;
}

-(void)performRequest {
        
    self.operation = [[UploadOperation alloc] init];
    
    
    NSString *export = exportPath(self.message.randomId,@"ogg");
    
    if(!self.filePath)
        self.filePath = export;
    
    if(![self.filePath isEqualToString:export]) {
        [[NSFileManager defaultManager] moveItemAtPath:self.filePath toPath:export error:nil];
        self.filePath = export;
        [self.message save:YES];
    }
    
    
    weak();
    
    [self.operation setUploadProgress:^(UploadOperation *uploader, NSUInteger current, NSUInteger total) {
        
        strongWeak();
        
        if(strongSelf != nil) {
            weakSelf.progress =  ((float)current/(float)total) * 100.0f;
        }
        
        
        
    }];
    
    
    [self.operation setUploadComplete:^(UploadOperation *uploader, id input) {
        
        strongWeak();
        
        if(strongSelf != nil) {
            TL_inputMediaUploadedDocument *media = [TL_inputMediaUploadedDocument createWithFile:input mime_type:@"audio/ogg" attributes:weakSelf.message.media.document.attributes caption:weakSelf.message.media.caption];
            
            id request = nil;
            
            if(weakSelf.conversation.type == DialogTypeBroadcast) {
                request = [TLAPI_messages_sendBroadcast createWithContacts:[weakSelf.conversation.broadcast inputContacts] random_id:[weakSelf.conversation.broadcast generateRandomIds] message:@"" media:media];
            } else {
                request = [TLAPI_messages_sendMedia createWithFlags:[self senderFlags] peer:weakSelf.conversation.inputPeer reply_to_msg_id:weakSelf.message.reply_to_msg_id media:media random_id:weakSelf.message.randomId  reply_markup:[TL_replyKeyboardMarkup createWithFlags:0 rows:[@[]mutableCopy]]];
            }
            
            weakSelf.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TLUpdates *response) {
                
                strongWeak();
                
                if(strongSelf != nil) {
                    [weakSelf updateMessageId:response];
                    
                    TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[[weakSelf updateNewMessageWithUpdates:response] message]];
                    
                    if(msg == nil)
                    {
                        [weakSelf cancel];
                        return;
                    }
                    
                    weakSelf.message.n_id = msg.n_id;
                    weakSelf.message.date = msg.date;
                    
                    TLPhotoSize *newSize = [[msg media].photo.sizes lastObject];
                    
                    if(weakSelf.message.media.photo.sizes.count > 1) {
                        TL_photoSize *size = weakSelf.message.media.photo.sizes[1];
                        size.location = newSize.location;
                    } else {
                        weakSelf.message.media = msg.media;
                    }
                    
                    
                    NSString *filePath = mediaFilePath(msg);
                    
                    
                    if ([[NSFileManager defaultManager] isReadableFileAtPath:weakSelf.filePath]) {
                        [[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:weakSelf.filePath] toURL:[NSURL fileURLWithPath:filePath] error:nil];
                    }
                    
                    weakSelf.operation = nil;
                    
                    weakSelf.message.dstate = DeliveryStateNormal;
                    
                    [weakSelf.message save:YES];
                    weakSelf.state = MessageSendingStateSent;
                }
                
                
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                strongWeak();
                if(strongSelf != nil) {
                    weakSelf.state = MessageSendingStateError;
                }
                
            } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
        }
        
    }];
    
    [self.operation setUploadCancelled:^(UploadOperation *uploader) {
        
    }];
    
    [self.operation setFilePath:self.filePath];
    [self.operation ready:UploadAudioType];
}

-(void)cancel {
    [self.operation cancel];
    [self.rpc_request cancelRequest];
    [super cancel];
}


@end
