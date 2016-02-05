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
#import "MessagetableCellAudioController.h"
#import "TGAudioPlayerWindow.h"
#import "DownloadQueue.h"
#import "DownloadDocumentItem.h"
#import "TL_documentAttributeAudio+Extension.h"
@implementation MessageTableItemAudio

- (id)initWithObject:(TLMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        
        TL_documentAttributeAudio *audio = (TL_documentAttributeAudio *) [object.media.document attributeWithClass:[TL_documentAttributeAudio class]];

        
        self.blockSize = NSMakeSize(200, 45);
        self.duration = [NSString durationTransformedValue:audio.duration];

        NSArray *waveform = [FileUtils arrayWaveform:audio.waveform];
        
        if([self isset])
            self.state = AudioStateWaitPlaying;
        else
            self.state = AudioStateWaitDownloading;
        
        
        [self checkStartDownload:[self.message.to_id isKindOfClass:[TL_peerChat class]] ? AutoGroupAudio : AutoPrivateAudio size:self.message.media.document.size];
        
    }
    return self;
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
    return self.message.media.document.dc_id != 0;
}

- (void)audioPlayerDidFinishPlaying:(TGAudioPlayer *)audioPlayer {
     [ASQueue dispatchOnMainQueue:^{
        [self.cellView stopPlayer];
    }];
}

-(void)setState:(AudioState)state {
    _state = state;
}

- (void)audioPlayerDidStartPlaying:(TGAudioPlayer *)audioPlayer {
    

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
        [super setDownloadItem:[DownloadQueue find:self.message.media.document.n_id]];
    
    return [super downloadItem];
}

- (int)size {
    return self.message.media.document.size;
}

- (BOOL)isset {
     return isPathExists([self path]) && [FileUtils checkNormalizedSize:self.path checksize:[self size]];
}

@end
