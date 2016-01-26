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
#import "TLPeer+Extensions.h"
#import "UploadOperation.h"
#import "ImageCache.h"
#import "ImageStorage.h"
#import "ImageUtils.h"
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
#import "TLFileLocation+Extensions.h"
#import "Telegram.h"
#import "TGTimer.h"
#import "NSString+FindURLs.h"
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
    
    AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:NSAppKitVersionNumber > NSAppKitVersionNumber10_10_Max ? AVAssetExportPresetMediumQuality : AVAssetExportPreset640x480];
    
    
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputURL = [NSURL fileURLWithPath:compressedPath];
    exportSession.outputFileType = AVFileTypeMPEG4;
   // exportSession
    
    
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
                 MTLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                 endProcessing = true;
                 break;
             case AVAssetExportSessionStatusCancelled:
                 endProcessing = true;
                 MTLog(@"Export canceled");
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
             
             if(!success || fileSize(path) < fileSize(compressedPath))
             {
                 [[NSFileManager defaultManager] removeItemAtPath:compressedPath error:nil];
                 [[NSFileManager defaultManager] copyItemAtPath:path toPath:compressedPath error:nil];
             }
             
             completeHandler(success,compressedPath);
         }
     }];
}


+ (NSDictionary *)videoParams:(NSString *)path thumbSize:(NSSize)thumbSize {
    
    
    
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
            MTLog(@"couldn't generate thumbnail, error:%@", error);
        }
        
        thumbImg = [[NSImage alloc] initWithCGImage:im size:thumbSize];
        dispatch_semaphore_signal(sema);
    };
    
    
    CGSize maxSize = thumbSize;
    generator.maximumSize = maxSize;
    
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//    dispatch_release(sema);

    
    
    NSSize size = strongsize([asset naturalSize], 640);
    return @{@"duration": @(duration), @"image":thumbImg, @"size":NSStringFromSize(size)};
}



+(TL_localMessage *)createOutMessage:(NSString *)msg media:(TLMessageMedia *)media conversation:(TL_conversation *)conversation {
    
    __block NSString *message = msg;
    
    __block TL_localMessage *replyMessage;
    
    __block TLWebPage *webpage;
    
    
    __block TL_localMessage *keyboardMessage;
    __block BOOL clear = YES;
    __block BOOL removeKeyboard = NO;
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        replyMessage = [transaction objectForKey:conversation.cacheKey inCollection:REPLAY_COLLECTION];
        
        
        keyboardMessage = [transaction objectForKey:conversation.cacheKey inCollection:BOT_COMMANDS];
        if(!keyboardMessage) {
            clear = NO;
        }
        
        [keyboardMessage.reply_markup.rows enumerateObjectsUsingBlock:^(TL_keyboardButtonRow *obj, NSUInteger idx, BOOL *stop) {
            
            [obj.buttons enumerateObjectsUsingBlock:^(TL_keyboardButton *button, NSUInteger idx, BOOL *stop) {
                
                if([message isEqualToString:button.text]) {
                    clear = NO;
                    
                    *stop = YES;
                }
                
            }];
            
            
        }];
        
        
//        if(((keyboardMessage.reply_markup.flags & (1 << 1) ) == (1 << 1)) && !clear) {
//            
//            [transaction removeObjectForKey:conversation.cacheKey inCollection:BOT_COMMANDS];
//            
//            removeKeyboard = YES;
//        }
        
        [transaction removeObjectForKey:conversation.cacheKey inCollection:REPLAY_COLLECTION];
       
    }];
    

    
    
    
    if(clear) {
        keyboardMessage = nil;
    }
    
    if([media isKindOfClass:[TL_messageMediaEmpty class]]) {
        
        webpage = [Storage findWebpage:[message webpageLink]];
    }
    
    if(!replyMessage && keyboardMessage.peer_id < 0 && !clear) {
        replyMessage = keyboardMessage;
    }
    
    int reply_to_msg_id = replyMessage.n_id;
    
    
    int flags = TGOUTMESSAGE;
    
    if(!conversation.user.isBot && conversation.type != DialogTypeChannel)
        flags|=TGUNREADMESSAGE;
    
    if(reply_to_msg_id > 0)
        flags|=TGREPLYMESSAGE;
    
        
    
    // channel from_id check this after update server side
    flags|=TGFROMIDMESSAGE;
    
    
    TL_localMessage *outMessage = [TL_localMessage createWithN_id:0 flags:flags from_id:UsersManager.currentUserId to_id:[conversation.peer peerOut]  fwd_from_id:0 fwd_date:0 reply_to_msg_id:reply_to_msg_id  date: (int) [[MTNetwork instance] getTime] message:message media:media fakeId:[MessageSender getFakeMessageId] randomId:rand_long() reply_markup:nil entities:nil views:1 isViewed:NO state:DeliveryStatePending];
    
    
    
    
    if(webpage)
    {
        outMessage.media = [TL_messageMediaWebPage createWithWebpage:webpage];
    }
    
    if(reply_to_msg_id != 0)
    {
        [[Storage manager] addSupportMessages:@[replyMessage]];
        [MessagesManager addSupportMessages:@[replyMessage]];
    }
    
    
    if(conversation.peer_id == [Telegram conversation].peer_id) {
        if(replyMessage || removeKeyboard) {
            [ASQueue dispatchOnMainQueue:^{
                
                if(replyMessage) {
                    [[Telegram rightViewController].messagesViewController removeReplayMessage:YES animated:YES];
                }
                
            }];
        }
        
    }
    
    
    return  outMessage;
}






+(NSData *)getEncrypted:(EncryptedParams *)params messageData:(NSData *)messageData {
    
    int messageLength = (int) messageData.length;
    NSMutableData *fullData = [NSMutableData dataWithBytes:&messageLength length:4];
    [fullData appendData:messageData];
    
    
    NSMutableData *msgKey = [[[Crypto sha1:fullData] subdataWithRange:NSMakeRange(4, 16)] mutableCopy];
    
   
    fullData = [fullData addPadding:16];
    
    NSData *encryptedData = [Crypto encrypt:0 data:fullData auth_key:params.lastKey msg_key:msgKey encrypt:YES];
    
    NSData *key_fingerprints = [[Crypto sha1:params.lastKey] subdataWithRange:NSMakeRange(12, 8)];;
    
    fullData = [NSMutableData dataWithData:key_fingerprints];
    [fullData appendData:msgKey];
    [fullData appendData:encryptedData];
    
    return fullData;;
}

+(void)insertEncryptedServiceMessage:(NSString *)title chat:(TLEncryptedChat *)chat {
    
    TL_localMessageService *msg = [TL_localMessageService createWithFlags:TGNOFLAGSMESSAGE n_id:[MessageSender getFutureMessageId] from_id:chat.admin_id to_id:[TL_peerSecret createWithChat_id:chat.n_id] date:[[MTNetwork instance] getTime] action:[TL_messageActionEncryptedChat createWithTitle:title] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() dstate:DeliveryStatePending];
    [MessagesManager addAndUpdateMessage:msg];
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

+(void)startEncryptedChat:(TLUser *)user callback:(dispatch_block_t)callback {
    
    [RPCRequest sendRequest:[TLAPI_messages_getDhConfig createWithVersion:1 random_length:256] successHandler:^(RPCRequest *request, TL_messages_dhConfig * response) {
        
        NSMutableData *a = [[NSMutableData alloc] initWithRandomBytes:256];
        int g = [response g];
        
        if(!MTCheckIsSafeG(g)) return;
        NSData *g_a = MTExp([[NSData alloc] initWithBytes:&g length:1], a, [response p]);
        if(!MTCheckIsSafeGAOrB(g_a, [response p])) return;
        
        EncryptedParams *params = [[EncryptedParams alloc] initWithChatId:rand_limit(INT32_MAX-1) encrypt_key:nil key_fingerprint:0 a:a p:[response p] random:[response random] g_a_or_b:g_a  g:g state:EncryptedWaitOnline access_hash:0 layer:MIN_ENCRYPTED_LAYER isAdmin:YES];
        
        
        
        TLInputUser *inputUser = user.inputUser;
        
        [RPCRequest sendRequest:[TLAPI_messages_requestEncryption createWithUser_id:inputUser random_id:params.n_id g_a:g_a] successHandler:^(RPCRequest *request, id response) {
            
            
            [params save];
            
            
            [[ChatsManager sharedManager] add:@[response]];
            
            [[Storage manager] insertEncryptedChat:response];
            
            [params save];
            
            TL_conversation *dialog = [TL_conversation createWithPeer:[TL_peerSecret createWithChat_id:params.n_id] top_message:-1 unread_count:0 last_message_date:[[MTNetwork instance] getTime] notify_settings:[TL_peerNotifySettingsEmpty create] last_marked_message:0 top_message_fake:-1 last_marked_date:[[MTNetwork instance] getTime] sync_message_id:0 read_inbox_max_id:0 unread_important_count:0 lastMessage:nil];
            
            [[DialogsManager sharedManager] insertDialog:dialog];
            
            [Notification perform:DIALOG_TO_TOP data:@{KEY_DIALOG:dialog}];
            
          //  [MessageSender insertEncryptedServiceMessage:NSLocalizedString(@"MessageAction.Secret.CreatedSecretChat", nil) chat:response];
         
            dispatch_async(dispatch_get_main_queue(), ^{
                if(callback) callback();
                [appWindow().navigationController showMessagesViewController:dialog];
            });
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
             if(callback) callback();
        } timeout:10];
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        if(callback) callback();
    } timeout:10];
}


static NSMutableArray *wrong_files;

+ (void)sendFilesByPath:(NSArray *)files dialog:(TL_conversation *)dialog isMultiple:(BOOL)isMultiple asDocument:(BOOL)asDocument {
   
    
   
    
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
      
        if(files.count > 0) {
            
            [self sendFilesByPath:files dialog:dialog isMultiple:isMultiple asDocument:asDocument];
        }
            
        
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
         sendImage:file forConversation:dialog file_data:nil isMultiple:isMultiple addCompletionHandler:nil];
        next();
        return;
        
    }
    
    if([videoTypes() containsObject:pathExtension] && !asDocument) {
        [[[Telegram rightViewController] messagesViewController]
         sendVideo:file forConversation:dialog];
         next();
       
        return;
    }
    
    [[[Telegram rightViewController] messagesViewController]
     sendDocument:file forConversation:dialog];
    next();
    
}

+(BOOL)sendDraggedFiles:(id <NSDraggingInfo>)sender dialog:(TL_conversation *)dialog asDocument:(BOOL)asDocument {
    NSPasteboard *pboard;
    
    if(![dialog canSendMessage])
        return NO;
    
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        BOOL isMultiple = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.pathExtension.lowercaseString IN (%@)",imageTypes()]].count > 1;
        [self sendFilesByPath:files dialog:dialog isMultiple:isMultiple asDocument:asDocument];
        
    } else if([[pboard types] containsObject:NSTIFFPboardType]) {
        NSData *tiff = [pboard dataForType:NSTIFFPboardType];
        
        if(!asDocument) {
            [[[Telegram rightViewController] messagesViewController]
             sendImage:nil forConversation:dialog file_data:tiff];
        } else {
            
            NSString *path = exportPath(rand_long(), @"jpg");
            
            [tiff writeToFile:path atomically:YES];
            
            [[Telegram rightViewController].messagesViewController sendDocument:path forConversation:[Telegram conversation]];
        }
        
        
    }
    
    return YES;
}


+(void)drop {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_message_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
