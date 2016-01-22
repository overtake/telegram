//
//  InlineBotMediaSecretSenderItem.m
//  Telegram
//
//  Created by keepcoder on 22/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "InlineBotMediaSecretSenderItem.h"
#import "DownloadDocumentItem.h"
#import "DownloadExternalItem.h"
@interface FileSecretSenderItem ()
-(void)performRequest;

@property (nonatomic,strong) DownloadItem *downloadItem;
@property (nonatomic,strong) DownloadEventListener *downloadEventListener;
@end

@implementation InlineBotMediaSecretSenderItem

-(id)initWithBotContextResult:(TLBotInlineResult *)result via_bot_name:(NSString *)via_bot_name conversation:(TL_conversation *)conversation {
    if(self = [super initWithConversation:conversation]) {
        
        int ttl = self.params.ttl;
        
        TLMessageMedia *media = [TL_messageMediaBotResult createWithBot_result:result query_id:-1];
        
        self.message = [TL_destructMessage45 createWithN_id:[MessageSender getFutureMessageId] flags:TGOUTUNREADMESSAGE from_id:UsersManager.currentUserId to_id:[TL_peerSecret createWithChat_id:conversation.peer.chat_id] date:[[MTNetwork instance] getTime] message:nil media:media destruction_time:0 randomId:rand_long() fakeId:[MessageSender getFakeMessageId] ttl_seconds:ttl == -1 ? 0 : ttl entities:nil via_bot_name:via_bot_name reply_to_random_id:0 out_seq_no:-1 dstate:DeliveryStatePending];
        
        [self takeAndFillReplyMessage];
        
        [self.message save:YES];
        
        
    }
    
    return self;
}

-(void)performRequest {
    
    self.filePath = mediaFilePath(self.message);
    
    if([self.message.media.bot_result isKindOfClass:[TL_botInlineMediaResultDocument class]]) {
        if(self.message.media.document != nil) {
            if(checkFileSize(self.filePath, self.message.media.bot_result.document.size)) {
                [self startSenderAfterDownload];
            } else
                [self downloadBeforeSending];
        } else {
            if(fileSize(self.filePath) > 0) {
                [self startSenderAfterDownload];
            }else
                [self downloadBeforeSending];
        }
    }
    
}

-(void)downloadBeforeSending {
    
    
    if([self.message.media.bot_result isKindOfClass:[TL_botInlineMediaResultDocument class]]) {
        
       NSString *external_path = self.message.media.bot_result.content_url;
        
        if(self.message.media.bot_result.document == nil) {
            self.downloadItem = [[DownloadExternalItem alloc] initWithObject:external_path];
        } else {
            self.downloadItem = [[DownloadDocumentItem alloc] initWithObject:self.message];
        }
        
        self.downloadEventListener = [[DownloadEventListener alloc] init];
        
        weak();
        
        [self.downloadEventListener setProgressHandler:^(DownloadItem *item) {
            strongWeak();
            
            if(strongSelf != nil)
                [strongSelf updateProgress];
        }];
        
        [self.downloadEventListener setCompleteHandler:^(DownloadItem *item) {
            strongWeak();
           
            if(strongSelf != nil) {
                [strongSelf updateProgress];
                [strongSelf startSenderAfterDownload];
            }
        }];
        
        [self.downloadEventListener setErrorHandler:^(DownloadItem *item) {
            
        }];
        
        [self.downloadItem addEvent:self.downloadEventListener];
        
        [self.downloadItem start];
        
    }
}

-(void)startSenderAfterDownload {
    
    if([self.message.media.bot_result isKindOfClass:[TL_botInlineMediaResultDocument class]]) {
        
        TLBotInlineResult *bot_result = self.message.media.bot_result;
        
        CGImageRef quickLookIcon = QLThumbnailImageCreate(NULL, (__bridge CFURLRef)[NSURL fileURLWithPath:self.filePath], CGSizeMake(90, 90), nil);
        
        NSData *thumbData;
        NSImage *thumb;
        if (quickLookIcon != NULL) {
            thumb = [[NSImage alloc] initWithCGImage:quickLookIcon size:NSMakeSize(0, 0)];
            CFRelease(quickLookIcon);
            
            thumbData = compressImage([ thumb TIFFRepresentation], 0.4);
        }
        
        TLPhotoSize *size = [TL_photoCachedSize createWithType:@"x" location:[TL_fileLocation createWithDc_id:0 volume_id:0 local_id:0 secret:0] w:thumb.size.width h:thumb.size.height bytes:thumbData];
        
        if(!thumbData) {
            size = [TL_photoSizeEmpty createWithType:@"x"];
        }
        
        self.message.media = [TL_messageMediaDocument createWithDocument:[TL_outDocument createWithN_id:rand_long() access_hash:0 date:[[MTNetwork instance] getTime] mime_type:mimetypefromExtension([self.filePath pathExtension]) size:(int)fileSize(self.filePath) thumb:size dc_id:0 file_path:self.filePath attributes:[@[[TL_documentAttributeFilename createWithFile_name:[self.filePath lastPathComponent]]] mutableCopy]] caption:@""];
        
        if([bot_result.type isEqualToString:@"gif"]) {
            [self.message.media.document.attributes addObjectsFromArray:@[[TL_documentAttributeAnimated create]]];
        }
        
    }
    
    
    
    [super performRequest];
}

-(void)updateProgress {
    
}


@end
