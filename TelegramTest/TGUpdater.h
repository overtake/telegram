//
//  TGUpdater.h
//  Telegram
//
//  Created by keepcoder on 08.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGUpdater : NSObject

-(id)initWithVersion:(int)version token:(NSString *)token url:(NSString *)url;

-(void)itsHaveNewVersion:(void(^)(bool nVersion))callback;

-(void)startDownload:(void (^)(NSString *fpath))callback progress:(void (^)(NSUInteger progress))progressHandler;

@end
