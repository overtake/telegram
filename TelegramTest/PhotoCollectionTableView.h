//
//  PhotoCollectionTableView.h
//  Telegram
//
//  Created by keepcoder on 04.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PhotoTableItemView.h"
@interface PhotoCollectionTableView : TMTableView


-(void)setItems:(NSArray *)items conversation:(TL_conversation *)conversation;

@end
