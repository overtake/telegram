//
//  MediaCollectionItemView.h
//  Messenger for Telegram
//
//  Created by keepcoder on 08.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MediaCollectionItem.h"
@interface MediaCollectionItemView : TMView
@property (weak) IBOutlet NSImageView *imageView;

@property (nonatomic,strong) MediaCollectionItem * item;

@end
