//
//  TGMultipleRequestCallback.h
//  Telegram
//
//  Created by keepcoder on 18/03/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGMultipleRequestCallback : NSObject
@property (nonatomic,strong,readonly) NSMutableArray *callbacks;
@property (nonatomic,strong,readonly) RPCRequest *request;

-(id)initWithRequest:(RPCRequest *)request;

@end
