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
#import "DownloadAudioItem.h"
#import "MessagetableCellAudioController.h"
#import "TGAudioPlayerWindow.h"
#import "DownloadQueue.h"
@implementation MessageTableItemAudio

- (id)initWithObject:(TLMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        self.blockSize = NSMakeSize(200, 45);
        self.duration = [NSString durationTransformedValue:object.media.audio.duration];
        self.message.media.audio.duration = self.message.media.audio.duration == 0 ? 1 : self.message.media.audio.duration;
        
        
        if([self isset])
            self.state = AudioStateWaitPlaying;
        else
            self.state = AudioStateWaitDownloading;
        
        
        [self checkStartDownload:[self.message.to_id isKindOfClass:[TL_peerChat class]] ? AutoGroupAudio : AutoPrivateAudio size:self.message.media.audio.size];
        
    }
    return self;
}

-(BOOL)canShare {
    return [self isset];
}



- (Class)downloadClass {
    return [DownloadAudioItem class];
}

- (NSString *)path {
    return mediaFilePath(self.message.media);
}

- (BOOL)canDownload {
    return self.message.media.audio.dc_id != 0;
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
    return [DownloadQueue find:self.message.media.audio.n_id];
}

- (int)size {
    return self.message.media.audio.size;
}

- (BOOL)isset {
     return isPathExists([self path]) && [FileUtils checkNormalizedSize:self.path checksize:[self size]];
}

@end
