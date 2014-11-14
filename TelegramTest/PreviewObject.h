//
//  PreviewObject.h
//  Messenger for Telegram
//
//  Created by keepcoder on 10.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreviewObject : NSObject
@property (nonatomic, strong, readonly) id media;
@property (nonatomic, assign, readonly) long msg_id;
@property (nonatomic, assign, readonly) int peerId;

@property (nonatomic,weak) id reservedObject;


-(id)initWithMsdId:(long)msg_id media:(id)media peer_id:(int)peer_id;
@end
