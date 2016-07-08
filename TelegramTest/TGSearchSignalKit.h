//
//  TGSearchSignalKit.h
//  Telegram
//
//  Created by keepcoder on 06/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGSearchKitResult : NSObject

@end

@interface TGSearchKitItem : NSObject

@property (nonatomic,strong,readonly) NSArray *added;
@property (nonatomic,assign,readonly) SEL indexSelector;
@property (nonatomic,assign,readonly) SEL uniqueKeySelector;

@property (nonatomic,strong,readonly) NSString *URI;

-(id)initWithAddedArray:(NSArray *)added URI:(NSString *)URI indexSelector:(SEL)indexSelector uniqueKeySelector:(SEL)uniqueKeySelector;

@end

@interface TGSearchSignalKit : NSObject



-(void)reIndexSearchWithItem:(TGSearchKitItem *)changeItem;

-(SSignal *)search:(NSString *)query parser:(id (^)(id object))parser;

@end
