//
//  MessageTableItemGeo.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"
#import "MessageTableItemGeo.h"
#import "TGExternalImageObject.h"
@interface MessageTableItemGeo : MessageTableItem

@property (nonatomic, strong) TGExternalImageObject *imageObject;

@property (nonatomic, assign) NSSize imageSize;

@property (nonatomic,strong) NSAttributedString *venue;
@property (nonatomic,assign) NSSize venueSize;
@end
