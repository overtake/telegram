//
//  TMRowItem.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMTableView;

@protocol TMRowItemDelegate <NSObject>

- (void) redrawRow;
- (void) changeSelected:(BOOL)isSelected;
- (void) checkSelected:(BOOL)isSelected;

@end

@protocol TMRowItemProtocol <NSObject>

- (NSObject *)itemForHash;
+ (NSUInteger)hash:(NSObject *)object;

@end

@interface TMRowItem : NSObject<TMRowItemProtocol>

@property (nonatomic, weak) TMTableView *table;
-(id)initWithObject:(id)object;
- (void) redrawRow;
- (NSUInteger)hash;


@property (nonatomic,assign,getter=isEditable) BOOL editable;

@end
