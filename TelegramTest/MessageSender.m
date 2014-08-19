//
//  MessageSender.m
//  TelegramTest
//
//  Created by keepcoder on 20.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "MessageSender.h"
#import "CMath.h"
#import "Notification.h"
#import "TGPeer+Extensions.h"
#import "UploadOperation.h"
#import "ImageCache.h"
#import "ImageStorage.h"
#import "ImageUtils.h"
#import "TGDialog+Extensions.h"
#import <QTKit/QTKit.h>
#import "Crypto.h"
#import "FileUtils.h"
#import "QueueManager.h"
#import "NSMutableData+Extension.h"
#import <MTProtoKit/MTEncryption.h>
#import "SelfDestructionController.h"
#import <AVFoundation/AVFoundation.h>
#import "Telegram.h"
#import "TGUpdateMessageService.h"
#import "NSArray+BlockFiltering.h"
#import "MessagesUtils.h"
#import "TGMessage+Extensions.h"
#import "TGFileLocation+Extensions.h"
#import "Telegram.h"
#import "TGTimer.h"
@implementation MessageSender


+(void)compressVideo:(NSString *)path randomId:(long)randomId completeHandler:(void (^)(BOOL success,NSString *compressedPath))completeHandler progressHandler:(void (^)(float progress))progressHandler {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *compressedPath = exportPath(randomId,@"mp4");
    
    
    if([manager fileExistsAtPath:compressedPath]) {
        if(completeHandler) completeHandler(NO,compressedPath);
        return;
    }
    
    if (floor(NSAppKitVersionNumber) <= 1187) {
        [[NSFileManager defaultManager] copyItemAtPath:path toPath:compressedPath error:nil];
        if(completeHandler) completeHandler(YES,compressedPath);
        
        return;
    }
    
    AVAsset *avAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset640x480];
    
    
    
    exportSession.outputURL = [NSURL fileURLWithPath:compressedPath];
    exportSession.outputFileType = AVFileTypeMPEG4;
    
    
    
    __block TGTimer *progressTimer = [[TGTimer alloc] initWithTimeout:0.1 repeat:YES completion:^{
        if(progressHandler)
            progressHandler(exportSession.progress);
        
    } queue:dispatch_get_current_queue()];
    
    [progressTimer start];
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         bool endProcessing = false;
         bool success = false;
         
         switch ([exportSession status])
         {
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                 endProcessing = true;
                 break;
             case AVAssetExportSessionStatusCancelled:
                 endProcessing = true;
                 NSLog(@"Export canceled");
                 break;
             case AVAssetExportSessionStatusCompleted:
             {
                 endProcessing = true;
                 success = true;
                 
                 break;
             }
             default:
                 break;
         }
         
         if (endProcessing)
         {
             [progressTimer invalidate];
             progressTimer = nil;
             completeHandler(success,compressedPath);
         }
     }];
}


+ (NSDictionary *)videoParams:(NSString *)path {
    
    
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    CMTime time = [asset duration];
    int duration = ceil(time.value / time.timescale);
    
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0, 30);
    
    __block NSImage *thumbImg;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        }
        
        thumbImg = [[NSImage alloc] initWithCGImage:im size:NSMakeSize(90, 90)];
        dispatch_semaphore_signal(sema);
    };
    
    
    CGSize maxSize = CGSizeMake(90, 90);
    generator.maximumSize = maxSize;
    
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    dispatch_release(sema);

    
    
    NSSize size = NSMakeSize(640, 480);
    return @{@"duration": @(duration), @"image":thumbImg, @"size":NSStringFromSize(size)};
}



+(TL_localMessage *)createOutMessage:(NSString *)message media:(TGMessageMedia *)media dialog:(TL_conversation *)dialog {
    return  [TL_localMessage createWithN_id:0 from_id:UsersManager.currentUserId to_id:[dialog.peer peerOut] n_out:YES unread:YES date: (int) [[MTNetwork instance] getTime] message:message media:media fakeId:[MessageSender getFakeMessageId] randomId:rand_long() state:DeliveryStatePending];
}




+(RPCRequest *)sendStatedMessage:(id)request successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler
{
    return [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
        [MessagesManager statedMessage:response];
        
        if(successHandler)
            successHandler(request, response);
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        if(errorHandler)
            errorHandler(request, error);
    } timeout:10];

}

+(RPCRequest *)setTTL:(int)ttl toConversation:(TL_conversation *)conversation  callback:(dispatch_block_t)callback {
    
    TL_encryptedChat *chat = [[ChatsManager sharedManager] find:conversation.peer.chat_id];
    
    TL_decryptedMessageService *msg = [TL_decryptedMessageService createWithRandom_id:rand_long() random_bytes:[[NSMutableData alloc] initWithRandomBytes:256] action:[TL_decryptedMessageActionSetMessageTTL createWithTtl_seconds:ttl]];
    
    NSData *messageData = [MessageSender getEncrypted:conversation messageData:[[TLClassStore sharedManager] serialize:msg]];
    
    
    NSString *text = [MessagesUtils selfDestructTimer:ttl];
    
    TL_localMessageService *message = [TL_localMessageService createWithN_id:0 from_id:[UsersManager currentUserId] to_id:[TL_peerSecret createWithChat_id:chat.n_id] n_out:YES unread:NO date:[[MTNetwork instance] getTime] action:[TL_messageActionEncryptedChat createWithTitle:text] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() dstate:DeliveryStateNormal];
    
    
    
    TLAPI_messages_sendEncryptedService *request = [TLAPI_messages_sendEncryptedService createWithPeer:[chat inputPeer] random_id:rand_long() data:messageData];
    
    return [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_sentEncryptedMessage* response) {
        
        message.date = [response date];
        
        message.n_id = [MessageSender getFutureMessageId];
        
        Destructor *destructor = [[Destructor alloc] initWithTLL:ttl max_id:message.n_id chat_id:chat.n_id];
        
        [SelfDestructionController addDestructor:destructor];
        
        
        [[MessagesManager sharedManager] addMessage:message];
        
        
        [Notification perform:MESSAGE_UPDATE_TOP_MESSAGE data:@{KEY_MESSAGE:message}];
        [Notification perform:MESSAGE_RECEIVE_EVENT data:@{KEY_MESSAGE:message}];
        
        if(callback) callback();
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        if(callback) callback();
    }];
    
}



+(NSData *)getEncrypted:(TL_conversation *)dialog messageData:(NSData *)messageData {
    
    EncryptedParams *params = [EncryptedParams findAndCreate:dialog.peer.chat_id];

    int messageLength = (int) messageData.length;
    NSMutableData *fullData = [NSMutableData dataWithBytes:&messageLength length:4];
    [fullData appendData:messageData];
    
    
    NSMutableData *msgKey = [[[Crypto sha1:fullData] subdataWithRange:NSMakeRange(4, 16)] mutableCopy];
    
   
    fullData = [fullData addPadding:16];
    
    NSData *encryptedData = [Crypto encrypt:0 data:fullData auth_key:params.encrypt_key msg_key:msgKey encrypt:YES];
    
    NSData *key_fingerprints = [[Crypto sha1:params.encrypt_key] subdataWithRange:NSMakeRange(12, 8)];;
    
    fullData = [NSMutableData dataWithData:key_fingerprints];
    [fullData appendData:msgKey];
    [fullData appendData:encryptedData];
    
    return fullData;;
}

+(void)insertEncryptedServiceMessage:(NSString *)title chat:(TGEncryptedChat *)chat {
    
    TL_localMessageService *msg = [TL_localMessageService createWithN_id:[MessageSender getFutureMessageId] from_id:chat.admin_id to_id:[TL_peerSecret createWithChat_id:chat.n_id] n_out:NO unread:NO date:[[MTNetwork instance] getTime] action:[TL_messageActionEncryptedChat createWithTitle:title] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() dstate:DeliveryStatePending];
    [MessagesManager addAndUpdateMessage:msg];
}

+(id)requestForDeleteEncryptedMessages:(NSMutableArray *)ids dialog:(TL_conversation *)dialog {
    
    TGEncryptedChat *chat = [[ChatsManager sharedManager] find:dialog.peer.chat_id];
    TL_decryptedMessageService *msg = [TL_decryptedMessageService createWithRandom_id:rand_long() random_bytes:[[NSMutableData alloc] initWithRandomBytes:256] action:[TL_decryptedMessageActionDeleteMessages createWithRandom_ids:ids]];
    
    NSData *messageData = [[TLClassStore sharedManager] serialize:msg];
    
    TLAPI_messages_sendEncryptedService *request = [TLAPI_messages_sendEncryptedService createWithPeer:[chat inputPeer] random_id:rand_long() data:[self getEncrypted:dialog messageData:messageData]];
    
    return request;
    
}

+(id)requestForFlushEncryptedHistory:(TL_conversation *)dialog {
    
    TGEncryptedChat *chat = [[ChatsManager sharedManager] find:dialog.peer.chat_id];
    
    TL_decryptedMessageService *msg = [TL_decryptedMessageService createWithRandom_id:rand_long() random_bytes:[[NSMutableData alloc] initWithRandomBytes:256] action:[TL_decryptedMessageActionFlushHistory create]];
    
    NSData *messageData = [[TLClassStore sharedManager] serialize:msg];
    
    TLAPI_messages_sendEncryptedService *request = [TLAPI_messages_sendEncryptedService createWithPeer:[chat inputPeer] random_id:rand_long() data:[self getEncrypted:dialog messageData:messageData]];
    
    return request;
    
}



+(int)getFutureMessageId {
    
    static NSInteger msgId;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        msgId = [[NSUserDefaults standardUserDefaults] integerForKey:@"store_secret_message_id"];
    });
    
    if(msgId == 0) {
        msgId = TGMINSECRETID;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(++msgId) forKey:@"store_secret_message_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return (int) msgId;
}


+(int)getFakeMessageId {
    
    static NSInteger msgId;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        msgId = [[NSUserDefaults standardUserDefaults] integerForKey:@"store_fake_message_id"];
    });
    
    if(msgId == 0) {
        msgId = TGMINFAKEID;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(++msgId) forKey:@"store_fake_message_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return (int) msgId;
}

+(void)startEncryptedChat:(TGUser *)user callback:(dispatch_block_t)callback {
    
    [RPCRequest sendRequest:[TLAPI_messages_getDhConfig createWithVersion:1 random_length:256] successHandler:^(RPCRequest *request, TL_messages_dhConfig * response) {
        
        NSMutableData *a = [[NSMutableData alloc] initWithRandomBytes:256];
        int g = [response g];
        
        if(!MTCheckIsSafeG(g)) return;
        NSData *g_a = [Crypto exp:[[NSData alloc] initWithBytes:&g length:1] b:a dhPrime:[response p]];
        if(!MTCheckIsSafeGAOrB(g_a, [response p])) return;
        
        EncryptedParams *params = [[EncryptedParams alloc] initWithChatId:rand_limit(INT32_MAX-1) encrypt_key:nil key_fingerprings:0 a:a g_a:g_a dh_prime:[response p] state:EncryptedWaitOnline access_hash:0];
        
        
        
        TGInputUser *inputUser = user.inputUser;
        
        [RPCRequest sendRequest:[TLAPI_messages_requestEncryption createWithUser_id:inputUser random_id:params.n_id g_a:g_a] successHandler:^(RPCRequest *request, id response) {
            
            
            [params save];
            
            
            [[ChatsManager sharedManager] add:@[response]];
            
            [[Storage manager] insertEncryptedChat:response];
            
            [params save];
            
            TL_conversation *dialog = [TL_conversation createWithPeer:[TL_peerSecret createWithChat_id:params.n_id] top_message:-1 unread_count:0 last_message_date:[[MTNetwork instance] getTime] notify_settings:nil last_marked_message:0 top_message_fake:-1 last_marked_date:[[MTNetwork instance] getTime]];
            
            [[DialogsManager sharedManager] insertDialog:dialog];
            
            [Notification perform:DIALOG_TO_TOP data:@{KEY_DIALOG:dialog}];
            
          //  [MessageSender insertEncryptedServiceMessage:NSLocalizedString(@"MessageAction.Secret.CreatedSecretChat", nil) chat:response];
         
            dispatch_async(dispatch_get_main_queue(), ^{
                if(callback) callback();
                [[Telegram sharedInstance] showMessagesFromDialog:dialog sender:self];
            });
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
             if(callback) callback();
        } timeout:10];
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        if(callback) callback();
    } timeout:10];
}


static NSMutableArray *wrong_files;

+ (void)sendFilesByPath:(NSArray *)files dialog:(TL_conversation *)dialog asDocument:(BOOL)asDocument {
   
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wrong_files = [[NSMutableArray alloc] init];
    });
    
    if(files.count == 0) {
        if(wrong_files.count > 0) {
            if(wrong_files.count > 0) {
                alert_bad_files(wrong_files);
                [wrong_files removeAllObjects];
            }
        }
        return;
    }
    
    
    NSString *file = files[0];
    
    files = [files subarrayWithRange:NSMakeRange(1, files.count-1)];
    
    
    dispatch_block_t next = ^ {
      
        if(files.count > 0)
            [self sendFilesByPath:files dialog:dialog asDocument:asDocument];
        
    };
    
    
    
    NSString *pathExtension = [[file pathExtension] lowercaseString];
    BOOL isDir;
    if([[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDir]) {
        if(isDir) {
            
            next();
            
            return;
        }
        
    } else {
        
         next();
        
        return;
    }
    
    
    if(!check_file_size(file)) {
        [wrong_files addObject:[file lastPathComponent]];
        
        next();
        return;
    }
    
    if([imageTypes() containsObject:pathExtension] && !asDocument) {
        [[[Telegram rightViewController] messagesViewController]
         sendImage:file file_data:nil addCompletionHandler:^{
             next();
         }];
        
        return;
        
    }
    
    if([videoTypes() containsObject:pathExtension] && !asDocument) {
        [[[Telegram rightViewController] messagesViewController]
         sendVideo:file addCompletionHandler:^{
              next();
         }];
        
       
        return;
    }
    
    [[[Telegram rightViewController] messagesViewController]
     sendDocument:file addCompletionHandler:^{
         next();
     }];
    
}

+(BOOL)sendDraggedFiles:(id <NSDraggingInfo>)sender dialog:(TL_conversation *)dialog asDocument:(BOOL)asDocument {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    if(![dialog canSendMessage])
        return NO;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        [self sendFilesByPath:files dialog:dialog asDocument:asDocument];
        
    } else if([[pboard types] containsObject:NSTIFFPboardType]) {
        NSData *tiff = [pboard dataForType:NSTIFFPboardType];
        
        [[[Telegram rightViewController] messagesViewController]
         sendImage:nil file_data:tiff];
    }
    
    return YES;
}


+(void)drop {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_message_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
