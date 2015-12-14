//
//  MessageTableItemMpeg.h
//  Telegram
//
//  Created by keepcoder on 10/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"

@interface MessageTableItemMpeg : MessageTableItem
@property (nonatomic,strong,readonly) TGImageObject *thumbObject;
-(NSString *)path;

@end
