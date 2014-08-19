//
//  ContentDelegate.h
//  TelegramTest
//
//  Created by keepcoder on 17.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContentDelegate <NSObject>
-(void)didChangeContent:(NSArray *)data;
@end
