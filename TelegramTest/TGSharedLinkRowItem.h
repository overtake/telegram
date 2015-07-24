//
//  TGSharedLinkRowItem.h
//  Telegram
//
//  Created by keepcoder on 24.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGSharedLinkRowItem : NSObject

@property (nonatomic,strong,readonly) MessageTableItem *item;
-(id)initWithObject:(MessageTableItem *)item;
@end
