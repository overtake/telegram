//
//  SearchSeparatorItem.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMElements.h"

@interface SearchSeparatorItem : TMRowItem

@property (nonatomic, strong) NSString *oneName;
@property (nonatomic, strong) NSString *pluralName;
@property (nonatomic) int itemCount;

- (id)initWithOneName:(NSString *)oneName pluralName:(NSString *)pluralName;

@end
