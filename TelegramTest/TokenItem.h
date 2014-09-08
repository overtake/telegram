//
//  TokenItem.h
//  Telegram
//
//  Created by keepcoder on 29.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TokenItem : NSObject

@property (nonatomic,strong,readonly) NSString *title;
@property (nonatomic,assign,readonly) NSUInteger identifier;

@property (nonatomic,strong,readonly) id object;

-(id)initWithIdentified:(NSUInteger)identifier object:(id)object title:(NSString *)title;

@end
