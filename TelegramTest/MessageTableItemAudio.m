//
//  MessageTableItemAudio.m
//  Messenger for Telegram
//
//  Created by keepcoder on 05.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemAudio.h"
#import "FileUtils.h"
#import "Telegram.h"
#import "NSStringCategory.h"
#import "TGAudioPlayerWindow.h"
#import "DownloadQueue.h"
#import "DownloadDocumentItem.h"
#import "TL_documentAttributeAudio+Extension.h"
#import "MessageTableCellAudioView.h"
#import "TGAudioGlobalController.h"
@implementation MessageTableItemAudio

- (id)initWithObject:(TLMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        
        TL_documentAttributeAudio *audio = (TL_documentAttributeAudio *) [self.document attributeWithClass:[TL_documentAttributeAudio class]];

        self.blockSize = NSMakeSize(300, 45);
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:[NSString durationTransformedValue:audio.duration] withColor:GRAY_TEXT_COLOR];
        [attr setFont:TGSystemFont(12) forRange:attr.range];
        _duration = attr;

        _waveform = audio.arrayWaveform;
        
        [self doAfterDownload];
        
        self.state = TGAudioPlayerGlobalStateWaitPlaying;
        
        [self checkStartDownload:[self.message.to_id isKindOfClass:[TL_peerChat class]] ? AutoGroupAudio : AutoPrivateAudio size:self.document.size];
        
    }
    return self;
}

-(TLDocument *)document {
    if([self.message.media isKindOfClass:[TL_messageMediaBotResult class]]) {
        return self.message.media.bot_result.document;
    } else
        return self.message.media.document;
}


-(BOOL)makeSizeByWidth:(int)width {
    
    self.contentSize = self.blockSize = NSMakeSize(width, 40);
    
    return [super makeSizeByWidth:width];
}

-(BOOL)canShare {
    return [self isset];
}



- (Class)downloadClass {
    return [DownloadDocumentItem class];
}

- (NSString *)path {
    return mediaFilePath(self.message);
}

- (BOOL)canDownload {
    return self.document.dc_id != 0;
}

- (void)audioPlayerDidFinishPlaying:(TGAudioPlayer *)audioPlayer {
     [ASQueue dispatchOnMainQueue:^{
        [self.cellView stopPlayer];
    }];
}

-(void)setState:(int)state {
    _state = state;
}

- (void)tryReadContent {
    

    if(!self.message.n_out && !self.message.readedContent) {
        [ASQueue dispatchOnMainQueue:^{
            
            self.message.flags&= ~TGREADEDCONTENT;
            [self.cellView setNeedsDisplay:YES];
            
        }];
        
        NSMutableArray *msgs = [@[@(self.message.n_id)] mutableCopy];
        
        [RPCRequest sendRequest:[TLAPI_messages_readMessageContents createWithN_id:msgs] successHandler:^(RPCRequest *request, id response) {
            
            [[MessagesManager sharedManager] readMessagesContent:msgs];
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
        }];
    }
    
}

-(DownloadItem *)downloadItem {
    
    if(super.downloadItem == nil)
        [super setDownloadItem:[DownloadQueue find:self.document.n_id]];
    
    return [super downloadItem];
}

- (int)size {
    return self.document.size;
}

- (BOOL)isset {
     return isPathExists([self path]) && [FileUtils checkNormalizedSize:self.path checksize:[self size]];
}

-(void)doAfterDownload {
    [super doAfterDownload];
    
}

-(NSArray *)emptyWaveform {
    static NSMutableArray *c;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        c = [NSMutableArray array];
        
        for (int i = 0; i < 100; i++) {
            [c addObject:@(4)];
        }
    });
    
    return c;
}

-(Class)viewClass {
    return [MessageTableCellAudioView class];
}

@end
