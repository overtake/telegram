//
//  TGForwardObject.h
//  Telegram
//
//  Created by keepcoder on 17.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGForwardObject : NSObject

@property (nonatomic,strong,readonly) NSArray *messages;

@property (nonatomic,strong,readonly) NSAttributedString *names;
@property (nonatomic,strong,readonly) NSAttributedString *fwd_desc;

-(id)initWithMessages:(NSArray *)messages;

@end
