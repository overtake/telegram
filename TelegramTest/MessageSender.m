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
#import "TGLocationRequest.h"
#import "TGContextMessagesvViewController.h"
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
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset640x480];
    
    
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
    CMTime thumbTime = CMTimeMakeWithSeconds(0, 1);
    
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



+(TL_localMessage *)createOutMessage:(NSString *)msg media:(TLMessageMedia *)media conversation:(TL_conversation *)conversation additionFlags:(int)additionFlags {
    
    __block NSString *message = msg;
    
    __block TL_localMessage *replyMessage;
    
    __block TLWebPage *webpage;
    
    
    __block TL_localMessage *keyboardMessage;
    __block BOOL clear = YES;
    __block BOOL removeKeyboard = NO;
    
    
    TGInputMessageTemplate *template = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:conversation.peer_id];
    
    replyMessage = template.replyMessage;
    
    
    
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        
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
        
        
        
    }];
    
    if(clear) {
        keyboardMessage = nil;
    }
    
    if([media isKindOfClass:[TL_messageMediaEmpty class]]) {
        
        webpage = [Storage findWebpage:display_url([message webpageLink])];
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
    
    
    TL_localMessage *outMessage = [TL_localMessage createWithN_id:0 flags:flags from_id:UsersManager.currentUserId to_id:[conversation.peer peerOut]  fwd_from:nil reply_to_msg_id:reply_to_msg_id  date: (int) [[MTNetwork instance] getTime] message:message media:media fakeId:[MessageSender getFakeMessageId] randomId:rand_long() reply_markup:nil entities:nil views:1 via_bot_id:0 edit_date:0 isViewed:NO state:DeliveryStatePending];
    
    if(media.bot_result != nil) {
        outMessage.reply_markup = media.bot_result.send_message.reply_markup;
    }
    
    if(additionFlags & (1 << 4))
        outMessage.flags|= (1 << 14);
    
    
    if(conversation.needRemoveFromIdBeforeSend)
        outMessage.from_id = 0;
    
    if(webpage)
    {
        outMessage.media = [TL_messageMediaWebPage createWithWebpage:webpage];
    }
    
    if(reply_to_msg_id != 0)
    {
        [[Storage manager] addSupportMessages:@[replyMessage]];
        outMessage.replyMessage = replyMessage;
    }
    
    template.autoSave = NO;
    [template setReplyMessage:nil save:NO];
    [template updateTextAndSave:@""];
    
    [template saveForce];
    [template saveTemplateInCloudIfNeeded];
    [template performNotification];
    
    
    return  outMessage;
}


+(NSString *)parseEntities:(NSString *)message entities:(NSMutableArray *)entities backstrips:(NSString *)backstrips startIndex:(NSUInteger)startIndex {
    
    NSRange startRange = [message rangeOfString:backstrips options:0 range:NSMakeRange(startIndex, message.length - startIndex)];
    
    
    if(startRange.location != NSNotFound) {
        
        NSRange stopRange = [message rangeOfString:backstrips options:0 range:NSMakeRange(startRange.location + startRange.length, message.length - (startRange.location + startRange.length ))];
        
        if(stopRange.location != NSNotFound) {
            
            TLMessageEntity *entity;
            
            NSString *innerMessage = [message substringWithRange:NSMakeRange(startRange.location + 1,stopRange.location - (startRange.location + 1))];
            
            
            if(innerMessage.trim.length > 0)  {
                message = [message stringByReplacingOccurrencesOfString:backstrips withString:@"" options:0 range:NSMakeRange(startRange.location, stopRange.location + stopRange.length  - startRange.location)];
                
                
                
                if(backstrips.length == 3) {
                    entity = [TL_messageEntityPre createWithOffset:(int)startRange.location length:(int)(stopRange.location - startRange.location - startRange.length) language:@""];
                } else
                entity = [TL_messageEntityCode createWithOffset:(int)startRange.location length:(int)(stopRange.location - startRange.location - startRange.length)];
                
                [entities addObject:entity];
            } else {
                startIndex = stopRange.location + 1;
            }
            
            
            if(message.length > 0) {
                
                
                int others = 0;
                if([[message substringToIndex:1] isEqualToString:@"\n"]) {
                    message = [message substringFromIndex:1];
                    others = 1;
                }
                
                
                [entities enumerateObjectsUsingBlock:^(TLMessageEntity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if(obj.offset > stopRange.location + stopRange.length) {
                        obj.offset-=((int)stopRange.length*2);
                    }
                    
                    if(obj.offset > 0) {
                        obj.offset-=others;
                    }
                    
                }];
                
                if([message rangeOfString:backstrips].location != NSNotFound) {
                    return [self parseEntities:message entities:entities backstrips:backstrips startIndex:startIndex];
                }
            }
            
            
            
        }
        
    }
    
    return message;
    
}

+(NSString *)parseCustomMentions:(NSString *)message entities:(NSMutableArray *)entities {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((?<!\\w)@\\[([^\\[\\]]+(\\|))+([0-9])+\\])" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *mentions = [[regex matchesInString:message options:0 range:NSMakeRange(0, [message length])] mutableCopy];
    
    __block NSMutableString *replacedMessage = [message mutableCopy];
    
    @try {
        [mentions enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *text = [replacedMessage substringWithRange:obj.range];
            
            NSString *name = [text substringWithRange:NSMakeRange(2, [text rangeOfString:@"|"].location - 2)];
            int user_id = [[text substringWithRange:NSMakeRange([text rangeOfString:@"|"].location + 1, text.length - 1 - [text rangeOfString:@"|"].location)] intValue];
            
            TLUser *user = [[UsersManager sharedManager] find:user_id];
            
            if(user) {
              //  [entities addObject:[TL_messageEntityMentionName createWithOffset:(int)obj.range.location length:(int)name.length user_id:user_id]];
                [entities addObject:[TL_inputMessageEntityMentionName createWithOffset:(int)obj.range.location length:(int)name.length input_user_id:user.inputUser]];
            }
            
            
            [replacedMessage deleteCharactersInRange:obj.range];
            [replacedMessage insertString:name atIndex:obj.range.location];
            
            *stop = YES;
            
        }];
        
        if(mentions.count > 0)
            return [self parseCustomMentions:replacedMessage entities:entities];

    } @catch (NSException *exception) {
        
    }
    
    return replacedMessage;
    
}


+(void)addRatingForPeer:(TLPeer *)peer {
    
    
    TLUser *user = [peer isKindOfClass:[TL_peerUser class]] ? [[UsersManager sharedManager] find:peer.user_id] : nil;
    
    [[Storage yap] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        
        @try {
            NSMutableArray *top = [transaction objectForKey:@"categories" inCollection:TOP_PEERS];
            
            if(top) {
                int dt = ([[MTNetwork instance] getTime] - [[transaction objectForKey:@"dt" inCollection:TOP_PEERS] intValue]);
                
                __block BOOL saved = NO;
                
                __block Class currentClass;
                
                int drating = pow(M_E, (dt/rating_e_decay()));
                
                
                [top enumerateObjectsUsingBlock:^(TL_topPeerCategoryPeers *obj, NSUInteger idx, BOOL * _Nonnull stop1) {
                    
                    BOOL isCurrentCategory = NO;
                    
                    if([peer isKindOfClass:[TL_peerUser class]]) {
                        if(user.isBot && user.isBotInlinePlaceholder) {
                            isCurrentCategory = [obj.category isKindOfClass:[TL_topPeerCategoryBotsInline class]];
                            
                            if(isCurrentCategory)
                                currentClass = [TL_topPeerCategoryBotsInline class];
                            
                        } else if(user.isBot) {
                            isCurrentCategory = [obj.category isKindOfClass:[TL_topPeerCategoryBotsPM class]];
                            
                            if(isCurrentCategory)
                            currentClass = [TL_topPeerCategoryBotsPM class];
                        }
                        else {
                            isCurrentCategory = [obj.category isKindOfClass:[TL_topPeerCategoryCorrespondents class]];
                            
                            if(isCurrentCategory)
                                currentClass = [TL_topPeerCategoryCorrespondents class];
                        }
                    }
                    
                    if(!isCurrentCategory) {
                        isCurrentCategory =([peer isKindOfClass:[TL_peerChat class]] && [obj.category isKindOfClass:[TL_topPeerCategoryGroups class]]);
                        
                        if(isCurrentCategory)
                        currentClass = [TL_topPeerCategoryGroups class];
                    }
                    
                    if(!isCurrentCategory) {
                        isCurrentCategory = isCurrentCategory || ([peer isKindOfClass:[TL_peerChannel class]] && [obj.category isKindOfClass:[TL_topPeerCategoryChannels class]]);
                        
                        if(isCurrentCategory)
                        currentClass = [TL_topPeerCategoryChannels class];
                        
                    }
                    
                    
                    if(isCurrentCategory) {
                        [obj.peers enumerateObjectsUsingBlock:^(TL_topPeer *topPeer, NSUInteger idx, BOOL * _Nonnull stop2) {
                            
                            
                            if(topPeer.peer.peer_id == peer.peer_id) {
                                topPeer.rating+= drating;
                                
                                
                                *stop1 = YES;
                                *stop2 = YES;
                                
                                saved = YES;
                                
                            }
                            
                        }];
                        
                        if(!saved) {
                            [obj.peers addObject:[TL_topPeer createWithPeer:peer rating:drating]];
                            saved = YES;
                        }
                        
                        [top enumerateObjectsUsingBlock:^(TL_topPeerCategoryPeers *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            [obj.peers sortUsingComparator:^NSComparisonResult(TL_topPeer *obj1, TL_topPeer *obj2) {
                                return obj1.rating < obj2.rating ? NSOrderedDescending : obj1.rating > obj2.rating ? NSOrderedAscending : NSOrderedSame;
                            }];
                        }];
                        
                        [transaction setObject:top forKey:@"categories" inCollection:TOP_PEERS];
                        
                    }
                    
                }];
//                
//                if(!saved) {
//                    [transaction removeObjectForKey:@"categories" inCollection:TOP_PEERS];
//                }
            }

        } @catch (NSException *exception) {
            
        }
        
       
        
    }];
    
}




+(void)syncTopCategories:(void (^)(NSArray *categories))completeHandler {
    

    
    dispatch_queue_t dqueue = dispatch_get_current_queue();
    
    [[Storage yap] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        
        @try {
            NSMutableArray *top = [transaction objectForKey:@"categories" inCollection:TOP_PEERS];
            
            __block int acc = 0;
            
            [top enumerateObjectsUsingBlock:^(TL_topPeerCategoryPeers *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj.peers sortUsingComparator:^NSComparisonResult(TL_topPeer *obj1, TL_topPeer *obj2) {
                    return obj1.rating < obj2.rating ? NSOrderedDescending : obj1.rating > obj2.rating ? NSOrderedAscending : NSOrderedSame;
                }];
                
                [obj.peers enumerateObjectsUsingBlock:^(TL_topPeer *topPeer, NSUInteger idx, BOOL * _Nonnull stop) {
                    acc = (acc * 20261) + abs(topPeer.peer.peer_id);
                }];
                
            }];
            
            
            acc = (int)(acc & 0x7FFFFFFF);
            
            int offset = 0;
            
            dispatch_async(dqueue, ^{
                completeHandler(top);
            });
            
            if([[transaction objectForKey:@"dt" inCollection:TOP_PEERS] intValue] + 24*60*60 < [[MTNetwork instance] getTime]) {
                [RPCRequest sendRequest:[TLAPI_contacts_getTopPeers createWithFlags:(1 << 0) | (1 << 2) offset:offset limit:100 n_hash:acc] successHandler:^(id request, TL_contacts_topPeers *response) {
                    
                    if([response isKindOfClass:[TL_contacts_topPeers class]]) {
                        [SharedManager proccessGlobalResponse:response];
                        
                        [transaction setObject:response.categories forKey:@"categories" inCollection:TOP_PEERS];
                        [transaction setObject:@([[MTNetwork instance] getTime]) forKey:@"dt" inCollection:TOP_PEERS];
                        
                        dispatch_async(dqueue, ^{
                            completeHandler(response.categories);
                        });
                        
                    } else {
                        dispatch_async(dqueue, ^{
                            completeHandler(top);
                        });
                    }
                    
                    
                    
                } errorHandler:^(id request, RpcError *error) {
                    
                }];
            }


        } @catch (NSException *exception) {
            
        }
        
    }];
    
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
    
    TL_localMessageService *msg = [TL_localMessageService createWithFlags:TGNOFLAGSMESSAGE n_id:[MessageSender getFutureMessageId] from_id:chat.admin_id to_id:[TL_peerSecret createWithChat_id:chat.n_id] reply_to_msg_id:0 date:[[MTNetwork instance] getTime] action:[TL_messageActionEncryptedChat createWithTitle:title] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() dstate:DeliveryStatePending];
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
            
            TL_conversation *dialog = [TL_conversation createWithPeer:[TL_peerSecret createWithChat_id:params.n_id] top_message:-1 unread_count:0 last_message_date:[[MTNetwork instance] getTime] notify_settings:[TL_peerNotifySettingsEmpty create] last_marked_message:0 top_message_fake:-1 last_marked_date:[[MTNetwork instance] getTime] sync_message_id:0 read_inbox_max_id:0 read_outbox_max_id:0 draft:[TL_draftMessageEmpty create] lastMessage:nil];
            
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

+ (void)sendFilesByPath:(NSArray *)files dialog:(TL_conversation *)dialog isMultiple:(BOOL)isMultiple asDocument:(BOOL)asDocument messagesViewController:(MessagesViewController *)messagesViewController {
   
    
   
    
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
            
            [self sendFilesByPath:files dialog:dialog isMultiple:isMultiple asDocument:asDocument messagesViewController:messagesViewController];
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
        [messagesViewController sendImage:file forConversation:dialog file_data:nil isMultiple:isMultiple addCompletionHandler:nil];
        next();
        return;
        
    }
    
    if([videoTypes() containsObject:pathExtension] && !asDocument) {
        [messagesViewController sendVideo:file forConversation:dialog];
         next();
       
        return;
    }
    
    [messagesViewController sendDocument:file forConversation:dialog];
    next();
    
}

+(BOOL)sendDraggedFiles:(id <NSDraggingInfo>)sender dialog:(TL_conversation *)dialog asDocument:(BOOL)asDocument  messagesViewController:(MessagesViewController *)messagesViewController {
    NSPasteboard *pboard;
    
    if(![dialog canSendMessage])
        return NO;
    
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        BOOL isMultiple = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.pathExtension.lowercaseString IN (%@)",imageTypes()]].count > 1;
        [self sendFilesByPath:files dialog:dialog isMultiple:isMultiple asDocument:asDocument messagesViewController:messagesViewController];
        
    } else if([[pboard types] containsObject:NSTIFFPboardType]) {
        NSData *tiff = [pboard dataForType:NSTIFFPboardType];
        
        if(!asDocument) {
            [messagesViewController
             sendImage:nil forConversation:dialog file_data:tiff];
        } else {
            
            NSString *path = exportPath(rand_long(), @"jpg");
            
            [tiff writeToFile:path atomically:YES];
            
        [messagesViewController sendDocument:path forConversation:dialog];
        }
        
        
    }
    
    return YES;
}


static TGLocationRequest *locationRequest;



+(RPCRequest *)proccessInlineKeyboardButton:(TLKeyboardButton *)keyboard messagesViewController:(MessagesViewController *)messagesViewController conversation:(TL_conversation *)conversation messageId:(int)messageId handler:(void (^)(TGInlineKeyboardProccessType type))handler {
    
    
    if([keyboard isKindOfClass:[TL_keyboardButtonCallback class]]) {
        
        handler(TGInlineKeyboardProccessingType);
        
        return [RPCRequest sendRequest:[TLAPI_messages_getBotCallbackAnswer createWithPeer:conversation.inputPeer msg_id:messageId data:keyboard.data] successHandler:^(id request, TL_messages_botCallbackAnswer *response) {
            
            if([response isKindOfClass:[TL_messages_botCallbackAnswer class]] && response.message.length > 0) {
                if(response.isAlert)
                    alert(appName(), response.message);
                else
                    if(response.message.length > 0)
                        [Notification perform:SHOW_ALERT_HINT_VIEW data:@{@"text":response.message,@"color":NSColorFromRGB(0x4ba3e2)}];
            }
            
                handler(TGInlineKeyboardSuccessType);
            
            
        } errorHandler:^(id request, RpcError *error) {
            handler(TGInlineKeyboardErrorType);
        }];
        
    } else if([keyboard isKindOfClass:[TL_keyboardButtonUrl class]]) {
        
        if([keyboard.url rangeOfString:@"telegram.me/"].location != NSNotFound || [keyboard.url hasPrefix:@"tg://"]) {
            open_link(keyboard.url);
        } else {
            confirm(appName(), [NSString stringWithFormat:NSLocalizedString(@"Link.ConfirmOpenExternalLink", nil),keyboard.url], ^{
                
                open_link(keyboard.url);
                
            }, nil);
        }
        
        
        handler(TGInlineKeyboardSuccessType);
        
    } else if([keyboard isKindOfClass:[TL_keyboardButtonRequestGeoLocation class]]) {
        
        [SettingsArchiver requestPermissionWithKey:kPermissionInlineBotGeo peer_id:conversation.peer_id handler:^(bool success) {
            
            if(success) {
                
                handler(TGInlineKeyboardProccessingType);
                
                locationRequest = [[TGLocationRequest alloc] init];
                
                [locationRequest startRequestLocation:^(CLLocation *location) {
                    
                    [messagesViewController sendLocation:location.coordinate forConversation:conversation];
                    
                    handler(TGInlineKeyboardSuccessType);
                    
                } failback:^(NSString *error) {
                    
                    handler(TGInlineKeyboardErrorType);
                    
                    alert(appName(), error);
                    
                }];
                
            } else {
                handler(TGInlineKeyboardErrorType);
            }
            
        }];
        
        
    } else if([keyboard isKindOfClass:[TL_keyboardButtonRequestPhone class]]) {
        
        
        [SettingsArchiver requestPermissionWithKey:kPermissionInlineBotContact peer_id:conversation.peer_id handler:^(bool success) {
            
            if(success) {
                
                [messagesViewController shareContact:[UsersManager currentUser] forConversation:conversation callback:nil];
                
                handler(TGInlineKeyboardSuccessType);
            }
            
        }];
        
    } else if([keyboard isKindOfClass:[TL_keyboardButton class]]) {
        [messagesViewController sendMessage:keyboard.text forConversation:conversation];
        
        handler(TGInlineKeyboardSuccessType);
    } else if([keyboard isKindOfClass:[TL_keyboardButtonSwitchInline class]]) {
        
        if(messagesViewController.class == [TGContextMessagesvViewController class]) {
            
            TGContextMessagesvViewController *m = (TGContextMessagesvViewController *)messagesViewController;
            
            [m.contextModalView didNeedCloseAndSwitch:keyboard];
        } else {
            [[Telegram rightViewController] showInlineBotSwitchModalView:conversation.user keyboard:keyboard];
        }
        
    }
    
    return nil;
}



+(void)drop {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secret_message_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
