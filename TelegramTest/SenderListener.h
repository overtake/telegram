//
//  SenderListener.h
//  Messenger for Telegram
//
//  Created by keepcoder on 18.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SenderItem;

@protocol SenderListener <NSObject>

@optional
-(void)onStateChanged:(SenderItem *)item;
-(void)onProgressChanged:(SenderItem *)item;
-(void)onAddedListener:(SenderItem *)item;
-(void)onRemovedListener:(SenderItem *)item;
@end
