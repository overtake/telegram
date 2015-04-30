//
//  UserInfoShortButtonView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/5/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface UserInfoShortButtonView : TMView
@property (nonatomic, strong) TMTextButton *textButton;
@property (nonatomic, assign) BOOL locked;
@property (nonatomic,strong) NSView *rightContainer;
@property (nonatomic, assign) NSPoint rightContainerOffset;

@property (nonatomic,strong,readonly) NSView *currentRightController;


+ (id) buttonWithText:(NSString *)string tapBlock:(dispatch_block_t)block;
- (id)initWithFrame:(NSRect)frame withName:(NSString *)name andBlock:(dispatch_block_t)block;

@property (nonatomic,strong) NSColor *selectedColor;
@property (nonatomic,assign) BOOL isSelected;
@end
