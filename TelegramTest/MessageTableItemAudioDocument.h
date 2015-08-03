//
//  MessageTableItemAudioDocument.h
//  Telegram
//
//  Created by keepcoder on 17.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemAudio.h"

@interface MessageTableItemAudioDocument : MessageTableItemAudio

@property (nonatomic,strong) NSString *fileSize;

@property (nonatomic,strong) NSString *id3fileName;

-(NSString *)fileName;

@property (nonatomic,strong,readonly) NSMutableAttributedString *id3AttributedString;
@property (nonatomic,strong,readonly) NSMutableAttributedString *id3AttributedStringHeader;
@property (nonatomic,strong,readonly) DownloadEventListener *secondDownloadListener;

@end
