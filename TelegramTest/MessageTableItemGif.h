//
//  MessageTableItemGif.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/3/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemDocument.h"
#import "TGImageObject.h"
@interface MessageTableItemGif : MessageTableItemDocument
@property (nonatomic, strong) TLDocument *document;
@property (nonatomic, strong) TLFileLocation *previewLocation;

@property (nonatomic,strong) TGImageObject *imageObject;
@end
