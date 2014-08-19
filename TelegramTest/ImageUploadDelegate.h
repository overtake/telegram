
//
//  ImageUploadDelegate.h
//  TelegramTest
//
//  Created by keepcoder on 02.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageUploadDelegate <NSObject>
-(void)uploadDidStart;
-(void)uploadDidProgress:(int)current total:(int)total;
-(void)uploadDidEnd:(TL_inputFile *)input;
@end
