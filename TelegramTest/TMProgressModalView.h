//
//  TMProgressModalView.h
//  Telegram
//
//  Created by keepcoder on 02.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TMProgressModalView : TMView

-(void)successAction;
-(void)progressAction;

-(void)setDescription:(NSString *)description;

@end
