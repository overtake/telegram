//
//  SelectTextManager.h
//  Telegram
//
//  Created by keepcoder on 03.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TGCTextView;


@protocol SelectTextDelegate <NSObject>

-(id)identifier;
-(NSString *)string;

@end


@protocol SelectTextManagerDelegate <NSObject>

-(void)clearSelection;

@end

@interface SelectTextManager : NSResponder

+(void)addSelectManagerDelegate:(id<SelectTextManagerDelegate>)delegate;
+(void)removeSelectManagerDelegate:(id<SelectTextManagerDelegate>)delegate;

+(void)addRange:(NSRange)range forItem:(id<SelectTextDelegate>)item;
+(void)removeRangeForItem:(id<SelectTextDelegate>)item;
+(void)clear;
+(NSRange)rangeForItem:(id<SelectTextDelegate>)item;

+(void)becomeFirstResponder;

+(NSUInteger)count;

+(void)enumerateItems:(void (^)(id obj, NSRange range))block;
+(id)instance;

+(NSString *)fullString;

@end
