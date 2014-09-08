//
//  TMLeftTabViewController.h
//  Telegram
//
//  Created by keepcoder on 25.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMSimpleTabViewController.h"
#import "TMTabItem.h"

@protocol TMTabViewDelegate <NSObject>


@required
-(void)tabItemDidChanged:(TMTabItem *)item index:(NSUInteger)index;

@end


@interface TMTabViewController : TMView

@property (nonatomic,strong) NSColor *topBorderColor;
@property (nonatomic,assign) NSUInteger borderWidth;
@property (nonatomic,assign) NSUInteger selectedIndex;

@property (nonatomic,strong) id <TMTabViewDelegate> delegate;


-(void)addTab:(TMTabItem *)tab;
-(void)insertTab:(TMTabItem *)tab atIndex:(NSUInteger)index;

-(void)removeTab:(TMTabItem *)tab;
-(void)removeTabAtIndex:(NSUInteger)index;

- (void)setUnreadCount:(int)count;

@end
