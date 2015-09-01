//
//  HistoryResponse.h
//  Telegram
//
//  Created by keepcoder on 27.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGHistoryResponse : NSObject

@property (nonatomic,strong,readonly) NSArray *result;
@property (nonatomic,strong,readonly) TGMessageHole *botHole;
@property (nonatomic,strong,readonly) TGMessageHole *topHole;

@property (nonatomic,strong,readonly) NSArray *groupHoles;

-(id)initWithResult:(NSArray *)result botHole:(TGMessageHole *)botHole topHole:(TGMessageHole *)topHole groupHoles:(NSArray *)groupHoles;
@end
