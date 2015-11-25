//
//  TMInAppLinks.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/5/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMInAppLinks : NSObject

+ (NSString *) userProfile:(int)user_id;

+ (NSString *)peerProfile:(TLPeer*)peer;

+ (void) parseUrlAndDo:(NSString *)url;

@end
