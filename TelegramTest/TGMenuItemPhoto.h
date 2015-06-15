//
//  TGMenuItemPhoto.h
//  Telegram
//
//  Created by keepcoder on 12.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGMenuItemPhoto : NSObject

@property (nonatomic,weak,readonly) NSMenuItem *menuItem;
@property (nonatomic,strong,readonly) TLUser *user;

@property (nonatomic,strong) TMAvaImageObject *imageObject;

-(id)initWithUser:(TLUser *)user menuItem:(NSMenuItem *)menuItem;

@end
