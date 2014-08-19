//
//  MessageTableItemPVG.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/3/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"

typedef enum {
    MessageTableItemPVGPhoto,
    MessageTableItemPVGVideo,
    MessageTableItemPVGGeo
} MessageTableItemPVGType;

@interface MessageTableItemPVG : MessageTableItem

@property (nonatomic, strong) TGFileLocation *userPhotoFileLocation;
@property (nonatomic, strong) TGFileLocation *fileLocation;
@property (nonatomic, strong) NSImage *cacheImage;

@property (nonatomic) int fileSize;

@end
