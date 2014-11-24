//
//  TGModernEncryptedUpdates.h
//  Telegram
//
//  Created by keepcoder on 27.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGModernEncryptedUpdates : NSObject

-(void)proccessUpdate:(TLEncryptedMessage *)update;


@end
