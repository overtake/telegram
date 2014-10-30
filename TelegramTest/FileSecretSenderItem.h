//
//  ImageSecretSenderItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 18.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SecretSenderItem.h"

@interface FileSecretSenderItem : SecretSenderItem

- (id)initWithImage:(NSImage *)image uploadType:(UploadType)uploadType  forConversation:(TL_conversation *)conversation;
- (id)initWithPath:(NSString *)filePath uploadType:(UploadType)uploadType  forConversation:(TL_conversation *)conversation;

-(void)setUploaderType:(UploadType)type;

@end
