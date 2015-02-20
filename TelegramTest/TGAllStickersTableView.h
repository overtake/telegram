//
//  TGAllStickersTableView.h
//  Telegram
//
//  Created by keepcoder on 25.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTableView.h"

@interface TGAllStickersTableView : TMTableView

-(void)removeSticker:(TL_outDocument *)document;
-(void)load:(BOOL)force;

@end
