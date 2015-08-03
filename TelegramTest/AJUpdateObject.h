//
//  AJUpdateObject.h
//  Telegram
//
//  Created by keepcoder on 09.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "AJObject.h"

@interface AJUpdateObject : AJObject

@property (nonatomic,assign,readonly) int ver;
@property (nonatomic,strong,readonly) NSString *download_url;
@property (nonatomic,strong,readonly) NSString *md5sum;

@end
