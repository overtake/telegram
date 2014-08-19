//
//  DialogDelegate.h
//  TelegramTest
//
//  Created by keepcoder on 18.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DialogDelegate <NSObject>
-(void)didChangeContent:(id)dialog;
@end
