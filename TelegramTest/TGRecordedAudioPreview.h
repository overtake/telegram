//
//  TGRecordedAudioPrevew.h
//  Telegram
//
//  Created by keepcoder on 14/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGRecordedAudioPreview : TMView


@property (nonatomic,strong,readonly) NSString *audio_file;
@property (nonatomic,strong,readonly) TL_documentAttributeAudio *audioAttr;


-(void)setAudio_file:(NSString *)audio_file  audioAttr:(TL_documentAttributeAudio *)audioAttr;
@end
