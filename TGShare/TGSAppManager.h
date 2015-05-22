//
//  TGSAppManager.h
//  Telegram
//
//  Created by keepcoder on 19.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGSAppManager : NSObject

+(void)showNoAuthView;
+(void)closeNoAuthView;


+(void)showPasslock:(passlockCallback)callback;
+(void)hidePasslock;
+(void)setMainView:(NSView *)view;

+(void)initializeContacts;

+(NSUserDefaults *)standartUserDefaults;

@end
