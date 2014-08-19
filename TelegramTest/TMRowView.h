//
//  TMRowView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/18/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TMRowItem.h"

@interface TMRowView : TMView<TMRowItemDelegate>

@property (nonatomic, strong) TMRowItem *rowItem;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isHover;
- (void)setHover:(BOOL)hover redraw:(BOOL)redraw;

@property (nonatomic) NSUInteger row;
@property (nonatomic, strong) NSColor *selectedBackgroundColor;
@property (nonatomic, strong) NSColor *normalBackgroundColor;
- (void) setItem:(id)item selected:(BOOL)isSelected;
@end
