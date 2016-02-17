
//
//  FileUtils.m
//  Telegram P-Edition
//
//  Created by keepcoder on 04.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "FileUtils.h"
#import "TLFileLocation+Extensions.h"
#import "Crypto.h"
#import "TMMediaController.h"
#include <IOKit/IOKitLib.h>

#import <CoreFoundation/CoreFoundation.h>
#import <MtProtoKit/MTEncryption.h>
#import "NSData+Extensions.h"
#import "TGStickerPackModalView.h"
#import "ComposeActionAddUserToGroupBehavior.h"
#import "TGHeadChatPanel.h"
#include "opus.h"
#include "opusfile.h"
#import "TGAudioWaveform.h"
@implementation OpenWithObject

-(id)initWithFullname:(NSString *)fullname app:(NSURL *)app icon:(NSImage *)icon {
    if(self = [super init]) {
        _fullname = fullname;
        _app = app;
        _icon = icon;
    }
    
    return self;
}


@end


@interface FileUtils ()
@property (nonatomic,strong) NSDictionary *mimeTypes;
@property (nonatomic,strong) NSDictionary *extensions;
@end

@implementation FileUtils


NSString *const TGImagePType = @"TGImagePasteType";
NSString *const TGImportCardPrefix = @"tg://resolve?domain=";
NSString *const TGImportShareLinkPrefix = @"tg://msg_url?url=";
NSString *const TGJoinGroupPrefix = @"tg://join?invite=";
NSString *const TGStickerPackPrefix = @"tg://addstickers?set=";
NSString *const TLUserNamePrefix = @"@";
NSString *const TLHashTagPrefix = @"#";
NSString *const TLBotCommandPrefix = @"/";






+(BOOL)checkNormalizedSize:(NSString *)path checksize:(int)checksize {
    int pathsize = (int)fileSize(path);
    int dif = abs(pathsize-checksize);
    return pathsize != 0 && dif <= 16; //for encrypted files
}


+ (void)showPanelWithTypes:(NSArray *)types completionHandler:(void (^)(NSArray *paths))handler forWindow:(NSWindow *)window {
    
    [[TMMediaController controller] close];
    
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    
    
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setCanCreateDirectories:YES];
    if(types.count > 0)
        [openDlg setAllowedFileTypes:types];
    
    [openDlg setAllowsMultipleSelection:YES];
    [openDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArray* urls = [openDlg URLs];
            
            NSMutableArray *paths = [[NSMutableArray alloc] init];
            
            for(int i = 0; i < [urls count]; i++ ) {
                NSString *path = [[urls objectAtIndex:i] path];
                NSString *pathExtension = [[path pathExtension] lowercaseString];
                
                 if(types) {
                    if([types containsObject:pathExtension])
                        [paths addObject:path];
                } else {
                    [paths addObject:path];
                }
            }
            
            handler(paths);
        }
    }];
}


+ (void)showChooseFolderPanel:(void (^)(NSString * result))handler forWindow:(NSWindow *)window {
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanCreateDirectories:YES];
    
    [openDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *url = [openDlg URL];
            handler([url path]);
        } else {
            handler(nil);
        }
    }];
}


+ (void)showPanelWithTypes:(NSArray *)types completionHandler:(void (^)(NSArray * paths))handler {
    [self showPanelWithTypes:types completionHandler:handler forWindow:[NSApp keyWindow]];
}



NSString* mediaFilePath(TL_localMessage *message) {
    if(message.media.document.audioAttr.isVoice) {
        return [NSString stringWithFormat:@"%@/%lu_%lu.ogg",path(),message.media.document.n_id,message.media.document.access_hash];
    }
    if([message.media isKindOfClass:[TL_messageMediaVideo class]]) {
        return [NSString stringWithFormat:@"%@/%lu_%lu.mp4",path(),message.media.video.n_id,message.media.video.access_hash];
    }
    
    if([message.media isKindOfClass:[TL_messageMediaDocument class]] || [message.media isKindOfClass:[TL_messageMediaDocument_old44 class]] || message.media.bot_result.document) {
        
        TLDocument *document = [message.media isKindOfClass:[TL_messageMediaBotResult class]] ? message.media.bot_result.document : message.media.document;
        
        
        id nondocValue = non_documents_mime_types()[document.mime_type];
        
        BOOL hasAttr = YES;
        
        if([nondocValue isKindOfClass:[TLDocumentAttribute class]]) {
            hasAttr = [document attributeWithClass:[nondocValue class]] != nil;
        }
        
        if((nondocValue != nil && hasAttr )) {
            
            return [NSString stringWithFormat:@"%@/%ld.%@",path(),document.n_id,[document.mime_type substringFromIndex:[document.mime_type rangeOfString:@"/"].location + 1]];
            
        }
        
        if([document attributeWithClass:[TL_documentAttributeVideo class]] != nil && [document.mime_type hasPrefix:@"video"]) {
            return [NSString stringWithFormat:@"%@/%ld.%@",path(),document.n_id,[document.mime_type substringFromIndex:[document.mime_type rangeOfString:@"/"].location + 1]];
        }
        
        if([message isKindOfClass:[TL_destructMessage class]] || [message.media.document.mime_type hasPrefix:@"image/gif"] || [message.media.document.mime_type hasPrefix:@"audio"]) {
            
            TL_documentAttributeFilename *name = (TL_documentAttributeFilename *) [message.media.document attributeWithClass:[TL_documentAttributeFilename class]];
            
            return [NSString stringWithFormat:@"%@/%ld_%@",path(),message.media.document.n_id,name.file_name];
        }
        
        return [FileUtils documentName:document];
    }
    
    if([message.media isKindOfClass:[TL_messageMediaBotResult class]]) {
        if([message.media.bot_result isKindOfClass:[TL_botInlineMediaResultPhoto class]]) {
            TL_photoSize *size = [message.media.bot_result.photo.sizes lastObject];
            return locationFilePath(size.location, @"jpg");
        } else if([message.media.bot_result isKindOfClass:[TL_botInlineMediaResultDocument class]]) {
            
            NSRange srange = [message.media.bot_result.document.mime_type rangeOfString:@"/"];
            
            NSString *ext = srange.location == NSNotFound ? @"file" : [message.media.bot_result.document.mime_type substringFromIndex:srange.location + 1];
            
            return [NSString stringWithFormat:@"%@/%ld.%@",path(),message.media.bot_result.document.n_id,ext];
        } else if([message.media.bot_result isKindOfClass:[TL_messageMediaBotResult class]]) {
            return [NSString stringWithFormat:@"%@/%ld.%@",path(),[message.media.bot_result.content_url hash],[message.media.bot_result.content_url pathExtension]];
        } else
            return path_for_external_link(message.media.bot_result.content_url);
    }
    
    if([message.media isKindOfClass:[TL_messageMediaPhoto class]]) {
        TL_photoSize *size = [message.media.photo.sizes lastObject];
        return locationFilePath(size.location, @"jpg");
    }
    
    return nil;
}

NSDictionary *non_documents_mime_types() {
    
    static NSDictionary *res;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        res = @{@"video/mp4":[TL_documentAttributeAnimated create],@"image/gif":@(0),@"webp:image/webp":@(0),@"audio/ogg":[TL_documentAttributeAudio class]};
    });
    
    return res;
};

void removeMessageMedia(TL_localMessage *message) {
    if(message) {
        NSString *path = mediaFilePath(message);
        
        if(path != nil &&![message.media.document isKindOfClass:[TL_outDocument class]]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        
        
    }
    
}


NSString* documentPath(TLDocument *document) {
    NSString *fileName = document.file_name;
    
    if([document isKindOfClass:[TL_outDocument class]]) {
        NSString *path_for_file = ((TL_outDocument *)document).file_path;
        if(isPathExists(path_for_file)) {
            return path_for_file;
        }
    }
    
    
    
    NSArray *item = [fileName componentsSeparatedByCharactersInSet:
                     [NSCharacterSet characterSetWithCharactersInString:@"."]];
    NSString *extenstion = extensionForMimetype(document.mime_type);
    
    if(item.count >= 2) {
        return [NSString stringWithFormat:@"%@/%@",[SettingsArchiver documentsFolder],document.file_name];
    }
    
    return [NSString stringWithFormat:@"%@/%@.%@",[SettingsArchiver documentsFolder],item[0],extenstion];
    
    
    
}

NSString* dp() {
    //  NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *downloadPath = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES)[0];
    // NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    // NSString *path = [[applicationSupportPath stringByAppendingPathComponent:applicationName] stringByAppendingPathComponent:@"documents"];
    
    
    // if (!) {
    
    // }
    return downloadPath;
}



+(NSString *)path {
    return path();
}




+(NSString *)documentName:(TLDocument *)document {
    return [self documentName:document number:0];
}

+(NSString *)documentName:(TLDocument *)document number:(int)number {
    NSString *doc = documentPath(document);
    NSString *pathExtension = [doc pathExtension];
    NSString *name = [doc stringByDeletingPathExtension];
    
    NSString *path = number > 0 ? [NSString stringWithFormat:@"%@ (%d).%@",name,number,pathExtension] : documentPath(document);
    
    if([self checkNormalizedSize:path checksize:document.size])
        return path;
    
    
    
    if(isPathExists(path))
        return [self documentName:document number:++number];
    return path;
}




void alert_bad_files(NSArray *bad_files) {
    NSString *bad_string = [bad_files componentsJoinedByString:@", "];
    NSString *localize = NSLocalizedString(@"Conversation.Send.FilesSizeError", nil);
    
    alert(NSLocalizedString(@"App.MaxFileSize", nil),[NSString stringWithFormat:localize, bad_string]);
}

void confirm(NSString *text, NSString *info, void (^block)(void), void (^cancelBlock)(void)) {
    
    [ASQueue dispatchOnMainQueue:^{
        NSAlert *alert = [NSAlert alertWithMessageText:text ? text : @"" informativeText:info ? info : @"" block:^(id result) {
            if([result intValue] == 1000)
                block();
            else if(cancelBlock)
                cancelBlock();
        }];
        [alert addButtonWithTitle:NSLocalizedString(@"Yes", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"No", nil)];
        [alert show];
    }];
    
}

void alert(NSString *text, NSString *info) {
    
    [ASQueue dispatchOnMainQueue:^{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setMessageText:text.length > 0 ? text : appName()];
        [alert setInformativeText:info];
        [alert beginSheetModalForWindow:[NSApp keyWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
    }];
    
}

+ (NSString *)dataMD5:(NSData *)data {
    NSUInteger size = [data length];
    
    NSString *md5 = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] md5];
    return [[NSString stringWithFormat:@"MD5_%@_%lu", md5, (unsigned long)size] md5];
    
}



NSDictionary *getUrlVars(NSString *url) {
    
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    
    if([url rangeOfString:@"?"].location == NSNotFound) {
        return @{@"domain":url,@"showProfile":@(1)};
    }
    
    NSArray *hashes = [[url substringFromIndex:[url rangeOfString:@"?"].location + 1] componentsSeparatedByString:@"&"];;
    
    for (int i = 0; i < hashes.count; i++) {
        
        NSArray *hash = [hashes[i] componentsSeparatedByString:@"="];
        d[hash[0]] = hash[1];
    }
    return d;
}


/*
 ~/Library/Sounds
 /Library/Sounds
 /Network/Library/Sounds
 /System/Library/Sounds
 */

NSArray * soundsList() {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.aiff'"];
    
    [list addObject:@"DefaultSoundName"];
    
    [list addObject:@"None"];
    
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:@"~/Library/Sounds" error:nil];
    [list addObjectsFromArray:[dirContents filteredArrayUsingPredicate:fltr]];
    
    dirContents = [fm contentsOfDirectoryAtPath:@"/Library/Sounds" error:nil];
    [list addObjectsFromArray:[dirContents filteredArrayUsingPredicate:fltr]];
    
    dirContents = [fm contentsOfDirectoryAtPath:@"/Network/Library/Sounds" error:nil];
    [list addObjectsFromArray:[dirContents filteredArrayUsingPredicate:fltr]];
    
    dirContents = [fm contentsOfDirectoryAtPath:@"/System/Library/Sounds" error:nil];
    [list addObjectsFromArray:[dirContents filteredArrayUsingPredicate:fltr]];
    
    
    
    for (int i = 0; i < list.count; i++) {
        list[i] = [list[i] stringByDeletingPathExtension];
    }
    
    return [list sortedArrayUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        if([obj2 isEqualToString:[SettingsArchiver soundNotification]]) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
        
    }];
    
}
void playSentMessage(BOOL play) {
    
//    static ASQueue *queue;
//    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        queue = [[ASQueue alloc] initWithName:"soundQueue"];
//    });
    
   // [queue dispatchOnQueue:^{
        static NSSound *sound ;
        
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            sound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sent" ofType:@"caf"] byReference:YES];
            [sound setVolume:1.0f];
        });
        if(play && [SettingsArchiver checkMaskedSetting:SoundEffects])
            [sound play];
   // }];
    
}

NSArray *urlSchemes() {
    NSString *scheme = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"url-schemes.txt"]];
    return [[[NSString alloc] initWithContentsOfFile:scheme encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}


TelegramWindow *appWindow() {
    
    TelegramWindow *window = (TelegramWindow *) [NSApp keyWindow];
    
    if(!window)
    {
        window = (TelegramWindow *)[Telegram delegate].mainWindow;
    }
    
    if(![window isKindOfClass:[TelegramWindow class]]) {
        window = [window respondsToSelector:@selector(window)] ? [window performSelector:@selector(window)] : window;
        
        if(![window isKindOfClass:[TelegramWindow class]]) {
            window = (TelegramWindow *)[Telegram delegate].mainWindow;
        }
        
    }
    
    return window;
}

void open_post(NSString *username,int postId) {
    if(username.length > 0 && postId > 0) {
        
        __block TLChat *chat = [ChatsManager findChatByName:username];
        
        dispatch_block_t performExport = ^{
            
            TL_localMessage *message = [[TL_localMessage alloc] init];
            message.to_id = [TL_peerChannel createWithChannel_id:chat.n_id];
            message.n_id = postId;
            
            [appWindow().navigationController showMessagesViewController:chat.dialog withMessage:message];
            
        };
        
        if(chat)
            performExport();
        else {
        
            [TMViewController showModalProgress];
            
            [RPCRequest sendRequest:[TLAPI_contacts_resolveUsername createWithUsername:username] successHandler:^(RPCRequest *request, TL_contacts_resolvedPeer *response) {
                
                [TMViewController hideModalProgress];
                
                [SharedManager proccessGlobalResponse:response];
                
                if([response.peer isKindOfClass:[TL_peerChannel class]]) {
                    chat = [response.chats firstObject];
                }
                
                if(chat)
                    performExport();
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                [TMViewController hideModalProgress];
            } timeout:4];

        
        }
    }
}

void open_card(NSString *link) {
    
    
    NSArray *card = encodeCard(link);
    
    if(card) {
        
        [TMViewController showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_contacts_importCard createWithExport_card:[card mutableCopy]] successHandler:^(RPCRequest *request, id response) {
            
            [TMViewController hideModalProgress];
            
            dispatch_after_seconds(0.2,^ {
                if(![response isKindOfClass:[TL_userEmpty class]]) {
                    [[UsersManager sharedManager] add:@[response]];
                    
                    
                    TLUser *user = [[UsersManager sharedManager] find:[(TLUser *)response n_id]];
                    
                    [appWindow().navigationController showInfoPage:user.dialog];
                    
                    
                } else {
                    alert(NSLocalizedString(@"CardImport.ErrorTextUserNotExist", nil), NSLocalizedString(@"CardImport.ErrorDescUserNotExist", nil));
                }
            });
            
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
            [TMViewController hideModalProgress];
            
            dispatch_after_seconds(0.2, ^{
                if(error.error_code == 400) {
                    alert(NSLocalizedString(@"CardImport.ErrorTextUserNotExist", nil), NSLocalizedString(@"CardImport.ErrorDescUserNotExist", nil));
                }
            });
            
            
            
        } timeout:4];
    }
    
    
}

void join_group_by_hash(NSString * hash) {
    
    
        [TMViewController showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_messages_checkChatInvite createWithN_hash:hash] successHandler:^(RPCRequest *request, id response) {
            
            if([response isKindOfClass:[TL_chatInviteAlready class]] && ![(TLChat *)[response chat] left]) {
                
                [appWindow().navigationController showMessagesViewController:[[DialogsManager sharedManager] findByChatId:[[response chat] n_id]]];
                
                
                [TMViewController hideModalProgress];
    
            } else if([response isKindOfClass:[TL_chatInvite class]]) {
                
                [TMViewController hideModalProgress];
                
                confirm(appName(), [NSString stringWithFormat:NSLocalizedString(@"Confirm.ConfrimToJoinGroup", nil),[response title]], ^{
                    
                    [TMViewController showModalProgress];
                    
                    [RPCRequest sendRequest:[TLAPI_messages_importChatInvite createWithN_hash:hash] successHandler:^(RPCRequest *request, TLUpdates *response) {
                        
                        if([response chats].count > 0) {
                            TLChat *chat = [response chats][0];
                            
                            TL_conversation *conversation = chat.dialog;
                            
                            [appWindow().navigationController showMessagesViewController:conversation];
                            
                            dispatch_after_seconds(0.2, ^{
                                
                                [TMViewController hideModalProgressWithSuccess];
                            });
                        } else {
                            [TMViewController hideModalProgress];
                        }
                        
                        
                        
                    } errorHandler:^(RPCRequest *request, RpcError *error) {
                        [TMViewController hideModalProgress];
                        
                        if(error.error_code == 400) {
                            alert(appName(), NSLocalizedString(error.error_msg, nil));
                        }
                        
                    }];
                    
                    
                }, nil);
            }
            
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
            [TMViewController hideModalProgress];
            
            if(error.error_code == 400) {
                alert(appName(), NSLocalizedString(error.error_msg, nil));
            }
            
        }];
    
}


void add_sticker_pack_by_name(TLInputStickerSet *set) {
    
    
    [TMViewController showModalProgress];
    
    [RPCRequest sendRequest:[TLAPI_messages_getStickerSet createWithStickerset:set] successHandler:^(id request, id response) {
        
        [TMViewController hideModalProgress];
      
        dispatch_after_seconds(0.2, ^{
            TGStickerPackModalView *stickerModalView = [[TGStickerPackModalView alloc] init];
            
            [stickerModalView setStickerPack:response];
            stickerModalView.canSendSticker = YES;
            [stickerModalView show:appWindow() animated:YES];

        });
        
        
        
    } errorHandler:^(id request, RpcError *error) {
        
        [TMViewController hideModalProgress];
        
    } timeout:5];
    
}

void open_user_by_name(NSDictionary *params) {
    
    __block id obj = [Telegram findObjectWithName:params[@"domain"]];
    
    dispatch_block_t showConversation = ^ {
        
        if([obj isKindOfClass:[TLUser class]]) {
            
            TLUser *user = obj;
            
            if(user.isBot && params[@"start"]) {
                [appWindow().navigationController showMessagesViewController:user.dialog];
                [appWindow().navigationController.messagesViewController showBotStartButton:params[@"start"] bot:user];
            } else if(user.isBot && params[@"startgroup"] && (user.flags & TGBOTGROUPBLOCKED) == 0) {
                [[Telegram rightViewController] showComposeAddUserToGroup:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionAddUserToGroupBehavior class] filter:nil object:user reservedObjects:@[params]]];
            } else if(params[@"open_profile"]) {
                [appWindow().navigationController showInfoPage:user.dialog];
            } else {
               [appWindow().navigationController showMessagesViewController:user.dialog];
            }
        } else {
            [appWindow().navigationController showMessagesViewController:((TLChat *)obj).dialog];
        }
        
        
    };
    
    
    dispatch_block_t showInfo = ^{
      
        [appWindow().navigationController showInfoPage:[obj dialog]];
        
    };
    
    
    dispatch_block_t perform = ^ {
      
        if(params[@"showProfile"])
            showInfo();
        else
            showConversation();
        
    };
    
    if(false) {
        
        perform();
        
    } else {
        [TMViewController showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_contacts_resolveUsername createWithUsername:params[@"domain"]] successHandler:^(RPCRequest *request, TL_contacts_resolvedPeer *response) {
            
            [TMViewController hideModalProgress];
            
            [SharedManager proccessGlobalResponse:response];
            
            dispatch_after_seconds(0.2,^ {
                
                if([response.peer isKindOfClass:[TL_peerChannel class]]) {
                    obj = [response.chats firstObject];
                } else if([response.peer isKindOfClass:[TL_peerUser class]]) {
                    obj = [response.users firstObject];
                }
                
                if(obj) {
                     perform();
                } else {
                    alert(NSLocalizedString(@"UserNameExport.UserNameNotFound", nil), NSLocalizedString(@"UserNameExport.UserNameNotFoundDescription", nil));
                }
                
            });
            
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
            [TMViewController hideModalProgress];
            
            dispatch_after_seconds(0.2, ^{
                if(error.error_code == 400) {
                    alert(NSLocalizedString(@"UserNameExport.UserNameNotFound", nil), NSLocalizedString(@"UserNameExport.UserNameNotFoundDescription", nil));
                }
            });
            
            
        } timeout:4];
    }
    
    
}

void share_link(NSString *url, NSString *text) {
    [[Telegram rightViewController] showShareLinkModalView:url text:text];
}

void determinateURLLink(NSString *link) {
    
    
    if([link hasPrefix:TGImportCardPrefix]) {
        
        NSDictionary *vars = getUrlVars(link);
        
        if(vars[@"post"] && [vars[@"post"] intValue] > 0) {
            open_post(vars[@"domain"], [vars[@"post"] intValue]);
        } else {
            open_user_by_name(vars);
        }
        
        [[NSApplication sharedApplication]  activateIgnoringOtherApps:YES];
        [[[Telegram delegate] mainWindow] deminiaturize:[Telegram delegate]];
        return;
    }
    
    if([link hasPrefix:TGImportShareLinkPrefix]) {
        NSDictionary *vars = getUrlVars(link);
        
        if([vars[@"url"] length] > 0 && [vars[@"text"] length] > 0) {
            share_link([vars[@"url"] stringByDecodingURLFormat], [vars[@"text"] stringByDecodingURLFormat]);
            
            [[NSApplication sharedApplication]  activateIgnoringOtherApps:YES];
            [[[Telegram delegate] mainWindow] deminiaturize:[Telegram delegate]];
            return;
        }
    }
    
    if([link hasPrefix:TGJoinGroupPrefix]) {
        join_group_by_hash([link substringFromIndex:TGJoinGroupPrefix.length]);
        [[NSApplication sharedApplication]  activateIgnoringOtherApps:YES];
        [[[Telegram delegate] mainWindow] deminiaturize:[Telegram delegate]];
        return;
    }
    
    if([link hasPrefix:TGStickerPackPrefix]) {
        add_sticker_pack_by_name([TL_inputStickerSetShortName createWithShort_name:[link substringFromIndex:TGStickerPackPrefix.length]]);
        [[NSApplication sharedApplication]  activateIgnoringOtherApps:YES];
        [[[Telegram delegate] mainWindow] deminiaturize:[Telegram delegate]];
        return;
    }
    
}

void open_link(NSString *link) {
    
    
    if([link hasPrefix:@"USER_PROFILE:"]) {
        
        [TMInAppLinks parseUrlAndDo:link];
        
        return;
    }
    
    if([link hasPrefix:@"openWithPeer:"]) {
        
        NSString *peer_str = [link substringFromIndex:@"openWithPeer:".length];
        int peer_id = [[peer_str substringFromIndex:[peer_str rangeOfString:@":"].location+1] intValue];
        Class peer = NSClassFromString([peer_str substringToIndex:[peer_str rangeOfString:@":"].location]);
        if(peer == [TL_peerUser class]) {
            
            TLUser *user = [[UsersManager sharedManager] find:peer_id];
            
            TL_conversation *conversation = user.dialog;
            
            [appWindow().navigationController showInfoPage:conversation];
            
        } else if(peer == [TL_peerChat class] || peer == [TL_peerChannel class]) {
            
            TLChat *chat = [[ChatsManager sharedManager] find:abs(peer_id)];
            
            if(chat.username.length == 0 && chat.isBroadcast && chat.dialog.isInvisibleChannel)
                return;
            
            if(appWindow().navigationController.messagesViewController.conversation.peer_id == peer_id) {
                 [appWindow().navigationController showInfoPage:chat.dialog];
            } else {
                [appWindow().navigationController showMessagesViewController:chat.dialog];
            }
            
        }
        
        return;
    }
    
    if([link hasPrefix:TGImportCardPrefix]) {
        
        open_card([link substringFromIndex:TGImportCardPrefix.length]);
        
        return;
    }
    
    
    if([link hasPrefix:TLUserNamePrefix]) {
        open_user_by_name(@{@"domain":[link substringFromIndex:TLUserNamePrefix.length],@"open_profile":@(1)});
        return;
    }
    
    if([link hasPrefix:TGJoinGroupPrefix]) {
        join_group_by_hash([link substringFromIndex:TGJoinGroupPrefix.length]);
        return;
    }
    
    
    if([link hasPrefix:TLHashTagPrefix]) {
        
        [[Telegram leftViewController] showTabControllerAtIndex:1];
        
        StandartViewController *controller = (StandartViewController *) [[Telegram leftViewController] currentTabController];
        
        [((StandartViewController *)controller).searchViewController dontLoadHashTagsForOneRequest];
                
        [controller searchByString:link];
        
        if([Telegram isSingleLayout]) {
            [[Telegram rightViewController] showNotSelectedDialog];
        }
        
        return;
    }
    
    
    if([link hasPrefix:TLBotCommandPrefix]) {
        [appWindow().navigationController.messagesViewController sendMessage:link forConversation:[appWindow().navigationController.messagesViewController conversation]];
        return;
    }
    
    
    
    NSRange checkRange = [link rangeOfString:@"telegram.me/"];
    
    
    if(checkRange.location != NSNotFound) {
        
        NSString *name = [link substringFromIndex:checkRange.location + checkRange.length ];
        
        if(name.length > 0) {
            
            NSString *joinPrefix = @"joinchat/";
            NSString *stickerPrefix = @"addstickers/";
            
            
            if([name hasPrefix:joinPrefix]) {
                join_group_by_hash([name substringFromIndex:joinPrefix.length]);
                return;
            } else if([name hasPrefix:stickerPrefix]) {
                add_sticker_pack_by_name([TL_inputStickerSetShortName createWithShort_name:[name substringFromIndex:stickerPrefix.length]]);
                return;
            } else if([name rangeOfString:@"/"].location == NSNotFound) {
                
                NSMutableDictionary *user = [@{@"domain":name} mutableCopy];
                
                if([name rangeOfString:@"?"].location != NSNotFound) {
                    NSDictionary *vars = getUrlVars(name);
                    
                    user[@"domain"] = [name substringToIndex:[name rangeOfString:@"?"].location];
                   
                    [user addEntriesFromDictionary:vars];
                }
                
                open_user_by_name(user);
                return;
            } else {
                NSArray *userAndPost = [name componentsSeparatedByString:@"/"];
                
                if(userAndPost.count == 2) {
                    NSString *username = userAndPost[0];
                    int postId = [userAndPost[1] intValue];
                    
                    open_post(username,postId);
                    
                    return;
                }
            }
            
            
            
            
        }
    } else if([link hasPrefix:@"tg://"]) {
        determinateURLLink(link);
        return;
    }
    
    NSArray *schemes = urlSchemes();
    BOOL hasSchemeInLink = false;
    for (NSString *uri in schemes) {
        hasSchemeInLink = [link hasPrefix:uri];
        if (hasSchemeInLink)
            break;
    }
    
    if(![link hasPrefix:@"http"] && ![link hasPrefix:@"ftp"] && !hasSchemeInLink) {
        if(!NSStringIsValidEmail(link)) {
            link = [@"http://" stringByAppendingString:link];
        } else if(![link hasPrefix:@"mailto:"]) {
            link = [@"mailto:" stringByAppendingString:link];
        }
    }
    
    
    
    
    
    
    NSMutableString *escaped = [[link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    
    [escaped replaceOccurrencesOfString:@"%24" withString:@"$" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%26" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%2B" withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%2C" withString:@"," options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%2F" withString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%3A" withString:@":" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%3B" withString:@";" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%3D" withString:@"=" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%3F" withString:@"?" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%40" withString:@"@" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%20" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%09" withString:@"\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%23" withString:@"#" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%3C" withString:@"<" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%3E" withString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%22" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%0A" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"%25" withString:@"%" options:NSCaseInsensitiveSearch range:NSMakeRange(0, escaped.length)];
     NSURL *url = [[NSURL alloc] initWithString: escaped];
    
    
    if([SettingsArchiver checkMaskedSetting:OpenLinksInBackground]) {
        [[NSWorkspace sharedWorkspace] openURLs:@[url] withAppBundleIdentifier:nil options:NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifiers:nil];
    } else {
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
}


static inline NSString *hxURLEscape(NSString *v) {
    static CFStringRef _hxURLEscapeChars = CFSTR("￼=,!$&'()*+;@?\r\n\"<>#\t :/");
    return ((__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (__bridge CFStringRef)[v mutableCopy],
                                                                                  NULL, 
                                                                                  _hxURLEscapeChars, 
                                                                                  kCFStringEncodingUTF8));
}

BOOL zipDirectory(NSURL *directoryURL, NSString * archivePath)
{
    //Delete existing zip
    if ( [[NSFileManager defaultManager] fileExistsAtPath:archivePath] ) {
        [[NSFileManager defaultManager] removeItemAtPath:archivePath error:nil];
    }
    
    //Specify action
    NSString *toolPath = @"/usr/bin/zip";
    
    //Get directory contents
    NSArray *pathsArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[directoryURL path] error:nil];
    
    //Add arguments
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    [arguments insertObject:@"-r" atIndex:0];
    [arguments insertObject:archivePath atIndex:0];
    for ( NSString *filePath in pathsArray ) {
        [arguments addObject:filePath]; //Maybe this would even work by specifying relative paths with ./ or however that works, since we set the working directory before executing the command
        //[arguments insertObject:@"-j" atIndex:0];
    }
    
    //Switch to a relative directory for working.
    NSString *currentDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:[directoryURL path]];
    //MTLog(@"dir %@", [[NSFileManager defaultManager] currentDirectoryPath]);
    
    //Create
    NSTask *task = [[NSTask alloc] init] ;
    [task setLaunchPath:toolPath];
    [task setArguments:arguments];
    
    //Run
    [task launch];
    [task waitUntilExit];
    
    //Restore normal path
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:currentDirectory];
    
    //Update filesystem
    [[NSWorkspace sharedWorkspace] noteFileSystemChanged:archivePath];
    
    return ([task terminationStatus] == 0);
}


BOOL unzip(NSString * zipFile, NSString * destination)
{
    
    NSTask *unzip = [[NSTask alloc] init];
    [unzip setLaunchPath:@"/usr/bin/unzip"];
    [unzip setArguments:[NSArray arrayWithObjects:@"-u", @"-d",
                         destination, zipFile, nil]];
    
    NSPipe *aPipe = [[NSPipe alloc] init];
    [unzip setStandardOutput:aPipe];
    
    [unzip launch];
    [unzip waitUntilExit];
    
    return true;
}


NSString *exportPath(long randomId, NSString *extension) {
    NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *applicationName = appName();
    NSString *exportDirectory = [[applicationSupportPath stringByAppendingPathComponent:applicationName] stringByAppendingPathComponent:@"exports"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:exportDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    
    
    return [NSString stringWithFormat:@"%@/%lu.%@",exportDirectory,randomId,extension];
}

NSString* md5sum(NSString *fp)
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/sbin/md5"];
    [task setArguments:@[fp]];
    
    NSPipe *outPipe = [[NSPipe alloc] init];
    [task setStandardOutput:outPipe];
    
    [task launch];
    NSData *data = [[outPipe fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];
    
    if ([task terminationStatus] != 0) {
        NSLog(@"NSString + MD5 : error");
        return nil;
    }
    
    NSString *str = [[NSString alloc] initWithData:data
                                          encoding:NSUTF8StringEncoding];
    
    @try {
        str = [[str substringFromIndex:[str rangeOfString:@"="].location + 1] trim];
    }
    @catch (NSException *exception) {
        str = nil;
    }
    
    return str;
}


NSString *decodeCard(NSArray *card) {
    
    __block NSString *c = @"";
    
    NSMutableArray *hex = [[NSMutableArray alloc] init];
    
    [card enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        [hex insertObject:[NSString stringWithFormat:@"%x",[obj intValue]] atIndex:idx];
    }];
    
    c = [hex componentsJoinedByString:@":"];
    
    return c;
}


NSArray *encodeCard(NSString *card) {
    NSArray *hex = [card componentsSeparatedByString:@":"];
    
    if(hex.count >= 3 && hex.count <= 10) {
        NSMutableArray *digit = [[NSMutableArray alloc] init];
        [hex enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
            
            NSScanner *scanner = [NSScanner scannerWithString:obj];
            
            int result = 0;
            
            [scanner scanHexInt:&result];
            
            
            [digit insertObject:@(result) atIndex:idx];
        }];
        
        return digit;
    }
    
    return nil;
}



+ (void) fillAppByUrl:(NSURL*)url bundle:(NSString**)bundle name:(NSString**)name version:(NSString**)version icon:(NSImage**)icon {
    NSBundle *b = [NSBundle bundleWithURL:url];
    if (b) {
        NSString *path = [url path];
        *name = [[NSFileManager defaultManager] displayNameAtPath: path];
        if (!*name) *name = (NSString*)[b objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if (!*name) *name = (NSString*)[b objectForInfoDictionaryKey:@"CFBundleName"];
        if (*name) {
            *bundle = [b bundleIdentifier];
            if (bundle) {
                *version = (NSString*)[b objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
                *icon = [[NSWorkspace sharedWorkspace] iconForFile: path];
                if (*icon && [*icon isValid]) [*icon setSize: CGSizeMake(16., 16.)];
                return;
            }
        }
    }
    *bundle = *name = *version = nil;
    *icon = nil;
}

+(NSArray *)appsForFileUrl:(NSString *)fileUrl {
    
    NSArray *appsList = (__bridge NSArray*)LSCopyApplicationURLsForURL((__bridge CFURLRef)[NSURL fileURLWithPath:fileUrl], kLSRolesAll);
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:16];
    int fullcount = 0;
    for (id app in appsList) {
        if (fullcount > 15) break;
        
        NSString *bundle = nil, *name = nil, *version = nil;
        NSImage *icon = nil;
        [FileUtils fillAppByUrl:(NSURL*)app bundle:&bundle name:&name version:&version icon:&icon];
        if (bundle && name) {
            NSString *key = [[NSArray arrayWithObjects:bundle, name, nil] componentsJoinedByString:@"|"];
            if (!version) version = @"";
            
            NSMutableDictionary *versions = (NSMutableDictionary*)[data objectForKey:key];
            if (!versions) {
                versions = [NSMutableDictionary dictionaryWithCapacity:2];
                [data setValue:versions forKey:key];
            }
            if (![versions objectForKey:version]) {
                [versions setValue:[NSArray arrayWithObjects:name, icon, app, nil] forKey:version];
                ++fullcount;
            }
        }
    }
    
    
    NSMutableArray *apps = [NSMutableArray arrayWithCapacity:fullcount];
    for (id key in data) {
        NSMutableDictionary *val = (NSMutableDictionary*)[data objectForKey:key];
        for (id ver in val) {
            NSArray *app = (NSArray*)[val objectForKey:ver];
            
            NSString *fullname = (NSString*)[app objectAtIndex:0], *version = (NSString*)ver;
            BOOL showVersion = ([val count] > 1);
            if (!showVersion) {
                NSError *error = NULL;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d+\\.\\d+\\.\\d+(\\.\\d+)?$" options:NSRegularExpressionCaseInsensitive error:&error];
                showVersion = ![regex numberOfMatchesInString:version options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0,[version length])];
            }
            if (showVersion) fullname = [[NSArray arrayWithObjects:fullname, @" (", version, @")", nil] componentsJoinedByString:@""];
            OpenWithObject *a = [[OpenWithObject alloc] initWithFullname:fullname app:app[2] icon:app[1]];
            
            [apps addObject:a];
        }
    }
    
    
    return apps;
}

int64_t SystemIdleTime(void) {
    int64_t idlesecs = -1;
    io_iterator_t iter = 0;
    if (IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOHIDSystem"), &iter) == KERN_SUCCESS) {
        io_registry_entry_t entry = IOIteratorNext(iter);
        if (entry) {
            CFMutableDictionaryRef dict = NULL;
            if (IORegistryEntryCreateCFProperties(entry, &dict, kCFAllocatorDefault, 0) == KERN_SUCCESS) {
                CFNumberRef obj = CFDictionaryGetValue(dict, CFSTR("HIDIdleTime"));
                if (obj) {
                    int64_t nanoseconds = 0;
                    if (CFNumberGetValue(obj, kCFNumberSInt64Type, &nanoseconds)) {
                        idlesecs = (nanoseconds >> 30); // Divide by 10^9 to convert from nanoseconds to seconds.
                    }
                }
                CFRelease(dict);
            }
            IOObjectRelease(entry);
        }
        IOObjectRelease(iter);
    }
    
    return idlesecs;
}

NSData *passwordHash(NSString *password, NSData *currentSalt) {
    
    
    NSMutableData *hashData = [NSMutableData dataWithData:currentSalt];
    
    [hashData appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
    
    [hashData appendData:currentSalt];
    
    return  MTSha256(hashData);
}

NSDictionary *audioTags(AVURLAsset *asset) {
    
    __block NSString *artistName = @"";
    __block NSString *songName = @"";
    
    if(NSAppKitVersionNumber >= NSAppKitVersionNumber10_10) {
        
        
        
        [asset.availableMetadataFormats enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
            
            NSArray *metadata = [asset metadataForFormat:obj];
            
            for (AVMutableMetadataItem *metaItem in metadata) {
                
                NSLog(@"%@",metaItem.identifier);
                
                if([metaItem.identifier isEqualToString:AVMetadataIdentifierID3MetadataLeadPerformer]) {
                    artistName = (NSString *) metaItem.value;
                } else if([metaItem.identifier isEqualToString:AVMetadataIdentifierID3MetadataTitleDescription]) {
                    songName = (NSString *) metaItem.value;
                } else if([metaItem.identifier isEqualToString:AVMetadataiTunesMetadataKeyArtist]) {
                    artistName = (NSString *) metaItem.value;
                } else if([metaItem.identifier isEqualToString:AVMetadataiTunesMetadataKeySongName]) {
                    songName = (NSString *) metaItem.value;
                } else if([metaItem.identifier isEqualToString:AVMetadataQuickTimeUserDataKeyArtist]) {
                    artistName = (NSString *) metaItem.value;
                } else if([metaItem.identifier isEqualToString:AVMetadataQuickTimeUserDataKeyTrackName]) {
                    songName = (NSString *)metaItem.value;
                } else if([metaItem.identifier isEqualToString:AVMetadataCommonIdentifierArtist]) {
                    artistName = (NSString *) metaItem.value;
                } else if([metaItem.identifier isEqualToString:AVMetadataCommonIdentifierTitle]) {
                    songName = (NSString *) metaItem.value;
                } else if([metaItem.identifier hasSuffix:@"wrt"]) {
                    artistName = (NSString *)metaItem.value;
                } else if([metaItem.identifier hasSuffix:@"nam"]) {
                    songName = (NSString *)metaItem.value;
                }
                
            }
            
            if(artistName.length > 0 && songName.length > 0)
                *stop = YES;
            
        }];
        
        
    }
    
    return @{@"artist":[artistName trim],@"songName":[songName trim]};
}


NSString *first_domain_character(NSString *url) {
    if(url != nil)
    {
        
        if(![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"] && ![url hasPrefix:@"ftp://"])
            return [[url substringToIndex:1] uppercaseString];
        
        NSURLComponents *components = [[NSURLComponents alloc] initWithString:url];
        
        return [[components.host substringToIndex:1] uppercaseString];
    }
    
    return @"L";
}

NSString *path_for_external_link(NSString *link) {
    return [NSString stringWithFormat:@"%@/%ld.%@",[FileUtils path],[link hash],[link pathExtension].length == 0 ? @"file" : [link pathExtension]];
}


NSString *display_url(NSString *url) {
    
    static NSArray *protocols;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        protocols = @[@"ftp://",@"http://",@"https://"];
    });
    
    __block NSString *displayUrl = [url copy];
    
    [protocols enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([displayUrl hasPrefix:obj]) {
            displayUrl = [displayUrl substringFromIndex:obj.length];
        }
        
    }];
    
    if([displayUrl hasSuffix:@"/"]) {
        displayUrl = [displayUrl substringToIndex:displayUrl.length - 1];
    }
    
    return displayUrl;
    
}



+ (int)convertBinaryStringToDecimalNumber:(NSString *)binaryString {
    unichar aChar;
    int value = 0;
    int index;
    for (index = 0; index<[binaryString length]; index++)
    {
        aChar = [binaryString characterAtIndex: index];
        if (aChar == '1')
            value += 1;
        if (index+1 < [binaryString length])
            value = value<<1;
    }
    return value;
}

+ (TGAudioWaveform *)waveformForPath:(NSString *)path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    
    int openError = OPUS_OK;
    OggOpusFile *opusFile = op_open_file([path UTF8String], &openError);
    if (opusFile == NULL || openError != OPUS_OK)
    {
        MTLog(@"[waveformForPath op_open_file failed: %d]", openError);
        return nil;
    } else {
        //_isSeekable = op_seekable(_opusFile);
        int64_t totalSamples = op_pcm_total(opusFile, -1);
        int32_t resultSamples = 100;
        int32_t sampleRate = (int32_t)(MAX(1, totalSamples / resultSamples));
        
        NSMutableData *samplesData = [[NSMutableData alloc] initWithLength:100 * 2];
        uint16_t *samples = samplesData.mutableBytes;
        
        int bufferSize = 1024 * 128;
        int16_t *sampleBuffer = malloc(bufferSize);
        uint64_t sampleIndex = 0;
        uint16_t peakSample = 0;
        
        int index = 0;
        
        while (true) {
            int readSamples = op_read(opusFile, sampleBuffer, bufferSize / 2, NULL);
            for (int i = 0; i < readSamples; i++) {
                uint16_t sample = (uint16_t)ABS(sampleBuffer[i]);
                if (sample > peakSample) {
                    peakSample = sample;
                }
                if (sampleIndex++ % sampleRate == 0) {
                    if (index < resultSamples) {
                        samples[index++] = peakSample;
                    }
                    peakSample = 0;
                }
            }
            if (readSamples == 0) {
                break;
            }
        }
        
        int64_t sumSamples = 0;
        for (int i = 0; i < resultSamples; i++) {
            sumSamples += samples[i];
        }
        uint16_t peak = (uint16_t)(sumSamples * 1.8f / resultSamples);
        if (peak < 2500) {
            peak = 2500;
        }
        
        for (int i = 0; i < resultSamples; i++) {
            uint16_t sample = (uint16_t)((int64_t)samples[i]);
            if (sample > peak) {
                samples[i] = peak;
            }
        }
        
        free(sampleBuffer);
        op_free(opusFile);
        
        TGAudioWaveform *waveform = [[TGAudioWaveform alloc] initWithSamples:samplesData peak:peak];
        
        NSData *bitstream = [waveform bitstream];
        waveform = [[TGAudioWaveform alloc] initWithBitstream:bitstream bitsPerSample:5];
        NSData *convertedBitstream = [waveform bitstream];
        if (![convertedBitstream isEqualToData:bitstream]) {
            MTLog(@"Bitstreams before and after don't match");
        }
        
        return waveform;
    }
}

NSArray *document_preview_mime_types() {
    static NSArray *types;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        types = @[@"image/bmp",@"image/jpeg",@"image/jpg",@"image/png",@"image/tiff",@"image/webp"];
    });
    
    return types;
}

@end