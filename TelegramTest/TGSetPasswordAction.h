//
//  TGSetPasswordAction.h
//  Telegram
//
//  Created by keepcoder on 27.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGSetPasswordAction : NSObject

typedef BOOL (^actionBlock)(NSString *inputPassword);

@property (nonatomic,strong) NSString *error;

@property (nonatomic,copy) actionBlock callback;

@property (nonatomic,strong) NSString *title;

@property (nonatomic,strong) NSString *header;

@property (nonatomic,strong) NSString *desc;

@property (nonatomic,weak) id controller;

@property (nonatomic,strong) NSString *defaultValue;

@property (nonatomic,assign) BOOL hasButton;

@end
