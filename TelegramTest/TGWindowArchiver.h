//
//  TGWindowArchiver.h
//  Telegram
//
//  Created by keepcoder on 05.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGWindowArchiver : NSObject<NSCoding>

@property (nonatomic,assign) NSSize size;
@property (nonatomic,assign) NSPoint origin;
@property (nonatomic,strong,readonly) NSString *requiredName;

- (id)initWithName:(NSString *)name;

+(TGWindowArchiver *)find:(NSString *)name;

- (void)save;

@end
